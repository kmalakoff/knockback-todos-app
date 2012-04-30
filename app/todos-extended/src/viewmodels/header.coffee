window.HeaderViewModel = (todos) ->
	@title = ko.observable('')

	@onAddTodo = (view_model, event) =>
		return true if not $.trim(@title()) or (event.keyCode != 13)

		# Create task and reset UI
		todos.create({title: $.trim(@title()), priority: app_settings_view_model.default_priority()})
		@title('')

	# EXTENSIONS: Localization
	@input_placeholder_text = kb.observable(kb.locale_manager, {key: 'placeholder_create'})
	@input_tooltip_text = kb.observable(kb.locale_manager, {key: 'tooltip_create'})

	# EXTENSIONS: Priorities
	@priority_color = ko.computed(-> return app_settings_view_model.default_priority_color())
	@tooltip_visible = ko.observable(false)
	tooltip_visible = @tooltip_visible # closured for onSelectPriority
	@onSelectPriority = (view_model, event) ->
		event.stopPropagation()
		tooltip_visible(false)
		app_settings_view_model.default_priority(ko.utils.unwrapObservable(@priority))
	@onToggleTooltip = => @tooltip_visible(!@tooltip_visible())
	@