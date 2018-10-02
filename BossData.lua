local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")
local BOSS_DATA = {}

function AddHolidayBosses()
	local holidayBosses = nil
	local bosses = {}

	for index = 1, GetNumRandomDungeons() do 
		local dungeonID, name = GetLFGRandomDungeonInfo(index);
		local _, _, _, _, _, _, _, _, _, _, _, _, _, description, isHoliday = GetLFGDungeonInfo(dungeonID)

		if isHoliday and dungeonID ~= 828  and description ~= "" then		
			boss = {}
			boss.name = name
			boss.displayName = name
			boss.dungeonID = dungeonID
			bosses[#bosses +1] = boss
		end 
	end

	if #bosses > 0 then
		holidayBosses = {}
		holidayBosses.category = 'Holiday'
		holidayBosses.name = 'Holiday'
		holidayBosses.maxKills = #bosses	
		holidayBosses.bosses = bosses
		holidayBosses.bonusRollCurrencies = {1580}

		BOSS_DATA[#BOSS_DATA +1] = holidayBosses
	end
end

function GetBoss(encounterID, questID)
	local boss = {}
	boss.name = EJ_GetEncounterInfo(encounterID)
	boss.questId = questID
	boss.displayName = boss.name

	return boss
end

function AddBfaBosses()
	local bfaBosses = {}
	local bosses = {}

	bosses[1] = { name = EJ_GetEncounterInfo(2210), questId = 52196 }                       -- Dunegorger Kraulok
	bosses[2] = { name = EJ_GetEncounterInfo(2141), questId = 52169 }                       -- Ji'arak
	bosses[3] = { name = EJ_GetEncounterInfo(2139), questId = 52181 }                       -- T'zane
	bosses[4] = { name = EJ_GetEncounterInfo(2198), questId = 52166 }                       -- Warbringer Yenajz
	bosses[5] = { name = EJ_GetEncounterInfo(2199), questId = 52163 }                       -- Azurethos, The Winged Typhoon
	bosses[6] = { name = EJ_GetEncounterInfo(2197), questId = 52157 }                       -- Hailstone Construct
	bosses[7] = { name = EJ_GetEncounterInfo(2213), questId = 52847, faction = 'Alliance' } -- Doom's Howl (Alliance)
	bosses[8] = { name = EJ_GetEncounterInfo(2212), questId = 52848, faction = 'Horde'    } -- The Lion's Roar (Horde)

	bfaBosses.name = 'Zandalar/Kul Tiras'
	bfaBosses.maxKills = 2
	bfaBosses.bosses = bosses
	bfaBosses.bonusRollCurrencies = {1580}

	BOSS_DATA[#BOSS_DATA +1] = bfaBosses
end

function AddBrokenIsles()
	local category = {}
	local bosses = {}

	bosses[1] = { name = EJ_GetEncounterInfo(1790), questId = 43512 }  -- Ana-Mouz
	bosses[2] = { name = EJ_GetEncounterInfo(1774), questId = 43193 }  -- Calamir
	bosses[3] = { name = EJ_GetEncounterInfo(1789), questId = 43448 }  -- Drugon the Frostblood
	bosses[4] = { name = EJ_GetEncounterInfo(1795), questId = 43985 }  -- Flotsam
	bosses[5] = { name = EJ_GetEncounterInfo(1770), questId = 42819 }  -- Humongris 
	bosses[6] = { name = EJ_GetEncounterInfo(1769), questId = 43192 }  -- Levantus
	bosses[7] = { name = EJ_GetEncounterInfo(1783), questId = 43513 }  -- Na'zak the Fiend
	bosses[8] = { name = EJ_GetEncounterInfo(1749), questId = 42270 }  -- Nithogg
	bosses[9] = { name = EJ_GetEncounterInfo(1763), questId = 42779 }  -- Shar'thos
	bosses[10] = { name = EJ_GetEncounterInfo(1756), questId = 42269 } -- The Soultakers
	bosses[11] = { name = EJ_GetEncounterInfo(1796), questId = 44287 } -- Withered'Jim
	bosses[12] = { name = EJ_GetEncounterInfo(1956), questId = 47061 } -- Apocron
	bosses[13] = { name = EJ_GetEncounterInfo(1883), questId = 46947 } -- Brutallus
	bosses[14] = { name = EJ_GetEncounterInfo(1884), questId = 46948 } -- Malificus
	bosses[15] = { name = EJ_GetEncounterInfo(1885), questId = 46945 } -- Si'vash
	bosses[16] = { name = 'Kosumoth', questId = 43798 }				   -- Kosumoth

	category.name = EJ_GetInstanceInfo(822)							   -- Broken Isles
	category.maxKills = 1
	category.bosses = bosses
	category.bonusRollCurrencies = {1273}

	BOSS_DATA[#BOSS_DATA +1] = category
end

function AddDraenor()
	local category = {}

	category.name = EJ_GetInstanceInfo(557)	-- Draenor 
	category.maxKills = 4
	category.bonusRollCurrencies = {1129, 994}
	category.bosses = {
		GetBoss(1452, 94015),	-- Supreme Lord Kazzak
		GetBoss(1262, 37464),	-- Rukhmar
		GetBoss(1211, 37462),	-- Tarlna the Ageless
		GetBoss(1291, 37462)	-- Drov the Ruiner
	}
	
	BOSS_DATA[#BOSS_DATA +1] = category
end

function AddPanderia()
	local category = {}

	category.name = EJ_GetInstanceInfo(322)	-- Panderia
	category.maxKills = 6
	category.bonusRollCurrencies = {776, 752, 697}
	category.bosses = {
		GetBoss(861),					-- Ordos
		{ name = L["The Celestials"] },	-- The Celestials 
		GetBoss(826),					-- Oondasta
		GetBoss(814),					-- Nalak
		GetBoss(725),					-- Salyisis's Warband
		GetBoss(691)					-- Sha of Anger
	}
	
	BOSS_DATA[#BOSS_DATA +1] = category
end

function WorldBossStatus:GetBossData()
	AddHolidayBosses()
	AddBfaBosses()
	AddBrokenIsles()
	AddDraenor()
	AddPanderia()

	return BOSS_DATA
end