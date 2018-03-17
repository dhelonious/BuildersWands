This plugin provides a collection of tools, which make building more effective or specialiced. The latter is useful when the client uses a resource pack, e.g. Conquest.

# General Commands #

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/enablebuilderswands | builderswands.enable | Enables all wands. |
|/disablebuilderswands | builderswands.disable | Disable all wands. |

# Wands #

## InfoWand ##

On left click the InfoWand reveals the type, meta and biome values of the target block.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/infowand | builderswands.infowand | Obtain the Info Wand. |

## MetaWand ##

The MetaWand allows for cycling through 15 meta states of the target block using right click. On left click the target block is reset to the default meta value of 0.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/metawand | builderswands.metawand | Obtain the Meta Wand. |

## BiomeWand ##

The BiomeWand allows for cycling through all possible biome states of target column using right click. On left click the target column is reset to the default biome value of 0.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/biomewand | builderswands.biomewand | Obtain the Biome Wand. |

## CopyWand ##

The CopyWand has 5 different modes:
- Copy (obtain type, meta, and biome values of the target block)
- Past (apply type, meta, and biome values to target block)
- PastTypeMeta
- PasteMetaBiome (useful for trapdoors)
- PastMeta
- PasteBiome

Right click cycles through all modes and left click applies the action.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/copywand | builderswands.copywand | Obtain the Copy Wand. |

## BuildersWand ##

The BuildersWand allows for fast building by duplicating connected blocks of the same type within a defined square on the targeted block face on left click. Right click switches through the different scales:
- Single
- Small (3x3)
- Medium (5x5)
- Large (7x7)

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/builderswand | builderswands.builderswand | Obtain the Builders Wand. |
|/builderswandundo | builderswands.builderswand.undo | Undo last action. |

Note: (so far) the undo command only undoes the last action.

# Extensibility #

The plugin provides the *cWand* class, which allows for an easy creation of tools.

## cWand class ##

This class creates a wand tool and binds a command for obtaining it.

### Functions ###

| Name | Parameters | Return value | Notes |
| ---- | ---------- | ------------ | ----- |
| new | *string* Name<br>*cItem* Item | *cWand* Wand | Creates a new cWand object using the given item or a stick (default). |
| BindCommand | *string* Command<br>*string* Description<br>*function* Callback | | Binds a new command to the wand. |
| GetName | | *string* Name | Returns the name of the wand. |
| GetClipboard | | *table* Clipboard | Returns the clipboard table of the wand. |
| Focused | *cPlayer* Player | *boolean* Focused | True if the wand is in the active inventory slot of the player. |
| Info | *cPlayer* Player<br>*string* Info | Sends info to the player and puts the wand name in brackets. |
| InitClipboard | *cPlayer* Player | | Initializes the wand clipboard for the given player. |
| InitModes | *cPlayer* Player<br>*table* Modes | Adds the given modes to the wand. Modes have to be given in the format ModeName:ModeValue. |
| GetMode | | *integer* Mode | Returns the current mode of the wand. |
| NextMode | *cPlayer* Player | | Cycles the wand modes. |

## Example

In the following, we will create My Wand. This wand can be obtained by `\mywand` and will print "Left Click" on left click and "Right Click" on right click, respectively.

    MyWand = cWand:new("My Wand")
    g_InitWands[MyWand:GetName()] = function(Player)
      MyWand:Info(Player, "Initialised")
    end
    g_LeftClick[MyWand:GetName()] = function(Player, Block, BlockFace)
      MyWand:Info(Player, "Left Click")
    end
    g_RightClick[MyWand:GetName()] = function(Player, Block, BlockFace)
      MyWand:Info(Player, "Right Click")
    end
