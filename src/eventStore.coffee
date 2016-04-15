module.exports = (overrides={})->
  events = []

  add = (event) -> events.push event
  getEvents = -> events.slice()

  properties =
    add:
      value: overrides.add || add
    getEvents:
      value: overrides.getEvents || getEvents

  Object.defineProperties {}, properties
