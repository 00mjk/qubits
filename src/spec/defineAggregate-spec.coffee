test = require 'tape'
defineAggregate = require '../defineAggregate'

test "defineAggregate takes an object with name, idGenerator, state, and methods, and returns a factory function", (t) ->
  SomeAggregate = defineAggregate
    name: 'SomeAggregate'
    idGenerator: -> 'foo1'
    state:
      name: null
    methods:
      foo: -> @id

  t.true typeof SomeAggregate is 'function', "result of defineAggregate is a function"

  agg = SomeAggregate name: 'foo'

  t.is agg.state.name, 'foo', "created object has the state passed into factory function"
  t.is agg.state.id, undefined, "created object does not have the attribute 'id' in its state"
  t.is agg.id, 'foo1', "created object has an id"
  t.ok agg.foo, "created object has the methods passed into factory function"
  t.is agg.foo(), agg.id, "create object methods have correct access to 'this'"
  t.end()

test "id is not part of state", (t) ->
  Aggregate = defineAggregate state: {}, methods: {}
  agg = Aggregate id: 'foo1'

  t.is agg.state.id, undefined, "created object does not have the attribute 'id' in its state"
  t.end()

test "Factory function expects an id if an id function isn't passed to defineAggregate function", (t) ->
  Aggregate = defineAggregate state: {}, methods: {}

  t.throws Aggregate
  t.end()

test "Factory function uses the passed in id even if an id function has already been defined", (t) ->
  Aggregate = defineAggregate
    idGenerator: -> 'foo1'
    state: {}
    methods: {}

  agg = Aggregate({id: 'foo2'})
  t.is agg.id, 'foo2', "created object has the passed in id"
  t.end()
