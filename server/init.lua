local REQUIRED_CORE_VERSION <const> = '1.0.0'

local dependency <const> = Siku.version.checkDependency('siku_core', REQUIRED_CORE_VERSION)

if not dependency.ok then
  Siku.print.throw(dependency.message)
end

Siku.print.success(('Linked to siku_core (%s)'):format(dependency.currentVersion))
Siku.version.checkRelease('siku-project/siku_target')

--- The target runs on the client; the server only reports what every
--- player will get, after the shared config has loaded.
CreateThread(function()
  Wait(0)

  Siku.print.success(('Target ready, mode %s, key %s (%s), submenus %s'):format(
    TargetConfig.mode,
    TargetConfig.keybind,
    TargetConfig.activation,
    MenuConfig.submenus and 'on' or 'off'
  ))
end)
