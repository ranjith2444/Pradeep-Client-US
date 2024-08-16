#!/bin/bash

# Check if CSV file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file.csv>"
  exit 1
fi

INPUT_FILE=$1

TARGET_COLUMNS=("name"	"namespace"	"kind"	"pollingInterval"	"cooldownPeriod"	"minReplicaCount"	"maxReplicaCount"	
"trigger1_Type" "trigger1_BootstrapServers"	"trigger1_ConsumerGroup" "trigger1_topic"	"trigger1_lagthreshold"
"trigger2_Type"	"trigger2_BootstrapServers"	"trigger2_ConsumerGroup" "trigger2_topic"	"trigger2_lagthreshold"	
"trigger3_Type"	"trigger3_BootstrapServers"	"trigger3_ConsumerGroup" "trigger3_topic" "trigger3_lagthreshold"	
"trigger4_Type"	"trigger4_BootstrapServers"	"trigger4_ConsumerGroup" "trigger4_topic"	"trigger4_lagthreshold"	
"trigger5_Type"	"trigger5_BootstrapServers"	"trigger5_ConsumerGroup" "trigger5_topic"	"trigger5_lagthreshold"	
"trigger6_Type"	"trigger6_BootstrapServers"	"trigger6_ConsumerGroup" "trigger6_topic"	"trigger6_lagthreshold"	
"trigger7_Type"	"trigger7_BootstrapServers"	"trigger7_ConsumerGroup" "trigger7_topic"	"trigger7_lagthreshold"	
"trigger8_Type"	"trigger8_BootstrapServers"	"trigger8_ConsumerGroup" "trigger8_topic"	"trigger8_lagthreshold"	
"trigger9_Type"	"trigger9_BootstrapServers"	"trigger9_ConsumerGroup" "trigger9_topic"	"trigger9_lagthreshold"	
"trigger10_Type" "trigger10_BootstrapServers" "trigger10_ConsumerGroup"	"trigger10_topic"	"trigger10_lagthreshold" "END")


IFS=, read -r -a header < "$INPUT_FILE"

declare -A COLUMN_INDEXES
for i in "${!header[@]}"; do
    if [[ -n "${header[$i]}" ]]; then  # skip empty elements
        for col in "${TARGET_COLUMNS[@]}"; do
            if [[ "${header[$i]}" == "$col" ]]; then
                COLUMN_INDEXES["$col"]=$i
            fi
        done
    fi
done



