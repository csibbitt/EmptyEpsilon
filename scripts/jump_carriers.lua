-- Script to control jump carrier that you can dock with to take you anywhere
-- on the map. Based on the idea from "Birth of the Atlantis"
--
-- Usage:
--  1. require("jump_carriers.lua")
--
--  2. Construct a table like this one,
--     indexed by callsign of the carriers you want to create.
--
--    jumpConfig = {
--      ["JC-2"] = {
--        destinations = {
--          ["Home"] = { 2000, 2000 },  -- NOTE: The first jump should start near the first listed destination (for "fly back" if you undock before jump)
--          ["Zulu Nine-Niner"] = { sectorToXY("Z99") },
--          ["Alpha Sector"] =  { sectorToXY("A0") }
--        }
--        pre_jump_hook = function() ... end  -- OPTIONAL function to be called before jump (allows you to set real-time destination coordinates)
--      }
--    }
--
--  3. Add something like this to your code to create your jump carrier.
--     Ensure the Carrier spawns near the first destination in the list,
--     or at least travels there before you call updateJumpCarrierState
--
--    jc2 = CpuShip():setFaction("Human Navy"):setTemplate("Jump Carrier"):setCallSign("JC-2"):setScanned(true):setPosition(300, 300):orderIdle()
--    jc2:setJumpDriveRange(5000, 50000000)
--    jc2:setCommsFunction(jcComms)
--
--  4. Add a line like this one in your update() code for each of the carriers
--
--    updateJumpCarrierState(jc2);
--
-- TODO
-- ----
-- Optional Comms message overrides in the config
-- Jump to waypoints
-- Localization

function handleJumpCarrier(jc, dest_x, dest_y)
  local config = jumpConfig[jc:getCallSign()]

  if config.countdown == nil then
    config.countdown_time = math.floor(getScenarioTime())
    config.countdown = 5
  else
    curtime = math.floor(getScenarioTime())
    if curtime - config.countdown_time > 0 then
      config.countdown = config.countdown - 1
      config.countdown_time = curtime
    else
      return
    end
  end

  if config.countdown > 0 then
    config.user:addToShipLog(config.countdown .."...".. getScenarioTime(), "White")
  else
    config.user:addToShipLog("JUMP!", "Red")
    jc:setPosition(dest_x, dest_y)
    config.current_destination = nil
    config.countdown = nil
  end
end


function jcComms(comms_source, comms_target)
  local config = jumpConfig[comms_target:getCallSign()]
  if not comms_source:isDocked(comms_target) then
    local destinations = ""
    for dest, c in pairs(config.destinations) do --FIX?: Order is not guaranteed
      destinations = destinations ..dest .."\n"
    end
    setCommsMessage("Please dock with us if you'd like to jump to any of our destinations: \n\n"..destinations)
    return
  end
  if config.jumping_state ~= nil then
    setCommsMessage("Please complete the current jump before calling back")
    return
  end
  setCommsMessage("Where to?")
  for dest, c in pairs(config.destinations) do --FIX?: Order is not guaranteed
    addCommsReply(dest, function()
        config.current_destination = dest
        config.user = comms_source
        setCommsMessage("Roger that, proceeding to "..dest)
      end
    )
  end
end


function updateJumpCarrierState(jc)
  local config = jumpConfig[jc:getCallSign()]

  -- Do nothing if we haven't set a destination via comms or if no longer docked
  if config.current_destination == nil then return end

  -- Abort current jump if undocked
  if not config.user:isDocked(jc) then config.current_destination = nil; return end

  -- Player is docked and ready to jump

  -- Optional hook to twiddle config before seting jump params (eg. realtime destination updates for orbiting bodies)
  if config.pre_jump_hook ~= nil then config.pre_jump_hook() end

  local dest = config.destinations[config.current_destination]

  handleJumpCarrier(jc, dest[1], dest[2])
end