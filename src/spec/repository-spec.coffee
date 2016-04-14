test = require 'tape'
Repository = require '../repository'

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
  Foo = (state) -> state

  repository = Repository('Foo', Foo, store)

  result = repository.add id: 'foo1'

  t.deepEquals result, createdEvent, "event published is as expected"
  t.end()

test "Repository::load with an existing id returns the aggregate", (t) ->
  Foo = (state) -> state
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository('Foo', Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  t.equals repository.load('foo1').id, aggregateId
  t.end()

test "Repository::load with a non-existent id returns null", (t) ->
  Foo = (state) -> state
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository('Foo', Foo, store)

  t.equal repository.load('foo1'), null
  t.end()

test "Repository::load with an existing id that is not already cached returns a recreated instance of most recent state", (t) ->
  Foo = (state) -> state
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

  t.deepEquals repository.load('foo1'), Foo(id: 'foo1', name: anotherEvent.payload.name)
  t.end()

test "Repository::delete returns an event", (t) ->
  Foo = (state) -> state
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

  result = repository.delete(aggregateId)
  t.deepEquals result, deletedEvent, "event published is as expected"
  t.end()

test "After Repository::delete an aggregate is no longer accessible", (t) ->
  Foo = (state) -> state
  store =
    add: new Function()
    getEvents: -> []

  repository = Repository('Foo', Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  repository.delete(aggregateId)
  t.equals repository.load('foo1'), null
  t.end()
