NB. tests for types/dict class
NB. require '~/addons/types/dict/dict.ijs'

NB. tests
test=: 3 : 0
  d=: dict 'abc';1 2 3
  assert 1-:gf__d 'a'
  assert 3 1 2 -: gf__d 'cab'
  assert 'a' -:gb__d 1
  assert 'cab'-:gb__d 3 1 2
  'd' set__d 100            NB. gb not used furtheron; updaterev'' not called.
  assert 100-:gf__d 'd'
  assert keys__d -: 'abcd'
  set__d 'a'
  assert keys__d -: 'bcd'
  assert vals__d -: 2 3 100
  'cx'set__d 11 99
  assert 11 99-:gf__d 'cx'
  destroy__d ''
  echo 'all tests ran without errors'
)

bench =: 3 : 0
num =: 1000000 NB. number of entries
nk  =: 10000   NB. number to retrieve
d0 =: dict (i.num);i. num
d1 =: dict (?~num);i. num
d2 =: dict (sym=. s: <@":"0 i. num);i. num          NB. symbol linear
d3 =: dict ((?~num){ sym);i. num                    NB. symbol scrambled
NB. bench get
echo 'Benchmark get ',(":nk),' items from ',":num
echo 1000&timespacex&> 'gf__d0 nk ?@$ num';'gf__d1 nk ?@$ num';'gf__d2 keys__d2{~nk?@$ num';'gf__d3 keys__d3{~nk?@$ num'
destroy__d0''
destroy__d1''
destroy__d2''
destroy__d3''
)
echo'Don''t forget to load dicts; run test'''' or bench'''''
