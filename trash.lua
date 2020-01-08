
function moveNext()
    local player = Isaac.GetPlayer(0);
    
    
    if path ~= nil then
      if currentRoom:GetGridIndex(player.Position) == currentRoom:GetGridIndex(path[index]) and index <= #path - 1 then 
  --      moveX = 0
  --      moveY = 0
        simpleMove(path[index], path[index + 1])
        index = index + 1
      end
      if index == #path and currentRoom:GetGridIndex(player.Position) == currentRoom:GetGridIndex(path[#path]) then
  --      moveX = 0
  --      moveY = 0
        index = 1
        simpleMove(player.Position, path[#path])
      end
    end
  end