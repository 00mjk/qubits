isObject = require 'is-plain-obj'

isArray = (object) -> '[object Array]' is Object.prototype.toString.call(object) ? true : false

module.exports = deepAssign = (target, sources...) ->
  if sources.length is 0
    target
  else
    sources.forEach (source) ->
      Object.keys(source).forEach (key) ->
        value = source[key]
        if isObject(value)
          target[key] = {}
          deepAssign target[key], value
        else if isArray(value)
          target[key] = value.slice()
        else
          target[key] = value
    target
