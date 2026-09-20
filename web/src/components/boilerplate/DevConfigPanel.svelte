<script lang="ts">
  import { Settings2 } from '@lucide/svelte'
  import { Button } from '$lib/components/ui/button'
  import * as Dialog from '$lib/components/ui/dialog'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Separator } from '$lib/components/ui/separator'
  import { Switch } from '$lib/components/ui/switch'
  import * as Tooltip from '$lib/components/ui/tooltip'
  import { actions } from '@/lib/actions'
  import { locale } from '@/lib/locale.svelte'
  import { target, type Mode } from '@/lib/target.svelte'

  const MODES: { value: Mode; label: string }[] = [
    { value: 'classic', label: 'Classic' },
    { value: 'free', label: 'Free mouse' },
  ]

  const RETICLES = ['crosshair', 'focus', 'scan', 'locate', 'target', 'circle-dot', 'plus', 'dot']

  let open = $state(false)

  const setMode = (mode: Mode): void => {
    target.setState({ active: false })
    target.patchConfig({ mode })
  }

  const setColor = (key: 'passive' | 'active', value: string): void => {
    target.patchConfig({ reticle: { ...target.config.reticle, [key]: value } })
  }

  const setNumber = (key: 'maxVisible' | 'width' | 'offset', value: string): void => {
    const parsed = Number.parseInt(value, 10)

    if (Number.isFinite(parsed)) {
      target.patchConfig({ menu: { ...target.config.menu, [key]: parsed } })
    }
  }

  const activate = (): void => {
    open = false
    target.setState({ active: true, reticle: target.isFree ? null : 'passive' })
  }

  const simulate = (): void => {
    open = false
    actions.simulate(target.isFree ? { x: 0.6, y: 0.55 } : 'reticle')
  }
</script>

<div class="fixed bottom-7 left-24 z-50">
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
            <Settings2 class="h-[17px] w-[17px]" />
          </Button>
        {/snippet}
      </Tooltip.Trigger>
      <Tooltip.Content side="right" class="sk-panel border-white/[0.08] text-xs text-sk-body">
        Simulation
      </Tooltip.Content>
    </Tooltip.Root>
  </Tooltip.Provider>

  <Dialog.Root bind:open>
    <Dialog.Content
      class="sk-panel sk-scroll max-h-[85vh] w-[460px] gap-0 overflow-y-auto border-white/[0.105] bg-[var(--sk-panel)] p-7 sm:rounded-[var(--sk-radius-panel)]"
    >
      <Dialog.Header class="mb-6 space-y-1 text-center sm:text-center">
        <Dialog.Title class="sk-label text-center font-medium">Simulation</Dialog.Title>
        <Dialog.Description class="text-xs text-sk-faint">
          What the game would send. Nothing here reaches it.
        </Dialog.Description>
      </Dialog.Header>

      <div class="flex flex-col gap-5">
        <p class="sk-label">Target</p>

        <div class="flex items-center justify-between">
          <span class="text-sm text-sk-body">Mode</span>
          <div class="flex gap-1.5">
            {#each MODES as mode (mode.value)}
              <button
                type="button"
                class="sk-chip px-3 py-1.5 text-xs {target.config.mode === mode.value
                  ? 'sk-chip--active'
                  : ''}"
                onclick={() => setMode(mode.value)}
              >
                {mode.label}
              </button>
            {/each}
          </div>
        </div>

        <div class="flex gap-2.5">
          <Button variant="outline" class="sk-btn sk-btn--ghost h-10 flex-1" onclick={activate}>
            {target.isFree ? 'Free the pointer' : 'Show the reticle'}
          </Button>
          <Button variant="outline" class="sk-btn sk-btn--primary h-10 flex-1" onclick={simulate}>
            Simulate a target
          </Button>
        </div>

        <p class="text-xs text-sk-faint">
          {target.isFree
            ? 'With the pointer free, click anywhere to open the menu next to it.'
            : 'A target with options turns the reticle to its active colour and opens the menu.'}
        </p>

        <Separator class="bg-white/[0.085]" />

        <p class="sk-label">Reticle</p>

        <div class="flex items-center justify-between">
          <span class="text-sm text-sk-body">Icon</span>
          <div class="flex flex-wrap justify-end gap-1.5">
            {#each RETICLES as icon (icon)}
              <button
                type="button"
                class="sk-chip px-2.5 py-1 text-[11px] {target.config.reticle.icon === icon
                  ? 'sk-chip--active'
                  : ''}"
                onclick={() => target.patchConfig({ reticle: { ...target.config.reticle, icon } })}
              >
                {icon}
              </button>
            {/each}
          </div>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div class="flex flex-col gap-1.5">
            <Label for="dev-passive" class="text-xs text-sk-soft">Passive colour</Label>
            <Input
              id="dev-passive"
              class="sk-field h-9"
              value={target.config.reticle.passive}
              oninput={(event) => setColor('passive', event.currentTarget.value)}
            />
          </div>
          <div class="flex flex-col gap-1.5">
            <Label for="dev-active" class="text-xs text-sk-soft">Active colour</Label>
            <Input
              id="dev-active"
              class="sk-field h-9"
              value={target.config.reticle.active}
              oninput={(event) => setColor('active', event.currentTarget.value)}
            />
          </div>
        </div>

        <Separator class="bg-white/[0.085]" />

        <p class="sk-label">Menu</p>

        <div class="flex items-center justify-between">
          <Label for="dev-submenus" class="text-sm text-sk-body">Submenus allowed</Label>
          <Switch
            id="dev-submenus"
            checked={target.config.menu.submenus}
            onCheckedChange={(value) =>
              target.patchConfig({ menu: { ...target.config.menu, submenus: value } })}
          />
        </div>

        <div class="grid grid-cols-3 gap-3">
          <div class="flex flex-col gap-1.5">
            <Label for="dev-rows" class="text-xs text-sk-soft">Visible rows</Label>
            <Input
              id="dev-rows"
              class="sk-field h-9"
              type="number"
              min="2"
              max="12"
              value={target.config.menu.maxVisible}
              oninput={(event) => setNumber('maxVisible', event.currentTarget.value)}
            />
          </div>
          <div class="flex flex-col gap-1.5">
            <Label for="dev-width" class="text-xs text-sk-soft">Width</Label>
            <Input
              id="dev-width"
              class="sk-field h-9"
              type="number"
              min="160"
              max="400"
              value={target.config.menu.width}
              oninput={(event) => setNumber('width', event.currentTarget.value)}
            />
          </div>
          <div class="flex flex-col gap-1.5">
            <Label for="dev-offset" class="text-xs text-sk-soft">Offset</Label>
            <Input
              id="dev-offset"
              class="sk-field h-9"
              type="number"
              min="0"
              max="80"
              value={target.config.menu.offset}
              oninput={(event) => setNumber('offset', event.currentTarget.value)}
            />
          </div>
        </div>

        <Separator class="bg-white/[0.085]" />

        <div class="flex items-center justify-between">
          <span class="text-sm text-sk-body">Language</span>
          <div class="flex gap-1.5">
            {#each locale.all as language (language)}
              <button
                type="button"
                class="sk-chip px-3 py-1.5 text-xs uppercase {locale.current === language
                  ? 'sk-chip--active'
                  : ''}"
                onclick={() => locale.set(language)}
              >
                {language}
              </button>
            {/each}
          </div>
        </div>
      </div>
    </Dialog.Content>
  </Dialog.Root>
</div>
