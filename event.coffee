deepAssign = require './deepAssign'

module.exports = ({aggregateId, name, payload}) ->
  event =
    name: name
    aggregateId: aggregateId
    payload: Object.freeze(deepAssign {}, payload)
  Object.freeze event
