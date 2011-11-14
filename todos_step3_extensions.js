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
  var $all_priority_pickers, LanguageOptionViewModel, PrioritiesSetting, PrioritiesSettingList, PrioritySettingsViewModel, SortingOptionViewModel, Todo, TodoList, TodoViewModel, create_view_model, footer_view_model, header_view_model, languages_view_model, locale, priorities, stats_view_model, todo_list_view_model, todos, _i, _len, _ref;
  kb.locale_manager.setLocale('en');
  kb.localized_dummy = kb.observable(kb.locale_manager, {
    key: 'remaining_template_s'
  });
  ko.bindingHandlers.dblclick = {
    init: function(element, value_accessor, all_bindings_accessor, view_model) {
      return $(element).dblclick(ko.utils.unwrapObservable(value_accessor()));
    }
  };
  PrioritiesSetting = (function() {
    __extends(PrioritiesSetting, Backbone.Model);
    function PrioritiesSetting() {
      PrioritiesSetting.__super__.constructor.apply(this, arguments);
    }
    return PrioritiesSetting;
  })();
  PrioritiesSettingList = (function() {
    __extends(PrioritiesSettingList, Backbone.Collection);
    function PrioritiesSettingList() {
      PrioritiesSettingList.__super__.constructor.apply(this, arguments);
    }
    PrioritiesSettingList.prototype.model = PrioritiesSetting;
    PrioritiesSettingList.prototype.localStorage = new Store("kb_priorities");
    return PrioritiesSettingList;
  })();
  priorities = new PrioritiesSettingList();
  priorities.fetch({
    success: function(collection) {
      if (!collection.get('high')) {
        collection.create({
          id: 'high',
          color: '#c00020'
        });
      }
      if (!collection.get('medium')) {
        collection.create({
          id: 'medium',
          color: '#c08040'
        });
      }
      if (!collection.get('low')) {
        return collection.create({
          id: 'low',
          color: '#00ff60'
        });
      }
    }
  });
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
    this.label = kb.locale_manager.localeToLabel(locale);
    this.option_group = 'lang';
    this.onClick = function() {};
    return this;
  };
  languages_view_model = {
    language_options: ko.observableArray([])
  };
  languages_view_model.current_language = ko.dependentObservable({
    read: function() {
      return kb.locale_manager.getLocale();
    },
    write: function(new_locale) {
      return kb.locale_manager.setLocale(new_locale);
    },
    owner: todo_list_view_model
  });
  _ref = kb.locale_manager.getLocales();
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    locale = _ref[_i];
    languages_view_model.language_options.push(new LanguageOptionViewModel(locale));
  }
  ko.applyBindings(languages_view_model, $('#todo-languages')[0]);
  PrioritySettingsViewModel = function(model) {
    this.priority = kb.observable(model, {
      key: 'id'
    });
    this.priority_text = ko.dependentObservable(__bind(function() {
      kb.localized_dummy();
      return kb.locale_manager.get(this.priority());
    }, this));
    this.priority_color = kb.observable(model, {
      key: 'color'
    });
    return this;
  };
  window.settings_view_model = {
    priority_settings: ko.observableArray([]),
    default_priority: ko.observable('medium'),
    getColorByPriority: function(priority) {
      check_color;
      var check_color, color, view_model, _j, _len2, _ref2;
      color = '';
      _ref2 = settings_view_model.priority_settings();
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        view_model = _ref2[_j];
        check_color = view_model.priority_color();
        if (view_model.priority() === priority) {
          color = check_color;
        }
      }
      return color;
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
  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(new Backbone.ModelRef(priorities, 'high')));
  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(new Backbone.ModelRef(priorities, 'medium')));
  settings_view_model.priority_settings.push(new PrioritySettingsViewModel(new Backbone.ModelRef(priorities, 'low')));
  settings_view_model.default_priority_color = ko.dependentObservable(function() {
    return settings_view_model.getColorByPriority(settings_view_model.default_priority());
  });
  header_view_model = {
    title: "Todos"
  };
  ko.applyBindings(header_view_model, $('#todo-header')[0]);
  create_view_model = {
    input_text: ko.observable(''),
    input_placeholder_text: kb.observable(kb.locale_manager, {
      key: 'placeholder_create'
    }),
    input_tooltip_text: kb.observable(kb.locale_manager, {
      key: 'tooltip_create'
    }),
    priority_color: ko.dependentObservable(function() {
      return window.settings_view_model.default_priority_color();
    }),
    setDefaultPriority: function(priority) {
      return settings_view_model.default_priority(ko.utils.unwrapObservable(priority));
    },
    addTodo: function(event) {
      var text;
      text = this.input_text();
      if (!text || event.keyCode !== 13) {
        return true;
      }
      todos.create({
        text: text,
        priority: settings_view_model.default_priority()
      });
      return this.input_text('');
    }
  };
  ko.applyBindings(create_view_model, $('#todo-create')[0]);
  SortingOptionViewModel = function(string_id) {
    this.id = string_id;
    this.label = kb.observable(kb.locale_manager, {
      key: string_id
    });
    this.option_group = 'list_sort';
    return this;
  };
  TodoViewModel = function(model) {
    this.text = kb.observable(model, {
      key: 'text',
      write: (function(text) {
        return model.save({
          text: text
        });
      })
    }, this);
    this.edit_mode = ko.observable(false);
    this.toggleEditMode = __bind(function() {
      return this.edit_mode(!this.edit_mode());
    }, this);
    this.onEnterEndEdit = __bind(function(event) {
      if (event.keyCode === 13) {
        return this.toggleEditMode();
      }
    }, this);
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
    this.done_at = kb.observable(model, {
      key: 'done_at',
      localizer: function(value) {
        return new LongDateLocalizer(value);
      }
    });
    this.done_text = ko.dependentObservable(__bind(function() {
      if (!!model.get('done_at')) {
        return "" + (kb.locale_manager.get('label_completed')) + ": " + (this.done_at());
      } else {
        return '';
      }
    }, this));
    this.setTodoPriority = function(priority) {
      return model.save({
        priority: ko.utils.unwrapObservable(priority)
      });
    };
    this.priority_color = kb.observable(model, {
      key: 'priority',
      read: function() {
        return settings_view_model.getColorByPriority(model.get('priority'));
      }
    });
    this.destroyTodo = __bind(function() {
      return model.destroy();
    }, this);
    return this;
  };
  todo_list_view_model = {
    todos: ko.observableArray([]),
    _list_sorting_mode: null
  };
  todo_list_view_model.list_sorting_mode = ko.dependentObservable({
    read: function() {
      return todo_list_view_model._list_sorting_mode;
    },
    write: function(new_mode) {
      todo_list_view_model._list_sorting_mode = new_mode;
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
              return settings_view_model.priorityToRank(test.get('priority'));
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
  todo_list_view_model._list_sorting_mode = 'label_name';
  todo_list_view_model.list_sorting_mode(todo_list_view_model._list_sorting_mode);
  stats_view_model = {
    remaining_text: ko.dependentObservable(function() {
      var count;
      kb.localized_dummy();
      count = collection_observable.collection().remainingCount();
      if (!count) {
        return '';
      }
      return kb.locale_manager.get((count === 1 ? 'remaining_template_s' : 'remaining_template_pl'), count);
    }),
    clear_text: ko.dependentObservable(function() {
      var count;
      kb.localized_dummy();
      count = collection_observable.collection().doneCount();
      if (!count) {
        return '';
      }
      return kb.locale_manager.get((count === 1 ? 'clear_template_s' : 'clear_template_pl'), count);
    }),
    onDestroyDone: function() {
      var model, _j, _len2, _ref2, _results;
      _ref2 = todos.allDone();
      _results = [];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        model = _ref2[_j];
        _results.push(model.destroy());
      }
      return _results;
    }
  };
  ko.applyBindings(stats_view_model, $('#todo-stats')[0]);
  footer_view_model = {
    instructions_text: kb.observable(kb.locale_manager, {
      key: 'instructions'
    })
  };
  ko.applyBindings(footer_view_model, $('#todo-footer')[0]);
  $all_priority_pickers = $('body').find('.priority-picker-tooltip');
  $('.colorpicker').mColorPicker();
  $('.colorpicker').bind('colorpicked', function() {
    var model;
    model = priorities.get($(this).attr('id'));
    if (model) {
      return model.save({
        color: $(this).val()
      });
    }
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