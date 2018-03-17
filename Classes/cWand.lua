require "Info"

cWand = {}

function cWand:new(Name, Item)
  local Wand = {}
  setmetatable(Wand, cWand)
  self.__index = self

  Wand.Name = Name
  Wand.name = Name:gsub("%s+", ""):lower()
  Wand.Mode = {}
  Wand.ModeNames = {}
  Wand.ModeValues = {}
  Wand.Clipboard = {}
  Wand.Item = cItem(Item or E_ITEM_STICK, 1, 0, "", Wand.Name)

  Wand:BindCommand("", "Obtain the " .. Wand.Name, function(Split, Player)
    if Player:GetInventory():AddItem(Wand.Item) then
      Player:SendMessage(cChatColor.Green .. "You have received a " .. Wand.Name)
    else
      Player:SendMessage(cChatColor.Red .. "Not enough inventory space.")
    end
    return true
  end)

  return Wand
end

function cWand:BindCommand(Command, Description, Callback)
  local Permission = g_PluginInfo.Name:lower() .. "." .. self.name
  if Command ~= "" then
    Permission = Permission .. "." .. Command:lower()
  end
  cPluginManager.BindCommand("/" .. self.name .. Command, Permission, Callback, "~ " .. Description)
end

function cWand:GetName()
  return self.Name
end

function cWand:GetClipboard(Player)
  return self.Clipboard[Player:GetUUID()]
end

function cWand:Focused(Player)
  return Player:GetEquippedItem().m_CustomName == self.Item.m_CustomName
end

function cWand:Info(Player, Info)
  Player:SendMessage(cChatColor.Yellow .. "[" .. self.Name .. "] " .. Info)
end

function cWand:InitClipboard(Player)
  self.Clipboard[Player:GetUUID()] = {}
end

function cWand:InitModes(Player, Modes)
  local Values = {}
  local ModeLookup = {}
  for Name, Value in pairs(Modes) do
    table.insert(Values, Value)
    ModeLookup[Value] = Name
  end
  table.sort(Values)

  for i, Value in ipairs(Values) do
    self.ModeNames[i] = ModeLookup[Value]
    self.ModeValues[i] = Value
  end
  self.Mode = 1
end

function cWand:GetMode()
  return self.ModeValues[self.Mode]
end

function cWand:NextMode(Player)
  NextMode = self.Mode+1
  if NextMode > #self.ModeValues then
    NextMode = 1
  end
  self.Mode = NextMode
  self:Info(Player, self.ModeNames[self.Mode])
end
