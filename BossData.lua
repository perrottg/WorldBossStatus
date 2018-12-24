local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")
local BOSS_DATA = nil
local resetIntervals = { daily = 1, weekly = 2, unknown = 3 }

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

function FlagActiveBosses()
	local bossData = BOSS_DATA
	local worldQuests = {}
	local lastSeen = WorldBossStatus.db.global.lastSeen or {}
   
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
			if category.expansion < 6 then
				boss.active = true
			elseif boss.questId then
				if worldQuests[boss.questId] or IsQuestFlaggedCompleted(boss.questId) then
					boss.active = true				
					lastSeen[boss.name] = time()
				elseif boss.resetInterval == resetIntervals.weekly then
					boss.active = lastSeen[boss.name] and lastSeen[boss.name] > (GetWeeklyQuestResetTime() - 604800)
				end
			end
		end
	end

	WorldBossStatus.db.global.lastSeen = lastSeen
end




 function GetBoss(encounterID, questID, mapID, drops, resetInterval, faction)
	local boss = {}

	if not resetInterval then resetInterval = resetIntervals.weekly end

	

	boss.name = EJ_GetEncounterInfo(encounterID)
	boss.questId = questID
	boss.drops = drops
	boss.resetInterval = resetInterval
	boss.faction = faction
	boss.displayName = boss.name

	_, boss.name = EJ_GetCreatureInfo(1, encounterID)

	if (mapID) then
		local mapInfo = C_Map.GetMapInfo(mapID)
		if mapInfo then 
			boss.location = mapInfo.name 
		end
	end

	return boss
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
		holidayBosses.name = 'Holiday'
		holidayBosses.maxKills = #bosses	
		holidayBosses.bosses = bosses
		holidayBosses.bonusRollCurrencies = {1580}

		BOSS_DATA[#BOSS_DATA +1] = holidayBosses
	end
end

function AddZandalarAndKulTiras()
	local category = {}

	category.name = _G["EXPANSION_NAME7"]
	category.title = category.name.." "..L["Bosses"]
	category.expansion = 7
	category.maxKills = 2
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
		GetBoss(2210, 52196, 864, { gear = 355 }), -- Dunegorger Kraulok
		GetBoss(2141, 52169, 862, { gear = 355 } ), -- Ji'arak
		GetBoss(2139, 52181, 863, { gear = 355 }), -- T'zane
		GetBoss(2198, 52166, 942, { gear = 355 }), -- Warbringer Yenajz
		GetBoss(2199, 52163, 895, { gear = 355 }), -- Azurethos, The Winged Typhoon
		GetBoss(2197, 52157, 896, { gear = 355 }), -- Hailstone Construct
		GetBoss(2213, 52847, 14, { gear = 370, toy = true }, resetIntervals.unknown, 'Alliance'), -- Doom's Howl (Alliance)
		GetBoss(2212, 52848, 14, { gear = 370, toy = true }, resetIntervals.unknown, 'Horde')  -- The Lion's Roar (Horde)
	}	
	category.showLocations = true 
	category.showDrops = true

	if GetAccountExpansionLevel() >= category.expansion and 
		(not WorldBossStatus.db.global.bossOptions.ignoredExpansions or
		not WorldBossStatus.db.global.bossOptions.ignoredExpansions[category.expansion]) then
		BOSS_DATA[#BOSS_DATA +1] = category
	end
end

function AddBrokenIsles()
	local category = {}
	local bosses = {}

	--category.name = EJ_GetInstanceInfo(822) -- Broken Isles
	category.name = _G["EXPANSION_NAME6"]
	category.title = category.name.." "..L["Bosses"]
	category.expansion = 6
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
		62,  -- DARKSHORE
		947  -- AZEROTH	
	}
	category.bosses = {
		GetBoss(1790, 43512, 680, { gear = 172 }), -- Ana-Mouz
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

	if GetAccountExpansionLevel() >= category.expansion and 
		(not WorldBossStatus.db.global.bossOptions.ignoredExpansions or
		not WorldBossStatus.db.global.bossOptions.ignoredExpansions[category.expansion]) then
		BOSS_DATA[#BOSS_DATA +1] = category
	end
end

function AddDraenor()
	local category = {}

	category.name = EJ_GetInstanceInfo(557)	-- Draenor 
	category.title = category.name.." "..L["Bosses"]
	category.expansion = 5
	category.maxKills = 4
	category.bonusRollCurrencies = {1129, 994}
	category.legacy = true
	category.bosses = {
		GetBoss(1452, 94015),	-- Supreme Lord Kazzak
		GetBoss(1262, 37464),	-- Rukhmar
		GetBoss(1211, 37462),	-- Tarlna the Ageless
		GetBoss(1291, 37462)	-- Drov the Ruiner
	}
	
	if GetAccountExpansionLevel() >= category.expansion and 
		(not WorldBossStatus.db.global.bossOptions.ignoredExpansions or
		not WorldBossStatus.db.global.bossOptions.ignoredExpansions[category.expansion]) then
		BOSS_DATA[#BOSS_DATA +1] = category
	end
end

function AddPanderia()
	local category = {}
	local mapInfo = C_Map.GetMapInfo(554)

	category.name = EJ_GetInstanceInfo(322)	-- Panderia
	category.title = category.name.." "..L["Bosses"]
	category.expansion = 4
	category.maxKills = 6
	category.bonusRollCurrencies = {776, 752, 697}
	category.legacy = true
	category.bosses = {
		GetBoss(861, nil, 554),			-- Ordos
		{ name = L["The Celestials"], displayName = L["The Celestials"], resetInterval = resetIntervals.weekly, location = mapInfo.name },	-- The Celestials 
		GetBoss(826, nil, 507),			-- Oondasta
		GetBoss(814, nil, 504),			-- Nalak
		GetBoss(725, nil, 376),			-- Salyisis's Warband
		GetBoss(691, nil, 379)			-- Sha of Anger
	}
	category.showLocations = true 
	
	if GetAccountExpansionLevel() >= category.expansion and 
		(not WorldBossStatus.db.global.bossOptions.ignoredExpansions or
		not WorldBossStatus.db.global.bossOptions.ignoredExpansions[category.expansion]) then
		BOSS_DATA[#BOSS_DATA +1] = category
	end
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