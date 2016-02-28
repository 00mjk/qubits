Event = require('./event')

module.exports = function(aggregateName, Aggregate, eventStore) {
  var cache = {}

  properties = {
    add: {
      value: function(state) {
        var agg = Aggregate(Object.assign({}, state))
        cache[agg.id] = agg
        var payload = agg.state || {}
        return Event({ name: aggregateName + "CreatedEvent", aggregateId: agg.id, payload: payload })
      }
    },
    load: {
      value: function(id) {
        if (cache[id])
          return cache[id]
        else {
          var toReturn = null
          eventStore.getEvents().reverse().some(function(event) {
            if (event.aggregateId === id) {
              var agg = Aggregate(Object.assign({id: id}, event.payload))
              cache[id] = agg
              toReturn = agg
              return true
            }
          })
          return toReturn
        }
      }
    }
  }

  return Object.defineProperties({}, properties)
}
