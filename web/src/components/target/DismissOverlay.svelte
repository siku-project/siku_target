<script lang="ts">
  import { actions } from '@/lib/actions'
</script>

<div
  class="pointer-events-auto fixed inset-0 z-30"
  role="presentation"
  onclick={() => actions.dismiss()}
  oncontextmenu={(event) => {
    event.preventDefault()
    actions.dismiss()
  }}
></div>
