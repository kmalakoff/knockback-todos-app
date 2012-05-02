(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  window.PriorityCollection = (function() {
    __extends(PriorityCollection, Backbone.Collection);
    function PriorityCollection() {
      PriorityCollection.__super__.constructor.apply(this, arguments);
    }
    PriorityCollection.prototype.localStorage = new Store('priorities-knockback-extended');
    return PriorityCollection;
  })();
}).call(this);
