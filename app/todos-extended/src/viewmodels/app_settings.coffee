# Localization
LanguageOptionViewModel = (locale) ->
	@id = locale
	@label = kb.locale_manager.localeToLabel(locale)
	@option_group = 'lang'
	@

# Priorities
PrioritiesViewModel = (model) ->
	@priority = model.get('id')
	@priority_text = kb.observable(kb.locale_manager, {key: @priority})
	@priority_color = kb.observable(model, {key: 'color'})
	@

# List Sorting
ListSortingOptionViewModel = (string_id) ->
	@id = string_id
	@label = kb.observable(kb.locale_manager, {key: string_id})
	@option_group = 'list_sort'
	@

# Global App Settings
window.AppSettingsViewModel = ->
	window.app_settings = @ # publish so settings are available in AppViewModel

	@collections =
		priorities: new PriorityCollection()

	# Fetch the prioties late to show the dynamic nature of Knockback with Backbone.ModelRef
	_.delay((=>
		@collections.priorities.fetch(
			success: (collection) =>
				collection.create({id:'high', color:'#bf30ff'}) if not collection.get('high')
				collection.create({id:'medium', color:'#98acff'}) if not collection.get('medium')
				collection.create({id:'low', color:'#38ff6a'}) if not collection.get('low')
		)

		# set up color pickers
		$('.colorpicker').mColorPicker({imageFolder: $.fn.mColorPicker.init.imageFolder})
		$('.colorpicker').bind('colorpicked', =>
			model = @collections.priorities.get($(this).attr('id'))
			model.save({color: $(this).val()}) if model
		)
	), 1000)

	# Language settings
	@language_options = _.map(kb.locale_manager.getLocales(), (locale) -> return new LanguageOptionViewModel(locale))
	@current_language = ko.observable() # start in english
	@selected_language = ko.computed(
		read: => return @current_language() # used to create a dependency
		write: (new_locale) => kb.locale_manager.setLocale(new_locale); @current_language(new_locale)
	)
	@selected_language('en') # start in English by default

	# Priorities settings
	priorities = [
		new Backbone.ModelRef(@collections.priorities, 'high'),
		new Backbone.ModelRef(@collections.priorities, 'medium'),
		new Backbone.ModelRef(@collections.priorities, 'low')
	]
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

	# List sorting
	@list_sorting_options = [new ListSortingOptionViewModel('label_title'), new ListSortingOptionViewModel('label_created'), new ListSortingOptionViewModel('label_priority')]
	@selected_list_sorting = ko.observable('label_title')

	@