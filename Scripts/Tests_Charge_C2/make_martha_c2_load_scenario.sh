#!/bin/ksh
#################################################
#default configuration parameters to be set     #
#################################################

export TEST_TOTAL_DURATION=13;  # in minute multiple de BASE_SCENARIO_DURATION
# export BASE_SCENARIO_DURATION=`expr 45 \* 60`; # in second
export BASE_SCENARIO_DURATION=768; # in second
export NB_OF_MIN_RESERVED_TO_DROP_OBJECTS=3 ; # in minute
BASE_SEQUENCE_DURATION=768; # in second
#  BASE_SEQUENCE_DURATION = DELTA_NBR * DELTA_TIME cf make_ji_file_for_c2_martha_load_scenario.sh
export OPERATIONAL_MESSAGE_START_TIME="00:02:00.000" ;

export LIST_OF_GENERATION_DIRECTIVES="DROP_MSG DONT_REPEAT_IN_BASE_SCENARIO";
export DATA_LINK_FILE_EXT="ji fom ind_rep_apu"
export HOST_FILE_EXT="xhd";

TEMPLATE_DIR="template"
TEMP_DIR="tmp"
OUTPUT_DIR="scenario"
TEST_NAME="SAMPT_CAPA_MAX_TEST"



INPUT_JI_MSG_FILE="tmp_init_result.ji"
OUTPUT_JI_MSG_FILE="tmp_result.ji"
OUTPUT_FOM_MSG_FILE="tmp_result.fom"
OUTPUT_APU_MSG_FILE="tmp_result.ind_rep_apu"

INIT_XHD_MSG_FILE="sampt_c2_init.xhd"
INIT_XHD_FILTER_FILE="filters_sequence.xhd"
INPUT_XHD_MSG_FILE="tmp_init_result.xhd"
OUTPUT_XHD_MSG_FILE="tmp_result.xhd"

###################################################################
#  load user parameters
###################################################################

# ./load_test_config_file.sh

###################################################################
#  computed parameters
###################################################################

# format is 'directive_1|directive_2|....|directive_n'
export LIST_OF_GENERATION_DIRECTIVES_IN_EGREP_FORMAT=\
`echo $LIST_OF_GENERATION_DIRECTIVES|awk '{for(i=1;i<=NF;i++){if(i!=1){printf("|%s",$i)}else{printf("%s",$i)}}}';`;

# data link file type list without ji type
export DATA_LINK_FILE_EXT_WITHOUT_JI=`echo $DATA_LINK_FILE_EXT|awk '{for(i=1;i<=NF;i++){if($i!="ji"){print $i}}}'`

echo "###############################################"
echo "#  COMPUTE JI BASE SEQUENCE of "$BASE_SEQUENCE_DURATION" second duration                  #"
echo "###############################################"
#pour rendre les differents scripts indépendents
# make_ji_file_for_c2_martha_load_scenario.sh
#make_ji_file_for_c2_martha_load_scenario.sh|tee tmp_init_result.ji
egrep -v $LIST_OF_GENERATION_DIRECTIVES_IN_EGREP_FORMAT $TEMP_DIR/$INPUT_JI_MSG_FILE > $TEMP_DIR/$OUTPUT_JI_MSG_FILE

########################################################
# Passage dans le rep temporaire
########################################################
cd $TEMP_DIR

echo "###############################################"
echo "#  CONVERT JI=> IND_REP_APU/FOM               #"
echo "###############################################"

# convert messages in base sequence without directive

../convert_to_ind_rep_apu $OUTPUT_JI_MSG_FILE $OUTPUT_APU_MSG_FILE
../convert  $OUTPUT_JI_MSG_FILE $OUTPUT_FOM_MSG_FILE

# convert messages  in base sequence with directive 

cat $OUTPUT_APU_MSG_FILE > tmp_init_result.ind_rep_apu
cat $OUTPUT_FOM_MSG_FILE > tmp_init_result.fom

