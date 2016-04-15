test = require 'tape'
EventStore = require '../eventStore'
Event = require '../event'

test 'Core members of EventStore are not mutable', (t) ->
  store = EventStore()
  store.add = 'foo'
  store.getEvents = 'foo'

  t.false store.add is 'foo'
  t.false store.getEvents is 'foo'
  t.end()

test 'Eventstore updates its in memory store of events', (t) ->
  store = EventStore()
  store.add {}

  t.ok store.getEvents().length is 1
  t.end()

test "::add and ::getEvents can be overriden through constructor function", (t) ->
  event = Event(name: 'FooEvent', aggregateId: 'foo', state: {}, payload: {})
  store = EventStore({
    add: (e) -> t.deepEquals event, e, "The override add function was called with the event"
    getEvents: -> ['foo']
  })

  store.add(event)

  events = store.getEvents()

  t.ok events.length is 1
  t.is events[0], 'foo', "the override getEvents function was called"
  t.end()
