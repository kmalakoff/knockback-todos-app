###
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
###

$(document).ready(->

  # set the language
  locale_manager.setLocale('fr-FR')

  # add a doubleclick handler to KO
  ko.bindingHandlers.dblclick =
    init: (element, value_accessor, all_bindings_accessor, view_model) ->
      $(element).dblclick(ko.utils.unwrapObservable(value_accessor()))

  ###################################
  # Model: http://en.wikipedia.org/wiki/Model_view_controller
  # ORM: http://en.wikipedia.org/wiki/Object-relational_mapping
  ###################################

  # Settings
  class PrioritiesSetting extends Backbone.Model

  class PrioritiesSettingList extends Backbone.Collection
    model: PrioritiesSetting
    localStorage: new Store("kb_priorities") # Save all of the todo items under the `"kb_priorities"` namespace.

  priorities = new PrioritiesSettingList()
  priorities.fetch({success: (collection) ->
    collection.create({id:'high', color:'#c00020'}) if not collection.get('high')
    collection.create({id:'medium', color:'#c08040'}) if not collection.get('medium')
    collection.create({id:'low', color:'#00ff60'}) if not collection.get('low')
  })

  # Todos
  class Todo extends Backbone.Model
    defaults: -> return {created_at: new Date()}
    set: (attrs) ->
      attrs['done_at'] = new Date(attrs['done_at']) if attrs and attrs.hasOwnProperty('done_at') and _.isString(attrs['done_at'])
      attrs['created_at'] = new Date(attrs['created_at']) if attrs and attrs.hasOwnProperty('created_at') and _.isString(attrs['created_at'])
      super
    isDone: -> !!@get('done_at')
    done: (done) -> @save({done_at: if done then new Date() else null})
    destroyDone: (done) -> @save({done_at: if done then new Date() else null})

  class TodoList extends Backbone.Collection
    model: Todo
    localStorage: new Store("kb_todos") # Save all of the todo items under the `"kb_todos"` namespace.
    doneCount: -> @models.reduce(((prev,cur)-> return prev + if !!cur.get('done_at') then 1 else 0), 0)
    remainingCount: -> @models.length - @doneCount()
    allDone: -> return @filter((todo) -> return !!todo.get('done_at'))

  todos = new TodoList()
  todos.fetch()

  ###################################
  # MVVM: http://en.wikipedia.org/wiki/Model_View_ViewModel
  ###################################

  # Localization
  LanguageOptionViewModel = (locale) ->
    @id = locale
    @label = locale_manager.localeToLabel(locale)
    @option_group = 'lang'
    @onClick = ->
    return this

  languages_view_model =
    language_options: ko.observableArray([])
  languages_view_model.current_language = ko.dependentObservable(
    read: -> return locale_manager.getLocale()
    write: (new_locale) -> locale_manager.setLocale(new_locale)
    owner: todo_list_view_model
  )
  languages_view_model.language_options.push(new LanguageOptionViewModel(locale)) for locale in locale_manager.getLocales()
  ko.applyBindings(languages_view_model, $('#todo-languages')[0])

  # Settings
  PrioritySettingsViewModel = (model) ->
    @priority = kb.observable(model, {key: 'id'})
    @priority_text = ko.dependentObservable(=> return locale_manager.get(@priority()))
    @priority_color = kb.observable(model, {key: 'color'})
    return this

  window.settings_view_model =
    priority_settings: []
    default_priority: ko.observable()
    default_priority_color: ko.observable()
    setDefaultPriority: (priority) ->
      settings_view_model.default_priority(priority)
      settings_view_model.default_priority_color(settings_view_model.getColorByPriority(priority))
    getColorByPriority: (priority) ->
      (return view_model.priority_color() if view_model.priority() == priority) for view_model in settings_view_model.priority_settings
      return ''
    priorityToRank: (priority) ->
      switch priority
        when 'high' then return 0
        when 'medium' then return 1
        when 'low' then return 2

  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(new Backbone.ModelRef(priorities, 'high')))
  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(new Backbone.ModelRef(priorities, 'medium')))
  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(new Backbone.ModelRef(priorities, 'low')))
  settings_view_model.setDefaultPriority('medium')

  # Header
  header_view_model =
    title: "Todos"
  ko.applyBindings(header_view_model, $('#todo-header')[0])

  create_view_model =
    input_text:                 ko.observable('')
    input_placeholder_text:     kb.observable(locale_manager, {key: 'placeholder_create'})
    input_tooltip_text:         kb.observable(locale_manager, {key: 'tooltip_create'})
    priority_color:             ko.dependentObservable(-> return window.settings_view_model.default_priority_color())

    setDefaultPriority: (priority) -> settings_view_model.setDefaultPriority(ko.utils.unwrapObservable(priority))
    addTodo: (event) ->
      text = @input_text()
      return true if (!text || event.keyCode != 13)
      todos.create({text: text, priority: settings_view_model.default_priority()})
      @input_text('')
  ko.applyBindings(create_view_model, $('#todo-create')[0])

  # Content
  SortingOptionViewModel = (string_id) ->
    @id = string_id
    @label = kb.observable(locale_manager, {key: string_id})
    @option_group = 'list_sort'
    return this

  TodoViewModel = (model) ->
    @text = kb.observable(model, {key: 'text', write: ((text) -> model.save({text: text}))}, this)
    @edit_mode = ko.observable(false)
    @toggleEditMode = => @edit_mode(!@edit_mode())
    @onEnterEndEdit = (event) => @toggleEditMode() if (event.keyCode == 13)

    @created_at = model.get('created_at')
    @done = kb.observable(model, {key: 'done_at', read: (-> return model.isDone()), write: ((done) -> model.done(done)) }, this)
    @done_text = kb.observable(model, {key: 'done_at', read: (->
      label = kb.observable(locale_manager, {key: 'label_completed'}) # use to register a dependency
      return if !!model.get('done_at') then return "#{label()}: #{locale_manager.localizeDate(model.get('done_at'))}" else ''
    )})

    @setTodoPriority = (priority) -> model.save({priority: ko.utils.unwrapObservable(priority)})
    @priority_color = kb.observable(model, {key: 'priority', read: -> settings_view_model.getColorByPriority(model.get('priority'))})

    @destroyTodo = => model.destroy()
    return this

  todo_list_view_model =
    todos: ko.observableArray([])
    # _list_sorting_mode: 'label_name'
    _list_sorting_mode: null # TODO: bug fix

  todo_list_view_model.list_sorting_mode = ko.dependentObservable(
    read: -> return todo_list_view_model._list_sorting_mode
    write: (new_mode) ->
      todo_list_view_model._list_sorting_mode = new_mode
      switch new_mode
        when 'label_name' then window.collection_observable.sorting((models, model)-> return _.sortedIndex(models, model, (test) -> test.get('text')))
        when 'label_created' then window.collection_observable.sorting((models, model)-> return _.sortedIndex(models, model, (test) -> test.get('created_at').valueOf()))
        when 'label_priority' then window.collection_observable.sorting((models, model)-> return _.sortedIndex(models, model, (test) -> settings_view_model.priorityToRank(test.get('priority'))))
    owner: todo_list_view_model
  )
  window.collection_observable = kb.collectionObservable(todos, todo_list_view_model.todos, { viewModelCreate: (model) -> return new TodoViewModel(model) })
  todo_list_view_model.sort_visible = ko.dependentObservable(-> collection_observable().length)
  todo_list_view_model.sorting_options = [new SortingOptionViewModel('label_name'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_priority')]
  ko.applyBindings(todo_list_view_model, $('#todo-list')[0])

  # TODO: bug fix - also for locale
  todo_list_view_model._list_sorting_mode = 'label_name'
  todo_list_view_model.list_sorting_mode(todo_list_view_model._list_sorting_mode)

  # Stats Footer
  stats_view_model =
    remaining_text: ko.dependentObservable(->
      count = collection_observable.collection().remainingCount(); return '' if not count
      kb.observable(locale_manager, {key: 'remaining_template_s'}) # use to register a dependency
      return locale_manager.get((if count == 1 then 'remaining_template_s' else 'remaining_template_pl'), count)
    )
    clear_text: ko.dependentObservable(->
      count = collection_observable.collection().doneCount(); return '' if not count
      kb.observable(locale_manager, {key: 'clear_template_s'}) # use to register a dependency
      return locale_manager.get((if count == 1 then 'clear_template_s' else 'clear_template_pl'), count)
    )
    onDestroyDone: -> model.destroy() for model in todos.allDone()
  ko.applyBindings(stats_view_model, $('#todo-stats')[0])

  footer_view_model =
    instructions_text: kb.observable(locale_manager, {key: 'instructions'})
  ko.applyBindings(footer_view_model, $('#todo-footer')[0])

  ###################################
  # Dynamic Interactions
  # jQuery: http://jquery.com/
  ###################################

  $all_priority_pickers = $('body').find('.priority-picker-tooltip')
  $('.colorpicker').mColorPicker()
  $('.colorpicker').bind('colorpicked', ->
    model = priorities.get($(this).attr('id'))
    model.save({color: $(this).val()}) if model
  )
  $('.priority-color-swatch').click(->
    $priority_picker = $(this).children('.priority-picker-tooltip')
    $all_priority_pickers.not($priority_picker).hide()
    $priority_picker.toggle()
  )
  $('body').click((event)-> $all_priority_pickers.hide() if not $(event.target).children('.priority-picker-tooltip').length and not $(event.target).closest('.priority-picker-tooltip').length ) # close all pickers
)