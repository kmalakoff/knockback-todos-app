class window.Todo extends Backbone.Model
	defaults: -> return {created_at: new Date()}

	set: (attrs) ->
		# note: this is to convert between Dates as JSON strings and Date objects. To automate this, take a look at Backbone.Articulation: https://github.com/kmalakoff/backbone-articulation
		attrs['completed'] = new Date(attrs['completed']) if attrs and attrs.hasOwnProperty('completed') and _.isString(attrs['completed'])
		attrs['created_at'] = new Date(attrs['created_at']) if attrs and attrs.hasOwnProperty('created_at') and _.isString(attrs['created_at'])
		super

	completed: (completed) ->
		return !!@get('completed') if arguments.length == 0
		@save({completed: if completed then new Date() else null})
