window.FooterViewModel = (todos) ->
	@collection_observable = kb.collectionObservable(todos)

	# EXTENSIONS: Localization
	@remaining_text_key = ko.computed(=> return if (todos.remainingCount() == 1) then 'remaining_template_s' else 'remaining_template_pl')
	@remaining_text = kb.observable(kb.locale_manager, {key: @remaining_text_key, args: => @collection_observable.collection().remainingCount()})

	# EXTENSIONS: Localization
	@clear_text_key = ko.computed(=> return if (@collection_observable.collection().completedCount()==0) then null else (if (todos.completedCount() == 1) then 'clear_template_s' else 'clear_template_pl'))
	@clear_text = kb.observable(kb.locale_manager, {key: @clear_text_key, args: => @collection_observable.collection().completedCount()})

	@onDestroyCompleted = => todos.destroyCompleted()

	# EXTENSIONS: Localization
	@instructions_text = kb.observable(kb.locale_manager, {key: 'instructions'})
	@