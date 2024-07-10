<script>
	import {
		DarkMode,
		Dropdown,
		DropdownItem,
		NavBrand,
		NavHamburger,
		NavLi,
		NavUl,
		Navbar,
		Search
	} from 'flowbite-svelte';
	import { ChevronDownOutline } from 'flowbite-svelte-icons';

	export let fluid = true;
	export let list = false;
</script>

<Navbar {fluid} class="text-black" color="default" let:NavContainer>
	<NavContainer class="mb-px mt-px px-1" {fluid}>
		<NavBrand href="/" class={list ? 'w-40' : 'lg:w-60'}>
			<img
				src="/images/dog-app-icon.svg"
				class="me-4 h-14 sm:h-16"
				alt="Flowbite Logo"
			/>
			<span
				class="ml-px self-center whitespace-nowrap text-xl font-semibold dark:text-white sm:text-2xl"
			>
				Legal Document Search
			</span>
		</NavBrand>
		<div class="ms-auto flex items-center text-gray-500 dark:text-gray-400 sm:order-2">
			<DarkMode />
		</div>
	</NavContainer>
</Navbar>
