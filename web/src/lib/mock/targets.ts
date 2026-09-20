import type { MenuItem } from '@/lib/target.svelte'

/** A submenu entry as the game would describe it: it acts, it never opens more. */
export interface MockEntry extends MenuItem {
  items?: MenuItem[]
}

/**
 * What the game would send for a player under the reticle or the pointer,
 * so the browser shows a real menu: a few actions, one submenu.
 */
export const MOCK_ROOT: MockEntry[] = [
  { id: 'mock:talk', label: 'Parler', icon: 'message-circle', submenu: false },
  { id: 'mock:search', label: 'Fouiller', icon: 'search', submenu: false },
  { id: 'mock:give', label: 'Donner un objet', icon: 'gift', submenu: false },
  { id: 'mock:cuff', label: 'Menotter', icon: 'link', submenu: false },
  { id: 'mock:heal', label: 'Soigner', icon: 'heart', submenu: false },
  {
    id: 'mock:admin',
    label: 'Administration',
    icon: 'shield',
    submenu: true,
    items: [
      { id: 'mock:admin/1', label: 'Météo dégagée', icon: 'sun', submenu: false },
      { id: 'mock:admin/2', label: 'Météo pluvieuse', icon: 'cloud-rain', submenu: false },
      { id: 'mock:admin/3', label: 'Téléporter à moi', icon: 'navigation', submenu: false },
      { id: 'mock:admin/4', label: 'Réanimer', icon: 'syringe', submenu: false },
      { id: 'mock:admin/5', label: 'Geler', icon: 'ban', submenu: false },
      { id: 'mock:admin/6', label: 'Spectateur', icon: 'eye', submenu: false },
      { id: 'mock:admin/7', label: 'Expulser', icon: 'log-out', submenu: false },
    ],
  },
  { id: 'mock:vehicle', label: 'Ouvrir le coffre', icon: 'car', submenu: false },
  { id: 'mock:id', label: 'Montrer sa carte', icon: 'credit-card', submenu: false },
]

/** The root as the menu shows it, submenus dropped when the config refuses them. */
export const mockRoot = (submenus: boolean): MenuItem[] =>
  MOCK_ROOT.filter((entry) => submenus || !entry.submenu).map(({ items: _items, ...item }) => item)

/** The entries of a mock submenu, or none. */
export const mockChildren = (id: string): MenuItem[] =>
  MOCK_ROOT.find((entry) => entry.id === id)?.items ?? []
