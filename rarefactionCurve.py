def calculateRarefactionCurve( input_file ):
	"""
	Calculate diversity with each number of subsamples
	input variable:
		input_file: name of input csv file
	output file:
		median diversity with each number of subsamples
	"""
	import numpy, collections
	samples, clones = readCSV(input_file)
	if len(samples) > 2:
		D = []
		for k in range(1,len(samples)):			   
			m = selectSamples(samples,k)
			diversity = []
			for subsamples in m:
				if k == 1:
					idx = samples.index(subsamples)
					diversity.append(len(clones[idx].split(' ')))
				else:
					indices=[i for i, item in enumerate(samples) if item in set(subsamples)]
					subclones = []
					for idx in indices:
						subclones += clones[idx].split(' ')
					counter = collections.Counter(subclones)
					f = counter.values()
					p = [float(x)/sum(f) for x in f]					
					diversity.append(calculateDiversity(p))
			D.append(numpy.median(diversity))
		print(D)
	else:
		print("too few samples")	


def calculateDiversity( p ):
	"""
	Calculate true diversity
	input variable:
		p: proportion of each clone
	return value:
		true diversity, which is exponential of Shannon index 
	"""
	import math	  
	H = 0
	for pk in p:
		H += pk * math.log(pk)
	H = -1 * H	
	return math.exp(H)
	

def selectSamples( samples,k,i=None ):
	"""
	Select different number of subsamples from all samples. Default times of resample is 10. More resample is slower but more accurate.
	input variables:
		samples: list of samples
		k: number of subsamples select
		i: times of resample, default is 10
	return value:
		list of subsamples
	"""
	import math, random, itertools
	if i is None:
	    i = 10
	n = len(samples)
	if k == 1:		
		return samples
	else:		
		from math import factorial
		if math.factorial(n) / math.factorial(k) / math.factorial(n-k) <= i:			 
			return list(itertools.combinations(samples,k))
		else:			 
			m = []
			for count in range(i):
				m.append(random.sample(samples,k))
			return m	
		  

def readCSV( input_file ):
    """
	Read csv file
	input variables:
		input_file: name of input csv file
	return value:
		samples: list of samples
		clones: list of clones in each sample
	"""
	import csv	
	with open(input_file,'rb') as csvin:
		csvin = csv.reader(csvin, delimiter=',')
		array = []
		for row in csvin:
			array.append(filter(None, row))		
	samples = []
	clones = []
	for row in array:
		samples.append(row[0])
		clones.append(row[1])
	return samples, clones


if __name__ == '__main__':
	calculateRarefactionCurve()
