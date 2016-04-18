Event = require('./event')

module.exports = (aggregateName, Aggregate, eventStore) ->
  aggregateName = aggregateName.trim()
  cache = {}

  _load =  (aggregateId, events) ->
    loaded = null
    events.reverse().some (event) ->
      if event.aggregateId is aggregateId
        if (event.name is "#{aggregateName}DeletedEvent")
          loaded = null
        else
          agg = Aggregate(Object.assign(id: aggregateId, event.state))
          cache[aggregateId] = agg
          loaded = agg
        return true
    loaded

  add = (attrs) ->
    agg = Aggregate(Object.assign({}, attrs))
    cache[agg.id] = agg
    state = Object.assign({}, agg.state)
    Event(name: "#{aggregateName}CreatedEvent", aggregateId: agg.id, state: state, payload: attrs)

  load = (aggregateId) ->
    if cache[aggregateId]
      return cache[aggregateId]
    else
      _events = eventStore.getEvents()
      if _events.then?
        return _events.then (events) -> _load aggregateId, events
      else
        return _load aggregateId, _events

  remove = (aggregateId) ->
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
      value: remove

  Object.defineProperties {}, properties
