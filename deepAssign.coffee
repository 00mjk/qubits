isObject = require 'is-plain-obj'

module.exports = deepAssign = (target, source) ->
  if not source?
    target
  else
    Object.keys(source).forEach (key) ->
      value = source[key]
      if isObject(value)
        target[key] = {}
        deepAssign target[key], value
      else
        target[key] = value
    target
