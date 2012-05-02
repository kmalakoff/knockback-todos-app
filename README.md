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

Frameworks Introduction
----------

Backbone is an MVC-like framework and Knockout is MVVM. For a little theoretical background:

1. [MVC][9] and [Backbone's take on MVC][10]
2. [MVVM][19]
3. [ORM][20] as related to Backbone models and collections

Some resources on Backbone:

* [Backbone website][15]

Some resources on Knockout:

* [Knockout website][16] - amazing interactive examples
* [Video][17] - a good overview

Both Knockout and Backbone have their strengths and weaknesses, but together they are amazing!

Please take a look at the [Knockback website][7] for an analysis of each framework and how by bridging the two framework, Knockout addresses each of their weaknesses and adds some powerful new features.

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

If you look at the Knockout Todo app [demo][21] and [code][14], you will notice a few things:

* it is small
* there is a custom client side persistence (ORM) that provides no framework for managing models, collections, and relationships

### Knockback

With the Knockback Todo project, I wanted to show more than a minimal demo to put Knockback into a good light, but demonstrate some real-world approaches to solving problems like (localization and data loading delays) and to present some of the additional functionality that Knockback can easily bring to your application.

So I split up the Todo application into steps that reflect a real-world development process and that make the concepts more easily digestible.

* **Todos - Classic**: the classic Todo app following the [TodoMVC App Specifications][8].
* **Todos - Knockback Complete**: the classic todo app with extensions for a completed date/time message, list view sorting, priorities with customizable colors, and localization (EN/FR/IT). It shows off the additional power and flexibility of Knockback including lazy model loading through Backbone.ModelRef.

Todos Architecture
------------

### Knockback follows the MVVM Pattern

With the MVVM pattern, instead of Model, View, Controller you use Model, View, ViewModel. As an simple approximation using MVC terminology:

* Models are handled by Backbone.Models and Backbone.Collections
* Views are handled by Templates (inline or jQuery)
* ViewModels take the place of Controllers

### MVVM in "Todos - Classic"

The Classic application is an upgraded port of the Backbone Todos application so it has the same ORM with Todo (Backbone.Model) and TodoCollection (Backbone.Collection), but the two views are replaced by various ViewModels and templates for each section of the screen (SettingsViewModel, HeaderViewModel, TodosViewModel, FooterViewModel).

**Models (Backbone.Model + Backbone.Collection)**

* **Todo:** provides the data and operations for a Todo like setting its complete state and saving changes on the server/local-storage
* **TodoCollection:** fetches models from the server and provides summary information on the Todo data like how many are completed, remaining, etc

**ViewModels**

* **SettingsViewModel:** provides properties to select the active filtering for Todos
* **HeaderViewModel:** provides properties to configure the new todo input element and provides a hook to the input element in the template so the ViewModel can create a new Todo Model when Enter is pressed
* **TodosViewModel:** provides the ViewModels to render each Todo in the collection
* **FooterViewModel:** provides and updates the summary stats attributes whenever the Todo list or one of its Todo models changes

### MVVM in "Todos - Extended"
This application extends the "Todos - Classic" by adding settings including todo priorities (display colors and orders), language selection and localized text, adding todos list sorting options (by name, created date, and priority). Along with the following changes:

**Models (Backbone.Model + Backbone.Collection)**

* **Priority:** provides the data for the priority and color information that is saved on the server/local-storage. It could be a generic Backbone.Model but for clarity and consistency with the mock up, it is given a class.
* **PriorityCollection:** a very basic collection for fetching all of the priority settings

**ViewModels**

* **PrioritiesViewModel:** provides localized text (that shouldn't be saved to the server) and color properties to the 'priority-setting-template' template
* **SettingsViewModel:** provides the priority settings globally to the application, the current default priority and color for new tasks, a priority ranking to the TodosViewModel for sorting, the selected and available locales from the locale manager ('en', 'fr-FR', 'it-IT') into display strings ('EN', 'FR', 'IT'), todos sorting radio buttons.
* **HeaderViewModel:** upgraded to expose properties for rendering the current default Todo priority and a hook to show/hide the tooltip for selecting the default priority
* **TodoViewModel:** upgraded to expose properties for rendering its Todo priority and a hook to show/hide the tooltip for selecting the Todo priority


### Localization

Localization is key for the global applications we create today. It should not be an afterthought!

Knockback does not provide a locale manager (although there is a sample implementation with this todos application in: models/locale_manager.coffee) because different applications will retrieve their localized strings in different ways. Instead, Knockback provides a localization pattern by using a simpified Backbone.Model-like signature that hooks into Knockback like any other model:

1. Emulate a simplified Backbone.Model through a get method like "get: (string_id) -> ..."
2. Mixin Backbone.Events '_.extend(LocaleManager.prototype, Backbone.Events)' and trigger Backbone.Events 'change' and 'change:#{string_id}' like:

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
**Note:** kb.LocalizedObservable's constructor actually returns a ko.computed (not the instance itself) so you either need to return super result or if you have custom initialization, return the underlying observable using the following helper: "kb.wrappedObservable(this)"

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

Tips and Gotchas
----------------

### ViewModel Lifecycle Management

Because this application doesn't have a good exit point, I have not demonstrated ViewModel lifecycle management.

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


### Relationships between Models and ViewModels - Often One-To-Many

In the Todos applications, there is a one-to-one relationship between Models and ViewModels, but the distinction is important:

* Backbone.Models encapsulate the data and operations on the data, are serialized/deserialized from/to the server, and are in short Models.
* ViewModels provide the attributes and logic to the templates often interacting with the Model data like Controllers. However, they may have their own data and logic that is purely View-related and that the server should never know about.

Besides providing a clean separation between data and display, this separation becomes important in a larger application. In a larger application, you often have different ways to present the same Model with different ViewModels. For example, a Model could have the following ViewModels:

1. Thumbnail View - the ViewModel could only expose a subset of the Model's attributes, dates/time may be in the shortest format possible, or maybe just an image would be provided to the template.
2. Cell View - the ViewModel could again expose a subset of only the most relevant summary attributes, routing information to a detailed summary view, etc.
3. Editing View - the ViewModel could expose almost all of the Model's attributes, localized labels for each, data and functions for the editing controls and functionality, routing information to specialized editing views, etc.

Important to understand that in a larger application the relationship between Models and ViewModels tends to be one-to-many. In this application, there is a one-to-many relationship from the Priority model through the the HeaderViewModel and TodoViewModel ViewModels because each one uses the Priority for rendering their priority colors and providing priority settings data to their tooltip, but the actions on selecting a priority in the tool tip differ.


### Knockout Dependencies

The big strength and gotcha with Knockout is its implicit dependencies for a ko.computed. Sometimes you need to include an explicit call to a ko.computed within your 'read' function to register dependencies such as:

```coffeescript
window.SettingsViewModel = (priorities, locales) ->
    ...
	@current_language = ko.observable(kb.locale_manager.getLocale())
	@selected_language = ko.computed(
		read: => return @current_language()  # used to create a dependency
		write: (new_locale) => kb.locale_manager.setLocale(new_locale); @current_language(new_locale)
	)
```

**Note:** Knockback's observables are all ko.computed behind-the-scenes so the same rules apply to them as for any ko.computed

[1]: https://github.com/kmalakoff/knockback/raw/master/knockback.js
[2]: https://github.com/kmalakoff/knockback/raw/master/knockback.min.js
[3]: http://knockoutjs.com/
[4]: http://documentcloud.github.com/backbone/
[5]: http://documentcloud.github.com/underscore/
[6]: https://github.com/kmalakoff/backbone-modelref
[7]: http://kmalakoff.github.com/knockback/
[8]: https://github.com/addyosmani/todomvc/wiki/App-Specification
[9]: http://en.wikipedia.org/wiki/Model_view_controller
[10]: http://documentcloud.github.com/backbone/#FAQ-mvc
[11]: http://addyosmani.github.com/todomvc/
[12]: http://addyosmani.github.com/todomvc/architecture-examples/backbone/index.html
[13]: http://documentcloud.github.com/backbone/docs/todos.html
[14]: https://github.com/rniemeyer/todomvc/tree/master/architecture-examples/knockoutjs
[15]: http://documentcloud.github.com/backbone/
[16]: http://knockoutjs.com/examples/helloWorld.html
[17]: http://channel9.msdn.com/Events/MIX/MIX11/FRM08
[18]: https://github.com/kmalakoff/backbone-modelref
[19]: http://en.wikipedia.org/wiki/Model_View_ViewModel
[20]: http://en.wikipedia.org/wiki/Object-relational_mapping
[21]: http://addyosmani.github.com/todomvc/architecture-examples/knockoutjs/index.html
