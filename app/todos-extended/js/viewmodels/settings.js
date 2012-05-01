(function() {
  var PrioritiesViewModel, SettingLanguageOptionViewModel, SettingListSortingOptionViewModel;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  SettingLanguageOptionViewModel = function(locale) {
    this.id = locale;
    this.label = kb.locale_manager.localeToLabel(locale);
    this.option_group = 'lang';
    return this;
  };
  PrioritiesViewModel = function(model) {
    this.priority = model.get('id');
    this.priority_text = kb.observable(kb.locale_manager, {
      key: this.priority
    });
    this.priority_color = kb.observable(model, {
      key: 'color'
    });
    return this;
  };
  SettingListSortingOptionViewModel = function(string_id) {
    this.id = string_id;
    this.label = kb.observable(kb.locale_manager, {
      key: string_id
    });
    this.option_group = 'list_sort';
    return this;
  };
  window.SettingsViewModel = function(priorities, locales) {
    this.current_language = ko.observable(kb.locale_manager.getLocale());
    this.language_options = _.map(locales, function(locale) {
      return new SettingLanguageOptionViewModel(locale);
    });
    this.selected_language = ko.computed({
      read: __bind(function() {
        return this.current_language();
      }, this),
      write: __bind(function(new_locale) {
        kb.locale_manager.setLocale(new_locale);
        return this.current_language(new_locale);
      }, this)
    });
    this.priorities = _.map(priorities, function(model) {
      return new PrioritiesViewModel(model);
    });
    this.getColorByPriority = function(priority) {
      var view_model, _i, _len, _ref;
      this.createColorsDependency();
      _ref = this.priorities;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        view_model = _ref[_i];
        if (view_model.priority === priority) {
          return view_model.priority_color();
        }
      }
      return '';
    };
    this.createColorsDependency = __bind(function() {
      var view_model, _i, _len, _ref, _results;
      _ref = this.priorities;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        view_model = _ref[_i];
        _results.push(view_model.priority_color());
      }
      return _results;
    }, this);
    this.default_priority = ko.observable('medium');
    this.default_priority_color = ko.computed(__bind(function() {
      return this.getColorByPriority(this.default_priority());
    }, this));
    this.priorityToRank = function(priority) {
      switch (priority) {
        case 'high':
          return 0;
        case 'medium':
          return 1;
        case 'low':
          return 2;
      }
    };
    this.list_filter_mode = ko.observable('');
    this.list_sorting_options = [new SettingListSortingOptionViewModel('label_text'), new SettingListSortingOptionViewModel('label_created'), new SettingListSortingOptionViewModel('label_priority')];
    this.selected_list_sorting = ko.observable('label_text');
    this.label_filter_all = kb.observable(kb.locale_manager, 'todo_filter_all');
    this.label_filter_active = kb.observable(kb.locale_manager, 'todo_filter_active');
    this.label_filter_completed = kb.observable(kb.locale_manager, 'todo_filter_completed');
    return this;
  };
}).call(this);
