<script lang="ts">
  import { ArrowLeft, ChevronRight } from '@lucide/svelte'
  import { actions } from '@/lib/actions'
  import { m } from '@/lib/i18n.svelte'
  import { iconOf } from '@/lib/icons'
  import { placeMenu, placeSubmenu } from '@/lib/placement'
  import { target, type MenuItem } from '@/lib/target.svelte'

  const ROW_HEIGHT = 34
  const SUBMENU_GAP = 6

  let rootWidth = $state(0)
  let rootHeight = $state(0)
  let subWidth = $state(0)
  let subHeight = $state(0)
  let rootElement = $state<HTMLDivElement | null>(null)
  let viewport = $state({ width: window.innerWidth, height: window.innerHeight })

  const menu = $derived(target.menu)
  const submenu = $derived(target.submenu)
  const listHeight = $derived(target.config.menu.maxVisible * ROW_HEIGHT + 8)

  const rootPosition = $derived(
    menu
      ? placeMenu(
          menu.anchor,
          { width: rootWidth, height: rootHeight },
          viewport,
          target.config.menu.offset,
        )
      : null,
  )

  /** The top of the row that opened the submenu, as it sits on screen. */
  const parentRowTop = (): number => {
    if (!rootElement || !submenu || !rootPosition) {
      return rootPosition?.y ?? 0
    }

    const row = rootElement.querySelector<HTMLElement>(
      `[data-id="${CSS.escape(submenu.parentId)}"]`,
    )

    return row ? row.getBoundingClientRect().top : rootPosition.y
  }

  const subPosition = $derived(
    submenu && rootPosition && subWidth > 0
      ? placeSubmenu(
          { ...rootPosition, width: rootWidth, height: rootHeight },
          parentRowTop(),
          { width: subWidth, height: subHeight },
          viewport,
          SUBMENU_GAP,
        )
      : null,
  )

  const resize = (): void => {
    viewport = { width: window.innerWidth, height: window.innerHeight }
  }
</script>

{#snippet rows(items: MenuItem[], openId: string | null)}
  {#if items.length > 0}
    <div class="sk-scroll overflow-y-auto py-1" style:max-height="{listHeight}px">
      {#each items as item (item.id)}
        {@const Icon = iconOf(item.icon)}
        <button
          type="button"
          class="target-menu__row flex w-full items-center gap-2.5 px-3 text-left"
          class:target-menu__row--open={item.id === openId}
          style:height="{ROW_HEIGHT}px"
          role="menuitem"
          data-id={item.id}
          onclick={() => actions.select(item.id)}
        >
          <span class="target-menu__icon flex h-4 w-4 shrink-0 items-center justify-center">
            {#if Icon}
              <Icon class="h-3.5 w-3.5" />
            {/if}
          </span>
          <span class="target-menu__label min-w-0 flex-1 truncate text-[13px] font-medium">
            {item.label}
          </span>
          {#if item.submenu}
            <span class="target-menu__chevron flex h-3.5 w-3.5 shrink-0 items-center">
              <ChevronRight class="h-3.5 w-3.5" />
            </span>
          {/if}
        </button>
      {/each}
    </div>
  {:else}
    <div class="px-3 py-3 text-xs text-sk-faint">{m.menu_empty()}</div>
  {/if}
{/snippet}

<svelte:window onresize={resize} />

{#if menu && rootPosition}
  <div
    class="target-menu pointer-events-auto fixed z-50 flex flex-col overflow-hidden"
    style:left="{rootPosition.x}px"
    style:top="{rootPosition.y}px"
    style:width="{target.config.menu.width}px"
    style:visibility={rootWidth > 0 ? 'visible' : 'hidden'}
    bind:this={rootElement}
    bind:clientWidth={rootWidth}
    bind:clientHeight={rootHeight}
    role="menu"
    tabindex="-1"
    onmouseenter={() => actions.hover(true)}
    onmouseleave={() => actions.hover(false)}
    onclick={(event) => event.stopPropagation()}
    oncontextmenu={(event) => event.preventDefault()}
    onkeydown={(event) => event.key === 'Escape' && actions.close()}
  >
    <div class="target-menu__head flex h-8 items-center px-3">
      <span class="target-menu__title truncate">{m.menu_title()}</span>
    </div>

    {@render rows(menu.items, submenu?.parentId ?? null)}
  </div>

  {#if submenu}
    <div
      class="target-menu target-menu--sub pointer-events-auto fixed z-50 flex flex-col overflow-hidden"
      style:left="{subPosition?.x ?? 0}px"
      style:top="{subPosition?.y ?? 0}px"
      style:width="{target.config.menu.width}px"
      style:visibility={subPosition ? 'visible' : 'hidden'}
      bind:clientWidth={subWidth}
      bind:clientHeight={subHeight}
      role="menu"
      tabindex="-1"
      onmouseenter={() => actions.hover(true)}
      onmouseleave={() => actions.hover(false)}
      onclick={(event) => event.stopPropagation()}
      oncontextmenu={(event) => event.preventDefault()}
      onkeydown={(event) => event.key === 'Escape' && actions.close()}
    >
      <div class="target-menu__head flex h-8 items-center gap-2 px-2.5">
        <button
          type="button"
          class="target-menu__back flex h-5 w-5 items-center justify-center rounded-md"
          aria-label={m.menu_back()}
          onclick={() => actions.back()}
        >
          <ArrowLeft class="h-3.5 w-3.5" />
        </button>
        <span class="target-menu__title truncate">{submenu.title}</span>
      </div>

      {@render rows(submenu.items, null)}
    </div>
  {/if}
{/if}

<style>
  /**
   * Glass over the game, without blur: the world shows through, a thin
   * frosted edge catches the light, and the text keeps a soft shadow so it
   * reads on any background.
   */
  .target-menu {
    border-radius: 10px;
    border: 1px solid rgba(226, 240, 252, 0.16);
    background: linear-gradient(180deg, rgba(14, 18, 24, 0.66) 0%, rgba(8, 10, 14, 0.72) 100%);
    box-shadow:
      0 0 0 1px rgba(0, 0, 0, 0.35),
      0 18px 40px -22px rgba(0, 0, 0, 0.9),
      inset 0 1px 0 rgba(255, 255, 255, 0.06);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
  }

  .target-menu--sub {
    border-color: rgba(108, 182, 246, 0.28);
  }

  .target-menu__head {
    border-bottom: 1px solid rgba(255, 255, 255, 0.07);
    background: rgba(255, 255, 255, 0.025);
  }

  .target-menu__title {
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    color: rgba(226, 240, 252, 0.55);
  }

  .target-menu__row {
    transition:
      background 100ms ease,
      color 100ms ease;
  }

  .target-menu__icon,
  .target-menu__chevron {
    color: rgba(226, 240, 252, 0.5);
  }

  .target-menu__label {
    color: rgba(255, 255, 255, 0.9);
  }

  .target-menu__row:hover,
  .target-menu__row--open {
    background: rgba(108, 182, 246, 0.16);
  }

  .target-menu__row:hover .target-menu__label,
  .target-menu__row--open .target-menu__label,
  .target-menu__row:hover .target-menu__icon,
  .target-menu__row--open .target-menu__icon,
  .target-menu__row:hover .target-menu__chevron,
  .target-menu__row--open .target-menu__chevron {
    color: var(--sk-accent-text);
  }

  .target-menu__back {
    color: rgba(226, 240, 252, 0.55);
    transition:
      background 100ms ease,
      color 100ms ease;
  }

  .target-menu__back:hover {
    background: rgba(255, 255, 255, 0.08);
    color: white;
  }
</style>
