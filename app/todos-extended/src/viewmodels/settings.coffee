# EXTENSIONS: Localization
SettingLanguageOptionViewModel = (locale) ->
	@id = locale
	@label = kb.locale_manager.localeToLabel(locale)
	@option_group = 'lang'
	@

# EXTENSIONS: Priorities
PrioritiesViewModel = (model) ->
	@priority = model.get('id')
	@priority_text = kb.observable(kb.locale_manager, {key: @priority})
	@priority_color = kb.observable(model, {key: 'color'})
	@

# EXTENSIONS: List Sorting
SettingListSortingOptionViewModel = (string_id) ->
	@id = string_id
	@label = kb.observable(kb.locale_manager, {key: string_id})
	@option_group = 'list_sort'
	@

window.SettingsViewModel = (priorities, locales) ->
	# EXTENSIONS: Language settings
	@language_options = _.map(locales, (locale) -> return new SettingLanguageOptionViewModel(locale))
	@current_language = ko.observable(kb.locale_manager.getLocale())
	@selected_language = ko.computed(
		read: => return @current_language()  # used to create a dependency
		write: (new_locale) => kb.locale_manager.setLocale(new_locale); @current_language(new_locale)
	)

	# EXTENSIONS: Priorities settings
	@priorities = _.map(priorities, (model) -> return new PrioritiesViewModel(model))
	@getColorByPriority = (priority) ->
		@createColorsDependency()
		(return view_model.priority_color() if view_model.priority == priority) for view_model in @priorities
		return ''
	@createColorsDependency = => view_model.priority_color() for view_model in @priorities
	@default_priority = ko.observable('medium')
	@default_priority_color = ko.computed(=> return @getColorByPriority(@default_priority()))
	@priorityToRank = (priority) ->
		switch priority
			when 'high' then return 0
			when 'medium' then return 1
			when 'low' then return 2

	@list_filter_mode = ko.observable('')
	# EXTENSIONS: List sorting
	@list_sorting_options = [new SettingListSortingOptionViewModel('label_text'), new SettingListSortingOptionViewModel('label_created'), new SettingListSortingOptionViewModel('label_priority')]
	@selected_list_sorting = ko.observable('label_text')

	# EXTENSIONS: Localization
	@label_filter_all = kb.observable(kb.locale_manager, 'todo_filter_all')
	@label_filter_active = kb.observable(kb.locale_manager, 'todo_filter_active')
	@label_filter_completed = kb.observable(kb.locale_manager, 'todo_filter_completed')
	@
