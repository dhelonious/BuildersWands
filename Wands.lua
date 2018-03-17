dofile(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/Classes/cWand.lua")

InfoWand     = cWand:new("Info Wand")
MetaWand     = cWand:new("Meta Wand")
BiomeWand    = cWand:new("Biome Wand")
CopyWand     = cWand:new("Copy Wand")
BuildersWand = cWand:new("Builders Wand", E_ITEM_BLAZE_ROD)

g_InitWands = {}
g_InitWands[CopyWand:GetName()] = function(Player)
  CopyWand:InitClipboard(Player)
  CopyWand:InitModes(Player, {
                                               Copy = 0,
                                               Paste = 1,
                                               PasteTypeMeta = 2,
                                               PasteMetaBiome = 5, -- Useful for Trapdoors.
                                               PasteMeta = 3,
                                               PasteBiome = 4,
                                             })
end
g_InitWands[BuildersWand:GetName()] = function(Player)
  BuildersWand:InitClipboard(Player)
  BuildersWand:InitModes(Player, {
                                                   Single = 0,
                                                   Small = 1,
                                                   Medium = 3,
                                                   Large = 5,
                                                 })
  BuildersWand:BindCommand("undo", "Undo last action", function(Split, Player)
    local World = Player:GetWorld()
    local Clipboard = BuildersWand:GetClipboard(Player)
    if (not Clipboard.Blocks) then
      BuildersWand:Info(Player, "Nothing to undo")
      return true
    end

    for i, Block in ipairs(Clipboard.Blocks) do
      if IsTypeMeta(World, Block, Clipboard.Type, Clipboard.Meta) then
        World:SetBlock(Block.x, Block.y, Block.z, 0, 0)
      end
    end
    BuildersWand:Info(Player, #Clipboard.Blocks .. " blocks undone")

    -- Empty clipboard.
    Clipboard.Type = nil
    Clipboard.Meta = nil
    Clipboard.Blocks = nil

    return true
  end)
end

--------------------------------------------------------------------------------

g_LeftClick = {}
g_LeftClick[InfoWand:GetName()] = function(Player, Block, BlockFace)
  if (not Block) or BlockFace == BLOCK_FACE_NONE then
    return true
  end
  local World = Player:GetWorld()
  local valid, Type, Meta = World:GetBlockTypeMeta(Block.x, Block.y, Block.z)
  InfoWand:Info(Player, "Position: (" .. Block.x .. "," .. Block.y .. "," .. Block.z ..")")
  InfoWand:Info(Player, "Type: " .. Type .. ":" .. Meta)
  InfoWand:Info(Player, "Biome: " .. World:GetBiomeAt(Block.x, Block.z))
  --InfoWand:Info(Player, "Face: " .. BlockFace)

  return true
end
g_LeftClick[MetaWand:GetName()] = function(Player, Block, BlockFace)
  return UseMetaWand(Player, Block, BlockFace, 0, "Reset")
end
g_LeftClick[BiomeWand:GetName()] = function(Player, Block, BlockFace)
  return UseBiomeWand(Player, Block, BlockFace, 1, "Reset")
end
g_LeftClick[CopyWand:GetName()] = function(Player, Block, BlockFace)

  if (not Block) or BlockFace == BLOCK_FACE_NONE then
    return true
  end

  local World = Player:GetWorld()
  local Clipboard = CopyWand:GetClipboard(Player)

  -- Copy Mode
  if CopyWand:GetMode() == 0 then
    local valid, Type, Meta = World:GetBlockTypeMeta(Block.x, Block.y, Block.z)

    Clipboard.Type = Type
    Clipboard.Meta = Meta
    Clipboard.Biome = World:GetBiomeAt(Block.x, Block.z)

    CopyWand:Info(Player, "Clipboard: " .. Clipboard.Type .. ":" .. Clipboard.Meta .. ", " .. Clipboard.Biome)
  end

  if not Clipboard.Type then
    CopyWand:Info(Player, "Clipboard is empy")
    return true
  end

  -- Paste Mode
  if CopyWand:GetMode() == 1 or CopyWand:GetMode() == 2 then
    World:SetBlock(Block.x, Block.y, Block.z, Clipboard.Type, Clipboard.Meta or 0)
  end
  if CopyWand:GetMode() == 3 or CopyWand:GetMode() == 5 then
    World:SetBlockMeta(Block.x, Block.y, Block.z, Clipboard.Meta or 0)
  end
  if CopyWand:GetMode() == 4 or CopyWand:GetMode() == 5 then
    World:SetAreaBiome(Block.x, Block.x, Block.z, Block.z, Clipboard.Biome or 0)
  end

  return true
end
g_LeftClick[BuildersWand:GetName()] = function(Player, Block, BlockFace)
  NVector = Vector3i(0, 0, 0)
  if BlockFace == 0 then
    NVector.y = -1
  elseif BlockFace == 1 then
    NVector.y = 1
  elseif BlockFace == 2 then
    NVector.z = -1
  elseif BlockFace == 3 then
    NVector.z = 1
  elseif BlockFace == 4 then
    NVector.x = -1
  elseif BlockFace == 5 then
    NVector.x = 1
  end

  local World = Player:GetWorld()
  local valid, OriginType, OriginMeta = World:GetBlockTypeMeta(Block.x, Block.y, Block.z)

  local Origin = Block
  local OVector1 = Vector3i(NVector.y, NVector.z, NVector.x) -- Arbitrary orthogonal vector
  local OVector2 = NVector:Cross(OVector1)
  local Directions = {OVector1, Vector3i(0, 0, 0) - OVector1, OVector2, Vector3i(0, 0, 0) - OVector2}

  local function InShape(RelativeVector)
    local Radius = BuildersWand:GetMode()
    --return RelativeVector:Length() <= Radius -- Circle
    return math.abs(RelativeVector.x) <= Radius and math.abs(RelativeVector.y) <= Radius and math.abs(RelativeVector.z) <= Radius -- Square
  end
  local function GetConnectedBlocks(World, Position, Blocks)
    local RelativePosition = Position - Origin
    if not InShape(RelativePosition) or not IsTypeMeta(World, Position, OriginType, OriginMeta) then
      return Blocks
    end

    table.insert(Blocks, Position)

    for i, Direction in ipairs(Directions) do
      NewPosition = Position + Direction
      local ValidPosition = true
      for j, Block in ipairs(Blocks) do
        if Block:Equals(NewPosition) then
          ValidPosition = false
        end
      end
      if ValidPosition then
        Blocks = GetConnectedBlocks(World, NewPosition, Blocks)
      end
    end

    return Blocks
  end

  Blocks = GetConnectedBlocks(World, Block, {})
  local NewBlocks = {}
  for i, Connected in ipairs(Blocks) do
    NewBlock = Connected + NVector
    if IsType(World, NewBlock, 0) then -- Is air?
      World:SetBlock(NewBlock.x, NewBlock.y, NewBlock.z, OriginType, OriginMeta)
      table.insert(NewBlocks, NewBlock)
    end
  end
  --BuildersWand:Info(Player, #NewBlocks .. " blocks built")

  --TODO: Implement undo history stack.
  BuildersWand:GetClipboard(Player).Type = OriginType
  BuildersWand:GetClipboard(Player).Meta = OriginMeta
  BuildersWand:GetClipboard(Player).Blocks = NewBlocks

  return true
end

--------------------------------------------------------------------------------

g_RightClick = {}
g_RightClick[InfoWand:GetName()] = function(Player, Block, BlockFace)
  return true -- Do nothing.
end
g_RightClick[MetaWand:GetName()] = function(Player, Block, BlockFace)
  local Meta = Player:GetWorld():GetBlockMeta(Block) + 1
  return UseMetaWand(Player, Block, BlockFace, Meta)
end
g_RightClick[BiomeWand:GetName()] = function(Player, Block, BlockFace)
  local Biome = Player:GetWorld():GetBiomeAt(Block.x, Block.z) + 1
  return UseBiomeWand(Player, Block, BlockFace, Biome)
end
g_RightClick[CopyWand:GetName()] = function(Player, Block, BlockFace)
  CopyWand:NextMode(Player)
  return true
end
g_RightClick[BuildersWand:GetName()] = function(Player, Block, BlockFace)
  BuildersWand:NextMode(Player)
  return true
end

--------------------------------------------------------------------------------

function UseMetaWand(Player, Block, BlockFace, Meta, Info)
  if (not Block) or BlockFace == BLOCK_FACE_NONE then
    return true
  end

  if Meta > 15 then
    Meta = 0
  end

  Player:GetWorld():SetBlockMeta(Block, Meta)
  MetaWand:Info(Player, "Meta: " .. (Info or Meta))

  return true
end

function UseBiomeWand(Player, Block, BlockFace, Biome, Info)
  if (not Block) or BlockFace == BLOCK_FACE_NONE then
    return true
  end

  if Biome > Biomes.biNumBiomes and Biome < Biomes.biFirstVariantBiome then
    Biome = Biomes.biFirstVariantBiome
  elseif Biome > Biomes.biNumVariantBiomes or Biome < Biomes.biFirstBiome then
    Biome = Biomes.biFirstBiome
  end

  Player:GetWorld():SetAreaBiome(Block.x, Block.x, Block.z, Block.z, Biome)
  MetaWand:Info(Player, "Biome: " .. (Info or Biome))

  return true
end
