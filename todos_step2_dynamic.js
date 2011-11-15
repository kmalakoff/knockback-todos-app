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
  var CreateTodoViewModel, StatsViewModel, Todo, TodoList, TodoListViewModel, TodoViewModel, create_view_model, footer_view_model, header_view_model, stats_view_model, todo_list_view_model, todos;
  kb.locale_manager.setLocale('en');
  ko.bindingHandlers.dblclick = {
    init: function(element, value_accessor, all_bindings_accessor, view_model) {
      return $(element).dblclick(ko.utils.unwrapObservable(value_accessor()));
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
  header_view_model = {
    title: "Todos"
  };
  $('#todo-header').append($("#header-template").tmpl(header_view_model));
  CreateTodoViewModel = function() {
    this.input_text = ko.observable('');
    this.input_placeholder_text = kb.observable(kb.locale_manager, {
      key: 'placeholder_create'
    });
    this.input_tooltip_text = kb.observable(kb.locale_manager, {
      key: 'tooltip_create'
    });
    this.addTodo = function(event) {
      var text;
      text = this.input_text();
      if (!text || event.keyCode !== 13) {
        return true;
      }
      todos.create({
        text: text
      });
      return this.input_text('');
    };
    return true;
  };
  create_view_model = new CreateTodoViewModel();
  ko.applyBindings(create_view_model, $('#todo-create')[0]);
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
      if (!this.done()) {
        return this.edit_mode(!this.edit_mode());
      }
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
    this.destroyTodo = __bind(function() {
      return model.destroy();
    }, this);
    return this;
  };
  TodoListViewModel = function(todos) {
    this.todos = ko.observableArray([]);
    this.collection_observable = kb.collectionObservable(todos, this.todos, {
      view_model: TodoViewModel
    });
    return true;
  };
  todo_list_view_model = new TodoListViewModel(todos);
  ko.applyBindings(todo_list_view_model, $('#todo-list')[0]);
  StatsViewModel = function(todos) {
    this.collection_observable = kb.collectionObservable(todos, this.todos);
    this.remaining_text = ko.dependentObservable(__bind(function() {
      var count;
      count = this.collection_observable.collection().remainingCount();
      if (!count) {
        return '';
      }
      return kb.locale_manager.get((count === 1 ? 'remaining_template_s' : 'remaining_template_pl'), count);
    }, this));
    this.clear_text = ko.dependentObservable(__bind(function() {
      var count;
      count = this.collection_observable.collection().doneCount();
      if (!count) {
        return '';
      }
      return kb.locale_manager.get((count === 1 ? 'clear_template_s' : 'clear_template_pl'), count);
    }, this));
    this.onDestroyDone = function() {
      var model, _i, _len, _ref, _results;
      _ref = todos.allDone();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        _results.push(model.destroy());
      }
      return _results;
    };
    return this;
  };
  stats_view_model = new StatsViewModel(todos);
  ko.applyBindings(stats_view_model, $('#todo-stats')[0]);
  footer_view_model = {
    instructions_text: kb.locale_manager.get('instructions')
  };
  return $('#todo-footer').append($("#footer-template").tmpl(footer_view_model));
});