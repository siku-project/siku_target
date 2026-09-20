import { describe, expect, it } from 'vitest'
import { applyTranslations, m } from './i18n.svelte'
import { locale } from './locale.svelte'

describe('i18n', () => {
  it('serves the compiled message when the game sent nothing', () => {
    expect(m.menu_back()).toBe('Retour')
  })

  it('prefers the string the game pushed for the running language', () => {
    applyTranslations(locale.current, { menu_back: 'Précédent' })

    expect(m.menu_back()).toBe('Précédent')
  })

  it('switches the language along with the strings', () => {
    applyTranslations('en', { menu_back: 'Go back' })

    expect(locale.current).toBe('en')
    expect(m.menu_back()).toBe('Go back')
    expect(m.menu_empty()).toBe('No option')
  })
})
