#!/bin/bash

# Check if CSV file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file.csv>"
  exit 1
fi

INPUT_FILE=$1

TARGET_COLUMNS=("name" "namespace" "kind" "pollingInterval" "cooldownPeriod" "minReplicaCount" "maxReplicaCount" 
"trigger1_Type" "trigger1_BootstrapServers" "trigger1_ConsumerGroup" "trigger1_topic" "trigger1_lagthreshold" 
"trigger2_Type" "trigger2_BootstrapServers" "trigger2_ConsumerGroup" "trigger2_topic" "trigger2_lagthreshold" 
"trigger3_Type" "trigger3_BootstrapServers" "trigger3_ConsumerGroup" "trigger3_topic" "trigger3_lagthreshold" 
"trigger4_Type" "trigger4_BootstrapServers" "trigger4_ConsumerGroup" "trigger4_topic" "trigger4_lagthreshold" 
"trigger5_Type" "trigger5_BootstrapServers" "trigger5_ConsumerGroup" "trigger5_topic" "trigger5_lagthreshold" 
"trigger6_Type" "trigger6_BootstrapServers" "trigger6_ConsumerGroup" "trigger6_topic" "trigger6_lagthreshold" 
"trigger7_Type" "trigger7_BootstrapServers" "trigger7_ConsumerGroup" "trigger7_topic" "trigger7_lagthreshold" 
"trigger8_Type" "trigger8_BootstrapServers" "trigger8_ConsumerGroup" "trigger8_topic" "trigger8_lagthreshold" 
"trigger9_Type" "trigger9_BootstrapServers" "trigger9_ConsumerGroup" "trigger9_topic" "trigger9_lagthreshold" 
"trigger10_Type" "trigger10_BootstrapServers" "trigger10_ConsumerGroup" "trigger10_topic" "trigger10_lagthreshold" "END")

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
    
    OUTPUT_VALUES_FILE="$filename.yml"
    > "$OUTPUT_VALUES_FILE"
    
    echo "apiVersion: keda.sh/v1alpha1" >> "$OUTPUT_VALUES_FILE"
    echo "kind: ScaledObject" >> "$OUTPUT_VALUES_FILE"
    echo "metadata:" >> "$OUTPUT_VALUES_FILE"
    echo "  name: ${line[${COLUMN_INDEXES[0]}]}-keda" >> "$OUTPUT_VALUES_FILE"
    echo "  namespace: ${line[${COLUMN_INDEXES[1]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "spec:" >> "$OUTPUT_VALUES_FILE"
    echo "  scaleTargetRef:" >> "$OUTPUT_VALUES_FILE"
    
    if [ "${line[${COLUMN_INDEXES[2]}]}" == "Deployment" ]; then
        echo "    #kind: ${line[${COLUMN_INDEXES[2]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    name: ${line[${COLUMN_INDEXES[0]}]}" >> "$OUTPUT_VALUES_FILE"
    elif [ "${line[${COLUMN_INDEXES[2]}]}" == "Statefulsets" ]; then
        echo "    kind: ${line[${COLUMN_INDEXES[2]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    name: ${line[${COLUMN_INDEXES[0]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    echo "  pollingInterval: ${line[${COLUMN_INDEXES[3]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "  cooldownPeriod: ${line[${COLUMN_INDEXES[4]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "  minReplicaCount: ${line[${COLUMN_INDEXES[5]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "  maxReplicaCount: ${line[${COLUMN_INDEXES[6]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "  triggers:" >> "$OUTPUT_VALUES_FILE"
    
    if [[ "${line[${COLUMN_INDEXES[7]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger1_Type is empty or whitespace hence Skipping Full Trigger1 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[7]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"

        value1=${line[${COLUMN_INDEXES[8]}]}
        bootstrap_server1=$(echo "$value1" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server1" >> "$OUTPUT_VALUES_FILE"

        echo "      consumerGroup: ${line[${COLUMN_INDEXES[9]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[10]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[11]}]}" >> "$OUTPUT_VALUES_FILE"
    fi


if [[ "${line[${COLUMN_INDEXES[12]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger2_Type is empty or whitespace hence Skipping Full Trigger2 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[12]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        
        value2=${line[${COLUMN_INDEXES[13]}]}
        bootstrap_server2=$(echo "$value2" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server2" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[13]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[14]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[15]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[16]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    if [[ "${line[${COLUMN_INDEXES[17]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger3_Type is empty or whitespace hence Skipping Full Trigger3 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[17]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value3=${line[${COLUMN_INDEXES[18]}]}
        bootstrap_server3=$(echo "$value3" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server3" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[18]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[19]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[20]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[21]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    if [[ "${line[${COLUMN_INDEXES[22]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger4_Type is empty or whitespace hence Skipping Full Trigger4 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[22]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value4=${line[${COLUMN_INDEXES[23]}]}
        bootstrap_server4=$(echo "$value4" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server4" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[23]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[24]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[25]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[26]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    if [[ "${line[${COLUMN_INDEXES[27]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger5_Type is empty or whitespace hence Skipping Full Trigger5 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[27]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value5=${line[${COLUMN_INDEXES[28]}]}
        bootstrap_server5=$(echo "$value5" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server5" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[28]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[29]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[30]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[31]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    if [[ "${line[${COLUMN_INDEXES[32]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger6_Type is empty or whitespace hence Skipping Full Trigger6 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[32]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value6=${line[${COLUMN_INDEXES[33]}]}
        bootstrap_server6=$(echo "$value6" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server6" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[33]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[34]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[35]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[36]}]}" >> "$OUTPUT_VALUES_FILE"
    fi


    if [[ "${line[${COLUMN_INDEXES[37]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger7_Type is empty or whitespace hence Skipping Full Trigger7 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[37]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value7=${line[${COLUMN_INDEXES[38]}]}
        bootstrap_server7=$(echo "$value7" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server7" >> "$OUTPUT_VALUES_FILE"

        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[38]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      bootstrapServers: $value" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[39]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[40]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[41]}]}" >> "$OUTPUT_VALUES_FILE"
    fi


    if [[ "${line[${COLUMN_INDEXES[42]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger8_Type is empty or whitespace hence Skipping Full Trigger8 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[42]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value8=${line[${COLUMN_INDEXES[43]}]}
        bootstrap_server8=$(echo "$value8" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server8" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[43]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[44]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[45]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[46]}]}" >> "$OUTPUT_VALUES_FILE"
    fi


    if [[ "${line[${COLUMN_INDEXES[47]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger9_Type is empty or whitespace hence Skipping Full Trigger9 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[47]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value9=${line[${COLUMN_INDEXES[48]}]}
        bootstrap_server9=$(echo "$value9" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server9" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[48]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[49]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[50]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[51]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    if [[ "${line[${COLUMN_INDEXES[52]}]}" =~ ^[[:space:]]*$ ]]; then
        echo " Trigger10_Type is empty or whitespace hence Skipping Full Trigger10 values"
    else
        echo "  - type: ${line[${COLUMN_INDEXES[52]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        value10=${line[${COLUMN_INDEXES[53]}]}
        bootstrap_server10=$(echo "$value10" | sed 's/=/,/g')
        echo "      bootstrapServers: $bootstrap_server10" >> "$OUTPUT_VALUES_FILE"
        #echo "      bootstrapServers: ${line[${COLUMN_INDEXES[53]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      consumerGroup: ${line[${COLUMN_INDEXES[54]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      topic: ${line[${COLUMN_INDEXES[55]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "      lagThreshold: ${line[${COLUMN_INDEXES[56]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    echo "Created YAML file: $OUTPUT_VALUES_FILE"
done < <(tail -n +2 "$INPUT_FILE")

echo "All valid rows have been written to their respective YAML files"
