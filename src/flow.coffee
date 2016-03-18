module.exports = ({eventStore, eventBus, commands, commandHandlers}) ->
  properties =
    dispatch:
      value: (command) ->
        events = commandHandlers[command.name]?(command.message)
        if events?
          eventStore.add events
          eventBus?.publish?(events)
        events

  Object.defineProperties {}, properties
