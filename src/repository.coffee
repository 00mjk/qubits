Event = require('./event')

module.exports = (aggregateName, Aggregate, eventStore) ->
  aggregateName = aggregateName.trim()
  cache = {}

  add = (attrs) ->
    agg = Aggregate(Object.assign({}, attrs))
    cache[agg.id] = agg
    state = Object.assign({}, agg.state)
    Event(name: "#{aggregateName}CreatedEvent", aggregateId: agg.id, state: state, payload: attrs)

  load = (aggregateId) ->
    if cache[aggregateId]
      cache[aggregateId]
    else
      toReturn = null
      eventStore.getEvents().reverse().some (event) ->
        if event.aggregateId is aggregateId
          if (event.name is "#{aggregateName}DeletedEvent")
            toReturn = null
          else
            agg = Aggregate(Object.assign(id: aggregateId, event.state))
            cache[aggregateId] = agg
            toReturn = agg
          return true
      toReturn

  _delete = (aggregateId) ->
    {state} = load(aggregateId)
    event = Event(name: "#{aggregateName}DeletedEvent", aggregateId: aggregateId, state: state)
    delete cache[aggregateId]
    event

  properties =
    add:
      value: add
    load:
      value: load
    delete:
      value: _delete

  Object.defineProperties {}, properties
