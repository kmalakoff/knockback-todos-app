/*
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
*/$(document).ready(function() {
  var $all_priority_pickers, LanguageOptionViewModel, LocaleManager, PrioritiesSettingsViewModel, SortingOptionViewModel, Todo, TodoViewModel, color, locale, priority, todo, todos, view_model, _i, _j, _k, _l, _len, _len2, _len3, _len4, _ref, _ref2;
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
  window.locale_manager = new LocaleManager({
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
  locale_manager.setLocale('it-IT');
  window.priorities_to_colors = {
    'high': '#c00020',
    'medium': '#c08040',
    'low': '#00ff60'
  };
  Todo = (function() {
    function Todo(attributes) {
      this.attributes = attributes;
      if (!this.attributes['created_at']) {
        this.attributes['created_at'] = new Date();
      }
    }
    Todo.prototype.has = function(attribute_name) {
      return this.attributes.hasOwnProperty(attribute_name);
    };
    Todo.prototype.get = function(attribute_name) {
      return this.attributes[attribute_name];
    };
    return Todo;
  })();
  todos = [
    new Todo({
      text: 'Test task text 1',
      priority: 'high'
    }), new Todo({
      text: 'Test task text 2',
      priority: 'medium'
    }), new Todo({
      text: 'Test task text 3',
      priority: 'low',
      done_at: new Date()
    })
  ];
  LanguageOptionViewModel = function(locale) {
    this.id = locale;
    this.label = locale_manager.localeToLabel(locale);
    this.option_name = 'lang';
    return this;
  };
  _ref = locale_manager.getLocales();
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    locale = _ref[_i];
    $('#todo-languages').append($("#option-template").tmpl(new LanguageOptionViewModel(locale)));
  }
  $('#todo-languages').find("#" + (locale_manager.getLocale())).attr({
    checked: 'checked'
  });
  PrioritiesSettingsViewModel = function(priority, color) {
    this.priority_text = locale_manager.get(priority);
    this.priority_color = color;
    return this;
  };
  window.priorities_to_colors_view_model = [];
  _ref2 = window.priorities_to_colors;
  for (priority in _ref2) {
    color = _ref2[priority];
    priorities_to_colors_view_model.push(new PrioritiesSettingsViewModel(priority, color));
  }
  window.header_view_model = {
    title: "Todos",
    priorities_to_colors: priorities_to_colors_view_model
  };
  $('#todo-header').append($("#header-template").tmpl(header_view_model));
  window.create_view_model = {
    input_placeholder_text: locale_manager.get('placeholder_create'),
    input_tooltip_text: locale_manager.get('tooltip_create'),
    priority_color: priorities_to_colors['low']
  };
  $('#todo-create').append($("#create-template").tmpl(create_view_model));
  TodoViewModel = function(model) {
    this.text = model.get('text');
    this.created_at = model.get('created_at');
    if (model.has('done_at')) {
      this.done_text = "" + (locale_manager.get('label_completed')) + ": " + (locale_manager.localizeDate(model.get('done_at')));
    }
    this.priority_color = priorities_to_colors[model.get('priority')];
    return this;
  };
  window.todo_view_models = [];
  for (_j = 0, _len2 = todos.length; _j < _len2; _j++) {
    todo = todos[_j];
    todo_view_models.push(new TodoViewModel(todo));
  }
  for (_k = 0, _len3 = todo_view_models.length; _k < _len3; _k++) {
    view_model = todo_view_models[_k];
    $("#todo-list").append($("#item-template").tmpl(view_model));
  }
  window.stats_view_model = {
    total: todos.length,
    done: todos.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 1 : 0);
    }), 0),
    remaining: todos.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 0 : 1);
    }), 0)
  };
  $('#todo-stats').append($("#stats-template").tmpl(stats_view_model));
  SortingOptionViewModel = function(string_id) {
    this.id = string_id;
    this.label = locale_manager.get(string_id);
    this.option_name = 'sort';
    return this;
  };
  window.list_sorting_options_view_model = [new SortingOptionViewModel('label_name'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_completed')];
  for (_l = 0, _len4 = list_sorting_options_view_model.length; _l < _len4; _l++) {
    view_model = list_sorting_options_view_model[_l];
    $('#todo-list-sorting').append($("#option-template").tmpl(view_model));
  }
  $('#todo-list-sorting').find('#label_created').attr({
    checked: 'checked'
  });
  window.footer_view_model = {
    instructions_text: locale_manager.get('instructions')
  };
  $('#todo-footer').append($("#footer-template").tmpl(footer_view_model));
  $all_priority_pickers = $('body').find('.priority-picker-tooltip');
  $('.colorpicker').mColorPicker();
  $('.priority-color-swatch').click(function() {
    $all_priority_pickers.hide();
    return $(this).children('.priority-picker-tooltip').toggle();
  });
  return $('body').click(function(event) {
    if (!$(event.target).children('.priority-picker-tooltip').length && !$(event.target).closest('.priority-picker-tooltip').length) {
      return $all_priority_pickers.hide();
    }
  });
});