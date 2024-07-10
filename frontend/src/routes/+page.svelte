<script>
    import {
        Search,
        Button,
        Dropdown,
        DropdownItem,
        Table,
        TableBody,
        TableBodyCell,
        TableBodyRow,
        TableHead,
        TableHeadCell,
    } from 'flowbite-svelte';
    import {ChevronDownOutline, SearchOutline} from 'flowbite-svelte-icons';
    import {enhance} from '$app/forms';

    import Header from '$lib/components/Header.svelte';

    /** @type {import('./$types').PageData} */
	export let data;
    export let form;

    const indexDropdownValues = data.allIndexes.map(str => ({ label: str }));
    indexDropdownValues.unshift({ label: 'All Indexes' });

    let selectedIndex = 'All Indexes';
    let formLoading = false;
</script>

<div class="flex flex-col min-h-screen">
    <header>
        <Header/>

        <form class="flex" method="POST" action="?/search"
              use:enhance={() => {
                  formLoading = true;
                  return async ({ update }) => {
                      formLoading = false;
                      update({ reset: false });
                  };
              }}
        >
            <div class="relative">
                <input type="hidden" id="selectedIndex" name="selectedIndex" value="{selectedIndex === 'All Indexes' ? '' : selectedIndex}">
                <Button class="rounded-e-none whitespace-nowrap border border-e-0 border-primary-700">
                    {selectedIndex}
                    <ChevronDownOutline class="w-2.5 h-2.5 ms-2.5"/>
                </Button>
                <Dropdown classContainer="w-40">
                    {#each indexDropdownValues as {label}}
                        <DropdownItem on:click={() => { selectedIndex = label; }} class={selectedIndex === label ? 'underline' : ''} >
                            {label}
                        </DropdownItem>
                    {/each}
                </Dropdown>
            </div>
            <Search name="queryStr" size="md" class="rounded-none py-2.5" placeholder="Search PDFs, Docs, XML, Images..."/>
            <Button class="!p-2.5 rounded-s-none" type="submit">
                <SearchOutline class="w-6 h-6"/>
            </Button>
        </form>
    </header>
    <div class="flex-grow">
        <main>
            <div>
            {#if formLoading}
                <div class="flex justify-center items-center mt-10">
                    <div class="loader"></div>
                </div>
            {/if}
            {#if form?.results && !formLoading}
                <Table class="mt-5">
                    <TableHead>
                        <TableHeadCell>Index</TableHeadCell>
                        <TableHeadCell>Filename</TableHeadCell>
                        <TableHeadCell>Highlight</TableHeadCell>
                    </TableHead>
                    <TableBody tableBodyClass="divide-y">
                        {#each form?.results || [] as result}
                            {#each result?.highlights || [] as highlight}
                                <TableBodyRow>
                                    <TableBodyCell>{result?.index}</TableBodyCell>
                                    <TableBodyCell>{result?.id}</TableBodyCell>
                                    <!--        <TableBodyCell>{result?.path}</TableBodyCell>-->
                                    <TableBodyCell>{@html highlight}</TableBodyCell>
                                </TableBodyRow>
                            {/each}
                        {/each}
                    </TableBody>
                    <tfoot>
                        <TableHeadCell>Index</TableHeadCell>
                        <TableHeadCell>Filename</TableHeadCell>
                        <TableHeadCell>Highlight</TableHeadCell>
                    </tfoot>
                </Table>
            {/if}
            </div>
        </main>
    </div>
</div>


<style>
    :global(.highlight) {
        margin: 5px 0;
        font-weight: bolder;
        font-size: 1.1rem;
        color: #EB4F27;
    }

    :global(thead) {
        height:32px;
		position: sticky;
		inset-block-start: 0;
    }
    :global(tbody) {
        height: 80%;
    }
    :global(th) {
		border-bottom:1px solid #e0e0e0;
		border-top:1px solid #e0e0e0;
	}
    tfoot {
		height: 32px;
		position: sticky;
		inset-block-end: 0;
	}

    /* HTML: <div class="loader"></div> */
    .loader {
      display: inline-grid;
      width: 80px;
      aspect-ratio: 1;
    }
    .loader:before,
    .loader:after {
      content:"";
      grid-area: 1/1;
      border-radius: 50%;
      animation: l3-0 2s alternate infinite ease-in-out;
    }
    .loader:before {
      margin: 25%;
      background: repeating-conic-gradient(#EB4F27 0 60deg,#27C3EB 0 120deg);
      translate: 0 50%;
      rotate: -150deg;
    }
    .loader:after {
      padding: 10%;
      margin: -10%;
      background: repeating-conic-gradient(#27C3EB 0 30deg,#EB4F27 0 60deg);
      mask:linear-gradient(#0000 50%,#000 0) content-box exclude,linear-gradient(#0000 50%,#000 0);
      rotate: -75deg;
      animation-name: l3-1;
    }
    @keyframes l3-0 {to{rotate: 150deg}}
    @keyframes l3-1 {to{rotate:  75deg}}
</style>