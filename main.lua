-- Outline:
--    TODO: kill enemies
--    TODO: traps
--    Done: move to next room



-- StartDebug();
local mod = RegisterMod("test5", 1)

local debugTextList = {}

-- moveX and moveY are used to simulate the keyInput,
--  eg, moveX = 1 : move to right
--              0 : no movement in the horizontal axis
--              -1 : move to left
local moveX;
local moveY;

-- local path = nil
local level = Game():GetLevel();
local currentRoom = level:GetCurrentRoom();
--local currentRoomEntities = Isaac.GetRoomEntities();
--获取一定范围内的entity : Isaac.FindInRadius (Vector Position, float Radius, integer Partitions)  see EntityPartition
--获取怪物数: Isaac.CountEnemies()  Isaac.CountBosses()

local targetDoorSlot;

require("PathFinder");

function showPath(path)
  if path ~= nil then
    for i = 1, #path do
      Isaac.Spawn(2, 0, 0, Vector(path[i].X, path[i].Y), Vector(0,0), player);
    end
  end
end

local index = 1;
function moveNext()
  local player = Isaac.GetPlayer(0);

  if path ~= nil and #path ~= 0 then
    if currentRoom:GetGridIndex(player.Position) == currentRoom:GetGridIndex(path[1]) then
      table.remove(path, 1);
    end
    if #path ~= 0 then
      simpleMove(player.Position, path[1]);
    end
  end
end

function afterPickupThings()
  if Isaac.CountEnemies() == 0 and path == nil then
    local player = Isaac.GetPlayer(0);
    local level = Game():GetLevel();
    local currentRoom = level:GetCurrentRoom();

    print(currentRoom:GetType());
    if currentRoom:GetType() == RoomType.ROOM_BOSS then
      -- path = PathFinder.getPath(player.Position, currentRoom:GetGridPosition(37));
      
      -- TODO: search for the trap door in the room
      -- TODO: Test
      local minimum = currentRoom:GetGridIndex(currentRoom:GetTopLeftPos());
      local maximum = currentRoom:GetGridIndex(currentRoom:GetBottomRightPos());
      local gridEntity;
      print("hello");
      for gridIndex = minimum, maximum do
          gridEntity = currentRoom:GetGridEntity(gridIndex);
          -- TODO: Replace '17' with enumeration 
          if gridEntity ~= nil and gridEntity:GetType() == 17 then
            path = PathFinder.getPath(player.Position, currentRoom:GetGridPosition(gridIndex));
            break;
          end
      end



      showPath(path);
      return
    end
    if targetDoorSlot == nil then
      local minimumVisited = 100;
      for i = 0, 7 do
        -- return nil if no door at the index
        door = currentRoom:GetDoor(i);
        -- if door ~= nil then debugTextList[i + 1] = door.TargetRoomType end
--        if door ~= nil and door:IsRoomType(RoomType.ROOM_CURSE) == false and door:IsRoomType(RoomType.ROOM_SHOP) == false and door:IsRoomType(7) == false and door:IsRoomType(8) == false then
  --      if door ~= nil and (door:IsRoomType(RoomType.ROOM_DEFAULT) or door:IsRoomType(RoomType.ROOM_BOSS) or door:IsRoomType(RoomType.ROOM_CHEST)) then
        -- Algorithm: always go to the room that has minimum visited count 
        if door ~= nil and (door.TargetRoomType == RoomType.ROOM_DEFAULT or door.TargetRoomType == RoomType.ROOM_BOSS) then
          local targetRoomIndex = door.TargetRoomIndex;
          local targetRoomDesc = level:GetRoomByIdx(targetRoomIndex);
          local visitCount = targetRoomDesc.VisitedCount;
          if visitCount < minimumVisited then
            minimumVisited = visitCount;
            targetDoorSlot = i;
          end
        end
      end
    end
    if targetDoorSlot == nil then
      print("Wrong!");
    else
      path = PathFinder.getPath(currentRoom:GetGridPosition(currentRoom:GetGridIndex(player.Position)), currentRoom:GetDoorSlotPosition(targetDoorSlot))
      -- final = currentRoom:GetDoorSlotPosition(targetDoorSlot);
      -- print(final.X .. final.Y);
      showPath(path);
    end
  end

end

-- mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
--   targetDoorSlot = nil
-- --      moveX = 0
-- --      moveY = 0
--   i = 1
--   path = nil
-- end)
-- mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, AfterPickupThings)

--used to set moveX and moveY according to the start and final Position
function simpleMove(start, final)
  if final.X > start.X  then moveX = 1  end
  if final.Y > start.Y  then moveY = 1  end
  if final.X == start.X then moveX = 0  end
  if final.Y == start.Y then moveY = 0  end
  if final.X < start.X  then moveX = -1 end
  if final.Y < start.Y  then moveY = -1 end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
  targetDoorSlot = nil
  index = 1
  afterPickupThings();
  showPath(path);
  -- for k = 1, #path do
  --     print(k .. ":" .. path[k].X .. path[k].Y);
  -- end
end);

-- show the GridEntityType the Isaac stands on
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
  local player = Isaac.GetPlayer(0);
  local room = Game():GetLevel():GetCurrentRoom();
  local entity = room:GetGridEntityFromPos(player.Position);
  if entity ~= nil then
    Isaac.RenderText(entity:GetType() , 100, 40 + 15, 255, 255, 255, 255)
  end
end)

-- This function determines the movement simulation
-- Input: moveX and moveY
function mod:keyInput(entity, inputHook, buttonAction)
  local player = Isaac.GetPlayer(0)
  if entity ~= nil and entity.index == player.index then
    if inputHook == InputHook.GET_ACTION_VALUE then
        if buttonAction == 0 and moveX == -1 then return 1 end
        if buttonAction == 1 and moveX == 1  then return 1 end
        if buttonAction == 2 and moveY == -1 then return 1 end
        if buttonAction == 3 and moveY == 1  then return 1 end
    end
  end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.keyInput)

-- Maybe change it to POST_UPDATE?
mod:AddCallback(ModCallbacks.MC_POST_RENDER, moveNext)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
  targetDoorSlot = nil
  moveX = 0
  moveY = 0
  i = 1
  path = nil
end)