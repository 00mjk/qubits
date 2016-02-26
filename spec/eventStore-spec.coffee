test = require 'tape'
EventStore = require '../eventStore'

test 'Core members of EventStore are not mutable', (t) ->
  store = EventStore()
  store.registerEventBus = 'foo'
  store.add = 'foo'
  store.getEvents = 'foo'

  t.false store.registerEventBus is 'foo'
  t.false store.add is 'foo'
  t.false store.getEvents is 'foo'
  t.end()

test 'EventStore registers an eventBus and publishes to it', (t) ->
  store = EventStore()
  t.plan 1
  eventToSave = name: 'event'
  store.registerEventBus publish: (event) -> t.deepEquals eventToSave, event, "The event was published"

  store.add(eventToSave)
  t.end()

test 'Eventstore updates its in memory store of events', (t) ->
  store = EventStore()
  store.add {}

  t.ok store.getEvents().length is 1
  t.end()
