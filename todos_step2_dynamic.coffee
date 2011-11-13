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

  ###################################
  # Model: http://en.wikipedia.org/wiki/Model_view_controller
  # ORM: http://en.wikipedia.org/wiki/Object-relational_mapping
  ###################################

  # Priority Settings
  class PrioritiesSetting
    constructor: (@attributes) ->
    get: (attribute_name) -> return @attributes[attribute_name]

  priority_settings =
    models: [
      new PrioritiesSetting({priority:'high',   color:'#c00020'}),
      new PrioritiesSetting({priority:'medium', color:'#c08040'}),
      new PrioritiesSetting({priority:'low',    color:'#00ff60'})
    ]
    getColorByPriority: (priority) ->
      model = @getModelByPriority(priority)
      return if model then model.get('color') else ''
    getModelByPriority: (priority) ->
      (return model if model.get('priority') == priority) for model in priority_settings.models
      return ''

  # Todos
  class Todo extends Backbone.Model
    defaults: -> return {created_at: new Date()}

  class TodoList extends Backbone.Collection
    model: Todo
    localStorage: new Store("todos") # Save all of the todo items under the `"todos"` namespace.

  todos = new TodoList()
  todos.fetch()

  ###################################
  # MVVM: http://en.wikipedia.org/wiki/Model_View_ViewModel
  ###################################

  # Localization
  LanguageOptionViewModel = (locale) ->
    @id = locale
    @label = locale_manager.localeToLabel(locale)
    @option_name = 'lang'
    return this

  $('#todo-languages').append($("#option-template").tmpl(new LanguageOptionViewModel(locale))) for locale in locale_manager.getLocales()
  $('#todo-languages').find("##{locale_manager.getLocale()}").attr(checked:'checked')

  # Priority Settings
  PrioritySettingsViewModel = (model) ->
    @priority = model.get('priority')
    @priority_text = locale_manager.get(@priority)
    @priority_color = model.get('color')
    return this

  window.settings_view_model =
    priority_settings: []
    default_setting: ko.observable()
    setDefault: (priority) ->
      (settings_view_model.default_setting(view_model) if view_model.priority == priority) for view_model in settings_view_model.priority_settings

  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(model)) for model in priority_settings.models
  settings_view_model.setDefault(priority_settings.models[0].get('priority'))

  # Header
  header_view_model =
    title: "Todos"
  $('#todo-header').append($("#header-template").tmpl(header_view_model))

  create_view_model =
    input_text:                 ko.observable('')
    input_placeholder_text:     locale_manager.get('placeholder_create')
    input_tooltip_text:         locale_manager.get('tooltip_create')
    priority_color:             ko.dependentObservable(-> return window.settings_view_model.default_setting().priority_color)

    setDefaultPriority: (priority) -> settings_view_model.setDefault(priority)
    addTodo: (event) ->
      text = @input_text()
      return true if (!text || event.keyCode != 13)
      todos.create({text: text, priority: settings_view_model.default_setting().priority})
      @input_text('')

  ko.applyBindings(create_view_model, $('#todo-create')[0])

  # Content
  TodoViewModel = (@model) ->
    @text = model.get('text')
    @created_at = model.get('created_at')
    @done_text = "#{locale_manager.get('label_completed')}: #{locale_manager.localizeDate(model.get('done_at'))}" if model.has('done_at')
    @priority_color = priority_settings.getColorByPriority(model.get('priority'))
    @destroyTodo = => @model.destroy()
    return this

  todo_list_view_model =
    todos: ko.observableArray([])
  kb.collectionSync(todos, todo_list_view_model.todos, { viewModelCreate: (model) -> return new TodoViewModel(model) })
  ko.applyBindings(todo_list_view_model, $('#todo-list')[0])

  # Footer
  stats_view_model =
    total:      todos.models.length
    done:       todos.models.reduce(((prev,cur)-> return prev + if cur.get('done_at') then 1 else 0), 0)
    remaining:  todos.models.reduce(((prev,cur)-> return prev + if cur.get('done_at') then 0 else 1), 0)
  $('#todo-stats').append($("#stats-template").tmpl(stats_view_model))

  SortingOptionViewModel = (string_id) ->
    @id = string_id
    @label =  locale_manager.get(string_id)
    @option_name = 'sort'
    return this
  list_sorting_options_view_model = [new SortingOptionViewModel('label_name'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_completed')]
  $('#todo-list-sorting').append($("#option-template").tmpl(view_model)) for view_model in list_sorting_options_view_model
  $('#todo-list-sorting').find('#label_created').attr(checked:'checked')

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