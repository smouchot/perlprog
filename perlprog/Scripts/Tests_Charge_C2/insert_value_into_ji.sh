echo `echo $5|awk '{for(i=1;i<11;i++){printf("%s ",$i)}}' ;echo  $5|awk '{for(i=NF;i>=11;i--){printf("%s",$i)}printf("\n")}'|/usr/xpg4/bin/awk -v base=$1 -v nb_bit=$2 -v pos_value=$3 -v value=$4 -v data_type=ji -f ./insert_value_into_data.awk`
#echo  $5|awk '{for(i=NF;i>=11;i--){printf("%s",$i)}printf("\n")}'|/usr/xpg4/bin/awk -v base=$1 -v nb_bit=$2 -v pos_value=$3 -v value=$4 -v data_type=$5 -f ./insert_value_into_data.awk
