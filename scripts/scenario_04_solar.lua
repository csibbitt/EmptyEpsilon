-- Name: Solar System
-- Description: Our Solar System, scaled to fit and look nice.
-- Type: Development
-- Author: Mike Mallett <mike@nerdcore.net>

--- Scenario
-- @script scenario_04_solar

require("utils.lua")
require("jump_carriers.lua")

function solScale(meters)
   -- Convert meter value to integer units (0.001U, 1mU) for use in Planet() functions
   -- Tried conversion factor of 1 Sun Radius = 696,000,000m = 200 U = 200,000 integer units
   -- Trying conversion factor of 1 Earth Radius = 6,378,137m = 50 U = 50,000 mU integer units = 2.5 Sectors
   --return (meters * (200 / 696000))
   --return (meters * (50000 / 6378137))
   -- Adjusting as needed
   return (meters * (100000 / 6378137))
end
function solScaleAU(au)
   -- 1 AU: 149.5979 Gm
   return solScale(au * 149598023000)
end
function dayToSec(d)
   -- FIXME: I mistook 1 game update for 1 second; So x40 for roughshot workaround
   return (d * 86400 * 40)
end
function yearToSec(y)
   return dayToSec(y * 365.256363004)
end

function init()
   -- Measures as of 2021-12-18
   --+---------+------------+-------------+----------------+--------------+
   --|   Name  |  Distance  |   Radius    |  Orbit Period  | Axial Period |
   --+---------+------------+-------------+----------------+--------------+
   --|   Sun   |     N/A    |   696 Mm    |       N/A      |    25.05 D   |
   --+---------+------------+-------------+----------------+--------------+
   --| Mercury | 0.387098AU |   2.44 Mm   |   87.9691 D    |     176 D    |
   --+---------+------------+-------------+----------------+--------------+
   --|  Venus  | 0.723332AU |  6.0518 Mm  |   224.701 D    |   -116.75 D  |
   --+---------+------------+-------------+----------------+--------------+
   --|  Earth  |    1.0 AU  | 6.378137 Mm | 1Y=31557945.6s |  1D = 86400s |
   --+---------+------------+-------------+----------------+--------------+
   --|  >Luna  | 384.399 Mm |  1.7381 Mm  |     ~28 D      |     ~28 D    |
   --+---------+------------+-------------+----------------+--------------+
   --|  Mars   | 1.523679AU |  3.3962 Mm  |   686.980 D    | 1.02749125 D |
   --+---------+------------+-------------+----------------+--------------+
   --| >Phobos |  9.376 Mm  |  11.2667 km |  0.31891023 D  | 0.31891023 D | 
   --+---------+------------+-------------+----------------+--------------+
   --| >Deimos | 23.4632 Mm |    6.2 km   |    1.263 D     |   1.263 D    |
   --+---------+------------+-------------+----------------+--------------+
   --|  Vesta  | 2.36179 AU |  262.70 km  |     3.63 y     |    5.342 h   |
   --+---------+------------+-------------+----------------+--------------+
   --|  Ceres  |   2.77 AU  |  469.73 km  |     1680 D     |  9.074170 h  |
   --+---------+------------+-------------+----------------+--------------+
   --| Jupiter |  5.2044 AU |  71.492 Mm  |    11.862 y    |    9.9258 h  |
   --+---------+------------+-------------+----------------+--------------+
   --|   >Io   | 421.700 Mm |  1.8216 Mm  |  152853.5047s =| 1.769137786 D|
   --+---------+------------+-------------+----------------+--------------+
   --| >Europa | 670.900 Mm |  1.5608 Mm  |   3.551181 D   |  3.551181 D  |
   --+---------+------------+-------------+----------------+--------------+
   --|>Ganymede| 1.070400Gm |  2.6341 Mm  |  7.15455296 D  | 7.15455296 D |
   --+---------+------------+-------------+----------------+--------------+
   --|>Callisto| 1.882700Gm |  2.4103 Mm  |  16.6890184 D  | 16.6890184 D |
   --+---------+------------+-------------+----------------+--------------+
   --|  Saturn |  9.5826 AU |  60.268 Mm  |    29.4571 Y   |   10.5433 h  |
   --+---------+------------+-------------+----------------+--------------+
   --| >Mimas  | 185.539 Mm |   198.2 km  |  0.942421959 D | 0.942421959 D|
   --+---------+------------+-------------+----------------+--------------+
   --|>Encelad.| 237.948 Mm |   252.1 km  |   1.370218 D   |  1.370218 D  |
   --+---------+------------+-------------+----------------+--------------+
   --| >Tethys | 294.619 Mm |   531.1 km  |   1.887802 D   |  1.887802 D  |
   --+---------+------------+-------------+----------------+--------------+
   --| >Dione  | 377.396 Mm |   561.4 km  |   2.736915 D   |  2.736915 D  |
   --+---------+------------+-------------+----------------+--------------+
   --|  >Rhea  | 527.108 Mm |   763.8 km  |   4.518212 D   |  4.518212 D  |
   --+---------+------------+-------------+----------------+--------------+
   --| >Titan  | 1.221870Gm |  2.57473 Mm |    15.945 D    |    15.945 D  |
   --+---------+------------+-------------+----------------+--------------+
   --|  Uranus | 19.19126 AU|  25.559 Mm  |    84.0205 Y   |  -0.71832 D  |
   --+---------+------------+-------------+----------------+--------------+
   --| Neptune |  30.07 AU  |  24.622 Mm  |     164.8 Y    |   0.67125 D  |
   --+---------+------------+-------------+----------------+--------------+

   -- ----- NOTE ----- --
   -- Starting with the values in the table above,
   -- I tried a lot of values for various radii and distances and orbital periods.
   -- The settings below differ from the values above.
   -- Deal with it.

   -- TODO: Randomize orbital positions, or better yet start the mission
   -- with all celestial bodies in their correct (calculated) positions
   -- For now, all bodies in a straight line (0 Y-axis)

   -- TODO: Decide which bodies should have :setPlanetAtmosphereTexture("planets/atmosphere.png")
   
   -- Place the Sun approximately 1 AU to the Left, so that we can start near Earth.
   local  sun = Planet():setCallSign("Sol"):setPosition(0-solScaleAU(1), 0):setPlanetRadius(solScale(696000000)):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(0.8, 0.6, 0.1)
   local sun_x, sun_y = sun:getPosition()

   local mercury = Planet():setCallSign("Mercury"):setPosition(sun_x+solScaleAU(0.387098), 0):setPlanetRadius(solScale(2440000)):setPlanetSurfaceTexture("planets/Mercury/mercury-1.png"):setPlanetAtmosphereColor(0.2, 0.1, 0.0):setAxialRotationTime(dayToSec(176)):setOrbit(sun, dayToSec(87.9691))

   local venus = Planet():setCallSign("Venus"):setPosition(sun_x+solScaleAU(0.723332), 0):setPlanetRadius(solScale(6051800)):setPlanetSurfaceTexture("planets/Venus/venus-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.64, 0.32, 0.11):setAxialRotationTime(0-dayToSec(116.75)):setOrbit(sun, dayToSec(87.9691))

   -- FIXME: Player ship shouldn't start ON Earth, but needs recalculation of positions
   -- KLUDGE: Ensure player ship starts Left of Earth by displacing Earth by half distance to Moon (+1)
   local earth = Planet():setCallSign("Earth"):setPosition(sun_x+solScaleAU(1)+(solScale(384399000)/16)+1, 0):setPlanetRadius(solScale(6378137)):setPlanetSurfaceTexture("planets/Earth/earth-1.png"):setPlanetCloudTexture("planets/clouds-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 0.5):setAxialRotationTime(dayToSec(1)):setOrbit(sun, yearToSec(1))

   local earth_x, earth_y = earth:getPosition()
   -- The lunar distance value was chosen from exprimental testing, ensuring Moon appears at LEO.
   -- FIXME: The Moon is tidally locked, but not facing the correct direction
   local moon = Planet():setCallSign("Luna"):setPosition(earth_x-(solScale(384399000)/8), 0):setPlanetRadius(solScale(1738100)):setPlanetSurfaceTexture("planets/Moon/luna-1.png"):setPlanetAtmosphereColor(0.1, 0.1, 0.1):setAxialRotationTime(dayToSec(28)):setOrbit(earth, dayToSec(28))

   -- IDEA: Phobos and Deimos could be asteroids? They are so small...
   local mars_distance = sun_x+solScaleAU(1.523679)
   local mars = Planet():setCallSign("Mars"):setPosition(mars_distance, 0):setPlanetRadius(solScale(3396200)):setPlanetSurfaceTexture("planets/Mars/mars-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.6, 0.4, 0.3):setAxialRotationTime(dayToSec(1.02749125)):setOrbit(sun, dayToSec(686.980))
   local phobos = Planet():setCallSign("Phobos"):setPosition(mars_distance-solScale(9376000), 0):setPlanetRadius(1126.67):setPlanetSurfaceTexture("planets/Mars/phobos-1.png"):setPlanetAtmosphereColor(0.12, 0.1, 0.1):setAxialRotationTime(dayToSec(0.31891023)):setOrbit(mars, dayToSec(0.31891023))
   local deimos = Planet():setCallSign("Deimos"):setPosition(mars_distance-solScale(23463200), 0):setPlanetRadius(620):setPlanetSurfaceTexture("planets/Mars/deimos-1.png"):setPlanetAtmosphereColor(0.12, 0.1, 0.1):setAxialRotationTime(dayToSec(1.263)):setOrbit(mars, dayToSec(1.263))

   -- TODO: Add asteroids to the Belt
   local vesta = Planet():setCallSign("4 Vesta"):setPosition(sun_x+solScaleAU(2.36179), 0):setPlanetRadius(solScale(262700)):setPlanetSurfaceTexture("planets/Belt/vesta-1.png"):setPlanetAtmosphereColor(0.1, 0.1, 0.1):setAxialRotationTime(dayToSec(0.222583)):setOrbit(sun, yearToSec(3.63))
   local ceres = Planet():setCallSign("Ceres"):setPosition(sun_x+solScaleAU(2.77), 0):setPlanetRadius(solScale(469730)):setPlanetSurfaceTexture("planets/Belt/ceres-1.png"):setPlanetAtmosphereColor(0.1, 0.1, 0.1):setAxialRotationTime(dayToSec(0.3780904166)):setOrbit(sun, dayToSec(1680))

   local jupiter_distance = sun_x+solScaleAU(5.2044)
   local jupiter = Planet():setCallSign("Jupiter"):setPosition(jupiter_distance, 0):setPlanetRadius(solScale(71492000)):setPlanetSurfaceTexture("planets/Jupiter/jupiter-1.png"):setPlanetAtmosphereColor(0.3, 0.1, 0.01):setAxialRotationTime(yearToSec(11.862)):setOrbit(sun, yearToSec(11.862))
   -- NOTE: These moons may be too close to each other at their closest
   -- These values were chosen because Jupiter begins to glitch out beyond Callisto
   local iomoon = Planet():setCallSign("Io"):setPosition(jupiter_distance-(solScale(421700000)/4), 0):setPlanetRadius(solScale(1821600)):setPlanetSurfaceTexture("planets/Jupiter/io-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.5, 0.4, 0.1):setAxialRotationTime(dayToSec(1.769137786)):setOrbit(jupiter, dayToSec(1.769137786))
   local europa = Planet():setCallSign("Europa"):setPosition(jupiter_distance-(solScale(670900000)/5), 0):setPlanetRadius(solScale(1560800)):setPlanetSurfaceTexture("planets/Jupiter/europa-1.png"):setPlanetAtmosphereColor(0.3, 0.2, 0.1):setAxialRotationTime(dayToSec(3.551181)):setOrbit(jupiter, dayToSec(3.551181))
   local ganymede = Planet():setCallSign("Ganymede"):setPosition(jupiter_distance-(solScale(1070400000)/6), 0):setPlanetRadius(solScale(2634100)):setPlanetSurfaceTexture("planets/Jupiter/ganymede-1.png"):setPlanetAtmosphereColor(0.1, 0.1, 0.1):setAxialRotationTime(dayToSec(7.15455296)):setOrbit(jupiter, dayToSec(7.15455296))
   local callisto = Planet():setCallSign("Callisto"):setPosition(jupiter_distance-(solScale(1882700000)/7), 0):setPlanetRadius(solScale(2410300)):setPlanetSurfaceTexture("planets/Jupiter/callisto-1.png"):setPlanetAtmosphereColor(0.075, 0.075, 0.075):setAxialRotationTime(dayToSec(16.6890184)):setOrbit(jupiter, dayToSec(16.6890184))

   -- TODO: How To Rings ???
   local saturn_distance = sun_x+solScaleAU(9.5826)
   local saturn = Planet():setCallSign("Saturn"):setPosition(saturn_distance, 0):setPlanetRadius(solScale(71492000)):setPlanetSurfaceTexture("planets/Saturn/saturn-1.png"):setPlanetAtmosphereColor(0.5, 0.3, 0.01):setAxialRotationTime(dayToSec(0.43930416)):setOrbit(sun, yearToSec(29.4571))
   -- NOTE: These orbital values were chosen for no good reason, I just like them.
   -- Atmo colours to taste.
   local mimas = Planet():setCallSign("Mimas"):setPosition(saturn_distance-(solScale(185539000)/2), 0):setPlanetRadius(solScale(198200)):setPlanetSurfaceTexture("planets/Saturn/mimas-1.png"):setPlanetAtmosphereColor(0.2, 0.2, 0.12):setAxialRotationTime(dayToSec(0.942421959)):setOrbit(saturn, dayToSec(0.942421959))
   local enceladus = Planet():setCallSign("Enceladus"):setPosition(saturn_distance-(solScale(237948000)/2), 0):setPlanetRadius(solScale(252100)):setPlanetSurfaceTexture("planets/Saturn/enceladus-1.png"):setPlanetAtmosphereColor(0.3, 0.4, 0.5):setAxialRotationTime(dayToSec(1.370218)):setOrbit(saturn, dayToSec(1.370218))
   local tethys = Planet():setCallSign("Tethys"):setPosition(saturn_distance-(solScale(294619000)/2), 0):setPlanetRadius(solScale(531100)):setPlanetSurfaceTexture("planets/Saturn/tethys-1.png"):setPlanetAtmosphereColor(0.12, 0.12, 0.1):setAxialRotationTime(dayToSec(1.887802)):setOrbit(saturn, dayToSec(1.887802))
   local dione = Planet():setCallSign("Dione"):setPosition(saturn_distance-(solScale(377396000)/2), 0):setPlanetRadius(solScale(561400)):setPlanetSurfaceTexture("planets/Saturn/dione-1.png"):setPlanetAtmosphereColor(0.1, 0.1, 0.09):setAxialRotationTime(dayToSec(2.736915)):setOrbit(saturn, dayToSec(2.736915))
   local rhea = Planet():setCallSign("Rhea"):setPosition(saturn_distance-(solScale(527108000)/2.2), 0):setPlanetRadius(solScale(763800)):setPlanetSurfaceTexture("planets/Saturn/rhea-1.png"):setPlanetAtmosphereColor(0.1, 0.08, 0.0):setAxialRotationTime(dayToSec(4.518212)):setOrbit(saturn, dayToSec(4.518212))
   local titan = Planet():setCallSign("Titan"):setPosition(saturn_distance-(solScale(1221870000)/4), 0):setPlanetRadius(solScale(2574730)):setPlanetSurfaceTexture("planets/Saturn/titan-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.6, 0.5, 0.2):setAxialRotationTime(dayToSec(15.945)):setOrbit(saturn, dayToSec(15.945))

   local uranus = Planet():setCallSign("Uranus"):setPosition(sun_x+solScaleAU(19.19126), 0):setPlanetRadius(solScale(25559000)):setPlanetSurfaceTexture("planets/Uranus/uranus-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 0.3):setAxialRotationTime(0-dayToSec(0.71832)):setOrbit(sun, yearToSec(84.0205))

   -- Atmosphere colour chosen from texture map
   local neptune = Planet():setCallSign("Neptune"):setPosition(sun_x+solScaleAU(30.07), 0):setPlanetRadius(solScale(24622000)):setPlanetSurfaceTexture("planets/Neptune/neptune-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.376, 0.529, 0.925):setAxialRotationTime(dayToSec(0.67125)):setOrbit(sun, yearToSec(164.8))

   jumpConfig = {
      ["JC-2"] = {
         destinations = {
         ["Home"] = { 2000, 2000 }  -- NOTE: The first jump needs to start near the first listed destination
         }
      }
   }

   destination_bodies = {
      sun, mercury, venus, earth, moon, mars, phobos, deimos, vesta, ceres, jupiter,
      iomoon, europa, ganymede, callisto, saturn, mimas, enceladus,
      tethys, dione, rhea, titan, uranus, neptune
   }

   -- destination_bodies = {
   --    sun, mercury, venus, earth, moon, mars, jupiter,
   --    saturn, uranus, neptune
   -- }

   -- Initial player ship helps with my debug workflow
   player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(sectorToXY("F5")):setRotation(315)
   player:setWarpDrive(true)
   player:setWarpSpeed(10000)

   jc2 = CpuShip():setFaction("Human Navy"):setTemplate("Jump Carrier"):setCallSign("JC-2"):setScanned(true):setPosition(300, 300):orderIdle()
   jc2:setJumpDriveRange(5000, 20000 * 200000)
   jc2:setCommsFunction(jcComms)

   -- ***** This would be better just being in "init" and allow a function in the config that gets called before the co-ords are retrieved
   for i = 1, #destination_bodies do
      p = destination_bodies[i]
      --player:addToShipLog(p:getCallSign(),"Yellow")
      x, y =  p:getPosition()
      x = x + p:getPlanetRadius() + 5 * 20000
      jumpConfig["JC-2"].destinations[p:getCallSign()] = {x, y}
   end

end

function update(delta)
   updateJumpCarrierState(jc2);

   -- ***** This would be better just being in "init" and allow a function in the config that gets called before the co-ords are retrieved
   -- for i = 1, #destination_bodies do
   --    p = destination_bodies[i]
   --    --player:addToShipLog(p:getCallSign(),"Yellow")
   --    x, y =  p:getPosition()
   --    x = x + p:getPlanetRadius() + 5 * 20000
   --    jumpConfig["JC-2"].destinations[p:getCallSign()] = {x, y}
   -- end
end

-- Set callback function
onNewPlayerShip(
    function(ship)
        -- Decide what you do with new ships:
        print(ship, ship.typeName, ship:getTypeName(), ship:getCallSign())
        -- ship:destroy()
        ship:setWarpDrive(true)
        ship:setWarpSpeed(5000)
    end
)
