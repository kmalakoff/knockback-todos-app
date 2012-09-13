###
  knockback-todos-app.js
  (c) 2011, 2012 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos-app/blob/master/LICENSE
###

# Localization
class LocaleManager
  _.extend(@prototype, Backbone.Events) # Mix in Backbone.Events so callers can subscribe

  constructor: (locale_identifier, @translations_by_locale) ->
    @setLocale(locale_identifier) if locale_identifier

  get: (string_id, parameters) ->
    return '' if not string_id
    culture_map = @translations_by_locale[@locale_identifier] if @locale_identifier
    return '' if not culture_map
    string = if culture_map.hasOwnProperty(string_id) then culture_map[string_id] else ''
    return string if arguments.length == 1
    return Knockback.toFormattedString.apply(null, [string].concat(Array.prototype.slice.call(arguments, 1)))

  getLocale: -> return @locale_identifier
  setLocale: (locale_identifier) ->
    @locale_identifier = locale_identifier
    Globalize.culture = Globalize.findClosestCulture(locale_identifier)
    return if !window.Backbone
    @trigger('change', @)
    culture_map = @translations_by_locale[@locale_identifier]
    return if not culture_map
    @trigger("change:#{key}", value) for key, value of culture_map
  getLocales: ->
    locales = []
    locales.push(string_id) for string_id, value of @translations_by_locale
    return locales

  localeToLabel: (locale) ->
    locale_parts = locale.split('-')
    return locale_parts[locale_parts.length-1].toUpperCase()
  localizeDate: (date) -> Globalize.format(date, Globalize.cultures[@locale_identifier].calendars.standard.patterns.f, @locale_identifier)

#######################################
# Set up strings
#######################################
throw new Error("Please include Knockback before the Locale Manager") unless kb

kb.locale_manager = new LocaleManager(null, {
  'en':
    placeholder_create:   'What needs to be done?'
    tooltip_create:       'Press Enter to save this task'
    label_title:          'Title'
    label_created:        'Created'
    label_priority:       'Priority'
    label_completed:      'Completed'
    instructions:         'Double-click to edit a todo'
    high:                 'high'
    medium:               'medium'
    low:                  'low'
    remaining_template_s: '<strong>{0}</strong> item remaining'
    remaining_template_pl:'<strong>{0}</strong> items remaining'
    clear_template_s:     'Clear completed ({0})'
    clear_template_pl:    'Clear completed ({0})'
    complete_all:         'Mark all as complete'
    todo_filter_all:      'All'
    todo_filter_active:   'Active'
    todo_filter_completed:'Completed'
  'fr-FR':
    placeholder_create:   'Que faire?'
    tooltip_create:       'Appuyez sur Enter pour enregistrer cette tâche'
    label_title:          'Titre'
    label_created:        'Création'
    label_priority:       'Priorité'
    label_completed:      'Complété'
    instructions:         'Double-cliquez pour modifier un todo'
    high:                 'haute'
    medium:               'moyen'
    low:                  'bas'
    remaining_template_s: '<strong>{0}</strong> point restant'
    remaining_template_pl:'<strong>{0}</strong> éléments restants'
    clear_template_s:     'Retirer terminée ({0})'
    clear_template_pl:    'Retirer terminés ({0})'
    complete_all:         'Marquer tous comme complète'
    todo_filter_all:      'Tous'
    todo_filter_active:   'Actif'
    todo_filter_completed:'Terminé'
  'it-IT':
    placeholder_create:   'Cosa fare?'
    tooltip_create:       'Premere Enter per salvare questo compito'
    label_title:          'Titolo'
    label_created:        'Creato'
    label_priority:       'Priorità'
    label_completed:      'Completato'
    instructions:         'Fare doppio clic per modificare una todo'
    high:                 'alto'
    medium:               'medio'
    low:                  'basso'
    remaining_template_s: '<strong>{0}</strong> elemento restante'
    remaining_template_pl:'<strong>{0}</strong> elementi rimanenti'
    clear_template_s:     'Rimuovere completato ({0})'
    clear_template_pl:    'Rimuovere completato ({0})'
    complete_all:         'Segna tutti come completo'
    todo_filter_all:      'Tutti'
    todo_filter_active:   'Attivo'
    todo_filter_completed:'Finito'
  'ja-JP':
    placeholder_create:   '何をする？'
    tooltip_create:       'このタスクを保存するには、Enterキーを押す'
    label_title:           'タイトル'
    label_created:        '作成日時'
    label_priority:       '優先'
    label_completed:      '完了日時'
    instructions:         'todoを編集するには、ダブルクリックします'
    high:                 '高'
    medium:               '中'
    low:                  '低'
    remaining_template_s: '残り <strong>{0}</strong>'
    remaining_template_pl:'残り <strong>{0}</strong>'
    clear_template_s:     '完了した項目を削除({0})'
    clear_template_pl:    '完了した項目を削除({0})'
    complete_all:         'として完了したすべてのマークを付ける'
    todo_filter_all:      '全て'
    todo_filter_active:   '作成中'
    todo_filter_completed:'完了'
})

#######################################
# Date localizer
#######################################
class window.LongDateLocalizer extends kb.LocalizedObservable
  constructor: -> return super
  read: (value) ->
    return Globalize.format(value, Globalize.cultures[kb.locale_manager.getLocale()].calendars.standard.patterns.f, kb.locale_manager.getLocale())
  write: (localized_string, value, observable) ->
    new_value = Globalize.parseDate(localized_string, Globalize.cultures[kb.locale_manager.getLocale()].calendars.standard.patterns.d, kb.locale_manager.getLocale())
    value.setTime(new_value.valueOf())
