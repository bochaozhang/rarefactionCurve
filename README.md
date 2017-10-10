Calculate true diversity with each number of subsample
=============

Bochao Zhang

## Usage

```
-d name of database
-s name of subject
-f field of the columns used to separate data
-g desired feature that needs to be calculated
-t size threshold, lower bound clone size, see below
```
For example

```
bash sampleRarefaction.sh -d lp11 -s D207 -f tissue -g BM -t 20
```

** Note: you will need permission to access databases, replace your username and pwd in security.cnf. **

## Methods


## Output files
The code will output one or two csv file(s):
[subject]-[compartment]-[C*X*]_curve.csv has two columns: number of subsamples and calculated ture diversity
[subject]-[compartment]-[C*X*].csv: has the C*X* list for [compartment] if not done so previously
in which *X* denotes the lower bound clone size:

