# LeafVE Achievements

**Version:** 2.0.3 · **Interface:** 11200 (Vanilla WoW / Turtle WoW 1.12)  
**Author:** Methl · **Server:** LeafVE private server

A comprehensive, self-contained achievement system for the LeafVE Vanilla WoW private server.  
Track your progress across levelling, exploration, dungeons, raids, PvP, professions, kills, quests, reputation, gold, and more — all stored locally with no external dependencies.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Slash Commands](#slash-commands)
- [Minimap Button](#minimap-button)
- [Achievement Categories](#achievement-categories)
- [Titles System](#titles-system)
- [Guild Chat Integration](#guild-chat-integration)
- [SavedVariables](#savedvariables)
- [File Structure](#file-structure)
- [Contributing / Extending](#contributing--extending)
- [Changelog](#changelog)

---

## Features

- **340+ achievements** spread across 12 categories.
- **Titles system** — earn a displayable title from select achievements. Your chosen title appears before your messages in guild chat.
- **Minimap button** — click to open the UI; drag to reposition (angle is saved across sessions).
- **Zone discovery tracking** — tracks both major zones (Kalimdor, Eastern Kingdoms) and Turtle WoW custom zones (Gilneas, Balor, Hyjal, Tel'Abim, Lapidis Isle, and more).
- **Dungeon & raid progress tracking** — boss-by-boss criteria tracked per dungeon/raid.
- **Kill counter** — generic enemy kills and named mob/critter milestones.
- **Profession mastery** — detects 300-skill cap in all primary and secondary professions.
- **Reputation tracking** — Revered and Exalted milestones for Alliance, Horde, and neutral factions.
- **Quest chain tracking** — multi-step quest chains (e.g. Onyxia attunement) tracked step by step.
- **Gold milestones** — peak gold accumulation thresholds.
- **Race & class identity achievements** — awarded automatically on login.
- **Meta-achievements** — unlock when all requirements of a group are met.
- **Legendary achievements** — rare feats with unique guild announcements and titles.
- **Guild Rank officer commands** — Anbu/Sannin/Hokage can grant achievements via `/achgrant`.
- **Debug mode** — toggle verbose logging with `/achtestdebug`.

---

## Installation

1. Download or clone this repository.
2. Copy the `LeafVE-Achievements-By-Methl` folder into your WoW `Interface/AddOns/` directory so the path looks like:
   ```
   World of Warcraft/
   └── Interface/
       └── AddOns/
           └── LeafVE-Achievements-By-Methl/
               ├── LeafVE_AchievementsTest.toc
               ├── LeafVE_AchievementsTest.lua
               └── data/
                   ├── LeafVE_ConsumablesDB.lua
                   ├── LeafVE_Ach_Kills.lua
                   ├── LeafVE_Ach_Skills.lua
                   ├── LeafVE_Ach_Identity.lua
                   ├── LeafVE_Ach_Reputation.lua
                   └── LeafVE_Ach_Quests.lua
   ```
3. Log in to the game and the addon will load automatically. You should see:
   ```
   [AchTest]: LeafVE Achievement System loaded successfully!
   ```

> **Compatibility:** This addon targets Interface version `11200` (Vanilla / 1.12.x).  
> It uses the Vanilla API (`this`, `arg1`, `event` event handler globals) and is not compatible with modern WoW clients.

---

## Slash Commands

| Command | Description |
|---|---|
| `/achtest` | Open the Achievements UI. |
| `/leafach` | Open the Achievements UI (alias for `/achtest`). |
| `/achtestdebug` | Toggle debug/verbose logging on or off. |
| `/achsync` | Broadcast your earned achievements to the guild channel. |
| `/achgrant <Player> <achievementId>` | *(Officer only)* Manually award an achievement to a player. Restricted to guild ranks **Anbu**, **Sannin**, and **Hokage**. |

**`/achgrant` examples:**
```
/achgrant Naruto dung_rfc_complete
/achgrant Sakura raid_mc_complete
```
If you omit the `dung_` or `raid_` prefix, the command will try to add it automatically.

---

## Minimap Button

A draggable button is placed on the minimap when the addon loads.

- **Left-click** — Opens the Achievements UI.
- **Drag** — Repositions the button around the minimap edge. The angle is saved to `LeafVE_AchTest_DB.minimapAngle` and restored on the next login/reload.
- **Hover** — Shows a tooltip: *"LeafVE Achievements — Click to open / Drag to move"*.

---

## Achievement Categories

### Leveling
Milestones at levels 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, and 60.

### Professions
Reach skill 300 in any primary or secondary profession:
Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, Fishing, First Aid, Herbalism, Leatherworking, Mining, Skinning, Tailoring.  
Bonus: **Dual Artisan** for maxing two primary professions.

### Gold
Peak gold accumulation thresholds: 10g, 100g, 500g, 1000g, 5000g.

### Dungeons
Full clears of all Vanilla and Turtle WoW dungeons including:
Ragefire Chasm, Deadmines, Shadowfang Keep, Stockade, Gnomeregan, Scarlet Monastery (all wings), Razorfen Kraul & Downs, Uldaman, Maraudon, Dire Maul (East/North/West), Blackrock Depths, Lower Blackrock Spire, Scholomance, Stratholme, Sunken Temple, Blackfathom Deeps, Karazhan Crypt, and several Turtle WoW-exclusive dungeons (Stormwrought Ruins, Gilneas City, Dragonmaw Retreat, Hateforge Quarry, Crescent Grove, Stormwind Vault, Caverns of Time: Black Morass).

### Raids
Full clears of: Molten Core, Onyxia's Lair, Blackwing Lair, Zul'Gurub, Ruins of Ahn'Qiraj, Temple of Ahn'Qiraj, and Naxxramas.  
Elite milestones: 25 and 50 total raid clears.

### Exploration
Discover all zones in Kalimdor and Eastern Kingdoms, plus detailed subzone exploration for Elwynn Forest, the Barrens, and many Turtle WoW custom zones (Gilneas, Balor, Northwind, Lapidis Isle, Gillijim's Isle, Scarlet Enclave, Grim Reaches, Tel'Abim, Hyjal, Tirisfal Uplands, and more).

### PvP
Reach PvP rank milestones up to Rank 14 (Grand Marshal / High Warlord).

### Identity
Automatically awarded on login for your character's race and class.  
All 9 playable classes and 10 races (including Turtle WoW's High Elf and Goblin) are supported.

### Kills
Generic kill milestones: 1, 100, 500, 1,000, 10,000, 50,000 enemies.  
Named mob kills: 50 kills of specific critters (Squirrel, Hare, Rat, Roach, Sheep, Cat, Rabbit, Frog, Snake, and more) and notable world bosses/enemies.

### Quests
Multi-step quest chain tracking (detected via system messages):
- Onyxia's Lair attunement (Alliance & Horde)
- Additional notable chains from Vanilla and Turtle WoW content.

### Reputation
Revered and Exalted achievements for Alliance, Horde, and all major neutral factions (Argent Dawn, Cenarion Circle, Timbermaw Hold, Gadgetzan, Ratchet, Everlook, Booty Bay, Thorium Brotherhood, Hydraxian Waterlords, Wintersaber Trainers, and more).

### Casual
Miscellaneous social/activity achievements: emoting (25 and 100 emotes), exploration, and other quality-of-life goals.

### Elite
High-difficulty milestones: 50 and 100 total dungeon runs; 25 and 50 total raid runs.

### Legendary
Extremely rare feats with unique guild-wide announcements and exclusive titles.

### Guild
Achievements tied to guild rank progression.

---

## Titles System

Certain achievements unlock a **title** (e.g. *"The Explorer"*, *"Onyxia's Bane"*, *"Grand Marshal"*).

- Open the UI (`/leafach`) and navigate to the **Titles** tab to see all unlocked titles.
- Select a title to make it active — it will appear in orange (or red for Legendary, brown for Guild) before your text when you speak in guild chat.
- Legendary and Guild titles have distinct colour formatting.

---

## Guild Chat Integration

When a title is active the addon hooks `SendChatMessage` to prepend your title to **guild** messages only. Example output:

```
[The Explorer] Naruto: Has anyone done RFC today?
```

The hook is installed 3 seconds after `PLAYER_ENTERING_WORLD` to avoid interfering with addon loading. It only modifies `GUILD` channel messages and ignores slash commands and system messages.

---

## SavedVariables

All data is persisted in `LeafVE_AchTest_DB` (defined in the `.toc` file):

| Key | Description |
|---|---|
| `achievements` | Table of earned achievements per player character. |
| `exploredZones` | Table of discovered zones/subzones per player character. |
| `selectedTitles` | Currently active title per player character. |
| `dungeonProgress` | Per-dungeon boss kill tracking. |
| `raidProgress` | Per-raid boss kill tracking. |
| `progressCounters` | Generic numeric counters (kills, emotes, etc.). |
| `completedQuests` | Completed quest chain steps per player character. |
| `peakGold` | Highest gold amount ever held per player character. |
| `minimapAngle` | Saved minimap button angle (in degrees, 0–360). |

---

## File Structure

```
LeafVE-Achievements-By-Methl/
├── LeafVE_AchievementsTest.toc       — AddOn manifest (Interface, SavedVariables, file list)
├── LeafVE_AchievementsTest.lua       — Core addon: UI, events, minimap button, slash commands
└── data/
    ├── LeafVE_ConsumablesDB.lua      — Consumables item database
    ├── LeafVE_Ach_Kills.lua          — Kill-based achievement definitions and event handlers
    ├── LeafVE_Ach_Skills.lua         — Skill/profession achievement definitions and handlers
    ├── LeafVE_Ach_Identity.lua       — Race and class achievement definitions and handlers
    ├── LeafVE_Ach_Reputation.lua     — Faction reputation achievement definitions and handlers
    └── LeafVE_Ach_Quests.lua         — Quest chain achievement definitions and handlers
```

---

## Contributing / Extending

### Adding a new achievement

1. Call `LeafVE_AchTest:AddAchievement(id, data)` or add an entry directly to the `ACHIEVEMENTS` table in `LeafVE_AchievementsTest.lua`.
2. Fill in the required fields:
   ```lua
   ACHIEVEMENTS["my_ach"] = {
     id       = "my_ach",
     name     = "My Achievement",
     desc     = "Do the thing.",
     category = "Casual",   -- must match an existing category
     points   = 10,
     icon     = "Interface\\Icons\\INV_Misc_QuestionMark",
   }
   ```
3. Award it in the appropriate event handler:
   ```lua
   LeafVE_AchTest:AwardAchievement("my_ach")
   ```

### Adding a new data file

1. Create `data/LeafVE_Ach_MyCategory.lua`.
2. Register achievements with `LeafVE_AchTest:AddAchievement(...)` inside an `ADDON_LOADED` event guard.
3. Add the file path to `LeafVE_AchievementsTest.toc` **before** `LeafVE_AchievementsTest.lua`.

### Debug mode

Enable verbose logging at any time:
```
/achtestdebug
```
All debug messages are prefixed with `[DEBUG]` in red.

---

## Changelog

### v1.4.1
- Fixed minimap icon layer (`BACKGROUND` → `ARTWORK`) and resized to 18×18 for better visibility.
- Fixed `UpdateMinimapPosition` converting the saved degree angle to radians correctly with `math.rad(LeafVE_AchTest_DB.minimapAngle)`.
- Minimap button angle is now saved to `LeafVE_AchTest_DB.minimapAngle` and restored on reload.
- Added `/leafach` slash command as a convenient alias to open the Achievements UI.

### v1.4.0
- Added more titles and a title search bar to the UI.
- Guild message integration: title is prepended to guild chat messages.

### Earlier versions
- Initial achievement system with Leveling, Dungeons, Raids, Exploration, PvP, Professions, Gold, and Casual categories.
- Minimap button and draggable positioning.
- Achievement broadcasting via `/achsync`.
- Officer grant command via `/achgrant`.
