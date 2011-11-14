/*
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
*/$(document).ready(function() {
  var $all_priority_pickers, LanguageOptionViewModel, PrioritiesSetting, PrioritySettingsViewModel, SortingOptionViewModel, Todo, TodoViewModel, create_view_model, footer_view_model, header_view_model, locale, model, priorities, stats_view_model, todo_list_view_model, todos, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
  kb.locale_manager.setLocale('it-IT');
  PrioritiesSetting = (function() {
    function PrioritiesSetting(attributes) {
      this.attributes = attributes;
    }
    PrioritiesSetting.prototype.get = function(attribute_name) {
      return this.attributes[attribute_name];
    };
    return PrioritiesSetting;
  })();
  priorities = {
    models: [
      new PrioritiesSetting({
        id: 'high',
        color: '#c00020'
      }), new PrioritiesSetting({
        id: 'medium',
        color: '#c08040'
      }), new PrioritiesSetting({
        id: 'low',
        color: '#00ff60'
      })
    ]
  };
  Todo = (function() {
    function Todo(attributes) {
      this.attributes = attributes;
      if (!this.attributes['created_at']) {
        this.attributes['created_at'] = new Date();
      }
    }
    Todo.prototype.get = function(attribute_name) {
      return this.attributes[attribute_name];
    };
    return Todo;
  })();
  todos = {
    models: [
      new Todo({
        text: 'Test task text 1',
        priority: 'medium'
      }), new Todo({
        text: 'Test task text 2',
        priority: 'low'
      }), new Todo({
        text: 'Test task text 3',
        priority: 'high',
        done_at: new Date()
      })
    ]
  };
  LanguageOptionViewModel = function(locale) {
    this.id = locale;
    this.label = kb.locale_manager.localeToLabel(locale);
    this.option_group = 'lang';
    return this;
  };
  _ref = kb.locale_manager.getLocales();
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    locale = _ref[_i];
    $('#todo-languages').append($("#option-template").tmpl(new LanguageOptionViewModel(locale)));
  }
  $('#todo-languages').find("#" + (kb.locale_manager.getLocale())).attr({
    checked: 'checked'
  });
  PrioritySettingsViewModel = function(model) {
    this.priority = model.get('id');
    this.priority_text = kb.locale_manager.get(this.priority);
    this.priority_color = model.get('color');
    return this;
  };
  window.settings_view_model = {
    priority_settings: [],
    getColorByPriority: function(priority) {
      var view_model, _j, _len2, _ref2;
      _ref2 = settings_view_model.priority_settings;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        view_model = _ref2[_j];
        if (view_model.priority === priority) {
          return view_model.priority_color;
        }
      }
      return '';
    }
  };
  _ref2 = priorities.models;
  for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
    model = _ref2[_j];
    settings_view_model.priority_settings.push(new PrioritySettingsViewModel(model));
  }
  settings_view_model.default_setting = settings_view_model.priority_settings[0];
  header_view_model = {
    title: "Todos"
  };
  $('#todo-header').append($("#header-template").tmpl(header_view_model));
  create_view_model = {
    input_placeholder_text: kb.locale_manager.get('placeholder_create'),
    input_tooltip_text: kb.locale_manager.get('tooltip_create'),
    priority_color: settings_view_model.default_setting.priority_color
  };
  $('#todo-create').append($("#create-template").tmpl(create_view_model));
  SortingOptionViewModel = function(string_id) {
    this.id = string_id;
    this.label = kb.locale_manager.get(string_id);
    this.option_group = 'list_sort';
    return this;
  };
  TodoViewModel = function(model) {
    this.text = model.get('text');
    this.created_at = model.get('created_at');
    if (!!model.get('done_at')) {
      this.done_text = "" + (kb.locale_manager.get('label_completed')) + ": " + (kb.locale_manager.localizeDate(model.get('done_at')));
    }
    this.priority_color = settings_view_model.getColorByPriority(model.get('priority'));
    return this;
  };
  todo_list_view_model = {
    todos: []
  };
  _ref3 = todos.models;
  for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
    model = _ref3[_k];
    todo_list_view_model.todos.push(new TodoViewModel(model));
  }
  todo_list_view_model.sort_visible = todos.models.length > 0;
  todo_list_view_model.sorting_options = [new SortingOptionViewModel('label_name'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_priority')];
  $("#todo-list").append($("#list-template").tmpl(todo_list_view_model));
  $('#todo-list-sorting').find('#label_created').attr({
    checked: 'checked'
  });
  stats_view_model = {
    total: todos.models.length,
    done: todos.models.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 1 : 0);
    }), 0),
    remaining: todos.models.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 0 : 1);
    }), 0)
  };
  $('#todo-stats').append($("#stats-template").tmpl(stats_view_model));
  footer_view_model = {
    instructions_text: kb.locale_manager.get('instructions')
  };
  $('#todo-footer').append($("#footer-template").tmpl(footer_view_model));
  $all_priority_pickers = $('body').find('.priority-picker-tooltip');
  $('.colorpicker').mColorPicker();
  $('.priority-color-swatch').click(function() {
    var $priority_picker;
    $priority_picker = $(this).children('.priority-picker-tooltip');
    $all_priority_pickers.not($priority_picker).hide();
    return $priority_picker.toggle();
  });
  return $('body').click(function(event) {
    if (!$(event.target).children('.priority-picker-tooltip').length && !$(event.target).closest('.priority-picker-tooltip').length) {
      return $all_priority_pickers.hide();
    }
  });
});