import { describe, expect, it } from 'vitest'
import { placeMenu, placeSubmenu } from './placement'

const viewport = { width: 1920, height: 1080 }
const menu = { width: 220, height: 200 }

describe('placeSubmenu', () => {
  it('sits to the right of the root, level with the opening row', () => {
    const root = { x: 978, y: 440, width: 220, height: 200 }

    expect(placeSubmenu(root, 508, menu, viewport, 6)).toEqual({ x: 1204, y: 508 })
  })

  it('moves to the left of the root when the right side is short', () => {
    const root = { x: 1690, y: 440, width: 220, height: 200 }

    expect(placeSubmenu(root, 508, menu, viewport, 6)).toEqual({ x: 1464, y: 508 })
  })

  it('never runs past the bottom', () => {
    const root = { x: 978, y: 900, width: 220, height: 200 }

    expect(placeSubmenu(root, 1050, menu, viewport, 6)).toEqual({ x: 1204, y: 880 })
  })
})

describe('placeMenu', () => {
  it('sits to the right of the reticle, vertically centred', () => {
    expect(placeMenu('reticle', menu, viewport, 18)).toEqual({ x: 978, y: 440 })
  })

  it('sits below and to the right of the pointer', () => {
    expect(placeMenu({ x: 0.25, y: 0.25 }, menu, viewport, 18)).toEqual({ x: 498, y: 288 })
  })

  it('flips to the left and above when the pointer is near the bottom right', () => {
    expect(placeMenu({ x: 0.95, y: 0.95 }, menu, viewport, 18)).toEqual({ x: 1586, y: 808 })
  })

  it('never leaves the screen, whatever the anchor', () => {
    const placed = placeMenu({ x: 0, y: 0 }, { width: 3000, height: 3000 }, viewport, 18)

    expect(placed).toEqual({ x: 0, y: 0 })
  })
})
