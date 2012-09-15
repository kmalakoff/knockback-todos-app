$(document).ready( ->
  module("Knockback Todos (Classic)")

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
  )
)