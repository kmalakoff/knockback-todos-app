$(->
  module("Knockback Todos (Extended)")

  test("TEST DEPENDENCY MISSING", ->
    ok(!!_); ok(!!Backbone); ok(!!ko); ok(!!kb)
  )

  test("Create a todo app", ->
    new AppSettingsViewModel()
    view_model = new AppViewModel()

    ok(view_model.collections.todos, "todos collection")
    equal(view_model.list_filter_mode(), '', "filter mode default")

    ok(view_model.tasks_exist, "tasks exist observable")

    view_model.title('do something')
    equal(view_model.title(), 'do something', "title works")

    ok(view_model.all_completed, "all_completed observable")

    ok(view_model.loc.remaining_message, "remaining_message observable")

    ok(view_model.loc.clear_message, "clear_message observable")

		#############################
		# Extended
		#############################
    ok(app_settings.language_options, "language_options observable")

    ok(view_model.loc.create_placeholder, "loc.create_placeholder observable")
    ok(view_model.loc.create_tooltip, "loc.create_tooltip observable")

    ok(view_model.priority_color, "priority_color observable")
    ok(view_model.tooltip_visible, "tooltip_visible observable")

    ok(view_model.sort_mode, "sort_mode observable")
  )
)