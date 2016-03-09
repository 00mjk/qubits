# System
This is simply a POC and my way of writing down my thoughts about how I would want to implement a CQRS system. The focus here is on components/tools and functions that can be interchanged rather than a full framework.

## components
  * Domain Model (Aggregate)
    > This is the object that represents the state of our model. Only it can change its own state as a result of Commands. Each state change results in an Event.

  * EventStore
    > A storage facility for events/history/facts. This can be in memory or backed by a database. What I have here is in memory.

  * EventBus
    > The medium through which facts of state change are shared to interested observers.

  * EventListeners
    > These are the observers of facts of state changes. They are functions to be invoked when the domain model has changed its state.

  * Repository
    > A component through which we create and access the domain model.

  * Commands
    > Objects representing an intent of state change by the user on the domain model.

  * CommandHandlers
    > Functions with the purpose of communicating the intended state change to the domain model.  

  * Events  
    > Objects representing a fact of state change in the domain model.

Based on these definitions of the components, the system should work like this:

  > CommandHandlers are effectively `CH(Command) -> [...Event]`

  >Actions the domain model can execute are `A() -> [...Event]`

This means every intention to change the state of the domain model results in *n* events (where n = 0 is a failure and n > 0 is success).

## Examples of usage
Of course, I'll use a Todo application because that's the app any system can build.

``` coffeescript
System = require 'system'

Todo = System.defineAggregate
  name: 'Todo'
  state:
    description: null
    completed: false
  methods:
    complete: ->
      @state.completed = true
      System.Event(aggregateId: @id, name: 'TodoCompletedEvent', payload: {completed: true}, state: @state)

TodoCommands =
  CreateTodo: ({id, description }) -> name: 'CreateTodo', message: {id, description}
  MarkAsCompleted: ({ id }) -> name: 'MarkAsCompleted', message: {id}

TodoEventStore = System.EventStore()

TodoRepository = System.Repository 'Todo', Todo, TodoEventStore

TodoCommandHandlers =
  CreateTodo: (attrs) -> TodoRepository.add attrs
  MarkAsCompleted: ({ id }) ->
    todo = TodoRepository.load id
    todo.complete()

TodoEventBus = System.EventBus()

TodoCreatedEventListenerToUpdateDB = (event) -> # Update database...
TodoCreatedEventListenerToLogStuff = (event) -> # Do some logging...

TodoEventBus.registerListeners
  TodoCreatedEvent: [
    TodoCreatedEventListenerToUpdateDB
    TodoCreatedEventListenerToLogStuff
  ]
  TodoCompletedEvent: [
    (event) ->
      # More stuff to be done
  ]
```

### It _can_(doesn't have to) all come together like so...
``` coffeescript
TodoFlow = System.Flow
  eventStore: TodoEventStore
  eventBus: TodoEventBus
  commands: TodoCommands
  commandHandlers: TodoCommandHandlers

## Later when the user wants to do things...
TodoFlow.dispatch TodoCommands.CreateTodo id: 'todo1', description: 'Create a todo'
TodoFlow.dispatch TodoCommands.MarkAsCompleted id: 'todo1'
```
