Calculate true diversity with each number of subsample
=============

Bochao Zhang

Calculate true diversity for each number of subsample (from 1 to total number of samples) in a certain group of samples.

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

will calculate true diversity of 1 to 35 subsamples randomly selected in BM C*20* clones, where subsamples are selected randomly for 10 rounds.

** Note: you will need permission to access databases, replace your username and pwd in security.cnf. **

## Methods
### Instance
We considered clone size to be the sum of the number of uniquely mutated sequences and all the different instances of the same unique sequence that are found in separate sequencing libraries. We refer to this hybrid clone size measure as “unique sequence instances”.

### Lower bound clone size
Our assumption is clones with larger size are easier to sample. So number of additional sample is calculated based on lower bound clone size. This lower bound clone size is defined as at least *X* instances in at least compartment. And they are generally referred to as C*X* clones, where *X* denotes the lower bound clone size.

### Calculation
True diversity calculated with default order of 1. The is equivalent to the exponential of Shannon index. Default round of resample is 10. More round is slower but more accurate.

## Output files
The code will output one or two csv file(s):
[subject]-[compartment]-[C*X*]-curve.csv has two columns: number of subsamples and calculated ture diversity
[subject]-[compartment]-[C*X*].csv: has the C*X* list for [compartment] if not done so previously
in which *X* denotes the lower bound clone size:

