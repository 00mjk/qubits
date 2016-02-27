test = require 'tape'
EventStore = require '../eventStore'

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
