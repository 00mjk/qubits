test = require 'tape'
Repository = require '../repository'
Event = require '../event'

# stub factory function
Foo = (state) ->
  id = state.id
  newState = Object.assign({}, state)
  delete newState.id
  agg = {
    state: newState
    id: id
  }
Foo.__aggregate_name__ = 'Foo'

test "Core methods of Repository cannot be changed", (t) ->
  repository = Repository(Foo, {})
  repository.add = 'foo'
  repository.load = 'foo'

  t.false repository.add is 'foo'
  t.false repository.load is 'foo'
  t.end()

test "Repository::add creates an aggregate from passed attributes and returns the create event", (t) ->
  createdEvent =
    name: 'FooCreatedEvent'
    aggregateId: 'foo1'
    payload:
      id: 'foo1'
    state: {}
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository(Foo, store)

  result = repository.add id: 'foo1'

  t.deepEquals result, createdEvent, "event published is as expected"
  t.end()

test "Repository::load with an existing id resolves to the aggregate", (t) ->
  t.plan 1

  store =
    add: new Function()
    getEvents: -> []

  repository = Repository(Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  repository.load('foo1').then (aggreate) ->
    t.equals aggreate.id, aggregateId

test "Repository::load with a non-existent id resolves to null", (t) ->
  t.plan 1

  store =
    add: new Function()
    getEvents: -> []

  repository = Repository(Foo, store)

  repository.load('foo1').then (aggregate) ->
    t.equal aggregate, null

test "Repository::load with an existing id that is not already cached returns a recreated instance of most recent state", (t) ->
  t.plan 1

  createdEvent =
    name: 'FooCreatedEvent'
    aggregateId: 'foo1'
    payload:
      name: 'something'
    state:
      name: 'something'
  anotherEvent =
    name: 'AnotherEvent'
    aggregateId: 'foo1'
    payload:
      name: 'another thing'
    state:
      name: 'another thing'

  store =
    add: new Function()
    getEvents: -> [createdEvent, anotherEvent]

  repository = Repository(Foo, store)
  repository.load('foo1').then (aggregate) ->
    t.deepEquals aggregate, Foo(id: 'foo1', name: anotherEvent.payload.name)

test "Repository::delete resolves to an event", (t) ->
  t.plan 1

  events = []
  store =
    add: (event) -> events.push event
    getEvents: -> events

  deletedEvent = Event(
    name: 'FooDeletedEvent'
    aggregateId: 'foo1'
    payload: {}
    state: {}
  )
  repository = Repository(Foo, store)

  createdEvent = repository.add id: 'foo1'
  store.add(createdEvent)

  repository.delete(createdEvent.aggregateId).then (event) ->
    t.deepEquals event, deletedEvent, "event published is as expected"

test "After Repository::delete an aggregate is no longer accessible", (t) ->
  t.plan 1
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository(Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  repository.delete(aggregateId)
  .then (event) -> repository.load('foo1')
  .then (aggregate) ->
    t.equal aggregate, null, "the promise resolved to null"

test "Repository function accepts an optional third argument for aggregate name", (t) ->
  createdEvent =
    name: 'UberFooCreatedEvent'
    aggregateId: 'foo1'
    payload:
      id: 'foo1'
    state: {}
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository(Foo, store, 'UberFoo')

  result = repository.add id: 'foo1'

  t.deepEquals result, createdEvent, "event published is as expected"
  t.end()
