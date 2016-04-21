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
      Promise.resolve cache[aggregateId]
    else
      Promise.resolve(eventStore.getEvents()).then (events) -> _load aggregateId, events

  remove = (aggregateId) ->
    load(aggregateId).then ({state}) ->
      if state? is false
        Promise.reject "Could not load aggregate with id of #{aggregateId}"
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
