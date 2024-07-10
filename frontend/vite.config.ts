import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';

/** @type {import('vite').UserConfig} */
export default defineConfig({
	plugins: [
		sveltekit(),
		{
			name: 'filepath',
			transform(code, id) {
				return code.replace('FILEPATH', `'${id}'`);
			}
		}
	],
	test: {
		include: ['src/**/*.{test,spec}.{js,ts}']
	}
});

