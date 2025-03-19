-- Name: Big Planets testing
-- Description: Big Planets testing
-- Type: Development

require("utils.lua")

-- Scaling factors:
-- Distance from Sol
scale_far = 1 / 500
-- Radius
scale_rad = 1
-- Orbital speed
scale_orb = scale_far * 10
--scale_orb = scale_far / 2200
-- Axial speed
scale_rot = 1 / 100

function solScale(meters)
  -- Convert meter value to integer units (0.001U, 1mU) for use in Planet() functions
  -- IDEA: math.log() to scale small distances less and large distances more
  return meters * (100000 / 6378137)
end
function solScaleAU(au)
  -- 1 AU: 149.5979 Gm
  --return solScale(au * 149598023000) / 600
  return solScale(au * 149598023000) * scale_far
end
-- FIXME: These two functions return (sec * 40) for game ticks, not actual seconds.
-- Could be renamed, I guess.
-- NOTE: According to the tutorial site, 60/s:
-- "the game runs any code in the update function every game tick, or about 60 times per second."
function dayToSec(d)
  return d * 86400 * 60
end
function hourToSec(h)
  return h * 3600 * 40
end
function yearToSec(y)
  return dayToSec(y * 365.256363004)
end

-- Scale radii
function solScaleRad(r)
  return solScale(r)
end
-- Scale orbital speeds
function solScaleOrb(o)
  return o * scale_orb
end
-- Scale axial rotation
-- KLUDGE: Earth spins CCW, but positive AxialRotationTime value makes it spin CW
-- so here we reverse (negate) the integer value so Earth and others spin correctly
-- (sorry, Uranus...)
function solScaleRot(a)
  return -a * scale_rot
end

sun_offset = 0 - solScaleAU(1.25) + solScaleRad(6378137)

function init()

  bodies = {
    ["Sol"] = {
      parent = nil,
      pos_x = sun_offset,
      pos_y = 0,
      radius = solScaleRad(696000000) / 14,
      angle = 0,
      atmo_r = 1.0,
      atmo_g = 0.8,
      atmo_b = 0.2,
      texture = "planets/star-1.png",
      rotation = 36000, -- FAST!
      orbit = 0,
      instance = nil
    },
    ["Earth"] = {
      parent = "Sol",
      --pos_x = solScale(384399000)/16,
      --pos_y = 0,
      distance = solScaleAU(1),
      radius = solScaleRad(6378137),
      angle = 0,
      atmo_r = 0.2,
      atmo_g = 0.2,
      atmo_b = 0.5,
      texture = "planets/planet-earth.png",
      rotation = dayToSec(1),
      orbit = yearToSec(1),
      instance = nil
    },
    -- The term "moon" is generic. This one is named Luna.
    -- Some values here not necessarily to scale; rather to look and play nice.
    ["Luna"] = {
      parent = "Earth",
      distance = solScale(384399000) / 16,
      radius = solScaleRad(1738100),
      -- This angle was chosen so that the tidally locked Moon texture
      -- planets/Moon/luna-1.png looks correct to folks at Earth (rough guess)
      angle = 100,
      texture = "planets/moon-2.png",
      rotation = dayToSec(28),
      orbit = yearToSec(28), -- Synchronous
      instance = nil
    }
  }

  Player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setCallSign("Sounder")
  Player:commandTargetRotation(180):setRotation(180)
  Player:setJumpDrive(true)
  Player:setWarpDrive(true)
  Player:setWarpSpeed(10000)

  makeBody("Luna", bodies["Luna"])

end

function makeBody(name,config)
  local b = Planet()
  b:setCallSign(name)
  b:setPlanetRadius(config["radius"])
  if config["texture"] then
    b:setPlanetSurfaceTexture(config["texture"])
  end
  -- FIXME: Uh, oh! Some scales are done in bodies{} and others (rot and orb) here :(
  b:setAxialRotationTime(solScaleRot(config["rotation"]))

  if config["atmo_r"] and config["atmo_g"] and config["atmo_b"] then
    b:setPlanetAtmosphereColor(config["atmo_r"], config["atmo_g"], config["atmo_b"])
  end
  if config["atmo_t"] then
    b:setPlanetAtmosphereTexture(config["atmo_t"])
  end
  if config["clouds"] then
    b:setPlanetCloudTexture(config["clouds"])
  end

  --Here comes the tricky part...
  if config["parent"] == nil then
    --if config["pos_x"] and config["pos_y"] then
    b:setPosition(config["pos_x"], config["pos_y"])
  else
    local p = bodies[config["parent"]]["instance"]
    if p == nil then
      p = makeBody(config["parent"], bodies[config["parent"]])
    end
    local px, py = p:getPosition()
    local pr = p:getPlanetRadius()
    setCirclePos(b, px, py, config["angle"], pr + config["distance"])
    -- setCirclePos(b, px, py, 0, config["distance"]) -- Straight line
    b:setOrbit(p, solScaleOrb(config["orbit"]))
  end

  bodies[name]["instance"] = b
  return b
end

function makeBodies()
  for name,config in pairs(bodies) do
    makeBody(name, config)
  end
end

lastupdate = 0
sectorNum = 7
function update(delta)
    lastupdate = lastupdate + delta
    if lastupdate > 10 then
        P:setPlanetRadius(sectorNum * 2000)
        P:setPosition(sectorToXY("F" .. sectorNum))
        P:setPlanetSurfaceTexture("planets/planet-" .. sectorNum % 6 .. ".png")
        sectorNum = sectorNum + 1
        lastupdate = 0
    end
end

-- Set callback function
onNewPlayerShip(
  function(ship)
      -- Decide what you do with new ships:
      print(ship, ship.typeName, ship:getTypeName(), ship:getCallSign())
  end
)
