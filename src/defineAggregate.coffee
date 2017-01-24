assign = require './deepAssign'

module.exports = ({name, idGenerator, state, methods}) ->
  name ?= 'Aggregate'
  factory = (attrs) ->
    instanceId = null
    if idGenerator? is false
      if !!attrs.id is false
        throw new Error("An id must be provided when creating an instance of #{name}")
      else
        instanceId = attrs.id
        delete attrs.id
    else
      instanceId = attrs.id ? idGenerator()
    instanceState = assign {}, state, attrs
    aggregate = Object.defineProperty {}, 'state', value: instanceState
    for name, fn of methods
      Object.defineProperty aggregate, name, value: fn
    Object.defineProperty aggregate, 'id', value: instanceId

  factory.__aggregate_name__ = name.trim()
  factory
