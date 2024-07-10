// src/lib/elasticsearch.ts
import fs from 'fs';
import path from 'path';
import { Client } from '@elastic/elasticsearch'
import type { SearchHit } from '@elastic/elasticsearch/lib/api/types'
import { env } from '$env/dynamic/private'
import { fileURLToPath } from 'url';

// Get the directory path
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const username: string = 'elastic';
const password: string = 'admin1234!';
const certPath: string = env.CERT_PATH || `../../../data/elasticsearch/certs/ca/ca.crt`;

const esUrl = env.ELASTICSEARCH_URL || 'https://localhost:9200';
console.log("Node Env ", env.NODE_ENV);
console.log("Origin ", env.ORIGIN);
console.log("ES ", esUrl);
console.log("Cert ", certPath);
console.log(FILEPATH);

export async function getElasticClient(): Promise<Client> {
  return new Client({
    node: esUrl,
    auth: {
      username: username,
      password: password,
    },
    tls: {
      ca: fs.readFileSync(path.join(__dirname, certPath)),
      rejectUnauthorized: false, // Set to false if using self-signed certificates
    },
  });
}

interface SearchResult {
  id: string;
  index: string;
  path: string;
  content: string;
  highlights: string[];
}

interface ElasticsearchSource {
  title: string;
  content: string;
}

export async function searchElastic(query: string, index: string): Promise<SearchResult[]> {
  const client = await getElasticClient();
  const result = await client.search({
    index: index,
    size: 100,
    _source: ["path"],
    query: {
      bool: {
        should: [
          {
            match: {
              content: {
                query: query
              }
            }
          }
        ]
      }
    },
    highlight : {
      pre_tags: ["<span class='highlight'>"],
      post_tags: ["</span>"],
      fields : {
        content : {
          fragment_size: 300,
          number_of_fragments : 3
        }
      }
    }
  });

  return result.hits.hits.map((hit: SearchHit) => ({
    id: hit._id,
    index: hit._index,
    path: hit._source.path.real,
    // content: hit._source.content,
    highlights: hit.highlight.content
    // highlight: hit._source.highlight
  }))
}

export async function getAllIndexes(): Promise<(string | undefined)[]> {
  const client = await getElasticClient();
  const allIndexInfo = await client.cat.indices({format: 'json'});
  return allIndexInfo
      // @ts-ignore
      .filter(item => !item.index.endsWith('_folder'))
      .map(item => item.index);
}
