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

You can get Knockback.js:

* [Development version][1]
* [Production version][2]

[1]: https://github.com/kmalakoff/knockback/raw/master/knockback.js
[2]: https://github.com/kmalakoff/knockback/raw/master/knockback.min.js

Here are the dependent libraries [Knockout.js][3], [Backbone.js][4], and [Underscore.js][5]. [Backbone.ModelRef.js][6] is optional.

[3]: http://knockoutjs.com/
[4]: http://documentcloud.github.com/backbone/
[5]: http://documentcloud.github.com/underscore/
[6]: https://github.com/kmalakoff/backbone-modelref

Frameworks Introduction
----------

Both Knockout and Backbone have their strengths and weaknesses, but together they are amazing! A non-exhaustive summary of the differences:

### Backbone

+ ORM: Backbone's Model and Collection provide a great, extensible [ORM][7] layer for loading, saving, and manipulating model data.
+ ORM: provides notifications like jQuery (bind/unbind, trigger) for model and collection changes.
- Controllers/Views/Templates: provides minimal helpers (like events bindings) to make views dynamic, but requires significant boilerplate and customization for complex dynamic logic. Views end up being a type of [controller][8] in [MVC][9] and templates often need conditional logic embedded in them.

### Knockout

+ Controllers/Views/Templates: follows the [MVVM][10] pattern to more cleanly separate model, controller, and view logic.
+ Controllers/Views/Templates: provides a mechanism to dynamically update templates incrementally.
+ Controllers/Views/Templates: reduces/eliminates the need for embedded conditional logic in your templates making a cleaner separation between presentation logic and presentation attributes.
+ Controllers/Views/Templates: simplifies jQuery logic by providing built-in or custom handlers bound in data-bind attributes.
- ORM: Knockout provides some JSON serialization functionality, but it is quite limited compared to Backbone. In addition, it view model-focussed instead of model-focussed meaning it mixes model manipulation with display logic manipulation and when you start having multiple view models per model, manual client-side synchronization is required.

### Knockback

+ ORM and Controllers/Views/Templates: bridges the ORM of Backbone with the MVVM of Knockout so you can have the best of both worlds.
+ ORM and Controllers/Views/Templates: helps separate your MVC model logic from your MVVM controller/view/template logic.
+ ORM and Controllers/Views/Templates: automates collection model synchronization with your rendering.
+ Localization: provides a convention using a locale manager and Backbone events to easily localize your views, to dynamically change locales, and to customize the presentation of your date/times, compound/dependent attributes, etc.

There is much more that can be compared and debated..."Google the Internets" if you want more!

[7]: http://en.wikipedia.org/wiki/Object-relational_mapping
[8]: http://documentcloud.github.com/backbone/#FAQ-mvc
[9]: http://en.wikipedia.org/wiki/Model_view_controller
[10]: http://en.wikipedia.org/wiki/Model_View_ViewModel


Todo App Introduction
----------

It has become common to write a Todo app to show off your Javascript MVC framework. Check [this][11] out for a central resource for various frameworks.

### Backbone

If you look at the Backbone Todo app [demo][12] and [annotated code][13], you will notice a few things:

+ the ORM solution with a local storage adapter makes persistence easy
+ there is a clean separation of logic: the models and collections provide data manipulation functionality that is used by the views
- the views require low-level jQuery manipulation. It is totally manageable in a small app but can be complex to scale up in a more complex application.

### Knockout

If you look at the Knockout Todo app [code][14], you will notice a few things:

+ it is small
- skips client side persistence (ORM)

### Knockback

With the Knockback Todo project, I wanted to show more than a minimal demo to put Knockback into a good light, but demonstrate some real-world approaches to solving problems like (localization and data loading delays) and to present some of the additional functionality that Knockback can easily bring to your application.

So I split up the Todo application into steps that reflect a real-world development process and that make the concepts more easily digestible.

* **Todos Mockup**: "beginning with the end in mind", I took the Backbone Todo demo, replaced the Underscore.js templates with jquery-tmpl (to be prepared for Knockout's bundled template engine), refactored out all strings into templates (localization shouldn't be an afterthought!), and then mocked out the extended functionality.

