#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Placeholder for whatever data-fetching logic your script implements
GOSSIP_KEY=$(consul keygen)

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg key "$GOSSIP_KEY" '{"key":$key}'