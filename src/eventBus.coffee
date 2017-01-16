doAtSomePoint = (cb) -> setTimeout(cb, 0)

module.exports = (listeners={}) ->
  registerListener = (eventName, listener) ->
    listenersForEvent = listeners[eventName]
    if listenersForEvent is undefined
      listeners[eventName] = [listener]
    else
      listenersForEvent.push listener

  registerListeners = (mapping) ->
    for eventName, ls of mapping
      ls.forEach (listener) -> registerListener(eventName, listener)

  properties =
    registerListeners:
      value: registerListeners
    registerListener:
      value: registerListener
    publish:
      value: (event) ->
        listeners[event.name]?.forEach (listener) ->
          doAtSomePoint -> listener(event)

  Object.defineProperties {}, properties