* **Todos - Classic**: I stripped out the extended functionality from todos_mockup, and wrote the ORM in Backbone and minimally ported the Controllers/Views/Templates to Knockout.

* **Todos - Knockback Complete**: the classic todo app with extensions for a completed date/time message, list view sorting, priorities with customizable colors, and localization (EN/FR/IT). It shows off the additional power and flexibility of Knockback including lazy model loading through Backbone.ModelRef, and is a complete port to Knockout (rather than partial in "Todos - Classic").


[11]: http://addyosmani.github.com/todomvc/
[12]: http://documentcloud.github.com/backbone/examples/todos/index.html
[13]: http://documentcloud.github.com/backbone/docs/todos.html
[14]: https://github.com/ashish01/knockoutjs-todos

Fundamentals
------------

### Backbone

A Google search will bring up many tutorials and tips including:

* [Backbone website][15]

[15]: http://documentcloud.github.com/backbone/

### Knockout

There are some great resources on Knockout:

* [Knockout website][16] - amazing interactive examples
* [Video][17] - a good overview

[16]: http://knockoutjs.com/examples/helloWorld.html
[17]: http://channel9.msdn.com/Events/MIX/MIX11/FRM08

### Todos Architecture and Best Practices

In order to keep a separation between the Models and Controllers/Views/Templates, I create a Backbone.Model to encapsulate the data and operations on the data, and a ViewModel object or light-class for the template data and controller functionality.

**Model Pattern:** combine data with data operation functionality

```coffeescript
class Todo extends Backbone.Model
  defaults: -> return {created_at: new Date()}
  ...
  done: (done) ->
    return !!@get('done_at') if arguments.length == 0
    @save({done_at: if done then new Date() else null})
```

**ViewModel Pattern 1:** use a Javascript object when properties are simple (non-dependent, non-writing observables)

```coffeescript
header_view_model =
  title: "Todos"
```

**ViewModel Pattern 2:** use a light-class when properties become dependent and writable:

```coffeescript
TodoListViewModel = (todos) ->
  @todos = ko.observableArray([])
  ...
  return this     # "return this" or else Coffeescript will return the last statement
todo_list_view_model = new TodoListViewModel(todos)
```
I prefer this light-class way to implement my view models because "this" is available within the scope of dependent observables which require a view model parameter (in this case: "this") if they are writable.

For consistency in the Todo app, I only use these patterns of view models.

Todos Mockup
------------

When approaching the mockup, I wanted to explain how the MVC/MVVM architecture related to Knockback's bridging Backbone and Knockout without getting into too many implementation details. I chose to use jquery-tmpl to make a (reasonably) static mockup of the final application using a consistent architecture that could be upgraded step by step later in the "Todos - Classic" and "Todos - Knockback Complete" applications.

Please take a look at the todos_mockup.html and todos_mockup.coffee files to study the implementation following the architecture as discussed in "Todos Architecture and Best Practices" (above).

Some highlights:

* To help with localization, all strings need to be put into templates so they can be replaced. Sometimes templates are nested so that they can be reused on a collection:

```html
<script type="text/x-jquery-tmpl" id="header-template">
  <div class="create-todo">
    <div class="title"><h1>${title}</h1></div>
    <div id="color-settings">
      {{tmpl(window.settings_view_model.priority_settings) "#priority-setting-template"}}
    </div>
  </div>
</script>

<script type="text/x-jquery-tmpl" id="priority-setting-template">
  <div class="priority-color-entry">
    <div class="priority-text">${priority_text}</div>
    <input class='priority-color-swatch colorpicker' value="${priority_color}" data-text="hidden" data-hex="true" />
  </div>
</script>
```

* Although this is only a mockup, you can manually change the locale by changing the "setLocale". Options are: 'en', 'fr-FR', and 'it-IT'

```coffeescript
  # set the language
  kb.locale_manager.setLocale('en')
```

* The code is separated into sections based on Knockback enhancements or classic using comment clocks to help you find them.

```coffeescript
###################################
# Knockback-powered enhancements - BEGIN
###################################

###################################
# Knockback-powered enhancements - END
###################################
```

Todos - Classic
---------------

### Backbone Integration

