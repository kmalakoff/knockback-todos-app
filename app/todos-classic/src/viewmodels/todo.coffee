window.TodoViewModel = (model) ->
	@editing = ko.observable(false)
	@completed = kb.observable(model, {key: 'completed', read: (-> return model.completed()), write: ((completed) -> model.completed(completed)) }, @)
	@visible = ko.computed(=>
		switch app.settings.list_filter_mode()
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

	@onCheckEditBegin = =>
		if not @editing() and not @completed()
			@editing(true)
			$('.todo-input').focus()

	@onCheckEditEnd = (view_model, event) =>
		if (event.keyCode == 13) or (event.type == 'blur')
			$('.todo-input').blur()
			@editing(false)

	@