ENTER_KEY = 13

window.AppViewModel = ->
	#############################
	#############################
	# CLASSIC APP with some EXTENSIONS hooks
	#############################
	#############################

	#############################
	# Shared
	#############################
	# collections
	@collections =
		todos: new TodoCollection()
	@collections.todos.fetch()

	# shared observables
	@list_filter_mode = ko.observable('')
	todos_filter_fn = ko.computed(=>
		switch @list_filter_mode()
			when 'active' then return (model) -> return model.completed()
			when 'completed' then return (model) -> return not model.completed()
			else return -> return false
	)
	@todos = kb.collectionObservable(@collections.todos, {view_model: TodoViewModel, filters: todos_filter_fn, sort_attribute: 'title'}) # EXTENSIONS: Add sorting
	@collections.todos.bind('change', => @todos.notifySubscribers(@todos())) # trigger an update whenever a model changes (default is only when added, removed, or resorted)
	@tasks_exist = ko.computed(=> !!@todos.collection().models.length)

	#############################
	# Header Section
	#############################
	@title = ko.observable('')

	@onAddTodo = (view_model, event) =>
		return true if not $.trim(@title()) or (event.keyCode != ENTER_KEY)

		# Create task and reset UI
		@collections.todos.create({title: $.trim(@title()), priority: app_settings.default_priority()}) # EXTENDED: Add priority to Todo
		@title('')

	#############################
	# Todos Section
	#############################
	@all_completed = ko.computed(
		read: => return not @todos.collection().remainingCount()
		write: (completed) => @todos.collection().completeAll(completed)
	)

	#############################
	# Footer Section
	#############################
	@remaining_text = ko.computed(=> return "<strong>#{@todos.collection().remainingCount()}</strong> #{if @todos.collection().remainingCount() == 1 then 'item' else 'items'} left")

	@onDestroyCompleted = =>
		@collections.todos.destroyCompleted()

	#############################
	# Routing
	#############################
	router = new Backbone.Router
	router.route('', null, => @list_filter_mode(''))
	router.route('active', null, => @list_filter_mode('active'))
	router.route('completed', null, => @list_filter_mode('completed'))
	Backbone.history.start()


	#############################
	#############################
	# Extensions
	#############################
	#############################

	#############################
	# Header Section
	#############################
	@input_placeholder_text = kb.observable(kb.locale_manager, {key: 'placeholder_create'})
	@input_tooltip_text = kb.observable(kb.locale_manager, {key: 'tooltip_create'})

	@priority_color = ko.computed(=> return app_settings.default_priority_color())
	@tooltip_visible = ko.observable(false)
	tooltip_visible = @tooltip_visible # closured for onSelectPriority
	@onSelectPriority = (view_model, event) =>
		event.stopPropagation()
		tooltip_visible(false)
		app_settings.default_priority(ko.utils.unwrapObservable(@priority))
	@onToggleTooltip = =>
		@tooltip_visible(!@tooltip_visible())

	#############################
	# Todos Section
	#############################
	@sort_mode = ko.computed(=>
		new_mode = app_settings.selected_list_sorting()
		switch new_mode
			when 'label_title' then @todos.sortAttribute('title')
			when 'label_created' then @todos.sortedIndex((models, model)=> return _.sortedIndex(models, model, (test) => kb.utils.wrappedModel(test).get('created_at').valueOf()))
			when 'label_priority' then @todos.sortedIndex((models, model)=> return _.sortedIndex(models, model, (test) => app_settings.priorityToRank(kb.utils.wrappedModel(test).get('priority'))))
	)

	@complete_all_text = kb.observable(kb.locale_manager, {key: 'complete_all'})

	#############################
	# Footer Section
	#############################
	@remaining_text_key = ko.computed(=>
		return if (@todos.collection().remainingCount() == 1) then 'remaining_template_s' else 'remaining_template_pl'
	)
	@remaining_text = kb.observable(kb.locale_manager, {
		key: @remaining_text_key
		args: => @todos.collection().remainingCount()
	})

	@clear_text_key = ko.computed(=>
		return if (@todos.collection().completedCount()==0) then null else (if (@todos.collection().completedCount() == 1) then 'clear_template_s' else 'clear_template_pl')
	)
	@clear_text = kb.observable(kb.locale_manager, {
		key: @clear_text_key
		args: => @todos.collection().completedCount()
	})

	# Localization
	@instructions_text = kb.observable(kb.locale_manager, {key: 'instructions'})
	@label_filter_all = kb.observable(kb.locale_manager, 'todo_filter_all')
	@label_filter_active = kb.observable(kb.locale_manager, 'todo_filter_active')
	@label_filter_completed = kb.observable(kb.locale_manager, 'todo_filter_completed')

	@