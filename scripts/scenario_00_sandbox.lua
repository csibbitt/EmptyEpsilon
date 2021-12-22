-- Name: Sandbox
-- Description: Are you in a sandbox, or the edge of a vast ocean? Are these wave crashing upon you, or merely a trickle of rain?
-- Type: Development

require("utils.lua")
require("jump_carrier.lua")
require("jam_area.lua")

jumpConfig = {
  ["JC-2"] = {
    destinations = {
      ["Home"] = { 2000, 2000 },
      ["Zulu Nine-Niner"] = { sectorToXY("Z99") },
      ["Alpha Sector"] =  { sectorToXY("A0") },
    },
    current_location = "Home",
    current_destination = nil,
    jumping_state = "wait_for_dock",
    jump_finished = true,
  }
}

function init()
  player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(sectorToXY("F5")):setRotation(315)
  player:setLongRangeRadarRange(80000)
  player:setWarpDrive(true)
  player:setWarpSpeed(5000)
  -- jamSectors("F6")
  -- jamSectors("H4", "J9")
  -- jamSectors("yf-9", "A-5")
  -- jamSectors("Z-9", "BB10")
  Planet():setPosition(56194, 26778):setPlanetRadius(5000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 1.0)
  Planet():setPosition(-20595, 60535):setPlanetRadius(40000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 1.0)

  jc2 = CpuShip():setFaction("Human Navy"):setTemplate("Jump Carrier"):setCallSign("JC-2"):setScanned(true):setPosition(300, 300):orderIdle()
  jc2:setJumpDriveRange(5000, 1000 * 50000)
  jc2:setCommsFunction(jcComms)

end

-- Main loop
function update(delta)

  --When the player ship is destroyed, call it a victory for the Exuari.
  if not player:isValid() then
    victory("The authors of history")
  end

  updateJumpCarrierState(jc2);

  --When Omega station is destroyed, call it a victory for the Human Navy.
  -- if not enemy_station:isValid() then
  --   victory("Human Navy")
  -- end

end



--   VisualAsteroid():setPosition(70391, -18259):setSize(128)
--   VisualAsteroid():setPosition(66985, -24693):setSize(128)
--   VisualAsteroid():setPosition(62254, -30747):setSize(111)
--   VisualAsteroid():setPosition(60741, -32261):setSize(129)
--   VisualAsteroid():setPosition(66796, -284):setSize(111)
--   VisualAsteroid():setPosition(60362, -32261):setSize(110)
--   VisualAsteroid():setPosition(83825, 32261):setSize(112)
--   VisualAsteroid():setPosition(81340, 47185):setSize(120)
--   VisualAsteroid():setPosition(-11539, 41533):setSize(113)
--   VisualAsteroid():setPosition(-34624, 26017):setSize(119)
--   VisualAsteroid():setPosition(-48436, 1041):setSize(125)
--   SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS196"):setPosition(55443, -23746)
--   SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS197"):setPosition(43522, -33586)
--   SpaceStation():setTemplate("Huge Station"):setFaction("Independent"):setCallSign("DS198"):setPosition(59227, 5771)
--   SpaceStation():setTemplate("Huge Station"):setFaction("Independent"):setCallSign("DS199"):setPosition(24500, 19343)
--   Artifact():setPosition(20255, -1201):setModel("artifact1")
--   Mine():setPosition(27608, -3415)
--   WormHole():setPosition(24255, 7844):setTargetPosition(0, 0)
--   WormHole():setPosition(3079, 19326):setTargetPosition(-25057, 25786)

--   research_station = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy")
--   research_station:setPosition(23500, 16100):setCallSign("Research-1")
--   main_station = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy")
--   main_station:setPosition(-25200, 32200):setCallSign("Orion-5")
--   enemy_station = SpaceStation():setTemplate("Large Station"):setFaction("Exuari")
--   enemy_station:setPosition(-45600, -15800):setCallSign("Omega")
--   neutral_station = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
--   neutral_station:setPosition(9100,-35400):setCallSign("Refugee-X")

--   --Start off the mission by sending a transmission to the player
--   research_station:sendCommsMessage(player, [[Epsilon, please come in?

-- We lost contact with our transport RT-4, who was transporting a diplomat from our research station to Orion-X.

-- Last contact was before RT-4 entered the nebula at G5.

-- Please investigate and recover the diplomat if possible!]])

--   Nebula():setPosition(62697, 19415)
--   Nebula():setPosition(35156, 44087)
--   BlackHole():setPosition(2356, 52216)
--   Planet():setPosition(56194, 26778):setPlanetRadius(5000)
--   Planet():setPosition(-20595, 60535):setPlanetRadius(5000)

--   enemy_station = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS209"):setPosition(-35057, 34786)
--   enemy_dreadnought = CpuShip():setShipTemplate("Atlantis X23"):setFaction("Exuari")
--   enemy_dreadnought:setPosition(-30057, 30786):orderDefendTarget(enemy_station)
--   CpuShip():setFaction("Exuari"):setTemplate("MT52 Hornet"):setCallSign("VS3"):setPosition(-30193, 34975):orderDefendTarget(enemy_dreadnought)
--   CpuShip():setFaction("Exuari"):setTemplate("MT52 Hornet"):setCallSign("SS2"):setPosition(-33194, 32148):orderDefendTarget(enemy_dreadnought)

--   jamArea(120000, 120000, 140000, 140000)

--   --Set the initial mission state
--   mission_state = 1
  
-- end

-- orderIdle(): Default state. Do not move or attack.
-- orderStandGround(): Hold this position, but attack enemies when they are in range. The ship will fire missiles as well as beam weapons.
-- orderDefendLocation(x, y): Fly toward the given position and defend it from attacks.
-- orderFlyFormation(target, offset_x, offset_y): Fly in formation with the target by keeping a certain offset. When enemies are near the target, engage them. Gives fleet behaviour.
-- orderFlyTowards(x, y): Fly toward a target position and attack enemies when they come too close.
-- orderFlyTowardsBlind(x, y): Fly toward a target position and ignore everything else.
-- orderAttack(target): Attack a specific target.
-- orderDock(target): Dock with a target. Can be used to make computer-controlled ships dock with stations.
