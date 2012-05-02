(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.FooterViewModel = function(todos) {
    this.collection_observable = kb.collectionObservable(todos);
    this.remaining_text_key = ko.computed(__bind(function() {
      if (todos.remainingCount() === 1) {
        return 'remaining_template_s';
      } else {
        return 'remaining_template_pl';
      }
    }, this));
    this.remaining_text = kb.observable(kb.locale_manager, {
      key: this.remaining_text_key,
      args: __bind(function() {
        return this.collection_observable.collection().remainingCount();
      }, this)
    });
    this.clear_text_key = ko.computed(__bind(function() {
      if (this.collection_observable.collection().completedCount() === 0) {
        return null;
      } else {
        if (todos.completedCount() === 1) {
          return 'clear_template_s';
        } else {
          return 'clear_template_pl';
        }
      }
    }, this));
    this.clear_text = kb.observable(kb.locale_manager, {
      key: this.clear_text_key,
      args: __bind(function() {
        return this.collection_observable.collection().completedCount();
      }, this)
    });
    this.onDestroyCompleted = __bind(function() {
      return todos.destroyCompleted();
    }, this);
    this.instructions_text = kb.observable(kb.locale_manager, {
      key: 'instructions'
    });
    return this;
  };
}).call(this);
