import type { Anchor } from '@/lib/target.svelte'

export interface Size {
  width: number
  height: number
}

export interface Point {
  x: number
  y: number
}

/**
 * Where the menu goes, in pixels from the top left of the viewport.
 *
 * Next to the reticle, it sits to the right of the centre, vertically
 * centred. Next to the pointer, it sits below and to the right, then flips
 * to the other side of the pointer on any axis where it would leave the
 * screen, and is clamped as a last resort so it always shows whole.
 */
export const placeMenu = (anchor: Anchor, menu: Size, viewport: Size, offset: number): Point => {
  const point: Point =
    anchor === 'reticle'
      ? { x: viewport.width / 2, y: viewport.height / 2 }
      : { x: anchor.x * viewport.width, y: anchor.y * viewport.height }

  let left = point.x + offset
  let top = anchor === 'reticle' ? point.y - menu.height / 2 : point.y + offset

  if (left + menu.width > viewport.width) {
    left = point.x - offset - menu.width
  }

  if (anchor !== 'reticle' && top + menu.height > viewport.height) {
    top = point.y - offset - menu.height
  }

  left = Math.max(0, Math.min(left, viewport.width - menu.width))
  top = Math.max(0, Math.min(top, viewport.height - menu.height))

  return { x: Math.round(left), y: Math.round(top) }
}

export interface Box extends Point, Size {}

/**
 * Where a submenu goes: beside the root menu, its first row level with
 * the row that opened it. To the right of the root when there is room,
 * to its left otherwise, and clamped inside the viewport.
 */
export const placeSubmenu = (
  root: Box,
  rowTop: number,
  submenu: Size,
  viewport: Size,
  gap: number,
): Point => {
  let left = root.x + root.width + gap

  if (left + submenu.width > viewport.width) {
    left = root.x - gap - submenu.width
  }

  const top = Math.max(0, Math.min(rowTop, viewport.height - submenu.height))

  return { x: Math.round(Math.max(0, left)), y: Math.round(top) }
}
