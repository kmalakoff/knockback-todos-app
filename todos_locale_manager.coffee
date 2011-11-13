###
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
###

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

locale_manager = new LocaleManager({
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
