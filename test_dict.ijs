NB. tests for types/dict class
NB. require '~/addons/types/dict/dict.ijs'
NB. - limitation of unittest: no way of requiring an error.
NB.   workaround: use assert 0 under line that should have triggered error.

NB. tests single dict
before_all=: load@'dict.ijs'"_
before_each=: 3 : 0
  d=: dict 'abc'; 1 2 3 NB. simple dict of rank 0 literal&number
  NB. set of compatible sym/list dicts
  a1=: dict (s: ' foo bar a b');i. 4 3
  a2=: dict (s: ' abc def a b');100 *i. 4 3 
  NB. complicated shape keys and values
  b =: dict (i. 5 2 3);(-i. 5 4)
  rank0a=: dict 'a';1 NB. create dict with rank 0 keys/vals
  rank0b=: dict 'a';1 NB. create dict with rank 0 keys/vals
)
after_each=: 3 : 0 NB. cleanup
  destroy__d''
  destroy__a1''
  destroy__a2''
  destroy__b''
  destroy__rank0a''
  destroy__rank0b''
)
test_creation_getk_getv=: 3 : 0
  assert 1-:getv__d 'a'
  assert 3 1 2 -: getv__d 'cab'
  assert 0=0{get_ready__d NB. shouldn't be ready before getk call
  assert 'a' -:getk__d 1
  assert 1=0{get_ready__d NB. afterwards, it should.
  assert 'cab'-:getk__d 3 1 2
  'b' set__rank0a 2   NB. should allow extension by one
  'abc' set__rank0b 1 2 3 NB. should also allow multi-insert
)
test_set=: 3 : 0
  assert 'a'-: getk__d 1 NB. just to get getk_ready = 1
  'd' set__d 100         NB. add d
  assert 0=0{get_ready__d NB. should be reset
  assert 100-:getv__d 'd'NB. check d
  assert keys__d -: 'abcd' NB. check keys
  'd' set__d 1000        NB. set d to 1000
  assert keys__d -: 'abcd' NB. should not add extra d
  set__d 'a'             NB. delete a
  assert 0=get_ready__d NB. should be reset by set
  assert keys__d -: 'bcd'NB. a should have been removed
  assert vals__d -: 2 3 1000 NB. together with its value
  'bc' set__d _20 _30    NB. redefine multiple
  assert keys__d -: 'bcd'
  assert vals__d -: _20 _30 1000
  'xy' set__d _40 _50    NB. create multiple
  assert keys__d -: 'bcdxy'
  assert vals__d -: _20 _30 1000 _40 _50
  'cz'set__d 11 99       NB. mixed create/redefine
  assert keys__d -: 'bcdxyz'
  assert vals__d -: _20 11 1000 _40 _50 99
)
NB. test datatype agreement
dataTypeKeys_expect=:'domain error'
test_dataTypeKeys =: 3 : 0
NB. test datatype agreement check for keys
NB. for now, no explicit check present, nor needed
  1 set__d 111
  assert 0 NB. trigger error if we made it through
)
dataTypeVals_expect=:'domain error'
test_dataTypeVals =: 3 : 0
NB. test datatype agreement check for values
  'a' set__d 'X'
  assert 0 NB. trigger error if we made it through
)

NB. test shape agreement
test_shapeOK =: 3 : 0
  NB. elements can be list of items 
  (s:<'hello') set__a1 22 33 44 NB. rank 0, 1 into rank 0, 1
  assert 1=#@$keys__a1
  assert 2=#@$vals__a1
  (s:' foo') set__a1 i. 1 3 NB. rank 1,2 into rank 0, 1
  assert 1=#@$keys__a1
  assert 2=#@$vals__a1
  (s: ' foo bar') set__a2 i. 2 3
)
shapeNOK1_expect =: 'length error'
test_shapeNOK1 =: 3 : 0
  error=: 0 0$13!:8&>~/@[^:(0 e. ])
  (9;'length error: foo bar') error 0
  NB. keys <-> values mismatch
  (s:' foo bar') set__a1 i. 3 3 NB. expected $ 2 3
  map__a1''
  assert 0 NB. trigger error if we made it through
)


NB. tests for inter-dict ops
NB. joink/joinv/intersect/...
NB. key/val agreement
NB. results
Note 'test2 =: 3 : 0'
a=. dict 
b=. dict
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
