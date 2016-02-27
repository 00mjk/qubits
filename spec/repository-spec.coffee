test = require 'tape'
Repository = require '../repository'

test "Core methods of Repository cannot be changed", (t) ->
  repository = Repository()
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
    payload: {}
  store = add: new Function()
  Foo = (state) -> state

  repository = Repository('Foo', Foo, store)

  result = repository.add id: 'foo1'

  t.deepEquals result, createdEvent, "event published is as expected"
  t.end()

test "Repository::load with an existing id returns the aggregate", (t) ->
  Foo = (state) -> state
  store = add: ->

  repository = Repository('Foo', Foo, store)

  {aggregateId} = repository.add id: 'foo1'

  t.equals repository.load('foo1').id, aggregateId
  t.end()

test "Repository::load with a non-existent id returns null", (t) ->
  Foo = (state) -> state
  store = add: ->

  repository = Repository('Foo', Foo, store)

  t.equal repository.load('foo1'), null
  t.end()
