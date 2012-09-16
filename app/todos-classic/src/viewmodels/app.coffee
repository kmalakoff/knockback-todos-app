ENTER_KEY = 13

window.AppViewModel = ->
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
	@todos = kb.collectionObservable(@collections.todos, {view_model: TodoViewModel, filters: todos_filter_fn})
	@collections.todos.bind('change', => @todos.notifySubscribers(@todos())) # trigger an update whenever a model changes (default is only when added, removed, or resorted)
	@tasks_exist = ko.computed(=> !!@todos.collection().models.length)

	#############################
	# Header Section
	#############################
	@title = ko.observable('')

	@onAddTodo = (view_model, event) =>
		return true if not $.trim(@title()) or (event.keyCode != ENTER_KEY)

		# Create task and reset UI
		@collections.todos.create({title: $.trim(@title())})
		@title('')

	#############################
	# Main Section
	#############################
	@all_completed = ko.computed(
		read: => return not @todos.collection().remainingCount()
		write: (completed) => @todos.collection().completeAll(completed)
	)

	#############################
	# Footer Section
	#############################
	@remaining_text = ko.computed(=> return "<strong>#{@todos.collection().remainingCount()}</strong> #{if @todos.collection().remainingCount() == 1 then 'item' else 'items'} left")

	@clear_text = ko.computed(=>
		return if (count = @todos.collection().completedCount()) then "Clear completed (#{count})" else ''
	)

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

	@