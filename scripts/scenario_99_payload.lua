-- Name: PushPayload
-- Description: Keep pushing the cart!
---
-- Type: Development

--- Scenario
-- @script scenario_99_payload
-- Setting[Difficulty]: Configures the difficulty in the scenario. Default is Easy
-- Difficulty[Easy|Default]: Minor enemy resistance and easier missions.
-- Difficulty[Medium]: More robust resistance with more risk (takes longer).
-- Difficulty[Hard]: Significant enemy resistance.

require("utils.lua")

Debug = false

---@diagnostic disable-next-line: lowercase-global
function init()

  if Debug then
    FieldSize = 20000
  else
    FieldSize = 120000
  end
  -- Create the faction stations
  FactionStation = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setPosition(0, 0)
  local kx, ky
  if Debug then
    kx = FieldSize
    ky = FieldSize
  else
    kx, ky = RandPositionInRadius(0, 0, FieldSize, FieldSize, 0, 360)
  end
  KraylorStation = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setPosition(kx, ky)

  -- Calculate midpoint between stations
  local fsX, fsY = FactionStation:getPosition()
  local esX, esY = KraylorStation:getPosition()
  local midX = math.floor((fsX + esX) / 2)
  local midY = math.floor((fsY + esY) / 2)

  -- Create the Payload ship
  PayloadDistanceThreshold = 2000
  PayloadShip = CpuShip():setTemplate("Adv. Gunship"):setFaction("Independent"):setPosition(midX, midY):setCallSign("Payload"):setImpulseMaxSpeed(625) -- :setImpulseMaxSpeed(1000):setRotationMaxSpeed(20):setAcceleration(40)
  PayloadShip.target = nil
  PayloadShip.scanACKd = false
  PayloadShip.Waypoints = {}
  PayloadShip.controlledBy = nil  -- Initialize controlledBy property

  -- Initialize wave variables
  WaveSize = 0
  WaveInterval = 300 --**seconds (usually 120)
  WaveTimer = WaveInterval
  WavePayloadLastControlledBy = nil
  KraylorShips = {}
  HumanShips = {}

  -- Initialize closest enemy tracking
  ClosestEnemies = {
    Kraylor = { ship = nil, distance = math.huge },
    HumanNavy = { ship = nil, distance = math.huge }
  }
  ClosestEnemyInterval = 5 -- seconds
  ClosestEnemyTimer = ClosestEnemyInterval


  -- Spawn the first wave immediately
  SpawnWave()

  -- Spawn Stations
  SpawnObjects(StationFactory("HVLI", 8), 1,    midX, midY, FieldSize / 2, 15000)
  SpawnObjects(StationFactory("Homing", 16), 1, midX, midY, FieldSize / 2, 15000)
  SpawnObjects(StationFactory("EMP", 24), 1,    midX, midY, FieldSize / 2, 15000)
  SpawnObjects(StationFactory("Mine", 32), 1,   midX, midY, FieldSize / 2, 15000)
  SpawnObjects(StationFactory("Nuke", 40), 1,   midX, midY, FieldSize / 2, 15000)

  -- irandom(midX - FieldSize / 2, midX + FieldSize / 2)
  -- irandom(midY - FieldSize / 2, midY + FieldSize / 2)

  -- Spawn Nebulas
  local nebulaNum = 10
  if Debug then
    nebulaNum = 0
  end
  for i = 1, nebulaNum do
    SpawnObjects(Nebula, 10, irandom(midX - FieldSize / 2, midX + FieldSize / 2), irandom(midY - FieldSize / 2, midY + FieldSize/ 2), 20000, 0)
  end

  -- Spawn Asteroids
  local asteroidNum = 20
  if Debug then
    asteroidNum = 0
  end
  for i = 1, asteroidNum do
    SpawnObjects(Asteroid, 150, irandom(midX - FieldSize / 2, midX + FieldSize / 2), irandom(midY - FieldSize / 2, midY + FieldSize / 2), 15000, 0)
  end

  -- Create the player ship
  allowNewPlayerShips(false)
  Player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos M3P"):setCallSign("Player"):setPosition(fsX + 1000, fsY + 1000)
  Player:setJumpDrive(false)
  Player:setWarpDrive(true)
  Player:setRotation(45):commandTargetRotation(45)
  Player:setWeaponStorageMax("Homing", 4)
  Player:setWeaponStorageMax("Nuke", 4)
  Player:setWeaponStorageMax("Mine", 4)
  Player:setWeaponStorageMax("EMP", 4)
  Player:setWeaponStorageMax("HVLI", 4)
  Player:setWeaponStorage("Homing", 4)
  Player:setWeaponStorage("Nuke", 0)
  Player:setWeaponStorage("Mine", 0)
  Player:setWeaponStorage("EMP", 0)
  Player:setWeaponStorage("HVLI", 4)
  Player:setLongRangeRadarRange(20000)
