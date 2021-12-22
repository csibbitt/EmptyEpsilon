--***** TODO
-- Jump to waypoints

-- jumpConfig = {
--   ["JC-2"] = {
--     destinations = {
--       ["Home"] = { 2000, 2000 },
--       ["Zulu Nine-Niner"] = { sectorToXY("Z99") },
--       ["Alpha Sector"] =  { sectorToXY("A0") },
--     },
--     current_location = "Home",
--     current_destination = nil,
--     jumping_state = "wait_for_dock",
--     jump_finished = true,
--   }
-- }


function handleJumpCarrier(jc, source_x, source_y, dest_x, dest_y)
  local config = jumpConfig[jc:getCallSign()]
  if config.jumping_state == "wait_for_dock" then
    if player:isDocked(jc) then
      jc:orderFlyTowardsBlind(dest_x, dest_y)
      config.jumping_state = "wait_for_jump"
    end
  elseif config.jumping_state == "wait_for_jump" then
    if distance(jc, dest_x, dest_y) < 10000 then
      -- We check for the player 1 tick later, as it can take a game tick for the player position to update as well.
      config.jumping_state = "check_for_player"
    end
  elseif config.jumping_state == "check_for_player" then
    config.jumping_state = "wait_for_dock"
    if distance(player, dest_x, dest_y) < 10000 then
      -- Good, continue.
      config.jump_finished = true
      return true
    else
      -- fly back if the player didn't land with us
      jc:orderFlyTowardsBlind(source_x, source_y)
      jc:sendCommsMessage(
          player,
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
    for dest, c in pairs(config.destinations) do
      destinations = destinations ..dest .."\n"
    end
    setCommsMessage("Please dock with us if you'd like to jump to any of our destinations: \n"..destinations)
    return
  end
  if config.jumping_state ~= "wait_for_dock" then
    setCommsMessage("Please complete the current jump before calling back")
    return
  end
  setCommsMessage("Where to?")
  for dest, c in pairs(config.destinations) do
    addCommsReply(dest, function()
        config.current_destination = dest
        config.jump_finished = false
        setCommsMessage("Roger that, proceeding to "..getSectorName(c[1], c[2]))
      end
    )
  end
end


function updateJumpCarrierState(jc)
  local config = jumpConfig[jc:getCallSign()]
  if config.current_destination == nil then return end
  if not config.jump_finished then
    local src = config.destinations[config.current_location]
    local dest = config.destinations[config.current_destination]

    if handleJumpCarrier(jc, src[1], src[2], dest[1], dest[2]) then
      config.current_location = config.current_destination
      config.current_destination = nil
    end
  end
end