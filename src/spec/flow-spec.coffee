test = require 'tape'
Flow = require '../flow'
Event = require '../event'

mockEventStore = add: new Function()

test "Core methods of Flow cannot be changed", (t) ->
  flow = Flow(eventStore: mockEventStore, commandHandlers: {})
  flow.dispatch = 'foo'

  t.false flow.dispatch is 'foo'
  t.end()

test "Flow will correctly map dispatched commands to their handlers", (t) ->
  t.plan 1

  commandArgs = x: 1, y: 1

  Commands =
    Add: -> name: 'Add', message: commandArgs
  AddedEvent = Event aggregateId: 'foo', name: 'AddedEvent', payload: commandArgs
  Handlers =
    Add: (args)->
      t.equal args, commandArgs, "command handler was invoked with command arguments"
      AddedEvent

  flow = Flow(eventStore: mockEventStore, commandHandlers: Handlers)

  flow.dispatch Commands.Add()

  t.end()

test "Flow puts newly created events from command handlers into the EventStore and EventBus", (t) ->
  t.plan 2

  AddedEvent = Event aggregateId: 'foo', name: 'AddedEvent', payload: {}
  EventStore = add: (event) -> t.equal event, AddedEvent, "EventStore::add was called with the event"
  EventBus = publish: (event) -> t.equal event, AddedEvent, "EventBus::publish was called with the event"

  Commands =
    Add: -> name: 'Add', message: {}
  Handlers =
    Add: -> AddedEvent

  flow = Flow(eventStore: EventStore, eventBus: EventBus, commandHandlers: Handlers)

  flow.dispatch Commands.Add()

  t.end()

test "Flow puts newly created events from Promise returning command handlers into the EventStore and EventBus", (t) ->
  t.plan 2

  AddedEvent = Event aggregateId: 'foo', name: 'AddedEvent', payload: {}
  EventStore = add: (event) -> t.equal event, AddedEvent, "EventStore::add was called with the event"
  EventBus = publish: (event) -> t.equal event, AddedEvent, "EventBus::publish was called with the event"

  Commands =
    Add: -> name: 'Add', message: {}
  Handlers =
    Add: -> Promise.resolve(AddedEvent)

  flow = Flow(eventStore: EventStore, eventBus: EventBus, commandHandlers: Handlers)

  flow.dispatch Commands.Add()
