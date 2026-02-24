-- LeafVE Achievement System - v1.4.0 - More Titles + Title Search Bar
-- Guild message: [Title] [LeafVE Achievement] earned [Achievement]

LeafVE_AchTest = LeafVE_AchTest or {}
LeafVE_AchTest.name = "LeafVE_AchievementsTest"
LeafVE_AchTest_DB = LeafVE_AchTest_DB or {}
LeafVE_AchTest.DEBUG = false -- Set to true for debug messages

local THEME = {
  bg = {0.05, 0.05, 0.06, 0.96},
  leaf = {0.20, 0.78, 0.35, 1.00},
  gold = {1.00, 0.82, 0.20, 1.00},
  orange = {1.00, 0.50, 0.00, 1.00},
  border = {0.28, 0.28, 0.30, 1.00}
}

local function Print(msg)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cFF2DD35C[AchTest]|r: "..tostring(msg))
  end
end

local function Debug(msg)
  if LeafVE_AchTest.DEBUG then
    Print("|cFFFF0000[DEBUG]|r "..tostring(msg))
  end
end

local function Now() return time() end

local function ShortName(name)
  if not name or name == "" then 
    name = UnitName("player")
    if not name or name == "" then return nil end
  end
  local dash = string.find(name, "-")
  if dash then return string.sub(name, 1, dash-1) end
  return name
end

local function EnsureDB()
  if not LeafVE_AchTest_DB then LeafVE_AchTest_DB = {} end
  if not LeafVE_AchTest_DB.achievements then LeafVE_AchTest_DB.achievements = {} end
  if not LeafVE_AchTest_DB.exploredZones then LeafVE_AchTest_DB.exploredZones = {} end
  if not LeafVE_AchTest_DB.selectedTitles then LeafVE_AchTest_DB.selectedTitles = {} end
  if not LeafVE_AchTest_DB.dungeonProgress then LeafVE_AchTest_DB.dungeonProgress = {} end
  if not LeafVE_AchTest_DB.raidProgress then LeafVE_AchTest_DB.raidProgress = {} end
  if not LeafVE_AchTest_DB.progressCounters then LeafVE_AchTest_DB.progressCounters = {} end
  if not LeafVE_AchTest_DB.completedQuests then LeafVE_AchTest_DB.completedQuests = {} end
  if not LeafVE_AchTest_DB.iconCache then LeafVE_AchTest_DB.iconCache = {} end
end

local KALIMDOR_ZONES = {"Durotar","Mulgore","The Barrens","Teldrassil","Darkshore","Ashenvale","Stonetalon Mountains","Desolace","Feralas","Thousand Needles","Tanaris","Dustwallow Marsh","Azshara","Felwood","Un'Goro Crater","Moonglade","Winterspring","Silithus"}
local EASTERN_KINGDOMS_ZONES = {"Dun Morogh","Elwynn Forest","Tirisfal Glades","Silverpine Forest","Westfall","Redridge Mountains","Duskwood","Wetlands","Loch Modan","Hillsbrad Foothills","Alterac Mountains","Arathi Highlands","Badlands","Searing Gorge","Burning Steppes","The Hinterlands","Western Plaguelands","Eastern Plaguelands","Stranglethorn Vale","Swamp of Sorrows","Blasted Lands","Deadwind Pass"}

-- Required subzone lists for continent exploration achievements.
-- Structure: [parentZone] = { subzone1, subzone2, ... }
local REQUIRED_KALIMDOR_ZONES = {
  ["Durotar"]              = {"Valley of Trials","Sen'jin Village","Razor Hill","The Burning Blade Coven"},
  ["Mulgore"]              = {"Red Cloud Mesa","Bloodhoof Village","Thunder Bluff","Winterhoof Water Well"},
  ["The Barrens"]          = {"The Crossroads","Ratchet","Camp Taurajo","Wailing Caverns","Mor'shan Rampart","Far Watch Post"},
  ["Teldrassil"]           = {"Shadowglen","Dolanaar","Darnassus","Ban'ethil Hollow"},
  ["Darkshore"]            = {"Auberdine","Grove of the Ancients","Ruins of Mathystra","Cliffspring River"},
  ["Ashenvale"]            = {"Astranaar","Splintertree Post","Raynewood Retreat","Blackfathom Deeps"},
  ["Stonetalon Mountains"] = {"Stonetalon Peak","Sun Rock Retreat","The Charred Vale","Windshear Crag"},
  ["Desolace"]             = {"Ghost Walker Post","Nijel's Point","Shadowprey Village","Thunder Axe Fortress"},
  ["Feralas"]              = {"Camp Mojache","Feathermoon Stronghold","Dire Maul","The Twin Colossals"},
  ["Thousand Needles"]     = {"Freewind Post","The Shimmering Flats","Darkcloud Pinnacle","Great Lift"},
  ["Dustwallow Marsh"]     = {"Brackenwall Village","Theramore Isle","Alcaz Island"},
  ["Tanaris"]              = {"Gadgetzan","Steamwheedle Port","Zul'Farrak","The Noxious Lair"},
  ["Un'Goro Crater"]       = {"Marshal's Refuge","Golakka Hot Springs","Fire Plume Ridge","The Slithering Scar"},
  ["Azshara"]              = {"Talrendis Point","Ruins of Eldarath","Bay of Storms","Hetaera's Clutch"},
  ["Felwood"]              = {"Bloodvenom Falls","Emerald Sanctuary","Jaedenar","Talonbranch Glade"},
  ["Moonglade"]            = {"Nighthaven","Shrine of Remulos","Stormrage Barrow Dens"},
  ["Winterspring"]         = {"Everlook","Frostsaber Rock","Lake Kel'Theril","Owl Wing Thicket"},
  ["Silithus"]             = {"Cenarion Hold","Hive'Regal","Hive'Ashi","Ruins of Ahn'Qiraj"},
}
local REQUIRED_EK_ZONES = {
  ["Elwynn Forest"]        = {"Northshire Valley","Goldshire","Stonefield Farm","Mirror Lake","Tower of Azora"},
  ["Westfall"]             = {"Sentinel Hill","Moonbrook","The Deadmines","The Dust Plains"},
  ["Redridge Mountains"]   = {"Lakeshire","Stonewatch Keep","Render's Camp","Tower of Ilgalar"},
  ["Duskwood"]             = {"Darkshire","Raven Hill","Tranquil Gardens Cemetery","Roland's Doom"},
  ["Dun Morogh"]           = {"Coldridge Valley","Anvilmar","Kharanos","Gnomeregan","Ironforge"},
  ["Loch Modan"]           = {"Thelsamar","Stonewrought Dam","The Loch","Mo'grosh Stronghold"},
  ["Wetlands"]             = {"Menethil Harbor","Dun Modr","Whelgar's Excavation Site","Direforge Hill"},
  ["Arathi Highlands"]     = {"Refuge Pointe","Hammerfall","Stromgarde Keep","Circle of East Binding"},
  ["Hillsbrad Foothills"]  = {"Southshore","Tarren Mill","Hillsbrad Fields","Durnholde Keep"},
  ["Alterac Mountains"]    = {"Strahnbrad","Ruins of Alterac","The Uplands","Crushridge Hold"},
  ["The Hinterlands"]      = {"Aerie Peak","Revantusk Village","Jintha'Alor","The Overlook Cliffs"},
  ["Tirisfal Glades"]      = {"Deathknell","Brill","Undercity","Agamand Mills","The Bulwark"},
  ["Silverpine Forest"]    = {"The Sepulcher","Ambermill","Shadowfang Keep","Skittering Dark"},
  ["Western Plaguelands"]  = {"Andorhal","Chillwind Camp","Caer Darrow","Scholomance"},
  ["Eastern Plaguelands"]  = {"Light's Hope Chapel","Stratholme","Crown Guard Tower","Naxxramas"},
  ["Badlands"]             = {"Kargath","Uldaman","Camp Kosh","Dustbelch Grotto"},
  ["Searing Gorge"]        = {"Thorium Point","The Cauldron","Grimesilt Dig Site"},
  ["Burning Steppes"]      = {"Morgan's Vigil","Blackrock Mountain","Flame Crest","Dreadmaul Rock"},
  ["Stranglethorn Vale"]   = {"Booty Bay","Grom'gol Base Camp","Rebel Camp","Zul'Gurub","Venture Co. Base Camp"},
  ["Blasted Lands"]        = {"The Dark Portal","Nethergarde Keep","Dreadmaul Hold"},
  ["Swamp of Sorrows"]     = {"Stonard","The Temple of Atal'Hakkar","Misty Valley"},
  ["Deadwind Pass"]        = {"Karazhan","Deadwind Ravine","The Vice"},
}

-- Build flat lookup sets for fast discovery checking.
local KALIMDOR_SUBZONE_SET = {}
local KALIMDOR_REQUIRED_TOTAL = 0
for _, subzones in pairs(REQUIRED_KALIMDOR_ZONES) do
  for _, sz in ipairs(subzones) do
    if not KALIMDOR_SUBZONE_SET[sz] then
      KALIMDOR_SUBZONE_SET[sz] = true
      KALIMDOR_REQUIRED_TOTAL = KALIMDOR_REQUIRED_TOTAL + 1
    end
  end
end

local EK_SUBZONE_SET = {}
local EK_REQUIRED_TOTAL = 0
for _, subzones in pairs(REQUIRED_EK_ZONES) do
  for _, sz in ipairs(subzones) do
    if not EK_SUBZONE_SET[sz] then
      EK_SUBZONE_SET[sz] = true
      EK_REQUIRED_TOTAL = EK_REQUIRED_TOTAL + 1
    end
  end
end

-- Union of Kalimdor + EK subzones: these are the "counted" subzones for The Wanderer.
local COUNTED_WANDERER_SUBZONES = {}
for sz in pairs(KALIMDOR_SUBZONE_SET) do COUNTED_WANDERER_SUBZONES[sz] = true end
for sz in pairs(EK_SUBZONE_SET)      do COUNTED_WANDERER_SUBZONES[sz] = true end

-- List of all TW zone-group achievement IDs required for World Explorer.
local WORLD_EXPLORER_TW_IDS = {
  "explore_tw_balor","explore_tw_gilneas","explore_tw_northwind","explore_tw_lapidis",
  "explore_tw_gillijim","explore_tw_scarlet_enclave","explore_tw_grim_reaches",
  "explore_tw_telabim","explore_tw_hyjal","explore_tw_tirisfal_uplands",
  "explore_tw_stonetalon","explore_tw_arathi","explore_tw_badlands","explore_tw_ashenvale",
}

-- Turtle WoW zone-group → list of discoverable subzone names.
-- Used for zone-group exploration achievements and their tooltip criteria.
local ZONE_GROUP_ZONES = {
  balor = {
    "Bilgerat Compound","Ruins of Breezehaven","SI:7 Outpost",
    "Sorrowmore Lake","Stormbreaker Point","Stormwrought Castle",
  },
  gilneas = {
    "Blackthorn's Camp","Brol'ok Mound","Dawnstone Mine","The Dryrock Mine",
    "Dryrock Valley (The Dryrock Pit)","Ebonmere Farm","Freyshear Keep",
    "Gilneas City","Glaymore Stead","The Greymane Wall","Greymane's Watch",
    "Hollow Web Cemetary","Hollow Web Woods","Mossgrove Farm","Northgate Tower",
    "Oldrock Pass","The Overgrown Acre","Ravenshire","Ravenwood Keep",
    "Rosewick Plantation","Ruins of Greyshire","Shademore Tavern",
    "Southmire Orchard","Stillward Church","Vagrant Encampment","Westgate Tower",
  },
  northwind = {
    "Abbey Gardens","Ambershire","Crystal Falls",
    "Northwind Logging Camp","Ruins of Birkhaven","Sherwood Quarry","Stillheart Port",
  },
  lapidis = {
    "Bright Coast","Caelan's Rest","Crown Island","Gor'dosh Heights",
    "Hazzuri Glade","The Rock","Shank's Reef","The Tower of Lapidis",
    "The Wallowing Coast","Zul'Hazu",
  },
  gillijim = {
    "The Broken Reef","Deeptide Sanctum","Distillery Island","Faelon's Folly",
    "Gillijim Canyon","Gillijim Strand","Kalkor Point","Kazon Island",
    "Maul'ogg Post","Maul'ogg Refuge","Ruins of Zul'Razar","The Silver Coast",
    "The Silver Sandbar","Southsea Sandbar","The Tangled Wood","Zul'Razar",
  },
  scarlet_enclave = {
    "The Forbidding Sea","Gloom Hill","Havenshire","King's Harbor",
    "Light's Point","New Avalon",
  },
  grim_reaches = {
    "Dun Kithas","The Grim Hollow","Ruins of Stolgaz Keep",
    "Shatterblade Post","Zarm'Geth Stronghold",
  },
  telabim = {
    "Bixxle's Storehouse","The Derelict Camp","Highvale Rise","The Jagged Isles",
    "The Shallow Strand","Tazzo's Shack","Tel Co. Basecamp","The Washing Shore",
  },
  hyjal = {
    "Barkskin Plateau","Barkskin Village","Bleakhollow Crater","Circle of Power",
    "Darkhollow Pass","The Emerald Gateway","Nordanaar","Nordrassil Glade",
    "The Ruins of Telennas","Zul'Hathar",
  },
  tirisfal_uplands = {
    "The Blacktower Inn","The Corinth Farmstead","Crumblepoint Tower",
    "Glenshire","Gracestone Mine","Ishnu'Danil","The Jagged Hills",
    "The Lafford House","The Remnants Camp","The Rogue Heights",
    "Shalla'Aran","Steepcliff Port","Shatteridge Tower","The Whispering Forest",
  },
  stonetalon_tw = {
    "Boulderslide Ravine","Greatwood Vale","Malaka'jin","Mirkfallon Lake",
    "Stonetalon Peak","The Talondeep Path","Windshear Crag",
  },
  arathi_tw = {
    "Wildtusk Village","Ruins of Zul'rasaz","Farwell Stead",
    "Gallant Square","Livingstone Croft",
  },
  badlands_tw = {
    "Ruins of Corthan","Scalebane Ridge","Crystalline Oasis",
    "Crystalline Pinnacle","Redbrand's Digsite","Angor Digsite","Ruins of Zeth",
  },
  ashenvale_tw = {
    "Forest Song","Thalanaar","Talonbranch Glade",
    "Demon Fall Ridge","Warsong Lumber Camp",
  },
}

