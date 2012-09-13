ENTER_KEY = 13

# global app settings
window.app =
  settings:
    list_filter_mode: ko.observable('')

window.TodoApp = (view_model, element) ->
  #############################
  # Shared
  #############################
  todos_collections = new TodoCollection()
  todos_collections.fetch()
  view_model.todos = kb.collectionObservable(todos_collections, {view_model: TodoViewModel})

  view_model.tasks_exist = ko.computed(-> view_model.todos().length)

  #############################
  # Header Section
  #############################
  view_model.title = ko.observable('')

  view_model.onAddTodo = (view_model, event) ->
    return true if not $.trim(view_model.title()) or (event.keyCode != ENTER_KEY)

    # Create task and reset UI
    todos_collections.create({title: $.trim(view_model.title())})
    view_model.title('')

  #############################
  # Main Section
  #############################
  view_model.all_completed = ko.computed(
    read: -> return not view_model.todos.collection().remainingCount()
    write: (completed) -> view_model.todos.collection().completeAll(completed)
  )

  #############################
  # Footer Section
  #############################
  view_model.remaining_text = ko.computed(-> return "<strong>#{view_model.todos.collection().remainingCount()}</strong> #{if view_model.todos.collection().remainingCount() == 1 then 'item' else 'items'} left")

  view_model.clear_text = ko.computed(->
    return if (count = view_model.todos.collection().completedCount()) then "Clear completed (#{count})" else ''
  )

  view_model.onDestroyCompleted = -> todos.destroyCompleted()

  #############################
  # Routing
  #############################
  router = new Backbone.Router
  router.route('', null, -> app.settings.list_filter_mode(''))
  router.route('active', null, -> app.settings.list_filter_mode('active'))
  router.route('completed', null, -> app.settings.list_filter_mode('completed'))
  Backbone.history.start()