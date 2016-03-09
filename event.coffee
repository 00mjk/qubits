deepAssign = require './deepAssign'

module.exports = ({aggregateId, name, payload, state}) ->
  event =
    name: name
    aggregateId: aggregateId
    payload: Object.freeze(deepAssign({}, payload))
    state: Object.freeze(deepAssign({}, state))
  Object.freeze event
