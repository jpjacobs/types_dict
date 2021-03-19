NB. tests for types/dict class
require '~/addons/types/dict/dict.ijs'

NB. tests
test=: 3 : 0
  nd=. conew&'dict'
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
  destroy__d ''
  echo 'all tests ran without errors'
)

bench =: 3 : 0
num =: 1000000 NB. number of entries
nk  =: 10000   NB. number to retrieve
d0 =: 'dict' conew~ (i.num);i. num
d1 =: 'dict' conew~ (?~num);i. num
d2 =: 'dict' conew~ (sym=. s: <@":"0 i. num);i. num          NB. symbol linear
d3 =: 'dict' conew~ ((?~num){ sym);i. num                    NB. symbol scrambled
NB. bench get
echo 'Benchmark get ',(":nk),' items from ',":num
echo 1000&timespacex&> 'get__d0 nk ?@$ num';'get__d1 nk ?@$ num';'get__d2 keys__d2{~nk?@$ num';'get__d3 keys__d3{~nk?@$ num'
NB. bench get inv
echo 'Benchmark get ',(":nk),' items from ',":num
echo 100&timespacex&> 'get__d0 inv nk ?@$ num';'get__d1 inv nk ?@$ num';'get__d2 inv nk?@$ num';'get__d3 inv nk?@$ num'
destroy__d0''
destroy__d1''
destroy__d2''
destroy__d3''
)
test ''
