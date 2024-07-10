// src/routes/+page.server.ts
import type { Actions, PageServerLoad } from './$types';
import {getAllIndexes, searchElastic } from '$lib/elasticsearch';
//
/** @type {import('./$types').PageServerLoad} */
export const load = async ({ url }) => {
  // @ts-ignore
  const allIndexes = (await getAllIndexes()).sort((a, b) => a.localeCompare(b));
  return { allIndexes };
};

/** @type {import('./$types').Actions} */
export const actions = {
  search: async ({ request }) => {
    const formData = await request.formData();
    const queryStr = formData.get('queryStr');
    const selectedIndex = formData.get('selectedIndex');
    if (typeof queryStr !== 'string') {
      return { status: 400, body: 'Invalid query' };
    }
    if (typeof selectedIndex !== 'string') {
      return { status: 400, body: 'Invalid query' };
    }
    const results = await searchElastic(queryStr, selectedIndex);
    return { results: results, query: queryStr, index: selectedIndex };
  }
};