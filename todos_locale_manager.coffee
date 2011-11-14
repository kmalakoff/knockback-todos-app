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
  get: (key, parameters) ->
    return @translations_by_locale[@current_locale][key] if arguments == 1
    string = @translations_by_locale[@current_locale][key]
    string.replace("{#{index}}", arg) for arg, index in Array.prototype.slice.call(arguments, 1)
    return string

locale_manager = new LocaleManager({
  'en':
    placeholder_create:   'What needs to be done?'
    tooltip_create:       'Press Enter to save this task'
    label_name:           'Name'
    label_created:        'Created'
    label_priority:       'Priority'
    label_completed:      'Completed'
    instructions:         'Double-click to edit a todo.'
    high:                 'high'
    medium:               'medium'
    low:                  'low'
    remaining_template_s: '{0} item remaining'
    remaining_template_pl:'{0} items remaining'
    clear_template_s:     'Clear {0} completed item'
    clear_template_pl:    'Clear {0} completed items'
  'fr-FR':
    placeholder_create:   'Que faire?'
    tooltip_create:       'Appuyez sur Enter pour enregistrer cette tâche'
    label_name:           'Nom'
    label_created:        'Création'
    label_priority:       'Priority'
    label_completed:      'Complété'
    instructions:         'Double-cliquez pour modifier un todo.'
    high:                 'haute'
    medium:               'moyen'
    low:                  'bas'
    remaining_template_s: '{0} point restant'
    remaining_template_pl:'{0} éléments restants'
    clear_template_s:     'Retirer {0} point terminée'
    clear_template_pl:    'Retirer les {0} éléments terminés'
  'it-IT':
    placeholder_create:   'Cosa fare?'
    tooltip_create:       'Premere Enter per salvare questo compito'
    label_name:           'Nome'
    label_created:        'Creato'
    label_priority:       'Priority'
    label_completed:      'Completato'
    instructions:         'Fare doppio clic per modificare una delle cose da fare.'
    high:                 'alto'
    medium:               'medio'
    low:                  'basso'
    remaining_template_s: '{0} elemento restante'
    remaining_template_pl:'{0} elementi rimanenti'
    clear_template_s:     'Rimuovere {0} elemento completato'
    clear_template_pl:    'Rimuovere {0} elementi completato'
})
