EventStore = require './eventStore'
Repository = require './repository'

Todo = (attrs) ->
  id = attrs.id
  delete attrs.id
  state =
    description: null
    completed: false

  state = Object.assign state, attrs
  todo = Object.defineProperties {}, {
    complete:
      value: ->
        state.completed = true
        id: id, name: 'TodoCompleted', payload: state
  }
  todo.state = state
  todo.id = id
  todo

runner = ->
  TodoEventStore = EventStore()

  TodoRepository = Repository 'Todo', Todo, TodoEventStore
  todo1 = TodoRepository.add id: 'todo1', description: 'build it'
  todo1.complete()

module.exports = {runner, Todo}
