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
-- Count-down for setPosition?
-- Optional Comms message overrides in the config
-- Jump to waypoints
-- Localization

function handleJumpCarrier(jc, source_x, source_y, dest_x, dest_y)
  local config = jumpConfig[jc:getCallSign()]
  if config.jumping_state == nil then
    if config.user:isDocked(jc) then
      -- jc:orderFlyTowardsBlind(dest_x, dest_y)  -- setPosition is more stable for very long jumps
      jc:setPosition(dest_x, dest_y)
      config.jumping_state = "wait_for_jump"
    end
  elseif config.jumping_state == "wait_for_jump" then
    if distance(jc, dest_x, dest_y) < 10000 then
      -- We check for the player 1 tick later, as it can take a game tick for the player position to update as well.
      config.jumping_state = "check_for_player"
    end
  elseif config.jumping_state == "check_for_player" then
    config.jumping_state = nil
    config.current_location = config.current_destination
    config.current_destination = nil
    if distance(config.user, dest_x, dest_y) < 10000 then
      sendCommsMessage("Welcome to "..getSectorName(dest_x, dest_y))
      return true
    else
      -- fly back if the player didn't land with us (undocked before jump)
      -- jc:orderFlyTowardsBlind(source_x, source_y)   -- setPosition is more stable for very long jumps
      jc:setPosition(source_x, source_y)
      jc:sendCommsMessage(
          config.user,
          _("JumpCarrier-incCall", "Looks like the docking couplers detached prematurely.\n\nThis happens sometimes. I am on my way so we can try again.")
      )
    end
  end
  return false
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

  -- Do nothing if we haven't set a destination via comms
  if config.current_destination == nil then return end

  -- Default location if the first destination in the list (*****BUG lua doesn't guarantee order - this can be set manually if it turns out to be a problem)
  if config.current_location == nil then config.current_location,_ = next(config.destinations) end

  -- Optional hook to twiddle config before seting jump params (eg. realtime destination updates for orbiting bodies)
  if config.pre_jump_hook ~= nil then config.pre_jump_hook() end

  local src = config.destinations[config.current_location]
  local dest = config.destinations[config.current_destination]

  handleJumpCarrier(jc, src[1], src[2], dest[1], dest[2])
end