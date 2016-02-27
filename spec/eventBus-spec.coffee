test = require 'tape'
EventBus = require '../eventBus'

test "Core methods of EventBus cannot be changed", (t) ->
  bus = EventBus()
  bus.registerListener = 'foo'
  bus.publish = 'foo'

  t.false bus.registerListener is 'foo'
  t.false bus.publish is 'foo'
  t.end()

test "Listeners can be registered all at once", (t) ->
  t.plan 2

  FooEvent = name: 'FooEvent'

  bus = EventBus()

  listeners =
    FooEvent: [
      (event) -> t.equals event, FooEvent
      (event) -> t.equals event, FooEvent
      ]

  bus.registerListeners listeners
  bus.publish FooEvent

  t.end()

test "EventBus invokes listeners when an event is published", (t) ->
  t.plan 1

  FooEvent = name: 'FooEvent'

  bus = EventBus()
  bus.registerListener 'FooEvent', (event) -> t.equals event, FooEvent
  bus.publish FooEvent

  t.end()