Backbone Models and Collections are very easy to pickup and start using!

There's not much to say except that we're using backbone-localstorage.js to provide client-side persistence by adding the following property to our collections:

```coffeescript
class TodoList extends Backbone.Collection
  localStorage: new Store("kb_todos") # Save all of the todo items under the `"kb_todos"` namespace.
```

### Knockout Integration

Knockout requires a little more explanation.

To render templates from Javascript, you need to pass a view model and the element:

```coffeescript
ko.applyBindings(todo_list_view_model, $('#todo-list')[0])
```

To render nested templates from the html, you need to use something like the following...

For a template with externally supplied view models (using ko.applyBindings):
```html
<div id="todo-list" data-bind="template: 'list-template'"></div>
```

For a template with data supplied from within your view models:

```html
<script type="text/x-jquery-tmpl" id="list-template">
  <ul class="todo-list" data-bind="template: {name: 'item-template', foreach: todos}"></ul>
</script>
```

**Note:** for compatibility between Knockout 1.2.1 and 1.3.0beta (template data passed down the template chain using the 1.3.0beta syntax), I've slightly modified ko.applyBindings:

```coffeescript
# ko1.2.1 compatibility with 1.3
if _.isUndefined(ko.templateSources)
  _ko_native_apply_bindings = ko.applyBindings
  ko.applyBindings = (view_model, element) ->
    view_model['$data'] = view_model
    _ko_native_apply_bindings(view_model, element)
```

```html
<div data-bind="template: {name: 'priority-swatch-picker-template', data: $data}"></div>
```

### Model Synchronization

A kb.Observable is used to observe a model attribute and update itself or notify its subscribers when it changes. It has four main patterns:

1. Just provide a key and the raw attribute is read-only
2. Provide a key and a property "write: true" and the raw attribute is read/write
3. Provide a "read: -> return ..."or "write: (value) -> ..." function to customize the set/get behavior including registering any Knockout dependencies
4. If the attribute doesn't exist, if the setToDefault function is called, or if using a Backbone.ModelRef which is not yet loaded, it returns the default value property "default: 'foo'"

Some examples:
```coffeescript
CreateTodoViewModel = ->
  ...
  @input_placeholder_text = kb.observable(kb.locale_manager, {key: 'placeholder_create'})

TodoViewModel = (model) ->
  @text = kb.observable(model, {key: 'text', write: ((text) -> model.save({text: text}))}, this)
  ...
  @done = kb.observable(model, {key: 'done_at', read: (-> return model.done()), write: ((done) -> model.done(done)) }, this)
```

* input_placeholder_text: it provides a read-only attribute from the locale_manager's 'placeholder_create' attribute
* text: it uses the default read implementation and adds saving when the text is written
* done: it is dependent on the **'done_at'** date attribute and converts it between a date and a boolean using the model done setter/getter

### Collection Synchronization

A kb.CollectionObservable has three main types of functionality:

1. Notifying ko.dependentObservables (all the Knockback Observables are these) when the collection or models in the collection are modified.
2. Optionally manages the lifecycle of view models for each model in the collection.
3. Optionally sorts (or synchronizes sorted order with the underlying collection) for all of the view models.

In this step, we only use the first two types.

In the list view model, we need to render the view models per todo so we use type 2, lifecycle management.
```coffeescript
TodoListViewModel = (todos) ->
  @todos = ko.observableArray([])
  ...
  @collection_observable = kb.collectionObservable(todos, @todos, { view_model: TodoViewModel })
```

In the stats view model (displaying remaining and allowing clearing), we need to know when the collection or its models are modified.
```coffeescript
# Stats Footer
StatsViewModel = (todos) ->
  @collection_observable = kb.collectionObservable(todos)
  @remaining_text = ko.dependentObservable(=>
    count = @collection_observable.collection().remainingCount(); return '' if not count
    ...
  )
```

* **Note:** even if we can easily access the todos directly, we use "@collection_observable.collection()" to create a dependency on the collection observable so we get notified when it changes. See the "Knockout Dependencies" section for an explanation.


Todos - Knockback Complete
--------------------------

### Completed Date/Time

By using a date localizer and a dependent observable, a custom localized message can be added to each todo.

