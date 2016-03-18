test = require 'tape'
deepAssign = require '../deepAssign'

test "deep assign", (t) ->
  original =
    name: 'akonwi'
    stuff:
      more:
        age: 22

  copy = deepAssign {}, original

  t.deepEqual original, copy, "objects are equal without changes"
  copy.name = 'jerry'
  copy.stuff.more.age = '23'

  t.notDeepEqual original, copy, "objects are different after one changes"
  t.end()
