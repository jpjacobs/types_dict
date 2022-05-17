#   Dictionary class for J
## Introduction
[J](https://jsoftware.com) does not come with a dictionary type.
This addon tries to fill this gap by offering an [OOP](https://code.jsoftware.com/wiki/Vocabulary/ObjectOrientedProgramming) dictionary type for J.

## Features
- [Precomputed searches](https://code.jsoftware.com/wiki/Vocabulary/SpecialCombinations#Searching_and_Matching_Items:_Precomputed_searches): Lookup performance should be good
- normal and inverse lookups: both keys and values can be searched (For values, the key of the first matching value is returned). Search verbs are only updated (in the sense of binding `i.` with keys or values) when needed, upon first invocation of the corresponding get method.
- Any J data-type allowed for both keys and values, but it should be homogeneous and rectangular; sparse arrays not supported because they cannot be boxed.
  If non-homogeneous datatypes or non-rectangular data is absolutely necessary, use boxes, but performances will likely be worse.
- Updates lists of keys and values in one amend (should be as fast as can be).
- Updating and creating new keys in a single call.
- Methods for filtering by keys and values
- Inter-dictionary methods for: equality, merging by keys, applying verbs to each value, applying verbs between values for matching keys of two dictionaries.
- Unittests Tests for all functionality

**Limitations**:
- No nested dictionaries. As the dictionary is a J object, it cannot be simply placed inside another dictionary, as it is just a boxed number.
- Updating reverse precomputed lookup is done automatically when calling getk as needed. The first call can therefore be slower. When values change, it is scheduled for update at the next execution of getk.

## Installation
You can install this addon straigth from github with:
```j
    install'github:jpjacobs/types_dict@main'
```

### Usage
Also reachable as `help_pdict_` after loadin te addon.
```j
Create new dict:

D=: 'pdict'conew~ keys;vals creates new dictionary object
D=: dict keys;vals (shortcut in the z-locale for the above)

  Keys and values can be any boxable type, but should be rectangular
  as keys and values are stored each in a single array.
  Otherwise, use sybmbols (fast) or boxes (slower).

Single Dictionary Methods:
--------------------
x getv__D y      gets the value corresponding to key y from D
x getk__D y      gets the first key corresponding to value y from D
                 getk and getv take as optional x a fill value for use when a
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

  map__D ''      pretty print dictionary D
x sort__D y      sorts D by key ('kK') or value ('vV'), lower case being
                 ascending. x is a flag for in-place sorting (defaults to 0)
  flip__D ''     exchange keys <-> values; returns new dict
  clone__D ''    clone a dictionary to a new object; returns new dict
  u filtk__D y   filter D's keys, keeping entries where u key is 1. (like for #). If y is '' or 0, returns a new dict, otherwise, operate in place.
  u filtv__D y   the same, filtering entries by value.

Fill element:
--------------------
If x is '' (default when no x), an index error is thrown when a key or value in
y is not in the dictionary.  When x is compatible datatype (i.e. vals,#{.x does
not error, or the same for keys) its first element is used as fill element.
Otherwise, the default fill element (e.g. 0 for numbers) is used. 

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
                   fill element, as for getk/getv.
                Note: gerund as u creates a result, but not as expected for /
                Could change in the future.
```
