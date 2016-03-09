Event = require('./event')

module.exports = function(aggregateName, Aggregate, eventStore) {
  var cache = {}

  properties = {
    add: {
      value: function(attrs) {
        var agg = Aggregate(Object.assign({}, attrs))
        cache[agg.id] = agg
        var state = Object.assign({}, agg.state)
        return Event({ name: aggregateName + "CreatedEvent", aggregateId: agg.id, state: state, payload: attrs })
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
