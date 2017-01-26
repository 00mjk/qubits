Event = require('./event')
assign = require './deepAssign'

module.exports = (Aggregate, eventStore, aggregateName=undefined) ->
  aggregateName ?= Aggregate.__aggregate_name__
  cache = {}

  _load =  (aggregateId, events) ->
    relevantEvents = events.filter((event) -> event.aggregateId is aggregateId)
    if relevantEvents.length is 0 or relevantEvents.find(({name}) -> name is "#{aggregateName}DeletedEvent")
      return null
    else
      createdEvent = relevantEvents.splice(0, 1)[0]
      agg = Aggregate(assign(id: aggregateId, createdEvent.payload))
      relevantEvents.forEach (event) ->
        Aggregate.__sourcing_methods__[event.name](event.payload, agg)
      cache[aggregateId] = agg
      return agg

  add = (attrs) ->
    agg = Aggregate(assign({}, attrs))
    cache[agg.id] = agg
    Event(name: "#{aggregateName}CreatedEvent", aggregateId: agg.id, payload: attrs)

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
      delete cache[aggregateId]
      Promise.resolve(Event(name: "#{aggregateName}DeletedEvent", aggregateId: aggregateId, payload: {}))

  properties =
    add:
      value: add
    load:
      value: load
    delete:
      value: remove

  Object.defineProperties {}, properties
