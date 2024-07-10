<script>
  import { createQuery } from '@tanstack/svelte-query';
  import { writable } from 'svelte/store';

  const ELASTICSEARCH_URL = import.meta.env.VITE_ELASTICSEARCH_URL;
  let queries = writable([{ query: '', operator: 'AND' }]);
  let results = writable([]);

  function addQuery() {
    queries.update(qs => [...qs, { query: '', operator: 'AND' }]);
  }

  function removeQuery(index) {
    queries.update(qs => qs.filter((_, i) => i !== index));
  }

  function createElasticSearchQuery(queries) {
    const must = [];
    const should = [];

    queries.forEach(q => {
      if (q.operator === 'AND') {
        must.push({ match: { content: q.query } });
      } else {
        should.push({ match: { content: q.query } });
      }
    });

    return {
      query: {
        bool: {
          must,
          should,
          minimum_should_match: 1
        }
      },
      highlight: {
        fields: {
          content: {}
        }
      }
    };
  }

  const { refetch } = createQuery({
    queryKey: ['searchResults'],
    queryFn: async ({ queryKey }) => {
      const queries = queryKey[1];
      const elasticSearchQuery = createElasticSearchQuery(queries);
      const response = await fetch(`${ELASTICSEARCH_URL}/_search`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(elasticSearchQuery)
      });
      const data = await response.json();
      return data.hits.hits.map(hit => ({ highlight: hit.highlight.content[0] }));
    },
    enabled: false, // Initially disabled
    onSuccess: data => results.set(data),
  });

  function handleSubmit() {
    queries.subscribe(qs => {
      refetch({ queryKey: ['searchResults', qs] });
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  {#each $queries as { query, operator }, index}
    <div>
      <input type="text" bind:value={query} placeholder="Enter search string" />
      <select bind:value={operator}>
        <option value="AND">AND</option>
        <option value="OR">OR</option>
      </select>
      {#if index > 0}
        <button type="button" on:click={() => removeQuery(index)}>Remove</button>
      {/if}
    </div>
  {/each}
  <button type="button" on:click={addQuery}>Add Query</button>
  <button type="submit">Submit</button>
</form>

{#if $results.length}
  <table>
    <thead>
      <tr>
        <th>Highlighted Text</th>
      </tr>
    </thead>
    <tbody>
      {#each $results as result}
        <tr>
          <td>{@html result.highlight}</td>
        </tr>
      {/each}
    </tbody>
  </table>
{/if}