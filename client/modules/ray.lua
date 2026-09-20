TargetRay = {}

local FLAGS <const> = 511
local IGNORE_FLAGS <const> = 4
local NO_ENTITY <const> = 0
local ROTATION_ORDER <const> = 2
local RAD <const> = math.pi / 180
local PROBE_DEPTH <const> = 10.0
local PROBE_ANGLE <const> = 10.0
local EPSILON <const> = 0.001
local DEBUG_COLOR <const> = { 108, 182, 246, 200 }
local DEBUG_MARKER_SIZE <const> = 0.08

--- The direction a camera rotation looks at.
---@param rotation vector3 The rotation in degrees.
---@return vector3 direction The normalized direction.
local function rotationToDirection(rotation)
  local radX <const> = rotation.x * RAD
  local radZ <const> = rotation.z * RAD
  local cosX <const> = math.abs(math.cos(radX))

  return vector3(-math.sin(radZ) * cosX, math.cos(radZ) * cosX, math.sin(radX))
end

--- Where a world point lands on the screen, as fractions of it.
---@param point vector3 The world point.
---@return number? x The horizontal fraction, or nil when off screen.
---@return number? y The vertical fraction.
local function worldToScreen(point)
  local onScreen <const>, x <const>, y <const> = GetScreenCoordFromWorldCoord(point.x, point.y, point.z)

  if not onScreen then
    return nil, nil
  end

  return x, y
end

--- The world point under a screen position, ten metres in front of the
--- camera: two probes measure how far a step right and a step up move on
--- the screen, then the screen offset is scaled back into the world.
---@param x number The horizontal screen fraction, 0 to 1.
---@param y number The vertical screen fraction, 0 to 1.
---@return vector3 origin The camera position.
---@return vector3 point The world point under the pointer, ten metres deep.
local function screenToWorld(x, y)
  local origin <const> = GetFinalRenderedCamCoord()
  local rotation <const> = GetFinalRenderedCamRot(ROTATION_ORDER)
  local forward <const> = rotationToDirection(rotation)

  local right <const> = rotationToDirection(rotation + vector3(0.0, 0.0, PROBE_ANGLE))
    - rotationToDirection(rotation + vector3(0.0, 0.0, -PROBE_ANGLE))
  local up <const> = rotationToDirection(rotation + vector3(PROBE_ANGLE, 0.0, 0.0))
    - rotationToDirection(rotation + vector3(-PROBE_ANGLE, 0.0, 0.0))

  local roll <const> = -rotation.y * RAD
  local rightRolled <const> = right * math.cos(roll) - up * math.sin(roll)
  local upRolled <const> = right * math.sin(roll) + up * math.cos(roll)

  local centre <const> = origin + forward * PROBE_DEPTH
  local probe <const> = centre + rightRolled + upRolled

  local centreX <const>, centreY <const> = worldToScreen(centre)
  local probeX <const>, probeY <const> = worldToScreen(probe)

  if not centreX or not probeX then
    return origin, centre
  end

  if math.abs(probeX - centreX) < EPSILON or math.abs(probeY - centreY) < EPSILON then
    return origin, centre
  end

  local scaleX <const> = (x - centreX) / (probeX - centreX)
  local scaleY <const> = (y - centreY) / (probeY - centreY)

  return origin, centre + rightRolled * scaleX + upRolled * scaleY
end

--- Draws where a ray went, when the debug flag is on.
---@param origin vector3 The start.
---@param result table The raycast result.
---@return nil
local function drawDebug(origin, result)
  if not TargetConfig.debug then
    return
  end

  local finish <const> = result.endCoords
  local r <const>, g <const>, b <const>, a <const> = table.unpack(DEBUG_COLOR)

  DrawLine(origin.x, origin.y, origin.z, finish.x, finish.y, finish.z, r, g, b, a)
  DrawMarker(
    28, finish.x, finish.y, finish.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    DEBUG_MARKER_SIZE, DEBUG_MARKER_SIZE, DEBUG_MARKER_SIZE, r, g, b, a,
    false, false, 2, false, nil, nil, false
  )
end

--- Casts from the camera through the centre of the screen.
---@return table result { hit, entityHit, endCoords, surfaceNormal, materialHash }.
function TargetRay.fromCamera()
  local result <const> = Siku.raycast.fromCamera(TargetConfig.rayDistance, FLAGS, PlayerPedId(), IGNORE_FLAGS)

  drawDebug(GetFinalRenderedCamCoord(), result)

  return result
end

--- Casts from the camera through a screen position, the player's own ped
--- included so a click on it finds it.
---@param x number The horizontal screen fraction, 0 to 1.
---@param y number The vertical screen fraction, 0 to 1.
---@return table result { hit, entityHit, endCoords, surfaceNormal, materialHash }.
function TargetRay.fromScreen(x, y)
  local origin <const>, point <const> = screenToWorld(x, y)
  local direction <const> = point - origin
  local length <const> = #direction

  if length < EPSILON then
    return { hit = false, entityHit = NO_ENTITY, endCoords = origin }
  end

  local destination <const> = origin + (direction / length) * TargetConfig.rayDistance
  local result <const> = Siku.raycast.fromCoords(origin, destination, FLAGS, NO_ENTITY, IGNORE_FLAGS)

  drawDebug(origin, result)

  return result
end
