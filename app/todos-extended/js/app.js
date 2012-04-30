(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var priorities, todos;
    kb.locale_manager.setLocale('en');
    kb.locale_change_observable = kb.triggeredObservable(kb.locale_manager, 'change');
    ko.bindingHandlers.dblclick = {
      init: function(element, value_accessor) {
        return $(element).dblclick(ko.utils.unwrapObservable(value_accessor()));
      }
    };
    ko.bindingHandlers.block = {
      update: function(element, value_accessor) {
        return element.style.display = ko.utils.unwrapObservable(value_accessor()) ? 'block' : 'none';
      }
    };
    ko.bindingHandlers.selectAndFocus = {
      init: function(element, value_accessor, all_bindings_accessor) {
        ko.bindingHandlers.hasfocus.init(element, value_accessor, all_bindings_accessor);
        return ko.utils.registerEventHandler(element, 'focus', function() {
          return element.select();
        });
      },
      update: function(element, value_accessor) {
        ko.utils.unwrapObservable(value_accessor());
        return _.defer(__bind(function() {
          return ko.bindingHandlers.hasfocus.update(element, value_accessor);
        }, this));
      }
    };
    ko.bindingHandlers.placeholder = {
      update: function(element, value_accessor, all_bindings_accessor, view_model) {
        return $(element).attr('placeholder', ko.utils.unwrapObservable(value_accessor()));
      }
    };
    priorities = new PrioritiesCollection();
    window.app_settings_view_model = new AppSettingsViewModel([new Backbone.ModelRef(priorities, 'high'), new Backbone.ModelRef(priorities, 'medium'), new Backbone.ModelRef(priorities, 'low')], kb.locale_manager.getLocales());
    ko.applyBindings(app_settings_view_model, $('#todoapp-settings')[0]);
    todos = new TodosCollection();
    window.app_view_model = new AppViewModel(todos);
    ko.applyBindings(app_view_model, $('#todoapp')[0]);
    new AppRouter();
    Backbone.history.start();
    todos.fetch();
    return _.delay((function() {
      priorities.fetch({
        success: function(collection) {
          if (!collection.get('high')) {
            collection.create({
              id: 'high',
              color: '#bf30ff'
            });
          }
          if (!collection.get('medium')) {
            collection.create({
              id: 'medium',
              color: '#98acff'
            });
          }
          if (!collection.get('low')) {
            return collection.create({
              id: 'low',
              color: '#38ff6a'
            });
          }
        }
      });
      $('.colorpicker').mColorPicker({
        imageFolder: 'app/todos-extended/css/images/'
      });
      return $('.colorpicker').bind('colorpicked', function() {
        var model;
        model = priorities.get($(this).attr('id'));
        if (model) {
          return model.save({
            color: $(this).val()
          });
        }
      });
    }), 1000);
  });
}).call(this);
