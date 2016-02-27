module.exports = function(aggregateName, Aggregate, eventStore) {
  var cache = {}

  properties = {
    add: {
      value: function(state) {
        var agg = Aggregate(state)
        cache[agg.id] = agg
        eventStore.add({ name: aggregateName + "CreatedEvent", aggregateId: agg.id, payload: agg.state })
        return agg
      }
    }
  }

  return Object.defineProperties({}, properties)
}
