module.exports = ({eventStore, eventBus, commandHandlers}) ->
  sendEvents = (events) ->
    eventStore.add events
    eventBus?.publish?(events)

  dispatch = (command) ->
    _events = commandHandlers[command.name]?(command.message)
    if _events.then?
      _events.then sendEvents
    else
      sendEvents _events
    _events

  properties =
    dispatch:
      value: dispatch

  Object.defineProperties {}, properties