for DIRECTIVE in $LIST_OF_GENERATION_DIRECTIVES;do

   grep  $DIRECTIVE $INPUT_JI_MSG_FILE|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n");}'>tmp_not_to_repeat_${DIRECTIVE}.ji

   ../convert_to_ind_rep_apu tmp_not_to_repeat_${DIRECTIVE}.ji  tmp_not_to_repeat_${DIRECTIVE}.ind_rep_apu
   awk '{printf("'$DIRECTIVE' %s\n",$0)}' tmp_not_to_repeat_${DIRECTIVE}.ind_rep_apu>tmp_not_to_repeat_2_${DIRECTIVE}.ind_rep_apu

   ../convert tmp_not_to_repeat_${DIRECTIVE}.ji tmp_not_to_repeat_${DIRECTIVE}.fom
   awk '{printf("'$DIRECTIVE' %s\n",$0)}' tmp_not_to_repeat_${DIRECTIVE}.fom>tmp_not_to_repeat_2_${DIRECTIVE}.fom

done

# merge them with base sequence messages without directive

for ext in $DATA_LINK_FILE_EXT_WITHOUT_JI ;do 
  cat tmp_result.$ext `echo $LIST_OF_GENERATION_DIRECTIVES|awk '{for(i=1;i<=NF;i++){printf("tmp_not_to_repeat_2_%s.'$ext' ",$i)}}'`>tmp_init_result.$ext
done

echo "###############################################"
echo "#  COMPUTE XHD BASE SEQUENCE   of "$BASE_SEQUENCE_DURATION" second duration               #"
echo "###############################################"

#make_xhd_file_for_c2_martha_load_scenario.sh|tee tmp_init_result.xhd
# suppression des lignes avec directive
egrep -v $LIST_OF_GENERATION_DIRECTIVES_IN_EGREP_FORMAT $INPUT_XHD_MSG_FILE > $OUTPUT_XHD_MSG_FILE

echo "###############################################"
echo "#  SORTING JI/XHD FILE                        #"
echo "###############################################"

for ext in $DATA_LINK_FILE_EXT ;do 
   sort tmp_result.$ext>tmp1_result.$ext
done
sort tmp_result.xhd>tmp1_result.xhd

#parameters computed
export BASE_SCENARIO_DURATION_IN_MINUTE=`echo|awk '{print '$BASE_SCENARIO_DURATION'/60}'`;

echo "#######################################################"
echo "#  REPEAT SEQUENCE UP TO OBTAIN "$BASE_SCENARIO_DURATION_IN_MINUTE" min SCENARIO       #"
echo "#######################################################"

for ext in $DATA_LINK_FILE_EXT ;do 
  /bin/rm -f tmp21_result.$ext;touch tmp21_result.$ext
done
/bin/rm -f tmp21_result.xhd;touch tmp21_result.xhd

export NB_OF_REPEATITION=`echo|awk '{print 1+int(('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')*60/'$BASE_SEQUENCE_DURATION') }'`

#export NB_OF_REPEATITION=`echo|awk '{print 1+int(('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')*60/'$BASE_SEQUENCE_DURATION') }'`
echo "will copy/paste "$NB_OF_REPEATITION" the initial sequence....."
export COUNT=0
while [[ $COUNT -ne $NB_OF_REPEATITION ]] ;do
 export TRANSLATION_VALUE=`expr $COUNT \* $BASE_SEQUENCE_DURATION`
 export TRANSLATION_HMS=`echo $TRANSLATION_VALUE|awk -f ../to_hour_minute_second.awk `
 export TRANSLATION_HOUR=`echo $TRANSLATION_HMS|cut -f1 -d":" `;
 export TRANSLATION_MINUTE=`echo $TRANSLATION_HMS|cut -f2 -d":" `;
 export TRANSLATION_SECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f1 -d"."`;
 export TRANSLATION_MSECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f2 -d"."`;
 for ext in $DATA_LINK_FILE_EXT ;do 
   ../add_time.sh tmp1_result.$ext $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp21_result.$ext  
