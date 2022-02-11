#   Dictionary class for J
## Introduction
[J](https://jsoftware.com) does not come with a dictionary type.
This addon tries to fill this gap by offering an [OOP](https://code.jsoftware.com/wiki/Vocabulary/ObjectOrientedProgramming) dictionary type for J.

## Features
- [Precomputed searches](https://code.jsoftware.com/wiki/Vocabulary/SpecialCombinations#Searching_and_Matching_Items:_Precomputed_searches): Lookup performance should be good
- normal and inverse lookups: both keys and values can be searched (For values, the key of the first matching value is returned).
- Any J data-type allowed for both keys and values, but it should be homogeneous and rectangular.
  If non-homogeneous datatypes or non-rectangular data is absolutely necessary, use boxes, but performances will likely be worse.
- Updates lists of keys and values in one amend (should be as fast as can be).
- Updating and creating new keys in a single call.

**Limitations**:
- No nested dictionaries. As the dictionary is a J object, it cannot be simply placed inside another dictionary, as it is just a boxed number.
- Updating reverse precomputed lookup is done automatically when calling getk as needed. The first call can therefore be slower. When values change, it is scheduled for update at the next execution of getk.

## Installation
You can install this addon straigth from github with:
```j
    install'github:jpjacobs/types_dict@main'
```

### Usage

```j
D=: 'dict'conew~ keys;vals    NB. creates new dictionary object
D=: dict keys;vals            NB. (shortcut in the z-locale for the above)
```
  Keys and values can be any boxable type, but should be rectangular
  as keys and values are stored each in a single array.
  Otherwise, use sybmbols (fast) or boxes (slower).

Dictionary Methods:
```j
  getv__D y      gets the value corresponding to key y from D
  getk__D y      gets the first key corresponding to value y from D
  set__D y       deletes key y and corresponding value from D
x set__D y       sets key x to value y (creates/updates as needed)
  map__D ''      pretty print dictionary
  sort__D y      sorts D by key (k/K) or value (v/V), lower being ascending
x joink__D y     join D with dictionaries in y by merging keys (last survives), in-place if x=1
x joinv__D y     NYI join D with dictionaries in y, in-place if x=1
x u filter__D y  NYI think through whats useful. feels like could be more general
```
