TargetResolve = {}

local ZONE_TAG <const> = 'siku_target'
local ENTITY_PED <const> = 1
local ENTITY_VEHICLE <const> = 2
local ENTITY_OBJECT <const> = 3
local NO_ENTITY <const> = 0

--- The kind of an entity the ray hit.
---@param entity number The entity handle.
---@return string kind 'localPlayer' | 'player' | 'ped' | 'vehicle' | 'object'.
---@return number? serverId The server id, for a player.
local function classify(entity)
  local entityType <const> = GetEntityType(entity)

  if entityType == ENTITY_PED then
    if entity == PlayerPedId() then
      return 'localPlayer', GetPlayerServerId(PlayerId())
    end

    if IsPedAPlayer(entity) then
      return 'player', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
    end

    return 'ped', nil
  end

  if entityType == ENTITY_VEHICLE then
    return 'vehicle', nil
  end

  if entityType == ENTITY_OBJECT then
    return 'object', nil
  end

  return 'world', nil
end

--- The ids of the target zones containing a point.
---@param coords vector3 The point.
---@return table ids The zone ids, possibly empty.
local function zonesAt(coords)
  local ids <const> = {}

  for _, zone in ipairs(Siku.spatial.getZonesAtCoords(coords, { ZONE_TAG })) do
    ids[#ids + 1] = zone.id
  end

  return ids
end

--- Turns a raycast result into the target every module reasons about.
---@param result table { hit, entityHit, endCoords }.
---@return table target { kind, entity?, netId?, model?, serverId?, coords, distance, zones, hit }.
function TargetResolve.fromRay(result)
  local coords <const> = result.endCoords
  local entity <const> = result.entityHit or NO_ENTITY
  local target <const> = {
    kind = 'world',
    coords = coords,
    distance = #(GetEntityCoords(PlayerPedId()) - coords),
    zones = zonesAt(coords),
    hit = result.hit == true,
  }

  if entity ~= NO_ENTITY and DoesEntityExist(entity) then
    local kind <const>, serverId <const> = classify(entity)

    if kind ~= 'world' then
      target.kind = kind
      target.entity = entity
      target.model = GetEntityModel(entity)
      target.serverId = serverId
      target.netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or nil
    end
  end

  if target.kind == 'world' and #target.zones > 0 then
    target.kind = 'zone'
  end

  return target
end

--- What tells two targets apart: the entity, or the zones, or the world.
---@param target table The target.
---@return string signature A key stable while the target stays the same.
function TargetResolve.signature(target)
  if target.entity then
    return ('%s:%d'):format(target.kind, target.entity)
  end

  if #target.zones > 0 then
    return 'zone:' .. table.concat(target.zones, ',')
  end

  return 'world'
end

--- The part of a target that survives the network: no handles, only what
--- a server can use.
---@param target table The target.
---@return table payload { kind, netId?, serverId?, model?, coords, distance, zones }.
function TargetResolve.serialize(target)
  return {
    kind = target.kind,
    netId = target.netId,
    serverId = target.serverId,
    model = target.model,
    coords = target.coords,
    distance = target.distance,
    zones = target.zones,
  }
end
