Event = require('./event')
assign = require './deepAssign'

module.exports = (Aggregate, eventStore, aggregateName=undefined) ->
  aggregateName ?= Aggregate.__aggregate_name__
  cache = {}

  _load =  (aggregateId, events) ->
    loaded = null
    events.reverse().some (event) ->
      if event.aggregateId is aggregateId
        if event.name isnt "#{aggregateName}DeletedEvent"
          agg = Aggregate(assign(id: aggregateId, event.state))
          cache[aggregateId] = agg
          loaded = agg
        return true
    loaded

  add = (attrs) ->
    agg = Aggregate(assign({}, attrs))
    cache[agg.id] = agg
    state = assign({}, agg.state)
    Event(name: "#{aggregateName}CreatedEvent", aggregateId: agg.id, state: state, payload: attrs)

  load = (aggregateId) ->
    if agg = cache[aggregateId]
      Promise.resolve agg
    else
      new Promise (resolve, reject) ->
        Promise.resolve(eventStore.getEvents()).then (events) ->
          if aggregate = _load aggregateId, events
            resolve(aggregate)
          else reject()

  remove = (aggregateId) ->
    load(aggregateId).then (agg) ->
      if not agg.state?
        Promise.reject "Could not load aggregate with id of #{aggregateId}"
      delete cache[aggregateId]
      Promise.resolve(Event(name: "#{aggregateName}DeletedEvent", aggregateId: aggregateId, state: agg.state, payload: {}))

  properties =
    add:
      value: add
    load:
      value: load
    delete:
      value: remove

  Object.defineProperties {}, properties
