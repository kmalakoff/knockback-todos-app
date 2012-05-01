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

### Try the live demo: http://kmalakoff.github.com/knockback-todos/
### Or checkout the website: http://kmalakoff.github.com/knockback/

You can get Knockback.js:

* [Development version][1]
* [Production version][2]

Here are the dependent libraries [Knockout.js][3], [Backbone.js][4], [Underscore.js][5], and [Backbone.ModelRef.js (optional)][6].

[1]: https://github.com/kmalakoff/knockback/raw/master/knockback.js
[2]: https://github.com/kmalakoff/knockback/raw/master/knockback.min.js
[3]: http://knockoutjs.com/
[4]: http://documentcloud.github.com/backbone/
[5]: http://documentcloud.github.com/underscore/
[6]: https://github.com/kmalakoff/backbone-modelref

Frameworks Introduction
----------

Backbone is an MVC-like framework and Knockout is MVVM. For a little theoretical background:

1. [MVC][http://en.wikipedia.org/wiki/Model_view_controller] and [Backbone's take on MVC][http://documentcloud.github.com/backbone/#FAQ-mvc]
2. [MVVM][http://en.wikipedia.org/wiki/Model_View_ViewModel]
3. [ORM][http://en.wikipedia.org/wiki/Object-relational_mapping] as related to Backbone models and collections

Some resources on Backbone:

* [Backbone website][15]

Some resources on Knockout:

* [Knockout website][16] - amazing interactive examples
* [Video][17] - a good overview

Both Knockout and Backbone have their strengths and weaknesses, but together they are amazing!

Please take a look at the [Knockout website][7] for an analysis of each framework and how by bridging the two framework, Knockout addresses their weaknesses and adds some powerful new features.

There is much more that can be compared and debated..."Google the Internets" if you want more!


Todo App Introduction
----------

It has become common to write a Todo app to show off your Javascript MVC framework. Check [this][11] out for a central resource for various frameworks.

### Backbone

If you look at the Backbone Todo app [demo][12] and [annotated code][13], you will notice a few things:

* the ORM solution with a local storage adapter makes persistence easy
* there is a clean separation of logic: the models and collections provide data manipulation functionality that is used by the views
* the views require low-level jQuery manipulation. It is manageable in a small app but can be complex to scale up and maintain in a more complex application.

### Knockout

If you look at the Knockout Todo app [code][14], you will notice a few things:

* it is small
* skips client side persistence (ORM)

### Knockback

With the Knockback Todo project, I wanted to show more than a minimal demo to put Knockback into a good light, but demonstrate some real-world approaches to solving problems like (localization and data loading delays) and to present some of the additional functionality that Knockback can easily bring to your application.

So I split up the Todo application into steps that reflect a real-world development process and that make the concepts more easily digestible.

* **Todos - Classic**: the classic Todo app following the [TodoMVC][11] guidelines.

* **Todos - Knockback Complete**: the classic todo app with extensions for a completed date/time message, list view sorting, priorities with customizable colors, and localization (EN/FR/IT). It shows off the additional power and flexibility of Knockback including lazy model loading through Backbone.ModelRef.


[7]: http://kmalakoff.github.com/knockback/
[11]: http://addyosmani.github.com/todomvc/
[12]: http://documentcloud.github.com/backbone/examples/todos/index.html
[13]: http://documentcloud.github.com/backbone/docs/todos.html
[14]: https://github.com/ashish01/knockoutjs-todos
[15]: http://documentcloud.github.com/backbone/
[16]: http://knockoutjs.com/examples/helloWorld.html
[17]: http://channel9.msdn.com/Events/MIX/MIX11/FRM08


Todos Architecture
------------

With the MVVM pattern, instead of Model, View, Controller you use Model, View, ViewModel. As an simple approximation using MVC terminology:

* Models are handled by Backbone.Models and Backbone.Collections
* Views are handled by Templates
* ViewModels take the place of Controllers

# MVVM in "Todos - Classic"

The Classic application is an upgraded port of the Backbone Todos application so it has the same ORM with Todo (Backbone.Model) and TodosCollection (Backbone.Collection), but the two views are replaced by various ViewModels and templates for each section of the screen (SettingsViewModel, HeaderViewModel, TodosViewModel, FooterViewModel).

**Models (Backbone.Model + Backbone.Collection)**

* **Todo:** provides the data and operations for a Todo like setting its complete state and saving changes on the server/local-storage
* **TodosCollection:** fetches models from the server and provides summary information on the Todo data like how many are completed, remaining, etc

**ViewModels**

* **SettingsViewModel:** provides properties to select the active filtering for Todos
* **HeaderViewModel:** provides properties to configure the new todo input element (placeholder text, etc) and provides a hook to the input element in the template so the ViewModel can create a new Todo Model when Enter is pressed
* **TodosViewModel:** provides all of the ViewModels to render each Todo
* **FooterViewModel:** provides and updates the summary stats attributes including localized text whenever the Todo list or one of its Todo models changes

# MVVM in "Todos - Extended"
This application extends the "Todos - Classic" by adding settings including todo priorities (display colors and orders), language selection and localized text, adding todos sorting options (by name, created date, and priority).

**Models (Backbone.Model + Backbone.Collection)**

* **Priority:** provides the data for the priority and color information that is saved on the server/local-storage. It could be a generic Backbone.Model but for clarity and consistency with the mock up, it is given a class.
* **PrioritiesCollection:** a very basic collection for fetching all of the priority settings

**ViewModels**

* **PrioritiesViewModel:** provides localized text (that shouldn't be saved to the server) and color properties to the 'priority-setting-template' template
* **SettingsViewModel:** provides the priority settings globally to the application, the current default priority and color for new tasks, a priority ranking to the TodosViewModel for sorting, the selected and available locales from the locale manager ('en', 'fr-FR', 'it-IT') into display strings ('EN', 'FR', 'IT'), todos sorting radio buttons.
* **HeaderViewModel:** upgraded to expose properties for rendering the current default Todo priority and a hook to show/hide the tooltip for selecting the default priority
* **TodoViewModel:** upgraded to expose properties for rendering its Todo priority and a hook to show/hide the tooltip for selecting the Todo priority

# Relationships between Models and ViewModels - Often One-To-Many

In the Todos applications, there is a one-to-one relationship between Models and ViewModels, but the distinction is important:

* Backbone.Models encapsulate the data and operations on the data, are serialized/deserialized from/to the server, and are in short Models.
* ViewModels provide the attributes and logic to the templates often interacting with the Model data like Controllers. However, they may have their own data and logic that is purely View-related and that the server should never know about.

Besides providing a clean separation between data and display, this separation becomes important in a larger application. In a larger application, you often have different ways to present the same Model with different ViewModels. For example, a Model could have the following ViewModels:

1. Thumbnail View - the ViewModel could only expose a subset of the Model's attributes, dates/time may be in the shortest format possible, or maybe just an image would be provided to the template.
2. Cell View - the ViewModel could again expose a subset of only the most relevant summary attributes, routing information to a detailed summary view, etc.
3. Editing View - the ViewModel could expose almost all of the Model's attributes, localized labels for each, data and functions for the editing controls and functionality, routing information to specialized editing views, etc.

Important to understand that in a larger application the relationship between Models and ViewModels tends to be one-to-many. In this application, there is a one-to-many relationship from the Priority model through the the HeaderViewModel and TodoViewModel ViewModels because each one uses the Priority for rendering their priority colors and providing priority settings data to their tooltip, but the actions on selecting a priority in the tool tip differ.

The HeaderViewModel sets the default priority for new Todos when you select the priority:

```coffeescript
HeaderViewModel = ->
  @onSelectPriority = (view_model, event) ->
    app.viewmodels.settings.default_priority(ko.utils.unwrapObservable(@priority))
```
The TodoViewModel sets the priority for its Todos Model when you select the priority:

```coffeescript
TodoViewModel = (model) ->
  @onSelectPriority = (view_model, event) ->
    model.save({priority: ko.utils.unwrapObservable(@priority)})
```

# Relationships between ViewModels and Views/Templates

You can see in the Todos application that there is a many-to-one relationship between the LanguagesViewModel and TodosViewModel with the 'option-template' View. Each ViewModel provides a similar signature of option items view data to the template, but the options ViewModels are different: SettingLanguageOptionViewModel and SettingListSortingOptionViewModel, respectively.

The language options are mapped from the available locales in the locale manager through a SettingLanguageOptionViewModel:

```coffeescript
LanguagesViewModel = (locales) ->
  @current_language = ko.observable(kb.locale_manager.getLocale())
  @language_options = ko.observableArray(_.map(locales, (locale) -> return new SettingLanguageOptionViewModel(locale)))
  @selected_value = ko.computed(...)
```

The sort options are hard coded but identifier and exposed through a SettingListSortingOptionViewModel:

```coffeescript
TodosViewModel = (todos) ->
  @sort_mode = ko.observable('label_text')
  @list_sorting_options = [new SettingListSortingOptionViewModel('label_text'), new SettingListSortingOptionViewModel('label_created'), new SettingListSortingOptionViewModel('label_priority')]
  @selected_value = ko.computed(...)
```

Finally, each option is rendered through a 'foreach' in a parent template using an 'option-template' template:

Language options:

```html
<div id="todo-languages" class="selection codestyle" data-bind="template: {name: 'option-template', foreach: language_options, templateOptions: {selected_value: selected_value} }"></div>
```

Sorting options:

```html
<div id="todo-list-sorting" class="selection codestyle" data-bind="template: {name: 'option-template', foreach: list_sorting_options, templateOptions: {selected_value: selected_value} }"></div>
```
The template per option:

```html
<script type="text/x-jquery-tmpl" id="option-template">
  <div class="option"><input type="radio" data-bind="attr: {id: id, name: option_group}, value: id, checked: $item.selected_value"><label data-bind="attr: {for: id}, text: label"></label></div>
</script>
```
Often the relationships between ViewModels and templates are one-to-one, but in this case to reuse the template per option, they are many-to-one.

### Todos Implementation

**Model Pattern:** combine data with data operation functionality

```coffeescript
class Todo extends Backbone.Model
  defaults: -> return {created_at: new Date()}
  ...
  complete: (complete) ->
    return !!@get('completed') if arguments.length == 0
    @save({completed: if completed then new Date() else null})
```

**ViewModel Pattern:** use a light-class when properties become dependent and writable:

```coffeescript
TodosViewModel = (todos) ->
  @todos = ko.observableArray([])
  ...
  @           # must return this or Coffeescript will return the last statement which is not what we want!
todos_view_model = new TodosViewModel(todos)
```
I prefer this light-class way to implement my view models because "this" is available within the scope of dependent observables which require a view model parameter (in this case: "this") if they are writable. For consistency in the Todo app, I only use these patterns of view models, but simple object work great for simple scenarios.

Todos Mockup
------------

When approaching the mockup, I wanted to explain how the MVC/MVVM architecture related to Knockback's bridging Backbone and Knockout without getting into too many implementation details. I chose to use jquery-tmpl to make a (reasonably) static mockup of the final application using a consistent architecture that could be upgraded step by step later in the "Todos - Classic" and "Todos - Knockback Complete" applications.

Please take a look at the todos_mockup.html and todos_mockup.coffee files to study the implementation following the architecture as discussed in "Todos Architecture and Best Practices" (above).

Some highlights:

* To help with localization, all strings need to be put into templates so they can be replaced. Sometimes templates are nested so that they can be reused on a collection:

```html
<div class="create-todo">
  <div class="title"><h1>${title}</h1></div>
  <div id="priority-color-settings">
    {{tmpl(window.app.viewmodels.settings.priorities) "#priority-setting-template"}}
  </div>
</div>

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
# EXTENSIONS:
```

Todos - Classic
---------------

### Backbone Integration

Backbone Models and Collections are very easy to pickup and start using!

There's not much to say except that we're using backbone-localstorage.js to provide client-side persistence by adding the following property to our collections:

```coffeescript
class TodosCollection extends Backbone.Collection
  localStorage: new Store('todos-knockback') # Save all of the todos under the `todos-knockback` namespace.
```

### Knockout Integration

Knockout requires a little more explanation.

To render templates from Javascript, you need to pass a view model and the element:

```coffeescript
ko.applyBindings(app.viewmodels, $('#todoapp')[0])
```
```

### Model Synchronization

A kb.Observable is used to observe a model attribute and update itself or notify its subscribers when it changes. It has four main patterns:

1. Just provide a key and the raw attribute is read-only
2. Provide a key and a property "write: true" and the raw attribute is read/write
3. Provide a "read: -> return ..."or "write: (value) -> ..." function to customize the set/get behavior including registering any Knockout dependencies
4. If the attribute doesn't exist, if the setToDefault function is called, or if using a Backbone.ModelRef which is not yet loaded, it returns the default value property "default: 'foo'"

Some examples:

```coffeescript
HeaderViewModel = ->
  ...
  @input_placeholder_text = kb.observable(kb.locale_manager, {key: 'placeholder_create'})

TodoViewModel = (model) ->
  @text = kb.observable(model, {key: 'text', write: ((text) -> model.save({text: text}))}, @)
  ...
  @completed = kb.observable(model, {key: 'completed', read: (-> return model.completed()), write: ((completed) -> model.completed(completed)) }, @)
```

* input_placeholder_text: it provides a read-only attribute from the locale_manager's 'placeholder_create' attribute
* text: it uses the default read implementation and adds saving when the text is written
* completed: it is dependent on the **'completed'** date attribute and converts it between a date and a boolean using the model completed setter/getter

### Collection Synchronization

A kb.CollectionObservable has three main types of functionality:

1. Notifying ko.computeds (all the Knockback Observables are these) when the collection or models in the collection are modified.
2. Optionally manages the lifecycle of view models for each model in the collection.
3. Optionally sorts (or synchronizes sorted order with the underlying collection) for all of the view models.

In this step, we only use the first two types.

In the list view model, we need to render the view models per todo so we use type 2, lifecycle management.

```coffeescript
TodosViewModel = (todos) ->
  @todos = ko.observableArray([])
  ...
  @collection_observable = kb.collectionObservable(todos, @todos, { view_model: TodoViewModel })
```

In the stats view model (displaying remaining and allowing clearing), we need to know when the collection or its models are modified.

```coffeescript
# Stats Footer
FooterViewModel = (todos) ->
  @collection_observable = kb.collectionObservable(todos)
  @remaining_text = ko.computed(=>
    count = @collection_observable.collection().remainingCount(); return '' if not count
    ...
  )
```

**Note:** even if we can easily access the todos directly, we use "@collection_observable.collection()" to create a dependency on the collection observable so we get notified when it changes. See the "Knockout Dependencies" section for an explanation.

Todos - Knockback Complete
--------------------------

### Completed Date/Time

By using a date localizer and a dependent observable, a custom localized message can be added to each todo.

In the view model, localize the date/time in "completed" and in "completed_text", combine the date/time string with a localized label 'label_completed'.

```coffeescript
TodoViewModel = (model) ->
  ...
  @completed = kb.observable(model, {key: 'completed', localizer: LongDateLocalizer})
  @completed_text = ko.computed(=>
    completed = @completed() # ensure there is a dependency
    return if !!completed then return "#{kb.locale_manager.get('label_completed')}: #{completed}" else ''
  )
```
**Note:** see the "Knockout Dependencies" section for an explanation of the "# ensure there is a dependency" comment.

Add the text to the item template:

```html
<script type="text/x-jquery-tmpl" id="item-template">
  <li>
        ...
        <div class="todo-completed-text" data-bind="text: completed_text"></div>
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
collection_observable.sortedIndex((models, model)-> return _.sortedIndex(models, model, (test) -> app.viewmodels.settings.priorityToRank(test.get('priority'))))
```

* for 'created_at', we convert it to a sortable integer, and for 'priority', we convert it to a sortable number.

We provide a standardized option view model that can be used with the "option-template" template:

```coffeescript
SettingListSortingOptionViewModel = (string_id) ->
  @id = string_id
  @label = kb.observable(kb.locale_manager, {key: string_id})
  @option_group = 'list_sort'
  @           # must return this or Coffeescript will return the last statement which is not what we want!
```

* **id**: used in the callback to update the selection
* **label**: a label that is dynamically localized by observing an attribute in the kb.locale_manager
* **option_group**: used by the radio button 'name' attribute for grouping them together

We upgrade the list view model for sorting:

```coffeescript
TodosViewModel = (todos) ->
  ...
  @sort_mode = ko.observable('label_text')  # used to create a dependency
  @list_sorting_options = [new SettingListSortingOptionViewModel('label_text'), new SettingListSortingOptionViewModel('label_created'), new SettingListSortingOptionViewModel('label_priority')]
  @selected_value = ko.computed(
    read: => return @sort_mode()
    write: (new_mode) =>
      @sort_mode(new_mode)
      # update the collection observable's sorting function
      switch new_mode
        when 'label_text' then ...
        when 'label_created' then ...
        when 'label_priority' then ...
  )
  @collection_observable = kb.collectionObservable(todos, @todos, {view_model: TodoViewModel, sort_attribute: 'text'})
  @tasks_exist = ko.computed(=> @collection_observable().length)
```

* **sort_mode**: stores the current mode
* **sort_options**: provides the per option information to the template
* **selected_value**: provides the selection to the template and updates the application state when it changes
* **collection_observable**: start the sorting on the text attribute
* **tasks_exist**: tells the template whether to hide/show the list sorting interface

The sorting html added to the list template:

```html
<div id="todo-list-sorting" class="selection codestyle" data-bind="template: {name: 'option-template', foreach: list_sorting_options, templateOptions: {selected_value: selected_value} }"></div>
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
class PrioritiesCollection extends Backbone.Collection
  localStorage: new Store("kb_priorities") # Save all of the todos under the `"kb_priorities"` namespace.
priorities = new PrioritiesCollection()
```

To display the localized name of the priority and to render its color, the model is mapped onto a view model as follows:

```coffeescript
PrioritiesViewModel = (model) ->
  @priority = model.get('id')
  @priority_text = kb.observable(kb.locale_manager, {key: @priority})
  @priority_color = kb.observable(model, {key: 'color'})
  @           # must return this or Coffeescript will return the last statement which is not what we want!
```

The tricky part is to set up the dependencies (see below section "Knockout Dependencies") for the settings display, the tooltip, and the model priority swatch. To do this, I wrote a small helper method "createColorsDependency" to manually create dependencies on all of the view model properties (which are themselves dependent on the model's 'color' attribute through the PrioritiesViewModel):

```coffeescript
SettingsViewModel = (priorities) ->
  @priorities = ko.observableArray(_.map(priorities, (model)-> return new PrioritiesViewModel(model)))
  @getColorByPriority = (priority) ->
    @createColorsDependency()
    (return view_model.priority_color() if view_model.priority == priority) for view_model in @priorities()
    return ''
  @createColorsDependency = => view_model.priority_color() for view_model in @priorities()
```

The priority color settings are rendered as follows:

```html
<div id="priority-color-settings" data-bind="template: {name: 'priority-setting-template', foreach: window.app.viewmodels.settings.priorities}"></div>
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

The tooltipped-priority is rendered in the create section and todo item template like:

```html
<div data-bind="template: {name: 'priority-swatch-picker-template', data: $data}"></div>
```

using this template for the color swatch:

```html
<script type="text/x-jquery-tmpl" id="priority-swatch-picker-template">
  <div class="priority-color-swatch todo create" data-bind="style: {background: priority_color}, click: onToggleTooltip">
    <span class="priority-picker-tooltip ui-tooltip-top" data-bind="visible: tooltip_visible">
      <div data-bind="template: {name: 'priority-picker-template', foreach: window.app.viewmodels.settings.priorities, templateOptions: {onSelectPriority: onSelectPriority} }"></div>
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
SettingsViewModel = (priorities) ->
  ...
  @priorityToRank = (priority) ->
    switch priority
      when 'high' then return 0
      when 'medium' then return 1
      when 'low' then return 2
  @           # must return this or Coffeescript will return the last statement which is not what we want!
```

**Note:** I made the "priorityToRank" helper part of the settings view model rather than the priority model itself because it is view-related, not data related (as I mentioned in the "Frameworks Introduction" for Knockout, Knockout does not make this important distinction and would serialize the view ranking into JSON sent to the server despite it being a view-only value).

### Localization

Localization is key for the global applications we create today. It should not be an afterthought! (although it is optional functionality in Knockback ;-) )

Knockback does not provide a locale manager (although there is a sample with this todos application in: todos_locale_manager.coffee) because different applications will retrieve their localized strings in different ways, but expects a familiar LocaleManager signature:

1. Emulate a simplified Backbone.Model through a get method like "get: (string_id) -> ..."
2. Trigger Backbone.Events 'change' and 'change:#{string_id}' like:

```coffeescript
@trigger('change', @)
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
HeaderViewModel = ->
  ...
  @input_placeholder_text = kb.observable(kb.locale_manager, {key: 'placeholder_create'})
```

Or model attributes can be localized automatically when your locale manager triggers a change:

```coffeescript
TodoViewModel = (model) ->
  ...
  @completed = kb.observable(model, {key: 'completed', localizer: LongDateLocalizer})
```

### Lazy Loading

By using Knockback with [Backbone.ModelRef][18], you can start rendering your views before the models are loaded.

As demonstration, you can see that the colors arrive a little after the rendering. It is achieved by passing model references instead of models to the settings view model:

```coffeescript
SettingsViewModel = (priorities) ->
  @priorities = ko.observableArray(_.map(priorities, (model)-> return new PrioritiesViewModel(model)))
  ...
window.app.viewmodels.settings = new SettingsViewModel([
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

### Routing and View Lifecycle Management

Because this application doesn't have a good exit point, I have not demonstrated routing for single page apps nor View lifecycle management.

Typically, I have a light "View" class that gets created and destroyed either by a routing mechanism for root views or by an owning view for subviews:

```coffeescript
class HomeView
  constructor: ->
    @view_model =
      foo: 'bar'

    ko.applyBindings(@view_model, $('#home_view')[0])

  destroy: ->
    kb.vmRelease(@view_model)
```

**Note:** you are seeing correctly. With Knockback, you no longer need to use Backbone.Views!

As for routing, you could do something like this:

```coffeescript
app = {}
app.setView = (view) ->
  return if app.current_view == view
  app.current_view.destroy() if app.current_view
  app.current_view = view

class AppRouter extends Backbone.Router
  routes: {
    'home': 'goHome'
    'page1': 'gotoPage1'
  }

  goHome: -> app.setView(new HomeView())
  gotoPage1: -> app.setView(new Page1View())

# Start the app on 'home' if no page supplied
app_router = new AppRouter
window.location.hash = 'home' if not window.location.hash
Backbone.history.start()
```

Of course, Backbone.Routers are not the only show in town. You could just as easily use [Path.js][19]:

```coffeescript
app = {}
app.setView = (view) ->
  return if app.current_view == view
  app.current_view.destroy() if app.current_view
  app.current_view = view

Path.map("#/home").to(-> app.setView(new HomeView()) )
Path.map("#/page1").to(-> app.setView(new Page1View()) )

Path.root = '#/home'
Path.listen()
```

[19]: https://github.com/mtrpcic/pathjs

### Knockout Dependencies

The big gotcha with Knockout is its implicit dependencies for ko.computeds. Sometimes you need to include an unnecessary call to a dependent observable within you read function just to register dependencies.

In this case, the displayed text "remaining_text" needs to be updated with the locale_changes, but because the string id is dynamic and it inserts the count number, a manual locale dependency is used.

```coffeescript
FooterViewModel = (todos) ->
  kb.locale_change_observable = kb.triggeredObservable(kb.locale_manager, 'change') # use to register a localization dependency
  ...
  @remaining_text = ko.computed(=>
    kb.locale_change_observable() # use to register a localization dependency
    count = @collection_observable.collection().remainingCount(); return '' if not count
    return kb.locale_manager.get((if count == 1 then 'remaining_template_s' else 'remaining_template_pl'), count)
  )
```

In this case, "completed" changes when the the "completed" attribute changes or locale changes (through LongDateLocalizer). So "completed_text" will be relocalized correctly.

```coffeescript
TodoViewModel = (model) ->
  ...
  @completed = kb.observable(model, {key: 'completed', localizer: LongDateLocalizer})
  @completed_text = ko.computed(=>
    completed = @completed() # ensure there is a dependency
    return if !!completed then return "#{kb.locale_manager.get('label_completed')}: #{completed}" else ''
  )
```

**Note:** Knockback's observables are all ko.computeds behind-the-scenes so the same rules apply to them as for any ko.computed