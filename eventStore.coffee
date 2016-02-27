module.exports = ->
  events = []

  properties =
    add:
      value: (event) ->
        events.push event
    getEvents:
      value: -> events.slice()

  Object.defineProperties {}, properties
