/*
  knockback-todos.js
  (c) 2011 Kevin Malakoff.
  Knockback-Todos is freely distributable under the MIT license.
  See the following for full license details:
    https:#github.com/kmalakoff/knockback-todos/blob/master/LICENSE
*/
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
}, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
$(document).ready(function() {
  var $all_priority_pickers, LanguageOptionViewModel, PrioritiesSetting, PrioritySettingsViewModel, SortingOptionViewModel, Todo, TodoList, TodoViewModel, create_view_model, footer_view_model, header_view_model, list_sorting_options_view_model, locale, model, priority_settings, stats_view_model, todo_list_view_model, todos, view_model, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
  locale_manager.setLocale('it-IT');
  PrioritiesSetting = (function() {
    function PrioritiesSetting(attributes) {
      this.attributes = attributes;
    }
    PrioritiesSetting.prototype.get = function(attribute_name) {
      return this.attributes[attribute_name];
    };
    return PrioritiesSetting;
  })();
  priority_settings = {
    models: [
      new PrioritiesSetting({
        priority: 'high',
        color: '#c00020'
      }), new PrioritiesSetting({
        priority: 'medium',
        color: '#c08040'
      }), new PrioritiesSetting({
        priority: 'low',
        color: '#00ff60'
      })
    ],
    getColorByPriority: function(priority) {
      var model;
      model = this.getModelByPriority(priority);
      if (model) {
        return model.get('color');
      } else {
        return '';
      }
    },
    getModelByPriority: function(priority) {
      var model, _i, _len, _ref;
      _ref = priority_settings.models;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        if (model.get('priority') === priority) {
          return model;
        }
      }
      return '';
    }
  };
  Todo = (function() {
    __extends(Todo, Backbone.Model);
    function Todo() {
      Todo.__super__.constructor.apply(this, arguments);
    }
    Todo.prototype.defaults = function() {
      return {
        created_at: new Date()
      };
    };
    return Todo;
  })();
  TodoList = (function() {
    __extends(TodoList, Backbone.Collection);
    function TodoList() {
      TodoList.__super__.constructor.apply(this, arguments);
    }
    TodoList.prototype.model = Todo;
    TodoList.prototype.localStorage = new Store("todos");
    return TodoList;
  })();
  todos = new TodoList();
  todos.fetch();
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
  PrioritySettingsViewModel = function(model) {
    this.priority = model.get('priority');
    this.priority_text = locale_manager.get(this.priority);
    this.priority_color = model.get('color');
    return this;
  };
  window.settings_view_model = {
    priority_settings: [],
    default_setting: ko.observable(),
    setDefault: function(priority) {
      var view_model, _j, _len2, _ref2, _results;
      _ref2 = settings_view_model.priority_settings;
      _results = [];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        view_model = _ref2[_j];
        _results.push((view_model.priority === priority ? settings_view_model.default_setting(view_model) : void 0));
      }
      return _results;
    }
  };
  _ref2 = priority_settings.models;
  for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
    model = _ref2[_j];
    settings_view_model.priority_settings.push(new PrioritySettingsViewModel(model));
  }
  settings_view_model.setDefault(priority_settings.models[0].get('priority'));
  header_view_model = {
    title: "Todos"
  };
  $('#todo-header').append($("#header-template").tmpl(header_view_model));
  create_view_model = {
    input_text: ko.observable(''),
    input_placeholder_text: locale_manager.get('placeholder_create'),
    input_tooltip_text: locale_manager.get('tooltip_create'),
    priority_color: ko.dependentObservable(function() {
      return window.settings_view_model.default_setting().priority_color;
    }),
    setDefaultPriority: function(priority) {
      return settings_view_model.setDefault(priority);
    },
    addTodo: function(event) {
      var text;
      text = this.input_text();
      if (!text || event.keyCode !== 13) {
        return true;
      }
      todos.create({
        text: text,
        priority: settings_view_model.default_setting().priority
      });
      return this.input_text('');
    }
  };
  ko.applyBindings(create_view_model, $('#todo-create')[0]);
  TodoViewModel = function(model) {
    this.model = model;
    this.text = model.get('text');
    this.created_at = model.get('created_at');
    if (model.has('done_at')) {
      this.done_text = "" + (locale_manager.get('label_completed')) + ": " + (locale_manager.localizeDate(model.get('done_at')));
    }
    this.priority_color = priority_settings.getColorByPriority(model.get('priority'));
    this.destroyTodo = __bind(function() {
      return this.model.destroy();
    }, this);
    return this;
  };
  todo_list_view_model = {
    todos: ko.observableArray([])
  };
  kb.collectionSync(todos, todo_list_view_model.todos, {
    viewModelCreate: function(model) {
      return new TodoViewModel(model);
    }
  });
  ko.applyBindings(todo_list_view_model, $('#todo-list')[0]);
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
  SortingOptionViewModel = function(string_id) {
    this.id = string_id;
    this.label = locale_manager.get(string_id);
    this.option_name = 'sort';
    return this;
  };
  list_sorting_options_view_model = [new SortingOptionViewModel('label_name'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_completed')];
  for (_k = 0, _len3 = list_sorting_options_view_model.length; _k < _len3; _k++) {
    view_model = list_sorting_options_view_model[_k];
    $('#todo-list-sorting').append($("#option-template").tmpl(view_model));
  }
  $('#todo-list-sorting').find('#label_created').attr({
    checked: 'checked'
  });
  footer_view_model = {
    instructions_text: locale_manager.get('instructions')
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