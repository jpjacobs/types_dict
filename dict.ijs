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
--------------------
x getv__D y      gets the value corresponding to key y from D
x getk__D y      gets the first key corresponding to value y from D
                 getk and getv take as optional x a padding value for use when a
                 key is not found (see below).
  set__D y       deletes key y and corresponding value from D
x set__D y       sets key x to value y (creates/updates as needed)

get/set support lists of keys/values (in case of set of equal length)
Updates should respect the item size in the dictionary. Creation of empty
dictionaries is supported, but they should be created with the right item size
and type, e.g. e=: dict (0$'a'); i. 0 2 3 .
Of course, you can always use the keys and values fields directly, e.g.
vals__D #/. keys__D If keys or values in D are altered manually, trigger
getk/getv rebuild with: get_ready=:0 0

  map__D ''      pretty print dictionary
x sort__D y      sorts D by key ('kK') or value ('vV'), lower case being
                 ascending. x is a flag for in-place sorting (defaults to 0)
  flip__D ''     exchange keys <-> values; returns new dict
  clone__D ''    clone a dictionary to a new object; returns new dict

Padding element:
--------------------
If x is '' (default when no x), an index error is thrown when a key or value in
y is not in the dictionary.  When x is compatible datatype (i.e. vals,#{.x does
not error, or the same for keys) its first element is used as padding element.
Otherwise, the default padding element (e.g. 0 for numbers) is used. 

Multi-dictionary Methods:
--------------------
x eq__D y        Equality of D with y, by default (x=0), the order of entries is
                 ignored; when x=1, strict comparison is used, i.e. dicts with
                 same entries, but sorted differently are not the same.
x merge__D y     join D with dictionaries in y by merging keys (last survives),
                 in-place if x=1
                 Notes:
                  - if a value is present in the current (or new) it's
                    *overwritten* by the ones in the others (in order) (could
                    be optimised).
                  - if joining multiple dicts in place, if one dict joined is
                    not compatible, fails, and leaves the original dict
                    incomplete.
  u appl__D ''   apply u to each of the values in D (i.e. u"_1 vals) (x ignored
                 if present)
x u appl__D y    insert u between corresponding values in all dicts in D,y
                 appl__D always returns a new dictionary. x defines how
                 non-matching keys are handled:
                 - '' (default) : intersect the sets of  keys between all
                   dictionaries
                 - any other: make a union between sets of keys, with x used as
                   padding element, as for getk/getv.
                Note: gerund as u creates a result, but not as expected for /
                Could change in the future.

  u filtk__D y   filter D's keys, keeping entries where u key is 1. (like #). If y is '' or 0, returns a new dict, otherwise, operate in place.
  u filtv__D y   the same, filtering entries by value.

