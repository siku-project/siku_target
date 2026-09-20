<script lang="ts">
  import { iconOf } from '@/lib/icons'
  import { target } from '@/lib/target.svelte'

  const Icon = $derived(iconOf(target.config.reticle.icon))
  const color = $derived(
    target.reticle === 'active' ? target.config.reticle.active : target.config.reticle.passive,
  )
</script>

{#if target.reticle && Icon}
  <div
    class="reticle pointer-events-none fixed left-1/2 top-1/2 z-40 -translate-x-1/2 -translate-y-1/2"
    class:reticle--active={target.reticle === 'active'}
    style:color
    style:width="{target.config.reticle.size}px"
    style:height="{target.config.reticle.size}px"
    aria-hidden="true"
  >
    <Icon class="h-full w-full" strokeWidth={2.2} />
  </div>
{/if}

<style>
  .reticle {
    filter: drop-shadow(0 0 2px rgba(0, 0, 0, 0.6));
    transition:
      color 120ms ease,
      transform 120ms ease;
  }

  .reticle--active {
    transform: translate(-50%, -50%) scale(1.12);
  }
</style>
