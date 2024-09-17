#!/bin/bash

# Check if CSV file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file.csv> env_name=<env_name>"
  exit 1
fi

# Check if env_name is provided
if [[ $2 != env_name=* ]]; then
  echo "Usage: $0 <input_file.csv> env_name=<env_name>"
  exit 1
fi

INPUT_FILE=$1
ENV_NAME=${2#env_name=}
OUTPUT_VALUES_FILE="values.yaml"
HELM_CHART_PATH="my-scaledobject-chart"

# Initialize or clear the values.yaml file
> "$OUTPUT_VALUES_FILE"

echo "scaledObjects:" >> "$OUTPUT_VALUES_FILE"


TARGET_COLUMNS=("name" "namespace" "kind" "based_config" "pollingInterval" "cooldownPeriod" "minReplicaCount" "maxReplicaCount" 
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

# Process each line in the CSV
while IFS=, read -r -a line; do
    if [[ -z "${line[*]}" ]]; then
        continue
    fi

    # Replace placeholders with the environment name
    name=$(echo "${line[${COLUMN_INDEXES[0]}]}" | sed "s/{{ env_name }}/$ENV_NAME/g")
    consumer_group=$(echo "${line[${COLUMN_INDEXES[10]}]}" | sed "s/{{ env_name }}/$ENV_NAME/g")

    echo "  - name: $name" >> "$OUTPUT_VALUES_FILE"
    echo "    namespace: ${line[${COLUMN_INDEXES[1]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "    pollingInterval: ${line[${COLUMN_INDEXES[3]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "    cooldownPeriod: ${line[${COLUMN_INDEXES[4]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "    minReplicaCount: ${line[${COLUMN_INDEXES[5]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "    maxReplicaCount: ${line[${COLUMN_INDEXES[6]}]}" >> "$OUTPUT_VALUES_FILE"
    echo "    scaleTargetRef:" >> "$OUTPUT_VALUES_FILE"
    echo "      name: $name" >> "$OUTPUT_VALUES_FILE"

    # Handle the "kind" value
    if [ "${line[${COLUMN_INDEXES[2]}]}" != "Deployment" ]; then
        echo "      kind: ${line[${COLUMN_INDEXES[2]}]}" >> "$OUTPUT_VALUES_FILE"
    fi

    echo "    triggers:" >> "$OUTPUT_VALUES_FILE"

    for trigger_index in {0..9}; do
        type_index=$((7 + trigger_index * 5))
        bootstrap_index=$((8 + trigger_index * 5))
        consumer_index=$((9 + trigger_index * 5))
        topic_index=$((10 + trigger_index * 5))
        lag_index=$((11 + trigger_index * 5))

        if [[ -n "${line[${COLUMN_INDEXES[$type_index]}]}" ]]; then
            echo "      - type: ${line[${COLUMN_INDEXES[$type_index]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "        metadata:" >> "$OUTPUT_VALUES_FILE"

            value=${line[${COLUMN_INDEXES[$bootstrap_index]}]}
            bootstrap_server=$(echo "$value" | sed 's/=/,/g')
            echo "          bootstrapServers: $bootstrap_server" >> "$OUTPUT_VALUES_FILE"
            echo "          consumerGroup: $consumer_group" >> "$OUTPUT_VALUES_FILE"
            echo "          topic: ${line[${COLUMN_INDEXES[$topic_index]}]}" >> "$OUTPUT_VALUES_FILE"
            echo "          lagThreshold: ${line[${COLUMN_INDEXES[$lag_index]}]}" >> "$OUTPUT_VALUES_FILE"
        fi
    done

done < <(tail -n +2 "$INPUT_FILE")

# Deploy the Helm chart for the environment
echo "Deploying Helm chart for environment: $ENV_NAME"
#helm upgrade --install "$ENV_NAME-scaledobjects" "$HELM_CHART_PATH" --values "$OUTPUT_VALUES_FILE" --namespace "${line[${COLUMN_INDEXES[1]}]}" --create-namespace

#echo "Helm chart deployed successfully for environment: $ENV_NAME."
