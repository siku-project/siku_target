<script lang="ts">
  import { Check, LayoutDashboard, MonitorOff } from '@lucide/svelte'
  import { Button } from '$lib/components/ui/button'
  import * as Dialog from '$lib/components/ui/dialog'
  import * as Tooltip from '$lib/components/ui/tooltip'

  let {
    views,
    currentView,
    onSelect,
  }: { views: string[]; currentView: string; onSelect: (view: string) => void } = $props()

  let open = $state(false)

  const toggle = (view: string): void => {
    onSelect(currentView === view ? 'none' : view)
  }
</script>

<div class="fixed bottom-7 left-7 z-50">
  <Tooltip.Provider>
    <Tooltip.Root>
      <Tooltip.Trigger>
        {#snippet child({ props })}
          <Button
            {...props}
            variant="outline"
            size="icon"
            class="sk-panel h-12 w-12 !rounded-full text-sk-soft hover:text-sk"
            onclick={() => (open = true)}
          >
            <LayoutDashboard class="h-[17px] w-[17px]" />
          </Button>
        {/snippet}
      </Tooltip.Trigger>
      <Tooltip.Content side="right" class="sk-panel border-white/[0.08] text-xs text-sk-body">
        Interfaces
      </Tooltip.Content>
    </Tooltip.Root>
  </Tooltip.Provider>

  <Dialog.Root bind:open>
    <Dialog.Content
      class="sk-panel w-[440px] gap-0 border-white/[0.105] bg-[var(--sk-panel)] p-7 sm:rounded-[var(--sk-radius-panel)]"
    >
      <Dialog.Header class="mb-6 space-y-0 text-center sm:text-center">
        <Dialog.Title class="sk-label text-center font-medium">Interfaces</Dialog.Title>
        <Dialog.Description class="sr-only">Pick the view to display</Dialog.Description>
      </Dialog.Header>

      {#if views.length > 0}
        <div class="flex flex-col gap-2.5">
          {#each views as view (view)}
            <button
              type="button"
              class="sk-row flex items-center justify-between px-5 py-3.5 text-left {currentView ===
              view
                ? 'sk-row--active'
                : ''}"
              onclick={() => toggle(view)}
            >
              <span
                class="text-sm font-medium {currentView === view
                  ? 'text-sk-accent'
                  : 'text-sk-body'}"
              >
                {view}
              </span>
              {#if currentView === view}
                <Check class="h-3.5 w-3.5 text-primary" />
              {/if}
            </button>
          {/each}
        </div>
      {:else}
        <div class="flex flex-col items-center gap-5 py-10">
          <MonitorOff class="h-9 w-9 text-sk-faint" />
          <span class="text-sm font-medium text-sk-muted">No interface yet</span>
          <span class="text-xs text-sk-faint">Create one and register it here</span>
        </div>
      {/if}
    </Dialog.Content>
  </Dialog.Root>
</div>