end

function CheckWinCondition()
  if PayloadShip:isDocked(FactionStation) then
    victory("Kraylor")
  elseif PayloadShip:isDocked(KraylorStation) then
    victory("Human Navy")
  end
  if not (PayloadShip:isValid()
    and FactionStation:isValid()
    and KraylorStation:isValid())
  then
    victory("Kraylor")
  end
end

-- Function to check player proximity to Payload
function CheckProximity()
  local oldTarget = PayloadShip.target
  local inControl, ourCount, oppositionCount = CheckProximityCounts(PayloadShip, "Human Navy", "Kraylor")

  -- Newly scanned
  if PayloadShip:isScannedBy(Player) and PayloadShip.scanACKd == false then
    if distance(PayloadShip, Player) > PayloadDistanceThreshold then
      Player:addToShipLog(_("You need to be closer to the Payload to guide it."), "red")
      PayloadShip:setScannedByFaction("Human Navy", false)
    elseif inControl == 1 then
      PayloadShip.scanACKd = true
    else
      Player:addToShipLog(string.format(_("Must be clear of enemies before the Payload can move. The enemy has %d ships nearby."), oppositionCount), "red")
    end
  end

  if inControl == -1 or distance(PayloadShip, Player) > PayloadDistanceThreshold then
    PayloadShip.scanACKd = false
    PayloadShip:setScannedByFaction("Human Navy", false)
  end

  -- Adjust target
  if inControl == 0 then
    PayloadShip.target = nil
    PayloadShip.controlledBy = nil
  elseif inControl == -1 then
    PayloadShip.target = FactionStation
    PayloadShip.controlledBy = "Kraylor"
  elseif inControl == 1 and PayloadShip.scanACKd then
    PayloadShip.target = KraylorStation
    PayloadShip.controlledBy = "Human Navy"
  end

  -- Target has changed
  if PayloadShip.target ~= nil and PayloadShip.target ~= oldTarget then
    PayloadShip.Waypoints = GenerateWaypoints(PayloadShip.target)
    if PayloadShip.target == FactionStation then
      Player:addToShipLog(_("DANGER, The payload is moving towards the Human Navy station!"), "red")
    elseif PayloadShip.target == KraylorStation then
      Player:addToShipLog(_("Payload is being delivered to the Kraylor station."), "green")
    end
  end
end

-- Function to check proximity counts
function CheckProximityCounts(target, faction1, faction2)
  local count1 = 0
  local count2 = 0

  local payloadX, payloadY = target:getPosition()

  local allShips = getObjectsInRadius(payloadX, payloadY, PayloadDistanceThreshold)

  for _, ship in ipairs(allShips) do
    if ship.typeName ~= "CpuShip" and ship.typeName ~= "PlayerSpaceship" then
      goto continue
    end
    if ship:isValid() and ship:getFaction() == faction1 then
      count1 = count1 + 1
    elseif ship:isValid() and ship:getFaction() == faction2 then
      count2 = count2 + 1
    end
    ::continue::
  end

  if count1 > 0 and count2 == 0 then
    return 1, count1, count2
  elseif count2 > 0 and count1 == 0 then
    return -1, count1, count2
  else
    return 0, count1, count2
  end
