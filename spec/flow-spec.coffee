test = require 'tape'
Flow = require '../flow'

test "Core methods of Flow cannot be changed", (t) ->
  flow = Flow()
  flow.dispatch = 'foo'

  t.false flow.dispatch is 'foo'
  t.end()

test "Flow with commands and command handlers, will correctly map them", (t) ->
  t.plan 1

  commandArgs = x: 1, y: 1

  Commands =
    Add: -> name: 'Add', message: commandArgs
  Handlers =
    Add: (args)-> t.equal args, commandArgs, "command handler was invoked with command arguments"

  flow = Flow(commands: Commands, commandHandlers: Handlers)

  flow.dispatch Commands.Add()

  t.end()
