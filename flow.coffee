module.exports = ({eventStore, commands, commandHandlers}) ->
  properties =
    dispatch:
      value: (command) ->
        events = commandHandlers[command.name]?(command.message)
        eventStore.add events if events?

  Object.defineProperties {}, properties