done
 ../add_time.sh tmp1_result.xhd $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp21_result.xhd
export COUNT=`expr $COUNT + 1`;
 echo $COUNT"th copy/paste proceeded"
done

##########################################################
# Suppression des fichiers temporaire
##########################################################
for ext in $DATA_LINK_FILE_EXT ;do
   rm -f  tmp1_result.$ext
done
rm -f  tmp1_result.xhd

#remove part of RASP refresh to put drop
export LAST_TIME_BEFORE_DROP_IN_HMS=`echo |awk '{print 60*('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')}'|awk -f ../to_hour_minute_second.awk|awk '{print substr($0,1,12)}'`
for ext in $DATA_LINK_FILE_EXT ;do 
  awk '{if($1<"'$LAST_TIME_BEFORE_DROP_IN_HMS'"){print}}' tmp21_result.$ext>tmp22_result.$ext
  rm -f tmp21_result.$ext
done
awk '{if($1<"'$LAST_TIME_BEFORE_DROP_IN_HMS'"){print}}' tmp21_result.xhd>tmp22_result.xhd
rm -f tmp21_result.xhd

# get DROPs messages

for ext in $DATA_LINK_FILE_EXT ;do 
  grep DROP_MSG tmp_init_result.$ext|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp23_result.$ext
done
grep DROP_MSG tmp_init_result.xhd|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp23_result.xhd

export START_HOUR_DROP=`echo |awk '{print int(('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')/60)}'`
export START_MIN_DROP=`echo |awk '{print int(('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')%60)}'`

for ext in $DATA_LINK_FILE_EXT ;do 
  ../add_time.sh tmp23_result.$ext $START_HOUR_DROP $START_MIN_DROP 0 0 >tmp24_result.$ext
  rm -f tmp23_result.$ext
done
../add_time.sh tmp23_result.xhd $START_HOUR_DROP $START_MIN_DROP 0 0 >tmp24_result.xhd
rm -f tmp23_result.xhd

#get messages of base sequence that shall not been repeated in base scenario

for ext in $DATA_LINK_FILE_EXT ;do 
  grep DONT_REPEAT_IN_BASE_SCENARIO tmp_init_result.$ext|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp25_result.$ext
done
grep DONT_REPEAT_IN_BASE_SCENARIO tmp_init_result.xhd|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp25_result.xhd


# merge all type of messages

for ext in $DATA_LINK_FILE_EXT ;do 
  cat tmp22_result.$ext tmp24_result.$ext tmp25_result.$ext |sort -u >tmp2_result.$ext
  rm -f tmp22_result.$ext tmp24_result.$ext tmp25_result.$ext
done
cat tmp22_result.xhd tmp24_result.xhd tmp25_result.xhd |sort -u >tmp2_result.xhd
rm -f tmp22_result.xhd tmp24_result.xhd tmp25_result.xhd

echo "###############################################"
echo "#  translate JI/XHD FILE from "$OPERATIONAL_MESSAGE_START_TIME"            #"
echo "###############################################"

export OPERATIONAL_MESSAGE_START_TIME_HOUR=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f1 -d":" `;
export OPERATIONAL_MESSAGE_START_TIME_MINUTE=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f2 -d":" `;
export OPERATIONAL_MESSAGE_START_TIME_SECOND=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f3 -d":"|cut -f1 -d"."`;
export OPERATIONAL_MESSAGE_START_TIME_MSEC=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f3 -d":"|cut -f2 -d"."`;

for ext in $DATA_LINK_FILE_EXT ;do 
  ../add_time.sh tmp2_result.$ext $OPERATIONAL_MESSAGE_START_TIME_HOUR \
                               $OPERATIONAL_MESSAGE_START_TIME_MINUTE \
                               $OPERATIONAL_MESSAGE_START_TIME_SECOND \
                               $OPERATIONAL_MESSAGE_START_TIME_MSEC >tmp3_result.$ext
  rm -f  tmp2_result.$ext