NYI:
  deepget        NYI: needed? would index into nested dictionaries, restricting 
  deepset        values to be boxed. Perhaps better as subclass.


)
NB. error helperverb (inspired by assert)
NB. takes x: errnum;msg
assertno =: 0 0$([ 13!:8~ ],~(LF,'|  '),~ (9!:8'') {::~ <:@[)&>/@[^:(0 e. ])

NB. TODO: NYI rethrow: use in catch to rethrow last error after cleanup.
NB. needed for wrapping adverbs below.

NB. linear display for map
lin =: 3 : '5!:5<''y'''

NB. create makes initial dict; expects boxed keys;vals
create=: 3 : 0
(3;'y must be boxed') assertno 32=3!:0 y
(3;'y must have 2 items') assertno 2=#y
(9;'keys and values must have same length') assertno =/ #&>y
NB. ensure at least rank 1; keys/values should be lists
'keys vals'=: ,^:(0=#@$)&.> y 
NB. wouldn't it be better to prune these to start with?
uk=. ~:keys
echo^:((+/uk)<#keys) 'warning: non unique keys: only first occurrences kept.'
keys=:uk#keys
vals=:uk#vals
0 0$get_ready=:0 0 NB. reset lookup ready flags
)
NB. set verb 
NB.   monad removes key y; 
NB.   dyad updates keys;vals to
NB.    include new key x with val y
NB.   (both recreate the get verb)
set=: 3 : 0
id=. <<<keys i. y NB. triple boxed indices to { remove them
'keys vals'=: keys ,&<&(id&{) vals NB. fails with index error if key not present.
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

NB. sort: sort dict by y e. 'kvKV'(default k)
NB.   k/v:keys/vals ascending
NB.   K/V:keys/vals descending
NB. x: inplace (1) or not (0)
NB. returns reference to the dictionary that is sorted
NB. TODO: generalise to sorting on function applied
NB. x u sortedby 'kKvV', which would render sort superfluous ( would become
NB. ]sortedby)
sort =: 4 : 0(0&$: :)
a=.'kvKV'i.y
(3;'unsupported sort: ',":y) assertno a<4
s=. keys /:@[`(/:@])`(\:@[)`(\:@])@.a vals
nkv=. keys (,&<)&(s&{) vals
if. x do. 
  'keys vals'=: nkv
  r=. coname''
else.
  r=.dict nkv
end.
0 0$get_ready=:0 0 NB. reset lookup ready flags
r
)
NB. update reverse lookup getkint only when getk is called if it's not ready.
NB.  create and set clear this flag, assuming values being changed.
NB. if x is '' (or other empty value): no padding for missed keys: length error instead
NB. if x is not empty, the first element of its ravel is used as padding element, if it is compatible with the type of vals (i.e. vals,{.,x does not result in an error), otherwise, the default padding element for vals' datatype will be used. This allows use of e.g. a: as meaning: pad with whatever is appropriate.
getk =: (4 : 0) (''&$: :) NB. monadic default x=''
if. -.0{get_ready do.
  valsi=: vals&i. NB. update internal version of getk
  get_ready=:1 0+.get_ready
end.
if. #x do.  NB. no padding el given
  NB. index keys padded with x (if matchrng datatype, or default pad for type)
  x=. {.,x NB. ensure x is atom
  (valsi y){keys(, :: (>:@#@[{.[))x NB. index padded keys
else.
  keys{~valsi y NB. could yield index error
end.
)

NB. the same for getv
getv =: (4 : 0) (''&$: :) NB. monadic default x=''
if. -. 1{get_ready do.
  keysi=: keys&i. NB. update internal version of getv
  get_ready=:0 1+.get_ready
end.
if. #x do.  NB. padding el given
  x=. {.,x NB. ensure x is atom
  NB. index vals padded with x (if matchrng datatype, or default pad for type)
  (keysi y){vals(, :: (>:@#@[{.[))x NB. index padded keys
else.
  vals{~keysi y NB. could yield index error
end.
)

NB. merge: join dicts y (as boxed locale numbers, use "," to link boxed number locales, not ";") into this dictionary, on keys, x inplace (1) or not. it returns the dict written to.
NB.  Notes:
NB. - if a value is present in the current (or new) it's *overwritten* by
NB.   the ones in the others (in order) (could be optimised).
NB. - if joining multiple dicts in place, if one dict joined is not compatible, fails, and leaves the original dict incomplete.
merge =: (4 : 0)(0&$: :) NB. monadic default x=0
if. -.x do.
  dest=. dict keys ,&< vals    NB. not in place: copy dict as dest
else. dest=. coname'' end. NB. in place: dest is *this* dict
for_od. y do. NB. for other dicts:
  try.
    keys__od set__dest vals__od
    NB. set might throw errors.
  catch.
    if. -. x do. NB. not in place. 
      destroy__dest ''
      dest=. a:
    end.
    (dberr dbsig dberm)'' NB. ugly rethrow
  end.
end.
dest
)

NB. no joining on values: This can be far more usefully extended to doing
NB. operations on dictionaries: as appl
NB. strangely enough, apply does not seem to execute in the dict objects locale... requires seriously odd fix below.
NB.  https://code.jsoftware.com/wiki/Vocabulary/Locales#Adverbs_in_Locales
NB. TODO: wrap in try-catch to return control to the right locale, and rethrow
NB. error.
appl =: (1 : 0)(''&$: :) NB. '' as default for monad.
  u appl_int (coname'')
)
appl_int =: 2 : 0
return_loc=. coname''
cocurrent n
NB. list of dict locales to operate on, self and those in args
ll=. (n),y
NB. intersect or union?
select. 1<#ll NB. monad or insert?
case. 0 do. NB. monad
  NB. keys don't change, apply u"_1 to vals
  r=. dict keys ,&< u"_1 vals
case. 1 do. NB. insert
  NB. case where x is 1 seems to be correct.
  op=. ([-.-.)`(~.@,)@.(#x) NB. intersection (x empty) or union
  nk=. keys
  for_od. }.ll do.
    nk=. nk op keys__od
  end.
  nv=.''
  for_od. ll do.
    NB. needs boxing; vals need not be congruous between dicts
    nv=. nv,<x getv__od nk
  end.
  NB. apply u on items between
  r=. dict nk ,&< > u"_1&.>/ nv
end.
cocurrent return_loc
r
)
NB. y indicates inplace (1) or not (0)
filtk =: 1 : 0
  u filtk_int (coname'')
)
filtk_int =: 2 : 0
return_loc=.coname''
cocurrent n
y=. {.y,0 NB. default to in place if y is empty
msk=. u keys
NB. TODO: check msk is boolean vector.
if. +./ msk -.@e. 0 1 do.
  cocurrent return_loc
  'result of u should be a boolean vector' assert 0
end.
nkv=. keys ,&<&(msk&#) vals
if. y do. NB. in-place?
  'keys vals'=: nkv
  get_ready =: 0 0
  r=. coname''
else.
  r=. dict nkv
end.
cocurrent return_loc
r
)
NB. y indicates inplace (1) or not (0)
filtv =: 1 : 0
  u filtv_int (coname'')
)
filtv_int =: 2 : 0
return_loc=.coname''
cocurrent n
y=. {.y,0 NB. default to in place if y is empty
msk=. u vals
NB. TODO: check msk is boolean vector.
if. +./ msk -.@e. 0 1 do.
  cocurrent return_loc
  'result of u should be a boolean vector' assert 0
end.
nkv=. keys ,&<&(msk&#) vals
if. y do. NB. in-place?
  'keys vals'=:nkv
  get_ready =: 0 0
  r=. coname''
else.
  r=. dict nkv
end.
cocurrent return_loc
r
)

NB. clone dict to new dict
clone=: 3 : 'dict_z_ keys ,&< vals'
NB. exchange keys and values
flip =: 3 : 'dict_z_ vals ,&< keys'

NB. dictionary equality
NB. x: strict (ordering as well, default 0, no ordering)
NB. y: list of dicts to compare with current
eq =: 4 : 0(0&$: :)
  NB. sort order of keys, depending on x
  sortk =. /:`#@.x keys 
  eql=.0 #~ #y
  for_ll. y do.
    if. x do. NB. key/val same sort!
      eqk=. keys-:keys__ll
      eqv=. vals-:vals__ll
    else.
      eqk=. (sortk{keys) -: keys__ll {~ skc=./:keys__ll
      eqv=. (sortk{vals) -: vals__ll {~ skc
    end.
    eql=.(eqk*.eqv) ll_index}eql
  end.
)

destroy=:codestroy

NB. defines convenience shortcut in z locale
dict_z_ =: conew&'pdict'
