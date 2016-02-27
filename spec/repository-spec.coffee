test = require 'tape'
Repository = require '../repository'

test "Core methods of Repository cannot be changed", (t) ->
  repository = Repository()
  repository.add = 'foo'

  t.false repository.add is 'foo'
  t.end()

test "Repository::add creates an aggregate from and adds the create event to the event store", (t) ->
  t.plan 2

  createdEvent =
    name: 'FooCreatedEvent'
    aggregateId: 'foo1'
    payload: {}
  store = add: (event) -> t.deepEquals createdEvent, event
  Foo = (state) -> state

  repository = Repository('Foo', Foo, store)

  foo = repository.add id: 'foo1'

  t.is foo.id, 'foo1'
  t.end()
