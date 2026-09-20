TargetRegistry = {}

local SCOPE_LISTS <const> = { 'localPlayer', 'player', 'ped', 'vehicle', 'object', 'global' }
local SCOPE_MAPS <const> = { 'models', 'entities', 'netEntities', 'zones' }

local lists <const> = {}
local maps <const> = {}
local index <const> = {}
local counters <const> = {}

for _, scope in ipairs(SCOPE_LISTS) do
  lists[scope] = {}
end

for _, scope in ipairs(SCOPE_MAPS) do
  maps[scope] = {}
end

--- The resource that called the export, or this one.
---@return string resource The resource name.
local function caller()
  return GetInvokingResource() or Siku.name
end

--- Whether a value may act as a callback.
---@param value any The value.
---@return boolean callable Whether it can be called.
local function isCallable(value)
  return type(value) == 'function' or Siku.isCallable(value) == true
end

--- Whether an option knows how to act.
---@param option table The option.
---@return boolean acts Whether it carries an action.
local function hasAction(option)
  return isCallable(option.onSelect)
    or type(option.event) == 'string'
    or type(option.serverEvent) == 'string'
    or type(option.export) == 'string'
end

--- Turns what a resource registered into an entry the target trusts.
--- Faults are reported and the option dropped, never fatal.
---@param raw any The option as registered.
---@param resource string The registering resource.
---@param nested boolean Whether this is a submenu entry.
---@return table? entry The entry, or nil when unusable.
local function normalize(raw, resource, nested)
  if type(raw) ~= 'table' then
    Siku.print.warn(T('option_invalid', resource, 'not a table'))
    return nil
  end

  if type(raw.label) ~= 'string' and not isCallable(raw.label) then
    Siku.print.warn(T('option_invalid', resource, 'label missing'))
    return nil
  end

  local entry <const> = {
    id = type(raw.id) == 'string' and raw.id or nil,
    label = raw.label,
    icon = type(raw.icon) == 'string' and raw.icon or nil,
    order = type(raw.order) == 'number' and raw.order or 0,
    distance = type(raw.distance) == 'number' and raw.distance or nil,
    canInteract = isCallable(raw.canInteract) and raw.canInteract or nil,
    onSelect = isCallable(raw.onSelect) and raw.onSelect or nil,
    event = type(raw.event) == 'string' and raw.event or nil,
    serverEvent = type(raw.serverEvent) == 'string' and raw.serverEvent or nil,
    export = type(raw.export) == 'string' and raw.export or nil,
    resource = resource,
  }

  if type(raw.items) == 'table' and #raw.items > 0 then
    if nested then
      Siku.print.warn(T('option_invalid', resource, 'a submenu entry cannot open another submenu'))
      return nil
    end

    entry.items = {}

    for i = 1, #raw.items do
      local child <const> = normalize(raw.items[i], resource, true)

      if child then
        entry.items[#entry.items + 1] = child
      end
    end

    if #entry.items == 0 then
      Siku.print.warn(T('option_invalid', resource, 'submenu without any usable entry'))
      return nil
    end
  elseif not hasAction(entry) then
    Siku.print.warn(T('option_invalid', resource, 'no action: onSelect, event, serverEvent or export'))
    return nil
  end

  return entry
end

--- Gives an entry a unique id when the resource gave none, and refuses a
--- duplicate.
---@param entry table The entry.
---@return boolean accepted Whether the id is usable.
local function assignId(entry)
  if not entry.id then
    counters[entry.resource] = (counters[entry.resource] or 0) + 1
    entry.id = ('%s#%d'):format(entry.resource, counters[entry.resource])
  end

  if index[entry.id] then
    Siku.print.warn(T('option_invalid', entry.resource, ('id "%s" already registered'):format(entry.id)))
    return false
  end

  if entry.items then
    for i = 1, #entry.items do
      entry.items[i].id = ('%s/%d'):format(entry.id, i)
    end
  end

  return true
end

--- Stores a list of options under a scope.
---@param list table The scope list.
---@param options any One option or a list of options.
---@param resource string The registering resource.
---@param location table Where the entry lives, for removal { list }.
---@return table ids The ids stored.
local function store(list, options, resource, location)
  local ids <const> = {}
  local raws <const> = type(options) == 'table' and options[1] ~= nil and options or { options }

  for i = 1, #raws do
    local entry <const> = normalize(raws[i], resource, false)

    if entry and assignId(entry) then
      list[#list + 1] = entry
      index[entry.id] = { entry = entry, list = list, key = location.key, map = location.map }
      ids[#ids + 1] = entry.id
    end
  end

  return ids
end

--- Registers options on a whole kind of target.
---@param scope string 'localPlayer' | 'player' | 'ped' | 'vehicle' | 'object' | 'global'.
---@param options any One option or a list of options.
---@return table ids The ids stored.
function TargetRegistry.addToScope(scope, options)
  return store(lists[scope], options, caller(), {})
end

--- Registers options on a keyed set: models, entities, netEntities, zones.
---@param map string The map name.
---@param key any The key: model hash, entity handle, net id or zone id.
---@param options any One option or a list of options.
---@return table ids The ids stored.
function TargetRegistry.addToMap(map, key, options)
  maps[map][key] = maps[map][key] or {}

  return store(maps[map][key], options, caller(), { map = map, key = key })
end

--- The options of a whole kind.
---@param scope string The scope name.
---@return table list The entries, possibly empty.
function TargetRegistry.scope(scope)
  return lists[scope] or {}
end

--- The options of a keyed set.
---@param map string The map name.
---@param key any The key.
---@return table list The entries, possibly empty.
function TargetRegistry.keyed(map, key)
  local set <const> = maps[map]

  return set and set[key] or {}
end

--- The entry behind an id.
---@param id string The option id.
---@return table? entry The entry, or nil.
function TargetRegistry.get(id)
  local located <const> = index[id]

  return located and located.entry or nil
end

--- Forgets an option.
---@param id string The option id.
---@return boolean removed Whether it existed.
function TargetRegistry.remove(id)
  local located <const> = index[id]

  if not located then
    return false
  end

  for i = #located.list, 1, -1 do
    if located.list[i].id == id then
      table.remove(located.list, i)
    end
  end

  if located.map and #located.list == 0 then
    maps[located.map][located.key] = nil
  end

  index[id] = nil

  return true
end

--- Forgets everything a resource registered.
---@param resource string The resource name.
---@return number count How many options went away.
function TargetRegistry.purge(resource)
  local ids <const> = {}

  for id, located in pairs(index) do
    if located.entry.resource == resource then
      ids[#ids + 1] = id
    end
  end

  for i = 1, #ids do
    TargetRegistry.remove(ids[i])
  end

  return #ids
end
