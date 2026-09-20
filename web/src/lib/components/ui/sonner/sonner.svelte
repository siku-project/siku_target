<script lang="ts">
  import { Toaster as Sonner, type ToasterProps as SonnerProps } from 'svelte-sonner'

  let { ...restProps }: SonnerProps = $props()
</script>

<Sonner
  theme="dark"
  position="bottom-center"
  offset="28px"
  gap={10}
  visibleToasts={3}
  class="toaster group"
  toastOptions={{
    classes: {
      toast:
        'group toast font-sans !rounded-[var(--sk-radius-panel)] !border !border-white/[0.105] !bg-[var(--sk-panel)] !text-[var(--sk-text)] !shadow-[var(--sk-shadow-panel)]',
      title: 'text-[13px] font-semibold tracking-[0.02em]',
      description: 'group-[.toast]:!text-[var(--sk-text-muted)] text-xs',
      icon: 'group-[.toast]:!text-[var(--sk-accent)]',
      success: '!text-[var(--sk-text)]',
      error: '!text-[var(--sk-text)]',
      warning: '!text-[var(--sk-text)]',
      info: '!text-[var(--sk-text)]',
    },
  }}
  {...restProps}
/>
