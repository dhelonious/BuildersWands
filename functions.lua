-- Locks all wands for given amount of ticks.
LOCKED = "locked"
function Lock(Player, Ticks)
  if g_PlayersEnabled[Player:GetUUID()] then
    g_PlayersEnabled[Player:GetUUID()] = LOCKED
    Player:GetWorld():ScheduleTask(Ticks,
      function (World)
        g_PlayersEnabled[Player:GetUUID()] = true
      end)
  end
end

-- Checks if World.Block.Type == Type
function IsType(World, Block, Type)
  local valid, BlockType, BlockMeta = World:GetBlockTypeMeta(Block.x, Block.y, Block.z)
  return BlockType == Type
end

-- Checks if World.Block.Type == Type and World.Block.Meta == Meta
function IsTypeMeta(World, Block, Type, Meta)
  local valid, BlockType, BlockMeta = World:GetBlockTypeMeta(Block.x, Block.y, Block.z)
  return BlockType == Type and BlockMeta == Meta
end
