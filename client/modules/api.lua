local ZONE_TAG <const> = 'siku_target'

--- Registers options on a whole kind of target.
---@param scope string The scope.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addScope(scope, options)
  return { ids = TargetRegistry.addToScope(scope, options) }
end

--- Options on the player's own ped, reachable in free mode.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addLocalPlayer(options)
  return addScope('localPlayer', options)
end

--- Options on every other player.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addPlayer(options)
  return addScope('player', options)
end

--- Options on every ped that is not a player.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addPed(options)
  return addScope('ped', options)
end

--- Options on every vehicle.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addVehicle(options)
  return addScope('vehicle', options)
end

--- Options on every object.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addObject(options)
  return addScope('object', options)
end

--- Options everywhere, the ground included, each one deciding for itself.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addGlobal(options)
  return addScope('global', options)
end

--- Options on one or several models.
---@param models string|number|table A model name or hash, or a list of them.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addModel(models, options)
  local list <const> = type(models) == 'table' and models or { models }
  local ids <const> = {}

  for _, model in ipairs(list) do
    local hash <const> = type(model) == 'string' and joaat(model) or model

    for _, id in ipairs(TargetRegistry.addToMap('models', hash, options)) do
      ids[#ids + 1] = id
    end
  end

  return { ids = ids }
end

--- Options on one entity, by its local handle.
---@param entity number The entity handle.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addEntity(entity, options)
  return { ids = TargetRegistry.addToMap('entities', entity, options) }
end

--- Options on one networked entity, by its net id, whatever its handle here.
---@param netId number The network id.
---@param options table One option or a list of options.
---@return table handle { ids }.
local function addNetworkedEntity(netId, options)
  return { ids = TargetRegistry.addToMap('netEntities', netId, options) }
end

--- Creates the core zone a shape describes, tagged for the target.
---@param shape table { sphere = { coords, radius } } | { box = { coords, size, heading } } | { poly = { points, minZ, maxZ } }.
---@param debug? boolean Whether the zone draws itself.
---@return table? zone The active zone, or nil when the shape is unknown.
local function createZone(shape, debug)
  local options <const> = { tags = { ZONE_TAG }, debug = debug == true }

  if type(shape.sphere) == 'table' then
    return Siku.spatial.addSphereZone(shape.sphere.coords, shape.sphere.radius, options)
  end

  if type(shape.box) == 'table' then
    return Siku.spatial.addBoxZone(shape.box.coords, shape.box.size, shape.box.heading or 0.0, options)
  end

  if type(shape.poly) == 'table' then
    return Siku.spatial.addPolyZone(shape.poly.points, shape.poly.minZ, shape.poly.maxZ, options)
  end

  return nil
end

--- Options inside a zone: the world clicked or aimed at within it.
---@param shape table The zone shape, see createZone.
---@param options table One option or a list of options.
---@return table? handle { ids, zone }, or nil when the shape is unknown.
local function addZone(shape, options)
  if type(shape) ~= 'table' then
    return nil
  end

  local zone <const> = createZone(shape, shape.debug)

  if not zone then
    Siku.print.warn(T('zone_invalid', GetInvokingResource() or Siku.name))
    return nil
  end

  return { ids = TargetRegistry.addToMap('zones', zone.id, options), zone = zone.id }
end

--- Options around a point.
---@param coords vector3 The centre.
---@param radius number The reach in metres.
---@param options table One option or a list of options.
---@return table? handle { ids, zone }.
local function addPoint(coords, radius, options)
  return addZone({ sphere = { coords = coords, radius = radius } }, options)
end

--- Forgets options: a handle, an id, or a list of ids. A zone made for
--- them goes away with them.
---@param what table|string A handle { ids, zone? }, an id, or a list of ids.
---@return number removed How many options went away.
local function remove(what)
  local removed = 0

  if type(what) == 'string' then
    return TargetRegistry.remove(what) and 1 or 0
  end

  if type(what) ~= 'table' then
    return 0
  end

  for _, id in ipairs(what.ids or what) do
    if TargetRegistry.remove(id) then
      removed = removed + 1
    end
  end

  if what.zone then
    Siku.spatial.removeZone(what.zone)
  end

  return removed
end

--- Whether the target is on screen.
---@return boolean active Whether it runs.
local function isActive()
  return TargetInput.isActive()
end

--- Keeps the target away, for a menu or a cinematic, and back.
---@param value boolean Whether the target is refused.
---@return nil
local function disable(value)
  TargetInput.setDisabled(value)
end

--- Closes the target if it runs.
---@return nil
local function close()
  TargetInput.stop()
end

exports('AddLocalPlayer', addLocalPlayer)
exports('AddPlayer', addPlayer)
exports('AddPed', addPed)
exports('AddVehicle', addVehicle)
exports('AddObject', addObject)
exports('AddGlobal', addGlobal)
exports('AddModel', addModel)
exports('AddEntity', addEntity)
exports('AddNetworkedEntity', addNetworkedEntity)
exports('AddZone', addZone)
exports('AddPoint', addPoint)
exports('Remove', remove)
exports('IsActive', isActive)
exports('Disable', disable)
exports('Close', close)
