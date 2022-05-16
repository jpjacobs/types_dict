NB. tests for 2 or more dicts
before_all=: load@'dict.ijs'
before_each =: 3 : 0
NB. set up and destroy test dictionaries
a=: dict 'abc';1 2 3 */ 10 100
b=: dict 'bcd';4 5 6 */ 1000 10000
c=: dict 'bef';4 5 6 */ _1 _2
d=: dict 'bd' ;1 _1
l=: dict 'adc'; 3 5$'hellogreatworld!'
)
after_each =: 3 : 0
destroy__a''
destroy__b''
destroy__c''
destroy__d''
)
NB. test dictionary equality
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
NB. actual tests inter-dict ops:
NB. merge (i.e. join/update keys)
test_merge=: 3 : 0
  f=. merge__a b
  assert keys__f-:'abcd'
  assert vals__f-:10 100,4 5 6*/1000 10000
  NB. multi-dict merge
  h=: merge__a b,c
  assert keys__h-:'abcdef'
  assert vals__h-: 10 100,_4 _8,5000 50000,6000 60000,(5 6*/_1 _2) 
  NB. in-place merge
  g=. 1 merge__a b
  assert g=a
  assert keys__g-:'abcd'
  assert vals__g-:10 100,4 5 6*/1000 10000
  destroy__f''
  NB. destroy__g'' don't, since now a=f
  destroy__h''
)
NB. NOTE: no need for incompatible shape error checking, done in set
mergeNoComp_expect=: 'domain error'
test_mergeNoComp =: 3 : 0
  r=. merge__a d 
  assert 0
)
NB. appl  (i.e. apply u between values with matching keys)
test_applMonad =: 3 : 0
  NB. monadic apply, y=''
  b=. +: appl__a ''
  assert keys__b-:  keys__a
  assert vals__b-:+:vals__a
  c=. , appl__a ''
  assert vals__c-: ,"_1 vals__a NB. should do u"_1
  c=. 0 +: appl__a '' NB. x ignored in "monad" case
  d=. 1 +: appl__a ''
  e=. ''+: appl__a ''
  assert 1 eq__c d,e
  assert a~:c,d,e
  ls =. ([: +/ a.&i.) appl__l ''
  assert 532 531 582 getv__l 'acd' 
  destroy__b''
  destroy__c''
  destroy__d''
  destroy__e''
  destroy__ls''
)

test_applInsert =: 3 : 0
   aa=. ,appl__a b NB. ,/ intersect&combine 2 dicts
   aa2=. '' ,appl__a b NB. '' means intersect
   assert 1 eq__aa aa2 NB. should be identical
   assert aa~:a,b,aa2 NB. should make new dict
   assert keys__aa -: keys__a ([-.-.) keys__b
   assert vals__aa -: (getv__a 'bc') ,"_1 getv__b'bc'
   NB. sum between items of a and b, with 0 filling
   sum1=. 0  + appl__a b NB. sum, union with 0 filling
   sum2=. a: + appl__a b NB. sum, union with 0 filling
   assert 1 eq__sum1 sum2 NB. 0 and a: are same for num
   assert keys__sum1-: 'abcd' NB. union
   assert vals__sum1-: (a:&getv__a + a:&getv__b) 'abcd'
   NB. extends more dicts: product of values with fills
   prod=. 0 *appl__a,b,c
   assert keys__prod -: 'abcdef'
   assert vals__prod -: 0 0, _320000 _64000000,4#(,:0 0)
   NB. cross-type op
   txt=. ([,': ',":@]) appl__l a
   assert 'literal'-:datatype vals__txt
   assert keys__txt -: 'ac'
   assert vals__txt -: ];._1 '|hello: 10 100|world: 30 300'
   NB. destroy junk
   destroy__aa''
   destroy__aa2''
   destroy__sum1''
   destroy__sum2''
   destroy__prod''
   destroy__txt''
)
