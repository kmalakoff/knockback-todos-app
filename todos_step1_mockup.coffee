###
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback.Observables is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
###

$(document).ready(->

  TodoViewModel = (attributes) ->
    @text = attributes['text']

    @done_at = attributes['done_at']
    @created_at = new Date()
    @time_text = "Completed: #{locale_manager.localizeDate(@done_at)}" if @done_at

    @priority = attributes['priority']
    @priority_color = priorities_to_colors[@priority]

    return this

  class LocaleManager
    constructor: (@locale) ->
    setLocale: (locale) ->
      @locale = locale
    localizeDate: (date) ->
      Globalize.format(date, Globalize.cultures[@locale].calendars.standard.patterns.f, @locale)

  window.language_options_view_model = [
    {label: 'EN', locale:'en', option_name:'lang'},
    {label: 'FR', locale:'fr-FR', option_name:'lang'},
    {label: 'IT', locale:'it-IT', option_name:'lang'}
  ]
  $('#todo-languages').append($("#option-template").tmpl(view_model)) for view_model in language_options_view_model
  $('#todo-languages').find('#IT').attr(checked:'checked')

  window.priorities_to_colors =
    'high':   '#c00020'
    'medium': '#c08040'
    'low':    '#00ff60'

  window.priorities_to_colors_view_model = []
  priorities_to_colors_view_model.push({priority_text: key, priority_color: value}) for key, value of window.priorities_to_colors

  window.header_view_model =
    title: "Todos"
    priorities_to_colors: priorities_to_colors_view_model
  $('#todo-header').append($("#header-template").tmpl(header_view_model))

  window.create_view_model =
    input_placeholder_text: "What needs to be done?"
    input_tooltip_text: "Press Enter to save this task"
    priority_color: priorities_to_colors['low']
  $('#todo-create').append($("#create-template").tmpl(create_view_model))

  window.locale_manager = new LocaleManager('it-IT')
  window.todo_view_models = []
  todo_view_models.push(new TodoViewModel({text:'Test task text 1', priority:'high'}))
  todo_view_models.push(new TodoViewModel({text:'Test task text 2', priority:'medium'}))
  todo_view_models.push(new TodoViewModel({text:'Test task text 3', priority:'low', done_at:new Date()}))
  $("#todo-list").append($("#item-template").tmpl(view_model)) for view_model in todo_view_models

  window.stats_view_model =
    total:      todo_view_models.length
    done:       todo_view_models.reduce(((prev,cur)-> return prev + if cur.done_at then 1 else 0), 0)
    remaining:  todo_view_models.reduce(((prev,cur)-> return prev + if cur.done_at then 0 else 1), 0)
  $('#todo-stats').append($("#stats-template").tmpl(stats_view_model))

  window.list_sorting_options_view_model = [
    {label: 'Name', option_name:'sort'},
    {label: 'Created', option_name:'sort'},
    {label: 'Completed', option_name:'sort'}
  ]
  $('#todo-list-sorting').append($("#option-template").tmpl(view_model)) for view_model in list_sorting_options_view_model
  $('#todo-list-sorting').find('#Created').attr(checked:'checked')

  window.footer_view_model =
    instructions_text: "Double-click to edit a todo."
  $('#todo-footer').append($("#footer-template").tmpl(footer_view_model))

  # set up the stubbed out dynamic interactions
  $all_priority_pickers = $('body').find('.priority-picker-tooltip')
  $('.colorpicker').mColorPicker()
  $('.priority-color-swatch').click(->
    $all_priority_pickers.hide()
    $(this).children('.priority-picker-tooltip').toggle()
  )
  $('body').click((event)-> $all_priority_pickers.hide() if not $(event.target).children('.priority-picker-tooltip').length and not $(event.target).closest('.priority-picker-tooltip').length ) # close all pickers
)