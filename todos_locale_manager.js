/*
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
*/
var LocaleManager, locale_manager;
LocaleManager = (function() {
  function LocaleManager(translations_by_locale) {
    this.translations_by_locale = translations_by_locale;
  }
  LocaleManager.prototype.getLocales = function() {
    var key, locales, value, _ref;
    locales = [];
    _ref = this.translations_by_locale;
    for (key in _ref) {
      value = _ref[key];
      locales.push(key);
    }
    return locales;
  };
  LocaleManager.prototype.setLocale = function(locale) {
    if (!this.translations_by_locale.hasOwnProperty(locale)) {
      throw new Error("Locale: " + locale + " not available");
    }
    return this.current_locale = locale;
  };
  LocaleManager.prototype.getLocale = function() {
    return this.current_locale;
  };
  LocaleManager.prototype.localeToLabel = function(locale) {
    var locale_parts;
    locale_parts = locale.split('-');
    return locale_parts[locale_parts.length - 1].toUpperCase();
  };
  LocaleManager.prototype.localizeDate = function(date) {
    return Globalize.format(date, Globalize.cultures[this.current_locale].calendars.standard.patterns.f, this.current_locale);
  };
  LocaleManager.prototype.get = function(key, parameters) {
    var arg, index, string, _len, _ref;
    if (arguments === 1) {
      return this.translations_by_locale[this.current_locale][key];
    }
    string = this.translations_by_locale[this.current_locale][key];
    _ref = Array.prototype.slice.call(arguments, 1);
    for (index = 0, _len = _ref.length; index < _len; index++) {
      arg = _ref[index];
      string.replace("{" + index + "}", arg);
    }
    return string;
  };
  return LocaleManager;
})();
locale_manager = new LocaleManager({
  'en': {
    placeholder_create: 'What needs to be done?',
    tooltip_create: 'Press Enter to save this task',
    label_name: 'Name',
    label_created: 'Created',
    label_priority: 'Priority',
    label_completed: 'Completed',
    instructions: 'Double-click to edit a todo.',
    high: 'high',
    medium: 'medium',
    low: 'low',
    remaining_template_s: '{0} item remaining',
    remaining_template_pl: '{0} items remaining',
    clear_template_s: 'Clear {0} completed item',
    clear_template_pl: 'Clear {0} completed items'
  },
  'fr-FR': {
    placeholder_create: 'Que faire?',
    tooltip_create: 'Appuyez sur Enter pour enregistrer cette tâche',
    label_name: 'Nom',
    label_created: 'Création',
    label_priority: 'Priority',
    label_completed: 'Complété',
    instructions: 'Double-cliquez pour modifier un todo.',
    high: 'haute',
    medium: 'moyen',
    low: 'bas',
    remaining_template_s: '{0} point restant',
    remaining_template_pl: '{0} éléments restants',
    clear_template_s: 'Retirer {0} point terminée',
    clear_template_pl: 'Retirer les {0} éléments terminés'
  },
  'it-IT': {
    placeholder_create: 'Cosa fare?',
    tooltip_create: 'Premere Enter per salvare questo compito',
    label_name: 'Nome',
    label_created: 'Creato',
    label_priority: 'Priority',
    label_completed: 'Completato',
    instructions: 'Fare doppio clic per modificare una delle cose da fare.',
    high: 'alto',
    medium: 'medio',
    low: 'basso',
    remaining_template_s: '{0} elemento restante',
    remaining_template_pl: '{0} elementi rimanenti',
    clear_template_s: 'Rimuovere {0} elemento completato',
    clear_template_pl: 'Rimuovere {0} elementi completato'
  }
});