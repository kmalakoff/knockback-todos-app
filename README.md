```
    __ __                  __   __               __       _
   / //_/____  ____  _____/ /__/ /_  ____ ______/ /__    (_)____
  / ,<  / __ \/ __ \/ ___/ //_/ __ \/ __ `/ ___/ //_/   / / ___/
 / /| |/ / / / /_/ / /__/ ,< / /_/ / /_/ / /__/ ,< _   / (__  )
/_/ |_/_/ /_/\____/\___/_/|_/_.___/\__,_/\___/_/|_(_)_/ /____/
                                                   /___/
 ___________        .___
 \__    ___/___   __| _/____  ______
   |    | /  _ \ / __ |/  _ \/  ___/
   |    |(  <_> ) /_/ (  <_> )___ \
   |____| \____/\____ |\____/____  >
                     \/          \/
```

Knockback-Todos: the obligatory todo app for Knockback.js.

You can get Knockback.js here:

* [Development version][1]
* [Production version][2]

[1]: https://github.com/kmalakoff/knockback/raw/master/knockback.js
[2]: https://github.com/kmalakoff/knockback/raw/master/knockback.min.js

You can find Knockout [here][3], Backbone.js [here][4], and Underscore.js [here][5].

[3]: https://github.com/SteveSanderson/knockout/downloads/
[4]: http://documentcloud.github.com/backbone/
[5]: http://documentcloud.github.com/underscore/


Frameworks Introduction
----------

Both Knockout and Backbone have their strengths and weaknesses, but together they are amazing! A non-exhaustive summary of the differences:

### Backbone

+ ORM: Backbone's Model and Collection provide a great, extensible [ORM][6] layer for loading, saving, and manipulating model data.
- Views/Templates: provides minimal helpers (like events bindings) to make views dynamic, but requires significant boilerplate and customization for complex dynamic logic. Views end up being a type of [controller][7] in [MVC][8] and templates often need conditional logic embedded in them.

### Knockout

+ Views/Templates: follows the [MVVM][9] pattern to more cleanly separate model, controller, and view logic. Knockout dynamically updates templates incrementally and reduces the need for embedded conditional logic.
- ORM: Knockout provides some JSON serialization functionality, but it is quite limited compared to Backbone. In addition, it view model-focussed instead of model-focussed meaning it mixes model manipulation with display logic manipulation and when you start having multiple view models per model, manual client-side synchronization is required.

### Knockback

+ ORM and Views/Templates: bridges the ORM of Backbone with the MVVM of Knockout so you can have the best of both worlds.
+ Localization: provides a convention using a locale_manager and Backbone events to easily localize your views and to change locales dynamically.


There is much more that can be compared and debated...Google if you want more!

[6]: http://en.wikipedia.org/wiki/Object-relational_mapping
[7]: http://documentcloud.github.com/backbone/#FAQ-mvc
[8]: http://en.wikipedia.org/wiki/Model_view_controller
[9]: http://en.wikipedia.org/wiki/Model_View_ViewModel


Todo App Introduction
----------

It has become common to write a Todo app to show off your Javascript MVC framework. Check [this][10] out for a central resource for various frameworks.

### Backbone

If you look at the Backbone Todo app [demo][11] and [annotated code][12], you will notice a few things:

+ the ORM solution with a local storage adapter makes persistence easy
+ the models and collections provide functionality that is used by the views
- the views require low-level jauery manipulation. It is totally manageable in a small app but can be complex to scale.

### Knockout

If you look at the Knockout Todo app [code][13], you will notice a few things:

- it is small, but skips client side persistence (ORM)

### Knockback

With the Knockback Todo project, I wanted to show more than a minimal demo to put Knockback into a good light, but demonstrate some real-world approaches to solving problems like (localization and data loading delays) and some of the additional dynamic functionality that Knockback can bring.

* **Todos Mockup**: starting with the end in mind, I took the Backbone Todo demo, replaced the Underscore.js templates with jquery-tmpl to be prepared for Knockout's bundled template engine, refactored out all strings into templates, and then mocked out the extended functionality including: localization (EN/FR/IT), priorities and corresponding colors, and list view sorting.

* **Todos Classic**: I stripped out the extended functionality from todos_mockup, and wrote the ORM in Backbone and minimally ported the Views/Templates to Knockout.

* **Todos - Knockback Complete**: the classic todo app with extensions for localization (EN/FR/IT), priorities and corresponding colors, and list view sorting. It shows off the additional power and flexibility of Knockback including lazy model loading through Backbone.ModelRef, and is a complete port to Knockout (rather than partial in todos_classic).


[10]: http://addyosmani.github.com/todomvc/
[11]: http://documentcloud.github.com/backbone/examples/todos/index.html
[12]: http://documentcloud.github.com/backbone/docs/todos.html
[13]: https://github.com/ashish01/knockoutjs-todos


Todos Mockup
----------

### Architecture

```coffeescript
```

```coffeescript
```

```html
```

Todos Classic
----------

### Backbone Integration

```coffeescript
```

### Knockout Integration

```coffeescript
```

```html
```

### Model Synchronization

```coffeescript
```

### Collection Synchronization

```coffeescript
```

Todos - Knockback Complete
----------

### List Sorting

Knockback's kb.CollectionObservable provides allow you to either use the Backbone.Collection's comparator-based sorting or to put the sorting under the control of the kb.CollectionObservable.

kb.CollectionObservable sorting API allows sorting to be specified at creation like:
```coffeescript
collection_observable = kb.collectionObservable(collection, view_models_array, {
  view_model:         TodoViewModel
  sort_attribute:     'text'
})
```

or dynamically like:
```coffeescript
collection_observable.sortAttribute('text')
collection_observable.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) -> test.get('created_at').valueOf()))
collection_observable.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) -> settings_view_model.priorityToRank(test.get('priority'))))
```

We provide a standardized option view model that can be used with the "option-template" template:
```coffeescript
SortingOptionViewModel = (string_id) ->
  @id = string_id
  @label = kb.observable(kb.locale_manager, {key: string_id})
  @option_group = 'list_sort'
  return this
