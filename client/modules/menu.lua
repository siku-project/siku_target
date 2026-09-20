TargetMenu = {}

local current = nil

--- Finds an entry by id in the root level, then in the open submenu.
---@param id string The option id.
---@return table? entry The entry, or nil.
---@return boolean nested Whether it came from the submenu.
local function shownEntry(id)
  if not current then
    return nil, false
  end

  for _, entry in ipairs(current.entries) do
    if entry.id == id then
      return entry, false
    end
  end

  for _, entry in ipairs(current.children or {}) do
    if entry.id == id then
      return entry, true
    end
  end

  return nil, false
end

--- Runs what an entry does, each way reported when it fails.
---@param entry table The entry.
---@param target table The target.
---@return nil
local function act(entry, target)
  if entry.onSelect then
    local ok <const>, err <const> = pcall(entry.onSelect, target)

    if not ok then
      Siku.print.warn(T('option_failed', entry.id, tostring(err)))
    end
  end

  if entry.event then
    TriggerEvent(entry.event, target)
  end

  if entry.serverEvent then
    TriggerServerEvent(entry.serverEvent, TargetResolve.serialize(target))
  end

  if entry.export then
    local resource <const>, name <const> = entry.export:match('^([%w_%-]+)%.([%w_]+)$')

    if resource and name then
      local ok <const>, err <const> = pcall(function()
        return exports[resource][name](nil, target)
      end)

      if not ok then
        Siku.print.warn(T('option_failed', entry.id, tostring(err)))
      end
    end
  end
end

--- Opens the menu on a target, with what it offers.
---@param target table The target.
---@param entries table The root entries.
---@param anchor table|string 'reticle', or { x, y } screen fractions.
---@return nil
function TargetMenu.open(target, entries, anchor)
  current = { target = target, entries = entries, anchor = anchor }

  TargetNui.openMenu({
    items = TargetOptions.describe(entries, target),
    anchor = anchor,
  })
end

--- Whether a menu is on screen.
---@return boolean open Whether one shows.
function TargetMenu.isOpen()
  return current ~= nil
end

--- The target the menu is open on.
---@return table? target The target, or nil.
function TargetMenu.target()
  return current and current.target or nil
end

--- Picks an option: a root option carrying a submenu opens it beside the
--- menu, any other option acts.
---@param id string The option id.
---@return nil
function TargetMenu.select(id)
  local entry <const>, nested <const> = shownEntry(id)

  if not entry then
    return
  end

  if entry.items and not nested then
    current.parent = entry
    current.children = TargetOptions.children(entry, current.target)

    TargetNui.openSubmenu({
      parentId = entry.id,
      title = TargetOptions.describe({ entry }, current.target)[1].label,
      items = TargetOptions.describe(current.children, current.target),
    })
    return
  end

  local target <const> = current.target

  if MenuConfig.closeOnSelect then
    TargetInput.stop()
  end

  act(entry, target)
end

--- Closes the submenu, or the whole menu when none is open.
---@return nil
function TargetMenu.back()
  if not current then
    return
  end

  if current.parent then
    current.parent = nil
    current.children = nil
    TargetNui.closeSubmenu()
    return
  end

  TargetMenu.close()
end

--- Takes the menu off the screen.
---@return nil
function TargetMenu.close()
  if not current then
    return
  end

  current = nil
  TargetNui.closeMenu()
end
