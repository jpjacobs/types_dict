NB. tests for types/dict class
require 'dict.ijs'

d=: nd 'abc';1 2 3
assert 1-:get__d 'a'
assert 3 1 2 -: get__d 'cab'
assert 'a' -:get__d inv 1
assert 'cab'-:get__d inv 3 1 2
'd' set__d 100
assert 100-:get__d 'd'
assert keys__d -: 'abcd'
set__d 'a'
assert keys__d -: 'bcd'
assert vals__d -: 2 3 100
'cx'set__d 11 99
assert 11 99-:get__d 'cx'
codestroy__d ''
echo 'all tests ran without errors'
)
