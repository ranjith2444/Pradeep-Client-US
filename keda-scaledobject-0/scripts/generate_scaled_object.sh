#!/bin/bash

dev_bootstrap_config="SEIDEVQ05KAF03.GWPDEV.SEIC.COM:9092,SEIDEVQ05KAF02.GWPDEV.SEIC.COM:9092,SEIDEVQ05KAF01.GWPDEV.SEIC.COM:9092"
qa_bootstrap_config="QA.QA.SEIC.COM:9092,QA.QA.SEIC.COM:9092,QA.QA.SEIC.COM:9092"
imps_bootstrap_config="imps.imps.SEIC.COM:9092,imps.imps.SEIC.COM:9092,imps.imps.SEIC.COM:9092"
prod_bootstrap_config="prod.prod.SEIC.COM:9092,prod.prod.SEIC.COM:9092,prod.prod.SEIC.COM:9092"

zeroBased_polling_Interval="23"
zeroBased_min_replica="10"
zeroBased_max_replica="11"
zeroBased_cooling_period="300"
zeroBased_thershold_lag="300"

slaBased_polling_Interval="77"
slaBased_min_replica="78"
slaBased_max_replica="79"
slaBased_cooling_period="500"
slaBased_thershold_lag="500"


chars_to_replace="{{ENV}}"

if [ -z "$1" ] || [ -z "$2" ]|| [ -z "$3" ]; then
  echo "Usage: $0 <input_file.csv> env_name=<env_name> sub_env=<sub_env_name> consumer_group_sub_env=<consumer_group_sub_env> topic_sub_env=<topic_sub_env>"
  exit 1
fi

