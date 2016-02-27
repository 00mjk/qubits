test = require 'tape'
Repository = require '../repository'

test "Core methods of Repository cannot be changed", (t) ->
  repository = Repository()
  repository.add = 'foo'
  repository.load = 'foo'

  t.false repository.add is 'foo'
  t.false repository.load is 'foo'
  t.end()

test "Repository::add creates an aggregate from and adds the create event to the event store", (t) ->
  t.plan 2

  createdEvent =
    name: 'FooCreatedEvent'
    aggregateId: 'foo1'
    payload: {}
  store = add: (event) -> t.deepEquals event, createdEvent, "event published is as expected"
  Foo = (state) -> state

  repository = Repository('Foo', Foo, store)

  foo = repository.add id: 'foo1'

  t.is foo.id, 'foo1'
  t.end()

test "Repository::load with an existing id returns the aggregate", (t) ->
  Foo = (state) -> state
  store = add: ->

  repository = Repository('Foo', Foo, store)

  foo1 = repository.add id: 'foo1'

  t.equal repository.load('foo1'), foo1
  t.end()

test "Repository::load with a non-existent id returns null", (t) ->
  Foo = (state) -> state
  store = add: ->

  repository = Repository('Foo', Foo, store)

  t.equal repository.load('foo1'), null
  t.end()
