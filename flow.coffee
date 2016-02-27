module.exports = ({commands, commandHandlers}) ->
  properties =
    dispatch:
      value: (command) ->
        commandHandlers[command.name]?(command.message)

  Object.defineProperties {}, properties
