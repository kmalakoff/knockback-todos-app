###
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
###

$(document).ready(->

  ###################################
  # Model: http://en.wikipedia.org/wiki/Model_view_controller
  # ORM: http://en.wikipedia.org/wiki/Object-relational_mapping
  ###################################

  # Localization
  class LocaleManager
    constructor: (@translations_by_locale) ->
    getLocales: ->
      locales = []
      locales.push(key) for key, value of @translations_by_locale
      return locales
    setLocale: (locale) ->
      throw new Error("Locale: #{locale} not available") if not @translations_by_locale.hasOwnProperty(locale)
      @current_locale = locale
    getLocale: -> return @current_locale
    localeToLabel: (locale) ->
      locale_parts = locale.split('-')
      return locale_parts[locale_parts.length-1].toUpperCase()
    localizeDate: (date) -> Globalize.format(date, Globalize.cultures[@current_locale].calendars.standard.patterns.f, @current_locale)
    get: (key) -> return @translations_by_locale[@current_locale][key]

  window.locale_manager = new LocaleManager({
    'en':
      placeholder_create:   'What needs to be done?'
      tooltip_create:       'Press Enter to save this task'
      label_name:           'Name'
      label_created:        'Created'
      label_completed:      'Completed'
      instructions:         'Double-click to edit a todo.'
      high:                 'high'
      medium:               'medium'
      low:                  'low'
    'fr-FR':
      placeholder_create:   'Que faire?'
      tooltip_create:       'Appuyez sur Enter pour enregistrer cette tâche'
      label_name:           'Nom'
      label_created:        'Création'
      label_completed:      'Complété'
      instructions:         'Double-cliquez pour modifier un todo.'
      high:                 'haute'
      medium:               'moyen'
      low:                  'bas'
    'it-IT':
      placeholder_create:   'Cosa fare?'
      tooltip_create:       'Premere Enter per salvare questo compito'
      label_name:           'Nome'
      label_created:        'Creato'
      label_completed:      'Completato'
      instructions:         'Fare doppio clic per modificare una delle cose da fare.'
      high:                 'alto'
      medium:               'medio'
      low:                  'basso'
  })
  locale_manager.setLocale('it-IT')

  # Settings
  window.priorities_to_colors =
    'high':   '#c00020'
    'medium': '#c08040'
    'low':    '#00ff60'

  # Todos
  class Todo
    constructor: (@attributes) ->
      @attributes['created_at'] = new Date() if not @attributes['created_at']
    has: (attribute_name) -> return @attributes.hasOwnProperty(attribute_name)
    get: (attribute_name) -> return @attributes[attribute_name]

  todos = [
    new Todo({text:'Test task text 1', priority:'high'}),
    new Todo({text:'Test task text 2', priority:'medium'}),
    new Todo({text:'Test task text 3', priority:'low', done_at:new Date()})
  ]

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

  # Settings
  PrioritiesSettingsViewModel = (priority, color) ->
    @priority_text = locale_manager.get(priority)
    @priority_color = color
    return this

  window.priorities_to_colors_view_model = []
  priorities_to_colors_view_model.push(new PrioritiesSettingsViewModel(priority, color)) for priority, color of window.priorities_to_colors

  # Header
  window.header_view_model =
    title: "Todos"
    priorities_to_colors: priorities_to_colors_view_model
  $('#todo-header').append($("#header-template").tmpl(header_view_model))

  window.create_view_model =
    input_placeholder_text:     locale_manager.get('placeholder_create')
    input_tooltip_text:         locale_manager.get('tooltip_create')
    priority_color:             priorities_to_colors['low']
  $('#todo-create').append($("#create-template").tmpl(create_view_model))

  # Content
  TodoViewModel = (model) ->
    @text = model.get('text')
    @created_at = model.get('created_at')
    @done_text = "#{locale_manager.get('label_completed')}: #{locale_manager.localizeDate(model.get('done_at'))}" if model.has('done_at')
    @priority_color = priorities_to_colors[model.get('priority')]
    return this

  window.todo_view_models = []
  todo_view_models.push(new TodoViewModel(todo)) for todo in todos
  $("#todo-list").append($("#item-template").tmpl(view_model)) for view_model in todo_view_models

  # Footer
  window.stats_view_model =
    total:      todos.length
    done:       todos.reduce(((prev,cur)-> return prev + if cur.get('done_at') then 1 else 0), 0)
    remaining:  todos.reduce(((prev,cur)-> return prev + if cur.get('done_at') then 0 else 1), 0)
  $('#todo-stats').append($("#stats-template").tmpl(stats_view_model))

  SortingOptionViewModel = (string_id) ->
    @id = string_id
    @label =  locale_manager.get(string_id)
    @option_name = 'sort'
    return this
  window.list_sorting_options_view_model = [
    new SortingOptionViewModel('label_name'),
    new SortingOptionViewModel('label_created'),
    new SortingOptionViewModel('label_completed')
  ]
  $('#todo-list-sorting').append($("#option-template").tmpl(view_model)) for view_model in list_sorting_options_view_model
  $('#todo-list-sorting').find('#label_created').attr(checked:'checked')

  window.footer_view_model =
    instructions_text: locale_manager.get('instructions')
  $('#todo-footer').append($("#footer-template").tmpl(footer_view_model))

  ###################################
  # Dynamic Interactions
  # jQuery: http://jquery.com/
  ###################################
  $all_priority_pickers = $('body').find('.priority-picker-tooltip')
  $('.colorpicker').mColorPicker()
  $('.priority-color-swatch').click(->
    $all_priority_pickers.hide()
    $(this).children('.priority-picker-tooltip').toggle()
  )
  $('body').click((event)-> $all_priority_pickers.hide() if not $(event.target).children('.priority-picker-tooltip').length and not $(event.target).closest('.priority-picker-tooltip').length ) # close all pickers
)