#!/bin/sh
echo "Starting FSCrawler with the following configurations:"
ls -la /root/.fscrawler/

echo $JAVA_HOME

keytool -delete -alias elastic_security -keystore "$JAVA_HOME\lib\security\cacerts" -storepass changeit -noprompt || true
keytool -import -alias elastic_security -keystore "$JAVA_HOME\lib\security\cacerts" -file /usr/share/fscrawler/certs/ca/ca.crt -storepass changeit -noprompt


for config in /root/.fscrawler/*; do
  if [ -d "$config" ]; then
    echo "Running FSCrawler for config: $(basename "$config")"
    fscrawler --config_dir /root/.fscrawler --loop 1 $(basename "$config") &
  fi
done

wait