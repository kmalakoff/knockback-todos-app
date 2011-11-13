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
  LocaleManager.prototype.get = function(key) {
    return this.translations_by_locale[this.current_locale][key];
  };
  return LocaleManager;
})();
locale_manager = new LocaleManager({
  'en': {
    placeholder_create: 'What needs to be done?',
    tooltip_create: 'Press Enter to save this task',
    label_name: 'Name',
    label_created: 'Created',
    label_completed: 'Completed',
    instructions: 'Double-click to edit a todo.',
    high: 'high',
    medium: 'medium',
    low: 'low'
  },
  'fr-FR': {
    placeholder_create: 'Que faire?',
    tooltip_create: 'Appuyez sur Enter pour enregistrer cette tâche',
    label_name: 'Nom',
    label_created: 'Création',
    label_completed: 'Complété',
    instructions: 'Double-cliquez pour modifier un todo.',
    high: 'haute',
    medium: 'moyen',
    low: 'bas'
  },
  'it-IT': {
    placeholder_create: 'Cosa fare?',
    tooltip_create: 'Premere Enter per salvare questo compito',
    label_name: 'Nome',
    label_created: 'Creato',
    label_completed: 'Completato',
    instructions: 'Fare doppio clic per modificare una delle cose da fare.',
    high: 'alto',
    medium: 'medio',
    low: 'basso'
  }
});