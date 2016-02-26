listeners = {}
events = []

bus =
  registerListener: (eventName, listener) ->
    listenersForEvent = listeners[eventName]
    if listenersForEvent is undefined
      listeners[eventName] = [listener]
    else
      listenersForEvent.push listener

  publish: (event) ->
    events.push event
    listeners[event.name]?.forEach?(listener -> listener.handle(event))

module.exports = bus
