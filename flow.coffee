module.exports = ({eventStore, eventBus, commands, commandHandlers, eventListeners}) ->
  properties =
    dispatch:
      value: (command) ->
        events = commandHandlers[command.name]?(command.message)
        if events?
          eventStore.add events
          eventBus.publish events

  Object.defineProperties {}, properties