end

function StationFactory(weaponType, price)
  local ss = SpaceStation():setTemplate("Medium Station")
  CommsFactory(ss, weaponType, price)
  return ss
end

function CommsFactory(target, weaponType, price)

  function StationCommsHandler(comms_source, comms_target)
    if not Player:isDocked(comms_target) then
      setCommsMessage(string.format(_("We sell %s for %d"), weaponType, price))
      return
    end

    setCommsMessage(_("Wanna buy?"))

    addCommsReply(string.format(_("Buy full complement of %s (%d rep)"), weaponType, price), function()
      if Player:getReputationPoints() >= price then
        Player:setReputationPoints(Player:getReputationPoints() - price)
        Player:setWeaponStorage(weaponType, Player:getWeaponStorageMax(weaponType))
        setCommsMessage(string.format(_("You have purchased a full complement of %s."), weaponType))
      else
        setCommsMessage("You do not have enough reputation points.")
      end
    end)
  end

  target:setCommsFunction(StationCommsHandler)
  return target
end

function RandPositionInRadius(x, y, maxdist, mindist, anglemin, anglemax)
  local angle = math.rad(irandom(anglemin, anglemax))
  local distance = irandom(mindist, maxdist)
  local offsetX = distance * math.cos(angle)
  local offsetY = distance * math.sin(angle)
  return x + offsetX, y + offsetY
end

-- Function to spawn any number of a spaceObject distributed around a given position
function SpawnObjects(object, num, x, y, maxdist, mindist)
  mindist = mindist or 0
  for i = 1, num do
    local rx, ry = RandPositionInRadius(x, y, maxdist, mindist, 0, 360)
    if type(object) == "function" then
      object():setPosition(rx, ry)
    else
      object:setPosition(rx, ry)
    end
  end
end

-- Function to spawn waves
function SpawnWave()
  local maxWaveSize = 6
  local perpendicularOffset = 1000
  local kraylorCount = #KraylorShips
  local humanCount = #HumanShips

  WaveSize = math.min(WaveSize + 1, maxWaveSize)
  local queenNumber = irandom(1, WaveSize)

  local spawnKraylorCount = WaveSize
  local spawnHumanCount = WaveSize

  if #KraylorShips > #HumanShips then
    spawnKraylorCount = WaveSize - (kraylorCount - humanCount)
  end

  if #HumanShips > #KraylorShips then
    spawnHumanCount = WaveSize - (humanCount - kraylorCount)
  end

  for i = 1, WaveSize do
    local angle = math.rad(PayloadShip:getRotation() + 90)
    local fsX, fsY = FactionStation:getPosition()
    local esX, esY = KraylorStation:getPosition()
  
    local enemyX = esX + math.cos(angle) * perpendicularOffset * i
    local enemyY = esY + math.sin(angle) * perpendicularOffset * i
    local humanX = fsX - math.cos(angle) * perpendicularOffset * i
    local humanY = fsY - math.sin(angle) * perpendicularOffset * i

    -- Alternate spawning on either side of the station
    if i % 2 == 0 then
      enemyX = esX - math.cos(angle) * perpendicularOffset * i
      enemyY = esY - math.sin(angle) * perpendicularOffset * i
      humanX = fsX + math.cos(angle) * perpendicularOffset * i
      humanY = fsY + math.sin(angle) * perpendicularOffset * i
    end

    if spawnKraylorCount > 0 then
      spawnKraylorCount = spawnKraylorCount - 1
      local enemyTemplate = "Adder MK5"
      if i == queenNumber and WaveSize > 1 then
        enemyTemplate = "Phobos M3P"
      end
      local enemy = CpuShip():setTemplate(enemyTemplate):setFaction("Kraylor"):setPosition(enemyX, enemyY)
      enemy:setWarpDrive(true)
      enemy:setWeaponStorage("Homing", 4)
      enemy:setWeaponStorage("Nuke", 0)
      enemy:setWeaponStorage("Mine", 0)
      enemy:setWeaponStorage("EMP", 0)
      enemy:setWeaponStorage("HVLI", 4)
      enemy:onTakingDamage(OnDamaged)
      table.insert(KraylorShips, enemy)
    end

    if spawnHumanCount > 0 then
      spawnHumanCount = spawnHumanCount - 1
      local human = CpuShip():setTemplate("Adder MK5"):setFaction("Human Navy"):setPosition(humanX, humanY)
      human:setWarpDrive(true)
      human:setScannedByFaction("Human Navy", true)
      human:onTakingDamage(OnDamaged)
      table.insert(HumanShips, human)
    end
  end
