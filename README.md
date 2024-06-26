# Ferret

A containerized application that indexes files in a specified folder, and distributes information onto an 
elasticsearch index.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)

## Installation

Instructions on how to install and set up the project.

```sh
# Clone the repository
git clone https://github.com/darkcloud1801/ferret.git

# Navigate to the project directory
cd ferret
```

## Usage
```sh
# Starting all the services, and automatically start indexing
docker compose up

# Stop all services for when you want to add a new index.
docker compose -f docker-compose.yaml -p ferret stop es01 pipeline-loader setup fscrawler kibana
```

## Features
1. ElasticSearch
2. Kibana
3. FSCrawler