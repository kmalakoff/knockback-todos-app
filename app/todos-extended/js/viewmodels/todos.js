(function() {
  var TodoViewModel;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  TodoViewModel = function(model) {
    var tooltip_visible;
    this.editing = ko.observable(false);
    this.completed = kb.observable(model, {
      key: 'completed',
      read: (function() {
        return model.completed();
      }),
      write: (function(completed) {
        return model.completed(completed);
      })
    }, this);
    this.visible = ko.computed(__bind(function() {
      switch (app.viewmodels.settings.list_filter_mode()) {
        case 'active':
          return !this.completed();
        case 'completed':
          return this.completed();
        default:
          return true;
      }
    }, this));
    this.title = kb.observable(model, {
      key: 'title',
      write: (__bind(function(title) {
        if ($.trim(title)) {
          model.save({
            title: $.trim(title)
          });
        } else {
          _.defer(function() {
            return model.destroy();
          });
        }
        return this.editing(false);
      }, this))
    }, this);
    this.onDestroyTodo = __bind(function() {
      return model.destroy();
    }, this);
    this.onCheckEditBegin = __bind(function() {
      if (!this.editing() && !this.completed()) {
        this.editing(true);
        return $('.todo-input').focus();
      }
    }, this);
    this.onCheckEditEnd = __bind(function(view_model, event) {
      if ((event.keyCode === 13) || (event.type === 'blur')) {
        $('.todo-input').blur();
        return this.editing(false);
      }
    }, this);
    this.created_at = model.get('created_at');
    this.completed_at = kb.observable(model, {
      key: 'completed',
      localizer: LongDateLocalizer
    });
    this.completed_text = ko.computed(__bind(function() {
      var completed_at;
      completed_at = this.completed_at();
      if (!!completed_at) {
        return "" + (kb.locale_manager.get('label_completed')) + ": " + completed_at;
      } else {
        return '';
      }
    }, this));
    this.priority_color = kb.observable(model, {
      key: 'priority',
      read: function() {
        return app.viewmodels.settings.getColorByPriority(model.get('priority'));
      }
    });
    this.tooltip_visible = ko.observable(false);
    tooltip_visible = this.tooltip_visible;
    this.onSelectPriority = function(view_model, event) {
      event.stopPropagation();
      tooltip_visible(false);
      return model.save({
        priority: ko.utils.unwrapObservable(this.priority)
      });
    };
    this.onToggleTooltip = __bind(function() {
      return this.tooltip_visible(!this.tooltip_visible());
    }, this);
    return this;
  };
  window.TodosViewModel = function(todos) {
    this.todos = ko.observableArray([]);
    this.collection_observable = kb.collectionObservable(todos, this.todos, {
      view_model: TodoViewModel,
      sort_attribute: 'title'
    });
    this.sort_mode = ko.computed(__bind(function() {
      var new_mode;
      new_mode = app.viewmodels.settings.selected_list_sorting();
      return _.defer(__bind(function() {
        switch (new_mode) {
          case 'label_text':
            return this.collection_observable.sortAttribute('title');
          case 'label_created':
            return this.collection_observable.sortedIndex(function(models, model) {
              return _.sortedIndex(models, model, function(test) {
                return test.get('created_at').valueOf();
              });
            });
          case 'label_priority':
            return this.collection_observable.sortedIndex(function(models, model) {
              return _.sortedIndex(models, model, __bind(function(test) {
                return app.viewmodels.settings.priorityToRank(test.get('priority'));
              }, this));
            });
        }
      }, this));
    }, this));
    this.tasks_exist = ko.computed(__bind(function() {
      return this.collection_observable().length;
    }, this));
    this.all_completed = ko.computed({
      read: __bind(function() {
        return !this.collection_observable.collection().remainingCount();
      }, this),
      write: __bind(function(completed) {
        return this.collection_observable.collection().completeAll(completed);
      }, this)
    });
    this.completed_all_text = kb.observable(kb.locale_manager, {
      key: 'completed_all'
    });
    return this;
  };
}).call(this);
