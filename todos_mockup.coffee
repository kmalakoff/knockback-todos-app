###
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
###

$(document).ready(->

  ###################################
  # Knockback-powered enhancements - BEGIN
  ###################################

  # set the language
  kb.locale_manager.setLocale('en')

  ###################################
  # Model: http://en.wikipedia.org/wiki/Model_view_controller
  # ORM: http://en.wikipedia.org/wiki/Object-relational_mapping
  ###################################

  # Priority Settings
  class PrioritySetting
    constructor: (@attributes) ->
    get: (attribute_name) -> return @attributes[attribute_name]

  priorities =
    models: [new PrioritySetting({id:'high',   color:'#c00020'}), new PrioritySetting({id:'medium', color:'#c08040'}), new PrioritySetting({id:'low',    color:'#00ff60'})]

  ###################################
  # MVVM: http://en.wikipedia.org/wiki/Model_View_ViewModel
  ###################################

  # Localization
  LanguageOptionViewModel = (locale) ->
    @id = locale
    @label = kb.locale_manager.localeToLabel(locale)
    @option_group = 'lang'
    return this

  # Priority Settings
  PrioritySettingsViewModel = (model) ->
    @priority = model.get('id')
    @priority_text = kb.locale_manager.get(@priority)
    @priority_color = model.get('color')
    return this

  SettingsViewModel = (priority_settings) ->
    @priority_settings = []
    @priority_settings.push(new PrioritySettingsViewModel(model)) for model in priority_settings
    @getColorByPriority = (priority) =>
      (return view_model.priority_color if view_model.priority == priority) for view_model in @priority_settings
      return ''
    @default_priority = @priority_settings[1].priority
    @default_priority_color = @getColorByPriority(@default_priority)
    return this
  window.settings_view_model = new SettingsViewModel(priorities.models)

  # Content
  SortingOptionViewModel = (string_id) ->
    @id = string_id
    @label =  kb.locale_manager.get(string_id)
    @option_group = 'list_sort'
    return this

  ###################################
  # Knockback-powered enhancements - END
  ###################################

  ###################################
  # Model: http://en.wikipedia.org/wiki/Model_view_controller
  # ORM: http://en.wikipedia.org/wiki/Object-relational_mapping
  ###################################

  # Todos
  class Todo
    constructor: (@attributes) ->
      @attributes['created_at'] = new Date() if not @attributes['created_at']
    get: (attribute_name) -> return @attributes[attribute_name]

  todos =
    models: [
      new Todo({text:'Test task text 1', priority:'medium'}),
      new Todo({text:'Test task text 2', priority:'low'}),
      new Todo({text:'Test task text 3', priority:'high', done_at:new Date()})
    ]

  ###################################
  # MVVM: http://en.wikipedia.org/wiki/Model_View_ViewModel
  ###################################

  # Header
  HeaderViewModel = ->
    @title = "Todos"
    return this
  $('#todo-header').append($("#header-template").tmpl(new HeaderViewModel()))

  CreateTodoViewModel = ->
    @input_placeholder_text = kb.locale_manager.get('placeholder_create')
    @input_tooltip_text = kb.locale_manager.get('tooltip_create')
    @priority_color = settings_view_model.default_priority_color
    return this
  $('#todo-create').append($("#create-template").tmpl(new CreateTodoViewModel()))

  TodoViewModel = (model) ->
    @text = model.get('text')
    @created_at = model.get('created_at')
    @done_text = "#{kb.locale_manager.get('label_completed')}: #{kb.locale_manager.localizeDate(model.get('done_at'))}" if !!model.get('done_at')
    @priority_color = settings_view_model.getColorByPriority(model.get('priority'))
    return this

  TodoListViewModel = (todos) ->
    @todos = []
    @todos.push(new TodoViewModel(model)) for model in todos
    @sort_visible = (@todos.length>0)
    @sorting_options = [new SortingOptionViewModel('label_text'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_priority')]
    return true
  $("#todo-list").append($("#list-template").tmpl(new TodoListViewModel(todos.models)))
  $('#todo-list-sorting').find('#label_created').attr(checked:'checked')

  # Stats Footer
  StatsViewModel = (todos) ->
    @total = todos.models.length
    @done = todos.models.reduce(((prev,cur)-> return prev + if cur.get('done_at') then 1 else 0), 0)
    @remaining = todos.models.reduce(((prev,cur)-> return prev + if cur.get('done_at') then 0 else 1), 0)
  $('#todo-stats').append($("#stats-template").tmpl(new StatsViewModel(todos)))

  FooterViewModel = ->
    @instructions_text = kb.locale_manager.get('instructions')
    return this
  $('#todo-footer').append($("#footer-template").tmpl(new FooterViewModel()))
  $('#todo-languages').append($("#option-template").tmpl(new LanguageOptionViewModel(locale))) for locale in kb.locale_manager.getLocales()
  $('#todo-languages').find("##{kb.locale_manager.getLocale()}").attr(checked:'checked')

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