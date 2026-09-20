InteractionsConfig = {
  --- Vehicles
  ---
  --- The options every vehicle offers out of the box, from
  --- client/interactions/vehicle.lua. Each family switches off on its own.
  vehicle = {
    enabled = true,

    --- Open or close each door the model has, in a submenu.
    doors = true,

    --- Open or close the hood, and the trunk.
    hood = true,
    trunk = true,

    --- Take a free seat, from outside or from another seat. Only in the
    --- free mode, where the player clicks the vehicle they stand by or
    --- sit in.
    seats = true,

    --- How close (metres) the player must be to the point hit.
    ---
    --- Default: 3.0
    distance = 3.0,
  },

  --- Self
  ---
  --- The options a player gets by clicking their own ped, from
  --- client/interactions/self.lua. Only reachable in the free mode.
  self = {
    enabled = true,
  },
}
