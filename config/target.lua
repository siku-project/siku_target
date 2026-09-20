TargetConfig = {
  --- Mode
  ---
  --- How a target is picked. Everything after that, the options, the menu,
  --- the actions, is the same in both modes.
  ---
  --- • 'classic': a reticle at the centre of the screen, what the camera
  ---   looks at is the target, the menu opens next to the reticle as soon
  ---   as the target has options.
  --- • 'free': the pointer roams the screen, a click on the world picks
  ---   the target under it and opens the menu next to the pointer.
  ---
  --- Available: 'classic', 'free'
  ---
  --- Default: 'classic'
  mode = 'classic',

  --- Keybind
  ---
  --- The key that activates the target, registered through the core so
  --- every player can rebind it in the game settings.
  ---
  --- Default: 'LMENU' (left Alt)
  keybind = 'LMENU',

  --- Activation
  ---
  --- • 'hold': the target lives while the key is held.
  --- • 'toggle': one press opens it, the next one closes it.
  ---
  --- Available: 'hold', 'toggle'
  ---
  --- Default: 'hold'
  activation = 'hold',

  --- Scan interval
  ---
  --- In classic mode, how often (ms) the camera ray is cast while the
  --- target is active. Nothing is cast when it is not.
  ---
  --- Default: 100
  scanInterval = 100,

  --- Ray distance
  ---
  --- How far (metres) the ray reaches. Beyond it, the target is the world.
  ---
  --- Default: 12.0
  rayDistance = 12.0,

  --- Option distance
  ---
  --- How close (metres) the player must be to the point hit for an option
  --- to show, unless the option carries its own `distance`.
  ---
  --- Default: 3.0
  optionDistance = 3.0,

  --- Controls
  ---
  --- The game controls disabled while the target is active, so a click on
  --- the menu never fires nor punches: attack, aim, weapon wheel and slots,
  --- melee, vehicle attack, phone, pause. The camera look (1, 2) is handled
  --- apart: free while aiming in classic mode, held only while the pointer
  --- is over the menu, always held in free mode.
  controls = {
    24, 25, 37, 44, 45, 47, 58, 140, 141, 142, 143, 257, 263, 264,
    14, 15, 16, 17, 157, 158, 159, 160, 161, 162, 163, 164, 165, 261, 262,
    68, 69, 70, 92, 114, 106,
    27, 172, 173, 174, 175, 176, 177,
    199, 200, 202, 244,
  },

  --- Debug
  ---
  --- Draws the ray and the point hit while the target is active.
  ---
  --- Default: false
  debug = false,
}
