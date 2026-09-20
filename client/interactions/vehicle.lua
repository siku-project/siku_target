local DOOR_FRONT_LEFT <const> = 0
local DOOR_FRONT_RIGHT <const> = 1
local DOOR_REAR_LEFT <const> = 2
local DOOR_REAR_RIGHT <const> = 3
local DOOR_HOOD <const> = 4
local DOOR_TRUNK <const> = 5
local SEAT_DRIVER <const> = -1
local SEAT_PASSENGER <const> = 0
local SEAT_REAR_LEFT <const> = 1
local SEAT_REAR_RIGHT <const> = 2
local LOCK_LOCKED <const> = 2
local CONTROL_TIMEOUT_MS <const> = 500
local CONTROL_POLL_MS <const> = 10
local ENTER_SPEED <const> = 1.0
local ENTER_FLAG_NORMAL <const> = 1
local MODE_FREE <const> = 'free'

local DOORS <const> = {
  { index = DOOR_FRONT_LEFT, key = 'interaction_door_front_left' },
  { index = DOOR_FRONT_RIGHT, key = 'interaction_door_front_right' },
  { index = DOOR_REAR_LEFT, key = 'interaction_door_rear_left' },
  { index = DOOR_REAR_RIGHT, key = 'interaction_door_rear_right' },
}

local SEATS <const> = {
  { index = SEAT_DRIVER, key = 'interaction_seat_driver' },
  { index = SEAT_PASSENGER, key = 'interaction_seat_passenger' },
  { index = SEAT_REAR_LEFT, key = 'interaction_seat_rear_left' },
  { index = SEAT_REAR_RIGHT, key = 'interaction_seat_rear_right' },
}

local config <const> = InteractionsConfig.vehicle

--- Takes control of a networked vehicle before touching it, for a moment.
---@param vehicle number The vehicle handle.
---@return boolean owned Whether this client may change it.
local function ensureControl(vehicle)
  if NetworkHasControlOfEntity(vehicle) then
    return true
  end

  NetworkRequestControlOfEntity(vehicle)

  local deadline <const> = GetGameTimer() + CONTROL_TIMEOUT_MS

  while not NetworkHasControlOfEntity(vehicle) do
    if GetGameTimer() >= deadline then
      return false
    end

    Wait(CONTROL_POLL_MS)
  end

  return true
end

--- Whether a door exists on the model, is not gone, and the vehicle is unlocked.
---@param vehicle number The vehicle handle.
---@param door number The door index.
---@return boolean usable Whether the door can be opened or closed.
local function isDoorUsable(vehicle, door)
  if not GetIsDoorValid(vehicle, door) or IsVehicleDoorDamaged(vehicle, door) then
    return false
  end

  return GetVehicleDoorLockStatus(vehicle) ~= LOCK_LOCKED
end

--- Whether a door is open at all.
---@param vehicle number The vehicle handle.
---@param door number The door index.
---@return boolean open Whether it is ajar or more.
local function isDoorOpen(vehicle, door)
  return GetVehicleDoorAngleRatio(vehicle, door) > 0.0
end

--- Opens a closed door, closes an open one.
---@param vehicle number The vehicle handle.
---@param door number The door index.
---@return nil
local function toggleDoor(vehicle, door)
  if not ensureControl(vehicle) then
    return
  end

  if isDoorOpen(vehicle, door) then
    SetVehicleDoorShut(vehicle, door, false)
  else
    SetVehicleDoorOpen(vehicle, door, false, false)
  end
end

--- The label of a door option: open or close, and which door.
---@param door number The door index.
---@param nameKey string The translation key of the door name.
---@return function label Reads the state at display time.
local function doorLabel(door, nameKey)
  return function(target)
    local verb <const> = isDoorOpen(target.entity, door) and 'interaction_close' or 'interaction_open'

    return T(verb, T(nameKey))
  end
end

--- One option toggling a door, hidden when the model has none.
---@param door number The door index.
---@param nameKey string The translation key of the door name.
---@param icon string The lucide icon.
---@param order number The sort key.
---@return table option The option.
local function doorOption(door, nameKey, icon, order)
  return {
    id = ('siku_target:vehicle:door:%d'):format(door),
    label = doorLabel(door, nameKey),
    icon = icon,
    order = order,
    distance = config.distance,
    canInteract = function(target)
      return isDoorUsable(target.entity, door)
    end,
    onSelect = function(target)
      toggleDoor(target.entity, door)
    end,
  }
end

--- Whether a seat exists on the model and nobody sits in it.
---@param vehicle number The vehicle handle.
---@param seat number The seat index.
---@return boolean free Whether the player may take it.
local function isSeatFree(vehicle, seat)
  if seat + 1 >= GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) then
    return false
  end

  return IsVehicleSeatFree(vehicle, seat)
end

--- Puts the player on a seat: a warp from another seat of the same
--- vehicle, a walk and a climb from outside.
---@param vehicle number The vehicle handle.
---@param seat number The seat index.
---@return nil
local function takeSeat(vehicle, seat)
  local ped <const> = PlayerPedId()

  if GetVehiclePedIsIn(ped, false) == vehicle then
    TaskWarpPedIntoVehicle(ped, vehicle, seat)
    return
  end

  TaskEnterVehicle(ped, vehicle, -1, seat, ENTER_SPEED, ENTER_FLAG_NORMAL, 0)
end

--- One entry of the seats submenu, hidden when the seat is taken or missing.
---@param seat number The seat index.
---@param nameKey string The translation key of the seat name.
---@return table option The option.
local function seatOption(seat, nameKey)
  return {
    id = ('siku_target:vehicle:seat:%d'):format(seat),
    label = T(nameKey),
    icon = seat == SEAT_DRIVER and 'key' or 'user',
    order = seat,
    canInteract = function(target)
      return isSeatFree(target.entity, seat)
    end,
    onSelect = function(target)
      takeSeat(target.entity, seat)
    end,
  }
end

--- Registers what every vehicle offers, as the config allows.
---@return nil
local function register()
  if not config.enabled then
    return
  end

  local options <const> = {}

  if config.doors then
    local doors <const> = {}

    for i, door in ipairs(DOORS) do
      doors[#doors + 1] = doorOption(door.index, door.key, 'door-open', i)
    end

    options[#options + 1] = {
      id = 'siku_target:vehicle:doors',
      label = T('interaction_doors'),
      icon = 'door-open',
      order = 10,
      distance = config.distance,
      canInteract = function(target)
        return GetVehicleDoorLockStatus(target.entity) ~= LOCK_LOCKED
      end,
      items = doors,
    }
  end

  if config.hood then
    options[#options + 1] = doorOption(DOOR_HOOD, 'interaction_hood', 'car', 20)
  end

  if config.trunk then
    options[#options + 1] = doorOption(DOOR_TRUNK, 'interaction_trunk', 'box', 30)
  end

  if config.seats then
    local seats <const> = {}

    for _, seat in ipairs(SEATS) do
      seats[#seats + 1] = seatOption(seat.index, seat.key)
    end

    options[#options + 1] = {
      id = 'siku_target:vehicle:seats',
      label = T('interaction_seats'),
      icon = 'users',
      order = 40,
      distance = config.distance,
      canInteract = function(target)
        return TargetConfig.mode == MODE_FREE and GetVehicleDoorLockStatus(target.entity) ~= LOCK_LOCKED
      end,
      items = seats,
    }
  end

  TargetRegistry.addToScope('vehicle', options)
end

register()
