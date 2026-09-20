<script lang="ts">
  import { Code } from '@lucide/svelte'
  import { Separator } from '$lib/components/ui/separator'
  import { RESOURCE } from '@/lib/nui'
  import { stack } from '@/lib/stack'

  let { currentView }: { currentView: string } = $props()

  let expanded = $state(false)
</script>

<div
  class="fixed right-7 top-7 z-50"
  role="presentation"
  onmouseenter={() => (expanded = true)}
  onmouseleave={() => (expanded = false)}
>
  <div
    class="sk-panel overflow-hidden transition-all duration-300 ease-out {expanded
      ? 'w-64'
      : 'h-12 w-12 !rounded-full'}"
  >
    {#if !expanded}
      <div class="flex h-12 w-12 items-center justify-center text-sk-soft">
        <Code class="h-[17px] w-[17px]" />
      </div>
    {:else}
      <div class="flex flex-col gap-4 p-6">
        <span class="sk-label text-center">{RESOURCE}</span>

        <Separator class="bg-white/[0.085]" />

        <div class="flex flex-col gap-2.5">
          {#each stack as entry (entry.name)}
            <div class="flex items-center justify-between">
              <span class="text-xs font-medium text-sk-soft">{entry.name}</span>
              <span class="sk-mono text-[11px] text-sk-body">{entry.version}</span>
            </div>
          {/each}
        </div>

        <Separator class="bg-white/[0.085]" />

        <div class="flex items-center justify-between">
          <span class="text-xs font-medium text-sk-soft">View</span>
          <span
            class="text-xs font-medium {currentView !== 'none'
              ? 'text-sk-accent'
              : 'text-sk-faint'}"
          >
            {currentView !== 'none' ? currentView : 'None'}
          </span>
        </div>
      </div>
    {/if}
  </div>
</div>
