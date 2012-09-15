ENTER_KEY = 13

window.TodoApp = ->
	window.app = @ # publish so settings are available globally

	#############################
	# Shared
	#############################
	# collections
	@collections =
		todos: new TodoCollection()
		priorities: new PriorityCollection() # EXTENSIONS: Add priorities
	@collections.todos.fetch()

	# EXTENSIONS: settings
	@settings = new SettingsViewModel([
		new Backbone.ModelRef(@collections.priorities, 'high'),
		new Backbone.ModelRef(@collections.priorities, 'medium'),
		new Backbone.ModelRef(@collections.priorities, 'low')
	], kb.locale_manager.getLocales())

	# shared observables
	@todos = kb.collectionObservable(@collections.todos, {view_model: TodoViewModel, sort_attribute: 'title'}) # EXTENSIONS: Add sorting
	@collections.todos.bind('change', => @todos.notifySubscribers(@todos())) # trigger an update whenever a model changes (default is only when added, removed, or resorted)
	@tasks_exist = ko.computed(=> @todos().length)

	#############################
	# Header Section
	#############################
	@title = ko.observable('')

	@onAddTodo = (view_model, event) =>
		return true if not $.trim(@title()) or (event.keyCode != ENTER_KEY)

		# Create task and reset UI
		@collections.todos.create({title: $.trim(@title()), priority: @settings.default_priority()}) # EXTENDED: Add priority to Todo
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
	router.route('', null, => @settings.list_filter_mode(''))
	router.route('active', null, => @settings.list_filter_mode('active'))
	router.route('completed', null, => @settings.list_filter_mode('completed'))
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

	@priority_color = ko.computed(=> return @settings.default_priority_color())
	@tooltip_visible = ko.observable(false)
	tooltip_visible = @tooltip_visible # closured for onSelectPriority
	@onSelectPriority = (view_model, event) =>
		event.stopPropagation()
		tooltip_visible(false)
		@settings.default_priority(ko.utils.unwrapObservable(@priority))
	@onToggleTooltip = =>
		@tooltip_visible(!@tooltip_visible())

	#############################
	# Todos Section
	#############################
	@sort_mode = ko.computed(=>
		new_mode = @settings.selected_list_sorting()
		switch new_mode
			when 'label_title' then @todos.sortAttribute('title')
			when 'label_created' then @todos.sortedIndex((models, model)=> return _.sortedIndex(models, model, (test) => kb.utils.wrappedModel(test).get('created_at').valueOf()))
			when 'label_priority' then @todos.sortedIndex((models, model)=> return _.sortedIndex(models, model, (test) => @settings.priorityToRank(kb.utils.wrappedModel(test).get('priority'))))
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

	@instructions_text = kb.observable(kb.locale_manager, {key: 'instructions'})

	#############################
	# Load the prioties late to show the dynamic nature of Knockback with Backbone.ModelRef
	#############################
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

	return # coffeescript will return last statement, but we need 'this'