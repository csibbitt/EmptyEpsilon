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

function jamSectors(ss, es)
  local sx,sy = sectorToXY(ss)
  es = es or ss
  local ex,ey = sectorToXY(es)
  jamArea(sx, sy, ex, ey)
end
