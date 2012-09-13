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
		_.defer(->ko.bindingHandlers.hasfocus.update(element, value_accessor))

# EXTENSIONS: Dynamic placeholder text
ko.bindingHandlers.placeholder =
	update: (element, value_accessor, all_bindings_accessor, view_model) -> $(element).attr('placeholder', ko.utils.unwrapObservable(value_accessor()))



#############################
# Main Section
#############################
view_model.sort_mode = ko.computed(->
	new_mode = app.settings.selected_list_sorting()
	switch new_mode
		when 'label_title'
			view_model.todos.sortAttribute('title')
		when 'label_created'
			view_model.todos.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) -> kb.utils.wrappedModel(test).get('created_at').valueOf()))
		when 'label_priority'
			view_model.todos.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) => app.settings.priorityToRank(kb.utils.wrappedModel(test).get('priority'))))
)

#############################
# Footer Section
#############################
view_model.remaining_text_key = ko.computed(->
	return if (app.collections.todos.remainingCount() is 1) then 'remaining_template_s' else 'remaining_template_pl'
)
view_model.remaining_text = kb.observable(kb.locale_manager, {
	key: view_model.remaining_text_key
	args: -> view_model.todos.collection().remainingCount()
})

view_model.clear_text_key = ko.computed(->
	if (view_model.todos.collection().completedCount() is 0)
		return null
	else
		return if (todos.completedCount() == 1) then 'clear_template_s' else 'clear_template_pl'
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