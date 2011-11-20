/*
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
*/
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
$(document).ready(function() {
  var $all_priority_pickers, CreateTodoViewModel, FooterViewModel, HeaderViewModel, LanguageOptionViewModel, PrioritySetting, PrioritySettingsViewModel, SettingsViewModel, SortingOptionViewModel, StatsViewModel, Todo, TodoListViewModel, TodoViewModel, app_view_model, priorities, todos;
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
  CreateTodoViewModel = function() {
    this.input_placeholder_text = kb.locale_manager.get('placeholder_create');
    this.input_tooltip_text = kb.locale_manager.get('tooltip_create');
    this.priority_color = window.settings_view_model.default_priority_color;
    return this;
  };
  TodoViewModel = function(model) {
    this.text = model.get('text');
    this.created_at = model.get('created_at');
    if (!!model.get('done_at')) {
      this.done_text = "" + (kb.locale_manager.get('label_completed')) + ": " + (kb.locale_manager.localizeDate(model.get('done_at')));
    }
    this.priority_color = window.settings_view_model.getColorByPriority(model.get('priority'));
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
    return this;
  };
  StatsViewModel = function(todos) {
    this.total = todos.models.length;
    this.done = todos.models.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 1 : 0);
    }), 0);
    this.remaining = todos.models.reduce((function(prev, cur) {
      return prev + (cur.get('done_at') ? 0 : 1);
    }), 0);
    return this;
  };
  FooterViewModel = function(locales) {
    var locale, _i, _len;
    this.instructions_text = kb.locale_manager.get('instructions');
    this.language_options = [];
    for (_i = 0, _len = locales.length; _i < _len; _i++) {
      locale = locales[_i];
      this.language_options.push(new LanguageOptionViewModel(locale));
    }
    return this;
  };
  window.settings_view_model = new SettingsViewModel(priorities.models);
  app_view_model = {
    header: new HeaderViewModel(),
    create: new CreateTodoViewModel(),
    todo_list: new TodoListViewModel(todos.models),
    footer: new FooterViewModel(kb.locale_manager.getLocales()),
    stats: new StatsViewModel(todos)
  };
  $('#todoapp').append($("#todoapp-template").tmpl(app_view_model));
  $('#todo-list-sorting').find('#label_created').attr({
    checked: 'checked'
  });
  $('#todo-languages').find("#" + (kb.locale_manager.getLocale())).attr({
    checked: 'checked'
  });
  $all_priority_pickers = $('body').find('.priority-picker-tooltip');
  $('.colorpicker').mColorPicker({
    imageFolder: 'css/images/'
  });
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