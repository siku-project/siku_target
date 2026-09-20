local MODE_FREE <const> = 'free'
local WAVE_DICT <const> = 'anim@mp_player_intcelebrationmale@wave'
local WAVE_ANIM <const> = 'wave'
local WAVE_FLAG_UPPER_BODY <const> = 48
local WAVE_DURATION_MS <const> = 2500
local BLEND_IN <const> = 8.0
local BLEND_OUT <const> = -8.0

local config <const> = InteractionsConfig.self

--- A first interaction on oneself, to see the free mode work: a wave.
---@return nil
local function wave()
  local ped <const> = PlayerPedId()

  local loaded <const> = pcall(Siku.streaming.requestAnimDict, WAVE_DICT)

  if not loaded or not HasAnimDictLoaded(WAVE_DICT) then
    return
  end

  TaskPlayAnim(ped, WAVE_DICT, WAVE_ANIM, BLEND_IN, BLEND_OUT, WAVE_DURATION_MS, WAVE_FLAG_UPPER_BODY, 0.0, false, false, false)
  RemoveAnimDict(WAVE_DICT)
end

--- Registers what a player gets by clicking their own ped.
---@return nil
local function register()
  if not config.enabled then
    return
  end

  TargetRegistry.addToScope('localPlayer', {
    id = 'siku_target:self:wave',
    label = T('interaction_self_wave'),
    icon = 'hand',
    order = 10,
    canInteract = function()
      return TargetConfig.mode == MODE_FREE
    end,
    onSelect = wave,
  })
end

register()
