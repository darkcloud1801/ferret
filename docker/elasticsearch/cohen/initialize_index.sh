#!/bin/sh

printenv

# Install curl
apk --no-cache add curl

# Wait for ElasticSearch to be ready
until curl_output=$(curl -s -X GET --cacert config/certs/ca/ca.crt "https://es01:9200/_cluster/health" -u elastic:${ELASTIC_PASSWORD} -k); do
  echo "Waiting for Elasticsearch availability..."
  sleep 5
done

while ! echo "${curl_output}" | awk '/"status":"green"/ || /"status":"yellow"/'; do
  echo "Elasticsearch status is not green or yellow. Retrying..."
  sleep 5
  curl_output=$(curl -s -X GET --cacert config/certs/ca/ca.crt "https://es01:9200/_cluster/health" -u elastic:${ELASTIC_PASSWORD} -k)
done
echo "Elasticsearch status is green or yellow. Proceeding..."


echo "Creating Management Role"
curl -s -X POST --cacert config/certs/ca/ca.crt -u elastic:${ELASTIC_PASSWORD} -k -H "Content-Type: application/json" https://es01:9200/_security/role/fscrawler_role -d'
{
  "cluster": ["manage_index_templates", "monitor", "manage"],
  "indices": [
    {
      "names": [ "*" ],
      "privileges": ["create_index", "write", "manage", "all"],
      "allow_restricted_indices": false
    }
  ]
}
';

echo ""
echo "Creating Manager User"
curl -s -X POST --cacert config/certs/ca/ca.crt -u elastic:${ELASTIC_PASSWORD} -k -H "Content-Type: application/json" https://es01:9200/_security/user/fscrawler_user -d'
{
  "password" : "'"${ELASTIC_PASSWORD}"'",
  "roles" : [ "fscrawler_role" ],
  "full_name" : "FSCrawler User",
  "email" : "user@example.com"
}';
sleep 1;

echo ""
echo "Setting kibana_system password";
curl -s -X POST --cacert config/certs/ca/ca.crt -u elastic:${ELASTIC_PASSWORD} -k -H "Content-Type: application/json" https://es01:9200/_security/user/kibana_system/_password -d'
{
  "password": "'"${KIBANA_PASSWORD}"'"
}';
sleep 1;

echo ""
echo "Setting up max async search response size for cluster"
curl -s -X PUT --cacert config/certs/ca/ca.crt -u fscrawler_user:${ELASTIC_PASSWORD} -k -H 'Content-Type: application/json' https://es01:9200/_cluster/settings -d '
{
  "persistent": {
    "search.max_async_search_response_size": "50mb"
  }
}';
sleep 1;

for config in /usr/local/bin/config/fscrawler/*; do
  if [ -d "$config" ] && [ "$(basename "$config")" != "_default" ]; then
    echo -e "Running FSCrawler for config: $(basename "$config")"
#    fscrawler --config_dir /root/.fscrawler --loop 1 $(basename "$config") &

    echo -e "Creating Index for $(basename "$config")"
    curl -s -X PUT --cacert config/certs/ca/ca.crt "https://es01:9200/$(basename "$config")" \
      -u fscrawler_user:${ELASTIC_PASSWORD} -k \
      -H 'Content-Type: application/json' \
      -d @/usr/local/bin/config/elasticsearch/initialization/analyzers.json
    sleep 1

    echo -e "Setting max highlighted offset for $(basename "$config")"
    curl -s -X PUT --cacert config/certs/ca/ca.crt "https://es01:9200/$(basename "$config")/_settings" \
      -u fscrawler_user:${ELASTIC_PASSWORD} -k -H 'Content-Type: application/json' \
      -d'
    {
      "index": {
        "highlight.max_analyzed_offset": 100000000
      }
    }';
  fi
done

#echo "Creating Indexes..."
#curl -s --cacert config/certs/ca/ca.crt -X PUT "https://es01:9200/cohen_individual" \
#  -u fscrawler_user:${ELASTIC_PASSWORD} -k \
#  -H 'Content-Type: application/json' \
#  -d @/usr/local/bin/config/cohen/initialization/analyzers.json
#echo "Cohen Individual Index Created."
#curl -s --cacert config/certs/ca/ca.crt -X PUT "https://es01:9200/cohen_natives" \
#  -u fscrawler_user:${ELASTIC_PASSWORD} -k \
#  -H 'Content-Type: application/json' \
#  -d @/usr/local/bin/config/cohen/initialization/analyzers.json
#echo "Cohen Natives Index Created."


# Make the curl request and capture the HTTP status code
payload=$(curl -o /dev/null -s --cacert config/certs/ca/ca.crt -X GET "https://es01:9200/_ingest/pipeline/content_preprocessor" -u kibana_system:${KIBANA_PASSWORD} -k -w "%{http_code}\n")
echo -e "The Payload"
echo -e ${payload}
# Check if the status code is 404
if [ "$payload" = "404" ]; then
  # Create the pipeline
  echo -e "Creating ingest pipeline..."
  payload=$(curl -s --cacert config/certs/ca/ca.crt -X PUT "https://es01:9200/_ingest/pipeline/content_preprocessor" \
    -u kibana_system:${KIBANA_PASSWORD} -k \
    -H 'Content-Type: application/json' \
    -d @/usr/local/bin/config/elasticsearch/pipelines/preprocessor.json)
    echo -e "Payload: ${payload}"

  echo "Ingest pipeline created."
else
  echo "Ingest pipeline already exists."
fi

# Create a completion signal file
touch /usr/local/bin/init_pipeline_done
#
#tail -f /dev/null


echo -e "Waiting for Kibana availability";
until curl -s -I http://kibana:5601 |  grep -q 'HTTP/1.1 302 Found'; do sleep 30; done;
