EventStore = require './eventStore'
Repository = require './repository'
Flow = require './flow'
Event = require './event'

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
        Event(aggregateId: id, name: 'TodoCompletedEvent', payload: state)
  }
  todo.state = state
  todo.id = id
  todo

TodoEventStore = EventStore()
TodoRepository = Repository 'Todo', Todo, TodoEventStore

TodoCommands =
  CreateTodo: ({ id, description }) -> name: 'CreateTodo', message: {id, description}
  MarkAsCompleted: ({ id }) -> name: 'MarkAsCompleted', message: {id}

TodoCommandHandlers =
  CreateTodo: (attrs) -> TodoRepository.add attrs
  MarkAsCompleted: ({ id }) ->
    todo = TodoRepository.load id
    todo.complete()

TodoFlow = Flow
  eventStore: TodoEventStore
  commands: TodoCommands
  commandHandlers: TodoCommandHandlers

TodoFlow.dispatch TodoCommands.CreateTodo id: 'todo1', description: 'Write tests.'
TodoFlow.dispatch TodoCommands.MarkAsCompleted id: 'todo1'
