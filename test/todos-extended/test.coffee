$(document).ready( ->
  module("Knockback Todos (Extended)")

  test("TEST DEPENDENCY MISSING", ->
    ok(!!_); ok(!!Backbone); ok(!!ko); ok(!!kb)
  )

  test("Create a todo app", ->
    view_model = new TodoApp()

    ok(app.collections.todos, "todos collection")
    equal(app.settings.list_filter_mode(), '', "filter mode default")

    ok(view_model.tasks_exist, "tasks exist observable")

    view_model.title('do something')
    equal(view_model.title(), 'do something', "title works")

    ok(view_model.all_completed, "all_completed observable")

    ok(view_model.remaining_text, "remaining_text observable")

    ok(view_model.clear_text, "clear_text observable")

		#############################
		# Extended
		#############################
    ok(app.settings.language_options, "language_options observable")

    ok(view_model.input_placeholder_text, "input_placeholder_text observable")
    ok(view_model.input_tooltip_text, "input_tooltip_text observable")

    ok(view_model.priority_color, "priority_color observable")
    ok(view_model.tooltip_visible, "tooltip_visible observable")

    ok(view_model.sort_mode, "sort_mode observable")
  )
)