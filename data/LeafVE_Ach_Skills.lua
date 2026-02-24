-- LeafVE_Ach_Skills.lua
-- Profession milestone (75/150/225) and weapon skill achievements.
-- Adapted from KeijinAchievementMonitor for LeafVE.
-- Requires LeafVE_AchievementsTest.lua to be loaded first.

-- ============================================================
-- Achievement Definitions
-- ============================================================

local PROFESSIONS = {
  {id="ALCHEMY",        name="Alchemy",        icon="Interface\\Icons\\Trade_Alchemy"},
  {id="BLACKSMITHING",  name="Blacksmithing",  icon="Interface\\Icons\\Trade_BlackSmithing"},
  {id="COOKING",        name="Cooking",        icon="Interface\\Icons\\INV_Misc_Food_15"},
  {id="ENCHANTING",     name="Enchanting",     icon="Interface\\Icons\\Trade_Engraving"},
  {id="ENGINEERING",    name="Engineering",    icon="Interface\\Icons\\Trade_Engineering"},
  {id="FIRSTAID",       name="First Aid",      icon="Interface\\Icons\\Spell_Holy_SealOfSacrifice"},
  {id="FISHING",        name="Fishing",        icon="Interface\\Icons\\Trade_Fishing"},
  {id="HERBALISM",      name="Herbalism",      icon="Interface\\Icons\\Trade_Herbalism"},
  {id="LEATHERWORKING", name="Leatherworking", icon="Interface\\Icons\\Trade_LeatherWorking"},
  {id="MINING",         name="Mining",         icon="Interface\\Icons\\Trade_Mining"},
  {id="SKINNING",       name="Skinning",       icon="Interface\\Icons\\INV_Misc_Pelt_Wolf_01"},
  {id="TAILORING",      name="Tailoring",      icon="Interface\\Icons\\Trade_Tailoring"},
  {id="JEWELCRAFTING",  name="Jewelcrafting",  icon="Interface\\Icons\\INV_Misc_Gem_01"},
}

local PROF_STEPS = {
  {value=75,  title="Apprentice", points=5},
  {value=125, title="Adept",      points=8},
  {value=150, title="Journeyman", points=10},
  {value=225, title="Expert",     points=15},
}

local WEAPONS = {
  {id="UNARMED",   name="Unarmed"},
  {id="DEFENSE",   name="Defense"},
  {id="CROSSBOWS", name="Crossbows"},
  {id="DAGGERS",   name="Daggers"},
  {id="GUNS",      name="Guns"},
  {id="MACES",     name="Maces"},
  {id="POLEARMS",  name="Polearms"},
  {id="THROWN",    name="Thrown"},
  {id="2HAXES",    name="Two-Handed Axes"},
  {id="2HMACES",   name="Two-Handed Maces"},
  {id="2HSWORDS",  name="Two-Handed Swords"},
  {id="WANDS",     name="Wands"},
  {id="FIST",      name="Fist Weapons"},
  {id="STAVES",    name="Staves"},
  {id="SWORDS",    name="Swords"},
  {id="AXES",      name="Axes"},
}

local WEAPON_STEPS = {
  {value=300, title="Master", points=20},
}

local function RegisterSkillAchievements()
  for _, prof in ipairs(PROFESSIONS) do
    for _, step in ipairs(PROF_STEPS) do
      local achId = "prof_"..string.lower(prof.id).."_"..step.value
      LeafVE_AchTest:AddAchievement(achId, {
        id=achId,
        name=prof.name.." "..step.title,
        desc="Reach "..step.value.." skill points in "..prof.name..".",
        category="Professions",
        points=step.points,
        icon=prof.icon,
      })
    end
  end

  for _, w in ipairs(WEAPONS) do
    for _, step in ipairs(WEAPON_STEPS) do
      local achId = "weapon_"..string.lower(w.id).."_"..step.value
      LeafVE_AchTest:AddAchievement(achId, {
        id=achId,
        name=w.name.." "..step.title,
        desc="Reach "..step.value.." in "..w.name.." weapon skill.",
        category="Skills",
        points=step.points,
        icon="Interface\\Icons\\INV_Sword_27",
      })
    end
  end
end

-- ============================================================
-- Skill Checking Helper
-- Scans all GetSkillLineInfo entries and awards milestones.
-- Called on CHAT_MSG_SKILL (every skill-up) and on ADDON_LOADED
-- (backlog check).
-- ============================================================
local PROF_MILESTONES = {75, 125, 150, 225}
local WEAPON_MILESTONES = {300}

-- Maps display name -> canonical id prefix for professions
local PROF_ID_MAP = {}
for _, p in ipairs(PROFESSIONS) do
  PROF_ID_MAP[p.name] = string.lower(p.id)
end

-- Maps display name -> canonical id prefix for weapons
local WEAPON_ID_MAP = {}
for _, w in ipairs(WEAPONS) do
  WEAPON_ID_MAP[w.name] = string.lower(w.id)
end

local function CheckSkillMilestones()
  local numSkills = GetNumSkillLines and GetNumSkillLines() or 0
  for i = 1, numSkills do
    local skillName, isHeader, _, skillRank = GetSkillLineInfo(i)
    if skillName and not isHeader and skillRank then
      local profKey = PROF_ID_MAP[skillName]
      if profKey then
        for _, threshold in ipairs(PROF_MILESTONES) do
          if skillRank >= threshold then
            LeafVE_AchTest:AwardAchievement("prof_"..profKey.."_"..threshold, true)
          end
        end
      end
      local weapKey = WEAPON_ID_MAP[skillName]
      if weapKey then
        for _, threshold in ipairs(WEAPON_MILESTONES) do
          if skillRank >= threshold then
            LeafVE_AchTest:AwardAchievement("weapon_"..weapKey.."_"..threshold, true)
          end
        end
      end
    end
  end
end

-- ============================================================
-- Event Handler
-- ============================================================
local skillFrame = CreateFrame("Frame")
skillFrame:RegisterEvent("CHAT_MSG_SKILL")    -- fires on every skill-up
skillFrame:RegisterEvent("ADDON_LOADED")       -- backlog check on load
skillFrame:RegisterEvent("PLAYER_ENTERING_WORLD") -- initial scan on login/reload

skillFrame:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == "LeafVE_AchievementsTest" then
    if LeafVE_AchTest and LeafVE_AchTest.AddAchievement then
      RegisterSkillAchievements()
    end
    CheckSkillMilestones()
  elseif event == "CHAT_MSG_SKILL" or event == "PLAYER_ENTERING_WORLD" then
    CheckSkillMilestones()
  end
end)