In the view model, localize the date/time in "done_at" and in "done_text", combine the date/time string with a localized label 'label_completed'.
```coffeescript
TodoViewModel = (model) ->
  ...
  @done_at = kb.observable(model, {key: 'done_at', localizer: LongDateLocalizer})
  @done_text = ko.dependentObservable(=>
    done_at = @done_at() # ensure there is a dependency
    return if !!done_at then return "#{kb.locale_manager.get('label_completed')}: #{done_at}" else ''
  )
```
**Note:** see the "Knockout Dependencies" section for an explanation of the "# ensure there is a dependency" comment.

Add the text to the item template:
```html
<script type="text/x-jquery-tmpl" id="item-template">
  <li>
        ...
        <div class="todo-done-text" data-bind="text: done_text"></div>
        ...
  </li>
</script>
```

### List Sorting

Knockback's kb.CollectionObservable allows you to either use the Backbone.Collection's comparator-based sorting or to put the sorting under the control of the kb.CollectionObservable.

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
* for 'created_at', we convert it to a sortable integer, and for 'priority', we convert it to a sortable number.

We provide a standardized option view model that can be used with the "option-template" template:
```coffeescript
SortingOptionViewModel = (string_id) ->
  @id = string_id
  @label = kb.observable(kb.locale_manager, {key: string_id})
  @option_group = 'list_sort'
  return this
```
* **id**: used in the callback to update the selection
* **label**: a label that is dynamically localized by observing an attribute in the kb.locale_manager
* **option_group**: used by the radio button 'name' attribute for grouping them together

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

The sorting html added to the list template:
```html
<script type="text/x-jquery-tmpl" id="list-template">
    ...
    <div id="todo-list-sorting" class="selection codestyle" data-bind="template: {name: 'option-template', foreach: sorting_options, templateOptions: {selected_value: selected_value} }"></div>
    ...
</script>
```

which renders the following group of radio buttons:
```html
<script type="text/x-jquery-tmpl" id="option-template">
  <div class="option"><input type="radio" data-bind="attr: {id: id, name: option_group}, value: id, checked: $item.selected_value"><label data-bind="attr: {for: id}, text: label"></label></div>
</script>
```

### Priorities

Priority settings are stored in a non-specialized Backbone model with the id being the priority identifier and assuming the color is stored in an attribute named color, and loaded into a collection:
```coffeescript
class PrioritiesSettingList extends Backbone.Collection
  localStorage: new Store("kb_priorities") # Save all of the todo items under the `"kb_priorities"` namespace.
priorities = new PrioritiesSettingList()
```

To display the localized name of the priority and to render its color, the model is mapped onto a view model as follows:
```coffeescript
PrioritySettingsViewModel = (model) ->
  @priority = model.get('id')
  @priority_text = kb.observable(kb.locale_manager, {key: @priority})
  @priority_color = kb.observable(model, {key: 'color'})
  return this
```

