/*
  An example Backbone application contributed by
  [Jérôme Gravel-Niquet](http://jgn.me/). This demo uses a simple
  [LocalStorage adapter](backbone-localstorage.html)
  to persist Backbone models within your browser.

  Ported to Coffeescript by Kevin Malakoff.
*/
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
window.Todo = (function() {
  __extends(Todo, Backbone.Model);
  function Todo() {
    Todo.__super__.constructor.apply(this, arguments);
  }
  Todo.prototype.defaults = function() {
    return {
      done: false,
      order: Todos.nextOrder()
    };
  };
  Todo.prototype.toggle = function() {
    return this.save({
      done: !this.get("done")
    });
  };
  return Todo;
})();
window.TodoList = (function() {
  __extends(TodoList, Backbone.Collection);
  function TodoList() {
    TodoList.__super__.constructor.apply(this, arguments);
  }
  TodoList.prototype.model = Todo;
  TodoList.prototype.localStorage = new Store("todos");
  TodoList.prototype.done = function() {
    return this.filter(function(todo) {
      return todo.get('done');
    });
  };
  TodoList.prototype.remaining = function() {
    return this.without.apply(this, this.done());
  };
  TodoList.prototype.nextOrder = function() {
    if (!this.length) {
      return 1;
    }
    return this.last().get('order') + 1;
  };
  TodoList.prototype.comparator = function(todo) {
    return todo.get('order');
  };
  return TodoList;
})();
window.Todos = new TodoList;
window.TodoView = (function() {
  __extends(TodoView, Backbone.View);
  function TodoView() {
    TodoView.__super__.constructor.apply(this, arguments);
  }
  TodoView.prototype.tagName = "li";
  TodoView.prototype.template = function() {
    return _.template($('#item-template').html());
  };
  TodoView.prototype.events = {
    "click .check": "toggleDone",
    "dblclick div.todo-text": "edit",
    "click span.todo-destroy": "clear",
    "keypress .todo-input": "updateOnEnter"
  };
  TodoView.prototype.initialize = function() {
    this.model.bind('change', this.render, this);
    return this.model.bind('destroy', this.remove, this);
  };
  TodoView.prototype.render = function() {
    $(this.el).html(this.template()(this.model.toJSON()));
    this.setText();
    return this;
  };
  TodoView.prototype.setText = function() {
    var text;
    text = this.model.get('text');
    this.$('.todo-text').text(text);
    this.input = this.$('.todo-input');
    return this.input.bind('blur', _.bind(this.close, this)).val(text);
  };
  TodoView.prototype.toggleDone = function() {
    return this.model.toggle();
  };
  TodoView.prototype.edit = function() {
    $(this.el).addClass("editing");
    return this.input.focus();
  };
  TodoView.prototype.close = function() {
    this.model.save({
      text: this.input.val()
    });
    return $(this.el).removeClass("editing");
  };
  TodoView.prototype.updateOnEnter = function(e) {
    if (e.keyCode === 13) {
      return this.close();
    }
  };
  TodoView.prototype.remove = function() {
    return $(this.el).remove();
  };
  TodoView.prototype.clear = function() {
    return this.model.destroy();
  };
  return TodoView;
})();
window.AppView = (function() {
  __extends(AppView, Backbone.View);
  function AppView() {
    AppView.__super__.constructor.apply(this, arguments);
  }
  AppView.prototype.el = "#todoapp";
  AppView.prototype.statsTemplate = function() {
    return _.template($('#stats-template').html());
  };
  AppView.prototype.events = {
    "keypress #new-todo": "createOnEnter",
    "keyup #new-todo": "showTooltip",
    "click .todo-clear a": "clearCompleted"
  };
  AppView.prototype.initialize = function() {
    this.input = this.$("#new-todo");
    Todos.bind('add', this.addOne, this);
    Todos.bind('reset', this.addAll, this);
    Todos.bind('all', this.render, this);
    return Todos.fetch();
  };
  AppView.prototype.render = function() {
    return this.$('#todo-stats').html(this.statsTemplate()({
      total: Todos.length,
      done: Todos.done().length,
      remaining: Todos.remaining().length
    }));
  };
  AppView.prototype.addOne = function(todo) {
    var view;
    view = new TodoView({
      model: todo
    });
    return this.$("#todo-list").append(view.render().el);
  };
  AppView.prototype.addAll = function() {
    return Todos.each(this.addOne);
  };
  AppView.prototype.createOnEnter = function(e) {
    var text;
    text = this.input.val();
    if (!text || e.keyCode !== 13) {
      return;
    }
    Todos.create({
      text: text
    });
    return this.input.val('');
  };
  AppView.prototype.clearCompleted = function() {
    _.each(Todos.done(), function(todo) {
      return todo.destroy();
    });
    return false;
  };
  AppView.prototype.showTooltip = function(e) {
    var show, tooltip, val;
    tooltip = this.$(".ui-tooltip-top");
    val = this.input.val();
    tooltip.fadeOut();
    if (this.tooltipTimeout) {
      clearTimeout(this.tooltipTimeout);
    }
    if (val === '' || val === this.input.attr('placeholder')) {
      return;
    }
    show = function() {
      return tooltip.show().fadeIn();
    };
    return this.tooltipTimeout = _.delay(show, 1000);
  };
  return AppView;
})();
$(document).ready(function() {
  return window.App = new AppView;
});