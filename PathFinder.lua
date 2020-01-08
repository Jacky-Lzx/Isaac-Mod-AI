PathFinder = {};
-- This file is used to get the path from a position to another one
-- API: 
--      PathFinder.getPath(start, final)
-- return: 
--      a table 'path' storing the Postions, including the start and final Positions 

-- 2020-1-8 Use DFS
-- TODO: change it to BFS one day

local level = Game():GetLevel();
local currentRoom = level:GetCurrentRoom();

local direction = {
  ["UP"]    = Vector(0, -40),
  ["RIGHT"] = Vector(40, 0),
  ["DOWN"]  = Vector(0, 40),
  ["LEFT"]  = Vector(-40, 0)
}
local function check(pos, path)
  for i = 1, #path do
    if pos.X == path[i].X and pos.Y == path[i].Y then return false end
  end
  
  local gridEntity = currentRoom:GetGridEntityFromPos(pos)

  -- No need to check whether it is door here. 
  -- If so the recursion will go outside the room and cause stack overflow
  -- TODO: Other things that Isaac can pass through
  if (gridEntity == nil or 
      gridEntity:GetType() == GridEntityType.GRID_SPIDERWEB or 
      gridEntity:GetType() == GridEntityType.GRID_DECORATION or 
      gridEntity:GetType() == GridEntityType.GRID_PRESSURE_PLATE) then
    return true
  end
  
  return false
end

local function DFS(start, final)
  path = {};

  local success = false;
  local function oneStep(start, final)
    table.insert(path, start);
    print("1: " .. start.X .. start.Y);

    if start == final then
      seccess = true;
      return success;
    end
    
    local vectors = {direction.LEFT, direction.UP, direction.RIGHT, direction.DOWN};
    -- Improvement: do it later
    if     final.X >  start.X and final.Y > start.Y then vectors = {direction.RIGHT, direction.DOWN, direction.LEFT, direction.UP}
    elseif final.X <  start.X and final.Y > start.Y then vectors = {direction.DOWN, direction.LEFT, direction.UP, direction.RIGHT}
    elseif final.X >  start.X and final.Y < start.Y then vectors = {direction.UP, direction.RIGHT, direction.DOWN, direction.LEFT}
    elseif final.X <  start.X and final.Y < start.Y then vectors = {direction.LEFT, direction.UP, direction.RIGHT, direction.DOWN}
    elseif final.Y == start.Y and final.X < start.X then vectors = {direction.LEFT, direction.UP, direction.DOWN, direction.RIGHT}
    elseif final.Y == start.Y and final.X > start.X then vectors = {direction.RIGHT, direction.UP, direction.DOWN, direction.LEFT}
    elseif final.X == start.X and final.Y > start.Y then vectors = {direction.DOWN, direction.RIGHT, direction.LEFT, direction.UP}
    elseif final.X == start.X and final.Y < start.Y then vectors = {direction.UP, direction.RIGHT, direction.LEFT, direction.DOWN}
    end

    for i = 1, 4 do
      if final.X == (start + vectors[i]).X and final.Y == (start + vectors[i]).Y then
        print("hello");
        success = true;
        return success;
      end
      -- print("3: " .. (start + direction[i]).X .. (start + direction[i]).Y);
      -- print("4: " .. final.X .. final.Y);

    end

    for i = 1, 4 do
        -- check validation
        -- print(type(start));
        -- print(type(direction[i]));
        local newPos = start + vectors[i];
        --TEST
        -- Isaac.Spawn(2, 0, 0, newPos, Vector(0,0), player);
        print("2: " .. newPos.X .. newPos.Y);

        local gridEntity = currentRoom:GetGridEntityFromPos(newPos);
        if check(newPos, path) then
            local returnvalue = oneStep(newPos, final);
            if returnvalue == true then
              return true;
            else
              table.remove(path)
            end
        end
    end
    return false;
  end

  local test = oneStep(start, final);
  print(test);
  return path;
end

function PathFinder.getPath(start, final)
  path = {};
  DFS(start, final);
  -- TODO: this line should not be here, move it to somewhere in DFS();
  table.insert(path, final);
  -- table.insert(path, final);
  return path;
end