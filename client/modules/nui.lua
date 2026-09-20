TargetNui = {}

local NUI_READY <const> = 'siku_target:nui:ready'
local ACTION_LOCALE <const> = 'siku_target:nui:setLocale'
local ACTION_CONFIG <const> = 'siku_target:nui:setConfig'
local ACTION_STATE <const> = 'siku_target:nui:setState'
local ACTION_OPEN_MENU <const> = 'siku_target:nui:openMenu'
local ACTION_CLOSE_MENU <const> = 'siku_target:nui:closeMenu'
local ACTION_OPEN_SUBMENU <const> = 'siku_target:nui:openSubmenu'
local ACTION_CLOSE_SUBMENU <const> = 'siku_target:nui:closeSubmenu'

--- What the interface needs from the configuration.
---@return table config { mode, reticle, menu }.
local function describeConfig()
  return {
    mode = TargetConfig.mode,
    reticle = ReticleConfig,
    menu = {
      submenus = MenuConfig.submenus,
      maxVisible = MenuConfig.maxVisible,
      width = MenuConfig.width,
      offset = MenuConfig.offset,
    },
  }
end

--- Sends the interface the language and its strings.
---@return nil
function TargetNui.pushLocale()
  SendNUIMessage({ action = ACTION_LOCALE, locale = TargetLocale.describe() })
end

--- Sends the interface the configuration.
---@return nil
function TargetNui.pushConfig()
  SendNUIMessage({ action = ACTION_CONFIG, payload = describeConfig() })
end

--- Tells the interface whether the target runs and what the reticle shows.
---@param active boolean Whether the target is active.
---@param reticle? string 'passive' | 'active', nil to leave it.
---@return nil
function TargetNui.setState(active, reticle)
  SendNUIMessage({ action = ACTION_STATE, payload = { active = active, reticle = reticle } })
end

--- Shows the root menu.
---@param menu table { items, anchor }.
---@return nil
function TargetNui.openMenu(menu)
  SendNUIMessage({ action = ACTION_OPEN_MENU, payload = menu })
end

--- Hides the menu, submenu included.
---@return nil
function TargetNui.closeMenu()
  SendNUIMessage({ action = ACTION_CLOSE_MENU })
end

--- Shows a submenu beside the root menu, level with the option that opened it.
---@param submenu table { parentId, title, items }.
---@return nil
function TargetNui.openSubmenu(submenu)
  SendNUIMessage({ action = ACTION_OPEN_SUBMENU, payload = submenu })
end

--- Hides the submenu, the root menu stays.
---@return nil
function TargetNui.closeSubmenu()
  SendNUIMessage({ action = ACTION_CLOSE_SUBMENU })
end

--- Reads a callback argument as a number.
---@param value any The raw value.
---@return number? number The number, or nil.
local function toNumber(value)
  local number <const> = tonumber(value)

  if number == nil or number ~= number then
    return nil
  end

  return number
end

RegisterNUICallback(NUI_READY, function(_, cb)
  cb({ locale = TargetLocale.describe(), config = describeConfig() })
end)

RegisterNUICallback('siku_target:nui:select', function(data, cb)
  cb({})

  if type(data) == 'table' and type(data.id) == 'string' then
    TargetMenu.select(data.id)
  end
end)

RegisterNUICallback('siku_target:nui:back', function(_, cb)
  cb({})
  TargetMenu.back()
end)

RegisterNUICallback('siku_target:nui:hover', function(data, cb)
  cb({})
  TargetInput.setHovering(type(data) == 'table' and data.hovering == true)
end)

RegisterNUICallback('siku_target:nui:click', function(data, cb)
  cb({})

  local x <const> = toNumber(type(data) == 'table' and data.x or nil)
  local y <const> = toNumber(type(data) == 'table' and data.y or nil)

  if x and y then
    TargetInput.pick(x, y)
  end
end)

RegisterNUICallback('siku_target:nui:close', function(_, cb)
  cb({})
  TargetInput.stop()
end)
