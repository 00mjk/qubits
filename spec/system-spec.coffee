test = require 'tape'
System = require '../system'

test "Core methods of System cannot be changed", (t) ->
  sys = System()
  sys.dispatch = 'foo'

  t.false sys.dispatch is 'foo'
  t.end()

test "System with commands and command handlers, will correctly map them", (t) ->
  t.plan 1

  commandArgs = x: 1, y: 1

  Commands =
    Add: -> name: 'Add', message: commandArgs
  Handlers =
    Add: (args)-> t.equal args, commandArgs, "command handler was invoked with command arguments"

  sys = System(commands: Commands, commandHandlers: Handlers)

  sys.dispatch Commands.Add()

  t.end()
