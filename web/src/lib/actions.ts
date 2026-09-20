import { mockChildren, mockRoot, MOCK_ROOT } from '@/lib/mock/targets'
import { inGame, sendNuiCallback } from '@/lib/nui'
import { target, type Anchor } from '@/lib/target.svelte'

/**
 * Everything the menu asks the game for. In the game the request goes
 * through a NUI callback and the game answers with a message; in the
 * browser the same call plays the answer on mock data, so the interface
 * behaves the same on both sides.
 */
export const actions = {
  /** A pick on the world in free mode: the pointer position, as screen fractions. */
  click(x: number, y: number): void {
    if (inGame) {
      void sendNuiCallback('click', { x, y })
      return
    }

    actions.simulate({ x, y })
  },

  select(id: string): void {
    if (inGame) {
      void sendNuiCallback('select', { id })
      return
    }

    const entry = MOCK_ROOT.find((candidate) => candidate.id === id)

    if (entry?.submenu) {
      target.openSubmenu({ parentId: id, title: entry.label, items: mockChildren(id) })
      return
    }

    target.setState({ active: false })
  },

  back(): void {
    if (inGame) {
      void sendNuiCallback('back')
      return
    }

    if (target.submenu) {
      target.closeSubmenu()
    } else {
      target.closeMenu()
    }
  },

  hover(hovering: boolean): void {
    if (inGame) {
      void sendNuiCallback('hover', { hovering })
    }
  },

  close(): void {
    if (inGame) {
      void sendNuiCallback('close')
      return
    }

    target.setState({ active: false })
  },

  /** Development only: a target with options lands under the reticle or the pointer. */
  simulate(anchor: Anchor): void {
    target.setState({ active: true, reticle: target.isFree ? null : 'active' })
    target.openMenu({ items: mockRoot(target.config.menu.submenus), anchor })
  },
}
