NB. Dict class for J
coclass 'pdict'
NB. Help text
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

get/set support lists of keys/values (in case of set of equal length)

Of course, you can always use the keys and values fields directly, e.g.

vals__D #/. keys__D

If keys or values in D are altered manually, redefine get to update accordingly:
  getv__D=: vals__D luv__D keys__D

)

NB. invertible lookup (first match)
luv=: 1 : 'vals{~m&i.'
luk=: 1 : 'keys{~m&i.'
NB. TODO don't work, define before use
NB. define helpers for symbol keys
NB. gets=: get@s:
NB. sets=: (set~s:)~
NB. linear display for map
lin =: 3 : '5!:5<''y'''

NB. create makes initial dict; expects boxed keys;vals
create=: 3 : 0
'y must be boxed' assert 32=3!:0 y
'y must have 2 items' assert 2=#y
'keys and values must have same lenght' assert =/ #&>y
'keys vals'=:y
echo^:(+./-.~:keys) 'warning: non unique keys are not retrievable'
getv=: keys luv
0 0$getk_ready=:0
)
NB. set verb 
NB.   monad removes key y; 
NB.   dyad updates keys;vals to
NB.    include new key x with val y
NB.   (both recreate the get verb)
NB. TODO: doesn't work properly:
NB. - removing ++ keys (maybe only when 1<#$vals ?)
NB. - k set__d vals when 1<:#vals
set=: 3 : 0
id=. <<<keys i. y NB. triple boxed indices to { remove them
'keys vals'=: keys ;&(id&{) vals
getv=: keys luv 
0 0$getk_ready=:0 NB. reset reverse lookup ready flag, assuming vals ohanged
:
NB. check and fix y to conform to keys and vals
NB. i.e. rank of x and y should be _1 cell rank of keys and vals
assert. keys (}.@[ -: -@<:@#@[ {. ])&$ x NB. same trailing axes required
if. keys -&#&$ x do. x=. (($,)~ 1,$) x end.
assert. vals (}.@[ -: -@<:@#@[ {. ])&$ y NB. same trailing axes required
if. vals -&#&$ y do. y=. (($,)~ 1,$) y end.
NB. s is mask indicating missing keys to be added
s=.(#keys)=id=.keys i. x
keys=: keys,(s#x) NB. add new keys
vals=: (y#~-.s)(id#~-.s)}vals,(s#y) NB. TODO fix
NB. rebuild if needed, i.e. newly created keys present
if. +./s do.
  getv=:keys luv 
end.
0 0$getk_ready=:0 NB. reset reverse lookup ready flag, assuming vals ohanged
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
('unsupported sort: ',":y) assert a<4
s=. keys /:@[`(/:@])`(\:@[)`(\:@])@.a vals
'keys vals'=: keys ;&(s&{) vals
getv=: keys luv 
0 0$getk_ready=:0 NB. reset reverse lookup ready flag
0 0$0
)
NB. update reverse lookup getkint only when getk is called if it's not ready.
NB.  create and set clear this flag, assuming values being changed.
getk =: 3 : 0
if. -. getk_ready do.
  getkint=: vals luk NB. update internal version of getk
  getk_ready=:1
end.
getkint y
)

NB. joink: join dicts y (as boxed locale numbers) into this dictionary, on keys,ex inplace (1) or not. it returns the dict written to.
NB.  Notes:
NB. - if a value is present in the current (or new) it's *overwritten* by
NB.   the ones in the others (in order) (could be optimised).
NB. - if joining multiple dicts in place, if one dict joined is not compatible, fails, and leaves the original dict inconsistent.
joink =: 4 : 0
0 joink y NB. default create new dict
:
if. -.x do.
  dest=. dict keys;vals    NB. not in place: copy dict as dest
else. dest=. coname'' end. NB. in place: dest is this dict
for_od. y do. NB. for other dicts:
  try.
    assert. vals__dest -:&$ vals__od     NB. require same shape
    NB. strict datatype checking not good, would prevent e.g. 0 , 0j1
    NB. assert. vals__dest =&(3!:0) vals__od NB. require same datatype
    keys__od set__dest vals__od
  catch.
    ('shapes or types dn not match; joined up to dict ',(":od_index),' in y') assert 0
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
joinv =: 3 : 0
for_od. y do. keys__od set vals__od end.
)
destroy=:codestroy

NB. defines convenience shortcut in z locale
dict_z_ =: conew&'pdict'
