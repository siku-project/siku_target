export type Mode = 'classic' | 'free'
export type ReticleState = 'passive' | 'active'
export type Anchor = 'reticle' | { x: number; y: number }

export interface ReticleConfig {
  icon: string
  size: number
  passive: string
  active: string
}

export interface MenuConfig {
  submenus: boolean
  maxVisible: number
  width: number
  offset: number
}

export interface TargetConfig {
  mode: Mode
  reticle: ReticleConfig
  menu: MenuConfig
}

export interface MenuItem {
  id: string
  label: string
  icon?: string
  submenu: boolean
}

export interface MenuState {
  items: MenuItem[]
  anchor: Anchor
}

export interface SubmenuState {
  parentId: string
  title: string
  items: MenuItem[]
}

/** What the interface assumes until the game sends its config files. */
const CONFIG_DEFAULTS: TargetConfig = {
  mode: 'classic',
  reticle: { icon: 'crosshair', size: 22, passive: '#000000', active: '#FFFFFF' },
  menu: { submenus: true, maxVisible: 6, width: 220, offset: 18 },
}

/** In the browser, `?mode=free` and `?active=1` start the target that way. */
const devInitial = (): { mode: Mode; active: boolean } => {
  if (!import.meta.env.DEV) {
    return { mode: CONFIG_DEFAULTS.mode, active: false }
  }

  const params = new URLSearchParams(window.location.search)

  return {
    mode: params.get('mode') === 'free' ? 'free' : 'classic',
    active: params.get('active') === '1',
  }
}

const initial = devInitial()

let config = $state<TargetConfig>({ ...CONFIG_DEFAULTS, mode: initial.mode })
let active = $state(initial.active)
let reticle = $state<ReticleState | null>(
  initial.active && initial.mode === 'classic' ? 'passive' : null,
)
let menu = $state<MenuState | null>(null)
let submenu = $state<SubmenuState | null>(null)

/** What the target shows. The game patches it, the interface only reads it. */
export const target = {
  get config(): TargetConfig {
    return config
  },

  get active(): boolean {
    return active
  },

  get reticle(): ReticleState | null {
    return reticle
  },

  get menu(): MenuState | null {
    return menu
  },

  get submenu(): SubmenuState | null {
    return submenu
  },

  get isFree(): boolean {
    return config.mode === 'free'
  },

  patchConfig(changes: Partial<TargetConfig>): void {
    config = {
      mode: changes.mode ?? config.mode,
      reticle: { ...config.reticle, ...changes.reticle },
      menu: { ...config.menu, ...changes.menu },
    }
  },

  setState(state: { active?: boolean; reticle?: ReticleState | null }): void {
    if (state.active !== undefined) {
      active = state.active

      if (!active) {
        menu = null
        submenu = null
        reticle = null
      }
    }

    if (state.reticle !== undefined) {
      reticle = state.reticle
    }
  },

  openMenu(state: MenuState): void {
    menu = state
    submenu = null
  },

  closeMenu(): void {
    menu = null
    submenu = null
  },

  openSubmenu(state: SubmenuState): void {
    submenu = state
  },

  closeSubmenu(): void {
    submenu = null
  },
}