done
../add_time.sh tmp2_result.xhd $OPERATIONAL_MESSAGE_START_TIME_HOUR \
                               $OPERATIONAL_MESSAGE_START_TIME_MINUTE \
                               $OPERATIONAL_MESSAGE_START_TIME_SECOND \
                               $OPERATIONAL_MESSAGE_START_TIME_MSEC >tmp3_result.xhd
rm -f tmp2_result.xhd

echo "#####################################################################"
echo "#  translate identical times in JI/XHD FILE                         #"
echo "#   (because test_driver discards messages with identical time tags)#"
echo "#####################################################################"

for ext in $DATA_LINK_FILE_EXT ;do 
   ../translate_identical_time_in_test_driver_sce.awk tmp3_result.$ext>tmp4_result.$ext
done
../translate_identical_time_in_test_driver_sce.awk tmp3_result.xhd>tmp4_result.xhd


#parameters computed
export TEST_TOTAL_DURATION_IN_HOUR=`echo|awk '{print '$TEST_TOTAL_DURATION'/60'}`;

echo "#######################################################"
echo "#  REPEAT "$BASE_SCENARIO_DURATION_IN_MINUTE" min SCENARIO TO OBTAIN "$TEST_TOTAL_DURATION_IN_HOUR" HOUR LOAD TEST #"
echo "#######################################################"

for ext in $DATA_LINK_FILE_EXT ;do 
  /bin/rm -f tmp21_result.$ext;touch tmp41_result.$ext
done
/bin/rm -f tmp21_result.xhd;touch tmp41_result.xhd

export NB_OF_REPEATITION=`echo|awk '{print 1+int('$TEST_TOTAL_DURATION'*60/'$BASE_SCENARIO_DURATION') }'`
echo "will copy/paste "$NB_OF_REPEATITION" the base sequence......"
export COUNT=0
while [[ $COUNT -ne $NB_OF_REPEATITION ]] ;do
 export TRANSLATION_VALUE=`expr $COUNT \* $BASE_SCENARIO_DURATION`
echo $TRANSLATION_VALUE 
 export TRANSLATION_HMS=`echo $TRANSLATION_VALUE|awk -f ../to_hour_minute_second.awk `
 export TRANSLATION_HOUR=`echo $TRANSLATION_HMS|cut -f1 -d":" `;
 export TRANSLATION_MINUTE=`echo $TRANSLATION_HMS|cut -f2 -d":" `;
 export TRANSLATION_SECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f1 -d"."`;
 export TRANSLATION_MSECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f2 -d"."`;
 for ext in $DATA_LINK_FILE_EXT ;do 
   ../add_time.sh tmp4_result.$ext $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp41_result.$ext
done
 ../add_time.sh tmp4_result.xhd $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp41_result.xhd
export COUNT=`expr $COUNT + 1`;
 echo $COUNT"th copy/paste proceeded"
done

##########################################################
# Suppression des fichiers temporaire
##########################################################
for ext in $DATA_LINK_FILE_EXT ;do
   rm -f  tmp4_result.$ext
done
rm -f  tmp4_result.xhd

###################################
# Retour dans le reprtoire de base
###################################
cd ..

echo "###############################################################"
echo "#  make SAMPT load test files  (load_test.xhd/ind_rep_apu)   #"
echo "#   1/add of init MARTHA DLIP init sequence (registration ...)#"
echo "###############################################################"

cat $TEMPLATE_DIR/$INIT_XHD_MSG_FILE $TEMPLATE_DIR/$INIT_XHD_FILTER_FILE $TEMP_DIR/tmp41_result.xhd > $OUTPUT_DIR/$TEST_NAME.xhd
rm -f $TEMP_DIR/tmp41_result.xhd

for ext in $DATA_LINK_FILE_EXT ;do 
  mv $TEMP_DIR/tmp41_result.$ext $OUTPUT_DIR/$TEST_NAME.$ext
  rm -f $TEMP_DIR/tmp41_result.$ext
