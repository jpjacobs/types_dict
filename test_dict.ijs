NB. run all unittests for dict
require'general/unittest'
NB. check files exist
'Please change dir to addon dir before tests' assert fexist&><;._1 ' dict.ijs tests1dict.ijs tests2dicts.ijs'

([: echo unittest)&> <;._1 ' tests1dict.ijs tests2dicts.ijs'

NB. optional benchmark
bench =: 3 : 0
num =: 1000000 NB. number of entries
nk  =: 10000   NB. number to retrieve
d0 =: dict (i.num);i. num
d1 =: dict (?~num);i. num
d2 =: dict (sym=. s: <@":"0 i. num);i. num          NB. symbol linear
d3 =: dict ((?~num){ sym);i. num                    NB. symbol scrambled
NB. bench get
echo 'Benchmark get ',(":nk),' items from ',":num
echo 1000&timespacex&> 'getv__d0 nk ?@$ num';'getv__d1 nk ?@$ num';'getv__d2 keys__d2{~nk?@$ num';'getv__d3 keys__d3{~nk?@$ num'
destroy__d0''
destroy__d1''
destroy__d2''
destroy__d3''
)
