-- LeafVE_Ach_Kills.lua
-- Kill achievements adapted from KeijinAchievementMonitor for LeafVE.
-- Tracks generic kill counts, named critter/mob kills, and non-raid boss kills.
-- Requires LeafVE_AchievementsTest.lua to be loaded first.

-- ============================================================
-- Achievement Definitions
-- ============================================================

-- Generic kill count milestones
local GENERIC_KILLS = {
  {id="kill_01",     name="First Blood",       desc="Defeat your first enemy.",              value=1,     points=5},
  {id="kill_05",     name="Warm-Up Round",      desc="Defeat 5 enemies.",                     value=5,     points=5},
  {id="kill_10",     name="Seasoned Combatant", desc="Defeat 10 enemies.",                    value=10,    points=5},
  {id="kill_50",     name="Azeroth Slayer",     desc="Defeat 50 enemies across Azeroth.",     value=50,    points=5},
  {id="kill_100",    name="Endless War",        desc="Defeat 100 enemies.",                   value=100,   points=10},
  {id="kill_200",    name="Slayer Supreme",     desc="Defeat 200 enemies.",                   value=200,   points=10},
  {id="kill_500",    name="Warmaster",          desc="Defeat 500 enemies.",                   value=500,   points=20},
  {id="kill_1000",   name="Massacre Master",    desc="Defeat 1000 enemies.",                  value=1000,  points=25},
  {id="kill_10000",  name="Unstoppable",        desc="Defeat 10,000 enemies.",                value=10000, points=50},
}

-- Named critter and mob kills (require 50 kills each)
local NAMED_KILLS = {
  {id="kill_squirrel",    name="Squirrel Sniper",          desc="Kill 50 Squirrels.",                          target="Squirrel",    value=50},
  {id="kill_hare",        name="Hare, No More!",           desc="Kill 50 Hares.",                              target="Hare",        value=50},
  {id="kill_rat",         name="Rat Control",              desc="Kill 50 Rats.",                               target="Rat",         value=50},
  {id="kill_roach",       name="Roach Sniper",             desc="Kill 50 Roaches.",                            target="Roach",       value=50},
  {id="kill_sheep",       name="Woolly Mistake",           desc="Kill 50 Sheep.",                              target="Sheep",       value=50},
  {id="kill_cat",         name="Nine Lives? Not Today.",   desc="Kill 50 Cats.",                               target="Cat",         value=50},
  {id="kill_rabbit",      name="No More Rabbits",          desc="Kill 50 Rabbits.",                            target="Rabbit",      value=50},
  {id="kill_frog",        name="Slimy Encounter",          desc="Kill 50 Frogs.",                              target="Frog",        value=50},
  {id="kill_snake",       name="Hiss Stopper",             desc="Kill 50 Snakes.",                             target="Snake",       value=50},
  {id="kill_chicken",     name="Feathered Fiend",          desc="Kill 50 Chickens.",                           target="Chicken",     value=50},
  {id="kill_cow",         name="Udder Chaos",              desc="Kill 50 Cows.",                               target="Cow",         value=50},
  {id="kill_deer",        name="Not So Bambi",             desc="Kill 50 Deer.",                               target="Deer",        value=50},
  {id="kill_prairiedog",  name="Prairie Dog Exterminator", desc="Kill 50 Prairie Dogs.",                       target="Prairie Dog", value=50},
  {id="kill_plainstrider",name="Bird Breakfast",           desc="Defeat 50 Plainstriders.",                    target="Plainstrider",value=50},
  {id="kill_black_rat",   name="Pest Control",             desc="Kill 50 Black Rats.",                         target="Black Rat",   value=50},
  {id="kill_adder",       name="Adder Annihilator",        desc="Kill 50 Adders.",                             target="Adder",       value=50},
  {id="kill_toad",        name="No Time for Toads",        desc="Kill 50 Toads.",                              target="Toad",        value=50},
  {id="kill_fawn",        name="Forest Heartbreaker",      desc="Kill 50 Fawns.",                              target="Fawn",        value=50},
  {id="kill_parrot",      name="Pretty Dead Polly",        desc="Kill 50 Parrots.",                            target="Parrot",      value=50},
  {id="kill_crab",        name="Shell Crusher",            desc="Kill 50 Crabs.",                              target="Crab",        value=50},
  {id="kill_turtle",      name="Slow and Slain",           desc="Kill 50 Turtles.",                            target="Turtle",      value=50},
  {id="kill_bat",         name="Night Hunter",             desc="Kill 50 Bats.",                               target="Bat",         value=50},
  {id="kill_scorpid",     name="Sting Stopper",            desc="Kill 50 Scorpids.",                           target="Scorpid",     value=50},
  {id="kill_goat",        name="Mountain Menace",          desc="Kill 50 Goats.",                              target="Goat",        value=50},
}

