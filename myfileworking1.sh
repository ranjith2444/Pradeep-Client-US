#!/bin/bash

CONFIG_FILE="config.json"

zeroBased_min_replica="10"
zeroBased_max_replica="11"
zeroBased_cooling_period="300"
zeroBased_thershold_lag="300"



slaBased_min_replica="20"
slaBased_max_replica="30"
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

#####

json=$(cat "$CONFIG_FILE")

extract_value() {
  local key="$1"
  echo "$json" | sed -n "s/.*\"$key\": \"\([^\"]*\)\".*/\1/p"
}

dev_bootstrap_config=$(extract_value "dev")
qa_bootstrap_config=$(extract_value "qa")
imps_bootstrap_config=$(extract_value "imps")
prod_bootstrap_config=$(extract_value "prod")




echo "dev: $dev_bootstrap_config"
echo "qa: $qa_bootstrap_config"
echo "imps: $imps_bootstrap_config"
echo "prod: $prod_bootstrap_config"

INPUT_FILE=$1

TARGET_COLUMNS=("name" "namespace" "kind" "based_config"
"trigger1_Type" "trigger1_BootstrapServers" "trigger1_ConsumerGroup" "trigger1_topic"  
"trigger2_Type" "trigger2_BootstrapServers" "trigger2_ConsumerGroup" "trigger2_topic" 
"trigger3_Type" "trigger3_BootstrapServers" "trigger3_ConsumerGroup" "trigger3_topic"  
"trigger4_Type" "trigger4_BootstrapServers" "trigger4_ConsumerGroup" "trigger4_topic"  
"trigger5_Type" "trigger5_BootstrapServers" "trigger5_ConsumerGroup" "trigger5_topic"  
"trigger6_Type" "trigger6_BootstrapServers" "trigger6_ConsumerGroup" "trigger6_topic" 
"trigger7_Type" "trigger7_BootstrapServers" "trigger7_ConsumerGroup" "trigger7_topic" 
"trigger8_Type" "trigger8_BootstrapServers" "trigger8_ConsumerGroup" "trigger8_topic"  
"trigger9_Type" "trigger9_BootstrapServers" "trigger9_ConsumerGroup" "trigger9_topic" 
"trigger10_Type" "trigger10_BootstrapServers" "trigger10_ConsumerGroup" "trigger10_topic" "END")

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

while IFS=, read -r -a line; do
    if [[ -z "${line[*]}" ]]; then
        continue
    fi

    filename="${line[${COLUMN_INDEXES[0]}]}"
    if [ -z "$filename" ]; then
        continue
    fi
    filename11="$sub_env-$filename"
    OUTPUT_VALUES_FILE="$filename11-values.yml"
    > "$OUTPUT_VALUES_FILE"
    
    echo "scaledObjects:" >> "$OUTPUT_VALUES_FILE"
    echo "  - name:  $sub_env-${line[${COLUMN_INDEXES[0]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "    namespace: ${line[${COLUMN_INDEXES[1]}]}" >> "$OUTPUT_VALUES_FILE"
    if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
        echo "    min_replicas: $zeroBased_min_replica " >> "$OUTPUT_VALUES_FILE"
        echo "    max_replica: $zeroBased_max_replica " >> "$OUTPUT_VALUES_FILE"
        echo "    cooling_period: $zeroBased_cooling_period " >> "$OUTPUT_VALUES_FILE"
    elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
        echo "    min_replicas: $slaBased_min_replica " >> "$OUTPUT_VALUES_FILE"
        echo "    max_replica: $slaBased_max_replica " >> "$OUTPUT_VALUES_FILE"
        echo "    cooling_period: $slaBased_cooling_period " >> "$OUTPUT_VALUES_FILE"
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
            echo "          consumerGroup: $sub_env-${line[${COLUMN_INDEXES[6]}]}" >> "$OUTPUT_VALUES_FILE"
        elif [ $consumer_group_sub_env == "no" ]; then
            echo "          consumerGroup: ${line[${COLUMN_INDEXES[6]}]}" >> "$OUTPUT_VALUES_FILE"
        fi    

            topic1="${sub_env}_${line[${COLUMN_INDEXES[7]}]}"
            echo "          topic: $topic1" >> "$OUTPUT_VALUES_FILE"
        if [ "${line[${COLUMN_INDEXES[3]}]}" == "zero_based" ]; then
            echo "          lagThreshold: $zeroBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        elif [ "${line[${COLUMN_INDEXES[3]}]}" == "sla_based" ]; then
            echo "          lagThreshold: $slaBased_thershold_lag " >> "$OUTPUT_VALUES_FILE"
        fi
      ########## trigger 1 #########
    fi


    echo "Created YAML file: $OUTPUT_VALUES_FILE"
done < <(tail -n +2 "$INPUT_FILE")

echo "All valid rows have been written to their respective YAML files"