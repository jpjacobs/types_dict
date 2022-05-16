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
  bb=: dict (;:'foo a b c') ,&< <"0]i. 4 3 2 NB. test boxed
  srt=: dict (1 3 5 9 4 2);'COFFEE'
)
after_each=: 3 : 0 NB. cleanup
  destroy__d''
  destroy__a1''
  destroy__a2''
  destroy__b''
  destroy__rank0a''
  destroy__rank0b''
  destroy__bb''
)
test_creation_getk_getv=: 3 : 0
  assert 0 0-: get_ready__d
  assert 1-:getv__d 'a'
  assert 3 1 2 -: getv__d 'cab'
  assert 0=0{get_ready__d NB. shouldn't be ready before getk call
  assert 'a' -:getk__d 1
  assert 1=0{get_ready__d NB. afterwards, it should.
  assert 'cab'-:getk__d 3 1 2
  'b'   set__rank0a 2     NB. should allow extension by one
  'abc' set__rank0b 1 2 3 NB. should also allow multi-insert

  empty =. dict (i. 0 2 3) ,&< 0$a: NB. empty dict
  (i. 4 2 3) set__empty ;:'foo bar ;: 10' NB. should work as well
  destroy__empty''
  
  tt =. dict 'abcad';1 2 3 4 5 NB. test removal of double keys
  assert keys__tt-:'abcd'
  assert vals__tt-:1 2 3 5
)
createErr1_expect=: 'length error'
test_createErr1 =: 3 : 0
  f=. dict 'abc';1 2 NB. different length
  assert 0
)
createErr2_expect=: 'domain error'
test_createErr2 =: 3 : 0
  f=. dict 1 2 NB. y not boxed
  assert 0
)
createErr3_expect=: 'domain error'
test_createErr3 =: 3 : 0
  f=. dict 'abc';'def';1 2 3 NB. y not boxed
  assert 0
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

test_getPadding =: 3 : 0
assert (getv__d -: '' getv__d ])'ab' NB. '' should be default, and mean no pad
assert  1 _ 3 -: _ getv__d 'axc'   NB. pad should replace absent key
assert  1 0 3 -: a: getv__d 'axc'  NB. non-matching defaults to fill
assert  1 _ 3 -: _ 66 getv__d 'axc' NB. should take first pad
assert  1 0 3 -: (i. 3 3) getv__d 'axc' NB. should take first pad of ravel

assert (getk__d -: '' getk__d ]) 1 3 NB. '' should be default, and mean no pad
assert  'aXc' -: 'X' getk__d 1 10 3   NB. pad should replace absent key
assert  'a c' -: a: getk__d 1 10 3  NB. non-matching defaults to fill
assert  'aXc' -: 'XY' getk__d 1 10 3 NB. should take first pad
assert  'aXc' -: (3 3$'XABCDEFGH') getk__d 1 10 3 NB. should take first pad of ravel
)
getError_expect=: 'index error'
test_getError =: 3 : 0
'' getv__d 'abX' NB. should throw index error since absent key and no pad
assert 0
)

NB. test datatype agreement
setDataTypeKeys_expect=:'domain error'
test_setDataTypeKeys =: 3 : 0
NB. test datatype agreement check for keys
NB. for now, no explicit check present, nor needed
  1 set__d 111
  assert 0 NB. trigger error if we made it through
)
setDataTypeVals_expect=:'domain error'
test_setDataTypeVals =: 3 : 0
NB. test datatype agreement check for values
  'a' set__d 'X'
  assert 0 NB. trigger error if we made it through
)

NB. test shape agreement
test_setShapeOK =: 3 : 0
  NB. elements can be list of items 
  (s:<'hello') set__a1 22 33 44 NB. rank 0, 1 into rank 0, 1
  assert 1=#@$keys__a1
  assert 2=#@$vals__a1
  (s:' foo') set__a1 i. 1 3 NB. rank 1,2 into rank 0, 1
  assert 1=#@$keys__a1
  assert 2=#@$vals__a1
  (s: ' foo bar') set__a2 i. 2 3
)
setShapeNOK1_expect =: 'length error'
test_setShapeNOK1 =: 3 : 0
  NB. keys <-> values mismatch
  (s:' foo bar') set__a1 i. 3 3 NB. expected $ 2 3
  map__a1''
  assert 0 NB. trigger error if we made it through
)
test_clone =: 3 : 0
  a=. clone__d''
  assert a ~: d NB. should be a different dict
  assert (keys__a -: keys__d), vals__a -: vals__d
  destroy__a''
)

test_eq =: 3 : 0
  assert eq__d d NB. should be self-equal
  assert eq__b b,b NB. should work on array of dict
  assert -. eq__b d NB. should not equal
  assert 0 1-: eq__b d,b
  NB. modify b and check
  bb=. clone__b ''
  keys__bb=: |.keys__bb NB. revers k/v
  vals__bb=: |.vals__bb
  assert 0 eq__b bb NB. equal but for sort
  assert eq__b bb   NB. equal but for sort (monad)
  assert -. 1 eq__b bb NB. not strictly equal
  vals__bb=:|.vals__bb NB. reverse only V, break link
  assert -. 0 eq__b bb NB. also not tolerantly equal.
  destroy__bb''
)

test_sort =: 3 : 0
  NB. test non-inplace sorting
  bb =. clone__srt''
  a=. sort__srt 'K' NB. sort in opposite order
  assert a ~: srt   NB. should return new dict
  assert eq__a srt  NB. same entries?
  assert (i.#keys__a)-:\:keys__a NB. keys sorted down?
  b=. 1 sort__srt 'v' NB. sort vals in place
  assert b=srt      NB. should return ref to same dict
  assert (i.#vals__b)-:/:vals__b NB. vals sorted?
  1 sort__b 'k'     NB. sort keys up
  assert (i.#keys__b)-:/:keys__b NB. keys sorted up?
  1 sort__b 'V'    
  assert (i.#vals__b)-:\:vals__b NB. vals sorted down?
)