-- Non-raid named boss/elite kills (one-shot)
-- (Raid bosses are already tracked separately in the main file)
local BOSS_KILLS = {
  {id="kill_hogger",    name="Justice for Elwynn",  desc="Defeat Hogger, the terror of Elwynn Forest.",       target="Hogger"},
  {id="kill_bellygrub", name="Boarbecue",            desc="Defeat Bellygrub, the infamous gluttonous boar.",   target="Bellygrub"},
  {id="kill_vancleef",  name="Brotherhood Broken",   desc="Defeat Edwin VanCleef in The Deadmines.",           target="Edwin VanCleef"},
  {id="kill_sharptusk", name="Sharptusk Falls",      desc="Defeat Chief Sharptusk Thornmantle.",               target="Chief Sharptusk Thornmantle"},
  {id="kill_azuregos",  name="Blue Dragon Down",     desc="Defeat the world boss Azuregos in Azshara.",        target="Azuregos"},
  {id="kill_kazzak",    name="Lord of Doom",         desc="Defeat Lord Kazzak in the Blasted Lands.",          target="Lord Kazzak"},
  {id="kill_emeriss",   name="Nightmare's Canopy",   desc="Defeat Emeriss, Dragon of Nightmare.",              target="Emeriss"},
  {id="kill_lethon",    name="Shadow of the Dream",  desc="Defeat Lethon, Dragon of Nightmare.",               target="Lethon"},
  {id="kill_taerar",    name="Shattered Nightmare",  desc="Defeat Taerar, Dragon of Nightmare.",               target="Taerar"},
  {id="kill_ysondre",   name="Moonwarden's Bane",    desc="Defeat Ysondre, Dragon of Nightmare.",              target="Ysondre"},
}

-- Register all achievements
local function RegisterKillAchievements()
  for _, ach in ipairs(GENERIC_KILLS) do
    LeafVE_AchTest:AddAchievement(ach.id, {
      id=ach.id, name=ach.name, desc=ach.desc,
      category="Kills", points=ach.points,
      icon="Interface\\Icons\\Ability_Warrior_Rampage",
    })
  end

  for _, ach in ipairs(NAMED_KILLS) do
    LeafVE_AchTest:AddAchievement(ach.id, {
      id=ach.id, name=ach.name, desc=ach.desc,
      category="Kills", points=10,
      icon="Interface\\Icons\\Ability_Warrior_Rampage",
    })
    -- Register progress tracking so the tooltip shows X/50
    if LeafVE_AchTest.RegisterProgressDef then
      LeafVE_AchTest:RegisterProgressDef(ach.id, {counter="nkills_"..ach.id, goal=ach.value})
    end
  end

  for _, ach in ipairs(BOSS_KILLS) do
    LeafVE_AchTest:AddAchievement(ach.id, {
      id=ach.id, name=ach.name, desc=ach.desc,
      category="Kills", points=10,
      icon="Interface\\Icons\\INV_Misc_Head_Dragon_01",
    })
  end
end

local killRegFrame = CreateFrame("Frame")
killRegFrame:RegisterEvent("ADDON_LOADED")
killRegFrame:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == "LeafVE_AchievementsTest" then
    if LeafVE_AchTest and LeafVE_AchTest.AddAchievement then
      RegisterKillAchievements()
    end
    -- Backlog: award critter achievements already reached from prior sessions
    if not (LeafVE_AchTest and LeafVE_AchTest.ShortName) then return end
    local me = LeafVE_AchTest.ShortName(UnitName("player"))
    if me and LeafVE_AchTest_DB and LeafVE_AchTest_DB.progressCounters then
      local pc = LeafVE_AchTest_DB.progressCounters[me]
      if pc then
        for _, ach in ipairs(NAMED_KILLS) do
          local total = pc["nkills_"..ach.id] or 0
          if total >= ach.value then
            LeafVE_AchTest:AwardAchievement(ach.id, true)
          end
        end
      end
    end
    killRegFrame:UnregisterEvent("ADDON_LOADED")
  end
end)

-- ============================================================
-- Build lookup table: lowercase target name -> achievement id
-- Used by the event handler for O(1) named kill matching
-- ============================================================
local NAMED_KILL_LOOKUP = {}
for _, ach in ipairs(NAMED_KILLS) do
  NAMED_KILL_LOOKUP[string.lower(ach.target)] = ach.id
