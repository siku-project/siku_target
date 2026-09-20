TargetInput = {}

local KEYBIND <const> = 'siku_target_activate'
local MODE_FREE <const> = 'free'
local ACTIVATION_TOGGLE <const> = 'toggle'
local LOOK_CONTROLS <const> = { 1, 2 }
local RETICLE_PASSIVE <const> = 'passive'
local RETICLE_ACTIVE <const> = 'active'
local ANCHOR_RETICLE <const> = 'reticle'

local active = false
local disabled = false
local hovering = false
local lookHeld = false
local signature = nil

--- Whether the pointer picks the target, rather than the reticle.
---@return boolean free Whether the free mode runs.
local function isFree()
  return TargetConfig.mode == MODE_FREE
end

--- Keeps or frees the camera look.
---@param held boolean Whether the camera must stay still.
---@return nil
local function holdLook(held)
  if lookHeld == held then
    return
  end

  lookHeld = held

  if held then
    Siku.controls.disable(table.unpack(LOOK_CONTROLS))
  else
    Siku.controls.enable(table.unpack(LOOK_CONTROLS))
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
--- and keeps the reticle and the menu in step with what it hits. The
--- target under the pointer is frozen while the menu is hovered.
---@return nil
local function scan()
  while active and not isFree() do
    if not hovering then
      local target <const> = TargetResolve.fromRay(TargetRay.fromCamera())
      local key <const> = TargetResolve.signature(target)

      if key ~= signature then
        signature = key
        TargetNui.setState(true, present(target, ANCHOR_RETICLE) and RETICLE_ACTIVE or RETICLE_PASSIVE)
      end
    end

    Wait(TargetConfig.scanInterval)
  end
end

--- Whether the target runs.
---@return boolean active Whether it is on screen.
function TargetInput.isActive()
  return active
end

--- Starts the target: pointer, controls, reticle, and the scan in classic
--- mode. Costs nothing until then.
---@return nil
function TargetInput.start()
  if active or disabled then
    return
  end

  active = true
  signature = nil
  hovering = false

  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(true)
  Siku.controls.disable(table.unpack(TargetConfig.controls))
  holdLook(isFree())

  TargetNui.setState(true, isFree() and nil or RETICLE_PASSIVE)

  if not isFree() then
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
  hovering = false
  lookHeld = false

  TargetMenu.close()
  TargetNui.setState(false, nil)
  Siku.controls.clear()
  SetNuiFocusKeepInput(false)
  SetNuiFocus(false, false)
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

--- The interface says whether the pointer is over the menu: the camera
--- and the target under the reticle stay still meanwhile.
---@param value boolean Whether the menu is hovered.
---@return nil
function TargetInput.setHovering(value)
  if not active then
    return
  end

  hovering = value == true

  if not isFree() then
    holdLook(hovering)
  end
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
