/*
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
*/
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
$(document).ready(function() {
  var $all_priority_pickers, CreateTodoViewModel, FooterViewModel, HeaderViewModel, LanguageOptionViewModel, PrioritySetting, PrioritySettingsViewModel, SettingsViewModel, SortingOptionViewModel, StatsViewModel, Todo, TodoListViewModel, TodoViewModel, locale, priorities, todos, _i, _len, _ref;
  kb.locale_manager.setLocale('en');
  PrioritySetting = (function() {
    function PrioritySetting(attributes) {
      this.attributes = attributes;
    }
    PrioritySetting.prototype.get = function(attribute_name) {
      return this.attributes[attribute_name];
    };
    return PrioritySetting;
  })();
  priorities = {
    models: [
      new PrioritySetting({
        id: 'high',
        color: '#c00020'
      }), new PrioritySetting({
        id: 'medium',
        color: '#c08040'
      }), new PrioritySetting({
        id: 'low',
        color: '#00ff60'
      })
    ]
  };
  LanguageOptionViewModel = function(locale) {
    this.id = locale;
    this.label = kb.locale_manager.localeToLabel(locale);
    this.option_group = 'lang';
    return this;
  };
  PrioritySettingsViewModel = function(model) {
    this.priority = model.get('id');
    this.priority_text = kb.locale_manager.get(this.priority);
    this.priority_color = model.get('color');
    return this;
  };
  SettingsViewModel = function(priority_settings) {
    var model, _i, _len;
    this.priority_settings = [];
    for (_i = 0, _len = priority_settings.length; _i < _len; _i++) {
      model = priority_settings[_i];
      this.priority_settings.push(new PrioritySettingsViewModel(model));
    }
    this.getColorByPriority = __bind(function(priority) {
      var view_model, _j, _len2, _ref;
      _ref = this.priority_settings;
      for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
        view_model = _ref[_j];
        if (view_model.priority === priority) {
          return view_model.priority_color;
        }
      }
      return '';
    }, this);
    this.default_priority = this.priority_settings[1].priority;
    this.default_priority_color = this.getColorByPriority(this.default_priority);
    return this;
  };
  window.settings_view_model = new SettingsViewModel(priorities.models);
  SortingOptionViewModel = function(string_id) {
    this.id = string_id;
    this.label = kb.locale_manager.get(string_id);
    this.option_group = 'list_sort';
    return this;
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
  HeaderViewModel = function() {
    this.title = "Todos";
    return this;
  };
  $('#todo-header').append($("#header-template").tmpl(new HeaderViewModel()));
  CreateTodoViewModel = function() {
    this.input_placeholder_text = kb.locale_manager.get('placeholder_create');
    this.input_tooltip_text = kb.locale_manager.get('tooltip_create');
    this.priority_color = settings_view_model.default_priority_color;
    return this;
  };
  $('#todo-create').append($("#create-template").tmpl(new CreateTodoViewModel()));
  TodoViewModel = function(model) {
    this.text = model.get('text');
    this.created_at = model.get('created_at');
    if (!!model.get('done_at')) {
      this.done_text = "" + (kb.locale_manager.get('label_completed')) + ": " + (kb.locale_manager.localizeDate(model.get('done_at')));
    }
    this.priority_color = settings_view_model.getColorByPriority(model.get('priority'));
    return this;
  };
  TodoListViewModel = function(todos) {
    var model, _i, _len;
    this.todos = [];
    for (_i = 0, _len = todos.length; _i < _len; _i++) {
      model = todos[_i];
      this.todos.push(new TodoViewModel(model));
    }
    this.sort_visible = this.todos.length > 0;
    this.sorting_options = [new SortingOptionViewModel('label_text'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_priority')];
    return true;
  };
  $("#todo-list").append($("#list-template").tmpl(new TodoListViewModel(todos.models)));
  $('#todo-list-sorting').find('#label_created').attr({
    checked: 'checked'
  });
  StatsViewModel = function(todos) {
    this.total = todos.models.length;
    this.done = todos.models.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 1 : 0);
    }), 0);
    return this.remaining = todos.models.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 0 : 1);
    }), 0);
  };
  $('#todo-stats').append($("#stats-template").tmpl(new StatsViewModel(todos)));
  FooterViewModel = function() {
    this.instructions_text = kb.locale_manager.get('instructions');
    return this;
  };
  $('#todo-footer').append($("#footer-template").tmpl(new FooterViewModel()));
  _ref = kb.locale_manager.getLocales();
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    locale = _ref[_i];
    $('#todo-languages').append($("#option-template").tmpl(new LanguageOptionViewModel(locale)));
  }
  $('#todo-languages').find("#" + (kb.locale_manager.getLocale())).attr({
    checked: 'checked'
  });
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