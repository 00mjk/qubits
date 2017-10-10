module.exports = ({eventStore, eventBus, commandHandlers}) ->
  sendEvents = (events) ->
    eventStore.add events
    eventBus?.publish?(events)

  dispatch = (command) ->
    eventsPromise = Promise.resolve(commandHandlers[command.name]?(command.message))
    eventsPromise.then(sendEvents)
    .catch (error) -> console.error(error)
    return eventsPromise

  properties =
    dispatch:
      value: dispatch

  Object.defineProperties {}, properties
