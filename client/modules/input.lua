TargetInput = {}

local KEYBIND <const> = 'siku_target_activate'
local MODE_FREE <const> = 'free'
local ACTIVATION_TOGGLE <const> = 'toggle'
local LOOK_CONTROLS <const> = { 1, 2 }
local CONTROL_ATTACK <const> = 24
local INPUT_GROUP <const> = 0
local RETICLE_PASSIVE <const> = 'passive'
local RETICLE_ACTIVE <const> = 'active'
local ANCHOR_RETICLE <const> = 'reticle'

local active = false
local disabled = false
local engaged = false
local signature = nil
local dismissed = nil

--- Whether the pointer picks the target, rather than the reticle.
---@return boolean free Whether the free mode runs.
local function isFree()
  return TargetConfig.mode == MODE_FREE
end

--- Gives the interface the pointer and holds the camera, or the reverse.
--- In classic mode this only happens while a menu is open: aiming stays
--- free, and the pointer only shows when there is something to click.
---@param value boolean Whether the pointer is out and the camera still.
---@return nil
local function engage(value)
  if engaged == value then
    return
  end

  engaged = value

  if value then
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    Siku.controls.disable(table.unpack(LOOK_CONTROLS))
  else
    Siku.controls.enable(table.unpack(LOOK_CONTROLS))
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
  end
end

--- Opens the menu on a target when it has options, closes it otherwise.
---@param target table The target.
---@param anchor table|string Where the menu goes.
---@return boolean shown Whether the target had options.
local function present(target, anchor)
  local entries <const> = TargetOptions.gather(target)

  if #entries == 0 then
    TargetMenu.close()
    return false
  end

  TargetMenu.open(target, entries, anchor)

  return true
end

--- Casts from the camera while the target runs, at the configured pace,
--- and keeps the reticle, the menu, the pointer and the camera in step
--- with what it hits. A menu the player dismissed stays closed until the
--- target changes or a click asks for it again.
---@return nil
local function scan()
  while active and not isFree() do
    local target <const> = TargetResolve.fromRay(TargetRay.fromCamera())
    local key <const> = TargetResolve.signature(target)

    if key ~= signature then
      signature = key

      if key ~= dismissed then
        dismissed = nil
      end

      local shown <const> = key ~= dismissed and present(target, ANCHOR_RETICLE)

      if not shown then
        TargetMenu.close()
      end

      TargetNui.setState(true, (shown or key == dismissed) and RETICLE_ACTIVE or RETICLE_PASSIVE)
    elseif key == dismissed and IsDisabledControlJustPressed(INPUT_GROUP, CONTROL_ATTACK) then
      dismissed = nil
      present(target, ANCHOR_RETICLE)
    end

    engage(TargetMenu.isOpen())

    Wait(dismissed ~= nil and key == dismissed and 0 or TargetConfig.scanInterval)
  end
end

--- Whether the target runs.
---@return boolean active Whether it is on screen.
function TargetInput.isActive()
  return active
end

--- Starts the target: controls held, reticle, and the scan in classic
--- mode; pointer and still camera at once in free mode. Costs nothing
--- until then.
---@return nil
function TargetInput.start()
  if active or disabled then
    return
  end

  active = true
  signature = nil
  dismissed = nil

  Siku.controls.disable(table.unpack(TargetConfig.controls))
  TargetNui.setState(true, isFree() and nil or RETICLE_PASSIVE)

  if isFree() then
    engage(true)
  else
    CreateThread(scan)
  end
end

--- Stops the target and gives everything back to the game.
---@return nil
function TargetInput.stop()
  if not active then
    return
  end

  active = false
  signature = nil
  dismissed = nil

  TargetMenu.close()
  TargetNui.setState(false, nil)
  engage(false)
  Siku.controls.clear()
end

--- Starts or stops the target.
---@return nil
function TargetInput.toggle()
  if active then
    TargetInput.stop()
  else
    TargetInput.start()
  end
end

--- Keeps the target away, for a menu or a cinematic, and back.
---@param value boolean Whether the target is refused.
---@return nil
function TargetInput.setDisabled(value)
  disabled = value == true

  if disabled then
    TargetInput.stop()
  end
end

--- A click beside the menu: it closes and the camera is free again, the
--- target staying marked until the player looks elsewhere or clicks it.
---@return nil
function TargetInput.dismiss()
  if not active then
    return
  end

  if isFree() then
    TargetMenu.close()
    return
  end

  dismissed = signature
  TargetMenu.close()
  engage(false)
end

--- A click on the world in free mode: what is under the pointer becomes
--- the target and the menu opens next to the pointer.
---@param x number The horizontal screen fraction, 0 to 1.
---@param y number The vertical screen fraction, 0 to 1.
---@return nil
function TargetInput.pick(x, y)
  if not active or not isFree() then
    return
  end

  local target <const> = TargetResolve.fromRay(TargetRay.fromScreen(x, y))

  present(target, { x = x, y = y })
end

Siku.keybind.add({
  name = KEYBIND,
  description = T('keybind_activate'),
  defaultKey = TargetConfig.keybind,
  onPressed = function()
    if TargetConfig.activation == ACTIVATION_TOGGLE then
      TargetInput.toggle()
    else
      TargetInput.start()
    end
  end,
  onReleased = function()
    if TargetConfig.activation ~= ACTIVATION_TOGGLE then
      TargetInput.stop()
    end
  end,
})

AddEventHandler('onResourceStop', function(resource)
  if resource == Siku.name then
    TargetInput.stop()
  else
    TargetRegistry.purge(resource)
  end
end)
