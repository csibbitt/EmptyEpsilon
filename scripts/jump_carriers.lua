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
--          ["Home"] = { 2000, 2000 },  -- NOTE: The first jump needs to start near the first listed destination
--          ["Zulu Nine-Niner"] = { sectorToXY("Z99") },
--          ["Alpha Sector"] =  { sectorToXY("A0") },
--        }
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

function handleJumpCarrier(jc, source_x, source_y, dest_x, dest_y)
  local config = jumpConfig[jc:getCallSign()]
  if config.jumping_state == nil then
    if config.user:isDocked(jc) then
      jc:orderFlyTowardsBlind(dest_x, dest_y)
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
      return true
    else
      -- fly back if the player didn't land with us (undocked before jump)
      jc:orderFlyTowardsBlind(source_x, source_y)
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
        setCommsMessage("Roger that, proceeding to "..getSectorName(c[1], c[2]))
      end
    )
  end
end


function updateJumpCarrierState(jc)
  local config = jumpConfig[jc:getCallSign()]
  if config.current_destination == nil then return end
  if config.current_location == nil then config.current_location,_ = next(config.destinations) end
  local src = config.destinations[config.current_location]
  local dest = config.destinations[config.current_destination]
  handleJumpCarrier(jc, src[1], src[2], dest[1], dest[2])
end