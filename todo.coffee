EventStore = require './eventStore'

extend = (prototype, attrs) ->
  object = Object.create prototype
  Object.keys(attrs).forEach (key) -> object[key] = attrs[key]
  object

TodoState =
  id: null
  description: null
  completed: false

Todo =
  state: {}

  complete: ->
    Object.assign @state, { completed: true}
    name: 'TodoCompleted', payload: Object.assign {}, @state
Object.freeze Todo

TodoFactory = (state) ->
  todo = Object.create Todo
  todo.state = Object.assign todo.state, TodoState, state
  todo

Repository =
  add: (state) ->
    todo = @factory state
    @eventStore.add name: 'TodoCreated', payload: todo.state
    @cache[todo.state.id] = todo
    todo
Object.freeze Repository

runner = ->
  TodoEventStore = EventStore()

  TodoRepository = extend Repository, {
    initialize: (@eventStore, @factory) -> @cache = {}
  }
  TodoRepository.initialize TodoEventStore, TodoFactory
  todo1 = TodoRepository.add id: 'todo1', description: 'build it'
  todo1.complete()

module.exports = {runner, TodoFactory, Repository}
