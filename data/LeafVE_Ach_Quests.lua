-- LeafVE_Ach_Quests.lua
-- Notable multi-step quest chain achievements with per-step progress tracking.
-- Quest completions are detected via CHAT_MSG_SYSTEM: Quest "Name" completed.
-- Requires LeafVE_AchievementsTest.lua to be loaded first.

-- ============================================================
-- Quest Chain Definitions
-- Each chain has an achievement + optional title reward.
-- _questSteps lists the exact quest turn-in names that must
-- be completed (case-insensitive match).
-- ============================================================

local QUEST_CHAINS = {

  -- ── Alliance: Onyxia's Lair Attunement ───────────────────
  {
    id    = "quest_onyxia_alliance",
    name  = "The Great Masquerade",
    desc  = "Complete the Onyxia's Lair attunement quest chain (Alliance).",
    points = 100,
    icon  = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
    title = {id="title_onyxia_bane", name="Onyxia's Bane", prefix=false},
    steps = {
      "Dragonkin Menace",
      "The True Masters",
      "Marshal Windsor",
      "Abandoned Hope",
      "A Crumpled Up Note",
      "A Shred of Hope",
      "Handing Over the Goods",
      "For the Marshal!",
      "The Great Masquerade",
      "The Dragon's Eye",
      "Drakefire Amulet",
    },
  },

  -- ── Horde: Onyxia's Lair Attunement ─────────────────────
  {
    id    = "quest_onyxia_horde",
    name  = "Blood of the Black Dragon Champion",
    desc  = "Complete the Onyxia's Lair attunement quest chain (Horde).",
    points = 100,
    icon  = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
    title = {id="title_bloodbound", name="the Bloodbound", prefix=false},
    steps = {
      "Warlord's Command",
      "Eitrigg's Wisdom",
      "For The Horde!",
      "What the Wind Carries",
      "The Champion of the Horde",
      "Mistress of Deception",
      "Oculus Illusions",
      "Emberstrife",
      "The Test of Skulls, Axtroz",
      "The Test of Skulls, Somnus",
      "The Test of Skulls, Chronalis",
      "The Test of Skulls, Scryer",
      "Blood of the Black Dragon Champion",
    },
  },

  -- ── Thunderfury, Blessed Blade of the Windseeker ─────────
  {
    id    = "quest_thunderfury",
    name  = "The Windseeker's Legacy",
    desc  = "Forge Thunderfury by completing the elemental weapon quest chain.",
    points = 150,
    icon  = "Interface\\Icons\\INV_Sword_39",
    title = {id="title_windseeker", name="the Windseeker", prefix=false},
    steps = {
      "Vessel of Rebirth",
      "Thunderaan's Oculus",
      "Arcanite Crystal",
      "Heart of Thunderaan",
      "Thunderfury, Blessed Blade of the Windseeker",
    },
  },

  -- ── Linken's Adventure (Un'Goro Crater) ──────────────────
  {
    id    = "quest_linken",
    name  = "Hero of Un'Goro Crater",
    desc  = "Help Linken recover his memory and complete his epic adventure chain.",
    points = 50,
    icon  = "Interface\\Icons\\INV_Misc_Note_06",
    title = {id="title_ungoro_adventurer", name="the Un'Goro Adventurer", prefix=false},
    steps = {
      "It's a Secret to Everybody",
      "The Videre Elixir",
      "Meet at the Grave",
      "A Grave Situation",
      "Linken's Sword",
      "A Gnome's Respite",
      "Linken's Memory",
      "Silver Heart",
      "Aquementas",
      "Linken's Boomerang",
    },
  },

  -- ── The Missing Diplomat (Alliance) ──────────────────────
  {
    id    = "quest_missing_diplomat",
    name  = "A Diplomat's Journey",
    desc  = "Unravel the disappearance of King Varian Wrynn across Azeroth.",
    points = 75,
    icon  = "Interface\\Icons\\INV_Misc_Map_02",
    title = {id="title_kingfinder", name="the Kingfinder", prefix=false},
    steps = {
      "A Fishy Peril",
      "Further Concerns",
      "What Lurks Beneath",
      "Cloak of Unending Life",
      "Bazil Thredd",
      "The Tulal Oasis",
      "Mennet Cadelan",
      "The Second Rebellion",
      "Stoley's Debt",
      "Keep An Eye Out",
      "The Scepter of Light",
      "The Absent Minded Prospector",
      "Dazed and Confused",
    },
  },

  -- ── Rhok'delar, Longbow of the Ancient Keepers (Hunter) ──
  {
    id    = "quest_rhokdelar",
    name  = "Bow of the Ancient Keepers",
    desc  = "Slay four ancient demons and claim Rhok'delar from the demigod Remulos.",
    points = 75,
    icon  = "Interface\\Icons\\INV_Weapon_Bow_13",
    title = {id="title_beastmaster", name="the Beastmaster", prefix=false},
    steps = {
      "The Ancient Leaf",
      "Stave of the Ancients",
      "Rhok'delar, Longbow of the Ancient Keepers",
    },
  },

  -- ── Benediction / Anathema (Priest) ──────────────────────
  {
    id    = "quest_benediction",
    name  = "The Light's Chosen Staff",
    desc  = "Balance Light and Shadow to forge Benediction (or Anathema).",
    points = 75,
    icon  = "Interface\\Icons\\INV_Staff_30",
    title = {id="title_lightbringer", name="the Lightbringer", prefix=false},
    steps = {
      "Redemption",
      "The Balance of Light and Shadow",
      "Benediction",
    },
  },

  -- ── Darrowshire (Eastern / Western Plaguelands) ───────────
  {
    id    = "quest_darrowshire",
    name  = "Echoes of Darrowshire",
    desc  = "Relive the tragic Battle of Darrowshire and lay its ghosts to rest.",
    points = 75,
    icon  = "Interface\\Icons\\Spell_Shadow_RaiseDead",
    title = {id="title_darrowshire_hero", name="the Darrowshire Hero", prefix=false},
    steps = {
      "Little Pamela",
      "Pamela's Doll",
      "Auntie Marlene",
      "A Strange Historian",
      "The Annals of Darrowshire",
      "Brother Carlin",
      "The Battle of Darrowshire",
    },
  },

  -- ── Molten Core Attunement ─────────────────────────────────
  {
    id    = "quest_mc_attunement",
    name  = "Attunement to the Core",
    desc  = "Complete the Molten Core attunement quest chain.",
    points = 75,
    icon  = "Interface\\Icons\\Spell_Fire_LavaSpawn",
    title = {id="title_core_seeker", name="Core Seeker", prefix=false},
    steps = {
      "Fireproof",
      "Overmaster Pyron",
      "Attunement to the Core",
    },
  },

  -- ── Princess Theradras Chain (Maraudon) ────────────────────
  {
    id    = "quest_princess_theradras",
    name  = "Earth's Bane",
    desc  = "Defeat Princess Theradras after completing the Maraudon quest chain.",
    points = 50,
    icon  = "Interface\\Icons\\INV_Misc_Root_02",
    title = {id="title_deep_diver", name="Deep Diver", prefix=false},
    steps = {
      "Corruption of Earth and Seed",
      "Legends of Maraudon",
      "The Scepter of Celebras",
      "Shadowshard Fragments",
      "Vyletongue Corruption",
    },
  },

}

