require "Info"

-- Global variables
g_PlayersEnabled = {}

function Initialize(Plugin)
  Plugin:SetName(g_PluginInfo.Name)
  Plugin:SetVersion(g_PluginInfo.Version)

  local name = g_PluginInfo.Name:lower()

  local function Enable(Player)
    g_PlayersEnabled[Player:GetUUID()] = true
    Player:SendMessage(cChatColor.Green .. g_PluginInfo.Name .. " enabled")
  end
  local function Disable(Player)
    g_PlayersEnabled[Player:GetUUID()] = false
    Player:SendMessage(cChatColor.Red .. g_PluginInfo.Name .. " disabled")
  end
  local function CheckWands(Player, Table, BlockX, BlockY, BlockZ, BlockFace)
    local Block = Vector3i(BlockX, BlockY, BlockZ)
    PlayerEnabled = g_PlayersEnabled[Player:GetUUID()]
    status = PlayerEnabled == LOCKED
    if PlayerEnabled and not status then
      for Wand, OnClick in pairs(Table) do
        if Player:GetEquippedItem().m_CustomName == Wand then
          status = OnClick(Player, Block, BlockFace)
          break
        end
      end
      Lock(Player, 1) -- Prevent execution for 1 tics
    end
    return status
  end

  -- Hooks
  cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_SPAWNED,
    function(Player)
      Enable(Player)
      for Wand, InitWand in pairs(g_InitWands) do
        InitWand(Player)
      end
    end)
  cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,
    function(Player, BlockX, BlockY, BlockZ, BlockFace)
      return CheckWands(Player, g_LeftClick, BlockX, BlockY, BlockZ, BlockFace)
    end)
  cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,
    function(Player, BlockX, BlockY, BlockZ, BlockFace)
      return CheckWands(Player, g_RightClick, BlockX, BlockY, BlockZ, BlockFace)
    end)

  -- Commands
  cPluginManager.BindCommand("/enable" .. name, name .. ".enable", function(Split, Player) Enable(Player); return true end, "Enables " .. g_PluginInfo.Name);
  cPluginManager.BindCommand("/disable" .. name, name .. ".disable", function(Split, Player) Disable(Player); return true end, "Disables " .. g_PluginInfo.Name);

  LOG("Initialised " .. g_PluginInfo.Name .. " v." .. g_PluginInfo.DisplayVersion)
  return true
end

function OnDisable()
  LOG("Disabling " .. g_PluginInfo.Name)
end
