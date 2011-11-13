/*
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback.Observables is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
*/$(document).ready(function() {
  var $all_priority_pickers, LocaleManager, TodoViewModel, key, value, view_model, _i, _j, _k, _len, _len2, _len3, _ref;
  TodoViewModel = function(attributes) {
    this.text = attributes['text'];
    this.done_at = attributes['done_at'];
    this.created_at = new Date();
    if (this.done_at) {
      this.time_text = "Completed: " + (locale_manager.localizeDate(this.done_at));
    }
    this.priority = attributes['priority'];
    this.priority_color = priorities_to_colors[this.priority];
    return this;
  };
  LocaleManager = (function() {
    function LocaleManager(locale) {
      this.locale = locale;
    }
    LocaleManager.prototype.setLocale = function(locale) {
      return this.locale = locale;
    };
    LocaleManager.prototype.localizeDate = function(date) {
      return Globalize.format(date, Globalize.cultures[this.locale].calendars.standard.patterns.f, this.locale);
    };
    return LocaleManager;
  })();
  window.language_options_view_model = [
    {
      label: 'EN',
      locale: 'en',
      option_name: 'lang'
    }, {
      label: 'FR',
      locale: 'fr-FR',
      option_name: 'lang'
    }, {
      label: 'IT',
      locale: 'it-IT',
      option_name: 'lang'
    }
  ];
  for (_i = 0, _len = language_options_view_model.length; _i < _len; _i++) {
    view_model = language_options_view_model[_i];
    $('#todo-languages').append($("#option-template").tmpl(view_model));
  }
  $('#todo-languages').find('#IT').attr({
    checked: 'checked'
  });
  window.priorities_to_colors = {
    'high': '#c00020',
    'medium': '#c08040',
    'low': '#00ff60'
  };
  window.priorities_to_colors_view_model = [];
  _ref = window.priorities_to_colors;
  for (key in _ref) {
    value = _ref[key];
    priorities_to_colors_view_model.push({
      priority_text: key,
      priority_color: value
    });
  }
  window.header_view_model = {
    title: "Todos",
    priorities_to_colors: priorities_to_colors_view_model
  };
  $('#todo-header').append($("#header-template").tmpl(header_view_model));
  window.create_view_model = {
    input_placeholder_text: "What needs to be done?",
    input_tooltip_text: "Press Enter to save this task",
    priority_color: priorities_to_colors['low']
  };
  $('#todo-create').append($("#create-template").tmpl(create_view_model));
  window.locale_manager = new LocaleManager('it-IT');
  window.todo_view_models = [];
  todo_view_models.push(new TodoViewModel({
    text: 'Test task text 1',
    priority: 'high'
  }));
  todo_view_models.push(new TodoViewModel({
    text: 'Test task text 2',
    priority: 'medium'
  }));
  todo_view_models.push(new TodoViewModel({
    text: 'Test task text 3',
    priority: 'low',
    done_at: new Date()
  }));
  for (_j = 0, _len2 = todo_view_models.length; _j < _len2; _j++) {
    view_model = todo_view_models[_j];
    $("#todo-list").append($("#item-template").tmpl(view_model));
  }
  window.stats_view_model = {
    total: todo_view_models.length,
    done: todo_view_models.reduce((function(prev, cur) {
      return prev + (cur.done_at ? 1 : 0);
    }), 0),
    remaining: todo_view_models.reduce((function(prev, cur) {
      return prev + (cur.done_at ? 0 : 1);
    }), 0)
  };
  $('#todo-stats').append($("#stats-template").tmpl(stats_view_model));
  window.list_sorting_options_view_model = [
    {
      label: 'Name',
      option_name: 'sort'
    }, {
      label: 'Created',
      option_name: 'sort'
    }, {
      label: 'Completed',
      option_name: 'sort'
    }
  ];
  for (_k = 0, _len3 = list_sorting_options_view_model.length; _k < _len3; _k++) {
    view_model = list_sorting_options_view_model[_k];
    $('#todo-list-sorting').append($("#option-template").tmpl(view_model));
  }
  $('#todo-list-sorting').find('#Created').attr({
    checked: 'checked'
  });
  window.footer_view_model = {
    instructions_text: "Double-click to edit a todo."
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