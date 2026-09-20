<script lang="ts">
  import { actions } from '@/lib/actions'

  /** A click on the world: the pointer position as fractions of the screen. */
  const pick = (event: MouseEvent): void => {
    actions.click(event.clientX / window.innerWidth, event.clientY / window.innerHeight)
  }
</script>

<div
  class="pointer-events-auto fixed inset-0 z-30 cursor-crosshair"
  role="presentation"
  onclick={pick}
  oncontextmenu={(event) => {
    event.preventDefault()
    actions.close()
  }}
></div>
