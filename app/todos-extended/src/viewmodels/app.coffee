ENTER_KEY = 13

window.AppViewModel = ->
	#############################
	#############################
	# CLASSIC APP with some EXTENSION hooks
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
	filter_fn = ko.computed =>
		switch @list_filter_mode()
			when 'active' then return (model) -> return not model.completed()
			when 'completed' then return (model) -> return model.completed()
			else return -> return true

	@todos = kb.collectionObservable(@collections.todos, {view_model: TodoViewModel, filters: filter_fn, sort_attribute: 'title'}) # EXTENSIONS: Add sorting
	@todos_changed = kb.triggeredObservable(@collections.todos, 'change add remove')
	@tasks_exist = ko.computed(=> @todos_changed(); return !!@collections.todos.length)

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
	@remaining_count = ko.computed(=> @todos_changed(); return @collections.todos.remainingCount())
	@completed_count = ko.computed(=> @todos_changed(); return @collections.todos.completedCount())
	@all_completed = ko.computed(
		read: => return not @remaining_count()
		write: (completed) => @collections.todos.completeAll(completed)
	)

	#############################
	# Footer Section
	#############################
	@remaining_message = ko.computed(=> return "<strong>#{@remaining_count()}</strong> #{if @remaining_count() == 1 then 'item' else 'items'} left")

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
	@priority_color = ko.computed(=> return app_settings.default_priority_color())
	@tooltip_visible = ko.observable(false)
	tooltip_visible = @tooltip_visible # closured for onSelectPriority
	@onSelectPriority = (view_model, event) =>
		event.stopPropagation(); tooltip_visible(false)
		app_settings.default_priority(ko.utils.unwrapObservable(view_model.priority))
	@onToggleTooltip = => @tooltip_visible(!@tooltip_visible())

	#############################
	# Todos Section
	#############################
	@sort_mode = ko.computed =>
		new_mode = app_settings.selected_list_sorting()
		switch new_mode
			when 'label_title' then @todos.sortAttribute('title')
			when 'label_created' then @todos.comparator( (model_a, model_b) ->
				return kb.utils.wrappedModel(model_a).get('created_at').valueOf() - kb.utils.wrappedModel(model_b).get('created_at').valueOf()
			)
			when 'label_priority' then @todos.comparator( (model_a, model_b) ->
				rank_a = _.indexOf(['high', 'medium', 'low'], kb.utils.wrappedModel(model_a).get('priority'))
				rank_b = _.indexOf(['high', 'medium', 'low'], kb.utils.wrappedModel(model_b).get('priority'))
				return delta if (delta = (rank_a - rank_b)) isnt 0
				return kb.utils.wrappedModel(model_a).get('created_at').valueOf() - kb.utils.wrappedModel(model_b).get('created_at').valueOf()
			)

	#############################
	# Localization
	#############################
	@remaining_message_key = ko.computed(=>return if (@remaining_count() == 1) then 'remaining_template_s' else 'remaining_template_pl')
	@clear_message_key = ko.computed(=>return if ((count = @completed_count()) is 0) then null else (if (count is 1) then 'clear_template_s' else 'clear_template_pl'))
	@loc = kb.viewModel(kb.locale_manager, {
		keys: ['complete_all', 'create_placeholder', 'create_tooltip', 'instructions', 'filter_all', 'filter_active', 'filter_completed']
		mappings:
			remaining_message: { key: @remaining_message_key, args: [@remaining_count] }
			clear_message: { key: @clear_message_key, args: [@completed_count] }
	})

	return