```
* **id**: used in the callback to update selection
* **label**: a dynamically localized label by observing an attribute in the kb.locale_manager
* **option_group**: used by the radio button name attribute for grouping them together

We upgrade the list view model for sorting:
```coffeescript
TodoListViewModel = (todos) ->
  ...
  @sort_mode = ko.observable('label_text')  # used to create a dependency
  @sorting_options = [new SortingOptionViewModel('label_text'), new SortingOptionViewModel('label_created'), new SortingOptionViewModel('label_priority')]
  @selected_value = ko.dependentObservable(
    read: => return @sort_mode()
    write: (new_mode) =>
      @sort_mode(new_mode)
      # update the collection observable's sorting function
      switch new_mode
        when 'label_text' then ...
        when 'label_created' then ...
        when 'label_priority' then ...
    owner: this
  )
  @collection_observable = kb.collectionObservable(todos, @todos, {view_model: TodoViewModel, sort_attribute: 'text'})
  @sort_visible = ko.dependentObservable(=> @collection_observable().length)
```
* **sort_mode**: stores the current mode
* **sort_options**: provides the per option information to the template
* **selected_value**: provides the selection to the template and updates the application state when it changes
* **collection_observable**: start the sorting on the text attribute
* **sort_visible**: tells the template whether to hide/show the list sorting interface

The sorting is
```html
<div id="todo-list-sorting" class="selection codestyle" data-bind="template: {name: 'option-template', foreach: sorting_options, templateOptions: {selected_value: selected_value} }"></div>

<script type="text/x-jquery-tmpl" id="option-template">
  <div class="option"><input type="radio" data-bind="attr: {id: id, name: option_group}, value: id, checked: $item.selected_value"><label data-bind="attr: {for: id}, text: label"></label></div>
</script>
```

### Priorities

```coffeescript
```

```html
```

### Localization

```coffeescript
```

```html
```

### Lazy Loading

```coffeescript
```
