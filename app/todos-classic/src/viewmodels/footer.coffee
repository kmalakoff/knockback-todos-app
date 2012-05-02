window.FooterViewModel = (todos) ->
	@collection_observable = kb.collectionObservable(todos)

	@remaining_text = ko.computed(=> return "<strong>#{@collection_observable.collection().remainingCount()}</strong> #{if @collection_observable.collection().remainingCount() == 1 then 'item' else 'items'} left")

	@clear_text = ko.computed(=>
		count = @collection_observable.collection().completedCount()
		return if count then "Clear completed (#{count})" else ''
	)

	@onDestroyCompleted = => todos.destroyCompleted()
	@