-- ============================================================
-- Helpers
-- ============================================================

-- Extract quest name from CHAT_MSG_SYSTEM completion message.
-- Handles: Quest "Name" completed.  /  Quest 'Name' completed.
local function ExtractQuestName(msg)
  if type(msg) ~= "string" then return nil end
  -- Primary pattern: Quest "Name" completed. (straight or curly quotes)
  local name = string.match(msg, 'Quest "([^"]+)" completed%.')
               or string.match(msg, "Quest '([^']+)' completed%.")
  if name and name ~= "" then return name end
  -- Fallback: ends with " completed."
  if string.find(msg, " completed%.") then
    local stripped = string.gsub(msg, " completed%.", "")
    stripped = string.gsub(stripped, '^Quest%s*["\']', "")
    stripped = string.gsub(stripped, '["\']%s*$', "")
    stripped = string.gsub(stripped, "^%s+", "")
    stripped = string.gsub(stripped, "%s+$", "")
    if stripped ~= "" then return stripped end
  end
  return nil
end

-- Check whether a chain is complete and award if so.
local function CheckChain(me, chain)
  if LeafVE_AchTest:HasAchievement(me, chain.id) then return end
  if not LeafVE_AchTest_DB or not LeafVE_AchTest_DB.completedQuests then return end
  local cq = LeafVE_AchTest_DB.completedQuests[me]
  if not cq then return end
  for _, step in ipairs(chain.steps) do
    if not cq[string.lower(step)] then return end
  end
  LeafVE_AchTest:AwardAchievement(chain.id, false)
