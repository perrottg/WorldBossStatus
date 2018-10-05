local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")
local BOSS_DATA = nil
local resetIntervals = { daily = 1, weekly = 2, unknown = 3 }


function FlagActiveBosses()
	local bossData = BOSS_DATA
	local worldQuests = {}
   
	for _, category in pairs(bossData) do	
		local zones = category.maps or {}

		for zoneIndex = 1, #zones do
			local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(zones[zoneIndex])
			if taskInfo and #taskInfo then
			   for taskIndex = 1, #taskInfo do
					worldQuests[taskInfo[taskIndex].questId] = time()                      
			   end
			end
		end
		
		for _, boss in pairs(category.bosses) do
			if boss.questId then
				if worldQuests[boss.questId] or IsQuestFlaggedCompleted(boss.questId) then
					boss.active = true				
				end
			end
		end
	end
end

function GetWeeklyQuestResetTime()
	local now = time()
	local region = GetCurrentRegion()
	local dayOffset = { 2, 1, 0, 6, 5, 4, 3 }
	local regionDayOffset = {{ 2, 1, 0, 6, 5, 4, 3 }, { 4, 3, 2, 1, 0, 6, 5 }, { 3, 2, 1, 0, 6, 5, 4 }, { 4, 3, 2, 1, 0, 6, 5 }, { 4, 3, 2, 1, 0, 6, 5 } }
	local nextDailyReset = GetQuestResetTime()
	local utc = date("!*t", now + nextDailyReset)      
	local reset = regionDayOffset[region][utc.wday] * 86400 + now + nextDailyReset
	
	return reset  
 end

function AddHoliday()
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
			boss.active = true
			boss.resetInterval = resetIntervals.daily
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

function GetBoss(encounterID, questID, resetInterval, faction)
	local boss = {}

	if not resetInterval then resetInterval = resetIntervals.weekly end

	boss.name = EJ_GetEncounterInfo(encounterID)
	boss.questId = questID
	boss.resetInterval = resetInterval
	boss.faction = faction
	boss.displayName = boss.name

	return boss
end

function AddZandalarAndKulTiras()
	local category = {}

	category.name = 'Zandalar/Kul Tiras'
	category.maxKills = 2
	category.bosses = bosses
	category.bonusRollCurrencies = {1580}
	category.maps = {
		942, -- STORMSONG_VALLEY,
		896, -- DRUSTVAR
		895, -- TIRAGARDE_SOUND
		864, -- VOLDUN
		863, -- NAZMIR
		862, -- ZULDAZAR
		14   -- ARATHI_HIGHLANDS 
	}
	category.bosses = {
		GetBoss(2210, 52196), -- Dunegorger Kraulok
		GetBoss(2141, 52169), -- Ji'arak
		GetBoss(2139, 52181), -- T'zane
		GetBoss(2198, 52166), -- Warbringer Yenajz
		GetBoss(2199, 52163), -- Azurethos, The Winged Typhoon
		GetBoss(2197, 52157), -- Hailstone Construct
		GetBoss(2213, 52847, resetIntervals.unknown, 'Alliance'), -- Doom's Howl (Alliance)
		GetBoss(2212, 52848, resetIntervals.unknown, 'Horde')  -- The Lion's Roar (Horde)
	}	

	BOSS_DATA[#BOSS_DATA +1] = category
end

function AddBrokenIsles()
	local category = {}
	local bosses = {}

	category.name = EJ_GetInstanceInfo(822) -- Broken Isles
	category.maxKills = 1
	category.bonusRollCurrencies = {1273}
	category.legacy = true
	category.maps = {
		619, -- BROKENISLES
		627, -- DALARAN
		630, -- AZSUNA
		634, -- STORMHEIM
		641, -- VALSHARAH
		650, -- HIGHMOUNTAIN
		680, -- SURAMAR
		790, -- EYEOFAZSHARA
		646, -- BROKENSHORE
		905, -- ARGUS
		885, -- ANTORANWASTES
		830, -- KROKUUN
		882, -- MACAREE
		62, --  DARKSHORE
		947 -- AZEROTH	
	}
	category.bosses = {
		GetBoss(1790, 43512), -- Ana-Mouz
		GetBoss(1774, 43193), -- Calamir
		GetBoss(1789, 43448), -- Drugon the Frostblood
		GetBoss(1795, 43985), -- Flotsam
		GetBoss(1770, 42819), -- Humongris 
		GetBoss(1769, 43192), -- Levantus
		GetBoss(1783, 43513), -- Na'zak the Fiend
		GetBoss(1749, 42270), -- Nithogg
		GetBoss(1763, 42779), -- Shar'thos
		GetBoss(1756, 42269), -- The Soultakers
		GetBoss(1796, 44287), -- Withered'Jim
		GetBoss(1956, 47061), -- Apocron
		GetBoss(1883, 46947), -- Brutallus
		GetBoss(1884, 46948), -- Malificus
		GetBoss(1885, 46945), -- Si'vash
		{ name = 'Kosumoth', questId = 43798, resetInterval = resetIntervals.weekly } -- Kosumoth
	}

	BOSS_DATA[#BOSS_DATA +1] = category
end

function AddDraenor()
	local category = {}

	category.name = EJ_GetInstanceInfo(557)	-- Draenor 
	category.maxKills = 4
	category.bonusRollCurrencies = {1129, 994}
	category.legacy = true
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
	category.legacy = true
	category.bosses = {
		GetBoss(861),					-- Ordos
		{ name = L["The Celestials"], resetInterval = resetIntervals.weekly },	-- The Celestials 
		GetBoss(826),					-- Oondasta
		GetBoss(814),					-- Nalak
		GetBoss(725),					-- Salyisis's Warband
		GetBoss(691)					-- Sha of Anger
	}
	
	BOSS_DATA[#BOSS_DATA +1] = category
end

function WorldBossStatus:GetNextReset()
	local reset = {}

	reset[resetIntervals.daily] = time() + GetQuestResetTime()
	reset[resetIntervals.weekly] = GetWeeklyQuestResetTime()
	reset[resetIntervals.unknown] = -1

	return reset
end

function WorldBossStatus:GetBossData(update)
	if update or BOSS_DATA == nil or #BOSS_DATA == 0 then		
		BOSS_DATA = {}

		AddHoliday()
		AddZandalarAndKulTiras()
		AddBrokenIsles()
		AddDraenor()
		AddPanderia()

		FlagActiveBosses()
	end

	return BOSS_DATA
end