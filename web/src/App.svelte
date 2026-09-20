<script lang="ts">
  import { onMount } from 'svelte'
  import type { Component } from 'svelte'
  import { applyTranslations } from '@/lib/i18n.svelte'
  import { locale } from '@/lib/locale.svelte'
  import { RESOURCE, sendNuiCallback } from '@/lib/nui'
  import {
    target,
    type MenuState,
    type ReticleState,
    type SubmenuState,
    type TargetConfig,
  } from '@/lib/target.svelte'
  import TargetView from '@/views/TargetView.svelte'

  interface LocalePayload {
    language?: string
    translations?: { web?: Record<string, string> }
  }

  interface ReadyResponse {
    locale?: LocalePayload
    config?: Partial<TargetConfig>
  }

  interface NuiMessage {
    action?: string
    locale?: LocalePayload
    payload?: Partial<TargetConfig> & {
      active?: boolean
      reticle?: ReticleState | null
    } & Partial<MenuState> &
      Partial<SubmenuState>
  }

  let Shell = $state<Component | null>(null)

  /** The game's language, and the strings it carries when it sends them. */
  const applyLocale = (payload?: LocalePayload): void => {
    if (!payload?.language) {
      return
    }

    const web = payload.translations?.web

    if (web && typeof web === 'object') {
      applyTranslations(payload.language, web)
    } else {
      locale.set(payload.language)
    }
  }

  const handleMessage = (event: MessageEvent<NuiMessage>): void => {
    const { action, locale: payload, payload: data } = event.data ?? {}

    switch (action) {
      case `${RESOURCE}:nui:setLocale`:
        applyLocale(payload)
        break
      case `${RESOURCE}:nui:setConfig`:
        if (data) {
          target.patchConfig(data)
        }
        break
      case `${RESOURCE}:nui:setState`:
        target.setState({ active: data?.active, reticle: data?.reticle })
        break
      case `${RESOURCE}:nui:openMenu`:
        if (data?.items && data.anchor) {
          target.openMenu({ items: data.items, anchor: data.anchor })
        }
        break
      case `${RESOURCE}:nui:closeMenu`:
        target.closeMenu()
        break
      case `${RESOURCE}:nui:openSubmenu`:
        if (data?.items && data.parentId) {
          target.openSubmenu({
            parentId: data.parentId,
            title: data.title ?? '',
            items: data.items,
          })
        }
        break
      case `${RESOURCE}:nui:closeSubmenu`:
        target.closeSubmenu()
        break
    }
  }

  onMount(() => {
    window.addEventListener('message', handleMessage)

    void sendNuiCallback<ReadyResponse>('ready').then((answer) => {
      if (!answer) {
        return
      }

      applyLocale(answer.locale)

      if (answer.config) {
        target.patchConfig(answer.config)
      }
    })

    if (import.meta.env.DEV) {
      void import('@/views/BoilerplateView.svelte').then((module) => {
        Shell = module.default
      })
    }

    return () => window.removeEventListener('message', handleMessage)
  })
</script>

{#key locale.current}
  {#if Shell}
    <Shell />
  {:else if !import.meta.env.DEV}
    <TargetView />
  {/if}
{/key}
