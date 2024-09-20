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


if [ -z "$1" ] || [ -z "$2" ]|| [ -z "$3" ]|| [ -z "$4" ]; then
  echo "Usage: $0 <input_file.csv> env_name=<env_name> sub_env=<sub_env_name>"
  exit 1
fi

input_file=$1
env_name=${2#*=}
sub_env=${3#*=}
consumer_group_sub_env=${4#*=}

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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[5]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[5]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[6]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[8]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[8]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[9]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[11]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[11]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[12]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[14]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[14]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[15]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[17]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[17]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[18]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[20]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[20]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[21]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[23]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[23]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[24]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[26]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[26]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[27]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[29]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[29]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[30]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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
            
        if [ $consumer_group_sub_env == "yes" ]; then
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[32]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[32]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    
            topic1="${sub_env}_${line[${COLUMN_INDEXES[33]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
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