# Get parameters needed for calculation

# Get input arguments
while getopts ":d:s:f:g:t:" opt; do
  case $opt in
    d) db_name=$OPTARG;;
    s) subject=$OPTARG;;
    f) feature=$OPTARG;;    
    g) desired_feature=$OPTARG;;  
    t) size_threshold=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1;;
  esac
done
echo -e "database: $db_name\nsubject: $subject\n$feature: $desired_feature\nlower clone size bound: $size_threshold"

# Get all features
features=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select distinct $feature from samples left join subjects on samples.subject_id = subjects.id where subjects.identifier='$subject'")
unique_features=$(echo "${features[@]}" | tr '\n' ' ')

# Get qualified clones
qualified_file="$db_name-$subject-$feature-C$size_threshold.txt"
if [ -f "$qualified_file" ]; then    # if there is a pre-calculated list, then use it
	echo "pre-calculated list found"
	qualified_clones=$(<$qualified_file)	
else                                 # if there isn't a pre-calculated list, then calculate and save it
	qualified_clones=()
	for feat in ${unique_features}; do
		# Get sample ids
		sample_id=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select samples.id from subjects right join samples on subjects.id = samples.subject_id where subjects.identifier='$subject' and samples.$feature='$feat'")	
		sample_id=$(echo "${sample_id[@]}" | tr '\n' ',')
		sample_id=${sample_id::-1}

		# Filter clones by size (instance)
		clones=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select clone_id,count(distinct seq_id) from sequences where sample_id in ($sample_id) and clone_id is not NULL and functional=1 group by clone_id;")	
		flag=0
		for clone in ${clones}; do
			if (($flag==0)); then
				qualified_clones+=($clone)
				flag=1
			else
				if (($clone<$size_threshold)); then
					unset qualified_clones[${#qualified_clones[@]}-1]
				fi
				flag=0
			fi
		done	
	done
	qualified_clones=($(echo "${qualified_clones[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
	echo "${#qualified_clones[@]} clones with at least $size_threshold instance(s) in at least one $feature"	
	qualified_clones=$(printf ",%s" "${qualified_clones[@]}")
	qualified_clones=${qualified_clones:1}	
	echo "$qualified_clones" > $qualified_file    # save the list
fi

# Get sample ids of desired feature
sample_ids=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select samples.id from subjects right join samples on subjects.id = samples.subject_id where subjects.identifier='$subject' and samples.$feature='$desired_feature'")	

# Get qualified clone for each sample in desired feature
output_file="$subject-$desired_feature-C$size_threshold.csv"
echo "sample_id,clone_ids" > $output_file
for sample_id in ${sample_ids}; do	
	echo "select distinct(clone_id) from sequences where sample_id=$sample_id and functional=1 and clone_id in ($qualified_clones)" > temp.txt
	clones=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B < temp.txt)	
	rm temp.txt	
	clones=$(echo "${clones[@]}" | tr '\n' ' ')	
	echo "$sample_id,$clones" >> $output_file	
done