The tricky part is to set up the dependencies (see below section "Knockout Dependencies") for the settings display, the tooltip, and the model priority swatch. To do this, I wrote a small helper method "createColorsDependency" to manually create dependencies on all of the view model properties (which are themselves dependent on the model's 'color' attribute through the PrioritySettingsViewModel):
```coffeescript
SettingsViewModel = (priority_settings) ->
  @priority_settings = ko.observableArray(_.map(priority_settings, (model)-> return new PrioritySettingsViewModel(model)))
  @getColorByPriority = (priority) ->
    @createColorsDependency()
    (return view_model.priority_color() if view_model.priority == priority) for view_model in @priority_settings()
    return ''
  @createColorsDependency = => view_model.priority_color() for view_model in @priority_settings()
```

The priority color settings are rendered as follows:
```html
<script type="text/x-jquery-tmpl" id="header-template">
    ...
    <div id="color-settings" data-bind="template: {name: 'priority-setting-template', foreach: window.settings_view_model.priority_settings}"></div>
    ...
</script>
```
using this template:
```html
<script type="text/x-jquery-tmpl" id="priority-setting-template">
  <div class="priority-color-entry">
    <div class="priority-text" data-bind="text: priority_text"></div>
    <input data-bind="attr: {id: priority}, value: priority_color" class='priority-color-swatch colorpicker' data-text="hidden" data-hex="true"/>
  </div>
</script>
```

The tooltipped-priority is rendered in the create section template like:
<script type="text/x-jquery-tmpl" id="create-template">
  <div class="content">
      ...
      <div data-bind="template: {name: 'priority-swatch-picker-template', data: $data}"></div>
      ...
  </div>
</script>

The tooltipped-priority is rendered in the todo template like:
```html
<script type="text/x-jquery-tmpl" id="item-template">
  <li>
        ...
        <div data-bind="template: {name: 'priority-swatch-picker-template', data: $data}"></div>
        ...
  </li>
</script>
```...

using this template for the color swatch:
```html
<script type="text/x-jquery-tmpl" id="priority-swatch-picker-template">
  <div class="priority-color-swatch todo create" data-bind="style: {background: priority_color}, click: onToggleTooltip">
    <span class="priority-picker-tooltip ui-tooltip-top" data-bind="visible: tooltip_visible">
      <div data-bind="template: {name: 'priority-picker-template', foreach: window.settings_view_model.priority_settings, templateOptions: {onSelectPriority: onSelectPriority} }"></div>
    </span>
  </div>
</script>
```
and this template for each available color in the tool tip:
```html
<script type="text/x-jquery-tmpl" id="priority-picker-template">
  <div class="priority-color-entry">
    <div class="priority-text" data-bind="text: priority_text"></div>
    <div class='priority-color-swatch' data-bind="style: {background: priority_color}, click: function(){$item.onSelectPriority(priority)}"></div>
  </div>
</script>
```

Finally, for the sorting, I wrote a small helper to turn the priority identifier into a number that could be used by Underscore's sortedIndex:
```coffeescript
SettingsViewModel = (priority_settings) ->
  ...
  @priorityToRank = (priority) ->
    switch priority
      when 'high' then return 0
      when 'medium' then return 1
      when 'low' then return 2
  return this
```

**Note:** I made the "priorityToRank" helper part of the settings view model rather than the priority model itself because it is view-related, not data related (as I mentioned in the "Frameworks Introduction" for Knockout, Knockout does not make this important distinction and would serialize the view ranking into JSON sent to the server despite it being a view-only value).

### Localization

Localization is key for the global applications we create today. It should not be an afterthought! (although it is optional functionality in Knockback ;-) )

Knockback does not provide a locale manager (although there is a sample with this todos application in: todos_locale_manager.coffee) because different applications will retrieve their localized strings in different ways, but expects a familiar LocaleManager signature:

1. Emulate a simplified Backbone.Model through a get method like "get: (string_id) -> ..."
2. Trigger Backbone.Events 'change' and 'change:#{string_id}' like:

```coffeescript
@trigger('change', this)
@trigger("change:#{key}", value) for key, value of @translations_by_locale[@locale_identifier]
```

Register your custom locale manager like:
```coffeescript
kb.locale_manager = new MyLocaleManager()
```

Also, if you want to perform some specialized formatting above and beyond a string lookup, you can provide custom localizer classes derived from kb.LocalizedObservable:
```coffeescript
class LongDateLocalizer extends kb.LocalizedObservable
  constructor: -> return super
  read: (value) ->
    return Globalize.format(value, Globalize.cultures[kb.locale_manager.getLocale()].calendars.standard.patterns.f, kb.locale_manager.getLocale())
  write: (localized_string, value, observable) ->
    new_value = Globalize.parseDate(localized_string, Globalize.cultures[kb.locale_manager.getLocale()].calendars.standard.patterns.d, kb.locale_manager.getLocale())
    value.setTime(new_value.valueOf())
```
**Note:** kb.LocalizedObservable's constructor actually returns a dependent observable (not the instance itself) so you either need to return super result or if you have custom initialization, return the underlying observable using the following helper: "kb.wrappedObservable(this)"

As for the "Todos - Knockout Complete" demo...

You can simply watch an attribute on the locale manager as follows:
```coffeescript
CreateTodoViewModel = ->
  ...
  @input_placeholder_text = kb.observable(kb.locale_manager, {key: 'placeholder_create'})
```

