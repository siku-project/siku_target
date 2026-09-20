import { describe, expect, it } from 'vitest'
import { cn } from './utils'

describe('cn', () => {
  it('merges conflicting Tailwind classes, the last one winning', () => {
    expect(cn('p-2', 'p-4')).toBe('p-4')
  })

  it('drops falsy entries', () => {
    expect(cn('flex', false, undefined, 'gap-2')).toBe('flex gap-2')
  })
})