end

-- Function to handle aggro
function OnDamaged(self, instigator)
  -- "Note that the callback function must reference something global, otherwise you get an error like "??[convert<ScriptSimpleCallback>::param] Upvalue 1 of function is not a table..."
  local _ = math.abs(0)
  if instigator and instigator:getFaction() ~= self:getFaction() then
    if not self.lastAggroSwitch or getScenarioTime() - self.lastAggroSwitch > 20 then
      self.aggroTarget = instigator
      self.aggroTimer = getScenarioTime() + 10 -- 10 seconds hysteresis
      self.lastAggroSwitch = getScenarioTime()
      self:orderAttack(instigator)
    end
  end
end

-- Function to calculate the angle between two coordinates
function CalculateAngle(x1, y1, x2, y2)
  local deltaY = y2 - y1
  local deltaX = x2 - x1
  local angle = math.atan(deltaY, deltaX) * (180 / math.pi)
  return angle
end

-- Function to generate waypoints
function GenerateWaypoints(target)
  local waypoints = {}
  local wayPointDistance = FieldSize / 16
  local payloadX, payloadY = PayloadShip:getPosition()
  local targetX, targetY = target:getPosition()
  local distanceBetween = distance(target, PayloadShip)
  local angleBetween = math.floor(CalculateAngle(payloadX, payloadY, targetX, targetY))
  local steps = math.floor(distanceBetween / wayPointDistance)
  local stepX = (targetX - payloadX) / steps
  local stepY = (targetY - payloadY) / steps

  if Debug then
    local points = Player:getWaypointCount()
    for i = points, 1, -1 do
      Player:commandRemoveWaypoint(i)
    end
  end

  for i = 1, steps do
    local waypointX = payloadX + stepX * i + math.random(-wayPointDistance, wayPointDistance) / i
    local waypointY = payloadY + stepY * i + math.random(-wayPointDistance, wayPointDistance) / i

    --RandPositionInRadius(x, y, maxdist, mindist, anglemin, anglemax)
    local startX = payloadX
    local startY = payloadY
    if i > 1 then
      startX = waypoints[i-1].x
      startY = waypoints[i-1].y
      angleBetween = math.floor(CalculateAngle(payloadX, payloadY, targetX, targetY))
    end
    waypointX, waypointY = RandPositionInRadius(startX, startY, wayPointDistance, wayPointDistance, angleBetween - 60, angleBetween + 60)

    table.insert(waypoints, {x = waypointX, y = waypointY})
    if Debug then
      Player:commandAddWaypoint(waypointX, waypointY)
    end
  end

  return waypoints
end

-- Function to handle Payload movement
function HandlePayloadMovement()
  local currentOrder = PayloadShip:getOrder()
  if PayloadShip.target == nil then
    if currentOrder ~= "Idle" then
      PayloadShip:orderIdle()
      Player:addToShipLog(_("Payload has stopped moving."), "red")
    end
  else
    if #PayloadShip.Waypoints > 0 then
      local waypoint = PayloadShip.Waypoints[1]
      if distance(PayloadShip, waypoint.x, waypoint.y) < 200 then
        table.remove(PayloadShip.Waypoints, 1)
      else
        local targetX, targetY = PayloadShip:getOrderTargetLocation()
        if currentOrder ~= "FlyTowards" or (currentOrder == "FlyTowards" and not (waypoint.x == targetX and waypoint.y == targetY)) then
          PayloadShip:orderFlyTowards(waypoint.x, waypoint.y)
        end
      end
    else
      PayloadShip:orderDock(PayloadShip.target)
    end
  end
