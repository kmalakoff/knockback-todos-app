ENTER_KEY = 13

# app globals
window.app =
	settings: {}
	collections: {}

window.TodoApp = (view_model, element) ->
	#############################
	# Shared
	#############################
	# EXTENSIONS: Configure localization manager
	kb.locale_manager.setLocale('en')
	kb.locale_change_observable = kb.triggeredObservable(kb.locale_manager, 'change') # use to register a localization dependency

	# collections
	app.collections.todos = new TodoCollection()
	app.collections.todos.fetch()
	app.collections.priorities = new PriorityCollection() # EXTENSIONS: Add priorities

	# EXTENSIONS: settings
	app.settings = new SettingsViewModel([
		new Backbone.ModelRef(app.collections.priorities, 'high'),
		new Backbone.ModelRef(app.collections.priorities, 'medium'),
		new Backbone.ModelRef(app.collections.priorities, 'low')
	], kb.locale_manager.getLocales())

	# shared observables
	view_model.todos = kb.collectionObservable(app.collections.todos, {view_model: TodoViewModel, sort_attribute: 'title'}) # EXTENSIONS: Add sorting
	app.collections.todos.bind('change', -> view_model.todos.notifySubscribers(view_model.todos())) # trigger an update whenever a model changes (default is only when added, removed, or resorted)
	view_model.tasks_exist = ko.computed(-> view_model.todos().length)

	#############################
	# Header Section
	#############################
	view_model.title = ko.observable('')

	view_model.onAddTodo = (view_model, event) ->
		return true if not $.trim(view_model.title()) or (event.keyCode != ENTER_KEY)

		# Create task and reset UI
		app.collections.todos.create({title: $.trim(view_model.title()), priority: app.settings.default_priority()}) # EXTENDED: add priority
		view_model.title('')

	#############################
	# Todos Section
	#############################
	view_model.all_completed = ko.computed(
		read: -> return not view_model.todos.collection().remainingCount()
		write: (completed) -> view_model.todos.collection().completeAll(completed)
	)

	#############################
	# Footer Section
	#############################
	view_model.remaining_text = ko.computed(-> return "<strong>#{view_model.todos.collection().remainingCount()}</strong> #{if view_model.todos.collection().remainingCount() == 1 then 'item' else 'items'} left")

	view_model.onDestroyCompleted = ->
		app.collections.todos.destroyCompleted()

	#############################
	# Routing
	#############################
	router = new Backbone.Router
	router.route('', null, -> app.settings.list_filter_mode(''))
	router.route('active', null, -> app.settings.list_filter_mode('active'))
	router.route('completed', null, -> app.settings.list_filter_mode('completed'))
	Backbone.history.start()

	#############################
	#############################
	# Extensions
	#############################
	#############################

	view_model.input_placeholder_text = kb.observable(kb.locale_manager, {key: 'placeholder_create'})
	view_model.input_tooltip_text = kb.observable(kb.locale_manager, {key: 'tooltip_create'})

	view_model.priority_color = ko.computed(-> return app.settings.default_priority_color())
	view_model.tooltip_visible = ko.observable(false)
	tooltip_visible = view_model.tooltip_visible # closured for onSelectPriority
	view_model.onSelectPriority = (view_model, event) ->
		event.stopPropagation()
		tooltip_visible(false)
		app.settings.default_priority(ko.utils.unwrapObservable(view_model.priority))
	view_model.onToggleTooltip = ->
		view_model.tooltip_visible(!view_model.tooltip_visible())

	#############################
	# Todos Section
	#############################
	view_model.sort_mode = ko.computed(->
		new_mode = app.settings.selected_list_sorting()
		switch new_mode
			when 'label_title' then view_model.todos.sortAttribute('title')
			when 'label_created' then view_model.todos.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) -> kb.utils.wrappedModel(test).get('created_at').valueOf()))
			when 'label_priority' then view_model.todos.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) -> app.settings.priorityToRank(kb.utils.wrappedModel(test).get('priority'))))
	)

	# EXTENSIONS: Localization
	view_model.complete_all_text = kb.observable(kb.locale_manager, {key: 'complete_all'})

	#############################
	# Footer Section
	#############################
	view_model.remaining_text_key = ko.computed(->
		return if (view_model.todos.collection().remainingCount() == 1) then 'remaining_template_s' else 'remaining_template_pl'
	)
	view_model.remaining_text = kb.observable(kb.locale_manager, {
		key: view_model.remaining_text_key
		args: -> view_model.todos.collection().remainingCount()
	})

	view_model.clear_text_key = ko.computed(->
		return if (view_model.todos.collection().completedCount()==0) then null else (if (view_model.todos.collection().completedCount() == 1) then 'clear_template_s' else 'clear_template_pl')
	)
	view_model.clear_text = kb.observable(kb.locale_manager, {
		key: view_model.clear_text_key
		args: -> view_model.todos.collection().completedCount()
	})

	view_model.instructions_text = kb.observable(kb.locale_manager, {key: 'instructions'})

	#############################
	# Load the prioties late to show the dynamic nature of Knockback with Backbone.ModelRef
	#############################
	_.delay((->
		app.collections.priorities.fetch(
			success: (collection) ->
				collection.create({id:'high', color:'#bf30ff'}) if not collection.get('high')
				collection.create({id:'medium', color:'#98acff'}) if not collection.get('medium')
				collection.create({id:'low', color:'#38ff6a'}) if not collection.get('low')
		)

		# set up color pickers
		$('.colorpicker').mColorPicker({imageFolder: $.fn.mColorPicker.init.imageFolder})
		$('.colorpicker').bind('colorpicked', ->
			model = app.collections.priorities.get($(this).attr('id'))
			model.save({color: $(this).val()}) if model
		)
	), 1000)