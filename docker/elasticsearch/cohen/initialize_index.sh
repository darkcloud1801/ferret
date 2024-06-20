#!/bin/sh

printenv

# Install curl
apk --no-cache add curl

# Wait for Elasticsearch to be available
until curl -s -X GET --cacert config/certs/ca/ca.crt "https://es01:9200/_cluster/health" -u kibana_system:admin1234! -k | grep -q '"status":"green"'; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done


echo "Creating cohen index..."
curl -s --cacert config/certs/ca/ca.crt -X PUT "https://es01:9200/cohen" \
  -u kibana_system:${KIBANA_PASSWORD} -k \
  -H 'Content-Type: application/json' \
  -d @/usr/local/bin/config/cohen/initialization/analyzers.json
echo "Cohen Index Created."


# Make the curl request and capture the HTTP status code
payload=$(curl -s -X GET --cacert config/certs/ca/ca.crt "https://es01:9200/_ingest/pipeline/content_preprocessor" -u kibana_system:admin1234! -k)
echo ${payload}
# Check if the status code is 404
if [ "$payload" = '{}' ]; then
  # Create the pipeline
  echo "Creating ingest pipeline..."
  curl -s --cacert config/certs/ca/ca.crt -X PUT "https://es01:9200/_ingest/pipeline/content_preprocessor" \
    -u kibana_system:${KIBANA_PASSWORD} -k \
    -H 'Content-Type: application/json' \
    -d @/usr/local/bin/config/cohen/pipelines/preprocessor.json
  echo "Ingest pipeline created."
else
  echo "Ingest pipeline already exists."
fi

# Create a completion signal file
touch /usr/local/bin/init_pipeline_done
#
tail -f /dev/null