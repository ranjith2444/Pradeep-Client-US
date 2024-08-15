#!/bin/bash

# Check if CSV file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file.csv>"
  exit 1
fi

INPUT_FILE=$1
OUTPUT_VALUES_FILE="values.yaml"

# Initialize values.yaml
echo "scaledObjects:" > $OUTPUT_VALUES_FILE

# Read the CSV file and process each line
while IFS=, read -r name namespace pollingInterval cooldownPeriod minReplicaCount maxReplicaCount \
  triggerType1 bootstrapServers1 consumerGroup1 topic1 lagThreshold1 \
  triggerType2 bootstrapServers2 consumerGroup2 topic2 lagThreshold2
do
  if [ "$name" != "name" ]; then # Skip header
    echo "  - name: $name" >> $OUTPUT_VALUES_FILE
    echo "    namespace: $namespace" >> $OUTPUT_VALUES_FILE
    echo "    pollingInterval: $pollingInterval" >> $OUTPUT_VALUES_FILE
    echo "    cooldownPeriod: $cooldownPeriod" >> $OUTPUT_VALUES_FILE
    echo "    minReplicaCount: $minReplicaCount" >> $OUTPUT_VALUES_FILE
    echo "    maxReplicaCount: $maxReplicaCount" >> $OUTPUT_VALUES_FILE
    echo "    triggers:" >> $OUTPUT_VALUES_FILE

    # Trigger 1
    echo "      - type: $triggerType1" >> $OUTPUT_VALUES_FILE
    echo "        metadata:" >> $OUTPUT_VALUES_FILE
    echo "          bootstrapServers: $bootstrapServers1" >> $OUTPUT_VALUES_FILE
    echo "          consumerGroup: $consumerGroup1" >> $OUTPUT_VALUES_FILE
    echo "          topic: $topic1" >> $OUTPUT_VALUES_FILE
    echo "          lagThreshold: $lagThreshold1" >> $OUTPUT_VALUES_FILE

    # Check if there is a second trigger
    if [ -n "$triggerType2" ]; then
      echo "      - type: $triggerType2" >> $OUTPUT_VALUES_FILE
      echo "        metadata:" >> $OUTPUT_VALUES_FILE
      echo "          bootstrapServers: $bootstrapServers2" >> $OUTPUT_VALUES_FILE
      echo "          consumerGroup: $consumerGroup2" >> $OUTPUT_VALUES_FILE
      echo "          topic: $topic2" >> $OUTPUT_VALUES_FILE
      echo "          lagThreshold: $lagThreshold2" >> $OUTPUT_VALUES_FILE
    fi
  fi
done < $INPUT_FILE

echo "Generated $OUTPUT_VALUES_FILE from $INPUT_FILE"
