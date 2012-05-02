(function() {
  var ENTER_KEY;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  ENTER_KEY = 13;
  window.HeaderViewModel = function(todos) {
    var tooltip_visible;
    this.title = ko.observable('');
    this.onAddTodo = __bind(function(view_model, event) {
      if (!$.trim(this.title()) || (event.keyCode !== ENTER_KEY)) {
        return true;
      }
      todos.create({
        title: $.trim(this.title()),
        priority: app.viewmodels.settings.default_priority()
      });
      return this.title('');
    }, this);
    this.input_placeholder_text = kb.observable(kb.locale_manager, {
      key: 'placeholder_create'
    });
    this.input_tooltip_text = kb.observable(kb.locale_manager, {
      key: 'tooltip_create'
    });
    this.priority_color = ko.computed(function() {
      return app.viewmodels.settings.default_priority_color();
    });
    this.tooltip_visible = ko.observable(false);
    tooltip_visible = this.tooltip_visible;
    this.onSelectPriority = function(view_model, event) {
      event.stopPropagation();
      tooltip_visible(false);
      return app.viewmodels.settings.default_priority(ko.utils.unwrapObservable(this.priority));
    };
    this.onToggleTooltip = __bind(function() {
      return this.tooltip_visible(!this.tooltip_visible());
    }, this);
    return this;
  };
}).call(this);