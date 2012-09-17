window.TodoViewModel = (model) ->
	#############################
	#############################
	# CLASSIC APP with some EXTENSION hooks
	#############################
	#############################

	@editing = ko.observable(false)
	@completed = kb.observable(model, {key: 'completed', read: (-> return model.completed()), write: ((completed) -> model.completed(completed)) }, @)

	@title = kb.observable(model, {
		key: 'title'
		write: ((title) =>
			if $.trim(title) then model.save(title: $.trim(title)) else _.defer(->model.destroy())
			@editing(false)
		)
	}, @)

	@onDestroyTodo = => model.destroy()

	@onCheckEditBegin = => (@editing(true); $('.todo-input').focus()) if not @editing() and not @completed()
	@onCheckEditEnd = (view_model, event) => ($('.todo-input').blur(); @editing(false)) if (event.keyCode == 13) or (event.type == 'blur')

	#############################
	#############################
	# EXTENSIONS
	#############################
	#############################

	# Created message
	@created_at = model.get('created_at')
	@completed_at = kb.observable(model, {key: 'completed', localizer: LongDateLocalizer})
	@completed_text = ko.computed(=>
		completed_at = @completed_at() # ensure there is a dependency
		return if !!completed_at then return "#{kb.locale_manager.get('label_completed')}: #{completed_at}" else ''
	)

	# Priorities
	@priority_color = kb.observable(model, {key: 'priority', read: -> return app_settings.getColorByPriority(model.get('priority'))})
	@tooltip_visible = ko.observable(false)
	tooltip_visible = @tooltip_visible # closured for onSelectPriority
	@onSelectPriority = (view_model, event) ->
		event.stopPropagation()
		tooltip_visible(false)
		model.save({priority: ko.utils.unwrapObservable(@priority)})
	@onToggleTooltip = => @tooltip_visible(!@tooltip_visible())

	# Localization
	@complete_all_text = kb.observable(kb.locale_manager, {key: 'complete_all'})

	@