TodoViewModel = (model) ->
	# Task UI state
	@editing = ko.observable(false)
	@completed = kb.observable(model, {key: 'completed', read: (-> return model.completed()), write: ((completed) -> model.completed(completed)) }, @)
	@visible = ko.computed(=>
		switch app.viewmodels.settings.list_filter_mode()
			when 'active' then return not @completed()
			when 'completed' then return @completed()
			else return true
	)

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

	# EXTENSIONS: Created message
	@created_at = model.get('created_at')
	@completed_at = kb.observable(model, {key: 'completed', localizer: LongDateLocalizer})
	@completed_text = ko.computed(=>
		completed_at = @completed_at() # ensure there is a dependency
		return if !!completed_at then return "#{kb.locale_manager.get('label_completed')}: #{completed_at}" else ''
	)

	# EXTENSIONS: Priorities
	@priority_color = kb.observable(model, {key: 'priority', read: -> return app.viewmodels.settings.getColorByPriority(model.get('priority'))})
	@tooltip_visible = ko.observable(false)
	tooltip_visible = @tooltip_visible # closured for onSelectPriority
	@onSelectPriority = (view_model, event) ->
		event.stopPropagation()
		tooltip_visible(false)
		model.save({priority: ko.utils.unwrapObservable(@priority)})
	@onToggleTooltip = => @tooltip_visible(!@tooltip_visible())
	@

window.TodosViewModel = (todos) ->
	@todos = kb.collectionObservable(todos, {view_model: TodoViewModel, sort_attribute: 'title'})

	@sort_mode = ko.computed(=>
		new_mode = app.viewmodels.settings.selected_list_sorting()
		switch new_mode
			when 'label_title' then @todos.sortAttribute('title')
			when 'label_created' then @todos.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) -> kb.utils.wrappedModel(test).get('created_at').valueOf()))
			when 'label_priority' then @todos.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) => app.viewmodels.settings.priorityToRank(kb.utils.wrappedModel(test).get('priority'))))
	)

	@tasks_exist = ko.computed(=> @todos().length)

	@all_completed = ko.computed(
		read: => return not @todos.collection().remainingCount()
		write: (completed) => @todos.collection().completeAll(completed)
	)

	# EXTENSIONS: Localization
	@completed_all_text = kb.observable(kb.locale_manager, {key: 'completed_all'})
	@