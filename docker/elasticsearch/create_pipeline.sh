#!/bin/bash

# Wait for Elasticsearch to be available
until  curl -s -X GET --cacert config/certs/ca/ca.crt "https://es01:9200/_cluster/health" -u kibana_system:${KIBANA_PASSWORD} -k | grep -q '"status":"green"'; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done

# Check if the pipeline already exists
if curl -s -X GET --cacert config/certs/ca/ca.crt "https://es01:9200/_ingest/pipeline/content_preprocessor" -u kibana_system:${KIBANA_PASSWORD} -k | grep -q '^\s*$'; then
  # Create the pipeline
  echo "Creating ingest pipeline..."
  curl -s --cacert config/certs/ca/ca.crt -X PUT "https://es01:9200/_ingest/pipeline/content_preprocessor" \
    -u kibana_system:${KIBANA_PASSWORD} -k \
    -H 'Content-Type: application/json' \
    -d @/usr/share/elasticsearch/config/pipelines/preprocessor.json
  echo "Ingest pipeline created."
else
  echo "Ingest pipeline already exists."
fi
