-- LeafVE_Ach_Identity.lua
-- Race and class identity achievements.
-- Adapted from KeijinAchievementMonitor for LeafVE.
-- Requires LeafVE_AchievementsTest.lua to be loaded first.

-- ============================================================
-- Achievement Definitions
-- ============================================================

local RACE_ACHIEVEMENTS = {
  {id="race_human",    name="First Steps: Human",       desc="Play as a Human character.",    race="Human",     icon="Interface\\Icons\\Achievement_Character_Human_Male"},
  {id="race_dwarf",    name="Stout Heart: Dwarf",        desc="Play as a Dwarf character.",    race="Dwarf",     icon="Interface\\Icons\\Achievement_Character_Dwarf_Male"},
  {id="race_nightelf", name="Shadow of the Woods",       desc="Play as a Night Elf.",          race="Night Elf", icon="Interface\\Icons\\Achievement_Character_Nightelf_Male"},
  {id="race_gnome",    name="Tinkerer Born: Gnome",      desc="Play as a Gnome character.",    race="Gnome",     icon="Interface\\Icons\\Achievement_Character_Gnome_Male"},
  {id="race_orc",      name="Blood Fury: Orc",           desc="Play as an Orc character.",     race="Orc",       icon="Interface\\Icons\\Achievement_Character_Orc_Male"},
  {id="race_troll",    name="Jungle Spirit: Troll",      desc="Play as a Troll character.",    race="Troll",     icon="Interface\\Icons\\Achievement_Character_Troll_Male"},
  {id="race_tauren",   name="Earth's Ward: Tauren",      desc="Play as a Tauren character.",   race="Tauren",    icon="Interface\\Icons\\Achievement_Character_Tauren_Male"},
  {id="race_undead",   name="Forsaken Path: Undead",     desc="Play as an Undead character.",  race="Scourge",   icon="Interface\\Icons\\Achievement_Character_Undead_Male"},
  {id="race_highelf",  name="Silver Bough: High Elf",    desc="Play as a High Elf character.", race="High Elf",  icon="Interface\\Icons\\Achievement_Character_Nightelf_Female"},
  {id="race_goblin",   name="Trade Prince's Path: Goblin",desc="Play as a Goblin character.", race="Goblin",    icon="Interface\\Icons\\Achievement_Character_Gnome_Female"},
}

local CLASS_ACHIEVEMENTS = {
  {id="class_warrior", name="Path of Strength: Warrior",   desc="Play as a Warrior.",  class="Warrior",   icon="Interface\\Icons\\Achievement_Character_Warrior_Male"},
  {id="class_paladin", name="Light's Initiate: Paladin",   desc="Play as a Paladin.",  class="Paladin",   icon="Interface\\Icons\\Achievement_Character_Paladin_Male"},
  {id="class_hunter",  name="Eyes of the Wild: Hunter",    desc="Play as a Hunter.",   class="Hunter",    icon="Interface\\Icons\\Achievement_Character_Hunter_Male"},
  {id="class_rogue",   name="Silent Step: Rogue",          desc="Play as a Rogue.",    class="Rogue",     icon="Interface\\Icons\\Achievement_Character_Rogue_Male"},
  {id="class_priest",  name="Faith's Candle: Priest",      desc="Play as a Priest.",   class="Priest",    icon="Interface\\Icons\\Achievement_Character_Priest_Male"},
  {id="class_shaman",  name="Voice of Elements: Shaman",   desc="Play as a Shaman.",   class="Shaman",    icon="Interface\\Icons\\Achievement_Character_Shaman_Male"},
  {id="class_mage",    name="First Spark: Mage",           desc="Play as a Mage.",     class="Mage",      icon="Interface\\Icons\\Achievement_Character_Mage_Male"},
  {id="class_warlock", name="Pact Signed: Warlock",        desc="Play as a Warlock.",  class="Warlock",   icon="Interface\\Icons\\Achievement_Character_Warlock_Male"},
  {id="class_druid",   name="Circle's Seed: Druid",        desc="Play as a Druid.",    class="Druid",     icon="Interface\\Icons\\Achievement_Character_Druid_Male"},
}

local function RegisterIdentityAchievements()
  for _, a in ipairs(RACE_ACHIEVEMENTS) do
    LeafVE_AchTest:AddAchievement(a.id, {
      id=a.id, name=a.name, desc=a.desc,
      category="Identity", points=5, icon=a.icon,
      _race=a.race,
    })
  end

  for _, a in ipairs(CLASS_ACHIEVEMENTS) do
    LeafVE_AchTest:AddAchievement(a.id, {
      id=a.id, name=a.name, desc=a.desc,
      category="Identity", points=5, icon=a.icon,
      _class=a.class,
    })
  end
end

-- ============================================================
-- Event Handler
-- ============================================================
local function CheckIdentity()
  local raceName = UnitRace("player")    -- e.g. "Human", "Night Elf", "Scourge"
  local className = UnitClass("player")  -- e.g. "Warrior", "Mage"
  if not raceName or not className then return end

  for _, a in ipairs(RACE_ACHIEVEMENTS) do
    if string.lower(raceName) == string.lower(a.race) then
      LeafVE_AchTest:AwardAchievement(a.id, true)
    end
  end
  for _, a in ipairs(CLASS_ACHIEVEMENTS) do
    if string.lower(className) == string.lower(a.class) then
      LeafVE_AchTest:AwardAchievement(a.id, true)
    end
  end
end

local identityFrame = CreateFrame("Frame")
identityFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
identityFrame:RegisterEvent("ADDON_LOADED")

identityFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    CheckIdentity()
  elseif event == "ADDON_LOADED" and arg1 == "LeafVE_AchievementsTest" then
    if LeafVE_AchTest and LeafVE_AchTest.AddAchievement then
      RegisterIdentityAchievements()
    end
    CheckIdentity()
  end
end)