local ACHIEVEMENTS = {
  -- Leveling
  lvl_10={id="lvl_10",name="Level 10",desc="Reach level 10",category="Leveling",points=5,icon="Interface\\Icons\\INV_Misc_Bone_HumanSkull_01"},
  lvl_20={id="lvl_20",name="Level 20",desc="Reach level 20",category="Leveling",points=10,icon="Interface\\Icons\\INV_Helmet_08"},
  lvl_30={id="lvl_30",name="Level 30",desc="Reach level 30",category="Leveling",points=15,icon="Interface\\Icons\\INV_Shoulder_23"},
  lvl_40={id="lvl_40",name="Level 40",desc="Reach level 40",category="Leveling",points=20,icon="Interface\\Icons\\INV_Chest_Plate16"},
  lvl_50={id="lvl_50",name="Level 50",desc="Reach level 50",category="Leveling",points=25,icon="Interface\\Icons\\INV_Weapon_ShortBlade_25"},
  lvl_60={id="lvl_60",name="Level 60",desc="Reach maximum level",category="Leveling",points=50,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength"},
  
  -- Professions
  prof_alchemy_300={id="prof_alchemy_300",name="Master Alchemist",desc="Reach 300 Alchemy",category="Professions",points=25,icon="Interface\\Icons\\Trade_Alchemy"},
  prof_blacksmithing_300={id="prof_blacksmithing_300",name="Master Blacksmith",desc="Reach 300 Blacksmithing",category="Professions",points=25,icon="Interface\\Icons\\Trade_BlackSmithing"},
  prof_enchanting_300={id="prof_enchanting_300",name="Master Enchanter",desc="Reach 300 Enchanting",category="Professions",points=25,icon="Interface\\Icons\\Trade_Engraving"},
  prof_engineering_300={id="prof_engineering_300",name="Master Engineer",desc="Reach 300 Engineering",category="Professions",points=25,icon="Interface\\Icons\\Trade_Engineering"},
  prof_herbalism_300={id="prof_herbalism_300",name="Master Herbalist",desc="Reach 300 Herbalism",category="Professions",points=25,icon="Interface\\Icons\\Trade_Herbalism"},
  prof_leatherworking_300={id="prof_leatherworking_300",name="Master Leatherworker",desc="Reach 300 Leatherworking",category="Professions",points=25,icon="Interface\\Icons\\Trade_LeatherWorking"},
  prof_mining_300={id="prof_mining_300",name="Master Miner",desc="Reach 300 Mining",category="Professions",points=25,icon="Interface\\Icons\\Trade_Mining"},
  prof_skinning_300={id="prof_skinning_300",name="Master Skinner",desc="Reach 300 Skinning",category="Professions",points=25,icon="Interface\\Icons\\INV_Misc_Pelt_Wolf_01"},
  prof_tailoring_300={id="prof_tailoring_300",name="Master Tailor",desc="Reach 300 Tailoring",category="Professions",points=25,icon="Interface\\Icons\\Trade_Tailoring"},
  prof_fishing_300={id="prof_fishing_300",name="Master Fisherman",desc="Reach 300 Fishing",category="Professions",points=25,icon="Interface\\Icons\\Trade_Fishing"},
  prof_cooking_300={id="prof_cooking_300",name="Master Chef",desc="Reach 300 Cooking",category="Professions",points=25,icon="Interface\\Icons\\INV_Misc_Food_15"},
  prof_firstaid_300={id="prof_firstaid_300",name="Master Medic",desc="Reach 300 First Aid",category="Professions",points=25,icon="Interface\\Icons\\Spell_Holy_SealOfSacrifice"},
  prof_dual_artisan={id="prof_dual_artisan",name="Dual Artisan",desc="Reach 300 in two professions",category="Professions",points=50,icon="Interface\\Icons\\INV_Misc_Note_06"},
  
  -- Gold
  gold_10={id="gold_10",name="Copper Baron",desc="Accumulate 10 gold",category="Gold",points=10,icon="Interface\\Icons\\INV_Misc_Coin_01"},
  gold_100={id="gold_100",name="Silver Merchant",desc="Accumulate 100 gold",category="Gold",points=20,icon="Interface\\Icons\\INV_Misc_Coin_03"},
  gold_500={id="gold_500",name="Gold Tycoon",desc="Accumulate 500 gold",category="Gold",points=40,icon="Interface\\Icons\\INV_Misc_Coin_05"},
  gold_1000={id="gold_1000",name="Wealthy Elite",desc="Accumulate 1000 gold",category="Gold",points=75,icon="Interface\\Icons\\INV_Misc_Coin_06"},
  gold_5000={id="gold_5000",name="Fortune Builder",desc="Accumulate 5000 gold",category="Gold",points=100,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  
  -- Dungeons (Completion — all bosses with checkmarks, awarded when all killed)
  dung_rfc_complete={id="dung_rfc_complete",name="Ragefire Chasm: Dungeon Clear",desc="Defeat all bosses in Ragefire Chasm",category="Dungeons",points=15,icon="Interface\\Icons\\Spell_Shadow_SealOfKings",criteria_key="rfc",criteria_type="dungeon"},
  dung_wc_complete={id="dung_wc_complete",name="Wailing Caverns: Dungeon Clear",desc="Defeat all bosses in Wailing Caverns",category="Dungeons",points=20,icon="Interface\\Icons\\Spell_Nature_NullifyDisease",criteria_key="wc",criteria_type="dungeon"},
  dung_dm_complete={id="dung_dm_complete",name="The Deadmines: Dungeon Clear",desc="Defeat all bosses in The Deadmines",category="Dungeons",points=20,icon="Interface\\Icons\\INV_Sword_01",criteria_key="dm",criteria_type="dungeon"},
  dung_sfk_complete={id="dung_sfk_complete",name="Shadowfang Keep: Dungeon Clear",desc="Defeat all bosses in Shadowfang Keep",category="Dungeons",points=25,icon="Interface\\Icons\\Spell_Shadow_Possession",criteria_key="sfk",criteria_type="dungeon"},
  dung_bfd_complete={id="dung_bfd_complete",name="Blackfathom Deeps: Dungeon Clear",desc="Defeat all bosses in Blackfathom Deeps",category="Dungeons",points=25,icon="Interface\\Icons\\INV_Misc_Fish_02",criteria_key="bfd",criteria_type="dungeon"},
  dung_stocks_complete={id="dung_stocks_complete",name="The Stockade: Dungeon Clear",desc="Defeat all bosses in The Stockade",category="Dungeons",points=25,icon="Interface\\Icons\\INV_Misc_Key_03",criteria_key="stocks",criteria_type="dungeon"},
  dung_tcg_complete={id="dung_tcg_complete",name="The Crescent Grove: Dungeon Clear",desc="Defeat all bosses in The Crescent Grove",category="Dungeons",points=25,icon="Interface\\Icons\\Spell_Nature_Regeneration",criteria_key="tcg",criteria_type="dungeon"},
  dung_gnomer_complete={id="dung_gnomer_complete",name="Gnomeregan: Dungeon Clear",desc="Defeat all bosses in Gnomeregan",category="Dungeons",points=30,icon="Interface\\Icons\\INV_Misc_Gear_01",criteria_key="gnomer",criteria_type="dungeon"},
  dung_rfk_complete={id="dung_rfk_complete",name="Razorfen Kraul: Dungeon Clear",desc="Defeat all bosses in Razorfen Kraul",category="Dungeons",points=30,icon="Interface\\Icons\\INV_Misc_Head_Boar_01",criteria_key="rfk",criteria_type="dungeon"},
  dung_sm_gy_complete={id="dung_sm_gy_complete",name="Scarlet Monastery - Graveyard: Dungeon Clear",desc="Defeat all bosses in Scarlet Monastery (Graveyard)",category="Dungeons",points=20,icon="Interface\\Icons\\Spell_Shadow_DeathScream",criteria_key="sm_gy",criteria_type="dungeon"},
  dung_sm_lib_complete={id="dung_sm_lib_complete",name="Scarlet Monastery - Library: Dungeon Clear",desc="Defeat all bosses in Scarlet Monastery (Library)",category="Dungeons",points=20,icon="Interface\\Icons\\INV_Misc_Book_11",criteria_key="sm_lib",criteria_type="dungeon"},
  dung_sm_arm_complete={id="dung_sm_arm_complete",name="Scarlet Monastery - Armory: Dungeon Clear",desc="Defeat all bosses in Scarlet Monastery (Armory)",category="Dungeons",points=20,icon="Interface\\Icons\\INV_Gauntlets_17",criteria_key="sm_arm",criteria_type="dungeon"},
  dung_sm_cat_complete={id="dung_sm_cat_complete",name="Scarlet Monastery - Cathedral: Dungeon Clear",desc="Defeat all bosses in Scarlet Monastery (Cathedral)",category="Dungeons",points=25,icon="Interface\\Icons\\Spell_Holy_GuardianSpirit",criteria_key="sm_cat",criteria_type="dungeon"},
  dung_swr_complete={id="dung_swr_complete",name="Stormwrought Ruins: Dungeon Clear",desc="Defeat all bosses in Stormwrought Ruins",category="Dungeons",points=30,icon="Interface\\Icons\\Spell_Shadow_Charm",criteria_key="swr",criteria_type="dungeon"},
  dung_rfdown_complete={id="dung_rfdown_complete",name="Razorfen Downs: Dungeon Clear",desc="Defeat all bosses in Razorfen Downs",category="Dungeons",points=35,icon="Interface\\Icons\\Spell_Ice_LichTransform",criteria_key="rfdown",criteria_type="dungeon"},
  dung_ulda_complete={id="dung_ulda_complete",name="Uldaman: Dungeon Clear",desc="Defeat all bosses in Uldaman",category="Dungeons",points=35,icon="Interface\\Icons\\INV_Misc_StoneTablet_11",criteria_key="ulda",criteria_type="dungeon"},
  dung_gc_complete={id="dung_gc_complete",name="Gilneas City: Dungeon Clear",desc="Defeat all bosses in Gilneas City",category="Dungeons",points=35,icon="Interface\\Icons\\INV_Shield_06",criteria_key="gc",criteria_type="dungeon"},
  dung_mara_complete={id="dung_mara_complete",name="Maraudon: Dungeon Clear",desc="Defeat all bosses in Maraudon",category="Dungeons",points=40,icon="Interface\\Icons\\INV_Misc_Root_02",criteria_key="mara",criteria_type="dungeon"},
  dung_zf_complete={id="dung_zf_complete",name="Zul'Farrak: Dungeon Clear",desc="Defeat all bosses in Zul'Farrak",category="Dungeons",points=40,icon="Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",criteria_key="zf",criteria_type="dungeon"},
  dung_st_complete={id="dung_st_complete",name="Sunken Temple: Dungeon Clear",desc="Defeat all bosses in The Sunken Temple",category="Dungeons",points=45,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Green",criteria_key="st",criteria_type="dungeon"},
  dung_hq_complete={id="dung_hq_complete",name="Hateforge Quarry: Dungeon Clear",desc="Defeat all bosses in Hateforge Quarry",category="Dungeons",points=40,icon="Interface\\Icons\\Trade_Mining",criteria_key="hq",criteria_type="dungeon"},
  dung_brd_complete={id="dung_brd_complete",name="Blackrock Depths: Dungeon Clear",desc="Defeat all bosses in Blackrock Depths",category="Dungeons",points=50,icon="Interface\\Icons\\Spell_Fire_LavaSpawn",criteria_key="brd",criteria_type="dungeon"},
  dung_dme_complete={id="dung_dme_complete",name="Dire Maul East: Dungeon Clear",desc="Defeat all bosses in Dire Maul East",category="Dungeons",points=45,icon="Interface\\Icons\\INV_Misc_Key_14",criteria_key="dme",criteria_type="dungeon"},
  dung_dmw_complete={id="dung_dmw_complete",name="Dire Maul West: Dungeon Clear",desc="Defeat all bosses in Dire Maul West",category="Dungeons",points=45,icon="Interface\\Icons\\INV_Misc_Book_09",criteria_key="dmw",criteria_type="dungeon"},
  dung_dmn_complete={id="dung_dmn_complete",name="Dire Maul North: Dungeon Clear",desc="Defeat all bosses in Dire Maul North",category="Dungeons",points=50,icon="Interface\\Icons\\INV_Crown_01",criteria_key="dmn",criteria_type="dungeon"},
  dung_scholo_complete={id="dung_scholo_complete",name="Scholomance: Dungeon Clear",desc="Defeat all bosses in Scholomance",category="Dungeons",points=55,icon="Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",criteria_key="scholo",criteria_type="dungeon"},
  dung_strat_complete={id="dung_strat_complete",name="Stratholme: Dungeon Clear",desc="Defeat all bosses in Stratholme",category="Dungeons",points=55,icon="Interface\\Icons\\Spell_Shadow_RaiseDead",criteria_key="strat",criteria_type="dungeon"},
  dung_lbrs_complete={id="dung_lbrs_complete",name="Lower Blackrock Spire: Dungeon Clear",desc="Defeat all bosses in Lower Blackrock Spire",category="Dungeons",points=50,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black",criteria_key="lbrs",criteria_type="dungeon"},
  dung_ubrs_complete={id="dung_ubrs_complete",name="Upper Blackrock Spire: Dungeon Clear",desc="Defeat all bosses in Upper Blackrock Spire",category="Dungeons",points=55,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",criteria_key="ubrs",criteria_type="dungeon"},
  dung_kc_complete={id="dung_kc_complete",name="Karazhan Crypt: Dungeon Clear",desc="Defeat all bosses in Karazhan Crypt",category="Dungeons",points=50,icon="Interface\\Icons\\Spell_Shadow_SoulGem",criteria_key="kc",criteria_type="dungeon"},
  dung_cotbm_complete={id="dung_cotbm_complete",name="Caverns of Time: Dungeon Clear",desc="Defeat all bosses in Caverns of Time: Black Morass",category="Dungeons",points=50,icon="Interface\\Icons\\INV_Misc_Rune_01",criteria_key="cotbm",criteria_type="dungeon"},
  dung_swv_complete={id="dung_swv_complete",name="Stormwind Vault: Dungeon Clear",desc="Defeat all bosses in Stormwind Vault",category="Dungeons",points=50,icon="Interface\\Icons\\INV_Misc_Key_03",criteria_key="swv",criteria_type="dungeon"},
  dung_dmr_complete={id="dung_dmr_complete",name="Dragonmaw Retreat: Dungeon Clear",desc="Defeat all bosses in Dragonmaw Retreat",category="Dungeons",points=35,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black",criteria_key="dmr",criteria_type="dungeon"},
  
  -- Raids - Molten Core
  raid_mc_lucifron={id="raid_mc_lucifron",name="Molten Core: Lucifron",desc="Defeat Lucifron",category="Raids",points=25,icon="Interface\\Icons\\Spell_Fire_Incinerate"},
  raid_mc_magmadar={id="raid_mc_magmadar",name="Molten Core: Magmadar",desc="Defeat Magmadar",category="Raids",points=25,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  raid_mc_gehennas={id="raid_mc_gehennas",name="Molten Core: Gehennas",desc="Defeat Gehennas",category="Raids",points=25,icon="Interface\\Icons\\Spell_Shadow_Requiem"},
  raid_mc_garr={id="raid_mc_garr",name="Molten Core: Garr",desc="Defeat Garr",category="Raids",points=25,icon="Interface\\Icons\\Spell_Nature_WispSplode"},
  raid_mc_geddon={id="raid_mc_geddon",name="Molten Core: Baron Geddon",desc="Defeat Baron Geddon",category="Raids",points=30,icon="Interface\\Icons\\Spell_Fire_ElementalDevastation"},
  raid_mc_shazzrah={id="raid_mc_shazzrah",name="Molten Core: Shazzrah",desc="Defeat Shazzrah",category="Raids",points=25,icon="Interface\\Icons\\Spell_Nature_Lightning"},
  raid_mc_sulfuron={id="raid_mc_sulfuron",name="Molten Core: Sulfuron Harbinger",desc="Defeat Sulfuron Harbinger",category="Raids",points=30,icon="Interface\\Icons\\Spell_Fire_FireArmor"},
  raid_mc_golemagg={id="raid_mc_golemagg",name="Molten Core: Golemagg",desc="Defeat Golemagg the Incinerator",category="Raids",points=30,icon="Interface\\Icons\\INV_Misc_MonsterScales_15"},
  raid_mc_majordomo={id="raid_mc_majordomo",name="Molten Core: Majordomo",desc="Defeat Majordomo Executus",category="Raids",points=40,icon="Interface\\Icons\\INV_Helmet_08"},
  raid_mc_ragnaros={id="raid_mc_ragnaros",name="Molten Core: Ragnaros",desc="Defeat Ragnaros the Firelord",category="Raids",points=100,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  
  -- Raids - Onyxia
  raid_onyxia={id="raid_onyxia",name="Onyxia's Lair",desc="Defeat Onyxia",category="Raids",points=75,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  
  -- Raids - Blackwing Lair
  raid_bwl_razorgore={id="raid_bwl_razorgore",name="Blackwing Lair: Razorgore",desc="Defeat Razorgore the Untamed",category="Raids",points=30,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  raid_bwl_vaelastrasz={id="raid_bwl_vaelastrasz",name="Blackwing Lair: Vaelastrasz",desc="Defeat Vaelastrasz the Corrupt",category="Raids",points=35,icon="Interface\\Icons\\Spell_Shadow_ShadowWordDominate"},
  raid_bwl_broodlord={id="raid_bwl_broodlord",name="Blackwing Lair: Broodlord",desc="Defeat Broodlord Lashlayer",category="Raids",points=30,icon="Interface\\Icons\\INV_Bracer_18"},
  raid_bwl_firemaw={id="raid_bwl_firemaw",name="Blackwing Lair: Firemaw",desc="Defeat Firemaw",category="Raids",points=25,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  raid_bwl_ebonroc={id="raid_bwl_ebonroc",name="Blackwing Lair: Ebonroc",desc="Defeat Ebonroc",category="Raids",points=25,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  raid_bwl_flamegor={id="raid_bwl_flamegor",name="Blackwing Lair: Flamegor",desc="Defeat Flamegor",category="Raids",points=25,icon="Interface\\Icons\\Spell_Fire_Fire"},
  raid_bwl_chromaggus={id="raid_bwl_chromaggus",name="Blackwing Lair: Chromaggus",desc="Defeat Chromaggus",category="Raids",points=40,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Bronze"},
  raid_bwl_nefarian={id="raid_bwl_nefarian",name="Blackwing Lair: Nefarian",desc="Defeat Nefarian",category="Raids",points=125,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  
  -- Raids - Zul'Gurub
  raid_zg_venoxis={id="raid_zg_venoxis",name="Zul'Gurub: High Priest Venoxis",desc="Defeat High Priest Venoxis",category="Raids",points=15,icon="Interface\\Icons\\Spell_Nature_NullifyPoison"},
  raid_zg_jeklik={id="raid_zg_jeklik",name="Zul'Gurub: High Priestess Jeklik",desc="Defeat High Priestess Jeklik",category="Raids",points=15,icon="Interface\\Icons\\Spell_Shadow_UnholyFrenzy"},
  raid_zg_marli={id="raid_zg_marli",name="Zul'Gurub: High Priestess Mar'li",desc="Defeat High Priestess Mar'li",category="Raids",points=15,icon="Interface\\Icons\\Spell_Nature_Polymorph"},
  raid_zg_thekal={id="raid_zg_thekal",name="Zul'Gurub: High Priest Thekal",desc="Defeat High Priest Thekal",category="Raids",points=20,icon="Interface\\Icons\\Ability_Druid_Mangle2"},
  raid_zg_arlokk={id="raid_zg_arlokk",name="Zul'Gurub: High Priestess Arlokk",desc="Defeat High Priestess Arlokk",category="Raids",points=20,icon="Interface\\Icons\\INV_Misc_MonsterScales_14"},
  raid_zg_hakkar={id="raid_zg_hakkar",name="Zul'Gurub: Hakkar",desc="Defeat Hakkar the Soulflayer",category="Raids",points=50,icon="Interface\\Icons\\Spell_Shadow_PainSpike"},
  
  -- Raids - AQ20
  raid_aq20_kurinnaxx={id="raid_aq20_kurinnaxx",name="Ruins of Ahn'Qiraj: Kurinnaxx",desc="Defeat Kurinnaxx",category="Raids",points=15,icon="Interface\\Icons\\INV_Qiraj_JewelBlessed"},
  raid_aq20_rajaxx={id="raid_aq20_rajaxx",name="Ruins of Ahn'Qiraj: General Rajaxx",desc="Defeat General Rajaxx",category="Raids",points=20,icon="Interface\\Icons\\INV_Sword_43"},
  raid_aq20_moam={id="raid_aq20_moam",name="Ruins of Ahn'Qiraj: Moam",desc="Defeat Moam",category="Raids",points=15,icon="Interface\\Icons\\Spell_Shadow_UnholyStrength"},
  raid_aq20_buru={id="raid_aq20_buru",name="Ruins of Ahn'Qiraj: Buru",desc="Defeat Buru the Gorger",category="Raids",points=20,icon="Interface\\Icons\\INV_Qiraj_JewelEngraved"},
  raid_aq20_ayamiss={id="raid_aq20_ayamiss",name="Ruins of Ahn'Qiraj: Ayamiss",desc="Defeat Ayamiss the Hunter",category="Raids",points=20,icon="Interface\\Icons\\INV_Spear_04"},
  raid_aq20_ossirian={id="raid_aq20_ossirian",name="Ruins of Ahn'Qiraj: Ossirian",desc="Defeat Ossirian the Unscarred",category="Raids",points=40,icon="Interface\\Icons\\INV_Qiraj_JewelGlowing"},
  
  -- Raids - AQ40
  raid_aq40_skeram={id="raid_aq40_skeram",name="Temple of Ahn'Qiraj: The Prophet Skeram",desc="Defeat The Prophet Skeram",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_MindSteal"},
  raid_aq40_bug_trio={id="raid_aq40_bug_trio",name="Temple of Ahn'Qiraj: Bug Trio",desc="Defeat the Silithid Royalty",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_02"},
  raid_aq40_sartura={id="raid_aq40_sartura",name="Temple of Ahn'Qiraj: Battleguard Sartura",desc="Defeat Battleguard Sartura",category="Raids",points=30,icon="Interface\\Icons\\INV_Weapon_ShortBlade_25"},
  raid_aq40_fankriss={id="raid_aq40_fankriss",name="Temple of Ahn'Qiraj: Fankriss",desc="Defeat Fankriss the Unyielding",category="Raids",points=30,icon="Interface\\Icons\\INV_Qiraj_Husk"},
  raid_aq40_viscidus={id="raid_aq40_viscidus",name="Temple of Ahn'Qiraj: Viscidus",desc="Defeat Viscidus",category="Raids",points=35,icon="Interface\\Icons\\Spell_Nature_Acid_01"},
  raid_aq40_huhuran={id="raid_aq40_huhuran",name="Temple of Ahn'Qiraj: Princess Huhuran",desc="Defeat Princess Huhuran",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_03"},
  raid_aq40_twins={id="raid_aq40_twins",name="Temple of Ahn'Qiraj: Twin Emperors",desc="Defeat the Twin Emperors",category="Raids",points=50,icon="Interface\\Icons\\INV_Jewelry_Ring_AhnQiraj_04"},
  raid_aq40_ouro={id="raid_aq40_ouro",name="Temple of Ahn'Qiraj: Ouro",desc="Defeat Ouro",category="Raids",points=40,icon="Interface\\Icons\\INV_Qiraj_JewelGlowing"},
  raid_aq40_cthun={id="raid_aq40_cthun",name="Temple of Ahn'Qiraj: C'Thun",desc="Defeat C'Thun",category="Raids",points=150,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  
  -- Raids - Naxxramas
  raid_naxx_anubrekhan={id="raid_naxx_anubrekhan",name="Naxxramas: Anub'Rekhan",desc="Defeat Anub'Rekhan",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_UnholyStrength"},
  raid_naxx_faerlina={id="raid_naxx_faerlina",name="Naxxramas: Grand Widow Faerlina",desc="Defeat Grand Widow Faerlina",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_Possession"},
  raid_naxx_maexxna={id="raid_naxx_maexxna",name="Naxxramas: Maexxna",desc="Defeat Maexxna",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_MonsterSpiderCarapace_01"},
  raid_naxx_noth={id="raid_naxx_noth",name="Naxxramas: Noth",desc="Defeat Noth the Plaguebringer",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"},
  raid_naxx_heigan={id="raid_naxx_heigan",name="Naxxramas: Heigan",desc="Defeat Heigan the Unclean",category="Raids",points=35,icon="Interface\\Icons\\Spell_Shadow_DeathScream"},
  raid_naxx_loatheb={id="raid_naxx_loatheb",name="Naxxramas: Loatheb",desc="Defeat Loatheb",category="Raids",points=50,icon="Interface\\Icons\\Spell_Shadow_CallofBone"},
  raid_naxx_razuvious={id="raid_naxx_razuvious",name="Naxxramas: Instructor Razuvious",desc="Defeat Instructor Razuvious",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_ShadowWordPain"},
  raid_naxx_gothik={id="raid_naxx_gothik",name="Naxxramas: Gothik",desc="Defeat Gothik the Harvester",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_ShadowBolt"},
  raid_naxx_four_horsemen={id="raid_naxx_four_horsemen",name="Naxxramas: Four Horsemen",desc="Defeat The Four Horsemen",category="Raids",points=60,icon="Interface\\Icons\\Spell_DeathKnight_ClassIcon"},
  raid_naxx_patchwerk={id="raid_naxx_patchwerk",name="Naxxramas: Patchwerk",desc="Defeat Patchwerk",category="Raids",points=30,icon="Interface\\Icons\\INV_Weapon_ShortBlade_25"},
  raid_naxx_grobbulus={id="raid_naxx_grobbulus",name="Naxxramas: Grobbulus",desc="Defeat Grobbulus",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_CallofBone"},
  raid_naxx_gluth={id="raid_naxx_gluth",name="Naxxramas: Gluth",desc="Defeat Gluth",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_AnimateDead"},
  raid_naxx_thaddius={id="raid_naxx_thaddius",name="Naxxramas: Thaddius",desc="Defeat Thaddius",category="Raids",points=40,icon="Interface\\Icons\\Spell_Shadow_UnholyFrenzy"},
  raid_naxx_sapphiron={id="raid_naxx_sapphiron",name="Naxxramas: Sapphiron",desc="Defeat Sapphiron",category="Raids",points=75,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Blue"},
  raid_naxx_kelthuzad={id="raid_naxx_kelthuzad",name="Naxxramas: Kel'Thuzad",desc="Defeat Kel'Thuzad",category="Raids",points=200,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},

  -- Raids - Molten Core (Turtle WoW additions)
  raid_mc_incindis={id="raid_mc_incindis",name="Molten Core: Incindis",desc="Defeat Incindis",category="Raids",points=20,icon="Interface\\Icons\\Spell_Fire_Incinerate"},
  raid_mc_twins={id="raid_mc_twins",name="Molten Core: Basalthar & Smoldaris",desc="Defeat Basalthar and Smoldaris",category="Raids",points=25,icon="Interface\\Icons\\INV_Misc_MonsterScales_15"},
  raid_mc_sorcerer={id="raid_mc_sorcerer",name="Molten Core: Sorcerer-Thane Thaurissan",desc="Defeat Sorcerer-Thane Thaurissan",category="Raids",points=25,icon="Interface\\Icons\\Spell_Fire_FireArmor"},

  -- Raids - Zul'Gurub (additional bosses)
  raid_zg_mandokir={id="raid_zg_mandokir",name="Zul'Gurub: Bloodlord Mandokir",desc="Defeat Bloodlord Mandokir",category="Raids",points=20,icon="Interface\\Icons\\Ability_Druid_Mangle2"},
  raid_zg_grilek={id="raid_zg_grilek",name="Zul'Gurub: Gri'lek",desc="Defeat Gri'lek",category="Raids",points=15,icon="Interface\\Icons\\INV_Misc_MonsterScales_14"},
  raid_zg_hazzarah={id="raid_zg_hazzarah",name="Zul'Gurub: Hazza'rah",desc="Defeat Hazza'rah",category="Raids",points=15,icon="Interface\\Icons\\Spell_Nature_Polymorph"},
  raid_zg_renataki={id="raid_zg_renataki",name="Zul'Gurub: Renataki",desc="Defeat Renataki",category="Raids",points=15,icon="Interface\\Icons\\Spell_Nature_NullifyPoison"},
  raid_zg_wushoolay={id="raid_zg_wushoolay",name="Zul'Gurub: Wushoolay",desc="Defeat Wushoolay",category="Raids",points=15,icon="Interface\\Icons\\Spell_Nature_Lightning"},
  raid_zg_gahzranka={id="raid_zg_gahzranka",name="Zul'Gurub: Gahz'ranka",desc="Defeat Gahz'ranka",category="Raids",points=15,icon="Interface\\Icons\\INV_Misc_Fish_02"},
  raid_zg_jindo={id="raid_zg_jindo",name="Zul'Gurub: Jin'do the Hexxer",desc="Defeat Jin'do the Hexxer",category="Raids",points=20,icon="Interface\\Icons\\Spell_Shadow_UnholyFrenzy"},

  -- Raids - Emerald Sanctum (Turtle WoW)
  raid_es_erennius={id="raid_es_erennius",name="Emerald Sanctum: Erennius",desc="Defeat Erennius",category="Raids",points=75,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Green"},
  raid_es_solnius={id="raid_es_solnius",name="Emerald Sanctum: Solnius the Awakener",desc="Defeat Solnius the Awakener",category="Raids",points=50,icon="Interface\\Icons\\Spell_Nature_Regeneration"},

  -- Raids - Lower Karazhan Halls (Turtle WoW)
  raid_lkh_rolfen={id="raid_lkh_rolfen",name="Lower Karazhan Halls: Master Blacksmith Rolfen",desc="Defeat Master Blacksmith Rolfen",category="Raids",points=30,icon="Interface\\Icons\\Trade_BlackSmithing"},
  raid_lkh_araxxna={id="raid_lkh_araxxna",name="Lower Karazhan Halls: Brood Queen Araxxna",desc="Defeat Brood Queen Araxxna",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_MonsterSpiderCarapace_01"},
  raid_lkh_grizikil={id="raid_lkh_grizikil",name="Lower Karazhan Halls: Grizikil",desc="Defeat Grizikil",category="Raids",points=30,icon="Interface\\Icons\\Spell_Nature_LightningShield"},
  raid_lkh_howlfang={id="raid_lkh_howlfang",name="Lower Karazhan Halls: Clawlord Howlfang",desc="Defeat Clawlord Howlfang",category="Raids",points=30,icon="Interface\\Icons\\Ability_Druid_Mangle2"},
  raid_lkh_blackwald={id="raid_lkh_blackwald",name="Lower Karazhan Halls: Lord Blackwald II",desc="Defeat Lord Blackwald II",category="Raids",points=35,icon="Interface\\Icons\\Spell_Shadow_Possession"},
  raid_lkh_moroes={id="raid_lkh_moroes",name="Lower Karazhan Halls: Moroes",desc="Defeat Moroes",category="Raids",points=50,icon="Interface\\Icons\\INV_Misc_Coin_05"},

  -- Raids - Upper Karazhan Halls (Turtle WoW)
  raid_ukh_gnarlmoon={id="raid_ukh_gnarlmoon",name="Upper Karazhan Halls: Keeper Gnarlmoon",desc="Defeat Keeper Gnarlmoon",category="Raids",points=30,icon="Interface\\Icons\\Spell_Nature_Regeneration"},
  raid_ukh_incantagos={id="raid_ukh_incantagos",name="Upper Karazhan Halls: Ley-Watcher Incantagos",desc="Defeat Ley-Watcher Incantagos",category="Raids",points=30,icon="Interface\\Icons\\Spell_Nature_Lightning"},
  raid_ukh_anomalus={id="raid_ukh_anomalus",name="Upper Karazhan Halls: Anomalus",desc="Defeat Anomalus",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_UnholyStrength"},
  raid_ukh_echo={id="raid_ukh_echo",name="Upper Karazhan Halls: Echo of Medivh",desc="Defeat the Echo of Medivh",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_Book_09"},
  raid_ukh_king={id="raid_ukh_king",name="Upper Karazhan Halls: King",desc="Win the Chess Battle",category="Raids",points=25,icon="Interface\\Icons\\INV_Crown_01"},
  raid_ukh_sanvtas={id="raid_ukh_sanvtas",name="Upper Karazhan Halls: Sanv Tas'dal",desc="Defeat Sanv Tas'dal",category="Raids",points=35,icon="Interface\\Icons\\Spell_Shadow_Possession"},
  raid_ukh_kruul={id="raid_ukh_kruul",name="Upper Karazhan Halls: Kruul",desc="Defeat Kruul",category="Raids",points=50,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  raid_ukh_rupturan={id="raid_ukh_rupturan",name="Upper Karazhan Halls: Rupturan the Broken",desc="Defeat Rupturan the Broken",category="Raids",points=40,icon="Interface\\Icons\\Ability_Warrior_SavageBlow"},
  raid_ukh_mephistroth={id="raid_ukh_mephistroth",name="Upper Karazhan Halls: Mephistroth",desc="Defeat Mephistroth",category="Raids",points=125,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},

  -- Raid Completions (criteria-based — all bosses with checkmarks)
  raid_zg_complete={id="raid_zg_complete",name="Zul'Gurub: Raid Clear",desc="Defeat all bosses in Zul'Gurub",category="Raids",points=100,icon="Interface\\Icons\\Ability_Mount_JungleTiger",criteria_key="zg",criteria_type="raid"},
  raid_aq20_complete={id="raid_aq20_complete",name="Ruins of Ahn'Qiraj: Raid Clear",desc="Defeat all bosses in Ruins of Ahn'Qiraj",category="Raids",points=100,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_04",criteria_key="aq20",criteria_type="raid"},
  raid_mc_complete={id="raid_mc_complete",name="Molten Core: Raid Clear",desc="Defeat all bosses in Molten Core",category="Raids",points=150,icon="Interface\\Icons\\Spell_Fire_Incinerate",criteria_key="mc",criteria_type="raid"},
  raid_onyxia_complete={id="raid_onyxia_complete",name="Onyxia's Lair: Raid Clear",desc="Defeat Onyxia",category="Raids",points=75,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",criteria_key="onyxia",criteria_type="raid"},
  raid_bwl_complete={id="raid_bwl_complete",name="Blackwing Lair: Raid Clear",desc="Defeat all bosses in Blackwing Lair",category="Raids",points=175,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black",criteria_key="bwl",criteria_type="raid"},
  raid_aq40_complete={id="raid_aq40_complete",name="Temple of Ahn'Qiraj: Raid Clear",desc="Defeat all bosses in Temple of Ahn'Qiraj",category="Raids",points=200,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_05",criteria_key="aq40",criteria_type="raid"},
  raid_naxx_complete={id="raid_naxx_complete",name="Naxxramas: Raid Clear",desc="Defeat all bosses in Naxxramas",category="Raids",points=250,icon="Interface\\Icons\\INV_Misc_Key_15",criteria_key="naxx",criteria_type="raid"},
  raid_es_complete={id="raid_es_complete",name="Emerald Sanctum: Raid Clear",desc="Defeat all bosses in the Emerald Sanctum",category="Raids",points=175,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Green",criteria_key="es",criteria_type="raid"},
  raid_lkh_complete={id="raid_lkh_complete",name="Lower Karazhan Halls: Raid Clear",desc="Defeat all bosses in Lower Karazhan Halls",category="Raids",points=175,icon="Interface\\Icons\\INV_Misc_Key_14",criteria_key="lkh",criteria_type="raid"},
  raid_ukh_complete={id="raid_ukh_complete",name="Upper Karazhan Halls: Raid Clear",desc="Defeat all bosses in Upper Karazhan Halls",category="Raids",points=200,icon="Interface\\Icons\\INV_Misc_Key_15",criteria_key="ukh",criteria_type="raid"},
  
  -- Exploration
  explore_kalimdor={id="explore_kalimdor",name="Explore Kalimdor",desc="Discover all required locations across Kalimdor",category="Exploration",points=50,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_type="continent",criteria_key="kalimdor"},
  explore_eastern_kingdoms={id="explore_eastern_kingdoms",name="Explore Eastern Kingdoms",desc="Discover all required locations across Eastern Kingdoms",category="Exploration",points=50,icon="Interface\\Icons\\INV_Misc_Map_02",criteria_type="continent",criteria_key="eastern_kingdoms"},

  -- Turtle WoW: Unique zone-group exploration achievements
  explore_tw_balor={id="explore_tw_balor",name="Explorer of Balor",desc="Discover all 6 locations in Balor.",category="Exploration",points=25,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_key="balor",criteria_type="zone_group"},
  explore_tw_gilneas={id="explore_tw_gilneas",name="Explorer of Gilneas",desc="Discover all 26 locations in Gilneas.",category="Exploration",points=75,icon="Interface\\Icons\\INV_Shield_06",criteria_key="gilneas",criteria_type="zone_group"},
  explore_tw_northwind={id="explore_tw_northwind",name="Explorer of Northwind",desc="Discover all 7 locations in Northwind.",category="Exploration",points=30,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_key="northwind",criteria_type="zone_group"},
  explore_tw_lapidis={id="explore_tw_lapidis",name="Explorer of Lapidis Isle",desc="Discover all 10 locations on Lapidis Isle.",category="Exploration",points=40,icon="Interface\\Icons\\INV_Misc_Map_02",criteria_key="lapidis",criteria_type="zone_group"},
  explore_tw_gillijim={id="explore_tw_gillijim",name="Explorer of Gillijim's Isle",desc="Discover all 16 locations on Gillijim's Isle.",category="Exploration",points=60,icon="Interface\\Icons\\INV_Misc_Map_02",criteria_key="gillijim",criteria_type="zone_group"},
  explore_tw_scarlet_enclave={id="explore_tw_scarlet_enclave",name="Explorer of the Scarlet Enclave",desc="Discover all 6 locations in the Scarlet Enclave.",category="Exploration",points=25,icon="Interface\\Icons\\Spell_Holy_PowerWordShield",criteria_key="scarlet_enclave",criteria_type="zone_group"},
  explore_tw_grim_reaches={id="explore_tw_grim_reaches",name="Explorer of the Grim Reaches",desc="Discover all 5 locations in the Grim Reaches.",category="Exploration",points=25,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_key="grim_reaches",criteria_type="zone_group"},
  explore_tw_telabim={id="explore_tw_telabim",name="Explorer of Tel'Abim",desc="Discover all 8 locations on Tel'Abim.",category="Exploration",points=35,icon="Interface\\Icons\\INV_Misc_Map_02",criteria_key="telabim",criteria_type="zone_group"},
  explore_tw_hyjal={id="explore_tw_hyjal",name="Explorer of Hyjal",desc="Discover all 10 locations in Hyjal.",category="Exploration",points=40,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Green",criteria_key="hyjal",criteria_type="zone_group"},
  explore_tw_tirisfal_uplands={id="explore_tw_tirisfal_uplands",name="Explorer of Tirisfal Uplands",desc="Discover all 14 locations in the Tirisfal Uplands.",category="Exploration",points=50,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_key="tirisfal_uplands",criteria_type="zone_group"},
  -- Turtle WoW: vanilla zone additions
  explore_tw_stonetalon={id="explore_tw_stonetalon",name="Stonetalon Pathfinder",desc="Discover 7 new Turtle WoW locations in Stonetalon Mountains.",category="Exploration",points=30,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_key="stonetalon_tw",criteria_type="zone_group"},
  explore_tw_arathi={id="explore_tw_arathi",name="Arathi Pathfinder",desc="Discover 5 new Turtle WoW locations in the Arathi Highlands.",category="Exploration",points=25,icon="Interface\\Icons\\INV_Misc_Map_02",criteria_key="arathi_tw",criteria_type="zone_group"},
  explore_tw_badlands={id="explore_tw_badlands",name="Badlands Pathfinder",desc="Discover 7 new Turtle WoW locations in the Badlands.",category="Exploration",points=30,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_key="badlands_tw",criteria_type="zone_group"},
  explore_tw_ashenvale={id="explore_tw_ashenvale",name="Ashenvale Pathfinder",desc="Discover 5 new Turtle WoW locations in Ashenvale.",category="Exploration",points=25,icon="Interface\\Icons\\INV_Misc_Map_01",criteria_key="ashenvale_tw",criteria_type="zone_group"},
  
  -- PvP
  pvp_hk_100={id="pvp_hk_100",name="Soldier",desc="Earn 100 honorable kills",category="PvP",points=10,icon="Interface\\Icons\\INV_Sword_27"},
  pvp_hk_1000={id="pvp_hk_1000",name="Gladiator",desc="Earn 1000 honorable kills",category="PvP",points=50,icon="Interface\\Icons\\INV_Sword_48"},
  pvp_hk_5000={id="pvp_hk_5000",name="Warlord",desc="Earn 5000 honorable kills",category="PvP",points=100,icon="Interface\\Icons\\INV_Sword_62"},
  pvp_hk_10000={id="pvp_hk_10000",name="High Warlord",desc="Earn 10000 honorable kills",category="PvP",points=200,icon="Interface\\Icons\\INV_Sword_39"},
  pvp_duel_10={id="pvp_duel_10",name="Duelist",desc="Win 10 duels",category="PvP",points=10,icon="Interface\\Icons\\Ability_Dualwield"},
  pvp_duel_50={id="pvp_duel_50",name="Master Duelist",desc="Win 50 duels",category="PvP",points=25,icon="Interface\\Icons\\INV_Sword_39"},
  pvp_duel_100={id="pvp_duel_100",name="Grand Duelist",desc="Win 100 duels",category="PvP",points=50,icon="Interface\\Icons\\INV_Sword_62"},
  pvp_hk_50={id="pvp_hk_50",name="Skirmisher",desc="Earn 50 honorable kills",category="PvP",points=10,icon="Interface\\Icons\\INV_Sword_27"},
  pvp_hk_2500={id="pvp_hk_2500",name="Battle-Hardened",desc="Earn 2500 honorable kills",category="PvP",points=75,icon="Interface\\Icons\\INV_Sword_48"},
  pvp_duel_25={id="pvp_duel_25",name="Dueling Champion",desc="Win 25 duels",category="PvP",points=35,icon="Interface\\Icons\\INV_Sword_39"},
  
  -- Elite Achievements
  elite_rag_5x={id="elite_rag_5x",name="Molten Core Veteran",desc="Defeat Ragnaros 5 times",category="Elite",points=150,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_nef_5x={id="elite_nef_5x",name="Blackwing Veteran",desc="Defeat Nefarian 5 times",category="Elite",points=200,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_kt_3x={id="elite_kt_3x",name="Scourge Slayer",desc="Defeat Kel'Thuzad 3 times",category="Elite",points=300,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_ironman={id="elite_ironman",name="Ironman",desc="Reach level 60 without dying (tracked from addon install)",category="Elite",points=500,icon="Interface\\Icons\\INV_Helmet_74"},
  elite_rag_10x={id="elite_rag_10x",name="Flame Conqueror",desc="Defeat Ragnaros 10 times",category="Elite",points=250,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  elite_nef_10x={id="elite_nef_10x",name="Blackwing Conqueror",desc="Defeat Nefarian 10 times",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  elite_cthun_5x={id="elite_cthun_5x",name="Ahn'Qiraj Conqueror",desc="Defeat C'Thun 5 times",category="Elite",points=400,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  elite_kt_5x={id="elite_kt_5x",name="Frost Conqueror",desc="Defeat Kel'Thuzad 5 times",category="Elite",points=500,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},
  elite_drakkisath_5x={id="elite_drakkisath_5x",name="Blackrock Champion",desc="Defeat General Drakkisath 5 times",category="Elite",points=200,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  elite_gandling_5x={id="elite_gandling_5x",name="Necromancer's Bane",desc="Defeat Darkmaster Gandling 5 times",category="Elite",points=200,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  elite_baron_5x={id="elite_baron_5x",name="Baron's Nemesis",desc="Defeat Baron Rivendare 5 times",category="Elite",points=200,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
  elite_100_bosses={id="elite_100_bosses",name="Centurion Slayer",desc="Kill 100 total bosses",category="Elite",points=150,icon="Interface\\Icons\\INV_Misc_Trophy_03"},
  elite_250_bosses={id="elite_250_bosses",name="Elite Slayer",desc="Kill 250 total bosses",category="Elite",points=200,icon="Interface\\Icons\\INV_Misc_Trophy_03"},
  elite_500_bosses={id="elite_500_bosses",name="Champion Slayer",desc="Kill 500 total bosses",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Trophy_03"},
  elite_50_dungeons={id="elite_50_dungeons",name="Dungeon Crawler",desc="Complete 50 dungeon runs",category="Elite",points=150,icon="Interface\\Icons\\INV_Misc_Key_14"},
  elite_100_dungeons={id="elite_100_dungeons",name="Dungeon Veteran",desc="Complete 100 dungeon runs",category="Elite",points=250,icon="Interface\\Icons\\INV_Misc_Key_15"},
  elite_25_raids={id="elite_25_raids",name="Raid Initiate",desc="Complete 25 raid runs",category="Elite",points=200,icon="Interface\\Icons\\INV_Misc_Ribbon_01"},
  elite_50_raids={id="elite_50_raids",name="Raid Regular",desc="Complete 50 raid runs",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Ribbon_01"},
  elite_onyxia_5x={id="elite_onyxia_5x",name="Dragonbane",desc="Defeat Onyxia 5 times",category="Elite",points=200,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  elite_onyxia_10x={id="elite_onyxia_10x",name="Dragon Slayer Supreme",desc="Defeat Onyxia 10 times",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  elite_hakkar_5x={id="elite_hakkar_5x",name="Soulflayer's End",desc="Defeat Hakkar 5 times",category="Elite",points=200,icon="Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk"},
  elite_all_raids_complete={id="elite_all_raids_complete",name="Raid Completionist",desc="Complete every Classic raid at least once",category="Elite",points=500,icon="Interface\\Icons\\Spell_Holy_BorrowedTime",criteria_type="raid_meta"},
  elite_all_dungeons_complete={id="elite_all_dungeons_complete",name="Dungeon Completionist",desc="Complete every Classic 5-man dungeon at least once",category="Elite",points=400,icon="Interface\\Icons\\INV_Chest_Cloth_17",criteria_type="dungeon_meta"},
  elite_pvp_rank_14={id="elite_pvp_rank_14",name="Grand Marshal",desc="Achieve PvP Rank 14",category="Elite",points=1000,icon="Interface\\Icons\\INV_Sword_39"},
  elite_25_unique_bosses={id="elite_25_unique_bosses",name="Boss Explorer",desc="Kill 25 unique bosses",category="Elite",points=200,icon="Interface\\Icons\\Ability_Warrior_DefensiveStance"},
  elite_50_unique_bosses={id="elite_50_unique_bosses",name="Boss Hunter",desc="Kill 50 unique bosses",category="Elite",points=300,icon="Interface\\Icons\\Spell_Holy_FlashHeal"},
  
  -- Casual Achievements
  casual_mount_60={id="casual_mount_60",name="First Mount",desc="Obtain your first mount at level 40",category="Casual",points=10,icon="Interface\\Icons\\Ability_Mount_Raptor"},
  casual_epic_mount={id="casual_epic_mount",name="Epic Mount",desc="Obtain an epic mount",category="Casual",points=25,icon="Interface\\Icons\\Ability_Mount_WhiteTiger"},
  casual_pet_collector={id="casual_pet_collector",name="Pet Collector",desc="Collect 10 vanity pets",category="Casual",points=15,icon="Interface\\Icons\\INV_Box_PetCarrier_01"},
  casual_pet_fanatic={id="casual_pet_fanatic",name="Pet Fanatic",desc="Collect 25 vanity pets",category="Casual",points=30,icon="Interface\\Icons\\INV_Box_PetCarrier_01"},
  casual_explore_barrens={id="casual_explore_barrens",name="Barrens Explorer",desc="Explore all of The Barrens",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Map_01"},
  casual_explore_elwynn={id="casual_explore_elwynn",name="Elwynn Explorer",desc="Explore all of Elwynn Forest",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Map_02"},
  casual_deaths_100={id="casual_deaths_100",name="Death's Door",desc="Die 100 times",category="Casual",points=5,icon="Interface\\Icons\\Spell_Shadow_DeathScream"},
  casual_hearthstone_use={id="casual_hearthstone_use",name="Frequent Traveler",desc="Use your hearthstone 50 times",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Rune_01"},
  casual_fish_100={id="casual_fish_100",name="Angler",desc="Catch 100 fish",category="Casual",points=10,icon="Interface\\Icons\\Trade_Fishing"},
  casual_fish_1000={id="casual_fish_1000",name="Master Angler",desc="Catch 1000 fish",category="Casual",points=25,icon="Interface\\Icons\\Trade_Fishing"},
  casual_quest_100={id="casual_quest_100",name="Quest Starter",desc="Complete 100 quests",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Note_06"},
  casual_quest_500={id="casual_quest_500",name="Quest Master",desc="Complete 500 quests",category="Casual",points=25,icon="Interface\\Icons\\INV_Misc_Note_06"},
  casual_quest_1000={id="casual_quest_1000",name="Loremaster",desc="Complete 1000 quests",category="Casual",points=50,icon="Interface\\Icons\\INV_Misc_Book_09"},
  casual_emote_25={id="casual_emote_25",name="Emotive",desc="Use 25 emotes on other players",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Toy_07"},
  casual_guild_join={id="casual_guild_join",name="Guild Member",desc="Join a guild",category="Casual",points=5,icon="Interface\\Icons\\INV_Shirt_GuildTabard_01"},
  casual_party_join={id="casual_party_join",name="Team Player",desc="Join 50 groups",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_GroupNeedMore"},
  casual_emote_100={id="casual_emote_100",name="Chatterbox",desc="Use 100 emotes on other players",category="Casual",points=10,icon="Interface\\Icons\\INV_Letter_15"},
  casual_hearthstone_1={id="casual_hearthstone_1",name="Home Is Where the Hearth Is",desc="Use your hearthstone for the first time",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Coin_01"},
  casual_hearthstone_100={id="casual_hearthstone_100",name="Seasoned Traveler",desc="Use your hearthstone 100 times",category="Casual",points=20,icon="Interface\\Icons\\INV_Misc_Coin_05"},
  casual_deaths_10={id="casual_deaths_10",name="First Casualty",desc="Die 10 times",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Toy_08"},
  casual_deaths_50={id="casual_deaths_50",name="Danger Seeker",desc="Die 50 times",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Spyglass_03"},
  casual_fall_death={id="casual_fall_death",name="Falling Star",desc="Die from falling 10 times",category="Casual",points=5,icon="Interface\\Icons\\Ability_Rogue_FeintedStrike"},
  casual_drown={id="casual_drown",name="Landlubber",desc="Drown 10 times",category="Casual",points=5,icon="Interface\\Icons\\Spell_Frost_SummonWaterElemental_2"},
  casual_fish_25={id="casual_fish_25",name="Weekend Angler",desc="Catch 25 fish",category="Casual",points=5,icon="Interface\\Icons\\Trade_BlackSmithing"},
  casual_bank_full={id="casual_bank_full",name="Pack Rat",desc="Fill your bank completely",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Bag_22"},
  -- Leveling extras (from KAM)
  -- Death extras (from KAM)
  casual_deaths_5={id="casual_deaths_5",name="First Steps to Death",desc="Die 5 times",category="Casual",points=3,icon="Interface\\Icons\\Spell_Shadow_DeathScream"},
  casual_deaths_25={id="casual_deaths_25",name="Quarter Century of Defeats",desc="Die 25 times",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Spyglass_03"},

  -- Tiered kill count achievements
  kills_100={id="kills_100",name="Hundred Slayer",desc="Kill 100 mobs",category="Kills",points=10,icon="Interface\\Icons\\Ability_Warrior_Rampage"},
  kills_500={id="kills_500",name="Five Hundred Club",desc="Kill 500 mobs",category="Kills",points=25,icon="Interface\\Icons\\Ability_Warrior_Rampage"},
  kills_1000={id="kills_1000",name="Thousand Slayer",desc="Kill 1000 mobs",category="Kills",points=50,icon="Interface\\Icons\\Ability_Warrior_Rampage"},
  kills_2500={id="kills_2500",name="Bloodsoaked",desc="Kill 2500 mobs",category="Kills",points=75,icon="Interface\\Icons\\Ability_Warrior_Rampage"},
  kills_5000={id="kills_5000",name="Death Incarnate",desc="Kill 5000 mobs",category="Kills",points=100,icon="Interface\\Icons\\Ability_Warrior_Rampage"},
  kills_10000={id="kills_10000",name="Annihilator",desc="Kill 10000 mobs",category="Kills",points=200,icon="Interface\\Icons\\Ability_Warrior_Rampage"},

  -- Tiered zone-exploration achievements (count of unique subzones discovered)
  explore_zones_10={id="explore_zones_10",name="Wanderer",desc="Discover any 10 counted subzones (Kalimdor or Eastern Kingdoms)",category="Exploration",points=5,icon="Interface\\Icons\\INV_Misc_Map_01"},
  explore_zones_25={id="explore_zones_25",name="Traveler",desc="Discover 25 unique subzones",category="Exploration",points=10,icon="Interface\\Icons\\INV_Misc_Map_01"},
  explore_zones_50={id="explore_zones_50",name="Pathfinder",desc="Discover 50 unique subzones",category="Exploration",points=20,icon="Interface\\Icons\\INV_Misc_Map_02"},
  explore_zones_100={id="explore_zones_100",name="World Explorer",desc="Complete Explore Kalimdor, Explore Eastern Kingdoms, and all Turtle WoW zone achievements",category="Exploration",points=100,icon="Interface\\Icons\\INV_Misc_Map_02",criteria_type="world_explorer_meta"},

  -- Additional PvP milestones (trackable via existing HK/duel counters)
  pvp_hk_250={id="pvp_hk_250",name="Veteran Combatant",desc="Earn 250 honorable kills",category="PvP",points=20,icon="Interface\\Icons\\INV_Sword_27"},
  pvp_duel_75={id="pvp_duel_75",name="Seasoned Duelist",desc="Win 75 duels",category="PvP",points=35,icon="Interface\\Icons\\INV_Sword_39"},
  pvp_wsg_flag_return={id="pvp_wsg_flag_return",name="Flag Defender",desc="Visit Warsong Gulch 10 times",category="PvP",points=20,icon="Interface\\Icons\\INV_Banner_02"},

  -- Additional casual milestones (trackable via existing counters)
  casual_deaths_200={id="casual_deaths_200",name="Hardened by Death",desc="Die 200 times",category="Casual",points=10,icon="Interface\\Icons\\Spell_Shadow_DeathScream"},
  casual_fish_50={id="casual_fish_50",name="Fisher",desc="Catch 50 fish",category="Casual",points=8,icon="Interface\\Icons\\Trade_Fishing"},
  casual_fish_250={id="casual_fish_250",name="Seasoned Angler",desc="Catch 250 fish",category="Casual",points=15,icon="Interface\\Icons\\Trade_Fishing"},
  casual_fish_500={id="casual_fish_500",name="Expert Angler",desc="Catch 500 fish",category="Casual",points=20,icon="Interface\\Icons\\Trade_Fishing"},
  casual_emote_500={id="casual_emote_500",name="Social Butterfly",desc="Use 500 emotes",category="Casual",points=20,icon="Interface\\Icons\\INV_Misc_Toy_07"},
  casual_quest_250={id="casual_quest_250",name="Quest Veteran",desc="Complete 250 quests",category="Casual",points=15,icon="Interface\\Icons\\INV_Misc_Note_06"},
  casual_quest_750={id="casual_quest_750",name="Quest Expert",desc="Complete 750 quests",category="Casual",points=30,icon="Interface\\Icons\\INV_Misc_Book_09"},
  casual_ah_sell={id="casual_ah_sell",name="Market Trader",desc="Visit the Auction House 10 times",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Coin_05"},
  casual_friend_emote={id="casual_friend_emote",name="Life of the Party",desc="Use 50 emotes",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Toy_07"},

  -- Elite achievements referenced by titles (now properly defined)
  elite_flawless_kt={id="elite_flawless_kt",name="Flawless Frost",desc="Defeat Kel'Thuzad without any raid deaths",category="Elite",points=750,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},
  elite_no_wipe_naxx={id="elite_no_wipe_naxx",name="Naxxramas Perfected",desc="Complete Naxxramas without a raid wipe",category="Elite",points=600,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
  elite_naked_rag={id="elite_naked_rag",name="Barely Geared",desc="Defeat Ragnaros with an average item level below 50",category="Elite",points=500,icon="Interface\\Icons\\INV_Chest_Cloth_17"},
  elite_flawless_cthun={id="elite_flawless_cthun",name="Eye of Perfection",desc="Defeat C'Thun without any raid deaths",category="Elite",points=750,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  elite_naxx_speedrun={id="elite_naxx_speedrun",name="Naxx Speed Clear",desc="Clear Naxxramas in under 3 hours",category="Elite",points=600,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_mc_speedrun={id="elite_mc_speedrun",name="Molten Rush",desc="Clear Molten Core in under 90 minutes",category="Elite",points=400,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_no_wipe_bwl={id="elite_no_wipe_bwl",name="Blackwing Perfected",desc="Clear Blackwing Lair without a single wipe",category="Elite",points=500,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  elite_flawless_nef={id="elite_flawless_nef",name="Nefarian's End",desc="Defeat Nefarian without any raid deaths",category="Elite",points=600,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  elite_flawless_rag={id="elite_flawless_rag",name="Flawless Firelord",desc="Defeat Ragnaros without any raid deaths",category="Elite",points=600,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  elite_guild_first_mc={id="elite_guild_first_mc",name="First Flames",desc="Participate in the guild's first Molten Core clear",category="Elite",points=300,icon="Interface\\Icons\\Spell_Fire_Incinerate"},
  elite_guild_first_naxx={id="elite_guild_first_naxx",name="Naxx Pioneers",desc="Participate in the guild's first Naxxramas clear",category="Elite",points=500,icon="Interface\\Icons\\INV_Misc_Key_15"},
  elite_undergeared_rag={id="elite_undergeared_rag",name="Rag Under Pressure",desc="Defeat Ragnaros with no player in tier 2 or higher",category="Elite",points=500,icon="Interface\\Icons\\INV_Chest_Cloth_17"},
  elite_resource_solo={id="elite_resource_solo",name="Self-Sufficient",desc="Reach 300 in two professions using only self-gathered materials",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  elite_all_raids_one_week={id="elite_all_raids_one_week",name="Raid Week",desc="Complete all available raids within one week",category="Elite",points=500,icon="Interface\\Icons\\Spell_Holy_BorrowedTime"},
  elite_no_consumables_rag={id="elite_no_consumables_rag",name="Pure Skill",desc="Defeat Ragnaros without using any consumables",category="Elite",points=500,icon="Interface\\Icons\\INV_Potion_54"},
  elite_tank_solo_5man={id="elite_tank_solo_5man",name="Fortress",desc="Tank a 5-man dungeon from start to finish without a wipe",category="Elite",points=200,icon="Interface\\Icons\\Ability_Warrior_DefensiveStance"},
  elite_heal_no_death={id="elite_heal_no_death",name="Perfect Restoration",desc="Heal a full dungeon run with zero player deaths",category="Elite",points=200,icon="Interface\\Icons\\Spell_Holy_FlashHeal"},
  elite_solo_ubrs={id="elite_solo_ubrs",name="Spire Solo",desc="Complete Upper Blackrock Spire solo",category="Elite",points=400,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  elite_solo_strat={id="elite_solo_strat",name="Stratholme Solo",desc="Complete Stratholme solo",category="Elite",points=400,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
}

local TITLES = {
  -- Leveling Titles
  {id="title_champion",name="Champion",achievement="lvl_60",prefix=false,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength",category="Leveling"},
  {id="title_elder",name="the Elder",achievement="lvl_60",prefix=false,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength",category="Leveling"},
  
  -- Molten Core Titles
  {id="title_firelord",name="Firelord",achievement="raid_mc_ragnaros",prefix=false,icon="Interface\\Icons\\Spell_Fire_LavaSpawn",category="Raids"},
  {id="title_flamewaker",name="Flamewaker",achievement="raid_mc_sulfuron",prefix=false,icon="Interface\\Icons\\Spell_Fire_FireArmor",category="Raids"},
  {id="title_core_hound",name="Core Hound",achievement="raid_mc_magmadar",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",category="Raids"},
  {id="title_molten_destroyer",name="Molten Destroyer",achievement="raid_mc_golemagg",prefix=false,icon="Interface\\Icons\\INV_Misc_MonsterScales_15",category="Raids"},
  
  -- Onyxia/Dragons
  {id="title_dragonslayer",name="Dragonslayer",achievement="raid_onyxia",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",category="Raids"},
  {id="title_dragon_hunter",name="Dragon Hunter",achievement="raid_onyxia",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",category="Raids"},
  
  -- Blackwing Lair Titles
  {id="title_blackwing_slayer",name="Blackwing Slayer",achievement="raid_bwl_nefarian",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black",category="Raids"},
  {id="title_dragonkin_slayer",name="Dragonkin Slayer",achievement="raid_bwl_razorgore",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black",category="Raids"},
  {id="title_chromatic",name="the Chromatic",achievement="raid_bwl_chromaggus",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Bronze",category="Raids"},
  {id="title_vaels_bane",name="Vael's Bane",achievement="raid_bwl_vaelastrasz",prefix=false,icon="Interface\\Icons\\Spell_Shadow_ShadowWordDominate",category="Raids"},
  {id="title_broodlord_slayer",name="Broodlord Slayer",achievement="raid_bwl_broodlord",prefix=false,icon="Interface\\Icons\\INV_Bracer_18",category="Raids"},
  
  -- Zul'Gurub Titles
  {id="title_zandalar",name="of Zandalar",achievement="raid_zg_hakkar",prefix=false,icon="Interface\\Icons\\Spell_Shadow_PainSpike",category="Raids"},
  {id="title_bloodlord",name="Bloodlord",achievement="raid_zg_hakkar",prefix=false,icon="Interface\\Icons\\Spell_Shadow_PainSpike",category="Raids"},
  {id="title_troll_slayer",name="Troll Slayer",achievement="raid_zg_thekal",prefix=false,icon="Interface\\Icons\\Ability_Druid_Mangle2",category="Raids"},
  {id="title_snake_handler",name="Snake Handler",achievement="raid_zg_venoxis",prefix=false,icon="Interface\\Icons\\Spell_Nature_NullifyPoison",category="Raids"},
  
  -- AQ20 Titles
  {id="title_silithid_slayer",name="Silithid Slayer",achievement="raid_aq20_ossirian",prefix=false,icon="Interface\\Icons\\INV_Qiraj_JewelGlowing",category="Raids"},
  {id="title_scarab_hunter",name="Scarab Hunter",achievement="raid_aq20_kurinnaxx",prefix=false,icon="Interface\\Icons\\INV_Qiraj_JewelBlessed",category="Raids"},
  
  -- AQ40 Titles
  {id="title_scarab_lord",name="Scarab Lord",achievement="raid_aq40_cthun",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm",category="Raids"},
  {id="title_qiraji_slayer",name="Qiraji Slayer",achievement="raid_aq40_cthun",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm",category="Raids"},
  {id="title_bug_squasher",name="Bug Squasher",achievement="raid_aq40_bug_trio",prefix=false,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_02",category="Raids"},
  {id="title_twin_emperor",name="Twin Emperor",achievement="raid_aq40_twins",prefix=false,icon="Interface\\Icons\\INV_Jewelry_Ring_AhnQiraj_04",category="Raids"},
  {id="title_viscidus_slayer",name="Viscidus Slayer",achievement="raid_aq40_viscidus",prefix=false,icon="Interface\\Icons\\Spell_Nature_Acid_01",category="Raids"},
  {id="title_the_prophet",name="the Prophet",achievement="raid_aq40_skeram",prefix=false,icon="Interface\\Icons\\Spell_Shadow_MindSteal",category="Raids"},
  
  -- Naxxramas Titles
  {id="title_death_demise",name="of the Ashen Verdict",achievement="raid_naxx_kelthuzad",prefix=false,icon="Interface\\Icons\\Spell_Shadow_SoulGem",category="Raids"},
  {id="title_immortal",name="the Immortal",achievement="elite_flawless_kt",prefix=false,icon="Interface\\Icons\\Spell_Holy_DivineIntervention",category="Elite"},
  {id="title_undying",name="the Undying",achievement="elite_no_wipe_naxx",prefix=false,icon="Interface\\Icons\\Spell_Shadow_RaiseDead",category="Elite"},
  {id="title_patient",name="the Patient",achievement="elite_no_wipe_naxx",prefix=false,icon="Interface\\Icons\\Spell_Nature_TimeStop",category="Elite"},
  {id="title_lich_hunter",name="Lich Hunter",achievement="raid_naxx_kelthuzad",prefix=false,icon="Interface\\Icons\\Spell_Shadow_SoulGem",category="Raids"},
  {id="title_plaguebearer",name="Plaguebearer",achievement="raid_naxx_loatheb",prefix=false,icon="Interface\\Icons\\Spell_Shadow_CallofBone",category="Raids"},
  {id="title_spore_bane",name="Spore Bane",achievement="raid_naxx_loatheb",prefix=false,icon="Interface\\Icons\\Spell_Shadow_CallofBone",category="Raids"},
  {id="title_frost_wyrm",name="Frost Wyrm Slayer",achievement="raid_naxx_sapphiron",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Blue",category="Raids"},
  {id="title_arachnid_slayer",name="Arachnid Slayer",achievement="raid_naxx_maexxna",prefix=false,icon="Interface\\Icons\\INV_Misc_MonsterSpiderCarapace_01",category="Raids"},
  {id="title_four_horsemen",name="of the Four Horsemen",achievement="raid_naxx_four_horsemen",prefix=false,icon="Interface\\Icons\\Spell_DeathKnight_ClassIcon",category="Raids"},
  {id="title_death_knight",name="Death Knight",achievement="raid_naxx_four_horsemen",prefix=false,icon="Interface\\Icons\\Spell_DeathKnight_ClassIcon",category="Raids"},
  
  -- Elite Raid Titles
  {id="title_insane",name="the Insane",achievement="elite_naked_rag",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm",category="Elite"},
  {id="title_flawless",name="the Flawless",achievement="elite_flawless_cthun",prefix=false,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength",category="Elite"},
  {id="title_speed_demon",name="Speed Demon",achievement="elite_naxx_speedrun",prefix=false,icon="Interface\\Icons\\Spell_Fire_BurningSpeed",category="Elite"},
  {id="title_speed_runner",name="the Speed Runner",achievement="elite_mc_speedrun",prefix=false,icon="Interface\\Icons\\Spell_Fire_BurningSpeed",category="Elite"},
  {id="title_unstoppable",name="the Unstoppable",achievement="elite_no_wipe_bwl",prefix=false,icon="Interface\\Icons\\INV_Misc_Ribbon_01",category="Elite"},
  {id="title_perfect",name="the Perfect",achievement="elite_flawless_nef",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black",category="Elite"},
  {id="title_flawless_firelord",name="Flawless Firelord",achievement="elite_flawless_rag",prefix=false,icon="Interface\\Icons\\Spell_Fire_LavaSpawn",category="Elite"},
  {id="title_untouchable",name="the Untouchable",achievement="elite_flawless_kt",prefix=false,icon="Interface\\Icons\\Spell_Shadow_SoulGem",category="Elite"},
  
  -- Elite Achievement Titles
  {id="title_ironman",name="the Ironman",achievement="elite_ironman",prefix=false,icon="Interface\\Icons\\INV_Helmet_74",category="Elite"},
  {id="title_guild_pioneer",name="Guild Pioneer",achievement="elite_guild_first_mc",prefix=false,icon="Interface\\Icons\\INV_Misc_Trophy_03",category="Elite"},
  {id="title_legendary",name="the Legendary",achievement="elite_guild_first_naxx",prefix=false,icon="Interface\\Icons\\INV_Misc_Trophy_03",category="Elite"},
  {id="title_undergeared",name="the Undergeared",achievement="elite_undergeared_rag",prefix=false,icon="Interface\\Icons\\INV_Chest_Cloth_17",category="Elite"},
  {id="title_self_made",name="the Self-Made",achievement="elite_resource_solo",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17",category="Elite"},
  {id="title_raid_marathon",name="Raid Marathoner",achievement="elite_all_raids_one_week",prefix=false,icon="Interface\\Icons\\Spell_Holy_BorrowedTime",category="Elite"},
  {id="title_purist",name="the Purist",achievement="elite_no_consumables_rag",prefix=false,icon="Interface\\Icons\\INV_Potion_54",category="Elite"},
  {id="title_one_man_army",name="One Man Army",achievement="elite_tank_solo_5man",prefix=false,icon="Interface\\Icons\\Ability_Warrior_DefensiveStance",category="Elite"},
  {id="title_perfect_healer",name="Perfect Healer",achievement="elite_heal_no_death",prefix=false,icon="Interface\\Icons\\Spell_Holy_FlashHeal",category="Elite"},
  {id="title_solo_hero",name="Solo Hero",achievement="elite_solo_ubrs",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",category="Elite"},
  {id="title_death_defier",name="Death Defier",achievement="elite_solo_strat",prefix=false,icon="Interface\\Icons\\Spell_Shadow_RaiseDead",category="Elite"},
  
  -- PvP Titles
  {id="title_warlord",name="Warlord",achievement="pvp_hk_5000",prefix=false,icon="Interface\\Icons\\INV_Sword_62",category="PvP"},
  {id="title_grand_marshal",name="Grand Marshal",achievement="elite_pvp_rank_14",prefix=false,icon="Interface\\Icons\\INV_Sword_39",category="PvP"},
  {id="title_bloodthirsty",name="the Bloodthirsty",achievement="pvp_hk_10000",prefix=false,icon="Interface\\Icons\\Spell_Shadow_BloodBoil",category="PvP"},
  {id="title_arena_master",name="Arena Master",achievement="pvp_duel_100",prefix=false,icon="Interface\\Icons\\INV_Sword_62",category="PvP"},
  {id="title_gladiator",name="Gladiator",achievement="pvp_hk_1000",prefix=false,icon="Interface\\Icons\\INV_Sword_48",category="PvP"},
  {id="title_duelist",name="the Duelist",achievement="pvp_duel_50",prefix=false,icon="Interface\\Icons\\INV_Sword_39",category="PvP"},
  {id="title_high_warlord",name="High Warlord",achievement="pvp_hk_10000",prefix=false,icon="Interface\\Icons\\INV_Sword_39",category="PvP"},
  {id="title_battlemaster",name="Battlemaster",achievement="pvp_wsg_flag_return",prefix=false,icon="Interface\\Icons\\INV_Banner_02",category="PvP"},
  
  -- Profession Titles
  {id="title_master_alchemist",name="Master Alchemist",achievement="prof_alchemy_300",prefix=false,icon="Interface\\Icons\\Trade_Alchemy",category="Profession"},
  {id="title_master_blacksmith",name="Master Blacksmith",achievement="prof_blacksmithing_300",prefix=false,icon="Interface\\Icons\\Trade_BlackSmithing",category="Profession"},
  {id="title_master_enchanter",name="Master Enchanter",achievement="prof_enchanting_300",prefix=false,icon="Interface\\Icons\\Trade_Engraving",category="Profession"},
  {id="title_master_engineer",name="Master Engineer",achievement="prof_engineering_300",prefix=false,icon="Interface\\Icons\\Trade_Engineering",category="Profession"},
  {id="title_artisan",name="the Artisan",achievement="prof_dual_artisan",prefix=false,icon="Interface\\Icons\\INV_Misc_Note_06",category="Profession"},
  
  -- Casual Titles
  {id="title_explorer",name="the Explorer",achievement="explore_kalimdor",prefix=false,icon="Interface\\Icons\\INV_Misc_Map_01",category="Exploration"},
  {id="title_loremaster",name="Loremaster",achievement="casual_quest_1000",prefix=false,icon="Interface\\Icons\\INV_Misc_Book_09",category="Casual"},
  {id="title_angler",name="the Master Angler",achievement="casual_fish_1000",prefix=false,icon="Interface\\Icons\\Trade_Fishing",category="Casual"},
  {id="title_pet_collector",name="the Pet Collector",achievement="casual_pet_fanatic",prefix=false,icon="Interface\\Icons\\INV_Box_PetCarrier_01",category="Casual"},
  {id="title_merchant",name="the Merchant",achievement="casual_ah_sell",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_05",category="Casual"},
  {id="title_banker",name="the Banker",achievement="gold_5000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17",category="Gold"},
  {id="title_socialite",name="the Socialite",achievement="casual_friend_emote",prefix=false,icon="Interface\\Icons\\INV_Misc_Toy_07",category="Casual"},
  {id="title_death_prone",name="Death-Prone",achievement="casual_deaths_100",prefix=false,icon="Interface\\Icons\\Spell_Shadow_DeathScream",category="Casual"},
  {id="title_clumsy",name="the Clumsy",achievement="casual_fall_death",prefix=false,icon="Interface\\Icons\\Ability_Rogue_FeintedStrike",category="Casual"},
  
  -- Gold Titles
  {id="title_wealthy",name="the Wealthy",achievement="gold_1000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_06",category="Gold"},
  {id="title_fortune_builder",name="Fortune Builder",achievement="gold_5000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17",category="Gold"},
  {id="title_tycoon",name="the Tycoon",achievement="gold_5000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17",category="Gold"},
  
  -- Dungeon Titles (updated to new completion IDs)
  {id="title_dungeoneer",name="the Dungeoneer",achievement="dung_ubrs_complete",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",category="Dungeons"},
  {id="title_undead_slayer",name="Undead Slayer",achievement="dung_strat_complete",prefix=false,icon="Interface\\Icons\\Spell_Shadow_RaiseDead",category="Dungeons"},
  {id="title_shadow_hunter",name="Shadow Hunter",achievement="dung_scholo_complete",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm",category="Dungeons"},
  {id="title_dungeon_master",name="Dungeon Master",achievement="dung_dmn_complete",prefix=false,icon="Interface\\Icons\\INV_Misc_Key_14",category="Dungeons"},

  -- New tiered kill titles (ordered by kill count; hard difficulty at higher tiers)
  {id="title_hundred_slayer",name="the Hundred Slayer",achievement="kills_100",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",difficulty="normal",category="Kills"},
  {id="title_five_hundred",name="Five Hundred Club",achievement="kills_500",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",difficulty="normal",category="Kills"},
  {id="title_thousand_slayer",name="Thousand Slayer",achievement="kills_1000",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",difficulty="normal",category="Kills"},
  {id="title_bloodsoaked",name="the Bloodsoaked",achievement="kills_2500",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",difficulty="normal",category="Kills"},
  {id="title_death_incarnate",name="Death Incarnate",achievement="kills_5000",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",difficulty="hard",category="Kills"},
  {id="title_annihilator",name="the Annihilator",achievement="kills_10000",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",difficulty="hard",category="Kills"},

  -- New exploration titles
  {id="title_wanderer",name="the Wanderer",achievement="explore_zones_10",prefix=false,icon="Interface\\Icons\\INV_Misc_Map_01",difficulty="normal",category="Exploration"},
  {id="title_world_explorer",name="World Explorer",achievement="explore_zones_100",prefix=false,icon="Interface\\Icons\\INV_Misc_Map_02",difficulty="normal",category="Exploration"},

  -- New quest chain titles
  {id="title_core_seeker",name="Core Seeker",achievement="quest_mc_attunement",prefix=false,icon="Interface\\Icons\\Spell_Fire_LavaSpawn",difficulty="normal",category="Quests"},
  {id="title_deep_diver",name="Deep Diver",achievement="quest_princess_theradras",prefix=false,icon="Interface\\Icons\\INV_Misc_Root_02",difficulty="normal",category="Quests"},

  -- New hard/elite titles
  {id="title_raid_conqueror",name="Raid Conqueror",achievement="elite_all_raids_complete",prefix=false,icon="Interface\\Icons\\Spell_Holy_BorrowedTime",difficulty="hard",category="Elite"},
  {id="title_dungeon_conqueror",name="Dungeon Conqueror",achievement="elite_all_dungeons_complete",prefix=false,icon="Interface\\Icons\\INV_Chest_Cloth_17",difficulty="hard",category="Elite"},

  -- PvP titles for existing trackable achievements
  {id="title_skirmisher",name="Skirmisher",achievement="pvp_hk_50",prefix=false,icon="Interface\\Icons\\INV_Sword_04",category="PvP"},
  {id="title_soldier",name="Soldier",achievement="pvp_hk_100",prefix=false,icon="Interface\\Icons\\INV_Sword_27",category="PvP"},
  {id="title_battle_hardened",name="the Battle-Hardened",achievement="pvp_hk_2500",prefix=false,icon="Interface\\Icons\\INV_Sword_48",category="PvP"},
  {id="title_veteran_combatant",name="Veteran Combatant",achievement="pvp_hk_250",prefix=false,icon="Interface\\Icons\\INV_Sword_27",category="PvP"},
  {id="title_dueler",name="the Dueler",achievement="pvp_duel_10",prefix=false,icon="Interface\\Icons\\Ability_Dualwield",category="PvP"},
  {id="title_dueling_champion",name="Dueling Champion",achievement="pvp_duel_25",prefix=false,icon="Interface\\Icons\\INV_Sword_39",category="PvP"},
  {id="title_master_duelist2",name="Master Duelist",achievement="pvp_duel_75",prefix=false,icon="Interface\\Icons\\INV_Sword_39",category="PvP"},
  {id="title_flag_defender",name="Flag Defender",achievement="pvp_wsg_flag_return",prefix=false,icon="Interface\\Icons\\INV_Banner_02",category="PvP"},

  -- Exploration titles for existing trackable achievements
  {id="title_kingdom_explorer",name="Kingdom Explorer",achievement="explore_eastern_kingdoms",prefix=false,icon="Interface\\Icons\\INV_Misc_Map_02",category="Exploration"},
  {id="title_pathfinder",name="Pathfinder",achievement="explore_zones_25",prefix=false,icon="Interface\\Icons\\INV_Misc_Map_01",category="Exploration"},
  {id="title_adventurer",name="the Adventurer",achievement="explore_zones_50",prefix=false,icon="Interface\\Icons\\INV_Misc_Map_02",category="Exploration"},

  -- Casual titles for existing trackable achievements
  {id="title_fisherman",name="the Fisherman",achievement="casual_fish_100",prefix=false,icon="Interface\\Icons\\Trade_Fishing",category="Casual"},
  {id="title_master_fisher",name="Master Fisher",achievement="casual_fish_1000",prefix=false,icon="Interface\\Icons\\Trade_Fishing",category="Casual"},
  {id="title_rider",name="the Rider",achievement="casual_mount_60",prefix=false,icon="Interface\\Icons\\Ability_Mount_Raptor",category="Casual"},
  {id="title_seasoned",name="the Seasoned",achievement="casual_deaths_50",prefix=false,icon="Interface\\Icons\\INV_Misc_Spyglass_03",category="Casual"},
  {id="title_traveler",name="the Traveler",achievement="casual_hearthstone_100",prefix=false,icon="Interface\\Icons\\INV_Misc_Rune_01",category="Casual"},
  {id="title_trader",name="the Trader",achievement="casual_ah_sell",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_05",category="Casual"},

  -- Raid titles for full-clear achievements
  {id="title_mc_champion",name="Champion of the Core",achievement="raid_mc_complete",prefix=false,icon="Interface\\Icons\\Spell_Fire_LavaSpawn",category="Raids"},
  {id="title_bwl_champion",name="Champion of Blackwing",achievement="raid_bwl_complete",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black",category="Raids"},
  {id="title_zg_champion",name="Champion of Zul'Gurub",achievement="raid_zg_complete",prefix=false,icon="Interface\\Icons\\Spell_Shadow_PainSpike",category="Raids"},
  {id="title_naxx_champion",name="Champion of Naxxramas",achievement="raid_naxx_complete",prefix=false,icon="Interface\\Icons\\Spell_Shadow_SoulGem",category="Raids"},
  {id="title_aq20_champion",name="Champion of Ruins",achievement="raid_aq20_complete",prefix=false,icon="Interface\\Icons\\INV_Qiraj_JewelBlessed",category="Raids"},
  {id="title_aq40_champion",name="Champion of Ahn'Qiraj",achievement="raid_aq40_complete",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm",category="Raids"},

  -- Kill titles for existing trackable kill achievements
  {id="title_combatant",name="the Combatant",achievement="kills_100",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",category="Kills"},
  {id="title_slayer",name="the Slayer",achievement="kills_1000",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",category="Kills"},
  {id="title_mass_murderer",name="Mass Murderer",achievement="kills_5000",prefix=false,icon="Interface\\Icons\\Ability_Warrior_Rampage",difficulty="hard",category="Kills"},
  {id="title_boss_hunter",name="Boss Hunter",achievement="elite_50_unique_bosses",prefix=false,icon="Interface\\Icons\\Spell_Holy_FlashHeal",category="Elite"},
  {id="title_boss_explorer",name="Boss Explorer",achievement="elite_25_unique_bosses",prefix=false,icon="Interface\\Icons\\Ability_Warrior_DefensiveStance",category="Elite"},
}

-- ==========================================
-- BOSS CRITERIA DATA (from AtlasLoot)
-- ==========================================

local DUNGEON_BOSSES = {
  rfc    = {"Taragaman the Hungerer","Oggleflint","Jergosh the Invoker","Bazzalan"},
  wc     = {"Lord Cobrahn","Lady Anacondra","Kresh","Zandara Windhoof","Lord Pythas","Skum","Vangros","Lord Serpentis","Verdan the Everliving","Mutanus the Devourer"},
  dm     = {"Jared Voss","Rhahk'Zor","Sneed","Sneed's Shredder","Gilnid","Masterpiece Harvester","Mr. Smite","Cookie","Captain Greenskin","Edwin VanCleef"},
  sfk    = {"Rethilgore","Fel Steed","Razorclaw the Butcher","Baron Silverlaine","Commander Springvale","Odo the Blindwatcher","Fenrus the Devourer","Wolf Master Nandos","Archmage Arugal","Prelate Ironmane"},
  bfd    = {"Ghamoo-ra","Lady Sarevess","Gelihast","Baron Aquanis","Velthelaxx the Defiler","Twilight Lord Kelris","Old Serra'kis","Aku'mai"},
  stocks = {"Targorr the Dread","Kam Deepfury","Hamhock","Dextren Ward","Bazil Thredd"},
  tcg    = {"Grovetender Engryss","Keeper Ranathos","High Priestess A'lathea","Fenektis the Deceiver","Master Raxxieth"},
  gnomer = {"Grubbis","Viscous Fallout","Electrocutioner 6000","Crowd Pummeler 9-60","Dark Iron Ambassador","Mekgineer Thermaplugg"},
  rfk    = {"Aggem Thorncurse","Death Speaker Jargba","Overlord Ramtusk","Agathelos the Raging","Charlga Razorflank","Rotthorn"},
  sm_gy  = {"Interrogator Vishas","Duke Dreadmoore","Bloodmage Thalnos"},
  sm_lib = {"Houndmaster Loksey","Brother Wystan","Arcanist Doan"},
  sm_arm = {"Herod","Armory Quartermaster Daghelm"},
  sm_cat = {"High Inquisitor Fairbanks","Scarlet Commander Mograine","High Inquisitor Whitemane"},
  swr    = {"Oronok Torn-Heart","Dagar the Glutton","Duke Balor the IV","Librarian Theodorus","Chieftain Stormsong","Deathlord Tidebane","Subjugator Halthas Shadecrest","Mycellakos","Eldermaw the Primordial","Lady Drazare","Mergothid"},
  rfdown = {"Tuten'kash","Plaguemaw the Rotting","Mordresh Fire Eye","Glutton","Death Prophet Rakameg","Amnennar the Coldbringer"},
  ulda   = {"Baelog","Olaf","Eric 'The Swift'","Revelosh","Ironaya","Ancient Stone Keeper","Galgann Firehammer","Grimlok","Archaedas"},
  gc     = {"Matthias Holtz","Packmaster Ragetooth","Judge Sutherland","Dustivan Blackcowl","Marshal Magnus Greystone","Horsemaster Levvin","Genn Greymane"},
  mara   = {"Noxxion","Razorlash","Lord Vyletongue","Celebras the Cursed","Landslide","Tinkerer Gizlock","Rotgrip","Princess Theradras"},
  zf     = {"Antu'sul","Witch Doctor Zum'rah","Shadowpriest Sezz'ziz","Gahz'rilla","Chief Ukorz Sandscalp","Zel'jeb the Ancient","Champion Razjal the Quick"},
  st     = {"Atal'alarion","Spawn of Hakkar","Avatar of Hakkar","Jammal'an the Prophet","Ogom the Wretched","Dreamscythe","Weaver","Morphaz","Hazzas","Shade of Eranikus"},
  hq     = {"High Foreman Bargul Blackhammer","Engineer Figgles","Corrosis","Hatereaver Annihilator","Har'gesh Doomcaller"},
  brd    = {"Lord Roccor","High Interrogator Gerstahn","Anub'shiah","Eviscerator","Gorosh the Dervish","Grizzle","Hedrum the Creeper","Ok'thor the Breaker","Theldren","Houndmaster Grebmar","Fineous Darkvire","Lord Incendius","Bael'Gar","General Angerforge","Golem Lord Argelmach","Ambassador Flamelash","Magmus","Emperor Dagran Thaurissan"},
  dme    = {"Pusillin","Zevrim Thornhoof","Hydrospawn","Lethtendris","Isalien","Alzzin the Wildshaper"},
  dmw    = {"Tendris Warpwood","Illyanna Ravenoak","Magister Kalendris","Immol'thar","Prince Tortheldrin"},
  dmn    = {"Guard Mol'dar","Stomper Kreeg","Guard Fengus","Guard Slip'kik","Captain Kromcrush","Cho'Rush the Observer","King Gordok"},
  scholo = {"Kirtonos the Herald","Jandice Barov","Rattlegore","Death Knight Darkreaver","Marduk Blackpool","Vectus","Ras Frostwhisper","Kormok","Instructor Malicia","Doctor Theolen Krastinov","Lorekeeper Polkelt","The Ravenian","Lord Alexei Barov","Lady Illucia Barov","Darkmaster Gandling"},
  strat  = {"Postmaster Malown","Fras Siabi","The Unforgiven","Timmy the Cruel","Cannon Master Willey","Archivist Galford","Balnazzar","Baroness Anastari","Nerub'enkan","Maleki the Pallid","Magistrate Barthilas","Ramstein the Gorger","Baron Rivendare"},
  lbrs   = {"Highlord Omokk","Shadow Hunter Vosh'gajin","War Master Voone","Mor Grayhoof","Mother Smolderweb","Urok Doomhowl","Quartermaster Zigris","Halycon","Gizrul the Slavener","Overlord Wyrmthalak"},
  ubrs   = {"Pyroguard Emberseer","Solakar Flamewreath","Father Flame","Warchief Rend Blackhand","Gyth","The Beast","Lord Valthalak","General Drakkisath"},
  kc     = {"Marrowspike","Hivaxxis","Corpsemuncher","Guard Captain Gort","Archlich Enkhraz","Commander Andreon","Alarus"},
  cotbm  = {"Chronar","Epidamu","Drifting Avatar of Sand","Time-Lord Epochronos","Mossheart","Rotmaw","Antnormi"},
  swv    = {"Aszosh Grimflame","Tham'Grarr","Black Bride","Damian","Volkan Cruelblade"},
  dmr    = {"Gowlfang","Cavernweb Broodmother","Web Master Torkon","Garlok Flamekeeper","Halgan Redbrand","Slagfist Destroyer","Overlord Blackheart","Elder Hollowblood","Searistrasz","Zuluhed the Whacked"},
}

local RAID_BOSSES = {
  zg     = {"High Priestess Jeklik","High Priest Venoxis","High Priestess Mar'li","Bloodlord Mandokir","Gri'lek","Hazza'rah","Renataki","Wushoolay","Gahz'ranka","High Priest Thekal","High Priestess Arlokk","Jin'do the Hexxer","Hakkar"},
  aq20   = {"Kurinnaxx","General Rajaxx","Moam","Buru the Gorger","Ayamiss the Hunter","Ossirian the Unscarred"},
  mc     = {"Incindis","Lucifron","Magmadar","Garr","Shazzrah","Baron Geddon","Golemagg the Incinerator","Basalthar","Sorcerer-Thane Thaurissan","Sulfuron Harbinger","Majordomo Executus","Ragnaros"},
  onyxia = {"Onyxia"},
  bwl    = {"Razorgore the Untamed","Vaelastrasz the Corrupt","Broodlord Lashlayer","Firemaw","Ebonroc","Flamegor","Chromaggus","Nefarian"},
  aq40   = {"The Prophet Skeram","Lord Kri","Princess Yauj","Vem","Battleguard Sartura","Fankriss the Unyielding","Viscidus","Princess Huhuran","Emperor Vek'lor","Ouro","C'Thun"},
  naxx   = {"Patchwerk","Grobbulus","Gluth","Thaddius","Anub'Rekhan","Grand Widow Faerlina","Maexxna","Noth the Plaguebringer","Heigan the Unclean","Loatheb","Instructor Razuvious","Gothik the Harvester","Highlord Mograine","Thane Korth'azz","Lady Blaumeux","Sir Zeliek","Sapphiron","Kel'Thuzad"},
  es     = {"Erennius","Solnius the Awakener"},
  lkh    = {"Master Blacksmith Rolfen","Brood Queen Araxxna","Grizikil","Clawlord Howlfang","Lord Blackwald II","Moroes"},
  ukh    = {"Keeper Gnarlmoon","Ley-Watcher Incantagos","Anomalus","Echo of Medivh","King","Sanv Tas'dal","Kruul","Rupturan the Broken","Mephistroth"},
}

-- Reverse lookup: boss name → dungeon key
local BOSS_TO_DUNGEON = {}
for dungId, bossList in pairs(DUNGEON_BOSSES) do
  for _, bossName in ipairs(bossList) do
    BOSS_TO_DUNGEON[bossName] = dungId
  end
end

-- Reverse lookup: boss name → raid key
local BOSS_TO_RAID = {}
for raidId, bossList in pairs(RAID_BOSSES) do
  for _, bossName in ipairs(bossList) do
    BOSS_TO_RAID[bossName] = raidId
  end
end

-- ==========================================
-- PUBLIC API FOR OTHER ADDONS
-- ==========================================

-- Fallback pool used when an achievement has no explicit icon.
local FALLBACK_ICON_POOL = {
  "Interface\\Icons\\INV_Misc_Map_01",
  "Interface\\Icons\\INV_Misc_Map_02",
  "Interface\\Icons\\INV_Misc_Coin_01",
  "Interface\\Icons\\INV_Misc_Coin_05",
  "Interface\\Icons\\INV_Misc_Trophy_03",
  "Interface\\Icons\\Spell_Holy_BlessingOfStrength",
  "Interface\\Icons\\Ability_Warrior_Rampage",
  "Interface\\Icons\\Spell_Nature_ResistNature",
}

-- Deterministic hash of a string achId: sum of (byte * position) mod pool length.
local function HashAchId(achId)
  local s = tostring(achId)
  local h = 0
  for i = 1, string.len(s) do
    h = h + string.byte(s, i) * i
  end
  return h
end

local function GetAchievementIcon(achId)
  -- 1. Use the explicitly configured icon if present.
  local achData = ACHIEVEMENTS[achId]
  if achData and achData.icon then return achData.icon end
  -- 2. Re-use a previously cached fallback so it never changes.
  if LeafVE_AchTest_DB and LeafVE_AchTest_DB.iconCache then
    local cached = LeafVE_AchTest_DB.iconCache[achId]
    if cached then return cached end
  end
  -- 3. Compute a deterministic fallback and store it.
  local poolLen = table.getn(FALLBACK_ICON_POOL)
  local idx = (HashAchId(achId) % poolLen) + 1
  local icon = FALLBACK_ICON_POOL[idx]
  if LeafVE_AchTest_DB and LeafVE_AchTest_DB.iconCache then
    LeafVE_AchTest_DB.iconCache[achId] = icon
  end
  return icon
end

-- ==========================================
-- PUBLIC API FOR OTHER ADDONS
-- ==========================================

LeafVE_AchTest.API = {
  GetPlayerPoints = function(playerName)
    return LeafVE_AchTest:GetTotalAchievementPoints(playerName)
  end,
  
  GetRecentAchievements = function(playerName, count)
    if not LeafVE_AchTest_DB or not LeafVE_AchTest_DB.achievements then return {} end
    playerName = ShortName(playerName)
    if not playerName then return {} end
    if not LeafVE_AchTest_DB.achievements[playerName] then return {} end
    
    local achievements = {}
    for achId, achData in pairs(LeafVE_AchTest_DB.achievements[playerName]) do
      if type(achData) == "table" and achData.points and achData.timestamp then
        local achievement = ACHIEVEMENTS[achId]
        if achievement then
          table.insert(achievements, {
            id = achId,
            name = achievement.name,
            icon = GetAchievementIcon(achId),
            points = achData.points,
            timestamp = achData.timestamp
          })
        end
      end
    end
    
    -- Sort by most recent
    table.sort(achievements, function(a, b) return a.timestamp > b.timestamp end)
    
    -- Return only the requested count
    local result = {}
    for i = 1, math.min(count or 5, table.getn(achievements)) do
      table.insert(result, achievements[i])
    end
    
    return result
  end
}

-- Cross-addon accessors used by LeafVillageLegends for tooltips
function LeafVE_AchTest.GetAchievementMeta(achId)
  return ACHIEVEMENTS[achId]
end

function LeafVE_AchTest.GetBossCriteria(criteriaKey, criteriaType)
  if criteriaType == "dungeon" then return DUNGEON_BOSSES[criteriaKey] end
  if criteriaType == "raid"    then return RAID_BOSSES[criteriaKey]    end
  return nil
end

function LeafVE_AchTest.GetBossProgress(playerName, criteriaKey, criteriaType)
  if not LeafVE_AchTest_DB then return nil end
  if criteriaType == "dungeon" then
    local dp = LeafVE_AchTest_DB.dungeonProgress
    return dp and dp[playerName] and dp[playerName][criteriaKey]
  end
  if criteriaType == "raid" then
    local rp = LeafVE_AchTest_DB.raidProgress
    return rp and rp[playerName] and rp[playerName][criteriaKey]
  end
  return nil
end

-- ==========================================
-- PROGRESS TRACKING HELPERS
-- ==========================================

-- Zone name (from GetRealZoneText) → dungeon completion achievement ID
local ZONE_TO_DUNGEON_ACH = {
  ["Ragefire Chasm"]               = "dung_rfc_complete",
  ["Wailing Caverns"]              = "dung_wc_complete",
  ["The Deadmines"]                = "dung_dm_complete",
  ["Shadowfang Keep"]              = "dung_sfk_complete",
  ["Blackfathom Deeps"]            = "dung_bfd_complete",
  ["The Stockade"]                 = "dung_stocks_complete",
  ["The Crescent Grove"]           = "dung_tcg_complete",
  ["Gnomeregan"]                   = "dung_gnomer_complete",
  ["Razorfen Kraul"]               = "dung_rfk_complete",
  ["Scarlet Monastery"]            = nil, -- multiple wings; skip blanket grant
  ["Stormwrought Ruins"]           = "dung_swr_complete",
  ["Razorfen Downs"]               = "dung_rfdown_complete",
  ["Uldaman"]                      = "dung_ulda_complete",
  ["Gilneas City"]                 = "dung_gc_complete",
  ["Maraudon"]                     = "dung_mara_complete",
  ["Zul'Farrak"]                   = "dung_zf_complete",
  ["The Sunken Temple"]            = "dung_st_complete",
  ["Hateforge Quarry"]             = "dung_hq_complete",
  ["Blackrock Depths"]             = "dung_brd_complete",
  ["Dire Maul"]                    = nil, -- multiple wings; skip blanket grant
  ["Scholomance"]                  = "dung_scholo_complete",
  ["Stratholme"]                   = "dung_strat_complete",
  ["Lower Blackrock Spire"]        = "dung_lbrs_complete",
  ["Upper Blackrock Spire"]        = "dung_ubrs_complete",
  ["Karazhan Crypt"]               = "dung_kc_complete",
  ["Black Morass"]                 = "dung_cotbm_complete",
  ["Stormwind Vault"]              = "dung_swv_complete",
  ["Dragonmaw Retreat"]            = "dung_dmr_complete",
}

-- Per-achievement counter/goal definitions for tooltip progress lines
local ACHIEVEMENT_PROGRESS_DEF = {
  -- PvP HKs: read live from the API
  pvp_hk_50    = {api="hk", goal=50},
  pvp_hk_100   = {api="hk", goal=100},
  pvp_hk_250   = {api="hk", goal=250},
  pvp_hk_1000  = {api="hk", goal=1000},
  pvp_hk_2500  = {api="hk", goal=2500},
  pvp_hk_5000  = {api="hk", goal=5000},
  pvp_hk_10000 = {api="hk", goal=10000},
  -- Duels tracked via DUEL_WON event
  pvp_duel_10  = {counter="duels", goal=10},
  pvp_duel_25  = {counter="duels", goal=25},
  pvp_duel_50  = {counter="duels", goal=50},
  pvp_duel_75  = {counter="duels", goal=75},
  pvp_duel_100 = {counter="duels", goal=100},
  -- Gold: read live from the API
  gold_10   = {api="gold", goal=10},
  gold_100  = {api="gold", goal=100},
  gold_500  = {api="gold", goal=500},
  gold_1000 = {api="gold", goal=1000},
  gold_5000 = {api="gold", goal=5000},
  -- Quests: prefer GetNumQuestsCompleted(), fall back to tracked counter
  casual_quest_100  = {api="quests", counter="quests", goal=100},
  casual_quest_500  = {api="quests", counter="quests", goal=500},
  casual_quest_1000 = {api="quests", counter="quests", goal=1000},
  -- Deaths tracked via PLAYER_DEAD event
  casual_deaths_5   = {counter="deaths", goal=5},
  casual_deaths_10  = {counter="deaths", goal=10},
  casual_deaths_25  = {counter="deaths", goal=25},
  casual_deaths_50  = {counter="deaths", goal=50},
  casual_deaths_100 = {counter="deaths", goal=100},
  casual_fall_death = {counter="fallDeaths", goal=10},
  casual_drown      = {counter="drownings", goal=10},
  -- Hearthstone uses tracked via UNIT_SPELLCAST_SUCCEEDED
  casual_hearthstone_1   = {counter="hearthstones", goal=1},
  casual_hearthstone_use = {counter="hearthstones", goal=50},
  casual_hearthstone_100 = {counter="hearthstones", goal=100},
  -- Fish tracked via CHAT_MSG_LOOT (bobber loot)
  casual_fish_25   = {counter="fish", goal=25},
  casual_fish_100  = {counter="fish", goal=100},
  casual_fish_1000 = {counter="fish", goal=1000},
  -- Groups joined: PARTY_MEMBERS_CHANGED (0 → >0)
  casual_party_join = {counter="groups", goal=50},
  -- Emotes tracked via CHAT_MSG_TEXT_EMOTE
  casual_emote_25  = {counter="emotes", goal=25},
  casual_emote_100 = {counter="emotes", goal=100},
  -- Boss kill counts tracked via CHAT_MSG_COMBAT_HOSTILE_DEATH
  elite_rag_5x        = {counter="boss_Ragnaros",    goal=5},
  elite_rag_10x       = {counter="boss_Ragnaros",    goal=10},
  elite_nef_5x        = {counter="boss_Nefarian",    goal=5},
  elite_nef_10x       = {counter="boss_Nefarian",    goal=10},
  elite_kt_3x         = {counter="boss_KelThuzad",   goal=3},
  elite_kt_5x         = {counter="boss_KelThuzad",   goal=5},
  elite_cthun_5x      = {counter="boss_CThun",       goal=5},
  elite_drakkisath_5x = {counter="boss_Drakkisath",  goal=5},
  elite_gandling_5x   = {counter="boss_Gandling",    goal=5},
  elite_baron_5x      = {counter="boss_BaronRiv",    goal=5},
  elite_onyxia_5x     = {counter="boss_Onyxia",      goal=5},
  elite_onyxia_10x    = {counter="boss_Onyxia",      goal=10},
  elite_hakkar_5x     = {counter="boss_Hakkar",      goal=5},
  -- Total and unique boss kills
  elite_100_bosses     = {counter="totalBossKills",  goal=100},
  elite_250_bosses     = {counter="totalBossKills",  goal=250},
  elite_500_bosses     = {counter="totalBossKills",  goal=500},
  elite_25_unique_bosses = {counter="uniqueBossKills", goal=25},
  elite_50_unique_bosses = {counter="uniqueBossKills", goal=50},
  -- Dungeon and raid run counts
  elite_50_dungeons  = {counter="dungeonRuns", goal=50},
  elite_100_dungeons = {counter="dungeonRuns", goal=100},
  elite_25_raids     = {counter="raidRuns",    goal=25},
  elite_50_raids     = {counter="raidRuns",    goal=50},
  -- Ironman: deaths must remain 0 to hit level 60
  elite_ironman = {counter="deaths", goal=0},

  -- Generic kill milestones (tracked via "genericKills" counter)
  kill_01      = {counter="genericKills", goal=1},
  kill_05      = {counter="genericKills", goal=5},
  kill_10      = {counter="genericKills", goal=10},
  kill_50      = {counter="genericKills", goal=50},
  kill_100     = {counter="genericKills", goal=100},
  kill_200     = {counter="genericKills", goal=200},
  kill_500     = {counter="genericKills", goal=500},
  kill_1000    = {counter="genericKills", goal=1000},
  kill_10000   = {counter="genericKills", goal=10000},
  kills_100    = {counter="genericKills", goal=100},
  kills_500    = {counter="genericKills", goal=500},
  kills_1000   = {counter="genericKills", goal=1000},
  kills_2500   = {counter="genericKills", goal=2500},
  kills_5000   = {counter="genericKills", goal=5000},
  kills_10000  = {counter="genericKills", goal=10000},
  -- Zone-exploration count achievements
  explore_zones_10  = {counter="wandererCount",    goal=10},
  explore_zones_25  = {counter="exploredZoneCount", goal=25},
  explore_zones_50  = {counter="exploredZoneCount", goal=50},
  -- Continent exploration progress
  explore_kalimdor          = {counter="kalimdorSubzoneCount", goal=KALIMDOR_REQUIRED_TOTAL},
  explore_eastern_kingdoms  = {counter="ekSubzoneCount",       goal=EK_REQUIRED_TOTAL},
}

-- Returns {current, goal} or nil if no progress data exists for this achievement.
local function GetAchievementProgress(me, achId)
  local def = ACHIEVEMENT_PROGRESS_DEF[achId]
  if not def then return nil end

  local current = 0

  if def.api == "hk" then
    current = (GetPVPLifetimeHonorableKills and GetPVPLifetimeHonorableKills()) or 0
  elseif def.api == "gold" then
    current = math.floor((GetMoney and GetMoney() or 0) / 10000)
  elseif def.api == "quests" then
    -- Prefer the server-side total (available via GetNumQuestsCompleted in Turtle WoW)
    if GetNumQuestsCompleted then
      current = GetNumQuestsCompleted() or 0
    else
      local pc = LeafVE_AchTest_DB and LeafVE_AchTest_DB.progressCounters
      local pme = pc and pc[me]
      current = (pme and pme[def.counter]) or 0
    end
  end

  if def.counter then
    local pc = LeafVE_AchTest_DB and LeafVE_AchTest_DB.progressCounters
    local pme = pc and pc[me]
    local tracked = (pme and pme[def.counter]) or 0
    -- For API-backed achievements the API value is more accurate; for others use counter
    if def.api ~= "hk" and def.api ~= "gold" and def.api ~= "quests" then
      current = tracked
    end
  end

  return {current = current, goal = def.goal}
end

-- Ensure a player's counter sub-table exists and increment a named counter
local function IncrCounter(playerName, counterName, amount)
  EnsureDB()
  if not LeafVE_AchTest_DB.progressCounters[playerName] then
    LeafVE_AchTest_DB.progressCounters[playerName] = {}
  end
  local c = LeafVE_AchTest_DB.progressCounters[playerName]
  c[counterName] = (c[counterName] or 0) + (amount or 1)
  return c[counterName]
end

-- ============================================================
-- GetTitleColor: returns WoW color code for a title difficulty.
-- |cFFFF7F00 = orange  (normal);  |cFFB00000 = dark red  (hard)
-- ============================================================
local function GetTitleColor(difficulty)
  if difficulty == "hard" then
    return "|cFFB00000"
  end
  return "|cFFFF7F00"
end

-- GetTitleColorRGB: returns r,g,b float tuple matching GetTitleColor hex.
local function GetTitleColorRGB(difficulty)
  if difficulty == "hard" then
    return 0.69, 0, 0    -- #B00000
  end
  return THEME.orange[1], THEME.orange[2], THEME.orange[3]  -- #FF7F00
end

-- ============================================================
-- Zone exploration helper
-- ============================================================
local function CheckZoneExplorationAchievements(me, zoneCount)
  EnsureDB()
  if not LeafVE_AchTest_DB.progressCounters[me] then LeafVE_AchTest_DB.progressCounters[me] = {} end
  LeafVE_AchTest_DB.progressCounters[me]["exploredZoneCount"] = zoneCount
  if zoneCount >= 25  then LeafVE_AchTest:AwardAchievement("explore_zones_25",  true) end
  if zoneCount >= 50  then LeafVE_AchTest:AwardAchievement("explore_zones_50",  true) end
end

-- Updates wandererCount (counted subzones only) and awards Wanderer achievement.
local function CheckWandererAchievement(me)
  EnsureDB()
  if not LeafVE_AchTest_DB.progressCounters[me] then LeafVE_AchTest_DB.progressCounters[me] = {} end
  local explored = LeafVE_AchTest_DB.exploredZones and LeafVE_AchTest_DB.exploredZones[me]
  if not explored then return end
  local count = 0
  for sz in pairs(explored) do
    if COUNTED_WANDERER_SUBZONES[sz] then count = count + 1 end
  end
  LeafVE_AchTest_DB.progressCounters[me]["wandererCount"] = count
  if count >= 10 then LeafVE_AchTest:AwardAchievement("explore_zones_10", true) end
end

-- Checks and awards Explore Kalimdor / Explore Eastern Kingdoms and World Explorer.
local function CheckContinentAchievements(me)
  EnsureDB()
  if not LeafVE_AchTest_DB.progressCounters[me] then LeafVE_AchTest_DB.progressCounters[me] = {} end
  local explored = LeafVE_AchTest_DB.exploredZones and LeafVE_AchTest_DB.exploredZones[me]
  if not explored then return end
  -- Kalimdor progress
  local kalCount = 0
  for sz in pairs(KALIMDOR_SUBZONE_SET) do if explored[sz] then kalCount = kalCount + 1 end end
  LeafVE_AchTest_DB.progressCounters[me]["kalimdorSubzoneCount"] = kalCount
  if kalCount >= KALIMDOR_REQUIRED_TOTAL then
    LeafVE_AchTest:AwardAchievement("explore_kalimdor", true)
  end
  -- Eastern Kingdoms progress
  local ekCount = 0
  for sz in pairs(EK_SUBZONE_SET) do if explored[sz] then ekCount = ekCount + 1 end end
  LeafVE_AchTest_DB.progressCounters[me]["ekSubzoneCount"] = ekCount
  if ekCount >= EK_REQUIRED_TOTAL then
    LeafVE_AchTest:AwardAchievement("explore_eastern_kingdoms", true)
  end
  -- World Explorer: requires both continents + all TW zone-group achievements
  if LeafVE_AchTest:HasAchievement(me, "explore_kalimdor") and
     LeafVE_AchTest:HasAchievement(me, "explore_eastern_kingdoms") then
    local allTW = true
    for _, twId in ipairs(WORLD_EXPLORER_TW_IDS) do
      if not LeafVE_AchTest:HasAchievement(me, twId) then allTW = false; break end
    end
    if allTW then LeafVE_AchTest:AwardAchievement("explore_zones_100", true) end
  end
end

-- ============================================================
-- Kill tracking: RecordKill with debounce
-- ============================================================

-- Kill-milestone ID list.
-- kill_* entries are older achievements defined in LeafVE_Ach_Kills.lua;
-- kills_* are newer tiered achievements added in the ACHIEVEMENTS table.
-- Both share the same genericKills counter so players earn both at each threshold.
local KILL_MILESTONE_LIST = {
  {value=1,     id="kill_01"},
  {value=5,     id="kill_05"},
  {value=10,    id="kill_10"},
  {value=50,    id="kill_50"},
  {value=100,   id="kill_100"},
  {value=200,   id="kill_200"},
  {value=500,   id="kill_500"},
  {value=1000,  id="kill_1000"},
  {value=10000, id="kill_10000"},
  {value=100,   id="kills_100"},
  {value=500,   id="kills_500"},
  {value=1000,  id="kills_1000"},
  {value=2500,  id="kills_2500"},
  {value=5000,  id="kills_5000"},
  {value=10000, id="kills_10000"},
}

local killDebounce_mob  = ""
local killDebounce_time = 0
-- 0.3s window covers the typical gap between CHAT_MSG_COMBAT_HOSTILE_DEATH and
-- CHAT_MSG_COMBAT_XP_GAIN / COMBAT_TEXT_UPDATE for the same kill event.
local KILL_DEBOUNCE_SEC = 0.3

local function UpdateKillAchievements(me, total)
  for _, m in ipairs(KILL_MILESTONE_LIST) do
    if total >= m.value and ACHIEVEMENTS[m.id] then
      LeafVE_AchTest:AwardAchievement(m.id, true)
    end
  end
end

local function RecordKill(mobName)
  local me = ShortName(UnitName("player"))
  if not me then return end
  local now = GetTime and GetTime() or 0
  local mkey = mobName or ""
  -- Debounce: same mob within the window, or any unnamed kill within the window
  if (now - killDebounce_time) < KILL_DEBOUNCE_SEC then
    if mkey == "" or mkey == killDebounce_mob then
      return
    end
  end
  killDebounce_mob  = mkey
  killDebounce_time = now
  local total = IncrCounter(me, "genericKills")
  Debug("Kill recorded: "..(mkey ~= "" and mkey or "unknown").." total="..tostring(total))
  UpdateKillAchievements(me, total)
end

-- ============================================================
-- CheckGuildMemberAchievement
-- ============================================================
local function CheckGuildMemberAchievement()
  if not IsInGuild or not IsInGuild() then return end
  local me = ShortName(UnitName("player"))
  if not me then return end
  if not LeafVE_AchTest:HasAchievement(me, "casual_guild_join") then
    LeafVE_AchTest:AwardAchievement("casual_guild_join", true)
  end
end

-- ============================================================
-- ScanProfessionsAndAward
-- ============================================================
-- Primary professions only (exclude secondary: First Aid, Fishing, Cooking)
local PRIMARY_PROFESSION_NAMES = {
  ["Alchemy"]=true, ["Blacksmithing"]=true, ["Enchanting"]=true,
  ["Engineering"]=true, ["Herbalism"]=true, ["Leatherworking"]=true,
  ["Mining"]=true, ["Skinning"]=true, ["Tailoring"]=true,
  ["Jewelcrafting"]=true,
}

function LeafVE_AchTest.ScanProfessionsAndAward()
  LeafVE_AchTest:CheckProfessionAchievements()
end

-- Explicit alias used by data files and external callers.
function LeafVE_AchTest.ScanProfessions()
  LeafVE_AchTest:CheckProfessionAchievements()
end

-- Ensure all quest-chain achievements are inserted into the ACHIEVEMENTS table.
-- Safe to call multiple times; AddAchievement is idempotent (last write wins).
function LeafVE_AchTest.EnsureQuestCategoryRegistered()
  -- Quest chain achievements are registered by LeafVE_Ach_Quests.lua on ADDON_LOADED.
  -- This no-op stub exists so external code can call it defensively.
end

-- Expose helpers so separate achievement module files loaded after this file
-- can add achievements and interact with the DB without duplicating locals.
LeafVE_AchTest.ShortName          = ShortName
LeafVE_AchTest.IncrCounter        = IncrCounter
LeafVE_AchTest.RecordKill         = RecordKill
LeafVE_AchTest.GetTitleColor      = GetTitleColor
LeafVE_AchTest.UpdateKillAchievements = UpdateKillAchievements
function LeafVE_AchTest:AddAchievement(id, data)
  ACHIEVEMENTS[id] = data
end
-- Allow external modules to register tooltip progress definitions.
function LeafVE_AchTest:RegisterProgressDef(achId, def)
  ACHIEVEMENT_PROGRESS_DEF[achId] = def
end
-- Allow external modules to add titles.
-- AddTitle inserts a title into the TITLES list.
-- Always forces prefix=false (suffix-only) and defaults category to "Quests".
function LeafVE_AchTest:AddTitle(titleData)
  local td = {}
  for k, v in pairs(titleData) do td[k] = v end
  if not td.category then td.category = "Quests" end
  td.prefix = false
  table.insert(TITLES, td)
end

-- Check and award quest-count achievements using GetNumQuestsCompleted() or the stored counter
function LeafVE_AchTest:CheckQuestAchievements()
  local me = ShortName(UnitName("player"))
  if not me then return end
  local total
  if GetNumQuestsCompleted then
    total = GetNumQuestsCompleted() or 0
  else
    EnsureDB()
    local pc = LeafVE_AchTest_DB.progressCounters[me]
    total = (pc and pc.quests) or 0
  end
  if total >= 100  then self:AwardAchievement("casual_quest_100",  true) end
  if total >= 250  then self:AwardAchievement("casual_quest_250",  true) end
  if total >= 500  then self:AwardAchievement("casual_quest_500",  true) end
  if total >= 750  then self:AwardAchievement("casual_quest_750",  true) end
  if total >= 1000 then self:AwardAchievement("casual_quest_1000", true) end
end

-- Check PvP rank achievement
function LeafVE_AchTest:CheckPvPRankAchievements()
  if not UnitPVPRank then return end
  local rank = UnitPVPRank("player") or 0
  if rank >= 14 then self:AwardAchievement("elite_pvp_rank_14", true) end
end

-- ==========================================
-- GUILD SYNC SYSTEM
-- ==========================================

-- Broadcast your achievements to guild
function LeafVE_AchTest:BroadcastAchievements()
  if not IsInGuild() then return end
  
  local me = ShortName(UnitName("player"))
  if not me then return end
  
  local myAchievements = self:GetPlayerAchievements(me)
  
  -- Build compressed achievement list (just IDs and timestamps)
  local achData = {}
  for achID, data in pairs(myAchievements) do
    table.insert(achData, achID..":"..data.timestamp..":"..data.points)
  end
  
  local message = table.concat(achData, ",")
  
  -- Send via addon channel
  if table.getn(achData) > 0 then
    SendAddonMessage("LeafVEAch", "SYNC:"..message, "GUILD")
    Debug("Broadcast "..table.getn(achData).." achievements to guild")
  else
    Debug("No achievements to broadcast")
  end
end

-- Receive other players' achievements (FIXED for Vanilla WoW)
function LeafVE_AchTest:OnAddonMessage(prefix, message, channel, sender)
  if prefix ~= "LeafVEAch" then return end
  if channel ~= "GUILD" then return end
  
  sender = ShortName(sender)
  if not sender then return end
  
  Debug("Received addon message from "..sender)
  
  -- Parse sync message
  if string.sub(message, 1, 5) == "SYNC:" then
    local achData = string.sub(message, 6)
    
    if not LeafVE_AchTest_DB.achievements[sender] then
      LeafVE_AchTest_DB.achievements[sender] = {}
    end
    
    -- Parse achievement data (Vanilla WoW compatible)
    local achievements = {}
    local startPos = 1
    
    while startPos <= string.len(achData) do
      local commaPos = string.find(achData, ",", startPos)
      local achEntry
      
      if commaPos then
        achEntry = string.sub(achData, startPos, commaPos - 1)
        startPos = commaPos + 1
      else
        achEntry = string.sub(achData, startPos)
        startPos = string.len(achData) + 1
      end
      
      -- Parse individual achievement: "achID:timestamp:points"
      local colonPos1 = string.find(achEntry, ":")
      if colonPos1 then
        local achID = string.sub(achEntry, 1, colonPos1 - 1)
        local colonPos2 = string.find(achEntry, ":", colonPos1 + 1)
        
        if colonPos2 then
          local timestamp = string.sub(achEntry, colonPos1 + 1, colonPos2 - 1)
          local points = string.sub(achEntry, colonPos2 + 1)
          
          achievements[achID] = {
            timestamp = tonumber(timestamp),
            points = tonumber(points)
          }
        end
      end
    end
    
    -- Update stored data for this player
    LeafVE_AchTest_DB.achievements[sender] = achievements
    
    local count = 0
    for _ in pairs(achievements) do count = count + 1 end
    Debug("Stored "..count.." achievements from "..sender)
    
    -- Refresh UI if viewing this player
    if LeafVE and LeafVE.UI and LeafVE.UI.cardCurrentPlayer == sender then
      LeafVE.UI:ShowPlayerCard(sender)
    end
  end
end

-- Register addon message listener
local syncFrame = CreateFrame("Frame")
syncFrame:RegisterEvent("CHAT_MSG_ADDON")
syncFrame:SetScript("OnEvent", function()
  if event == "CHAT_MSG_ADDON" then
    LeafVE_AchTest:OnAddonMessage(arg1, arg2, arg3, arg4)
  end
end)

-- Auto-broadcast on login and every 5 minutes
local broadcastTimer = 0
local broadcastFrame = CreateFrame("Frame")
broadcastFrame:SetScript("OnUpdate", function()
  broadcastTimer = broadcastTimer + arg1
  if broadcastTimer >= 300 then -- 5 minutes
    broadcastTimer = 0
    LeafVE_AchTest:BroadcastAchievements()
  end
end)

-- Broadcast shortly after login
local loginBroadcast = CreateFrame("Frame")
loginBroadcast:RegisterEvent("PLAYER_ENTERING_WORLD")
loginBroadcast:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    local waitTimer = 0
    this:SetScript("OnUpdate", function()
      waitTimer = waitTimer + arg1
      if waitTimer >= 5 then
        LeafVE_AchTest:BroadcastAchievements()
        this:SetScript("OnUpdate", nil)
        this:UnregisterEvent("PLAYER_ENTERING_WORLD")
      end
    end)
  end
end)

Print("Achievement sync system loaded!")

-- Store original SendChatMessage before hooking
local originalSendChatMessage = SendChatMessage

function LeafVE_AchTest:GetPlayerAchievements(playerName)
  EnsureDB()
  playerName = ShortName(playerName or UnitName("player"))
  if not playerName then return {} end
  if not LeafVE_AchTest_DB.achievements[playerName] then
    LeafVE_AchTest_DB.achievements[playerName] = {}
  end
  return LeafVE_AchTest_DB.achievements[playerName]
end

function LeafVE_AchTest:HasAchievement(playerName, achievementID)
  local achievements = self:GetPlayerAchievements(playerName)
  return achievements[achievementID] ~= nil
end

function LeafVE_AchTest:ShowAchievementPopup(achievementID)
  local achievement = ACHIEVEMENTS[achievementID]
  if not achievement then return end
  
  local popup = CreateFrame("Frame", nil, UIParent)
  popup:SetWidth(320)
  popup:SetHeight(90)
  popup:SetPoint("TOP", UIParent, "TOP", 0, -150)
  popup:SetFrameStrata("HIGH")
  popup:SetAlpha(0)
  
  popup:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  popup:SetBackdropColor(0, 0, 0, 0.9)
  popup:SetBackdropBorderColor(THEME.orange[1], THEME.orange[2], THEME.orange[3], 1)
  
  local earnedText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  earnedText:SetPoint("TOP", popup, "TOP", 0, -10)
  earnedText:SetText("|cFFFF7F00Achievement Earned!|r")
  
  local icon = popup:CreateTexture(nil, "ARTWORK")
  icon:SetWidth(48)
  icon:SetHeight(48)
  icon:SetPoint("LEFT", popup, "LEFT", 15, -5)
  icon:SetTexture(achievement.icon)
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  
  local nameText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
  nameText:SetPoint("RIGHT", popup, "RIGHT", -10, 0)
  nameText:SetJustifyH("LEFT")
  nameText:SetText("|cFF2DD35C"..achievement.name.."|r")
  
  local descText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  descText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -3)
  descText:SetPoint("RIGHT", popup, "RIGHT", -10, 0)
  descText:SetJustifyH("LEFT")
  descText:SetText(achievement.desc)
  
  local pointsText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  pointsText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
  pointsText:SetText("|cFFFF7F00+"..achievement.points.." points|r")
  
  local fadeIn = 0
  local stay = 0
  local fadeOut = 0
  
  popup:SetScript("OnUpdate", function()
    if fadeIn < 0.5 then
      fadeIn = fadeIn + arg1
      popup:SetAlpha(fadeIn / 0.5)
    elseif stay < 4 then
      stay = stay + arg1
      popup:SetAlpha(1)
    elseif fadeOut < 0.5 then
      fadeOut = fadeOut + arg1
      popup:SetAlpha(1 - (fadeOut / 0.5))
    else
      popup:Hide()
      popup = nil
    end
  end)
  
  popup:Show()
  PlaySound("LevelUp")
end

function LeafVE_AchTest:AwardAchievement(achievementID, silent)
  local playerName = UnitName("player")
  if not playerName or playerName == "" then return end
  local me = ShortName(playerName)
  if not me or me == "" then return end
  if self:HasAchievement(me, achievementID) then
    return
  end
  local achievement = ACHIEVEMENTS[achievementID]
  if not achievement then return end
  local achievements = self:GetPlayerAchievements(me)
  achievements[achievementID] = {timestamp = Now(), points = achievement.points}
  
  if not silent then
    self:ShowAchievementPopup(achievementID)
    Print("Achievement earned: "..achievement.name.." (+"..achievement.points.." pts)")
  end
  
  -- Guild announcement — achievement name is a clickable hyperlink
  if IsInGuild() then
    local currentTitle = self:GetCurrentTitle(me)
    local achLink = "|cFF2DD35C|Hleafve_ach:"..achievementID.."|h["..achievement.name.."]|h|r"
    local guildMsg = ""

    -- Build message: [Title] [LeafVE Achievement] earned [Achievement]
    if currentTitle then
      local titleDiff = "normal"
      for _, td in ipairs(TITLES) do
        if td.id == currentTitle.id then titleDiff = td.difficulty or "normal"; break end
      end
      local titleColor = GetTitleColor(titleDiff)
      guildMsg = titleColor.."["..currentTitle.name.."]|r |cFF2DD35C[LeafVE Achievement]|r earned "..achLink
    else
      guildMsg = "|cFF2DD35C[LeafVE Achievement]|r earned "..achLink
    end

    -- Use original SendChatMessage to avoid adding title twice
    if originalSendChatMessage then
      originalSendChatMessage(guildMsg, "GUILD")
    else
      SendChatMessage(guildMsg, "GUILD")
    end

    Debug("Sent guild achievement: "..guildMsg)
  end
  
  if LeafVE_AchTest.UI and LeafVE_AchTest.UI.Refresh then
    LeafVE_AchTest.UI:Refresh()
  end
  
  -- Notify LeafLegends to refresh if it's open
  if LeafVE and LeafVE.UI and LeafVE.UI.ShowPlayerCard and LeafVE.UI.cardCurrentPlayer then
    LeafVE.UI:ShowPlayerCard(LeafVE.UI.cardCurrentPlayer)
  end
end

function LeafVE_AchTest:GetTotalAchievementPoints(playerName)
  local achievements = self:GetPlayerAchievements(playerName)
  local total = 0
  for achID, data in pairs(achievements) do
    local ach = ACHIEVEMENTS[achID]
    if ach then total = total + ach.points end
  end
  return total
end

function LeafVE_AchTest:GetCurrentTitle(playerName)
  EnsureDB()
  playerName = ShortName(playerName or UnitName("player"))
  if not playerName then return nil end
  local titleData = LeafVE_AchTest_DB.selectedTitles[playerName]
  if not titleData then return nil end
  local titleID = titleData
  local asPrefix = false
  if type(titleData) == "table" then
    titleID = titleData.id
    asPrefix = titleData.asPrefix or false
  end
  for _, title in ipairs(TITLES) do
    if title.id == titleID then
      return {id=title.id,name=title.name,achievement=title.achievement,prefix=false}
    end
  end
  return nil
end

-- usePrefix is accepted for backwards compatibility but is always ignored; titles are always suffix.
function LeafVE_AchTest:SetTitle(playerName, titleID, usePrefix)
  EnsureDB()
  playerName = ShortName(playerName or UnitName("player"))
  if not playerName then return end
  if not titleID or titleID == "" then return end
  local titleData = nil
  for _, title in ipairs(TITLES) do
    if title.id == titleID then titleData = title break end
  end
  if not titleData then return end
  if self:HasAchievement(playerName, titleData.achievement) then
    LeafVE_AchTest_DB.selectedTitles[playerName] = {id=titleID,asPrefix=false}
    local displayText = playerName.." "..titleData.name
    Print("Title set to: |cFFFF7F00"..displayText.."|r")
    if LeafVE_AchTest.UI and LeafVE_AchTest.UI.Refresh then
      LeafVE_AchTest.UI:Refresh()
    end
  else
    Print("You haven't earned that title yet!")
  end
end

function LeafVE_AchTest:CheckLevelAchievements()
  local level = UnitLevel("player")
  if level >= 10 then self:AwardAchievement("lvl_10", true) end
  if level >= 20 then self:AwardAchievement("lvl_20", true) end
  if level >= 30 then self:AwardAchievement("lvl_30", true) end
  if level >= 40 then self:AwardAchievement("lvl_40", true) end
  if level >= 50 then self:AwardAchievement("lvl_50", true) end
  if level >= 60 then self:AwardAchievement("lvl_60") end
end

function LeafVE_AchTest:CheckGoldAchievements()
  local gold = math.floor(GetMoney() / 10000)
  if gold >= 10 then self:AwardAchievement("gold_10", true) end
  if gold >= 100 then self:AwardAchievement("gold_100", true) end
  if gold >= 500 then self:AwardAchievement("gold_500", true) end
  if gold >= 1000 then self:AwardAchievement("gold_1000", true) end
  if gold >= 5000 then self:AwardAchievement("gold_5000", true) end
end

LeafVE_AchTest.UI = {}
LeafVE_AchTest.UI.currentView = "achievements"
LeafVE_AchTest.UI.selectedCategory = "All"
LeafVE_AchTest.UI.selectedTitleCategory = "All"
LeafVE_AchTest.UI.searchText = ""
LeafVE_AchTest.UI.titleSearchText = ""

-- Boss kill tracking: raid bosses only — dungeon bosses are tracked via BOSS_TO_DUNGEON
local BOSS_ACHIEVEMENTS = {
  -- Molten Core
  ["Incindis"] = "raid_mc_incindis",
  ["Lucifron"] = "raid_mc_lucifron",
  ["Magmadar"] = "raid_mc_magmadar",
  ["Gehennas"] = "raid_mc_gehennas",
  ["Garr"] = "raid_mc_garr",
  ["Baron Geddon"] = "raid_mc_geddon",
  ["Shazzrah"] = "raid_mc_shazzrah",
  ["Sulfuron Harbinger"] = "raid_mc_sulfuron",
  ["Golemagg the Incinerator"] = "raid_mc_golemagg",
  ["Basalthar"] = "raid_mc_twins",
  ["Sorcerer-Thane Thaurissan"] = "raid_mc_sorcerer",
  ["Majordomo Executus"] = "raid_mc_majordomo",
  ["Ragnaros"] = "raid_mc_ragnaros",
  -- Onyxia
  ["Onyxia"] = "raid_onyxia",
  -- Blackwing Lair
  ["Razorgore the Untamed"] = "raid_bwl_razorgore",
  ["Vaelastrasz the Corrupt"] = "raid_bwl_vaelastrasz",
  ["Broodlord Lashlayer"] = "raid_bwl_broodlord",
  ["Firemaw"] = "raid_bwl_firemaw",
  ["Ebonroc"] = "raid_bwl_ebonroc",
  ["Flamegor"] = "raid_bwl_flamegor",
  ["Chromaggus"] = "raid_bwl_chromaggus",
  ["Nefarian"] = "raid_bwl_nefarian",
  -- Zul'Gurub
  ["High Priest Venoxis"] = "raid_zg_venoxis",
  ["High Priestess Jeklik"] = "raid_zg_jeklik",
  ["High Priestess Mar'li"] = "raid_zg_marli",
  ["Bloodlord Mandokir"] = "raid_zg_mandokir",
  ["Gri'lek"] = "raid_zg_grilek",
  ["Hazza'rah"] = "raid_zg_hazzarah",
  ["Renataki"] = "raid_zg_renataki",
  ["Wushoolay"] = "raid_zg_wushoolay",
  ["Gahz'ranka"] = "raid_zg_gahzranka",
  ["High Priest Thekal"] = "raid_zg_thekal",
  ["High Priestess Arlokk"] = "raid_zg_arlokk",
  ["Jin'do the Hexxer"] = "raid_zg_jindo",
  ["Hakkar"] = "raid_zg_hakkar",
  -- AQ20
  ["Kurinnaxx"] = "raid_aq20_kurinnaxx",
  ["General Rajaxx"] = "raid_aq20_rajaxx",
  ["Moam"] = "raid_aq20_moam",
  ["Buru the Gorger"] = "raid_aq20_buru",
  ["Ayamiss the Hunter"] = "raid_aq20_ayamiss",
  ["Ossirian the Unscarred"] = "raid_aq20_ossirian",
  -- AQ40
  ["The Prophet Skeram"] = "raid_aq40_skeram",
  ["Lord Kri"] = "raid_aq40_bug_trio",
  ["Princess Yauj"] = "raid_aq40_bug_trio",
  ["Vem"] = "raid_aq40_bug_trio",
  ["Battleguard Sartura"] = "raid_aq40_sartura",
  ["Fankriss the Unyielding"] = "raid_aq40_fankriss",
  ["Viscidus"] = "raid_aq40_viscidus",
  ["Princess Huhuran"] = "raid_aq40_huhuran",
  ["Emperor Vek'lor"] = "raid_aq40_twins",
  ["Ouro"] = "raid_aq40_ouro",
  ["C'Thun"] = "raid_aq40_cthun",
  -- Naxxramas
  ["Anub'Rekhan"] = "raid_naxx_anubrekhan",
  ["Grand Widow Faerlina"] = "raid_naxx_faerlina",
  ["Maexxna"] = "raid_naxx_maexxna",
  ["Noth the Plaguebringer"] = "raid_naxx_noth",
  ["Heigan the Unclean"] = "raid_naxx_heigan",
  ["Loatheb"] = "raid_naxx_loatheb",
  ["Instructor Razuvious"] = "raid_naxx_razuvious",
  ["Gothik the Harvester"] = "raid_naxx_gothik",
  ["Highlord Mograine"] = "raid_naxx_four_horsemen",
  ["Thane Korth'azz"] = "raid_naxx_four_horsemen",
  ["Lady Blaumeux"] = "raid_naxx_four_horsemen",
  ["Sir Zeliek"] = "raid_naxx_four_horsemen",
  ["Patchwerk"] = "raid_naxx_patchwerk",
  ["Grobbulus"] = "raid_naxx_grobbulus",
  ["Gluth"] = "raid_naxx_gluth",
  ["Thaddius"] = "raid_naxx_thaddius",
  ["Sapphiron"] = "raid_naxx_sapphiron",
  ["Kel'Thuzad"] = "raid_naxx_kelthuzad",
  -- Emerald Sanctum (Turtle WoW)
  ["Erennius"] = "raid_es_erennius",
  ["Solnius the Awakener"] = "raid_es_solnius",
  -- Lower Karazhan Halls (Turtle WoW)
  ["Master Blacksmith Rolfen"] = "raid_lkh_rolfen",
  ["Brood Queen Araxxna"] = "raid_lkh_araxxna",
  ["Grizikil"] = "raid_lkh_grizikil",
  ["Clawlord Howlfang"] = "raid_lkh_howlfang",
  ["Lord Blackwald II"] = "raid_lkh_blackwald",
  ["Moroes"] = "raid_lkh_moroes",
  -- Upper Karazhan Halls (Turtle WoW)
  ["Keeper Gnarlmoon"] = "raid_ukh_gnarlmoon",
  ["Ley-Watcher Incantagos"] = "raid_ukh_incantagos",
  ["Anomalus"] = "raid_ukh_anomalus",
  ["Echo of Medivh"] = "raid_ukh_echo",
  ["King"] = "raid_ukh_king",
  ["Sanv Tas'dal"] = "raid_ukh_sanvtas",
  ["Kruul"] = "raid_ukh_kruul",
  ["Rupturan the Broken"] = "raid_ukh_rupturan",
  ["Mephistroth"] = "raid_ukh_mephistroth",
}

-- ==========================================
-- BOSS TRACKING & BACKLOG LOGIC
-- ==========================================

-- Record a dungeon boss kill and award completion if all bosses done
function LeafVE_AchTest:RecordDungeonBoss(bossName)
  local dungId = BOSS_TO_DUNGEON[bossName]
  if not dungId then return end
  local me = ShortName(UnitName("player"))
  if not me then return end
  EnsureDB()
  local dp = LeafVE_AchTest_DB.dungeonProgress
  if not dp[me] then dp[me] = {} end
  if not dp[me][dungId] then dp[me][dungId] = {} end
  if not dp[me][dungId][bossName] then
    dp[me][dungId][bossName] = Now()
    Debug("Dungeon boss: "..bossName.." ("..dungId..")")
    local achId = "dung_"..dungId.."_complete"
    if ACHIEVEMENTS[achId] and not self:HasAchievement(me, achId) then
      local allDone = true
      for _, req in ipairs(DUNGEON_BOSSES[dungId]) do
        if not dp[me][dungId][req] then allDone = false; break end
      end
      if allDone then
        self:AwardAchievement(achId)
        -- Count completed dungeon runs for run-count achievements
        local runTotal = IncrCounter(me, "dungeonRuns")
        if runTotal >= 50  then self:AwardAchievement("elite_50_dungeons",  true) end
        if runTotal >= 100 then self:AwardAchievement("elite_100_dungeons", true) end
        self:CheckMetaAchievements()
      end
    end
  end
end

-- Record a raid boss kill and award completion if all bosses done
function LeafVE_AchTest:RecordRaidBoss(bossName)
  local raidId = BOSS_TO_RAID[bossName]
  if not raidId then return end
  local me = ShortName(UnitName("player"))
  if not me then return end
  EnsureDB()
  local rp = LeafVE_AchTest_DB.raidProgress
  if not rp[me] then rp[me] = {} end
  if not rp[me][raidId] then rp[me][raidId] = {} end
  if not rp[me][raidId][bossName] then
    rp[me][raidId][bossName] = Now()
    local achId = "raid_"..raidId.."_complete"
    if ACHIEVEMENTS[achId] and not self:HasAchievement(me, achId) then
      local allDone = true
      for _, req in ipairs(RAID_BOSSES[raidId]) do
        if not rp[me][raidId][req] then allDone = false; break end
      end
      if allDone then
        self:AwardAchievement(achId)
        -- Count completed raid runs for run-count achievements
        local runTotal = IncrCounter(me, "raidRuns")
        if runTotal >= 25 then self:AwardAchievement("elite_25_raids", true) end
        if runTotal >= 50 then self:AwardAchievement("elite_50_raids", true) end
        self:CheckMetaAchievements()
      end
    end
  end
end

-- Backlog: check all stored kill progress on login and award any completions earned.
-- Also scans LeafVE_DB.pointHistory for "Instance completion: <Zone>" entries so that
-- dungeons cleared before the achievement addon was installed are retroactively credited.
function LeafVE_AchTest:CheckBacklogAchievements()
  local me = ShortName(UnitName("player"))
  if not me then return end
  EnsureDB()
  local dp = LeafVE_AchTest_DB.dungeonProgress
  local rp = LeafVE_AchTest_DB.raidProgress
  if dp and dp[me] then
    for dungId, killed in pairs(dp[me]) do
      local achId = "dung_"..dungId.."_complete"
      if ACHIEVEMENTS[achId] and not self:HasAchievement(me, achId) then
        local bossList = DUNGEON_BOSSES[dungId]
        if bossList then
          local allDone = true
          for _, b in ipairs(bossList) do
            if not killed[b] then allDone = false; break end
          end
          if allDone then self:AwardAchievement(achId, true) end
        end
      end
    end
  end
  if rp and rp[me] then
    for raidId, killed in pairs(rp[me]) do
      local achId = "raid_"..raidId.."_complete"
      if ACHIEVEMENTS[achId] and not self:HasAchievement(me, achId) then
        local bossList = RAID_BOSSES[raidId]
        if bossList then
          local allDone = true
          for _, b in ipairs(bossList) do
            if not killed[b] then allDone = false; break end
          end
          if allDone then self:AwardAchievement(achId, true) end
        end
      end
    end
  end

  -- Re-check meta achievements based on what has been awarded so far
  self:CheckMetaAchievements()

  -- Check honorable kill milestones via API (triggers on login/backlog)
  if GetPVPLifetimeHonorableKills then
    local hkTotal = GetPVPLifetimeHonorableKills() or 0
    if hkTotal >= 50    then self:AwardAchievement("pvp_hk_50",    true) end
    if hkTotal >= 100   then self:AwardAchievement("pvp_hk_100",   true) end
    if hkTotal >= 250   then self:AwardAchievement("pvp_hk_250",   true) end
    if hkTotal >= 1000  then self:AwardAchievement("pvp_hk_1000",  true) end
    if hkTotal >= 2500  then self:AwardAchievement("pvp_hk_2500",  true) end
    if hkTotal >= 5000  then self:AwardAchievement("pvp_hk_5000",  true) end
    if hkTotal >= 10000 then self:AwardAchievement("pvp_hk_10000", true) end
  end

  -- Scan LeafVE_DB point history for previously tracked instance completions.
  -- If LeafVillageLegends recorded "Instance completion: <Zone>", credit the
  -- corresponding dungeon clear achievement (the run was validated by that addon).
  if LeafVE_DB and LeafVE_DB.pointHistory and LeafVE_DB.pointHistory[me] then
    for _, entry in ipairs(LeafVE_DB.pointHistory[me]) do
      local zone = entry.reason and string.match(entry.reason, "^Instance completion: (.+)$")
      if zone then
        local achId = ZONE_TO_DUNGEON_ACH[zone]
        if achId and ACHIEVEMENTS[achId] and not self:HasAchievement(me, achId) then
          self:AwardAchievement(achId, true)
          Debug("Backlog from history: "..achId.." ("..zone..")")
        end
      end
    end
  end
end

-- Backlog: check profession skill levels via API and award any earned achievements
function LeafVE_AchTest:CheckProfessionAchievements()
  local profMap = {
    ["Alchemy"]       = "prof_alchemy_300",
    ["Blacksmithing"] = "prof_blacksmithing_300",
    ["Enchanting"]    = "prof_enchanting_300",
    ["Engineering"]   = "prof_engineering_300",
    ["Herbalism"]     = "prof_herbalism_300",
    ["Leatherworking"]= "prof_leatherworking_300",
    ["Mining"]        = "prof_mining_300",
    ["Skinning"]      = "prof_skinning_300",
    ["Tailoring"]     = "prof_tailoring_300",
    ["Fishing"]       = "prof_fishing_300",
    ["Cooking"]       = "prof_cooking_300",
    ["First Aid"]     = "prof_firstaid_300",
  }
  local artisanCount = 0
  local numSkills = GetNumSkillLines and GetNumSkillLines() or 0
  for i = 1, numSkills do
    local skillName, isHeader, _, skillRank = GetSkillLineInfo(i)
    if skillName and not isHeader then
      local achId = profMap[skillName]
      if achId and skillRank and skillRank >= 300 then
        self:AwardAchievement(achId, true)
        if PRIMARY_PROFESSION_NAMES[skillName] then
          artisanCount = artisanCount + 1
        end
      end
    end
  end
  if artisanCount >= 2 then
    self:AwardAchievement("prof_dual_artisan", true)
  end
end

-- Maps boss name to a safe counter key used in progressCounters
local BOSS_KILL_COUNTER = {
  ["Ragnaros"]            = "boss_Ragnaros",
  ["Nefarian"]            = "boss_Nefarian",
  ["Kel'Thuzad"]          = "boss_KelThuzad",
  ["C'Thun"]              = "boss_CThun",
  ["General Drakkisath"]  = "boss_Drakkisath",
  ["Darkmaster Gandling"] = "boss_Gandling",
  ["Baron Rivendare"]     = "boss_BaronRiv",
  ["Onyxia"]              = "boss_Onyxia",
  ["Hakkar"]              = "boss_Hakkar",
}

-- All raid completion achievement IDs — used by the meta achievement check
local ALL_RAID_COMPLETE_IDS = {
  "raid_zg_complete","raid_aq20_complete","raid_mc_complete","raid_onyxia_complete",
  "raid_bwl_complete","raid_aq40_complete","raid_naxx_complete",
  "raid_es_complete","raid_lkh_complete","raid_ukh_complete",
}
-- All dungeon completion achievement IDs — used by the meta achievement check
local ALL_DUNGEON_COMPLETE_IDS = {
  "dung_rfc_complete","dung_wc_complete","dung_dm_complete","dung_sfk_complete",
  "dung_bfd_complete","dung_stocks_complete","dung_tcg_complete","dung_gnomer_complete",
  "dung_rfk_complete","dung_sm_gy_complete","dung_sm_lib_complete","dung_sm_arm_complete",
  "dung_sm_cat_complete","dung_swr_complete","dung_rfdown_complete","dung_ulda_complete",
  "dung_gc_complete","dung_mara_complete","dung_zf_complete","dung_st_complete",
  "dung_hq_complete","dung_brd_complete","dung_dme_complete","dung_dmw_complete",
  "dung_dmn_complete","dung_scholo_complete","dung_strat_complete","dung_lbrs_complete",
  "dung_ubrs_complete","dung_kc_complete","dung_cotbm_complete","dung_swv_complete",
  "dung_dmr_complete",
}

function LeafVE_AchTest:CheckMetaAchievements()
  local me = ShortName(UnitName("player"))
  if not me then return end
  local allRaids = true
  for _, id in ipairs(ALL_RAID_COMPLETE_IDS) do
    if not self:HasAchievement(me, id) then allRaids = false; break end
  end
  if allRaids then self:AwardAchievement("elite_all_raids_complete", true) end
  local allDungeons = true
  for _, id in ipairs(ALL_DUNGEON_COMPLETE_IDS) do
    if not self:HasAchievement(me, id) then allDungeons = false; break end
  end
  if allDungeons then self:AwardAchievement("elite_all_dungeons_complete", true) end
end

function LeafVE_AchTest:CheckBossKill(bossName)
  -- Ignore regular elite mobs that are not tracked bosses
  if not (BOSS_ACHIEVEMENTS[bossName] or BOSS_TO_DUNGEON[bossName] or BOSS_TO_RAID[bossName]) then return end
  -- Award individual raid boss achievement if mapped
  if BOSS_ACHIEVEMENTS[bossName] then
    Debug("Raid boss kill: "..bossName)
    self:AwardAchievement(BOSS_ACHIEVEMENTS[bossName])
  end
  -- Track dungeon progress (awards completion when all bosses done)
  self:RecordDungeonBoss(bossName)
  -- Track raid progress (awards completion when all bosses done)
  self:RecordRaidBoss(bossName)
  -- Track per-boss, total, and unique kill counts
  local me = ShortName(UnitName("player"))
  if me then
    -- Per-boss counter for repeat-kill achievements
    local bossCounter = BOSS_KILL_COUNTER[bossName]
    if bossCounter then
      local n = IncrCounter(me, bossCounter)
      if bossCounter == "boss_Ragnaros" then
        if n >= 5  then self:AwardAchievement("elite_rag_5x",  true) end
        if n >= 10 then self:AwardAchievement("elite_rag_10x", true) end
      elseif bossCounter == "boss_Nefarian" then
        if n >= 5  then self:AwardAchievement("elite_nef_5x",  true) end
        if n >= 10 then self:AwardAchievement("elite_nef_10x", true) end
      elseif bossCounter == "boss_KelThuzad" then
        if n >= 3 then self:AwardAchievement("elite_kt_3x", true) end
        if n >= 5 then self:AwardAchievement("elite_kt_5x", true) end
      elseif bossCounter == "boss_CThun" then
        if n >= 5 then self:AwardAchievement("elite_cthun_5x", true) end
      elseif bossCounter == "boss_Drakkisath" then
        if n >= 5 then self:AwardAchievement("elite_drakkisath_5x", true) end
      elseif bossCounter == "boss_Gandling" then
        if n >= 5 then self:AwardAchievement("elite_gandling_5x", true) end
      elseif bossCounter == "boss_BaronRiv" then
        if n >= 5 then self:AwardAchievement("elite_baron_5x", true) end
      elseif bossCounter == "boss_Onyxia" then
        if n >= 5  then self:AwardAchievement("elite_onyxia_5x",  true) end
        if n >= 10 then self:AwardAchievement("elite_onyxia_10x", true) end
      elseif bossCounter == "boss_Hakkar" then
        if n >= 5 then self:AwardAchievement("elite_hakkar_5x", true) end
      end
    end
    -- Total boss kills
    local total = IncrCounter(me, "totalBossKills")
    if total >= 100 then self:AwardAchievement("elite_100_bosses", true) end
    if total >= 250 then self:AwardAchievement("elite_250_bosses", true) end
    if total >= 500 then self:AwardAchievement("elite_500_bosses", true) end
    -- Unique boss kills (first kill of each boss name)
    EnsureDB()
    local pc = LeafVE_AchTest_DB.progressCounters
    if not pc[me] then pc[me] = {} end
    local killedKey = "killed_"..string.gsub(bossName, "[^%w]", "_")
    if not pc[me][killedKey] then
      pc[me][killedKey] = true
      local unique = IncrCounter(me, "uniqueBossKills")
      if unique >= 25 then self:AwardAchievement("elite_25_unique_bosses", true) end
      if unique >= 50 then self:AwardAchievement("elite_50_unique_bosses", true) end
    end
  end
end

-- Virtual-scroll constants for the achievement list.
-- Card row color constants (shared by CreateAchievementRow and UpdateVisibleAchievements)
local CARD_BG_D     = {0.06, 0.06, 0.06, 0.90}   -- default card bg
local CARD_BG_H     = {0.11, 0.10, 0.07, 0.95}   -- hover card bg
local CARD_BORD_CMP = {0.85, 0.70, 0.25, 0.95}   -- completed border (soft gold)
local CARD_BORD_INC = {0.25, 0.40, 0.25, 0.90}   -- incomplete border (muted green)
local CARD_BORD_CH  = {1.00, 0.85, 0.30, 1.00}   -- completed hover border
local CARD_BORD_IH  = {0.35, 0.55, 0.35, 1.00}   -- incomplete hover border

-- Apply a flat backdrop style to a tab/filter button.
-- isActive=true → gold border; false → grey border.
local function StyleTabFlat(btn, isActive)
  if not btn then return end
  local nt = btn:GetNormalTexture()
  local pt = btn:GetPushedTexture()
  local ht = btn:GetHighlightTexture()
  if nt then nt:SetAlpha(0) end
  if pt then pt:SetAlpha(0) end
  if ht then ht:SetAlpha(0) end
  btn:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = {left=2, right=2, top=2, bottom=2}
  })
  btn:SetBackdropColor(0.06, 0.06, 0.06, 0.90)
  if isActive then
    btn:SetBackdropBorderColor(0.85, 0.70, 0.25, 0.95)
  else
    btn:SetBackdropBorderColor(0.28, 0.28, 0.30, 0.90)
  end
end

-- Public alias so external callers can also invoke it.
LeafVE_StyleTabButton = StyleTabFlat

-- ── Shared modern backdrop definition (panel/button style) ───────────────
local MODERN_BD_PANEL = {
  bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 8,
  insets = {left=3, right=3, top=3, bottom=3},
}

-- ── LeafVE_ApplyModernBackdrop: apply a named backdrop style to any frame ─
-- styleKey is reserved for future backdrop variants; currently always applies
-- the shared dark panel style.
function LeafVE_ApplyModernBackdrop(frame, styleKey)
  if not frame then return end
  frame:SetBackdrop(MODERN_BD_PANEL)
end

-- ── LeafVE_StyleButton: flat modern nav/action button with hover effect ───
-- isActive=true → gold border + slightly brighter bg
-- isActive=false → grey border + dark bg
local BTN_ACT_BG      = {0.10, 0.09, 0.05, 0.95}
local BTN_ACT_BORD    = {0.85, 0.70, 0.25, 0.95}
local BTN_ACT_BG_H    = {0.14, 0.12, 0.06, 0.95}
local BTN_ACT_BORD_H  = {1.00, 0.85, 0.35, 1.00}
local BTN_INACT_BG    = {0.06, 0.06, 0.07, 0.90}
local BTN_INACT_BORD  = {0.28, 0.28, 0.30, 0.90}
local BTN_INACT_BG_H  = {0.10, 0.10, 0.12, 0.95}
local BTN_INACT_BORD_H = {0.45, 0.45, 0.48, 1.00}

function LeafVE_StyleButton(btn, isActive)
  if not btn then return end
  local nt = btn:GetNormalTexture()
  local pt = btn:GetPushedTexture()
  local ht = btn:GetHighlightTexture()
  if nt then nt:SetAlpha(0) end
  if pt then pt:SetAlpha(0) end
  if ht then ht:SetAlpha(0) end
  btn:SetBackdrop(MODERN_BD_PANEL)
  btn._leafveActive = isActive
  if isActive then
    btn:SetBackdropColor(BTN_ACT_BG[1],   BTN_ACT_BG[2],   BTN_ACT_BG[3],   BTN_ACT_BG[4])
    btn:SetBackdropBorderColor(BTN_ACT_BORD[1], BTN_ACT_BORD[2], BTN_ACT_BORD[3], BTN_ACT_BORD[4])
  else
    btn:SetBackdropColor(BTN_INACT_BG[1],   BTN_INACT_BG[2],   BTN_INACT_BG[3],   BTN_INACT_BG[4])
    btn:SetBackdropBorderColor(BTN_INACT_BORD[1], BTN_INACT_BORD[2], BTN_INACT_BORD[3], BTN_INACT_BORD[4])
  end
  btn:SetScript("OnEnter", function()
    if this._leafveActive then
      this:SetBackdropColor(BTN_ACT_BG_H[1],   BTN_ACT_BG_H[2],   BTN_ACT_BG_H[3],   BTN_ACT_BG_H[4])
      this:SetBackdropBorderColor(BTN_ACT_BORD_H[1], BTN_ACT_BORD_H[2], BTN_ACT_BORD_H[3], BTN_ACT_BORD_H[4])
    else
      this:SetBackdropColor(BTN_INACT_BG_H[1],   BTN_INACT_BG_H[2],   BTN_INACT_BG_H[3],   BTN_INACT_BG_H[4])
      this:SetBackdropBorderColor(BTN_INACT_BORD_H[1], BTN_INACT_BORD_H[2], BTN_INACT_BORD_H[3], BTN_INACT_BORD_H[4])
    end
  end)
  btn:SetScript("OnLeave", function()
    if this._leafveActive then
      this:SetBackdropColor(BTN_ACT_BG[1],   BTN_ACT_BG[2],   BTN_ACT_BG[3],   BTN_ACT_BG[4])
      this:SetBackdropBorderColor(BTN_ACT_BORD[1], BTN_ACT_BORD[2], BTN_ACT_BORD[3], BTN_ACT_BORD[4])
    else
      this:SetBackdropColor(BTN_INACT_BG[1],   BTN_INACT_BG[2],   BTN_INACT_BG[3],   BTN_INACT_BG[4])
      this:SetBackdropBorderColor(BTN_INACT_BORD[1], BTN_INACT_BORD[2], BTN_INACT_BORD[3], BTN_INACT_BORD[4])
    end
  end)
end

-- ── LeafVE_StyleInputBox: modern dark styled edit box ────────────────────
function LeafVE_StyleInputBox(editBox)
  if not editBox then return end
  editBox:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = {left=4, right=4, top=3, bottom=3},
  })
  editBox:SetBackdropColor(0.03, 0.03, 0.04, 0.95)
  editBox:SetBackdropBorderColor(0.35, 0.35, 0.38, 0.90)
  editBox:SetTextInsets(8, 8, 0, 0)
end

-- ── LeafVE_StyleScrollBar: dark modern scrollbar track + thumb ────────────
function LeafVE_StyleScrollBar(scrollBar)
  if not scrollBar then return end
  scrollBar:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = {left=2, right=2, top=2, bottom=2},
  })
  scrollBar:SetBackdropColor(0.04, 0.04, 0.05, 0.90)
  scrollBar:SetBackdropBorderColor(0.22, 0.22, 0.24, 0.75)
  scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  local thumb = scrollBar:GetThumbTexture()
  if thumb then
    thumb:SetVertexColor(0.50, 0.50, 0.55, 0.85)
  end
end

-- ── LeafVE_StyleCategoryButton: sidebar filter row with left accent bar ───
-- Creates (once) a 3-px accent bar on the left edge and manages active state.
function LeafVE_StyleCategoryButton(btn, isActive)
  if not btn then return end
  if not btn._accentBar then
    local bar = btn:CreateTexture(nil, "OVERLAY")
    bar:SetWidth(3)
    bar:SetPoint("TOPLEFT",    btn, "TOPLEFT",  0, 0)
    bar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
    bar:SetTexture(1, 1, 1, 1)
    btn._accentBar = bar
  end
  if isActive then
    btn:SetBackdropColor(0.10, 0.42, 0.16, 0.60)
    btn.label:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])
    btn._accentBar:SetVertexColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 0.90)
    btn._accentBar:Show()
  else
    btn:SetBackdropColor(0, 0, 0, 0)
    btn.label:SetTextColor(0.78, 0.78, 0.78)
    btn._accentBar:Hide()
  end
end

-- ACH_ROW_H: pixel height of each achievement row.
-- ACH_POOL:  number of recycled frame slots (covers visible area + buffer).
local ACH_ROW_H = 64
local ACH_POOL  = 14

-- Enable/disable the gold shimmer pulse on a badge frame.
-- Only call with enable=true for completed achievements with points >= 20.
local function ShimmerOnUpdate()
  this._shimmerElapsed = (this._shimmerElapsed or 0) + arg1
  local alpha = 0.20 + 0.15 * math.sin(this._shimmerElapsed * math.pi)
  this.Shimmer:SetAlpha(alpha)
end

local function SetBadgeShimmer(badge, enable)
  if enable then
    if not badge._shimmerElapsed then badge._shimmerElapsed = 0 end
    badge:SetScript("OnUpdate", ShimmerOnUpdate)
  else
    badge:SetScript("OnUpdate", nil)
    badge.Shimmer:SetAlpha(0)
    badge._shimmerElapsed = nil
  end
end

-- Create one card-style achievement row frame attached to `parent`.
local function CreateAchievementRow(parent)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetWidth(660)
  frame:SetHeight(60)
  frame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left=3, right=3, top=3, bottom=3}
  })
  frame:SetBackdropColor(CARD_BG_D[1], CARD_BG_D[2], CARD_BG_D[3], CARD_BG_D[4])
  frame:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.90)

  -- Icon (left, 38px with cropped texcoords)
  local icon = frame:CreateTexture(nil, "ARTWORK")
  icon:SetWidth(38)
  icon:SetHeight(38)
  icon:SetPoint("LEFT", frame, "LEFT", 10, 2)
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  frame.icon = icon

  -- Checkmark overlay
  local checkmark = frame:CreateTexture(nil, "OVERLAY")
  checkmark:SetWidth(18)
  checkmark:SetHeight(18)
  checkmark:SetPoint("CENTER", icon, "TOPRIGHT", -2, -2)
  checkmark:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  frame.checkmark = checkmark

  -- Title FontString (top-left of text area, bright)
  local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -4)
  name:SetWidth(460)
  name:SetJustifyH("LEFT")
  frame.name = name

  -- Description FontString (below title, slightly brighter)
  local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
  desc:SetWidth(460)
  desc:SetJustifyH("LEFT")
  frame.desc = desc

  -- Points badge (right side, 44x44 golden badge icon with "X pts" text)
  local badge = CreateFrame("Frame", nil, frame)
  badge:SetWidth(44)
  badge:SetHeight(44)
  badge:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
  badge:SetFrameLevel(frame:GetFrameLevel() + 3)
  frame.badge = badge
  frame.PointBadge = badge

  local badgeIcon = badge:CreateTexture(nil, "ARTWORK")
  badgeIcon:SetAllPoints()
  badgeIcon:SetTexture("Interface\\Icons\\Spell_Nature_ResistNature")
  badgeIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  badgeIcon:SetDrawLayer("ARTWORK", 2)
  badge.Icon = badgeIcon

  local badgeText = badge:CreateFontString(nil, "OVERLAY")
  badgeText:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE")
  badgeText:SetPoint("CENTER", badge, "CENTER", 0, 0)
  badgeText:SetJustifyH("CENTER")
  badgeText:SetDrawLayer("OVERLAY", 7)
  badge.Text = badgeText

  -- Shimmer texture for high-value (>= 20 pts) completed achievements
  local shimmer = badge:CreateTexture(nil, "OVERLAY")
  shimmer:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
  shimmer:SetBlendMode("ADD")
  shimmer:SetAlpha(0)
  shimmer:SetPoint("CENTER", badge, "CENTER", 0, 0)
  shimmer:SetWidth(58)
  shimmer:SetHeight(58)
  shimmer:SetDrawLayer("OVERLAY", 6)
  badge.Shimmer = shimmer

  -- Stop shimmer when badge (and its parent row) is hidden
  badge:SetScript("OnHide", function()
    this:SetScript("OnUpdate", nil)
    this.Shimmer:SetAlpha(0)
    this._shimmerElapsed = nil
  end)

  -- Status text (right-aligned, below badge)
  local status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  status:SetPoint("TOPRIGHT", badge, "BOTTOMRIGHT", 0, -2)
  status:SetJustifyH("RIGHT")
  frame.status = status

  -- Progress bar background texture
  local barBg = frame:CreateTexture(nil, "BACKGROUND")
  barBg:SetHeight(10)
  barBg:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 6)
  barBg:SetPoint("BOTTOMRIGHT", badge, "BOTTOMLEFT", -4, 6)
  barBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
  barBg:SetVertexColor(0.08, 0.08, 0.08, 0.85)
  barBg:Hide()
  frame.barBg = barBg

  -- Progress bar (StatusBar, for rep/progress achievements)
  local bar = CreateFrame("StatusBar", nil, frame)
  bar:SetHeight(10)
  bar:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 6)
  bar:SetPoint("BOTTOMRIGHT", badge, "BOTTOMLEFT", -4, 6)
  bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  bar:SetStatusBarColor(0.3, 0.7, 0.3, 1)
  bar:SetMinMaxValues(0, 1)
  bar:SetValue(0)
  bar:Hide()
  frame.bar = bar

  -- Progress text (right-aligned on bar)
  local barText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  barText:SetAllPoints(bar)
  barText:SetJustifyH("RIGHT")
  barText:SetJustifyV("MIDDLE")
  barText:Hide()
  frame.barText = barText

  -- ── Row API methods ──────────────────────────────────────────────────────
  frame.SetData = function(self, data)
    self.achData = data
    self.icon:SetTexture(data.iconTexture or data.icon)
    self.name:SetText(data.title or data.name or "")
    self.desc:SetText(data.description or data.desc or "")
    self.badge.Text:SetText(tostring(data.points or 0).." pts")
    self:SetCompleted(data.isCompleted or false)
    if data.progressCur and data.progressMax and data.progressMax > 0 then
      self:SetProgress(data.progressCur, data.progressMax, true)
    else
      self:SetProgress(nil, nil, false)
    end
  end

  frame.SetCompleted = function(self, completed)
    self.achCompleted = completed
    if completed then
      self.icon:SetDesaturated(false)
      self.icon:SetAlpha(1)
      self.checkmark:Show()
      self:SetBackdropColor(CARD_BG_D[1], CARD_BG_D[2], CARD_BG_D[3], CARD_BG_D[4])
      self:SetBackdropBorderColor(CARD_BORD_CMP[1], CARD_BORD_CMP[2], CARD_BORD_CMP[3], CARD_BORD_CMP[4])
      self.badge.Icon:SetVertexColor(THEME.gold[1], THEME.gold[2], THEME.gold[3])
      self.name:SetTextColor(1.00, 0.95, 0.70)
      self.desc:SetTextColor(0.80, 0.80, 0.80)
      self.status:SetText("Completed")
      self.status:SetTextColor(0.4, 0.8, 0.4)
    else
      self.icon:SetDesaturated(true)
      self.icon:SetAlpha(0.5)
      self.checkmark:Hide()
      self:SetBackdropColor(CARD_BG_D[1], CARD_BG_D[2], CARD_BG_D[3], CARD_BG_D[4])
      self:SetBackdropBorderColor(CARD_BORD_INC[1], CARD_BORD_INC[2], CARD_BORD_INC[3], CARD_BORD_INC[4])
      self.badge.Icon:SetVertexColor(0.5, 0.5, 0.5)
      self.name:SetTextColor(0.70, 0.70, 0.70)
      self.desc:SetTextColor(0.50, 0.50, 0.50)
      self.status:SetText("In Progress")
      self.status:SetTextColor(0.55, 0.55, 0.55)
    end
  end

  frame.SetProgress = function(self, cur, max, showText)
    if not max or max <= 0 then
      self.bar:Hide()
      self.barBg:Hide()
      self.barText:Hide()
      return
    end
    self.barBg:Show()
    self.bar:Show()
    self.bar:SetMinMaxValues(0, max)
    self.bar:SetValue(math.min(cur or 0, max))
    local pct = (cur or 0) / max
    self.bar:SetStatusBarColor(0.20 + pct * 0.60, 0.55, 0.20, 1)
    if showText then
      self.barText:Show()
      self.barText:SetText(tostring(cur or 0).." / "..tostring(max))
    else
      self.barText:Hide()
    end
  end

  -- ── Hover effect (cheap: backdrop color only, no OnUpdate) ───────────────
  frame:EnableMouse(true)
  frame:SetScript("OnEnter", function()
    this:SetBackdropColor(CARD_BG_H[1], CARD_BG_H[2], CARD_BG_H[3], CARD_BG_H[4])
    if this.achCompleted then
      this:SetBackdropBorderColor(CARD_BORD_CH[1], CARD_BORD_CH[2], CARD_BORD_CH[3], CARD_BORD_CH[4])
    else
      this:SetBackdropBorderColor(CARD_BORD_IH[1], CARD_BORD_IH[2], CARD_BORD_IH[3], CARD_BORD_IH[4])
    end
    local ad = this.achData
    local me = this.achPlayerName
    if not ad then return end
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    if this.achCompleted then
      GameTooltip:SetText(ad.name, THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 1, true)
      GameTooltip:AddLine("|cFF888888"..ad.category.."|r", 1, 1, 1)
      GameTooltip:AddLine(ad.desc, 1, 1, 1, true)
      GameTooltip:AddLine(" ", 1, 1, 1)
      GameTooltip:AddLine("Earned: "..date("%m/%d/%Y", this.achTimestamp), 0.5, 0.8, 0.5)
    else
      GameTooltip:SetText(ad.name, 0.6, 0.6, 0.6, 1, true)
      GameTooltip:AddLine("|cFF888888"..ad.category.."|r", 1, 1, 1)
      GameTooltip:AddLine(ad.desc, 0.7, 0.7, 0.7, true)
      GameTooltip:AddLine(" ", 1, 1, 1)
      local prog = GetAchievementProgress(me, ad.id)
      if prog then
        if ad.id == "elite_ironman" then
          local label = prog.current == 0 and "|cFF00CC00No deaths recorded|r" or
                        "|cFFFF4444"..prog.current.." death(s) recorded — run invalidated|r"
          GameTooltip:AddLine(label, 1, 1, 1)
        else
          GameTooltip:AddLine(string.format("Progress: %d / %d", prog.current, prog.goal), 0.6, 0.8, 1.0)
        end
      end
      if ad.manual then
        GameTooltip:AddLine("|cFFFF8800Requires officer grant: /achgrant <name> "..ad.id.."|r", 1, 1, 1, true)
      else
        GameTooltip:AddLine("Not yet earned", 0.8, 0.4, 0.4)
      end
    end
    GameTooltip:AddLine(" ", 1, 1, 1)
    GameTooltip:AddLine(ad.points.." Achievement Points", 1.0, 0.5, 0.0)
    -- ── Dungeon / Raid boss criteria ──────────────────────────────────────
    if ad.criteria_key and (ad.criteria_type == "dungeon" or ad.criteria_type == "raid") then
      local bossList, progress
      if ad.criteria_type == "dungeon" then
        bossList = DUNGEON_BOSSES[ad.criteria_key]
        local dp = LeafVE_AchTest_DB and LeafVE_AchTest_DB.dungeonProgress
        progress = dp and dp[me] and dp[me][ad.criteria_key]
      elseif ad.criteria_type == "raid" then
        bossList = RAID_BOSSES[ad.criteria_key]
        local rp = LeafVE_AchTest_DB and LeafVE_AchTest_DB.raidProgress
        progress = rp and rp[me] and rp[me][ad.criteria_key]
      end
      if bossList then
        local killed, total = 0, table.getn(bossList)
        GameTooltip:AddLine(" ", 1, 1, 1)
        for _, bossName in ipairs(bossList) do
          if progress and progress[bossName] then
            killed = killed + 1
            GameTooltip:AddLine("|cFF00CC00[x]|r "..bossName, 0.9, 0.9, 0.9)
          else
            GameTooltip:AddLine("|cFF666666[ ]|r "..bossName, 0.5, 0.5, 0.5)
          end
        end
        GameTooltip:AddLine(string.format("Criteria: %d / %d bosses", killed, total), 1.0, 0.82, 0.2)
      end
    end
    -- ── Dungeon Completionist meta criteria ───────────────────────────────
    if ad.criteria_type == "dungeon_meta" then
      local done, total = 0, table.getn(ALL_DUNGEON_COMPLETE_IDS)
      GameTooltip:AddLine(" ", 1, 1, 1)
      for _, dachId in ipairs(ALL_DUNGEON_COMPLETE_IDS) do
        local dach = ACHIEVEMENTS[dachId]
        if dach then
          if LeafVE_AchTest:HasAchievement(me, dachId) then
            done = done + 1
            GameTooltip:AddLine("|cFF00CC00[x]|r "..dach.name, 0.9, 0.9, 0.9)
          else
            GameTooltip:AddLine("|cFF666666[ ]|r "..dach.name, 0.5, 0.5, 0.5)
          end
        end
      end
      GameTooltip:AddLine(string.format("Criteria: %d / %d dungeons", done, total), 1.0, 0.82, 0.2)
    end
    -- ── Raid Completionist meta criteria ──────────────────────────────────
    if ad.criteria_type == "raid_meta" then
      local done, total = 0, table.getn(ALL_RAID_COMPLETE_IDS)
      GameTooltip:AddLine(" ", 1, 1, 1)
      for _, rachId in ipairs(ALL_RAID_COMPLETE_IDS) do
        local rach = ACHIEVEMENTS[rachId]
        if rach then
          if LeafVE_AchTest:HasAchievement(me, rachId) then
            done = done + 1
            GameTooltip:AddLine("|cFF00CC00[x]|r "..rach.name, 0.9, 0.9, 0.9)
          else
            GameTooltip:AddLine("|cFF666666[ ]|r "..rach.name, 0.5, 0.5, 0.5)
          end
        end
      end
      GameTooltip:AddLine(string.format("Criteria: %d / %d raids", done, total), 1.0, 0.82, 0.2)
    end
    -- ── Zone-group exploration criteria ───────────────────────────────────
    if ad.criteria_type == "zone_group" and ad.criteria_key then
      local zones = ZONE_GROUP_ZONES[ad.criteria_key]
      if zones then
        local pz = LeafVE_AchTest_DB and LeafVE_AchTest_DB.exploredZones
        local myZones = pz and pz[me]
        local found, total = 0, table.getn(zones)
        GameTooltip:AddLine(" ", 1, 1, 1)
        for _, z in ipairs(zones) do
          if myZones and myZones[z] then
            found = found + 1
            GameTooltip:AddLine("|cFF00CC00[x]|r "..z, 0.9, 0.9, 0.9)
          else
            GameTooltip:AddLine("|cFF666666[ ]|r "..z, 0.5, 0.5, 0.5)
          end
        end
        GameTooltip:AddLine(string.format("Discovered: %d / %d locations", found, total), 1.0, 0.82, 0.2)
      end
    end
    -- ── Continent exploration criteria (Kalimdor / Eastern Kingdoms) ──────
    if ad.criteria_type == "continent" and ad.criteria_key then
      local reqZones, reqSet, reqTotal
      if ad.criteria_key == "kalimdor" then
        reqZones = REQUIRED_KALIMDOR_ZONES; reqSet = KALIMDOR_SUBZONE_SET; reqTotal = KALIMDOR_REQUIRED_TOTAL
      elseif ad.criteria_key == "eastern_kingdoms" then
        reqZones = REQUIRED_EK_ZONES; reqSet = EK_SUBZONE_SET; reqTotal = EK_REQUIRED_TOTAL
      end
      if reqZones and reqSet then
        local pz = LeafVE_AchTest_DB and LeafVE_AchTest_DB.exploredZones
        local myZones = pz and pz[me]
        local found = 0
        GameTooltip:AddLine(" ", 1, 1, 1)
        -- Show per-zone progress (grouped)
        for zoneName, subzones in pairs(reqZones) do
          local zFound, zTotal = 0, table.getn(subzones)
          for _, sz in ipairs(subzones) do
            if myZones and myZones[sz] then zFound = zFound + 1; found = found + 1 end
          end
          local color = (zFound == zTotal) and "|cFF00CC00" or "|cFFFF8800"
          GameTooltip:AddLine(color..zoneName..": "..zFound.."/"..zTotal.."|r", 0.9, 0.9, 0.9)
        end
        GameTooltip:AddLine(string.format("Discovered: %d / %d locations", found, reqTotal), 1.0, 0.82, 0.2)
      end
    end
    -- ── World Explorer meta criteria ───────────────────────────────────────
    if ad.criteria_type == "world_explorer_meta" then
      GameTooltip:AddLine(" ", 1, 1, 1)
      local done, total = 0, 2 + table.getn(WORLD_EXPLORER_TW_IDS)
      -- Continent achievements
      for _, contId in ipairs({"explore_kalimdor","explore_eastern_kingdoms"}) do
        local cach = ACHIEVEMENTS[contId]
        if cach then
          if LeafVE_AchTest:HasAchievement(me, contId) then
            done = done + 1
            GameTooltip:AddLine("|cFF00CC00[x]|r "..cach.name, 0.9, 0.9, 0.9)
          else
            GameTooltip:AddLine("|cFF666666[ ]|r "..cach.name, 0.5, 0.5, 0.5)
          end
        end
      end
      -- TW zone-group achievements
      for _, twId in ipairs(WORLD_EXPLORER_TW_IDS) do
        local tach = ACHIEVEMENTS[twId]
        if tach then
          if LeafVE_AchTest:HasAchievement(me, twId) then
            done = done + 1
            GameTooltip:AddLine("|cFF00CC00[x]|r "..tach.name, 0.9, 0.9, 0.9)
          else
            GameTooltip:AddLine("|cFF666666[ ]|r "..tach.name, 0.5, 0.5, 0.5)
          end
        end
      end
      GameTooltip:AddLine(string.format("Criteria: %d / %d", done, total), 1.0, 0.82, 0.2)
    end
    -- ── Quest chain step criteria ─────────────────────────────────────────
    if ad._questSteps then
      local cq = LeafVE_AchTest_DB and LeafVE_AchTest_DB.completedQuests
      local myQ = cq and cq[me]
      local done, total = 0, table.getn(ad._questSteps)
      GameTooltip:AddLine(" ", 1, 1, 1)
      for _, step in ipairs(ad._questSteps) do
        if myQ and myQ[string.lower(step)] then
          done = done + 1
          GameTooltip:AddLine("|cFF00CC00[x]|r "..step, 0.9, 0.9, 0.9)
        else
          GameTooltip:AddLine("|cFF666666[ ]|r "..step, 0.5, 0.5, 0.5)
        end
      end
      GameTooltip:AddLine(string.format("Progress: %d / %d quests", done, total), 1.0, 0.82, 0.2)
    end
    GameTooltip:Show()
  end)
  frame:SetScript("OnLeave", function()
    this:SetBackdropColor(CARD_BG_D[1], CARD_BG_D[2], CARD_BG_D[3], CARD_BG_D[4])
    if this.achCompleted then
      this:SetBackdropBorderColor(CARD_BORD_CMP[1], CARD_BORD_CMP[2], CARD_BORD_CMP[3], CARD_BORD_CMP[4])
    else
      this:SetBackdropBorderColor(CARD_BORD_INC[1], CARD_BORD_INC[2], CARD_BORD_INC[3], CARD_BORD_INC[4])
    end
    GameTooltip:Hide()
  end)
  return frame
end

-- Public API: create a card row frame.  Accepts an optional `index` argument
-- (ignored internally) so external callers can pass a row index if needed.
LeafVE_CreateAchievementRow = function(parent, index)
  return CreateAchievementRow(parent)
end

function LeafVE_AchTest.UI:Build()
  if self.frame then
    self.frame:Show()
    self:Refresh()
    return
  end
  
  local f = CreateFrame("Frame", "LeafVE_AchTestFrame", UIParent)
  self.frame = f
  f:SetPoint("CENTER", 0, 0)
  f:SetWidth(870)
  f:SetHeight(520)
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function() f:StartMoving() end)
  f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
  f:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  f:SetBackdropColor(THEME.bg[1], THEME.bg[2], THEME.bg[3], THEME.bg[4])
  f:SetBackdropBorderColor(THEME.border[1], THEME.border[2], THEME.border[3], 1)
  
  -- Header background bar (fully opaque, dark green tint)
  local headerBG = f:CreateTexture(nil, "BACKGROUND")
  headerBG:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
  headerBG:SetPoint("TOPLEFT",  f, "TOPLEFT",  0,  0)
  headerBG:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0,  0)
  headerBG:SetHeight(56)
  headerBG:SetVertexColor(0.04, 0.08, 0.05, 1)

  -- Leaf-coloured accent line at the bottom of the header bar
  local headerAccent = f:CreateTexture(nil, "ARTWORK")
  headerAccent:SetTexture("Interface\\Tooltips\\UI-Tooltip-Separator")
  headerAccent:SetHeight(2)
  headerAccent:SetPoint("TOPLEFT",  f, "TOPLEFT",  0, -54)
  headerAccent:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -54)
  headerAccent:SetVertexColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 1)

  -- Title shadow (depth effect — drawn first so it sits beneath the main title)
  local titleShadow = f:CreateFontString(nil, "OVERLAY")
  titleShadow:SetFont("Fonts\\MORPHEUS.ttf", 20)
  titleShadow:SetPoint("TOP", f, "TOP", 0, -17)
  titleShadow:SetText("LeafVE Achievement System")
  titleShadow:SetTextColor(0, 0, 0, 0.85)

  -- Main title (OUTLINE flag adds letter-edge depth on top of the shadow)
  local title = f:CreateFontString(nil, "OVERLAY")
  title:SetFont("Fonts\\MORPHEUS.ttf", 20, "OUTLINE")
  title:SetPoint("TOP", f, "TOP", 0, -15)
  title:SetText("LeafVE Achievement System")
  title:SetTextColor(THEME.gold[1], THEME.gold[2], THEME.gold[3])

  self.pointsLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  self.pointsLabel:SetPoint("TOP", f, "TOP", 0, -38)
  self.pointsLabel:SetTextColor(0.70, 0.70, 0.72)

  -- Divider line beneath the header (fully opaque, full-width to match header)
  local divider = f:CreateTexture(nil, "ARTWORK")
  divider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Separator")
  divider:SetHeight(16)
  divider:SetPoint("TOPLEFT",  f, "TOPLEFT",  0, -56)
  divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -56)

  -- Close button aligned top-right, clear of the header text
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)
  
  local achTab = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  achTab:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -75)
  achTab:SetWidth(100)
  achTab:SetHeight(25)
  achTab:SetText("Achievements")
  achTab:SetScript("OnClick", function()
    LeafVE_AchTest.UI.currentView = "achievements"
    LeafVE_AchTest.UI:Refresh()
  end)
  self.achTab = achTab
  
  local titlesTab = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  titlesTab:SetPoint("LEFT", achTab, "RIGHT", 5, 0)
  titlesTab:SetWidth(80)
  titlesTab:SetHeight(25)
  titlesTab:SetText("Titles")
  titlesTab:SetScript("OnClick", function()
    LeafVE_AchTest.UI.currentView = "titles"
    LeafVE_AchTest.UI:Refresh()
  end)
  self.titlesTab = titlesTab

  -- Apply modern flat style to tabs (Achievements = active by default)
  LeafVE_StyleButton(achTab, true)
  LeafVE_StyleButton(titlesTab, false)

  -- Award / Reset buttons (placed directly after the Titles tab)
  local awardBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  awardBtn:SetPoint("LEFT", titlesTab, "RIGHT", 15, 0)
  awardBtn:SetWidth(60)
  awardBtn:SetHeight(25)
  awardBtn:SetText("Award")
  awardBtn:SetScript("OnClick", function()
    local me = ShortName(UnitName("player") or "")
    local playerAchievements = LeafVE_AchTest:GetPlayerAchievements(me)
    local availableAchievements = {}
    for achID, achData in pairs(ACHIEVEMENTS) do
      if not playerAchievements[achID] then
        table.insert(availableAchievements, achID)
      end
    end
    if table.getn(availableAchievements) > 0 then
      local randomIndex = math.random(1, table.getn(availableAchievements))
      local randomAchID = availableAchievements[randomIndex]
      LeafVE_AchTest:AwardAchievement(randomAchID, false)
    else
      Print("You already have all achievements!")
    end
  end)
  LeafVE_StyleButton(awardBtn, false)
  self.awardBtn = awardBtn

  local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  resetBtn:SetPoint("LEFT", awardBtn, "RIGHT", 5, 0)
  resetBtn:SetWidth(60)
  resetBtn:SetHeight(25)
  resetBtn:SetText("Reset")
  resetBtn:SetScript("OnClick", function()
    LeafVE_AchTest_DB.achievements = {}
    LeafVE_AchTest_DB.selectedTitles = {}
    Print("Reset complete!")
    LeafVE_AchTest.UI:Refresh()
  end)
  LeafVE_StyleButton(resetBtn, false)

  -- ── Left sidebar: category navigation ───────────────────────────────────
  local sidebarFrame = CreateFrame("Frame", nil, f)
  sidebarFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -110)
  sidebarFrame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 8, 10)
  sidebarFrame:SetWidth(130)
  sidebarFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = {left=2, right=2, top=2, bottom=2},
  })
  sidebarFrame:SetBackdropColor(0.07, 0.07, 0.08, 0.92)
  sidebarFrame:SetBackdropBorderColor(0.28, 0.28, 0.30, 0.8)
  self.sidebarFrame = sidebarFrame

  -- Ordered list of categories shown in the sidebar
  local SIDEBAR_CATS = {
    {display="All",            filter="All"},
    {display="Leveling",       filter="Leveling"},
    {display="Quests",         filter="Quests"},
    {display="Professions",    filter="Professions"},
    {display="Skills",         filter="Skills"},
    {display="Dungeons",       filter="Dungeons"},
    {display="Raids",          filter="Raids"},
    {display="Exploration",    filter="Exploration"},
    {display="PvP",            filter="PvP"},
    {display="Gold",           filter="Gold"},
    {display="Elite",          filter="Elite"},
    {display="Casual",         filter="Casual"},
    {display="Kills",          filter="Kills"},
    {display="Identity",       filter="Identity"},
    {display="Reputation",     filter="Reputation"},
  }
  self.categoryButtons = {}
  for i, cat in ipairs(SIDEBAR_CATS) do
    local filterVal = cat.filter
    local btn = CreateFrame("Frame", nil, sidebarFrame)
    btn:SetPoint("TOPLEFT", sidebarFrame, "TOPLEFT", 4, -(i-1)*26 - 6)
    btn:SetWidth(122)
    btn:SetHeight(22)
    btn:EnableMouse(true)
    btn:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      tile = true, tileSize = 8,
      insets = {left=2, right=2, top=2, bottom=2},
    })
    btn:SetBackdropColor(0, 0, 0, 0)
    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT",     btn, "TOPLEFT",  9, 0)
    lbl:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, 0)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(cat.display)
    lbl:SetTextColor(0.78, 0.78, 0.78)
    btn.label     = lbl
    btn.filterValue = filterVal
    btn:SetScript("OnMouseDown", function()
      LeafVE_AchTest.UI.selectedCategory = this.filterValue
      LeafVE_AchTest.UI:Refresh()
    end)
    btn:SetScript("OnEnter", function()
      if this.filterValue ~= LeafVE_AchTest.UI.selectedCategory then
        this:SetBackdropColor(0.14, 0.14, 0.17, 0.65)
      end
    end)
    btn:SetScript("OnLeave", function()
      if this.filterValue ~= LeafVE_AchTest.UI.selectedCategory then
        this:SetBackdropColor(0, 0, 0, 0)
      end
    end)
    LeafVE_StyleCategoryButton(btn, false)
    table.insert(self.categoryButtons, btn)
  end

  -- ── Title Category Sidebar ───────────────────────────────────────────────
  local titleSidebarFrame = CreateFrame("Frame", nil, f)
  titleSidebarFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -145)
  titleSidebarFrame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 8, 10)
  titleSidebarFrame:SetWidth(130)
  titleSidebarFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = {left=2, right=2, top=2, bottom=2},
  })
  titleSidebarFrame:SetBackdropColor(0.07, 0.07, 0.08, 0.92)
  titleSidebarFrame:SetBackdropBorderColor(0.28, 0.28, 0.30, 0.8)
  titleSidebarFrame:Hide()
  self.titleSidebarFrame = titleSidebarFrame

  local TITLE_CATS = {
    {display="All",         filter="All"},
    {display="Obtained",    filter="Obtained"},
    {display="Leveling",    filter="Leveling"},
    {display="Raids",       filter="Raids"},
    {display="Elite",       filter="Elite"},
    {display="PvP",         filter="PvP"},
    {display="Profession",  filter="Profession"},
    {display="Dungeons",    filter="Dungeons"},
    {display="Kills",       filter="Kills"},
    {display="Exploration", filter="Exploration"},
    {display="Casual",      filter="Casual"},
    {display="Gold",        filter="Gold"},
    {display="Quests",      filter="Quests"},
  }
  self.titleCategoryButtons = {}
  for i, cat in ipairs(TITLE_CATS) do
    local filterVal = cat.filter
    local tbtn = CreateFrame("Frame", nil, titleSidebarFrame)
    tbtn:SetPoint("TOPLEFT", titleSidebarFrame, "TOPLEFT", 4, -(i-1)*26 - 6)
    tbtn:SetWidth(122)
    tbtn:SetHeight(22)
    tbtn:EnableMouse(true)
    tbtn:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      tile = true, tileSize = 8,
      insets = {left=2, right=2, top=2, bottom=2},
    })
    tbtn:SetBackdropColor(0, 0, 0, 0)
    local tlbl = tbtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tlbl:SetPoint("TOPLEFT",     tbtn, "TOPLEFT",  9, 0)
    tlbl:SetPoint("BOTTOMRIGHT", tbtn, "BOTTOMRIGHT", 2, 0)
    tlbl:SetJustifyH("LEFT")
    tlbl:SetText(cat.display)
    tlbl:SetTextColor(0.78, 0.78, 0.78)
    tbtn.label       = tlbl
    tbtn.filterValue = filterVal
    tbtn:SetScript("OnMouseDown", function()
      LeafVE_AchTest.UI.selectedTitleCategory = this.filterValue
      LeafVE_AchTest.UI:Refresh()
    end)
    tbtn:SetScript("OnEnter", function()
      if this.filterValue ~= LeafVE_AchTest.UI.selectedTitleCategory then
        this:SetBackdropColor(0.14, 0.14, 0.17, 0.65)
      end
    end)
    tbtn:SetScript("OnLeave", function()
      if this.filterValue ~= LeafVE_AchTest.UI.selectedTitleCategory then
        this:SetBackdropColor(0, 0, 0, 0)
      end
    end)
    LeafVE_StyleCategoryButton(tbtn, false)
    table.insert(self.titleCategoryButtons, tbtn)
  end
  local searchLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  searchLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 155, -110)
  searchLabel:SetText("Search:")
  self.searchLabel = searchLabel
  
  local searchBox = CreateFrame("EditBox", nil, f)
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 5, 0)
  searchBox:SetWidth(200)
  searchBox:SetHeight(22)
  searchBox:SetAutoFocus(false)
  searchBox:SetFontObject("GameFontHighlight")
  LeafVE_StyleInputBox(searchBox)
  searchBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
  searchBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
  searchBox:SetScript("OnTextChanged", function()
    LeafVE_AchTest.UI.searchText = this:GetText()
    LeafVE_AchTest.UI:Refresh()
  end)
  self.searchBox = searchBox
  
  local clearBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  clearBtn:SetPoint("LEFT", searchBox, "RIGHT", 4, 0)
  clearBtn:SetWidth(22)
  clearBtn:SetHeight(22)
  clearBtn:SetText("x")
  clearBtn:SetScript("OnClick", function()
    searchBox:SetText("")
    LeafVE_AchTest.UI.searchText = ""
    LeafVE_AchTest.UI:Refresh()
  end)
  LeafVE_StyleButton(clearBtn, false)
  self.clearBtn = clearBtn
  
  -- Title Search Bar (hidden by default)
  local titleSearchLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  titleSearchLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 155, -110)
  titleSearchLabel:SetText("Search:")
  titleSearchLabel:Hide()
  self.titleSearchLabel = titleSearchLabel
  
  local titleSearchBox = CreateFrame("EditBox", nil, f)
  titleSearchBox:SetPoint("LEFT", titleSearchLabel, "RIGHT", 5, 0)
  titleSearchBox:SetWidth(200)
  titleSearchBox:SetHeight(22)
  titleSearchBox:SetAutoFocus(false)
  titleSearchBox:SetFontObject("GameFontHighlight")
  LeafVE_StyleInputBox(titleSearchBox)
  titleSearchBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
  titleSearchBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
  titleSearchBox:SetScript("OnTextChanged", function()
    LeafVE_AchTest.UI.titleSearchText = this:GetText()
    LeafVE_AchTest.UI:Refresh()
  end)
  titleSearchBox:Hide()
  self.titleSearchBox = titleSearchBox
  
  local titleClearBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  titleClearBtn:SetPoint("LEFT", titleSearchBox, "RIGHT", 4, 0)
  titleClearBtn:SetWidth(22)
  titleClearBtn:SetHeight(22)
  titleClearBtn:SetText("x")
  titleClearBtn:SetScript("OnClick", function()
    titleSearchBox:SetText("")
    LeafVE_AchTest.UI.titleSearchText = ""
    LeafVE_AchTest.UI:Refresh()
  end)
  LeafVE_StyleButton(titleClearBtn, false)
  titleClearBtn:Hide()
  self.titleClearBtn = titleClearBtn
  
  local scrollFrame = CreateFrame("ScrollFrame", nil, f)
  scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 148, -145)
  scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 10)
  scrollFrame:EnableMouseWheel(true)
  self.scrollFrame = scrollFrame
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(685)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  self.scrollChild = scrollChild
  
  local scrollbar = CreateFrame("Slider", nil, f)
  scrollbar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -145)
  scrollbar:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 15)
  scrollbar:SetWidth(14)
  scrollbar:SetOrientation("VERTICAL")
  LeafVE_StyleScrollBar(scrollbar)
  scrollbar:SetMinMaxValues(0, 1)
  scrollbar:SetValue(0)
  scrollbar:SetValueStep(20)
  self.scrollbar = scrollbar
  
  scrollbar:SetScript("OnValueChanged", function()
    if LeafVE_AchTest.UI and LeafVE_AchTest.UI.scrollFrame then
      LeafVE_AchTest.UI.scrollFrame:SetVerticalScroll(this:GetValue())
      if LeafVE_AchTest.UI.currentView == "achievements" then
        LeafVE_AchTest.UI:UpdateVisibleAchievements()
      end
    end
  end)
  
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = this:GetVerticalScroll()
    local maxScroll = this:GetVerticalScrollRange()
    local newScroll = current - (arg1 * 20)
    if newScroll < 0 then newScroll = 0 end
    if newScroll > maxScroll then newScroll = maxScroll end
    this:SetVerticalScroll(newScroll)
    if LeafVE_AchTest.UI and LeafVE_AchTest.UI.scrollbar then
      LeafVE_AchTest.UI.scrollbar:SetValue(newScroll)
    end
  end)
  
  self:Refresh()

  -- Optional fade-in on first open (safe nil-check for 1.12 compatibility)
  if UIFrameFadeIn then
    f:SetAlpha(0)
    UIFrameFadeIn(f, 0.25, 0, 1)
  end
end

function LeafVE_AchTest.UI:Refresh()
  if not self.frame or not self.scrollChild then return end
  
  local me = ShortName(UnitName("player") or "")
  local totalPoints = LeafVE_AchTest:GetTotalAchievementPoints(me)
  local currentTitle = LeafVE_AchTest:GetCurrentTitle(me)
  
  if self.pointsLabel then
    if currentTitle then
      local titleText = me.." "..currentTitle.name
      local titleDiff = "normal"
      for _, td in ipairs(TITLES) do
        if td.id == currentTitle.id then titleDiff = td.difficulty or "normal"; break end
      end
      local titleColor = GetTitleColor(titleDiff)
      self.pointsLabel:SetText(titleColor..titleText.."|r | Points: |cFFFF7F00"..totalPoints.."|r")
    else
      self.pointsLabel:SetText(me.." | Points: |cFFFF7F00"..totalPoints.."|r")
    end
  end
  
  if self.achievementFrames then
    for i = 1, table.getn(self.achievementFrames) do
      if self.achievementFrames[i] then self.achievementFrames[i]:Hide() end
    end
  end
  
  if self.titleFrames then
    for i = 1, table.getn(self.titleFrames) do
      if self.titleFrames[i] then self.titleFrames[i]:Hide() end
    end
  end
  
  if self.scrollFrame then self.scrollFrame:SetVerticalScroll(0) end
  if self.scrollbar then self.scrollbar:SetValue(0) end
  
  if self.currentView == "achievements" then
    if self.achTab then self.achTab:Disable() end
    if self.titlesTab then self.titlesTab:Enable() end
    LeafVE_StyleButton(self.achTab, true)
    LeafVE_StyleButton(self.titlesTab, false)
    if self.awardBtn then self.awardBtn:Show() end
    if self.searchLabel then self.searchLabel:Show() end
    if self.searchBox then self.searchBox:Show() end
    if self.clearBtn then self.clearBtn:Show() end
    if self.titleSearchLabel then self.titleSearchLabel:Hide() end
    if self.titleSearchBox then self.titleSearchBox:Hide() end
    if self.titleClearBtn then self.titleClearBtn:Hide() end
    -- Show achievement sidebar; hide title sidebar
    if self.sidebarFrame then self.sidebarFrame:Show() end
    if self.titleSidebarFrame then self.titleSidebarFrame:Hide() end
    if self.categoryButtons then
      for _, btn in ipairs(self.categoryButtons) do
        LeafVE_StyleCategoryButton(btn, btn.filterValue == self.selectedCategory)
      end
    end
    self:RefreshAchievements()
  else
    if self.achTab then self.achTab:Enable() end
    if self.titlesTab then self.titlesTab:Disable() end
    LeafVE_StyleButton(self.achTab, false)
    LeafVE_StyleButton(self.titlesTab, true)
    if self.awardBtn then self.awardBtn:Hide() end
    if self.searchLabel then self.searchLabel:Hide() end
    if self.searchBox then self.searchBox:Hide() end
    if self.clearBtn then self.clearBtn:Hide() end
    if self.titleSearchLabel then self.titleSearchLabel:Show() end
    if self.titleSearchBox then self.titleSearchBox:Show() end
    if self.titleClearBtn then self.titleClearBtn:Show() end
    -- Hide achievement sidebar; show title sidebar
    if self.sidebarFrame then self.sidebarFrame:Hide() end
    if self.titleSidebarFrame then self.titleSidebarFrame:Show() end
    if self.titleCategoryButtons then
      for _, tbtn in ipairs(self.titleCategoryButtons) do
        LeafVE_StyleCategoryButton(tbtn, tbtn.filterValue == self.selectedTitleCategory)
      end
    end
    self:RefreshTitles()
  end
  
  if self.scrollFrame and self.scrollbar then
    local maxScroll = self.scrollFrame:GetVerticalScrollRange()
    self.scrollbar:SetMinMaxValues(0, maxScroll > 0 and maxScroll or 1)
  end
end

function LeafVE_AchTest.UI:RefreshAchievements()
  if not self.scrollChild then return end
  local me = ShortName(UnitName("player") or "")
  local playerAchievements = LeafVE_AchTest:GetPlayerAchievements(me)
  if not self.achievementFrames then self.achievementFrames = {} end

  -- Build filtered & sorted achievement list.
  local achievementList = {}
  for achID, achData in pairs(ACHIEVEMENTS) do
    local matchesCategory = self.selectedCategory == "All" or achData.category == self.selectedCategory
    local matchesSearch = true
    if self.searchText and self.searchText ~= "" then
      local searchLower = string.lower(self.searchText)
      local nameLower = string.lower(achData.name)
      local descLower = string.lower(achData.desc)
      matchesSearch = string.find(nameLower, searchLower) or string.find(descLower, searchLower)
    end
    if matchesCategory and matchesSearch then
      local completed = playerAchievements[achID] ~= nil
      local timestamp = completed and playerAchievements[achID].timestamp or 0
      table.insert(achievementList, {id=achID, data=achData, completed=completed, timestamp=timestamp})
    end
  end

  table.sort(achievementList, function(a, b)
    if a.completed and not b.completed then return true end
    if not a.completed and b.completed then return false end
    if a.completed and b.completed then return a.timestamp > b.timestamp end
    return a.data.points > b.data.points
  end)

  -- Store the sorted list for virtual-scroll updates.
  self.currentAchList  = achievementList
  self.currentAchOwner = me

  -- Debug: log category counts for Quest and Skills when DEBUG is enabled
  if LeafVE_AchTest.DEBUG then
    local questCount, skillCount = 0, 0
    for _, entry in ipairs(achievementList) do
      if entry.data.category == "Quests"     then questCount = questCount + 1 end
      if entry.data.category == "Skills"     then skillCount = skillCount + 1 end
    end
    Debug("RefreshAchievements [cat="..tostring(self.selectedCategory).."] Quests="..questCount.." Skills="..skillCount.." total="..table.getn(achievementList))
  end

  -- Set the scrollChild virtual height so the scrollbar range is correct.
  local totalHeight = math.max(10, table.getn(achievementList) * ACH_ROW_H + 10)
  self.scrollChild:SetHeight(totalHeight)

  if self.scrollFrame and self.scrollbar then
    local maxScroll = self.scrollFrame:GetVerticalScrollRange()
    self.scrollbar:SetMinMaxValues(0, maxScroll > 0 and maxScroll or 1)
  end

  -- Ensure the recycled frame pool exists (created once, reused forever).
  while table.getn(self.achievementFrames) < ACH_POOL do
    local frame = CreateAchievementRow(self.scrollChild)
    frame:Hide()
    table.insert(self.achievementFrames, frame)
  end

  self:UpdateVisibleAchievements()
end

-- Reposition and repopulate only the pool frames that fall inside the current
-- scroll viewport.  Called by RefreshAchievements and by scroll events.
function LeafVE_AchTest.UI:UpdateVisibleAchievements()
  local list = self.currentAchList
  if not list or not self.scrollFrame then return end
  local me    = self.currentAchOwner or ""
  local total = table.getn(list)

  -- Hide all pooled frames before re-assigning.
  for i = 1, table.getn(self.achievementFrames) do
    if self.achievementFrames[i] then self.achievementFrames[i]:Hide() end
  end

  if total == 0 then return end

  local scrollOff = self.scrollFrame:GetVerticalScroll() or 0
  -- First row index (1-based) that is at least partially visible.
  local firstRow  = math.max(1, math.floor(scrollOff / ACH_ROW_H) + 1)
  local poolSize  = table.getn(self.achievementFrames)

  for pi = 1, poolSize do
    local rowIdx = firstRow + pi - 1
    if rowIdx > total then break end
    local ach   = list[rowIdx]
    local frame = self.achievementFrames[pi]
    if not frame then break end

    local yOff = (rowIdx - 1) * ACH_ROW_H
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 5, -yOff)

    frame.achData       = ach.data
    frame.achCompleted  = ach.completed
    frame.achTimestamp  = ach.timestamp
    frame.achPlayerName = me

    frame.icon:SetTexture(ach.data.icon)

    -- Fetch progress data for this achievement (used by rep/counter achievements)
    local progCur, progMax
    local prog = GetAchievementProgress(me, ach.data.id)
    if prog then
      progCur = prog.current
      progMax = prog.goal
    end

    if ach.completed then
      frame.icon:SetDesaturated(false)
      frame.icon:SetAlpha(1)
      frame.checkmark:Show()
      frame:SetBackdropColor(CARD_BG_D[1], CARD_BG_D[2], CARD_BG_D[3], CARD_BG_D[4])
      frame:SetBackdropBorderColor(CARD_BORD_CMP[1], CARD_BORD_CMP[2], CARD_BORD_CMP[3], CARD_BORD_CMP[4])
      frame.name:SetText(ach.data.name)
      frame.name:SetTextColor(1.00, 0.95, 0.70)
      frame.desc:SetText(ach.data.desc)
      frame.desc:SetTextColor(0.80, 0.80, 0.80)
      frame.badge.Icon:SetVertexColor(THEME.gold[1], THEME.gold[2], THEME.gold[3])
      frame.badge.Text:SetText(tostring(ach.data.points).." pts")
      frame.status:SetText("Completed")
      frame.status:SetTextColor(0.4, 0.8, 0.4)
      frame:SetProgress(nil, nil, false)
      SetBadgeShimmer(frame.badge, (ach.data.points or 0) >= 20)
    else
      frame.icon:SetDesaturated(true)
      frame.icon:SetAlpha(0.5)
      frame.checkmark:Hide()
      frame:SetBackdropColor(CARD_BG_D[1], CARD_BG_D[2], CARD_BG_D[3], CARD_BG_D[4])
      frame:SetBackdropBorderColor(CARD_BORD_INC[1], CARD_BORD_INC[2], CARD_BORD_INC[3], CARD_BORD_INC[4])
      frame.name:SetText(ach.data.name)
      frame.name:SetTextColor(0.70, 0.70, 0.70)
      frame.desc:SetText(ach.data.desc)
      frame.desc:SetTextColor(0.55, 0.55, 0.55)
      frame.badge.Icon:SetVertexColor(0.5, 0.5, 0.5)
      frame.badge.Text:SetText(tostring(ach.data.points).." pts")
      frame.status:SetText("In Progress")
      frame.status:SetTextColor(0.55, 0.55, 0.55)
      if progCur and progMax and progMax > 0 then
        frame:SetProgress(progCur, progMax, true)
      else
        frame:SetProgress(nil, nil, false)
      end
      SetBadgeShimmer(frame.badge, false)
    end
    frame:Show()
    -- Golden border highlight when a text search is active (all visible rows are matches)
    if self.searchText and self.searchText ~= "" then
      frame:SetBackdropBorderColor(0.92, 0.80, 0.15, 0.85)
    end
  end
end

function LeafVE_AchTest.UI:RefreshTitles()
  if not self.scrollChild then return end
  local me = ShortName(UnitName("player") or "")
  if not self.titleFrames then self.titleFrames = {} end

  -- Build filtered title list
  local filteredTitles = {}
  for i, titleData in ipairs(TITLES) do
    local earned = LeafVE_AchTest:HasAchievement(me, titleData.achievement)

    -- Category filter ("Obtained" = earned only; otherwise match category field)
    local matchesCategory = true
    local selCat = self.selectedTitleCategory or "All"
    if selCat == "Obtained" then
      matchesCategory = earned
    elseif selCat ~= "All" then
      matchesCategory = (titleData.category or "Other") == selCat
    end

    -- Search filter
    local matchesSearch = true
    if self.titleSearchText and self.titleSearchText ~= "" then
      local searchLower = string.lower(self.titleSearchText)
      local nameLower = string.lower(titleData.name)
      local achData = ACHIEVEMENTS[titleData.achievement]
      local achNameLower = achData and string.lower(achData.name) or ""
      matchesSearch = string.find(nameLower, searchLower) or string.find(achNameLower, searchLower)
    end

    if matchesCategory and matchesSearch then
      table.insert(filteredTitles, {data=titleData, earned=earned})
    end
  end

  local yOffset = 0
  for i, entry in ipairs(filteredTitles) do
    local titleData = entry.data
    local earned    = entry.earned
    local frame = self.titleFrames[i]
    if not frame then
      frame = CreateFrame("Frame", nil, self.scrollChild)
      frame:SetWidth(660)
      frame:SetHeight(55)
      frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
      })
      frame:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
      local icon = frame:CreateTexture(nil, "ARTWORK")
      icon:SetWidth(32)
      icon:SetHeight(32)
      icon:SetPoint("LEFT", frame, "LEFT", 10, 0)
      icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      frame.icon = icon
      local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      name:SetPoint("LEFT", icon, "RIGHT", 10, 8)
      name:SetWidth(430)
      name:SetJustifyH("LEFT")
      frame.name = name
      local requirement = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      requirement:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
      requirement:SetWidth(430)
      requirement:SetJustifyH("LEFT")
      frame.requirement = requirement
      -- Single "Use" button — always applies title as suffix
      local useBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
      useBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -12)
      useBtn:SetWidth(60)
      useBtn:SetHeight(20)
      useBtn:SetText("Use")
      frame.useBtn = useBtn
      -- Tooltip
      frame:EnableMouse(true)
      frame:SetScript("OnEnter", function()
        if not this.titleData then return end
        local td = this.titleData
        local achData = ACHIEVEMENTS[td.achievement]
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        if this.titleEarned then
          GameTooltip:SetText(td.name, THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 1, true)
          GameTooltip:AddLine("|cFF888888Title|r", 1, 1, 1)
          if achData then
            GameTooltip:AddLine("Requires: "..achData.name, 1, 1, 1, true)
          end
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Earned", 0.5, 0.8, 0.5)
        else
          GameTooltip:SetText(td.name, 0.6, 0.6, 0.6, 1, true)
          GameTooltip:AddLine("|cFF888888Title|r", 1, 1, 1)
          if achData then
            GameTooltip:AddLine("Requires: "..achData.name, 0.7, 0.7, 0.7, true)
          end
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Not yet earned", 0.8, 0.4, 0.4)
        end
        GameTooltip:Show()
      end)
      frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      table.insert(self.titleFrames, frame)
    end
    -- Store per-frame data for the tooltip
    frame.titleData  = titleData
    frame.titleEarned = earned
    frame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 5, -yOffset)
    local achData = ACHIEVEMENTS[titleData.achievement]
    frame.icon:SetTexture(titleData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    if earned then
      frame:SetBackdropBorderColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 0.6)
      frame.icon:SetDesaturated(false)
      frame.icon:SetAlpha(1)
      local titleDiff = titleData.difficulty or "normal"
      local r, g, b = GetTitleColorRGB(titleDiff)
      frame.name:SetText(titleData.name)
      frame.name:SetTextColor(r, g, b)
      frame.requirement:SetText("From: "..(achData and achData.name or "Complete the associated achievement."))
      frame.requirement:SetTextColor(0.9, 0.9, 0.9)
      frame.useBtn:Enable()
      frame.useBtn.titleID = titleData.id
      frame.useBtn:SetScript("OnClick", function()
        LeafVE_AchTest:SetTitle(me, this.titleID, false)
        LeafVE_AchTest.UI:Refresh()
      end)
    else
      frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
      frame.icon:SetDesaturated(true)
      frame.icon:SetAlpha(0.3)
      frame.name:SetText(titleData.name)
      frame.name:SetTextColor(0.5, 0.5, 0.5)
      frame.requirement:SetText("Requires: "..(achData and achData.name or "Complete the associated achievement."))
      frame.requirement:SetTextColor(0.6, 0.4, 0.4)
      frame.useBtn:Disable()
    end
    frame:Show()
    yOffset = yOffset + 60
  end

  -- Hide unused frames
  for i = table.getn(filteredTitles) + 1, table.getn(self.titleFrames) do
    if self.titleFrames[i] then
      self.titleFrames[i]:Hide()
    end
  end

  if self.scrollChild then self.scrollChild:SetHeight(yOffset + 10) end
  if self.scrollFrame and self.scrollbar then
    local maxScroll = self.scrollFrame:GetVerticalScrollRange()
    self.scrollbar:SetMinMaxValues(0, maxScroll > 0 and maxScroll or 1)
  end
end

-- Timestamps of the most recent fall and drowning damage; used to classify the cause of death.
local lastFallDamageTime  = 0
local lastDrownDamageTime = 0
-- Maximum seconds between environmental damage and PLAYER_DEAD to classify cause of death.
local DEATH_CLASSIFY_WINDOW = 3

local ef = CreateFrame("Frame")
ef:RegisterEvent("ADDON_LOADED")
ef:RegisterEvent("PLAYER_LEVEL_UP")
ef:RegisterEvent("PLAYER_MONEY")
ef:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
ef:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
ef:RegisterEvent("PLAYER_DEAD")
ef:RegisterEvent("QUEST_COMPLETE")
ef:RegisterEvent("PARTY_MEMBERS_CHANGED")
ef:RegisterEvent("DUEL_WON")
ef:RegisterEvent("PLAYER_ENTERING_WORLD")
ef:RegisterEvent("GUILD_ROSTER_UPDATE")
ef:RegisterEvent("SKILL_LINES_CHANGED")
ef:RegisterEvent("TRADE_SKILL_SHOW")
ef:RegisterEvent("CRAFT_SHOW")

ef:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == LeafVE_AchTest.name then
    EnsureDB()
    -- Backlog: auto-award anything already earned that can be queried via the API
    LeafVE_AchTest:CheckLevelAchievements()
    LeafVE_AchTest:CheckGoldAchievements()
    LeafVE_AchTest:CheckProfessionAchievements()
    LeafVE_AchTest:CheckQuestAchievements()
    LeafVE_AchTest:CheckPvPRankAchievements()
    -- Backlog: award completions from previously stored boss kill progress + history
    LeafVE_AchTest:CheckBacklogAchievements()
    Print("Achievement System Loaded! Type /achtest")
    -- Backlog: sync exploration counters for tiered zone achievements
    do
      local me = ShortName(UnitName("player"))
      if me and LeafVE_AchTest_DB.exploredZones and LeafVE_AchTest_DB.exploredZones[me] then
        local zoneCount = 0
        for _ in pairs(LeafVE_AchTest_DB.exploredZones[me]) do zoneCount = zoneCount + 1 end
        CheckZoneExplorationAchievements(me, zoneCount)
        CheckWandererAchievement(me)
        CheckContinentAchievements(me)
      end
    end
    Debug("Debug mode is: "..tostring(LeafVE_AchTest.DEBUG))
  end
  if event == "PLAYER_LEVEL_UP" then LeafVE_AchTest:CheckLevelAchievements() end
  if event == "PLAYER_MONEY" then LeafVE_AchTest:CheckGoldAchievements() end
  if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
    -- Extract mob/boss name from death messages
    local bossName = string.match(arg1, "^(.+) dies%.$")
                  or string.match(arg1, "^(.+) is slain!$")
                  or string.match(arg1, "^(.+) has been slain%.$")
    if bossName then
      LeafVE_AchTest:CheckBossKill(bossName)
      RecordKill(bossName)
    end
  end
  if event == "CHAT_MSG_COMBAT_XP_GAIN" then
    -- Fallback kill signal: only count if CHAT_MSG_COMBAT_HOSTILE_DEATH didn't already
    -- record a kill within the debounce window (avoids inflating from quest XP, etc.)
    local now = GetTime and GetTime() or 0
    if (now - killDebounce_time) >= KILL_DEBOUNCE_SEC then
      RecordKill(nil)
    end
  end
  if event == "PLAYER_ENTERING_WORLD" then
    CheckGuildMemberAchievement()
    LeafVE_AchTest.ScanProfessionsAndAward()
  end
  if event == "GUILD_ROSTER_UPDATE" then
    CheckGuildMemberAchievement()
  end
  if event == "SKILL_LINES_CHANGED" or event == "TRADE_SKILL_SHOW" or event == "CRAFT_SHOW" then
    LeafVE_AchTest.ScanProfessionsAndAward()
  end
  if event == "PLAYER_DEAD" then
    local me = ShortName(UnitName("player"))
    if me then
      local total = IncrCounter(me, "deaths")
      if total >= 5   then LeafVE_AchTest:AwardAchievement("casual_deaths_5",   true) end
      if total >= 25  then LeafVE_AchTest:AwardAchievement("casual_deaths_25",  true) end
      if total >= 10  then LeafVE_AchTest:AwardAchievement("casual_deaths_10",  true) end
      if total >= 50  then LeafVE_AchTest:AwardAchievement("casual_deaths_50",  true) end
      if total >= 100 then LeafVE_AchTest:AwardAchievement("casual_deaths_100", true) end
      if total >= 200 then LeafVE_AchTest:AwardAchievement("casual_deaths_200", true) end
      -- Check if death was caused by falling (fall damage fired just before death)
      if GetTime() - lastFallDamageTime < DEATH_CLASSIFY_WINDOW then
        local fallTotal = IncrCounter(me, "fallDeaths")
        if fallTotal >= 10 then LeafVE_AchTest:AwardAchievement("casual_fall_death", true) end
      end
      -- Check if death was caused by drowning (suffocation damage fired just before death)
      if GetTime() - lastDrownDamageTime < DEATH_CLASSIFY_WINDOW then
        local drownTotal = IncrCounter(me, "drownings")
        if drownTotal >= 10 then LeafVE_AchTest:AwardAchievement("casual_drown", true) end
      end
    end
  end
  if event == "QUEST_COMPLETE" then
    local me = ShortName(UnitName("player"))
    if me then
      IncrCounter(me, "quests")
      LeafVE_AchTest:CheckQuestAchievements()
    end
  end
  if event == "PARTY_MEMBERS_CHANGED" then
    -- Award when first joining a group (party goes from 0 to 1+ members)
    local me = ShortName(UnitName("player"))
    local partySize = GetNumPartyMembers and GetNumPartyMembers() or 0
    if me then
      local pc = LeafVE_AchTest_DB and LeafVE_AchTest_DB.progressCounters
      if partySize >= 1 then
        local prev = pc and pc[me] and pc[me].lastPartySize or 0
        if prev == 0 then
          local total = IncrCounter(me, "groups")
          if total >= 50 then LeafVE_AchTest:AwardAchievement("casual_party_join", true) end
        end
        -- Refresh cached size for this player
        if pc and pc[me] then pc[me].lastPartySize = partySize end
      elseif partySize == 0 then
        if pc and pc[me] then pc[me].lastPartySize = 0 end
      end
    end
  end
  if event == "DUEL_WON" then
    local me = ShortName(UnitName("player"))
    if me then
      local total = IncrCounter(me, "duels")
      if total >= 10  then LeafVE_AchTest:AwardAchievement("pvp_duel_10",  true) end
      if total >= 25  then LeafVE_AchTest:AwardAchievement("pvp_duel_25",  true) end
      if total >= 50  then LeafVE_AchTest:AwardAchievement("pvp_duel_50",  true) end
      if total >= 75  then LeafVE_AchTest:AwardAchievement("pvp_duel_75",  true) end
      if total >= 100 then LeafVE_AchTest:AwardAchievement("pvp_duel_100", true) end
    end
  end
end)

-- Track environmental damage timestamps to classify the cause of death in PLAYER_DEAD.
-- Fall damage fires through CHAT_MSG_COMBAT_SELF_HITS ("You fall for X damage.").
-- Drowning (suffocation) fires through CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE ("You suffocate for X damage.").
local envFrame = CreateFrame("Frame")
envFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
envFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
envFrame:SetScript("OnEvent", function()
  if event == "CHAT_MSG_COMBAT_SELF_HITS" then
    if string.find(arg1 or "", "You fall for") then
      lastFallDamageTime = GetTime()
    end
  elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then
    if string.find(arg1 or "", "suffocate") then
      lastDrownDamageTime = GetTime()
    end
  end
end)

-- ---------------------------------------------------------------------------
-- Hearthstone tracking
-- ---------------------------------------------------------------------------

-- Time a Hearthstone cast started (0 = not casting); used by the Vanilla 1.12
-- SPELLCAST_START / SPELLCAST_STOP path.
local pendingHearthstoneStart = 0

local spellFrame = CreateFrame("Frame")
spellFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
-- Vanilla 1.12 cast events (fire for the local player only; no unit ID in arg1).
spellFrame:RegisterEvent("SPELLCAST_START")
spellFrame:RegisterEvent("SPELLCAST_STOP")
spellFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
spellFrame:RegisterEvent("SPELLCAST_FAILED")
spellFrame:SetScript("OnEvent", function()
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    if arg1 ~= "player" then return end
    local spellName = arg2 or ""
    if string.find(spellName, "^Hearthstone") then
      local me = ShortName(UnitName("player"))
      if me then
        local total = IncrCounter(me, "hearthstones")
        if total >= 1   then LeafVE_AchTest:AwardAchievement("casual_hearthstone_1",   true) end
        if total >= 50  then LeafVE_AchTest:AwardAchievement("casual_hearthstone_use", true) end
        if total >= 100 then LeafVE_AchTest:AwardAchievement("casual_hearthstone_100", true) end
      end
    end

  elseif event == "SPELLCAST_START" then
    local spellName = string.lower(arg1 or "")
    if string.find(spellName, "^hearthstone") then
      pendingHearthstoneStart = GetTime()
    end

  elseif event == "SPELLCAST_STOP" then
    if pendingHearthstoneStart > 0 then
      local me = ShortName(UnitName("player"))
      if me then
        local total = IncrCounter(me, "hearthstones")
        if total >= 1   then LeafVE_AchTest:AwardAchievement("casual_hearthstone_1",   true) end
        if total >= 50  then LeafVE_AchTest:AwardAchievement("casual_hearthstone_use", true) end
        if total >= 100 then LeafVE_AchTest:AwardAchievement("casual_hearthstone_100", true) end
      end
      pendingHearthstoneStart = 0
    end

  elseif event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" then
    pendingHearthstoneStart = 0
  end
end)

-- Track fish catches via loot messages
local lootFrame = CreateFrame("Frame")
lootFrame:RegisterEvent("CHAT_MSG_LOOT")
-- Keywords (lowercase) for matching fish item names in loot messages.
local FISH_KEYWORDS = {
  "fish", "snapper", "catfish", "smallfish", "grudgeon", "mightfish",
  "pufferfish", "swordfish", "tuna", "salmon", "trout", "eel",
  "whitefish", "mackere", "perch", "lobster", "craw", "shrimp",
  "oyster", "crab", "clam", "squid", "gourami",
}

lootFrame:SetScript("OnEvent", function()
  if event == "CHAT_MSG_LOOT" then
    -- Only count fish looted while fishing (message says "receive loot")
    local msg = string.lower(arg1 or "")
    if not string.find(msg, "you receive loot") then return end
    local isFish = false
    for _, kw in ipairs(FISH_KEYWORDS) do
      if string.find(msg, kw, 1, true) then isFish = true; break end
    end
    if isFish then
      local me = ShortName(UnitName("player"))
      if me then
        local total = IncrCounter(me, "fish")
        if total >= 25   then LeafVE_AchTest:AwardAchievement("casual_fish_25",   true) end
        if total >= 50   then LeafVE_AchTest:AwardAchievement("casual_fish_50",   true) end
        if total >= 100  then LeafVE_AchTest:AwardAchievement("casual_fish_100",  true) end
        if total >= 250  then LeafVE_AchTest:AwardAchievement("casual_fish_250",  true) end
        if total >= 500  then LeafVE_AchTest:AwardAchievement("casual_fish_500",  true) end
        if total >= 1000 then LeafVE_AchTest:AwardAchievement("casual_fish_1000", true) end
      end
    end
  end
end)

-- Track player emotes via CHAT_MSG_TEXT_EMOTE (fires when the local player uses an emote)
local emoteFrame = CreateFrame("Frame")
emoteFrame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
emoteFrame:SetScript("OnEvent", function()
  if event == "CHAT_MSG_TEXT_EMOTE" then
    -- arg2 is the sender name; only count emotes from the local player
    local senderName = arg2 and string.match(arg2, "^([^%-]+)") or ""
    local me = ShortName(UnitName("player"))
    if me and ShortName(senderName) == me then
      local total = IncrCounter(me, "emotes")
      if total >= 25  then LeafVE_AchTest:AwardAchievement("casual_emote_25",       true) end
      if total >= 50  then LeafVE_AchTest:AwardAchievement("casual_friend_emote",   true) end
      if total >= 100 then LeafVE_AchTest:AwardAchievement("casual_emote_100",      true) end
      if total >= 500 then LeafVE_AchTest:AwardAchievement("casual_emote_500",      true) end
    end
  end
end)

-- Track Auction House visits for casual_ah_sell achievement (10 visits).
local ahFrame = CreateFrame("Frame")
ahFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
ahFrame:SetScript("OnEvent", function()
  if event == "AUCTION_HOUSE_SHOW" then
    local me = ShortName(UnitName("player"))
    if me then
      local total = IncrCounter(me, "ahvisits")
      if total >= 10 then LeafVE_AchTest:AwardAchievement("casual_ah_sell", true) end
    end
  end
end)

-- Track Warsong Gulch entries for pvp_wsg_flag_return achievement (10 enters).
local wsgFrame = CreateFrame("Frame")
wsgFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
wsgFrame:SetScript("OnEvent", function()
  if event == "UPDATE_BATTLEFIELD_STATUS" then
    local me = ShortName(UnitName("player"))
    if me and GetBattlefieldStatus then
      for i = 1, GetMaxBattlefieldID and GetMaxBattlefieldID() or 3 do
        local status, mapName = GetBattlefieldStatus(i)
        if status == "active" and mapName and string.find(string.lower(mapName), "warsong") then
          local total = IncrCounter(me, "wsgvisits")
          if total >= 10 then LeafVE_AchTest:AwardAchievement("pvp_wsg_flag_return", true) end
          break
        end
      end
    end
  end
end)

SLASH_ACHTEST1 = "/achtest"
SlashCmdList["ACHTEST"] = function(msg)
  LeafVE_AchTest.UI:Build()
end

SLASH_ACHTESTDEBUG1 = "/achtestdebug"
SlashCmdList["ACHTESTDEBUG"] = function(msg)
  LeafVE_AchTest.DEBUG = not LeafVE_AchTest.DEBUG
  Print("Debug mode: "..tostring(LeafVE_AchTest.DEBUG))
end

SLASH_ACHSYNC1 = "/achsync"
SlashCmdList["ACHSYNC"] = function()
  LeafVE_AchTest:BroadcastAchievements()
  Print("Broadcasting achievements to guild...")
end

-- /achgrant <player> <achId>  — lets officers credit a player for pre-addon completions
-- Example: /achgrant Naruto rfc_complete    or    /achgrant Naruto raid_mc_complete
SLASH_ACHGRANT1 = "/achgrant"
SlashCmdList["ACHGRANT"] = function(msg)
  local target, achId = string.match(msg, "^(%S+)%s+(%S+)$")
  if not target or not achId then
    Print("Usage: /achgrant <PlayerName> <achievementId>")
    Print("Example: /achgrant Naruto dung_rfc_complete")
    return
  end
  -- Prefix dung_ if player typed a bare dungeon key like rfc_complete
  if not string.find(achId, "^dung_") and not string.find(achId, "^raid_") then
    -- Try prefixing dung_ first, then raid_
    if ACHIEVEMENTS["dung_"..achId] then
      achId = "dung_"..achId
    elseif ACHIEVEMENTS["raid_"..achId] then
      achId = "raid_"..achId
    end
  end
  local ach = ACHIEVEMENTS[achId]
  if not ach then
    Print("Unknown achievement ID: "..achId)
    return
  end
  local playerName = ShortName(target)
  EnsureDB()
  if not LeafVE_AchTest_DB.achievements[playerName] then
    LeafVE_AchTest_DB.achievements[playerName] = {}
  end
  if LeafVE_AchTest_DB.achievements[playerName][achId] then
    Print(playerName.." already has: "..ach.name)
    return
  end
  LeafVE_AchTest_DB.achievements[playerName][achId] = {timestamp = Now(), points = ach.points}
  Print("|cFFFF7F00[Admin Grant]|r "..playerName.." awarded: |cFF2DD35C"..ach.name.."|r (+"..ach.points.." pts)")
  if LeafVE_AchTest.UI and LeafVE_AchTest.UI.Refresh then
    LeafVE_AchTest.UI:Refresh()
  end
end

-- Chat Title Integration with Orange Color (Vanilla WoW Compatible)
local chatHooked = false

local function HookChatWithTitles()
  if chatHooked then 
    Debug("Chat already hooked")
    return 
  end
  
  Debug("Installing chat title hooks...")
  
  SendChatMessage = function(msg, chatType, language, channel)
    Debug("SendChatMessage called - Type: "..tostring(chatType))
    local me = ShortName(UnitName("player"))
    
    -- ONLY add titles to GUILD chat
    if me and msg and msg ~= "" and chatType == "GUILD" then
      if not string.find(msg, "^/") and not string.find(msg, "^%[LeafVE") then
        local title = LeafVE_AchTest:GetCurrentTitle(me)
        if title then
          Debug("Adding title: "..title.name)
          local titleDiff = "normal"
          for _, td in ipairs(TITLES) do
            if td.id == title.id then titleDiff = td.difficulty or "normal"; break end
          end
          local titleColor = GetTitleColor(titleDiff)
          msg = msg.." "..titleColor.."["..title.name.."]|r"
          Debug("Modified message: "..msg)
        else
          Debug("No title found for player")
        end
      end
    end
    return originalSendChatMessage(msg, chatType, language, channel)
  end
  
  chatHooked = true
  Print("Chat titles enabled!")
  Debug("Chat hook complete")
end

-- Minimap Button
local minimapButton = CreateFrame("Button", "LeafVE_AchTestMinimapButton", Minimap)
minimapButton:SetWidth(32)
minimapButton:SetHeight(32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Icon
local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetTexture("Interface\\Icons\\INV_Misc_Trophy_03")
icon:SetPoint("CENTER", 0, 1)
minimapButton.icon = icon

-- Border
local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
overlay:SetWidth(52)
overlay:SetHeight(52)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT", 0, 0)

-- Position on minimap
local function UpdateMinimapPosition()
  local angle = 45 -- Default angle
  local x = math.cos(angle) * 80
  local y = math.sin(angle) * 80
  minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

UpdateMinimapPosition()

-- Dragging functionality
minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)
minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetScript("OnDragStart", function()
  this:StartMoving()
end)

minimapButton:SetScript("OnDragStop", function()
  this:StopMovingOrSizing()
  local centerX, centerY = Minimap:GetCenter()
  local buttonX, buttonY = this:GetCenter()
  local angle = math.atan2(buttonY - centerY, buttonX - centerX)
  local x = math.cos(angle) * 80
  local y = math.sin(angle) * 80
  this:ClearAllPoints()
  this:SetPoint("CENTER", Minimap, "CENTER", x, y)
end)

-- Click to open
minimapButton:SetScript("OnClick", function()
  LeafVE_AchTest.UI:Build()
end)

-- Tooltip
minimapButton:SetScript("OnEnter", function()
  GameTooltip:SetOwner(this, "ANCHOR_LEFT")
  GameTooltip:SetText("|cFF2DD35CLeafVE Achievements|r", 1, 1, 1)
  GameTooltip:AddLine("Click to open", 0.8, 0.8, 0.8)
  GameTooltip:AddLine("Drag to move", 0.6, 0.6, 0.6)
  GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

Print("Minimap button loaded!")

-- ---------------------------------------------------------------------------
-- Zone discovery tracking for Turtle WoW exploration achievements
-- ---------------------------------------------------------------------------
local zoneDiscLastSeen = ""  -- debounce: skip if subzone hasn't changed
local zoneDiscFrame = CreateFrame("Frame")
zoneDiscFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneDiscFrame:RegisterEvent("ZONE_CHANGED")
zoneDiscFrame:RegisterEvent("MINIMAP_ZONE_CHANGED")
zoneDiscFrame:SetScript("OnEvent", function()
  local subzone = GetSubZoneText and GetSubZoneText() or ""
  if subzone == "" or subzone == zoneDiscLastSeen then return end
  zoneDiscLastSeen = subzone
  local me = ShortName(UnitName("player"))
  if not me then return end
  EnsureDB()
  if not LeafVE_AchTest_DB.exploredZones[me] then
    LeafVE_AchTest_DB.exploredZones[me] = {}
  end
  if LeafVE_AchTest_DB.exploredZones[me][subzone] then return end
  LeafVE_AchTest_DB.exploredZones[me][subzone] = true
  -- Update the total zone count for tiered exploration achievements
  local zoneCount = 0
  for _ in pairs(LeafVE_AchTest_DB.exploredZones[me]) do zoneCount = zoneCount + 1 end
  CheckZoneExplorationAchievements(me, zoneCount)
  -- Check Wanderer (counted subzones only) and continent achievements
  if COUNTED_WANDERER_SUBZONES[subzone] then
    CheckWandererAchievement(me)
    CheckContinentAchievements(me)
  end
  -- Check every zone-group achievement whose zones include this subzone
  for groupKey, zones in pairs(ZONE_GROUP_ZONES) do
    local achId = "explore_tw_"..groupKey
    if not LeafVE_AchTest:HasAchievement(me, achId) then
      local allFound = true
      for _, z in ipairs(zones) do
        if not LeafVE_AchTest_DB.exploredZones[me][z] then
          allFound = false
          break
        end
      end
      if allFound then
        LeafVE_AchTest:AwardAchievement(achId, true)
        -- A new TW zone completion might complete World Explorer
        CheckContinentAchievements(me)
      end
    end
  end
end)

local hookTimer = 0
local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
hookFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    Debug("Player entering world - starting hook timer")
    hookTimer = 0
    hookFrame:SetScript("OnUpdate", function()
      hookTimer = hookTimer + arg1
      if hookTimer >= 3 then
        HookChatWithTitles()
        hookFrame:SetScript("OnUpdate", nil)
      end
    end)
  end
end)

-- ---------------------------------------------------------------------------
-- Public API functions (spec deliverables)
-- ---------------------------------------------------------------------------

-- Update the header points label with the given player name and point total.
function LeafVE_UpdateHeader(frame, playerName, points)
  if LeafVE_AchTest and LeafVE_AchTest.UI and LeafVE_AchTest.UI.pointsLabel then
    LeafVE_AchTest.UI.pointsLabel:SetText(
      tostring(playerName).." | Points: |cFFFF7F00"..tostring(points).."|r"
    )
  end
end

-- Re-render the visible achievement rows at the given scroll offset.
-- Passing scrollOffset is optional; the current scroll position is used if omitted.
function LeafVE_UpdateVisibleRows(scrollOffset)
  if LeafVE_AchTest and LeafVE_AchTest.UI then
    if scrollOffset and LeafVE_AchTest.UI.scrollFrame then
      LeafVE_AchTest.UI.scrollFrame:SetVerticalScroll(scrollOffset)
    end
    LeafVE_AchTest.UI:UpdateVisibleAchievements()
  end
end

Print("LeafVE Achievement System loaded successfully!")