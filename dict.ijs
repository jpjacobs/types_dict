NB. Dict class for J
coclass 'pdict'
NB. Help text TODO: verify docs with current behaviour
help =: 0 : 0
Dictionary class for J
load 'types/dict/dict.ijs'

Create new dict:

D=: 'pdict'conew~ keys;vals creates new dictionary object
D=: dict keys;vals (shortcut in the z-locale for the above)

  Keys and values can be any boxable type, but should be rectangular
  as keys and values are stored each in a single array.
  Otherwise, use sybmbols (fast) or boxes (slower).

Dictionary Methods:
  getv__D y      gets the value corresponding to key y from D
  getk__D y      gets the first key corresponding to value y from D
  set__D y       deletes key y and corresponding value from D
x set__D y       sets key x to value y (creates/updates as needed)
  map__D ''      pretty print dictionary
  sort__D y      sorts D by key (k/K) or value (v/V), lower being ascending

Multi-dictionary Methods:
x joink__D y     join D with dictionaries in y by merging keys (last survives), in-place if x=1
x joinv__D y     NYI join D with dictionaries in y, in-place if x=1
x u filter__D y  NYI think through whats useful. feels like could be more general

get/set support lists of keys/values (in case of set of equal length)

Of course, you can always use the keys and values fields directly, e.g.

vals__D #/. keys__D

If keys or values in D are altered manually, trigger getk/getv rebuild with:
get_ready=:0 0

)
NB. error helperverb (inspired by assert)
NB. takes x: errnum;msg
assertno =: 0 0$([ 13!:8~ ],~(LF,'|  '),~ (9!:8'') {::~ <:@[)&>/@[^:(0 e. ])

NB. invertible lookup (first match)
luv=: 1 : 'vals{~m&i.'
luk=: 1 : 'keys{~m&i.'
NB. linear display for map
lin =: 3 : '5!:5<''y'''

NB. create makes initial dict; expects boxed keys;vals
create=: 3 : 0
(3;'y must be boxed') assertno 32=3!:0 y
(3;'y must have 2 items') assertno 2=#y
(9;'keys and values must have same length') assertno =/ #&>y
NB. ensure at least rank 1; keys/values should be lists
'keys vals'=: ,^:(0=#@$)&.> y 
echo^:(+./-.~:keys) 'warning: non unique keys are not retrievable'
0 0$get_ready=:0 0 NB. reset lookup ready flags
)
NB. set verb 
NB.   monad removes key y; 
NB.   dyad updates keys;vals to
NB.    include new key x with val y
NB.   (both recreate the get verb)
set=: 3 : 0
id=. <<<keys i. y NB. triple boxed indices to { remove them
'keys vals'=: keys ;&(id&{) vals NB. fails with index error if key not present.
0 0$get_ready=:0 0 NB. reset lookup ready flags, assuming keys and vals changed
:
NB. check and fix y to conform to keys and vals
NB. i.e. rank of x and y should be _1 cell rank of keys and vals
try. NB. check for shape agreements, error in catch.
  assert. keys (}.@[ -: }.@]^:(=&#))&$ x NB. same trailing axes required
  kfix=. (($,)~ 1,$)^:(keys -&#&$ x) x
  assert. vals (}.@[ -: }.@]^:(=&#))&$ y NB. same trailing axes required
  vfix=. (($,)~ 1,$)^:(vals -&#&$ y ) y
  NB. now kfix and vfix should have same number of items
  assert. kfix =&# vfix
catch.
  (9;'}.@$ of keys and values to be set should match those of the dictionary keys and values') assertno 0
end.
NB. s is mask indicating missing keys to be added
s=.(#keys)=id=.keys i. kfix
keys=: keys,(s#kfix) NB. add new keys
vals=: (vfix#~-.s)(id#~-.s)}vals,(s#vfix)
NB. invalidate getk, trigger getv rebuild if needed, i.e. newly created keys present
0 0$get_ready=:0 ,-.+./s
)

NB. map returns dict in easy display form, indicating dataypes as well
map =: 3 : 0
keys (;&datatype , ;&$ ,: ,&<&:(lin"_1)) vals
)

NB. sort: sort dict by x e. 'kvKV'(default k)
NB.   k/v:keys/vals ascending
NB.   K/V:keys/vals descending
sort =: 3 : 0
a=.'kvKV'i.y
(3;'unsupported sort: ',":y) assertno a<4
s=. keys /:@[`(/:@])`(\:@[)`(\:@])@.a vals
'keys vals'=: keys ;&(s&{) vals
0 0$get_ready=:0 0 NB. reset lookup ready flags
)
NB. update reverse lookup getkint only when getk is called if it's not ready.
NB.  create and set clear this flag, assuming values being changed.
getk =: 3 : 0
if. -.0{get_ready do.
  getkint=: vals luk NB. update internal version of getk
  get_ready=:1 0+.get_ready
end.
getkint y
)
NB. the same for getv
getv =: 3 : 0
if. -. 1{get_ready do.
  getvint=: keys luv NB. update internal version of getv
  get_ready=:0 1+.get_ready
end.
getvint y
)

NB. joink: join dicts y (as boxed locale numbers) into this dictionary, on keys,ex inplace (1) or not. it returns the dict written to.
NB.  Notes:
NB. - if a value is present in the current (or new) it's *overwritten* by
NB.   the ones in the others (in order) (could be optimised).
NB. - if joining multiple dicts in place, if one dict joined is not compatible, fails, and leaves the original dict inconsistent.
joink =: 3 : 0
0 joink y NB. default create new dict
:
if. -.x do.
  dest=. dict keys;vals    NB. not in place: copy dict as dest
else. dest=. coname'' end. NB. in place: dest is this dict
for_od. y do. NB. for other dicts:
  try.
    assert. vals__dest -:&}.&$ vals__od     NB. require same trailing shape
    NB. strict datatype checking not good, would prevent e.g. 0 , 0j1
    NB. assert. vals__dest =&(3!:0) vals__od NB. require same datatype
    keys__od set__dest vals__od
  catch.
    (9;'shapes do not match; joined up to dict ',(":od_index),' in y') assertno 0
    if. -. x do. NB. not in place. 
      destroy__dest ''
      dest=. a:
      break.
    end.
  end.
end.
dest
)

NB. joinv: join dicts y (as boxed locale numbers) into this dictionary, by catenating values
NB. TODO finish!
joinv =: 3 : 0
for_od. y do. keys__od set vals__od end.
)
destroy=:codestroy

NB. defines convenience shortcut in z locale
dict_z_ =: conew&'pdict'
