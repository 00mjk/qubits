module.exports = ({name, idGenerator, state, methods}={name: 'Aggregate'}) ->
  (attrs) ->
    instanceId = null
    if idGenerator? is false
      if !!attrs.id is false
        throw new Error("An id must be provided when creating an instance of #{name}")
      else
        instanceId = attrs.id
        delete attrs.id
    else
      if !!attrs.id
        throw new Error("An id generator has been already been provided for #{name}. Passing an id to the factory function isn't necessary")
      instanceId = idGenerator()
    instanceState = Object.assign {}, state, attrs
    aggregate = Object.defineProperty {}, 'state', value: instanceState
    for name, fn of methods
      Object.defineProperty aggregate, name, value: fn
    Object.defineProperty aggregate, 'id', value: instanceId
