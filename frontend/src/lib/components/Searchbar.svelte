<script>
    export let searchResponse;

    import {
        Search,
        Button,
        Dropdown,
        DropdownItem,
    } from 'flowbite-svelte';
    import {ArrowLeftToBracketOutline, ChevronDownOutline, SearchOutline} from 'flowbite-svelte-icons';

    const items = [
        {
            label: 'All categories'
        },
        {
            label: 'Mockups'
        },
        {
            label: 'Templates'
        },
        {
            label: 'Design'
        },
        {
            label: 'Logos'
        }
    ]

    let selectedIndex = 'All Indexes';

    function handleSubmit(event) {
        event.preventDefault();
        const formData = new FormData(event.target);
        formData.set('selectedIndex', selectedIndex); // Ensure the dropdown value is set

        // Here you can send the form data using fetch, axios, or any other method
        fetch('?/search', {
            method: 'POST',
            body: formData,
        }).then(response => {
            console.log('Form submitted', response);
            searchResponse = JSON.stringify(response.json()['data']);
        }).catch(error => {
            console.error('Error submitting form', error);
        });
    }


</script>

<form class="flex" on:submit={handleSubmit}>
    <div class="relative">
        <Button class="rounded-e-none whitespace-nowrap border border-e-0 border-primary-700">
            {selectedIndex}
            <ChevronDownOutline class="w-2.5 h-2.5 ms-2.5"/>
        </Button>
        <Dropdown bind:value={selectedIndex} classContainer="w-40">
            {#each items as {label}}
                <DropdownItem
                        on:click={() => {
            selectedIndex = label;
          }}
                        class={selectedIndex === label ? 'underline' : ''}
                >
                    {label}
                </DropdownItem>
            {/each}
        </Dropdown>
    </div>
    <Search name="queryStr" size="md" class="rounded-none py-2.5"
            placeholder="Search Mockups, Logos, Design Templates..."/>
    <Button class="!p-2.5 rounded-s-none" type="submit">
        <SearchOutline class="w-6 h-6"/>
    </Button>
</form>