done
exit
echo "#############################################################################################"
echo "#  make vanilla 'light load test no 1' files (light_load_test_vanilla_data_link.ji/fom/xhd):#"
echo "#    1/ don't  put anything in xhd file / keep only J3.2/J7.0 in data link file             #"
echo "#############################################################################################"

echo>light_load_test_vanilla_data_link.xhd
awk '{if(($9=="090C")||($9=="001C")){print}}' load_test_vanilla.fom>light_load_test_vanilla_data_link.fom
egrep "0E030200|0E070000" load_test_vanilla.ji>light_load_test_vanilla_data_link.ji

echo "#############################################################################################"
echo "#  make vanilla 'light load test no 2' files (light_load_test_vanilla_host.ji/fom/xhd):     #"
echo "#    1/ don't  put anything in JI/FOM file / keep only AHD101/AHD121 in host file           #"
echo "#############################################################################################"

echo>light_load_test_vanilla_host.ji
echo>light_load_test_vanilla_host.fom

awk '{data="";for(i=2;i<=NF;i++){data=sprintf("%s%s",data,$i)};if((substr(data,15,2)=="65")||(substr(data,15,2)=="79")){print}}'  load_test_vanilla.xhd>light_load_test_vanilla_host.xhd

echo "#############################################################################################"
echo "#  make MARTHA light tests files corresponding to vanilla ones                              #"
echo "# (light_load_test_martha_host/data_link.ind_rep_apu/xhd):                                  #"
echo "#    1/compute  ind_rep_apu                                                                 #"
echo "#    2/add of init MARTHA DLIP initsequence (registration ...)                              #"
echo "#############################################################################################"

echo "computing  ind_rep_apu(remove messages)"

awk '{if(($42=="090C")||($42=="001C")||($1<"00:01:40.000")){print}}' load_test_martha.ind_rep_apu>light_load_test_martha_data_link.ind_rep_apu
cp ~/bin/martha_c2_init_dlip_protocol.ind_rep_apu light_load_test_martha_host.ind_rep_apu


echo "putting in protocol for xhd"
for f in light_load_test*.xhd;do
  export MARTHA_NAME=`echo $f |sed  "s/vanilla/martha/g"`
  cat ~/bin/martha_c2_init_dlip_protocol.xhd $f>$MARTHA_NAME
done


echo "################################################################"
echo "#  1/changing version number in vanilla host files             #"
echo "#  2/removing martha specific blocks in vanilla host files     #"
echo "################################################################"

for f in *load_test*vanilla*xhd ;do
   echo "changing version numbers/removing martha spec. block for "$f
   awk 'BEGIN{v["65"]="01";v["6A"]="01";v["6B"]="02";v["6E"]="01";v["BE"]="01";v["79"]="01"}{data="";for(i=2;i<=NF;i++){data=sprintf("%s%s",data,$i)};nver=v[substr(data,15,2)];new_data=sprintf("%s%s%s",substr(data,1,28),nver,substr(data,31));printf("%s ",$1);for(i=1;i<=length(new_data);i+=2){printf("%s ",substr(new_data,i,2))};printf("\n");}'  $f |awk '{numb="123456789ABCDEF";len_orig="";for(i=2;i<=5;i++){len_orig=sprintf("%s%s",len_orig,$i)};len_mess=0;mult=1;for(i=8;i>=1;i--){len_mess+=mult*index(numb,substr(len_orig,i,1));mult*=16;};if($9=="65"){len_mess-=13};if($9=="6A"){len_mess-=17};len_fin=sprintf("%0.8X ",len_mess);printf("%s ",$1);for(i=1;i<=8;i+=2){printf("%s ",substr(len_fin,i,2))};for(i=6;i<=NF;i++){if((((i<=NF-13)&&($9=="65"))||((i<=NF-17)&&($9=="6A")))||(($9!="65")&&($9!="6A"))){printf("%s ",$i)}};printf("\n");}'>$f.tmp
   mv $f.tmp $f
done

#############################################
# TO ADD for vanilla scenarii: change LINK ID 2 into 1
#############################################
