test = require 'tape'
Repository = require '../repository'

Foo = (state) -> state

test "Core methods of Repository cannot be changed", (t) ->
  repository = Repository('')
  repository.add = 'foo'
  repository.load = 'foo'

  t.false repository.add is 'foo'
  t.false repository.load is 'foo'
  t.end()

test "Repository::add creates an aggregate from passed attributes and returns the create event", (t) ->
  t.plan 1

  createdEvent =
    name: 'FooCreatedEvent'
    aggregateId: 'foo1'
    payload:
      id: 'foo1'
    state: {}
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository('Foo', Foo, store)

  result = repository.add id: 'foo1'

  t.deepEquals result, createdEvent, "event published is as expected"
  t.end()

test "Repository::load with an existing id resolves to the aggregate", (t) ->
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository('Foo', Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  repository.load('foo1').then (aggreate) ->
    t.equals aggreate.id, aggregateId
    t.end()

test "Repository::load with a non-existent id resolves to null", (t) ->
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository('Foo', Foo, store)

  repository.load('foo1').then (aggregate) ->
    t.equal aggregate, null
    t.end()

test "Repository::load with an existing id that is not already cached returns a recreated instance of most recent state", (t) ->
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

  repository = Repository('Foo', Foo, store)
  repository.load('foo1').then (aggregate) ->
    t.deepEquals aggregate, Foo(id: 'foo1', name: anotherEvent.payload.name)
    t.end()

test "Repository::delete resolves to an event", (t) ->
  store =
    add: new Function()
    getEvents: -> []

  deletedEvent =
    name: 'FooDeletedEvent'
    aggregateId: 'foo1'
    payload: {}
    state: {}
  repository = Repository('Foo', Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  repository.delete(aggregateId).then (event) ->
    t.deepEquals event, deletedEvent, "event published is as expected"
    t.end()

test "After Repository::delete an aggregate is no longer accessible", (t) ->
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository('Foo', Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  repository.delete(aggregateId)
  .then (event) -> repository.load('foo1')
  .then (aggregate) ->
    t.equal aggregate, null, "the promise resolved to null"
    t.end()
