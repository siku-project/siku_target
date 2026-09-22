<script lang="ts">
  import DismissOverlay from '@/components/target/DismissOverlay.svelte'
  import FreeOverlay from '@/components/target/FreeOverlay.svelte'
  import Reticle from '@/components/target/Reticle.svelte'
  import TargetMenu from '@/components/target/TargetMenu.svelte'
  import { actions } from '@/lib/actions'
  import { target } from '@/lib/target.svelte'

  const handleKeyboard = (event: KeyboardEvent): void => {
    if (target.active && event.key === 'Escape') {
      event.preventDefault()
      actions.close()
    }
  }
</script>

<svelte:window onkeydown={handleKeyboard} />

{#if target.active}
  {#if target.isFree}
    <FreeOverlay />
  {:else}
    <Reticle />
    {#if target.menu}
      <DismissOverlay />
    {/if}
  {/if}

  <TargetMenu />
{/if}
