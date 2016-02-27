test = require 'tape'
Flow = require '../flow'
Event = require '../event'

mockEventStore = add: new Function()

test "Core methods of Flow cannot be changed", (t) ->
  flow = Flow(eventStore: mockEventStore, commands: {}, commandHandlers: {})
  flow.dispatch = 'foo'

  t.false flow.dispatch is 'foo'
  t.end()

test "Flow with commands and command handlers, will correctly map them", (t) ->
  t.plan 1

  commandArgs = x: 1, y: 1

  Commands =
    Add: -> name: 'Add', message: commandArgs
  Handlers =
    Add: (args)-> t.equal args, commandArgs, "command handler was invoked with command arguments"

  flow = Flow(eventStore: mockEventStore, commands: Commands, commandHandlers: Handlers)

  flow.dispatch Commands.Add()

  t.end()

test "Flow puts newly created events from commands into the EventStore and EventBus", (t) ->
  t.plan 2

  AddedEvent = Event aggregateId: 'foo', name: 'AddedEvent', payload: {}
  EventStore = add: (event) -> t.equal event, AddedEvent, "EventStore::add was called with the event"
  EventBus = publish: (event) -> t.equal event, AddedEvent, "EventBus::publish was called with the event"

  Commands =
    Add: -> name: 'Add', message: {}
  Handlers =
    Add: -> AddedEvent

  flow = Flow(eventStore: EventStore, eventBus: EventBus, commands: Commands, commandHandlers: Handlers)

  flow.dispatch Commands.Add()

  t.end()
