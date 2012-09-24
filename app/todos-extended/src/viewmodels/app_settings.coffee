# Localization
LanguageOptionViewModel = (locale) ->
	@id = locale
	@label = kb.locale_manager.localeToLabel(locale)
	@option_group = 'lang'
	@

# Priorities
PrioritiesViewModel = (model) ->
	@priority = model.get('id')
	@priority_text = kb.observable(kb.locale_manager, @priority)
	@priority_color = kb.observable(model, 'color')
	@

# List Sorting
ListSortingOptionViewModel = (string_id) ->
	@id = string_id
	@label = kb.observable(kb.locale_manager, string_id)
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
		$('.colorpicker').bind('colorpicked', (event) =>
			$input = $(event.currentTarget)
			model = @collections.priorities.get($input.attr('id'))
			model.save({color: $input.val()}) if model
		)
		return
	), 1000)

	# Language settings
	@language_options = _.map(kb.locale_manager.getLocales(), (locale) -> new LanguageOptionViewModel(locale))
	@current_language = ko.observable() # start in english
	@selected_language = ko.computed(
		read: => return @current_language() # used to create a dependency
		write: (new_locale) => kb.locale_manager.setLocale(new_locale); @current_language(new_locale)
	)
	@selected_language('en') # start in English by default

	# Priorities settings
	priorities = _.map(['high', 'medium', 'low'], (priority) => new Backbone.ModelRef(@collections.priorities, priority))
	@priorities = _.map(priorities, (model) -> return new PrioritiesViewModel(model))
	@getColorByPriority = (priority) ->
		view_model.priority_color() for view_model in @priorities # create dependency on all colors
		view_model = _.find(@priorities, (test) -> test.priority is priority)
		return if view_model then view_model.priority_color() else ''
	@default_priority = ko.observable('medium')
	@default_priority_color = ko.computed(=> return @getColorByPriority(@default_priority()))
	@priorityToRank = (priority) -> _.indexOf(['high', 'medium', 'low'], priority)

	# List sorting
	@list_sorting_options = _.map(['label_title', 'label_created', 'label_priority'], (label) -> new ListSortingOptionViewModel(label))
	@selected_list_sorting = ko.observable('label_title')

	return