module.exports = ->
  events = []
  eventBus = null

  updateEventBus = (event) -> eventBus?.publish?(event)

  properties =
    registerEventBus:
      value: (bus) -> eventBus = bus
    add:
      value: (event) ->
        console.log 'EventStore -- add ->', event
        events.push event
        updateEventBus event, eventBus
    getEvents:
      value: -> events.slice()

  Object.defineProperties {}, properties
