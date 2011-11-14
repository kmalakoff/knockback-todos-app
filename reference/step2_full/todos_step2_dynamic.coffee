###
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
###

$(document).ready(->

  # set the language
  locale_manager.setLocale('it-IT')

  # add a doubleclick handler to KO
  ko.bindingHandlers.dblclick =
    init: (element, value_accessor, all_bindings_accessor, view_model) ->
      $(element).dblclick(ko.utils.unwrapObservable(value_accessor()))

  ###################################
  # Model: http://en.wikipedia.org/wiki/Model_view_controller
  # ORM: http://en.wikipedia.org/wiki/Object-relational_mapping
  ###################################

  # Priority Settings
  class PrioritiesSetting
    constructor: (@attributes) ->
    get: (attribute_name) -> return @attributes[attribute_name]

  priorities =
    models: [
      new PrioritiesSetting({id:'high',   color:'#c00020'}),
      new PrioritiesSetting({id:'medium', color:'#c08040'}),
      new PrioritiesSetting({id:'low',    color:'#00ff60'})
    ]

  # Todos
  class Todo extends Backbone.Model
    defaults: -> return {created_at: new Date()}
    set: (attrs) ->
      attrs['done_at'] = new Date(attrs['done_at']) if attrs and attrs.hasOwnProperty('done_at') and _.isString(attrs['done_at'])
      super
    isDone: -> !!@get('done_at')
    done: (done) -> @save({done_at: if done then new Date() else null})
    destroyDone: (done) -> @save({done_at: if done then new Date() else null})

  class TodoList extends Backbone.Collection
    model: Todo
    localStorage: new Store("kb_todos") # Save all of the todo items under the `"todos"` namespace.
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
    return this

  $('#todo-languages').append($("#option-template").tmpl(new LanguageOptionViewModel(locale))) for locale in locale_manager.getLocales()
  $('#todo-languages').find("##{locale_manager.getLocale()}").attr(checked:'checked')

  # Priority Settings
  PrioritySettingsViewModel = (model) ->
    @priority = model.get('id')
    @priority_text = locale_manager.get(@priority)
    @priority_color = model.get('color')
    return this

  window.settings_view_model =
    priority_settings: []
    getColorByPriority: (priority) ->
      (return view_model.priority_color if view_model.priority == priority) for view_model in settings_view_model.priority_settings
      return ''
  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(model)) for model in priorities.models
  settings_view_model.default_priority = settings_view_model.priority_settings[0].priority
  settings_view_model.default_priority_color = settings_view_model.priority_settings[0].priority_color

  # Header
  header_view_model =
    title: "Todos"
  $('#todo-header').append($("#header-template").tmpl(header_view_model))

  create_view_model =
    input_text:                 ko.observable('')
    input_placeholder_text:     locale_manager.get('placeholder_create')
    input_tooltip_text:         locale_manager.get('tooltip_create')
    priority_color:             settings_view_model.default_priority_color

    addTodo: (event) ->
      text = @input_text()
      return true if (!text || event.keyCode != 13)
      todos.create({text: text, priority: settings_view_model.default_priority})
      @input_text('')

  ko.applyBindings(create_view_model, $('#todo-create')[0])

  # Content
  SortingOptionViewModel = (string_id) ->
    @id = string_id
    @label =  locale_manager.get(string_id)
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
      return if !!model.get('done_at') then return "#{locale_manager.get('label_completed')}: #{locale_manager.localizeDate(model.get('done_at'))}" else ''
    )})
    @priority_color = settings_view_model.getColorByPriority(model.get('priority'))
    @destroyTodo = => model.destroy()
    return this

  todo_list_view_model =
    todos: ko.observableArray([])
  collection_observable = kb.collectionObservable(todos, todo_list_view_model.todos, { viewModelCreate: (model) -> return new TodoViewModel(model) })
  todo_list_view_model.sort_visible = ko.dependentObservable(-> collection_observable().length)
  todo_list_view_model.sorting_options = [new SortingOptionViewModel('label_name'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_priority')]
  ko.applyBindings(todo_list_view_model, $('#todo-list')[0])
  $('#todo-list-sorting').find('#label_created').attr(checked:'checked')

  # Stats Footer
  stats_view_model =
    remaining_text: ko.dependentObservable(->
      count = collection_observable.collection().remainingCount(); return '' if not count
      return locale_manager.get((if count == 1 then 'remaining_template_s' else 'remaining_template_pl'), count)
    )
    clear_text: ko.dependentObservable(->
      count = collection_observable.collection().doneCount(); return '' if not count
      return locale_manager.get((if count == 1 then 'clear_template_s' else 'clear_template_pl'), count)
    )
    onDestroyDone: -> model.destroy() for model in todos.allDone()
  ko.applyBindings(stats_view_model, $('#todo-stats')[0])

  footer_view_model =
    instructions_text: locale_manager.get('instructions')
  $('#todo-footer').append($("#footer-template").tmpl(footer_view_model))

  ###################################
  # Dynamic Interactions
  # jQuery: http://jquery.com/
  ###################################

  $all_priority_pickers = $('body').find('.priority-picker-tooltip')
  $('.colorpicker').mColorPicker()
  $('.priority-color-swatch').click(->
    $priority_picker = $(this).children('.priority-picker-tooltip')
    $all_priority_pickers.not($priority_picker).hide()
    $priority_picker.toggle()
  )
  $('body').click((event)-> $all_priority_pickers.hide() if not $(event.target).children('.priority-picker-tooltip').length and not $(event.target).closest('.priority-picker-tooltip').length ) # close all pickers
)