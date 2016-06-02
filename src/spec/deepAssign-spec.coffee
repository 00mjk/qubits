test = require 'tape'
deepAssign = require '../deepAssign'

test "deep assign", (t) ->
  original =
    foo: 'bar'
    baz:
      boom: 'flip'
    nested:
      array: [1]

  copy = deepAssign {}, original
  t.deepEqual original, copy, "objects are equal without changes"

  original.nested.array = [2]
  t.notDeepEqual original, copy, "arrays are different after changes"

  copy = deepAssign {}, original
  original.foo = 'baz'
  t.notDeepEqual original, copy, "foo values are different after changes"

  copy = deepAssign {}, original
  original.baz.boom = 'flop'
  t.notDeepEqual original, copy, "baz values are different after changes"
  t.end()

test "deep assign with multiple sources", (t) ->
  original =
    name: 'akonwi'
  another =
    age: 22

  t.deepEqual {name: 'akonwi', age: 22}, deepAssign({}, original, another)
  t.end()
