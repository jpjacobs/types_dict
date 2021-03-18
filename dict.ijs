NB. Dict class for J
NB. D=: 'dict'conew~ keys;vals creates new dictionary object
NB. dict_z_ keys;vals (shortcut for the above)
NB.   keys and values can be any boxable type, but should be rectangular
NB.   as keys and values are stored each in a single array.
NB.   Otherwise, use sybmbolss (fast) or boxes (slower).
NB. Methods:
NB.   get/set support lists of keys/values (in case of set of equal length)
NB. get__D y     gets the value corresponding to key y from D
NB. get__D inv y gets the first key corresponding to value y from D
NB. set__D y     deletes key y and corresponding value from D
NB. x set__D y   sets key x to value y (creates/updates as needed)
NB. map__D ''    pretty print dictionary
NB. sort__D y    sorts D by key (k/K) or value (v/V), lower being ascending

coret=. coname'' NB. restore after definition
coclass 'dict'
NB. invertible lookup (first match)
lu=: 2 : '(m{~n&i. ) :. (n{~m&i.)'
NB. TODO don't work, define before use
NB. define helpers for symbol keys
NB. gets=: get@s:
NB. sets=: (set~s:)~

NB. create makes initial dict; expects boxed keys;vals
create=: 3 : 0
'y must be boxed' assert 32=3!:0 y
'y must have 2 items' assert 2=#y
'keys and values must have same lenght' assert =/ #&>y
'keys vals'=:y
echo^:(+./-.~:keys) 'warning: non unique keys are not retrievable'
get=: vals lu keys
0 0$0
)
NB. set verb 
NB.   monad removes key y; 
NB.   dyad updates keys;vals to
NB.    include new key x with val y
NB.   (both recreate get verb)
set=: 3 : 0
id=. <<<keys i. y NB. triple boxed indices to { remove them
'keys vals'=: keys ;&(id&{) vals
get=: vals lu keys NB. update lookup
0 0$0
:
NB. s indicates new keys to be added
s=.(#keys)=id=.keys i. x
keys=: keys,(s#x) NB. add new keys
vals=: (y#~-.s)(id#~-.s)}vals,(s#y)
NB. rebuild if needed, i.e. newly created keys present
if. +./s do. get=:vals lu keys end.
0 0$0
)

NB. map returns dict in easy display form, indicating dataypes as well
map =: 3 : 0
(datatype&.> , $&.> ,:]) keys ,&< &,.vals
)

NB. sort: sort dict by x e. 'kvKV'(default k)
NB.   k/v:keys/vals ascending
NB.   K/V:keys/vals descending
sort =: 3 : 0
a=.'kvKV'i.y
('unsupported sort: ',":y) assert a<4
s=. keys /:@[`(/:@])`(\:@[)`(\:@])@.a vals
'keys vals'=: keys ;&(s&{) vals
get=: vals lu keys
0 0$0
)
NB. restore orig. locale
cocurrent coret
NB. defines convenience shortcut in z locale
dict_z_ =: conew&'dict'
