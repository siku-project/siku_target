# siku_target

A modern and flexible targeting system for the SIKU ecosystem — built for immersive player interactions, contextual actions, dynamic menus, and seamless world integration. Designed with performance, extensibility, and clean architecture in mind.

![Version](https://img.shields.io/badge/version-0.0.1-4785bd)
![FiveM](https://img.shields.io/badge/fx__version-cerulean-4785bd)
![Lua](https://img.shields.io/badge/Lua-5.4-4785bd)
![Svelte](https://img.shields.io/badge/Svelte-5-4785bd)

The target owns nothing of the game's rules. Other resources register options on kinds of targets, each option saying for itself whether it shows and what it does; the target finds what the player aims at or clicks, asks the options, draws the menu and runs the pick.

## Features

- **Two ways to pick, one engine** — `classic` puts a reticle at the centre of the screen and targets what the camera looks at: aiming stays free, no pointer, until the target has options; then the menu opens, the pointer comes out and the camera holds still. A click beside the menu closes it and frees the camera, the target staying marked, and a click brings it back. `free` frees the pointer from the start and targets what a click lands on, the menu opening next to the pointer where there is room. Options, conditions, menu, submenu and actions are the same code in both modes.
- **Every kind of target** — the player's own ped, other players, peds, vehicles, objects, models, one entity by handle or by net id, zones (sphere, box, polygon through the core spatial grid), points, and the world itself for global options.
- **Options that decide for themselves** — `canInteract(target)` is the only gate: job, grade, permission, state, ownership, anything the registering resource knows. A `distance` per option, an `order`, an icon, a label that may be a function of the target.
- **Actions without coupling** — `onSelect(target)`, or a client `event`, a `serverEvent` (the target serialized without handles), or an `export` of another resource.
- **One level of submenu** — an option may carry `items`; those always act. Submenus can be switched off in `config/menu.lua`, then the options carrying one are left out.
- **Compact glass menu in the SIKU look** — a translucent panel the world shows through, icon and label rows, chevron for a submenu that opens in a column beside the menu, level with the option that opened it (to the left when the right side is short), scroll beyond the visible rows, Escape or a right click to close.
- **Idle for free** — nothing runs until the key is pressed: no thread, no ray. Active, one thread casts at the configured pace in classic mode, and nothing at all in free mode until a click. No entity pool is ever scanned.

## Dependencies

| Resource | Required | Purpose |
|---|---|---|
| [`siku_core`](https://github.com/siku-project/siku_core) | Yes | Raycast, spatial zones, keybinds, controls, locale, print. |

## Configuration

| File | Options |
|---|---|
| `config/target.lua` | `mode` classic / free, `keybind`, `activation` hold / toggle, `scanInterval`, `rayDistance`, `optionDistance`, `controls`, `debug` |
| `config/reticle.lua` | `icon` (lucide name), `size`, `passive`, `active` |
| `config/menu.lua` | `submenus`, `maxVisible`, `width`, `offset`, `closeOnSelect` |
| `config/interactions.lua` | The built-in interactions: `vehicle` (doors, hood, trunk, seats, distance), `self` |
| `config/translation.lua` | `language` (`fr` / `en`) |

The config travels to the interface at startup, so a value changed in Lua changes the reticle and the menu without touching the web.

## Built-in interactions

`client/interactions/` ships what every server wants without writing a resource for it, one file per target, registered through the same registry as any other resource. Each family switches off in `config/interactions.lua`.

| File | Target | Options |
|---|---|---|
| `vehicle.lua` | Any vehicle | **Doors**, a submenu with each door the model has, the label reading open or close by its state; **Hood** and **Trunk**, the same toggle; **Change seat**, free mode only, a submenu of the free seats: a walk and a climb from outside, a warp from another seat. A locked vehicle offers none of it. |
| `self.lua` | The player's own ped, free mode only | **Wave**, a first interaction to see the mode work. |

## API

All exports are client side.

```lua
local target = exports.siku_target

target:AddPlayer({
  id = 'police:search',
  label = 'Fouiller',
  icon = 'search',
  distance = 2.0,
  canInteract = function(target) return exports.siku_jobs:HasJob('police') end,
  serverEvent = 'siku_police:server:search',
})

target:AddModel({ 'prop_atm_01', 'prop_atm_02' }, {
  label = 'Utiliser le distributeur',
  icon = 'credit-card',
  onSelect = function(target) exports.siku_bank:OpenAtm(target.entity) end,
})

local handle = target:AddLocalPlayer({
  label = 'Administration',
  icon = 'shield',
  canInteract = function() return IsAdmin() end,
  items = {
    { label = 'Météo dégagée', icon = 'sun', serverEvent = 'siku_admin:server:weather', },
    { label = 'Réanimer', icon = 'syringe', event = 'siku_admin:client:revive' },
  },
})

target:Remove(handle)
```

| Export | Purpose |
|---|---|
| `AddLocalPlayer` / `AddPlayer` / `AddPed` / `AddVehicle` / `AddObject` / `AddGlobal` | Options on a whole kind of target. |
| `AddModel(models, options)` | Options on one or several models, by name or hash. |
| `AddEntity(entity, options)` / `AddNetworkedEntity(netId, options)` | Options on one entity. |
| `AddZone(shape, options)` / `AddPoint(coords, radius, options)` | Options inside a zone: `{ sphere = { coords, radius } }`, `{ box = { coords, size, heading } }`, `{ poly = { points, minZ, maxZ } }`, plus `debug = true` to draw it. |
| `Remove(handle or id or ids)` | Forgets options, and the zone made for them. |
| `IsActive()` / `Disable(bool)` / `Close()` | Whether the target runs; keep it away; close it. |

Every `Add` takes one option or a list and returns `{ ids }`. Options registered by a resource go away when it stops.

### Option

| Field | Purpose |
|---|---|
| `id` | Unique, generated when absent. |
| `label` | The text, already translated by the registering resource, or `function(target) → string`. |
| `icon` | A lucide name from the curated set (`web/src/lib/icons.ts`). |
| `order` | Sort key, ascending. |
| `distance` | Reach in metres, `optionDistance` by default. |
| `canInteract` | `function(target) → boolean`, the option's own say. |
| `onSelect` / `event` / `serverEvent` / `export` | What the pick does. |
| `items` | A submenu, one level: its entries carry no `items`. |

### Target

What conditions and actions receive: `{ kind, entity?, netId?, model?, serverId?, coords, distance, zones, hit }` with `kind` one of `localPlayer`, `player`, `ped`, `vehicle`, `object`, `zone`, `world`. A `serverEvent` receives it without `entity` and `hit`.

## Translations

Every string lives in `translations/fr.lua` and `translations/en.lua`, the interface ones in their `web` block. The game pushes the block of the configured language to the interface at startup, and `bun run messages` compiles the same files for the browser. Option labels are not the target's: the registering resource translates them.

## Development

```
cd web
bun install
bun run dev      # boilerplate with the Target view and the simulation panel
bun run build    # production build into web/dist, served by ui_page
bun run check    # locales, format, types, lints
bun run test:unit
```

In the browser, `?view=Target&active=1` shows the reticle, `&mode=free` frees the pointer, and the simulation panel (bottom left) switches mode, reticle icon and colours, submenus, rows, and simulates a target with mock options.
