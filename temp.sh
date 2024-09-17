#!/bin/bash

CONFIG_FILE="config.json"

json=$(cat "$CONFIG_FILE")

extract_value() {
  local key="$1"
  echo "$json" | sed -n "s/.*\"$key\": \"\([^\"]*\)\".*/\1/p"
}

dev=$(extract_value "dev")
qa=$(extract_value "qa")
imps=$(extract_value "imps")
prod=$(extract_value "prod")

echo "dev: $dev"
echo "qa: $qa"
echo "imps: $imps"
echo "prod: $prod"