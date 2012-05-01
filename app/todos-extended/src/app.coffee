$ ->
	# EXTENSIONS: Configure localization manager
	kb.locale_manager.setLocale('en')
	kb.locale_change_observable = kb.triggeredObservable(kb.locale_manager, 'change') # use to register a localization dependency

	# Add custom handlers to Knockout.js - adapted from Knockout.js Todos app: https://github.com/ashish01/knockoutjs-todos
	ko.bindingHandlers.dblclick =
		init: (element, value_accessor) -> $(element).dblclick(ko.utils.unwrapObservable(value_accessor()))
	ko.bindingHandlers.block =
		update: (element, value_accessor) -> element.style.display = if ko.utils.unwrapObservable(value_accessor()) then 'block' else 'none'
	ko.bindingHandlers.selectAndFocus =
		init: (element, value_accessor, all_bindings_accessor) ->
			ko.bindingHandlers.hasfocus.init(element, value_accessor, all_bindings_accessor)
			ko.utils.registerEventHandler(element, 'focus', -> element.select())
		update: (element, value_accessor) ->
			ko.utils.unwrapObservable(value_accessor()) # create dependency
			_.defer(=>ko.bindingHandlers.hasfocus.update(element, value_accessor))
	ko.bindingHandlers.placeholder =
		update: (element, value_accessor, all_bindings_accessor, view_model) -> $(element).attr('placeholder', ko.utils.unwrapObservable(value_accessor()))

	# Create and bind the app viewmodels
	window.app = {viewmodels: {}}
	priorities = new PrioritiesCollection()
	app.viewmodels.settings = new SettingsViewModel([
		new Backbone.ModelRef(priorities, 'high'),
		new Backbone.ModelRef(priorities, 'medium'),
		new Backbone.ModelRef(priorities, 'low')
	], kb.locale_manager.getLocales())
	todos = new TodosCollection()
	app.viewmodels.header = new HeaderViewModel(todos)
	app.viewmodels.todos = new TodosViewModel(todos)
	app.viewmodels.footer = new FooterViewModel(todos)
	ko.applyBindings(app.viewmodels, $('#todoapp')[0])

	# Start the app routing
	new AppRouter()
	Backbone.history.start()

	# Load the todos
	todos.fetch()

	# EXTENSIONS: Load the prioties late to show the dynamic nature of Knockback with Backbone.ModelRef
	_.delay((->
		priorities.fetch(
			success: (collection) ->
				collection.create({id:'high', color:'#bf30ff'}) if not collection.get('high')
				collection.create({id:'medium', color:'#98acff'}) if not collection.get('medium')
				collection.create({id:'low', color:'#38ff6a'}) if not collection.get('low')
		)

		# set up color pickers
		$('.colorpicker').mColorPicker({imageFolder: $.fn.mColorPicker.init.imageFolder})
		$('.colorpicker').bind('colorpicked', ->
			model = priorities.get($(this).attr('id'))
			model.save({color: $(this).val()}) if model
		)
	), 1000)

	# kb.vmRelease(app.viewmodels)		# Destroy when finished with the view model