Or model attributes can be localized automatically when your locale manager triggers a change:
```coffeescript
TodoViewModel = (model) ->
  ...
  @done_at = kb.observable(model, {key: 'done_at', localizer: LongDateLocalizer})
```

### Lazy Loading

By using Knockback with [Backbone.ModelRef][18], you can start rendering your views before the models are loaded.

As demonstration, you can see that the colors arrive a little after the rendering. It is achieved by passing model references instead of models to the settings view model:
```coffeescript
SettingsViewModel = (priority_settings) ->
  @priority_settings = ko.observableArray(_.map(priority_settings, (model)-> return new PrioritySettingsViewModel(model)))
  ...
window.settings_view_model = new SettingsViewModel([
  new Backbone.ModelRef(priorities, 'high'),
  new Backbone.ModelRef(priorities, 'medium'),
  new Backbone.ModelRef(priorities, 'low')
])
```

and then lazy fetching them (which creates them if they don't exist):
```coffeescript
# Load the prioties late to show the dynamic nature of Knockback with Backbone.ModelRef
_.delay((->
  priorities.fetch(
    success: (collection) ->
      collection.create({id:'high', color:'#c00020'}) if not collection.get('high')
      collection.create({id:'medium', color:'#c08040'}) if not collection.get('medium')
      collection.create({id:'low', color:'#00ff60'}) if not collection.get('low')
  )
  ...
), 1000)
```

[18]: https://github.com/kmalakoff/backbone-modelref

Tips and Gotchas
----------------

### Lifecycle Management

Because this application doesn't have a good exit point, I have not demonstrated cleanup.

Typically, I have a light "View" class that gets created and destroyed either by a routing mechanism for root views or by an owning view for subviews:

```coffeescript
class MvView
  constructor: ->
    @view_model =
      foo: 'bar'

    ko.applyBindings(@view_model, $('#my_view')[0])

  destroy: ->
    kb.vmDestroy(@view_model)
```

**Note:** you are seeing correctly. With Knockback, you no longer need to use Backbone.Views!

### Knockout Dependencies

The big gotcha with Knockout is its implicit dependencies for ko.dependentObservables. Sometimes you need to include an unnecessary call to a dependent observable within you read function just to register dependencies.

In this case, the displayed text "remaining_text" needs to be updated with the locale_changes, but because the string id is dynamic and it inserts the count number, a manual locale dependency is used.
```coffeescript
StatsViewModel = (todos) ->
  kb.locale_change_observable = kb.triggeredObservable(kb.locale_manager, 'change') # use to register a localization dependency
  ...
  @remaining_text = ko.dependentObservable(=>
    kb.locale_change_observable() # use to register a localization dependency
    count = @collection_observable.collection().remainingCount(); return '' if not count
    return kb.locale_manager.get((if count == 1 then 'remaining_template_s' else 'remaining_template_pl'), count)
  )
```

In this case, "done_at" changes when the the "done_at" attribute changes or locale changes (through LongDateLocalizer). So "done_text" will be relocalized correctly.
```coffeescript
TodoViewModel = (model) ->
  ...
  @done_at = kb.observable(model, {key: 'done_at', localizer: LongDateLocalizer})
  @done_text = ko.dependentObservable(=>
    done_at = @done_at() # ensure there is a dependency
    return if !!done_at then return "#{kb.locale_manager.get('label_completed')}: #{done_at}" else ''
  )
```

**Note:** Knockback's observables are all ko.dependentObservables behind-the-scenes so the same rules apply to them as for any ko.dependentObservable

### Template Syntax

This is really small, but I've encountered it a few times. You have to be careful with curly braces inside your templates.

"} }" is right:
```html
<div id="todo-list-sorting" class="selection codestyle" data-bind="template: {name: 'option-template', foreach: sorting_options, templateOptions: {selected_value: selected_value} }"></div>
```

"}}" is wrong (the "}}" is interpreted as template control flow by jquery-tmpl)
```html
<div id="todo-list-sorting" class="selection codestyle" data-bind="template: {name: 'option-template', foreach: sorting_options, templateOptions: {selected_value: selected_value}}"></div>
```