while IFS=, read -r -a line
do
    if [[ "${line[@]}" =~ ^([[:space:]]*|)$ ]]; then
        continue
    else
        filename="${line[${COLUMN_INDEXES["name"]}]}"
        if [ -z "$filename" ]; then
            continue
        fi
        #Change the path for Yml file , currently it is in Present workingDirectory of the .sh 
        OUTPUT_VALUES_FILE="$filename.yml"
        
        > "$OUTPUT_VALUES_FILE"
        echo "apiVersion: keda.sh/v1alpha1" >> "$OUTPUT_VALUES_FILE"
        echo "kind: ScaledObject" >> "$OUTPUT_VALUES_FILE"
        echo "metadata:" >> "$OUTPUT_VALUES_FILE"
        echo "  name: ${line[${COLUMN_INDEXES["name"]}]}"-keda >> "$OUTPUT_VALUES_FILE"
        echo "  namespace: ${line[${COLUMN_INDEXES["namespace"]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "spec: ScaledObject" >> "$OUTPUT_VALUES_FILE"
        echo "  scaleTargetRef:" >> "$OUTPUT_VALUES_FILE"
        #for future to just write the values
        #echo "    kind: ${line[${COLUMN_INDEXES["kind"]}]}" >> "$OUTPUT_VALUES_FILE"
        #echo "    name: ${line[${COLUMN_INDEXES["name"]}]}" >> "$OUTPUT_VALUES_FILE"
        

        #comment from here 
        if [ "${line[${COLUMN_INDEXES["kind"]}]}" == "Deployment" ]; then
        echo "    #kind: ${line[${COLUMN_INDEXES["kind"]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    name: ${line[${COLUMN_INDEXES["name"]}]}" >> "$OUTPUT_VALUES_FILE"       
        elif [ "${line[${COLUMN_INDEXES["kind"]}]}" == "Statefulsets" ]; then
        echo "    kind: ${line[${COLUMN_INDEXES["kind"]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "    name: ${line[${COLUMN_INDEXES["name"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi
        #comment to here 

        echo "  pollingInterval: ${line[${COLUMN_INDEXES["pollingInterval"]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "  cooldownPeriod: ${line[${COLUMN_INDEXES["cooldownPeriod"]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "  minReplicaCount: ${line[${COLUMN_INDEXES["minReplicaCount"]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "  maxReplicaCount: ${line[${COLUMN_INDEXES["maxReplicaCount"]}]}" >> "$OUTPUT_VALUES_FILE"
        echo "  triggers:">> "$OUTPUT_VALUES_FILE"
        

        if [[ "${line[${COLUMN_INDEXES["trigger1_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
             
            echo " Trigger1_Type is empty or whitespace hence Skipping Full Trigger1 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger1_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger1_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger1_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger1_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger1_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger2_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
             
            echo " trigger2_Type is empty or whitespace hence Skipping Full trigger2 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger2_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger2_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger2_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger2_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger2_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger3_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger3_Type is empty or whitespace hence Skipping Full trigger3 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger3_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger3_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger3_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger3_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger3_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger4_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger4_Type is empty or whitespace hence Skipping Full trigger4 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger4_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger4_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger4_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger4_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger4_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi


        if [[ "${line[${COLUMN_INDEXES["trigger5_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger5_Type is empty or whitespace hence Skipping Full trigger5 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger5_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger5_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger5_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger5_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger5_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger6_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger6_Type is empty or whitespace hence Skipping Full trigger6 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger6_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger6_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger6_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger6_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger6_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger7_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger7_Type is empty or whitespace hence Skipping Full trigger7 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger7_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger7_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger7_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger7_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger7_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger8_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger8_Type is empty or whitespace hence Skipping Full trigger8 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger8_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger8_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger8_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger8_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger8_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger9_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger9_Type is empty or whitespace hence Skipping Full trigger9 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger9_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger9_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger9_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger9_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger9_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        if [[ "${line[${COLUMN_INDEXES["trigger10_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
            echo " trigger10_Type is empty or whitespace hence Skipping Full trigger10 values"
        else
            echo "  - type: ${line[${COLUMN_INDEXES["trigger10_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
            echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger10_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger10_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      topic: ${line[${COLUMN_INDEXES["trigger10_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger10_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        fi

        echo "Created YAML file: $OUTPUT_VALUES_FILE"
    fi
done < <(tail -n +2 "$INPUT_FILE")

echo "All valid rows have been written to their respective YAML files"
















        # if [[ "${line[${COLUMN_INDEXES["trigger1_Type"]}]}" =~ ^[[:space:]]*$ ]]; then
        #      
        # else
        #     echo "  - type: ${line[${COLUMN_INDEXES["trigger1_Type"]}]}" >> "$OUTPUT_VALUES_FILE"
        #     echo "    metadata:" >> "$OUTPUT_VALUES_FILE"
        #     echo "      bootstrapServers: ${line[${COLUMN_INDEXES["trigger1_BootstrapServers"]}]}" >> "$OUTPUT_VALUES_FILE"
        #     echo "      consumerGroup: ${line[${COLUMN_INDEXES["trigger1_ConsumerGroup"]}]}" >> "$OUTPUT_VALUES_FILE"
        #     echo "      topic: ${line[${COLUMN_INDEXES["trigger1_topic"]}]}" >> "$OUTPUT_VALUES_FILE"
        #     echo "      lagThreshold: ${line[${COLUMN_INDEXES["trigger1_lagthreshold"]}]}" >> "$OUTPUT_VALUES_FILE"
        # fi



        


        # # Check if trigger1_Type is not null or empty spaces
        # if [ -n "${line[${COLUMN_INDEXES["trigger1_Type"]}]}" ]; then
           
        # fi
