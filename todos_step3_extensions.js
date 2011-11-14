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
  var $all_priority_pickers, LanguageOptionViewModel, PrioritiesSetting, PrioritySettingsViewModel, SortingOptionViewModel, Todo, TodoList, TodoViewModel, create_view_model, footer_view_model, header_view_model, locale, model, settings, stats_view_model, todo_list_view_model, todos, _i, _j, _len, _len2, _ref, _ref2;
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
  settings = {
    list_sorting_mode: '',
    priorities: [
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
      _ref = settings.priorities;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        if (model.get('priority') === priority) {
          return model;
        }
      }
      return '';
    },
    priorityToRank: function(priority) {
      switch (priority) {
        case 'high':
          return 0;
        case 'medium':
          return 1;
        case 'low':
          return 2;
      }
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
    Todo.prototype.set = function(attrs) {
      if (attrs && attrs.hasOwnProperty('done_at') && _.isString(attrs['done_at'])) {
        attrs['done_at'] = new Date(attrs['done_at']);
      }
      if (attrs && attrs.hasOwnProperty('created_at') && _.isString(attrs['created_at'])) {
        attrs['created_at'] = new Date(attrs['created_at']);
      }
      return Todo.__super__.set.apply(this, arguments);
    };
    Todo.prototype.isDone = function() {
      return !!this.get('done_at');
    };
    Todo.prototype.done = function(done) {
      return this.save({
        done_at: done ? new Date() : null
      });
    };
    Todo.prototype.destroyDone = function(done) {
      return this.save({
        done_at: done ? new Date() : null
      });
    };
    return Todo;
  })();
  TodoList = (function() {
    __extends(TodoList, Backbone.Collection);
    function TodoList() {
      TodoList.__super__.constructor.apply(this, arguments);
    }
    TodoList.prototype.model = Todo;
    TodoList.prototype.localStorage = new Store("kb_todos");
    TodoList.prototype.doneCount = function() {
      return this.models.reduce((function(prev, cur) {
        return prev + (!!cur.get('done_at') ? 1 : 0);
      }), 0);
    };
    TodoList.prototype.remainingCount = function() {
      return this.models.length - this.doneCount();
    };
    TodoList.prototype.allDone = function() {
      return this.filter(function(todo) {
        return !!todo.get('done_at');
      });
    };
    return TodoList;
  })();
  todos = new TodoList();
  todos.fetch();
  LanguageOptionViewModel = function(locale) {
    this.id = locale;
    this.label = locale_manager.localeToLabel(locale);
    this.option_group = 'lang';
    this.onClick = function() {};
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
  _ref2 = settings.priorities;
  for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
    model = _ref2[_j];
    settings_view_model.priority_settings.push(new PrioritySettingsViewModel(model));
  }
  settings_view_model.setDefault(settings.priorities[0].get('priority'));
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
  SortingOptionViewModel = function(string_id) {
    this.id = string_id;
    this.label = locale_manager.get(string_id);
    this.option_group = 'list_sort';
    return this;
  };
  TodoViewModel = function(model) {
    this.text = model.get('text');
    this.created_at = model.get('created_at');
    this.done = kb.observable(model, {
      key: 'done_at',
      read: (function() {
        return model.isDone();
      }),
      write: (function(done) {
        return model.done(done);
      })
    }, this);
    this.done_text = kb.observable(model, {
      key: 'done_at',
      read: (function() {
        if (!!model.get('done_at')) {
          return "" + (locale_manager.get('label_completed')) + ": " + (locale_manager.localizeDate(model.get('done_at')));
        } else {
          return '';
        }
      })
    });
    this.priority_color = settings.getColorByPriority(model.get('priority'));
    this.destroyTodo = __bind(function() {
      return model.destroy();
    }, this);
    return this;
  };
  todo_list_view_model = {
    todos: ko.observableArray([])
  };
  todo_list_view_model.list_sorting_mode = ko.dependentObservable({
    read: function() {
      return settings.list_sorting_mode;
    },
    write: function(new_mode) {
      settings.list_sorting_mode = new_mode;
      switch (new_mode) {
        case 'label_name':
          return window.collection_observable.sorting(function(models, model) {
            return _.sortedIndex(models, model, function(test) {
              return test.get('text');
            });
          });
        case 'label_created':
          return window.collection_observable.sorting(function(models, model) {
            return _.sortedIndex(models, model, function(test) {
              return test.get('created_at').valueOf();
            });
          });
        case 'label_priority':
          return window.collection_observable.sorting(function(models, model) {
            return _.sortedIndex(models, model, function(test) {
              return settings.priorityToRank(test.get('priority'));
            });
          });
      }
    },
    owner: todo_list_view_model
  });
  window.collection_observable = kb.collectionObservable(todos, todo_list_view_model.todos, {
    viewModelCreate: function(model) {
      return new TodoViewModel(model);
    }
  });
  todo_list_view_model.sort_visible = ko.dependentObservable(function() {
    return collection_observable().length;
  });
  todo_list_view_model.sorting_options = [new SortingOptionViewModel('label_name'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_priority')];
  ko.applyBindings(todo_list_view_model, $('#todo-list')[0]);
  settings.list_sorting_mode = 'label_name';
  todo_list_view_model.list_sorting_mode(settings.list_sorting_mode);
  stats_view_model = {
    remaining_text: ko.dependentObservable(function() {
      var count;
      count = collection_observable.collection().remainingCount();
      if (!count) {
        return '';
      }
      return locale_manager.get((count === 1 ? 'remaining_template_s' : 'remaining_template_pl'), count);
    }),
    clear_text: ko.dependentObservable(function() {
      var count;
      count = collection_observable.collection().doneCount();
      if (!count) {
        return '';
      }
      return locale_manager.get((count === 1 ? 'clear_template_s' : 'clear_template_pl'), count);
    }),
    onDestroyDone: function() {
      var model, _k, _len3, _ref3, _results;
      _ref3 = todos.allDone();
      _results = [];
      for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
        model = _ref3[_k];
        _results.push(model.destroy());
      }
      return _results;
    }
  };
  ko.applyBindings(stats_view_model, $('#todo-stats')[0]);
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