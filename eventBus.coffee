module.exports = ->
  listeners = {}

  registerListener = (eventName, listener) ->
    listenersForEvent = listeners[eventName]
    if listenersForEvent is undefined
      listeners[eventName] = [listener]
    else
      listenersForEvent.push listener

  registerListeners = (mapping) ->
    for event, ls of mapping
      ls.forEach (listener) -> registerListener event, listener

  properties =
    registerListeners:
      value: registerListeners
    registerListener:
      value: registerListener
    publish:
      value: (event) ->
        listeners[event.name]?.forEach (listener) -> listener(event)

  Object.defineProperties {}, properties
