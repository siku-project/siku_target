<script lang="ts">
  import { Languages } from '@lucide/svelte'
  import { Badge } from '$lib/components/ui/badge'
  import { Button } from '$lib/components/ui/button'
  import { Separator } from '$lib/components/ui/separator'
  import { locale } from '@/lib/locale.svelte'
  import { RESOURCE } from '@/lib/nui'

  const isDev = import.meta.env.DEV
</script>

<div class="fixed left-1/2 top-7 z-50 -translate-x-1/2">
  <div class="sk-panel flex h-12 items-center gap-5 px-6">
    <span class="sk-label">{RESOURCE}</span>

    <Separator orientation="vertical" class="h-4 bg-white/[0.08]" />

    <span class="text-xs font-medium text-sk-soft">Svelte 5</span>

    <Separator orientation="vertical" class="h-4 bg-white/[0.08]" />

    <Badge
      variant="outline"
      class="gap-2 border-white/[0.08] px-2.5 text-[10px] font-semibold uppercase tracking-[0.16em] {isDev
        ? 'text-sk-accent'
        : 'text-sk'}"
    >
      <span class="h-1.5 w-1.5 rounded-full {isDev ? 'bg-primary shadow-glow' : 'bg-white/70'}"
      ></span>
      {isDev ? 'Dev' : 'Prod'}
    </Badge>

    <Separator orientation="vertical" class="h-4 bg-white/[0.08]" />

    <Button
      variant="ghost"
      size="sm"
      class="h-7 gap-2 px-2 text-[11px] font-semibold uppercase tracking-[0.14em] text-sk-soft hover:text-sk"
      onclick={() => locale.cycle()}
    >
      <Languages class="h-3.5 w-3.5" />
      {locale.current}
    </Button>
  </div>
</div>
