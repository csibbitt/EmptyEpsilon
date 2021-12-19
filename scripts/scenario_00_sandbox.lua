-- Name: Sandbox
-- Description: Are you in a sandbox, or the edge of a vast ocean? Are these wave crashing upon you, or merely a trickle of rain?
-- Type: Development

require("utils.lua")

-- Deny warp/jump in a large area
-- TODO allow setting onTakingDamage and onDestruction callbacks that the jammer
--   class has. One idea is replace on Destruction so it's invincible
-- TODO generalize this to other entities and add a density control
function jamArea(startx, starty, endx, endy, faction)
  startx = startx or 0
  starty = starty or 0
  endx = endx or startx
  endy = endy or starty
  local morex = false
  local morey = false
  faction = faction or "Independent"

  for cury = starty, endy, 20000 do
    if cury < endy then morey = true else morey = false end
    for curx = startx, endx, 20000 do
      if curx < endx then morex = true else morex = false end
      -- Core Set
      WarpJammer():setFaction(faction):setPosition(curx + 6865, cury + 6870)
      WarpJammer():setFaction(faction):setPosition(curx + 13120, cury + 6870)
      WarpJammer():setFaction(faction):setPosition(curx + 6870, cury + 13120)
      WarpJammer():setFaction(faction):setPosition(curx + 13120, cury + 13120)
      -- right
      if morex then
        WarpJammer():setFaction(faction):setPosition(curx + 20000, cury + 6870)
        WarpJammer():setFaction(faction):setPosition(curx + 20000, cury + 13120)
      end
      -- bottom
      if morey then
        WarpJammer():setFaction(faction):setPosition(curx + 6870, cury + 20000)
        WarpJammer():setFaction(faction):setPosition(curx + 13120, cury + 20000)
      end
      -- bottom right corner
      if morex and morey then WarpJammer():setFaction(faction):setPosition(curx + 20000, cury + 20000) end
    end
  end
end


function jamArea(startx, starty, endx, endy, faction)
  startx = startx or 0
  starty = starty or 0
  endx = endx or startx
  endy = endy or starty
  local morex = false
  local morey = false
  faction = faction or "Independent"

  for cury = starty, endy, 20000 do
    if cury < endy then morey = true else morey = false end
    for curx = startx, endx, 20000 do
      if curx < endx then morex = true else morex = false end
      -- Core Set
      WarpJammer():setFaction(faction):setPosition(curx + 6865, cury + 6870)
      WarpJammer():setFaction(faction):setPosition(curx + 13120, cury + 6870)
      WarpJammer():setFaction(faction):setPosition(curx + 6870, cury + 13120)
      WarpJammer():setFaction(faction):setPosition(curx + 13120, cury + 13120)
      -- right
      if morex then
        WarpJammer():setFaction(faction):setPosition(curx + 20000, cury + 6870)
        WarpJammer():setFaction(faction):setPosition(curx + 20000, cury + 13120)
      end
      -- bottom
      if morey then
        WarpJammer():setFaction(faction):setPosition(curx + 6870, cury + 20000)
        WarpJammer():setFaction(faction):setPosition(curx + 13120, cury + 20000)
      end
      -- bottom right corner
      if morex and morey then WarpJammer():setFaction(faction):setPosition(curx + 20000, cury + 20000) end
    end
  end
end


function jamSectors(ss, es)
  local sx,sy = sectorToXY(ss)
  es = es or ss
  local ex,ey = sectorToXY(es)
  jamArea(sx, sy, ex, ey)
end


jumping_state = "wait_for_dock"
function handleJumpCarrier(jc, source_x, source_y, dest_x, dest_y, jumping_message)
    if jumping_state == "wait_for_dock" then
        if player:isDocked(jc) then
            jc:orderFlyTowardsBlind(dest_x, dest_y)
            jc:sendCommsMessage(player, jumping_message)
            jumping_state = "wait_for_jump"
        end
    elseif jumping_state == "wait_for_jump" then
        if distance(jc, dest_x, dest_y) < 10000 then
            -- We check for the player 1 tick later, as it can take a game tick for the player position to update as well.
            jumping_state = "check_for_player"
        end
    elseif jumping_state == "check_for_player" then
        jumping_state = "wait_for_dock"
        if distance(player, dest_x, dest_y) < 10000 then
            -- Good, continue.
            jump_finished = true
            return true
        else
            -- fly back
            jc:orderFlyTowardsBlind(source_x, source_y)
            jc:sendCommsMessage(
                player,
                _("JumpCarrier-incCall", [[Looks like the docking couplers detached prematurely.

This happens sometimes. I am on my way so we can try again.]])
            )
        end
    end
    return false
end

jump_finished = false
function update_transport_state()
  if transport_state == "home" then
    source_x, source_y = 2000, 2000
    dest_x, dest_y = sectorToXY("Z99")
    jumping_message = "Heading to Z99"
  elseif transport_state == "Z" then
    source_x, source_y = sectorToXY("Z99")
    dest_x, dest_y = 2000, 2000
    jumping_message = "Heading home"
  end
  
  if player:isDocked(jc2) then
    if not jump_finished then -- Tried to combine these but lua doesn't do short-circuit boolean eval?
      if handleJumpCarrier(jc2, source_x, source_y, dest_x, dest_y, jumping_message) then
        if transport_state == "home" then
          transport_state = "Z"
        elseif transport_state == "Z" then 
          transport_state = "home"
        end
      end
    end
  else
    jump_finished = false
  end
end

-- Test sectorToXY()
function init()
  player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(sectorToXY("F5"))
  player:setLongRangeRadarRange(80000)
  player:setWarpDrive(true)
  player:setWarpSpeed(5000)
  -- jamSectors("F6")
  -- jamSectors("H4", "J9")
  -- jamSectors("yf-9", "A-5")
  -- jamSectors("Z-9", "BB10")
  Planet():setPosition(56194, 26778):setPlanetRadius(5000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 1.0)
  Planet():setPosition(-20595, 60535):setPlanetRadius(40000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 1.0)

  jc2 = CpuShip():setFaction("Human Navy"):setTemplate("Jump Carrier"):setCallSign("JC-2"):setScanned(true):setPosition(1000, 1000):orderIdle()
  jc2:setJumpDriveRange(5000, 1000 * 50000)
  transport_state = "home"

end

-- Main loop
function update(delta)

  --When the player ship is destroyed, call it a victory for the Exuari.
  if not player:isValid() then
    victory("The authors of history")
  end

  update_transport_state();

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