end
for _, ach in ipairs(BOSS_KILLS) do
  NAMED_KILL_LOOKUP[string.lower(ach.target)] = ach.id
end

-- Maps achievement ID -> required kill count (critters only; bosses are nil = one-shot)
local NAMED_KILL_GOALS = {}
for _, ach in ipairs(NAMED_KILLS) do
  NAMED_KILL_GOALS[ach.id] = ach.value
end

-- Generic kill milestones sorted ascending for the counter check
local GENERIC_MILESTONES = {}
for _, ach in ipairs(GENERIC_KILLS) do
  table.insert(GENERIC_MILESTONES, {value=ach.value, id=ach.id})
end
table.sort(GENERIC_MILESTONES, function(a, b) return a.value < b.value end)

-- Recent target tracking for fallback kill validation (scenarios 6-8)
local BOSS_TARGET_WINDOW = 30  -- seconds; "X dies." counts if boss was targeted within this window
local recentTargets_kill = {}  -- lowercase name -> last-targeted timestamp

-- ============================================================
-- Event Handler
-- ============================================================
local killFrame = CreateFrame("Frame")
killFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")  -- for generic, named, and boss kills
killFrame:RegisterEvent("PLAYER_TARGET_CHANGED")          -- to track recent targets for fallback

killFrame:SetScript("OnEvent", function()
  -- Track player target changes for fallback kill validation
  if event == "PLAYER_TARGET_CHANGED" then
    local tname = UnitName("target")
    if tname then
      recentTargets_kill[string.lower(tname)] = time()
    end
    return
  end

  -- All kill tracking via hostile death message
  if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
    local msg = arg1 or ""
    -- Scenarios 1-3: explicit killer message (player, party, or raid landing the blow)
    local playerKill = string.match(msg, "^You have slain (.+)!$")
    local targetName = playerKill
      or string.match(msg, "^Your party has slain (.+)!$")
      or string.match(msg, "^Your raid has slain (.+)!$")

    -- Scenarios 4-5: no explicit killer (DoT tick, shared kill credit, etc.)
    -- Validate that our party was actually in the fight before crediting.
    if not targetName then
      local fallbackName = string.match(msg, "^(.+) dies%.$")
        or string.match(msg, "^(.+) has been slain%.$")
      if fallbackName then
        local lname = string.lower(fallbackName)
        -- Scenario 6: player targeted the boss within the recent window
        local recentlyTargeted = recentTargets_kill[lname]
          and (time() - recentTargets_kill[lname]) < BOSS_TARGET_WINDOW
        -- Scenario 7: a party/raid member currently has it targeted
        local partyTargeting = false
        if not recentlyTargeted then
          local numRaid = GetNumRaidMembers()
          local numParty = GetNumPartyMembers()
          if numRaid > 0 then
            for i = 1, numRaid do
              if UnitName("raid"..i.."target") == fallbackName then
                partyTargeting = true; break
              end
            end
          elseif numParty > 0 then
            for i = 1, numParty do
              if UnitName("party"..i.."target") == fallbackName then
                partyTargeting = true; break
              end
            end
          end
        end
        -- Scenario 8: player is currently in combat (boss died mid-fight)
        local inCombat = UnitAffectingCombat and UnitAffectingCombat("player")
        if recentlyTargeted or partyTargeting or inCombat then
          targetName = fallbackName
        end
      end
    end

    if not targetName then return end

    -- Generic kill counter: only count kills confirmed as ours ("You have slain X!")
    if playerKill and LeafVE_AchTest and LeafVE_AchTest.ShortName then
      local me = LeafVE_AchTest.ShortName(UnitName("player"))
      if me then
        local total = LeafVE_AchTest.IncrCounter(me, "genericKills")
        for i = 1, table.getn(GENERIC_MILESTONES) do
          local m = GENERIC_MILESTONES[i]
          if total >= m.value then
            LeafVE_AchTest:AwardAchievement(m.id, true)
          end
        end
      end
    end

    -- Named / boss kill tracking
    local lname = string.lower(targetName)
    local achId = NAMED_KILL_LOOKUP[lname]
    if achId and LeafVE_AchTest then
      local goal = NAMED_KILL_GOALS[achId]
      if goal then
        -- Critter: track cumulative kills
        local me = LeafVE_AchTest.ShortName(UnitName("player"))
        if me then
          local total = LeafVE_AchTest.IncrCounter(me, "nkills_"..achId)
          if total >= goal then
            LeafVE_AchTest:AwardAchievement(achId, true)
          end
        end
      else
        -- Named boss: one-shot award
        LeafVE_AchTest:AwardAchievement(achId, true)
      end
    end
  end
end)