#!/bin/sh
echo "Starting FSCrawler with the following configurations:"
ls -la /root/.fscrawler/

for config in /root/.fscrawler/*; do
  if [ -d "$config" ]; then
    echo "Running FSCrawler for config: $(basename "$config")"
    fscrawler --config_dir /root/.fscrawler --loop 1 $(basename "$config") &
  fi
done

# Wait for all background processes to finish
wait