(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  window.PrioritiesCollection = (function() {
    __extends(PrioritiesCollection, Backbone.Collection);
    function PrioritiesCollection() {
      PrioritiesCollection.__super__.constructor.apply(this, arguments);
    }
    PrioritiesCollection.prototype.localStorage = new Store('priorities-knockback-extended');
    return PrioritiesCollection;
  })();
}).call(this);
