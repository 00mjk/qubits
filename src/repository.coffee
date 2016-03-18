Event = require('./event')

module.exports = (aggregateName, Aggregate, eventStore) ->
  cache = {}

  properties =
    add:
      value: (attrs) ->
        agg = Aggregate(Object.assign({}, attrs))
        cache[agg.id] = agg
        state = Object.assign({}, agg.state)
        Event(name: "#{aggregateName.trim()}CreatedEvent", aggregateId: agg.id, state: state, payload: attrs)
    load:
      value: (id) ->
        if cache[id]
          cache[id]
        else
          toReturn = null
          eventStore.getEvents().reverse().some (event) ->
            if event.aggregateId is id
              agg = Aggregate(Object.assign(id: id, event.state))
              cache[id] = agg
              toReturn = agg
              return true
          toReturn

  Object.defineProperties {}, properties
