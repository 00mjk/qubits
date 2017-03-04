# Qubits
This was originally a simple POC and a way for me to write down my thoughts about how I would want to implement an eventsourced CQRS system. The focus here is on components/tools and functions that can be interchanged rather than a full framework.

## components
  * Domain Model (Aggregate)
    > This is the object that represents the state of our model. It is responsible for changing its own state as a result of Commands. Each state change results in an Event.

  * Events  
    > Objects representing a fact of state change in the domain model.

  * EventStore
    > A storage facility for events/history/facts. This can be in memory or backed by a database.

  * EventBus
    > The medium through which facts of state change are shared to interested observers.

  * EventListeners
    > These are the observers of facts of state changes. They are functions to be invoked when the Aggregate has changed its state.

  * Repository
    > A component through which we create and access the domain model. It's an in-memory collection of Aggregates.

  * Commands
    > Objects representing an intent of state change by the user on the Aggregate.

  * CommandHandlers
    > Functions with the purpose of communicating the intended state change to the Aggregate.  

Based on these definitions of the components and given CommandHandlers (CH) and actions the Aggregate can do (A), the system should work like this:

  > `CH(Command) -> A() -> [...Event]`

This means every intention to change the state of the domain model results in *n* events (where n = 0 is a failure and n > 0 is success).

## Examples of usage
Of course, I'll use a Todo application to demonstrate how this works.

``` javascript
const {defineAggregate, Event, EventStore, Repository, EventBus} = require('qubits')

const Todo = defineAggregate({
  name: 'Todo',
  state: {
    description: null,
    completed: false
  },
  methods: {
    complete: () => {
      this.state.completed = true
      return Event({
        aggregateId: this.id,
        name: 'TodoCompletedEvent',
        payload: {completed: true}
      })
    }
  }
})

// Create commands to represent intent to change state.
// These are just factory functions
const TodoCommands = {
  CreateTodo: ({id, description }) => {
    return {name: 'CreateTodo', message: {id, description}},
  },
  MarkAsCompleted: ({id}) => {
    return {name: 'MarkAsCompleted', message: {id}}
  }
}

const TodoEventStore = EventStore()
// If you want to persist events somewhere else like a database,
// it's easy to override how the event store works.
//
// const TodoEventStore = EventStore({
//  add: event => // put it somewhere
//  getEvents: => // return an array (or Promise of an array) of events
// })

const TodoRepository = Repository(Todo, TodoEventStore)

const TodoCommandHandlers = {
  CreateTodo: attrs => {
    return TodoRepository.add(attrs)
  },
  MarkAsCompleted: ({ id }) => {
    const todo = TodoRepository.load(id)
    return todo.complete()
  }
}

const TodoEventBus = EventBus()

// These are event listeners. They are plain functions with side effects.
// They don't need to return anything because they are simply observers
const TodoCreatedEventListenerToUpdateDB = event => // Update database...
const TodoCreatedEventListenerToLogStuff = event => // Do some logging...
const TodoCompletedEventListenerToSendNotification = event => // whatever...

TodoEventBus.registerListeners({
  TodoCreatedEvent: [
    TodoCreatedEventListenerToUpdateDB,
    TodoCreatedEventListenerToLogStuff
  ],
  TodoCompletedEvent: [TodoCompletedEventListenerToSendNotification]
})
```

### It _can_(but doesn't have to) all come together like so...
``` javascript
const TodoFlow = Qubits.Flow({
  eventStore: TodoEventStore,
  eventBus: TodoEventBus,
  commandHandlers: TodoCommandHandlers
})

// Later when the user wants to do things...
TodoFlow.dispatch(TodoCommands.CreateTodo({id: 'todo1', description: 'Create a todo'}))
TodoFlow.dispatch(TodoCommands.MarkAsCompleted({id: 'todo1'}))
```
