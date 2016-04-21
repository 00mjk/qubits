module.exports = ({eventStore, eventBus, commandHandlers}) ->
  sendEvents = (events) ->
    eventStore.add events
    eventBus?.publish?(events)

  dispatch = (command) ->
    Promise.resolve(commandHandlers[command.name]?(command.message))
    .then(sendEvents)
    .catch (error) -> console.error(error)

  properties =
    dispatch:
      value: dispatch

  Object.defineProperties {}, properties