end

-- Wave timer and spawn control
function HandleNPCWaves(delta)
  WaveTimer = WaveTimer - delta

  -- When capturing payload, give at least 30 seconds before next wave
  if PayloadShip.controlledBy == "Human Navy" and WavePayloadLastControlledBy ~= "Human Navy" then
    WaveTimer = math.max(WaveTimer, 30) -- add randomness
  end
  WavePayloadLastControlledBy = PayloadShip.controlledBy

  -- Max one minute before next wave if no enemies and not pushing payload
  if #KraylorShips == 0 and PayloadShip.controlledBy == nil then
    WaveTimer = math.min(WaveTimer, 60) -- add randomness
  end

  if (PayloadShip.controlledBy ~= nil or #KraylorShips == 0) then
    Player:addCustomInfo("science","wavetimer","Next wave: " .. WaveTimer .. "s")
    Player:addCustomInfo("operations","wavetimer","Next wave: " .. WaveTimer .. "s")
  else
    Player:addCustomInfo("science","wavetimer","")
    Player:addCustomInfo("operations","wavetimer","")
  end

  -- Spawn wave if timer is up and pushing payload or no enemies
  if WaveTimer <= 0 then
    if (PayloadShip.controlledBy ~= nil or #KraylorShips == 0) then
      SpawnWave()
    end
    WaveTimer = WaveInterval
  end
end

-- Function to update closest enemies
function UpdateClosestEnemies()
  -- Reset closest enemies
  ClosestEnemies.Kraylor.ship = nil
  ClosestEnemies.Kraylor.distance = math.huge
  ClosestEnemies.HumanNavy.ship = nil
  ClosestEnemies.HumanNavy.distance = math.huge

  -- Find closest Kraylor ship
  for _, ship in ipairs(KraylorShips) do
    if ship:isValid() then
      local dist = distance(PayloadShip, ship)
      if dist < ClosestEnemies.Kraylor.distance then
        ClosestEnemies.Kraylor.ship = ship
        ClosestEnemies.Kraylor.distance = dist
      end
    end
  end

  -- Find closest Human Navy ship
  for _, ship in ipairs(HumanShips) do
    if ship:isValid() then
      local dist = distance(PayloadShip, ship)
      if dist < ClosestEnemies.HumanNavy.distance then
        ClosestEnemies.HumanNavy.ship = ship
        ClosestEnemies.HumanNavy.distance = dist
      end
    end
  end
end

function SafeOrder(ship, target, order, changeTarget)
  local changeTarget = changeTarget or false
  -- Handle invalid args
  if ship == nil or target == nil or not (ship:isValid() and target:isValid()) then
    return false
  end

  -- Handle case when already executing same order & target
  if (ship:getOrder() == order and ship:getOrderTarget() == target) then
    return true
  end

  if order == "Attack" then
    -- Do not override an existing attack order
    if not (ship:getOrder() == "Attack" and ship:getOrderTarget() ~= target) or changeTarget then
      ship:orderAttack(target)
    end
  elseif order == "Fly in formation" then
    ship:orderFlyFormation(target, irandom(-1400, 1400), irandom(-1400, 1400))
  end

  return true
end

function SafeAttackRandom(ship, shipList, changeTarget)
  local changeTarget = changeTarget or false
  local randomEnemy = shipList[irandom(1, #shipList)]
  return SafeOrder(ship, randomEnemy, "Attack", changeTarget)
end

function CleanShipLists()
  -- Iterate through KraylorShips and HumanShips and remove any nil or invalid entries
  for i = #KraylorShips, 1, -1 do
    if KraylorShips[i] == nil or not KraylorShips[i]:isValid() then
      table.remove(KraylorShips, i)
    end
  end
  for i = #HumanShips, 1, -1 do
    if HumanShips[i] == nil or not HumanShips[i]:isValid() then
      table.remove(HumanShips, i)
    end
  end
end

function IssueOneOrder(ship, ClosestEnemy, oppShipList)
  -- Do nothing if we have captain's orders
  local currentOrder = ship:getOrder()
  if ship:getOrder() ~= "Attack" and ship:getOrder() ~= "Fly in formation" and ship:getOrder() ~= "Idle" then
    return
  end

  -- Clean out stale attack orders
  if ship:getOrder() == "Attack" and (ship:getOrderTarget() == nil or not ship:getOrderTarget():isValid()) then
    ship:orderIdle() --Temporary until overriden below
  end

  -- Have been aggro'd
  if ship.aggroTarget then
    if not SafeOrder(ship, ship.aggroTarget, "Attack") then
      ship.aggroTarget = nil
      if not SafeAttackRandom(ship, oppShipList) then
        SafeOrder(ship, PayloadShip, "Fly in formation")
      end
    end
  -- Close to payload with an enemy close to payload
  elseif distance(ship, PayloadShip) < PayloadDistanceThreshold and distance(ClosestEnemy, PayloadShip) < PayloadDistanceThreshold then
      if not SafeOrder(ship, ClosestEnemy, "Attack") then
        if not SafeAttackRandom(ship, oppShipList) then
          SafeOrder(ship, PayloadShip, "Fly in formation")
        end
      end
  -- Contested payload
  elseif PayloadShip.controlledBy == nil then
    if not SafeAttackRandom(ship, oppShipList) then
      if ship:getFaction() ~= Player:getFaction() and distance(PayloadShip, Player) < 2.5 * PayloadDistanceThreshold then
        SafeOrder(ship, Player, "Attack")
      else
        SafeOrder(ship, PayloadShip, "Fly in formation")
      end
    end
  -- In control of payload
  elseif PayloadShip.controlledBy == ship:getFaction() then
    SafeOrder(ship, PayloadShip, "Fly in formation")
  -- Not in control of payload
  elseif PayloadShip.controlledBy ~= ship:getFaction() then
    if not SafeOrder(ship, ClosestEnemy, "Attack") then
      if not SafeAttackRandom(ship, oppShipList) then
        SafeOrder(ship, PayloadShip, "Fly in formation")
      end
    end
  -- Debug catch-all
  else
    print('Unknown state in IssueOneOrder()')
  end
end

function IssueOrders(shipList, oppShipList, ClosestEnemy)
  for _, ship in ipairs(shipList) do
    IssueOneOrder(ship, ClosestEnemy, oppShipList)
  end
end

-- Function to handle enemy and human ship interactions
function HandleNPCs()
    CleanShipLists()

  ---@diagnostic disable-next-line: undefined-field
  if (ClosestEnemies.HumanNavy.ship == nil or ClosestEnemies.Kraylor.ship == nil) or not (ClosestEnemies.HumanNavy.ship:isValid() and ClosestEnemies.Kraylor.ship:isValid()) then
    UpdateClosestEnemies()
  end

  IssueOrders(KraylorShips, HumanShips, ClosestEnemies.HumanNavy.ship)
  IssueOrders(HumanShips, KraylorShips, ClosestEnemies.Kraylor.ship)
end

-- Main update function
---@diagnostic disable-next-line: lowercase-global
function update(delta)
  CheckWinCondition()
  CheckProximity()
  HandlePayloadMovement()
  HandleNPCWaves(delta)
  HandleNPCs()

  -- Update closest enemies every 5 seconds
  ClosestEnemyTimer = ClosestEnemyTimer - delta
  if ClosestEnemyTimer <= 0 then
    UpdateClosestEnemies()
    ClosestEnemyTimer = ClosestEnemyInterval
  end

end
