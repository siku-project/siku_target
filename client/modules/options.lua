TargetOptions = {}

--- The scopes an entity kind draws from, besides models, entities and zones.
local KIND_SCOPES <const> = {
  localPlayer = { 'localPlayer' },
  player = { 'player' },
  ped = { 'ped' },
  vehicle = { 'vehicle' },
  object = { 'object' },
  zone = {},
  world = {},
}

--- Whether a value may act as a callback.
---@param value any The value.
---@return boolean callable Whether it can be called.
local function isCallable(value)
  return type(value) == 'function' or Siku.isCallable(value) == true
end

--- The label of an entry for a target, resolved when it is a function.
---@param entry table The entry.
---@param target table The target.
---@return string label The label.
local function labelOf(entry, target)
  if isCallable(entry.label) then
    local ok <const>, label <const> = pcall(entry.label, target)

    return ok and type(label) == 'string' and label or entry.id
  end

  return entry.label
end

--- Whether an entry shows for a target: near enough, and its own say.
---@param entry table The entry.
---@param target table The target.
---@return boolean shown Whether it is available here.
local function isAvailable(entry, target)
  local reach <const> = entry.distance or TargetConfig.optionDistance

  if target.hit and target.distance > reach then
    return false
  end

  if entry.items and not MenuConfig.submenus then
    return false
  end

  if not entry.canInteract then
    return true
  end

  local ok <const>, allowed <const> = pcall(entry.canInteract, target)

  if not ok then
    Siku.print.warn(T('option_failed', entry.id, tostring(allowed)))
    return false
  end

  return allowed ~= false
end

--- The entries that apply to a target, sorted, before any condition.
---@param target table The target.
---@return table entries The candidate entries.
local function candidates(target)
  local pool <const> = {}
  local seen <const> = {}

  local function take(list)
    for i = 1, #list do
      if not seen[list[i].id] then
        seen[list[i].id] = true
        pool[#pool + 1] = list[i]
      end
    end
  end

  for _, scope in ipairs(KIND_SCOPES[target.kind] or {}) do
    take(TargetRegistry.scope(scope))
  end

  if target.entity then
    take(TargetRegistry.keyed('models', target.model))
    take(TargetRegistry.keyed('entities', target.entity))

    if target.netId then
      take(TargetRegistry.keyed('netEntities', target.netId))
    end
  end

  for _, zoneId in ipairs(target.zones) do
    take(TargetRegistry.keyed('zones', zoneId))
  end

  take(TargetRegistry.scope('global'))

  table.sort(pool, function(a, b)
    if a.order ~= b.order then
      return a.order < b.order
    end

    return a.id < b.id
  end)

  return pool
end

--- The entries available on a target right now, from the whole registry.
---@param target table The target.
---@return table entries The entries, in menu order.
function TargetOptions.gather(target)
  local entries <const> = {}

  for _, entry in ipairs(candidates(target)) do
    if isAvailable(entry, target) then
      entries[#entries + 1] = entry
    end
  end

  return entries
end

--- The entries of a submenu available on a target right now.
---@param parent table The entry that opens the submenu.
---@param target table The target.
---@return table entries The child entries, in menu order.
function TargetOptions.children(parent, target)
  local entries <const> = {}

  for _, child in ipairs(parent.items or {}) do
    if isAvailable(child, target) then
      entries[#entries + 1] = child
    end
  end

  table.sort(entries, function(a, b)
    if a.order ~= b.order then
      return a.order < b.order
    end

    return a.id < b.id
  end)

  return entries
end

--- What the interface draws for a list of entries.
---@param entries table The entries.
---@param target table The target.
---@return table rows A list of { id, label, icon?, submenu }.
function TargetOptions.describe(entries, target)
  local rows <const> = {}

  for i = 1, #entries do
    rows[i] = {
      id = entries[i].id,
      label = labelOf(entries[i], target),
      icon = entries[i].icon,
      submenu = entries[i].items ~= nil,
    }
  end

  return rows
end
