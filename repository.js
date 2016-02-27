Event = require('./event')

module.exports = function(aggregateName, Aggregate, eventStore) {
  var cache = {}

  properties = {
    add: {
      value: function(state) {
        var agg = Aggregate(Object.assign({}, state))
        cache[agg.id] = agg
        payload = agg.state || {}
        return Event({ name: aggregateName + "CreatedEvent", aggregateId: agg.id, payload: payload })
      }
    },
    load: {
      value: function(id) {
        return cache[id] || null
      }
    }
  }

  return Object.defineProperties({}, properties)
}