input_file=$1
env_name=${2#*=}
sub_env=${3#*=}
# consumer_group_sub_env=${4#*=}
# topic_sub_env=${5#*=}

echo "Input file: $input_file"
echo "Environment name: $env_name"

INPUT_FILE=$1

TARGET_COLUMNS=("name" "namespace" "kind" "based_config"
"trigger1_Type" "trigger1_ConsumerGroup" "trigger1_topic"  
"trigger2_Type" "trigger2_ConsumerGroup" "trigger2_topic" 
"trigger3_Type" "trigger3_ConsumerGroup" "trigger3_topic"  
"trigger4_Type" "trigger4_ConsumerGroup" "trigger4_topic"  
"trigger5_Type" "trigger5_ConsumerGroup" "trigger5_topic"  
"trigger6_Type" "trigger6_ConsumerGroup" "trigger6_topic" 
"trigger7_Type" "trigger7_ConsumerGroup" "trigger7_topic" 
"trigger8_Type" "trigger8_ConsumerGroup" "trigger8_topic"  
"trigger9_Type" "trigger9_ConsumerGroup" "trigger9_topic" 
"trigger10_Type" "trigger10_ConsumerGroup" "trigger10_topic" "END")

# Read the header and find the column indexes
IFS=, read -r -a header < "$INPUT_FILE"

# Initialize an array to store the indexes
COLUMN_INDEXES=()

for col in "${TARGET_COLUMNS[@]}"; do
    for i in "${!header[@]}"; do
        if [ "${header[$i]}" == "$col" ]; then
            COLUMN_INDEXES+=("$i")
            break
        fi
    done
done
OUTPUT_VALUES_FILE="./scaledObject/values.yml"
 > $OUTPUT_VALUES_FILE  
    echo "scaledObjects:" >> "$OUTPUT_VALUES_FILE"
while IFS=, read -r -a line; do
    if [[ -z "${line[*]}" ]]; then
        continue
    fi

    filename="${line[${COLUMN_INDEXES[0]}]}"
    if [ -z "$filename" ]; then
        continue
    fi
   
    
    echo "  - name:  $sub_env-${line[${COLUMN_INDEXES[0]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "    namespace: ${line[${COLUMN_INDEXES[1]}]}" >> "$OUTPUT_VALUES_FILE"
    if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
        echo "    pollingInterval: $zeroBased_polling_Interval " >> "$OUTPUT_VALUES_FILE"
        echo "    cooldownPeriod: $zeroBased_cooling_period " >> "$OUTPUT_VALUES_FILE"
        echo "    minReplicaCount: $zeroBased_min_replica " >> "$OUTPUT_VALUES_FILE"
        echo "    maxReplicaCount: $zeroBased_max_replica " >> "$OUTPUT_VALUES_FILE"
    elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
        echo "    pollingInterval: $slaBased_polling_Interval " >> "$OUTPUT_VALUES_FILE"
        echo "    cooldownPeriod: $slaBased_cooling_period " >> "$OUTPUT_VALUES_FILE"
        echo "    minReplicaCount: $slaBased_min_replica " >> "$OUTPUT_VALUES_FILE"
        echo "    maxReplicaCount: $slaBased_max_replica " >> "$OUTPUT_VALUES_FILE"
    fi  
        echo "    scaleTargetRef:" >> "$OUTPUT_VALUES_FILE"
    if [ "${line[${COLUMN_INDEXES[2]}]}" == "Deployment" ]; then
        echo "      #kind: ${line[${COLUMN_INDEXES[2]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      name: $sub_env-${line[${COLUMN_INDEXES[0]}]}" >> "$OUTPUT_VALUES_FILE"
    elif [ "${line[${COLUMN_INDEXES[2]}]}" == "Statefulsets" ]; then
        echo "      kind: ${line[${COLUMN_INDEXES[2]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      name: $sub_env-${line[${COLUMN_INDEXES[0]}]}" >> "$OUTPUT_VALUES_FILE"
    fi
        echo "    triggers:" >> "$OUTPUT_VALUES_FILE"
    

    ########## trigger 1 #########
    if [[ "${line[${COLUMN_INDEXES[4]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger1_Type is empty or whitespace hence Skipping Full Trigger1 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[4]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup1=$(echo "${line[${COLUMN_INDEXES[5]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup1" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup1=$(echo "${line[${COLUMN_INDEXES[5]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup1" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic1=$(echo "${line[${COLUMN_INDEXES[6]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic1=$(echo "${line[${COLUMN_INDEXES[6]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
        # fi    

        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## trigger 1 #########

    ########## trigger 2 #########
    if [[ "${line[${COLUMN_INDEXES[7]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger2_Type is empty or whitespace hence Skipping Full Trigger2 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[4]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup2=$(echo "${line[${COLUMN_INDEXES[8]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup2" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup2=$(echo "${line[${COLUMN_INDEXES[8]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup2" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic2=$(echo "${line[${COLUMN_INDEXES[9]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic2" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic2=$(echo "${line[${COLUMN_INDEXES[9]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic2" >> "$OUTPUT_VALUES_FILE"
        # fi 


        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi  
    ########## trigger 2 #########

    ########## Trigger3 #########
    if [[ "${line[${COLUMN_INDEXES[10]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger3_Type is empty or whitespace hence Skipping Full Trigger3 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[10]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup3=$(echo "${line[${COLUMN_INDEXES[11]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup3" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup3=$(echo "${line[${COLUMN_INDEXES[11]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup3" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic3=$(echo "${line[${COLUMN_INDEXES[12]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic3" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic3=$(echo "${line[${COLUMN_INDEXES[12]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic3" >> "$OUTPUT_VALUES_FILE"
        # fi 


        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## Trigger3 #########

         ########## Trigger4 #########
    if [[ "${line[${COLUMN_INDEXES[13]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger4_Type is empty or whitespace hence Skipping Full Trigger4 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[13]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup4=$(echo "${line[${COLUMN_INDEXES[14]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup4" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup4=$(echo "${line[${COLUMN_INDEXES[14]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup4" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic4=$(echo "${line[${COLUMN_INDEXES[15]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic4" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic4=$(echo "${line[${COLUMN_INDEXES[15]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic4" >> "$OUTPUT_VALUES_FILE"
        # fi 


        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## Trigger4 #########


    ########## Trigger5 #########
    if [[ "${line[${COLUMN_INDEXES[16]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger5_Type is empty or whitespace hence Skipping Full Trigger5 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[16]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup5=$(echo "${line[${COLUMN_INDEXES[17]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup5" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup5=$(echo "${line[${COLUMN_INDEXES[17]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup5" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic5=$(echo "${line[${COLUMN_INDEXES[18]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic5" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic5=$(echo "${line[${COLUMN_INDEXES[18]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic5" >> "$OUTPUT_VALUES_FILE"
        # fi 


        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## Trigger5 #########

        ########## Trigger6 #########
    if [[ "${line[${COLUMN_INDEXES[19]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger6_Type is empty or whitespace hence Skipping Full Trigger6 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[19]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup6=$(echo "${line[${COLUMN_INDEXES[20]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup6" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup6=$(echo "${line[${COLUMN_INDEXES[20]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup6" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic6=$(echo "${line[${COLUMN_INDEXES[21]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic6" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic6=$(echo "${line[${COLUMN_INDEXES[21]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic6" >> "$OUTPUT_VALUES_FILE"
        # fi 


        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## Trigger6 #########

        ########## Trigger7 #########
    if [[ "${line[${COLUMN_INDEXES[22]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger7_Type is empty or whitespace hence Skipping Full Trigger7 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[22]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup7=$(echo "${line[${COLUMN_INDEXES[23]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup7" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup7=$(echo "${line[${COLUMN_INDEXES[23]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup7" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic7=$(echo "${line[${COLUMN_INDEXES[24]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic7" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic7=$(echo "${line[${COLUMN_INDEXES[24]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic7" >> "$OUTPUT_VALUES_FILE"
        # fi 


        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## Trigger7 #########

    

      
   ########## Trigger8 #########
    if [[ "${line[${COLUMN_INDEXES[25]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger8_Type is empty or whitespace hence Skipping Full Trigger8 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[25]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup8=$(echo "${line[${COLUMN_INDEXES[26]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup8" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup8=$(echo "${line[${COLUMN_INDEXES[26]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup8" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic8=$(echo "${line[${COLUMN_INDEXES[27]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic8" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic8=$(echo "${line[${COLUMN_INDEXES[27]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic8" >> "$OUTPUT_VALUES_FILE"
        # fi 


        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## Trigger8 #########

    

    ########## Trigger9 #########
    if [[ "${line[${COLUMN_INDEXES[28]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger9_Type is empty or whitespace hence Skipping Full Trigger9 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[28]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup9=$(echo "${line[${COLUMN_INDEXES[29]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup9" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup9=$(echo "${line[${COLUMN_INDEXES[29]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup9" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic9=$(echo "${line[${COLUMN_INDEXES[30]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic9" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic9=$(echo "${line[${COLUMN_INDEXES[30]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic9" >> "$OUTPUT_VALUES_FILE"
        # fi 

            
        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
    fi
    ########## Trigger9 #########

       ########## Trigger10 #########
    if [[ "${line[${COLUMN_INDEXES[31]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger10_Type is empty or whitespace hence Skipping Full Trigger10 values"
    else
        echo "      - type: ${line[${COLUMN_INDEXES[31]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "        metadata:" >> "$OUTPUT_VALUES_FILE"
        if [ $env_name == "dev" ]; then
            echo "          bootstrapServers: $dev_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "qa" ]; then
            echo "          bootstrapServers: $qa_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "imps" ]; then
            echo "          bootstrapServers: $imps_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        elif [ $env_name == "prod" ]; then
            echo "          bootstrapServers: $prod_bootstrap_config " >> "$OUTPUT_VALUES_FILE"
        fi
            
        # if [ $consumer_group_sub_env == "yes" ]; then
            consumerGroup10=$(echo "${line[${COLUMN_INDEXES[32]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          consumerGroup: $consumerGroup10" >> "$OUTPUT_VALUES_FILE"
        # elif [ $consumer_group_sub_env == "no" ]; then
        #     consumerGroup10=$(echo "${line[${COLUMN_INDEXES[32]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          consumerGroup: $consumerGroup10" >> "$OUTPUT_VALUES_FILE"
        # fi

        # if [ $topic_sub_env == "yes" ]; then
            topic10=$(echo "${line[${COLUMN_INDEXES[33]}]}" | sed "s/$chars_to_replace/$sub_env/")
            echo "          topic: $topic10" >> "$OUTPUT_VALUES_FILE"
        # elif [ $topic_sub_env == "no" ]; then
        #     topic10=$(echo "${line[${COLUMN_INDEXES[33]}]}" | sed "s/$chars_to_replace/""/")
        #     echo "          topic: $topic10" >> "$OUTPUT_VALUES_FILE"
        # fi 
        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi

    fi
    ########## Trigger10 #########
    
    echo "Created YAML file: $OUTPUT_VALUES_FILE"
done < <(tail -n +2 "$INPUT_FILE")

echo "All valid rows have been written to their respective YAML files"