end

-- Record a quest completion and check chains.
local function RecordQuestCompletion(me, questName)
  if not questName or questName == "" then return end
  if not LeafVE_AchTest_DB then return end
  if not LeafVE_AchTest_DB.completedQuests then LeafVE_AchTest_DB.completedQuests = {} end
  if not LeafVE_AchTest_DB.completedQuests[me] then LeafVE_AchTest_DB.completedQuests[me] = {} end
  local lname = string.lower(questName)
  -- Record the step and check each chain that contains it
  local recorded = false
  for _, chain in ipairs(QUEST_CHAINS) do
    for _, step in ipairs(chain.steps) do
      if string.lower(step) == lname then
        LeafVE_AchTest_DB.completedQuests[me][lname] = true
        recorded = true
        break
      end
    end
    if recorded then
      CheckChain(me, chain)
      recorded = false
    end
  end
end

-- ============================================================
-- Registration
-- ============================================================

local function RegisterQuestChainAchievements()
  for _, chain in ipairs(QUEST_CHAINS) do
    LeafVE_AchTest:AddAchievement(chain.id, {
      id          = chain.id,
      name        = chain.name,
      desc        = chain.desc,
      category    = "Quests",
      points      = chain.points or 50,
      icon        = chain.icon,
      _questSteps = chain.steps,
    })
    if chain.title and LeafVE_AchTest.AddTitle then
      LeafVE_AchTest:AddTitle({
        id          = chain.title.id,
        name        = chain.title.name,
        achievement = chain.id,
        prefix      = chain.title.prefix,
        icon        = chain.icon,
      })
    end
  end
end

-- ============================================================
-- Event Handler
-- ============================================================

local questFrame = CreateFrame("Frame")
questFrame:RegisterEvent("ADDON_LOADED")
questFrame:RegisterEvent("CHAT_MSG_SYSTEM")

questFrame:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == "LeafVE_AchievementsTest" then
    if LeafVE_AchTest and LeafVE_AchTest.AddAchievement then
      RegisterQuestChainAchievements()
    end
    -- Backlog: re-check chains in case all steps were completed in a prior session
    local me = LeafVE_AchTest and LeafVE_AchTest.ShortName and
               LeafVE_AchTest.ShortName(UnitName("player"))
    if me then
      for _, chain in ipairs(QUEST_CHAINS) do
        CheckChain(me, chain)
      end
    end
    return
  end

  if event == "CHAT_MSG_SYSTEM" then
    local questName = ExtractQuestName(arg1)
    if questName then
      local me = LeafVE_AchTest and LeafVE_AchTest.ShortName and
                 LeafVE_AchTest.ShortName(UnitName("player"))
      if me then
        RecordQuestCompletion(me, questName)
      end
    end
  end
end)