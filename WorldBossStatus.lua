local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")
WorldBossStatus = LibStub("AceAddon-3.0"):NewAddon("WorldBossStatus", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "LibSink-2.0");

local textures = {}


textures.worldBossStatus = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8.png"
textures.alliance = "|TInterface\\FriendsFrame\\PlusManz-Alliance:18|t"
textures.horde = "|TInterface\\FriendsFrame\\PlusManz-Horde:18|t"
textures.bossDefeated = "|TInterface\\WorldMap\\Skull_64Red:18|t"
textures.bossStatus = "|TInterface\\WorldMap\\Skull_64Red:18|t"
textures.bossAvailable = "|TInterface\\WorldMap\\Skull_64Grey:18|t"
textures.quest = "|TInterface\\Minimap\\OBJECTICONS:20:20:0:0:256:192:32:64:20:48|t"

local addonName = "WordBossStatus";
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local LibQTip = LibStub('LibQTip-1.0')

local red = { r = 1.0, g = 0.2, b = 0.2 }
local blue = { r = 0.4, g = 0.4, b = 1.0 }
local green = { r = 0.2, g = 1.0, b = 0.2 }
local yellow = { r = 1.0, g = 1.0, b = 0.2 }
local gray = { r = 0.5, g = 0.5, b = 0.5 }
local black = { r = 0.0, g = 0.0, b = 0.0 }
local white = { r = 1.0, g = 1.0, b = 1.0 }
local epic = { r = 0.63921568627451, g = 0.2078431372549, b = 0.93333333333333 }
local frame

local CURRENCIES = {	{currencyId = 1580,														  -- Seal of Wartorn Fate
						 weeklyMax = 2,
						 quests = {	{questId = 52834, level = 1, cost = 2000},					  -- Sealing Fate: Gold
							 		{questId = 52838, level = 2, cost = 5000},					  -- Sealing Fate: Piles of Gold
									{questId = 52837, level = 1, cost = 250, currencyId = 1560}, -- Sealing Fate: War Resources
									{questId = 52840, level = 2, cost = 500, currencyId = 1560}, -- Sealing Fate: Stashed War Resources
									{questId = 52835, level = 1, cost = 10, currencyId = 52839}, -- Sealing Fate: War Resources
									{questId = 52839, level = 2, cost = 25, currencyId = 52839}  -- Sealing Fate: Stashed War Resources

								  }
						},
						{currencyId = 1560}													  -- War Resources						 						
}


local MAPID_BROKENISLES = 1007
local isInitialized = false
	 
						   
for key, currency in pairs(CURRENCIES) do
	if not currency.name and currency.currencyId then
		currency.name, _, currency.texture = GetCurrencyInfo(currency.currencyId)	
	end
end
				 						   
local function colorise(s, color)
	if color and s then
		return format("|cff%02x%02x%02x%s|r", (color.r or 1) * 255, (color.g or 1) * 255, (color.b or 1) * 255, s)
	else
		return s
	end
end

local WorldBossStatusLauncher = LDB:NewDataObject(addonName, {
		type = "data source",
		text = L["World Boss Status"],
		label = "WorldBossStatus",
		tocname = "WorldBossStatus",
			--"launcher",
		icon = textures.worldBossStatus,
		OnClick = function(clickedframe, button)
			WorldBossStatus:ShowOptions() 
		end,
		OnEnter = function(self)
			frame = self
			WorldBossStatus:ShowToolTip()
		end,
	})
	
local defaults = {
	realm = {
		characters = {
			},
	},
	global = {
		realms = {
			},
		MinimapButton = {
			hide = false,
		}, 
		displayOptions = {
			showHintLine = true,
			showLegend = true,
			showMinimapButton = true,
		},
		characterOptions = {
			levelRestriction = true,
			minimumLevel = 120,
			removeInactive = true,
			inactivityThreshold = 28,
			include = 3,
		},
		bossOptions = {
			hideBoss = {
			},	
			trackLegacyBosses = false,
			disableHoldidayBossTracking = false,
		},
		bonusRollOptions = {		
			trackWeeklyQuests = true,
			trackedCurrencies = { 
				[1129] = true,
			},
			trackLegacyCurrencies = false,
		},
	},
};

local options = {
    handler = WorldBossStatus,
    type = "group",
    args = {
		features = {
			handler = WorldBossStatus,
			type = 'group',
			name = L["General Options"],
			desc = "",
			order = 10,
			args = {			
				displayOptions = {
					type = 'group',
					inline = true,
					name = L["Display Options"],
					desc = "",
					order = 1,
					args = {	
						showMiniMapButton = {
							type = "toggle",
							name = L["Minimap Button"],
							desc = L["Toggles the display of the minimap button."],
							get = "IsShowMinimapButton",
							set = "ToggleMinimapButton",
							order=1,
						},
						--showHintLine = {
						--	type = "toggle",
						--	name = L["Hint Line"],
						--	desc = L["Toggles the display of the hint line."],
						--	get = function(info)
						--			return WorldBossStatus.db.global.displayOptions.showHintLine
						--		  end,
						--	set = function(info, value)
						--			WorldBossStatus.db.global.displayOptions.showHintLine = value
						--		  end,
						--	order = 2,
						--},
					},
				},
				
			},
		},
		characterOptions = {
			handler = WorldBossStatus,
			type = 'group',
			name = L["Character Options"],
			desc = "",
			order = 20,
			args = {	
				inlcudeCharactersOptions = {
					type = 'group',
					inline = true,
					name = L["Show Characters"],
					desc = "",
					order = 1,
					args = {					
						realmOption = {
							type = "toggle",
							name = L["On this realm"],
							desc = L["Show characters on this realm."],
							get = function(info)
								return WorldBossStatus.db.global.characterOptions.include == 2
							end,
							set = function(info, value)
								if value then 
									WorldBossStatus.db.global.characterOptions.include = 2
								else
									WorldBossStatus.db.global.characterOptions.include = 1
								end
							end,
							order=1,
						},
						accountOption = {
							type = "toggle",
							name = L["On this account"],
							desc = L["Show characters on this WoW account."],
							get = function(info)
								return WorldBossStatus.db.global.characterOptions.include == 3
							end,
							set = function(info, value)
								if value then 
									WorldBossStatus.db.global.characterOptions.include = 3
								else
									WorldBossStatus.db.global.characterOptions.include = 1
								end
							end,
							order=2,
						},
					},
				},
				characterLevelOptions = {
					type= "group",
					inline = true,
					name = L["Level Restriction"],
					desc = "",
					order=5,
					args = {
						enableLevelRestriction = {
							type = "toggle",
							name = L["Enable"],
							desc = L["Enable level restriction."],
							get = function(info)
								return WorldBossStatus.db.global.characterOptions.levelRestriction
							end,
							set = function(info, value)
								WorldBossStatus.db.global.characterOptions.levelRestriction = value
							end,
							order=1,
						},
						minimumLevelOption = {
							type = "range",
							name = L["Minimum Level"],
							desc = L["Show characters this level and higher."],
							step = 1, min = 1, max = 120,
							order = 2,
							get = function(info)
								return WorldBossStatus.db.global.characterOptions.minimumLevel
							end,
							set = function(info, value)
								WorldBossStatus.db.global.characterOptions.minimumLevel = value
							end,
							disabled = function()
								return not WorldBossStatus.db.global.characterOptions.levelRestriction
							end,
						},
					},
 				},
				hideInactiveOptions = {
					type= "group",
					inline = true,
					name = L["Hide Inactive Characters"],
					desc = "",
					order=6,
					args = {
						purgeInactiveCharacters = {
							type = "toggle",
							name = L["Enable"],
							desc = L["Enable hiding inactive characters."],
							get = function(info)
								return WorldBossStatus.db.global.characterOptions.removeInactive
							end,
							set = function(info, value)
								WorldBossStatus.db.global.characterOptions.removeInactive = value
							end,
							order=1,
						},
						inactivityThresholdOption = {
							type = "range",
							name = L["Inactivity Threshold (days)"],
							desc = L["Hide characters that have been inactive for this many days."],
							step = 1, min = 14, max = 42,
							order = 2,
							get = function(info)
								return WorldBossStatus.db.global.characterOptions.inactivityThreshold
							end,
							set = function(info, value)
								WorldBossStatus.db.global.characterOptions.inactivityThreshold = value
							end,
							disabled = function()
								return not WorldBossStatus.db.global.characterOptions.removeInactive
							end,
						},
					},
				},
				trackedCharactersOption = {
					type = "group",
					inline = true,
					name = L["Remove Tracked Characters"],
					desc = "",
					order = 7,
					args = {
						realmSelect = {
							type = "select",
							name = L["Realm"],
							desc = L["Select a realm to remove a tracked character from."],
							order = 1,
							values = function()
										local realmList = {}

										for realm in pairs(WorldBossStatus.db.global.realms) do
											realmList[realm] = realm
										end

										return realmList
									 end,
							get = function(info)
									return selectedRealm
								  end,
							set = function(info, value)
									selectedRealm = value
									selectedCharacter = nil
								  end,
						},
						characterSelect = {
							type = "select",
							name = L["Character"],
							desc = L["Select the tracked character to remove."],
							order = 2,
							disabled = function()
										  return selectedRealm == nil
									   end,
							values = function()
										local list = {}
										local realmInfo = WorldBossStatus.db.global.realms[selectedRealm]
										if realmInfo then
											local characters = realmInfo.characters
	
											for key,value in pairs(characters) do
												list[key] = key
											end
										end
										return list
									 end,
							get = function(info)
									return selectedCharacter
								  end,
							set = function(info, value)
									selectedCharacter = value
								  end,
						},
						removeAction = {
							type = "execute",							
							name = L["Remove"],
							desc = L["Click to remove the selected tracked character."],
							order = 3,
							disabled = function()
										  return selectedRealm == nil or selectedCharacter == nil
									   end,
							func = function()

								local realmInfo = WorldBossStatus.db.global.realms[selectedRealm]
								local characterInfo = realmInfo.characters[selectedCharacter]
								local count = 0

								if not realmInfo then
									return
								end

								if characterInfo then 
									realmInfo.characters[selectedCharacter] = nil								
								end
								
								for key,value in pairs(realmInfo.characters) do 
									count = count + 1
								end
								
								if count == 0 then 
									WorldBossStatus.db.global.realms[selectedRealm] = nil
								end
							end,
						},
					},
				},
			}		
		},
		bossTracking = {
			type = "group",
			name = L["Boss Options"],
			handler = WorldBossStatus,
			desc = "",
			order = 30,
			args = {
				trackHoldidayBosses = {
					type = "toggle",
					name = L["Track holiday bosses"],
					desc = L["Automatically track holiday bosses during world events."],
					get = function(info)
						return not WorldBossStatus.db.global.bossOptions.disableHoldidayBossTracking
					end,
					set = function(info, value)
						WorldBossStatus.db.global.bossOptions.disableHoldidayBossTracking = not value
					end,
					order=1,
				},
				trackedBosses = {
					type = "multiselect",
					name = L["Tracked Bosses"],
					desc = L["Select the world bosses you would like to track."],
					width = "full",
					values = "GetBossOptions",
					--get = function(info, key)
					--		return not WorldBossStatus.db.global.bossOptions.hideBoss[WOD_WORLD_BOSSES[key].name]
					--	end,
					--set = function(info, key, value)
					--		WorldBossStatus.db.global.bossOptions.hideBoss[WOD_WORLD_BOSSES[key].name] = not value
					--end,
					--get = function(info, key)
					--		return not WorldBossStatus.db.global.bossOptions.hideBoss[WORLD_BOSSES[key].name]
					--	end,
					--set = function(info, key, value)
					--		WorldBossStatus.db.global.bossOptions.hideBoss[WORLD_BOSSES[key].name] = not value
					--end,
					order=2
				},
				--trackLegacyBosses = {
				--	type = "toggle",
				--	name = L["Track legacy bosses"],
				--	desc = L["Enable tracking of older legacy world bosses."],
				--	get = function(info)
				--		return WorldBossStatus.db.global.bossOptions.trackLegacyBosses
				--	end,
				--	set = function(info, value)
				--		WorldBossStatus.db.global.bossOptions.trackLegacyBosses = value
				--	end,
				--	order=3,
				--},
				--trackedLegacyBosses = {
				--	type = "multiselect",
				--	name = L["Tracked Legacy Bosses"],
				--	desc = L["Select the legacy world bosses you would like to track."],
				--	width = "full",
				--	values = "GetLegacyWorldBossOptions",
				--	get = function(info, key)
				--			return not WorldBossStatus.db.global.bossOptions.hideBoss[WOD_WORLD_BOSSES[key].name]
				--		end,
				--	set = function(info, key, value)
				--			WorldBossStatus.db.global.bossOptions.hideBoss[WOD_WORLD_BOSSES[key].name] = not value
				--	end,
				--	disabled = function()
				--		return not WorldBossStatus.db.global.bossOptions.trackLegacyBosses
				--	end,
				--	order=4
				--},
			}
		}--,
		--worldBossTracking = {
		--	type = "group",
		--	name = L["World Boss Options"],
		--	handler = WorldBossStatus,
		--	desc = "",
		--	order = 30,
		--	args = {
		--		trackHoldidayBosses = {
		--			type = "toggle",
		--			name = L["Track holiday bosses"],
		--			desc = L["Automatically track holiday bosses during world events."],
		--			get = function(info)
		--				return not WorldBossStatus.db.global.bossOptions.disableHoldidayBossTracking
		--			end,
		--			set = function(info, value)
		--				WorldBossStatus.db.global.bossOptions.disableHoldidayBossTracking = not value
		--			end,
		--			order=1,
		--		},
		--		--trackedWorldBosses = {
		--		--	type = "multiselect",
		--		--	name = L["Tracked World Bosses"],
		--		--	desc = L["Select the world bosses you would like to track."],
		--		--	width = "full",
		--		--	values = "GetWorldBossOptions",
		--		--	--get = function(info, key)
		--		--	--		return not WorldBossStatus.db.global.bossOptions.hideBoss[WOD_WORLD_BOSSES[key].name]
		--		--	--	end,
		--		--	--set = function(info, key, value)
		--		--	--		WorldBossStatus.db.global.bossOptions.hideBoss[WOD_WORLD_BOSSES[key].name] = not value
		--		--	--end,
		--		--	--get = function(info, key)
		--		--	--		return not WorldBossStatus.db.global.bossOptions.hideBoss[WORLD_BOSSES[key].name]
		--		--	--	end,
		--		--	--set = function(info, key, value)
		--		--	--		WorldBossStatus.db.global.bossOptions.hideBoss[WORLD_BOSSES[key].name] = not value
		--		--	--end,
		--		--	order=2
		--		--},
		--	}
		--}--,
--		bonusRollTracking = {
--			type = "group",
--			--inline = true,
--			handler = WorldBossStatus,
--			name = L["Bonus Roll Options"],
--			desc = "",
--			order = 40,
--			args = {
--				trackQuests = {
--					type = "toggle",
--					name = L["Track weekly quests"],
--					desc = L["Enable tracking the weekly 'Sealing Fate' quests."],
--					width = "full",
--					get = function(info)
--							return WorldBossStatus.db.global.bonusRollOptions.trackWeeklyQuests
--						end,
--					set = function(info, value)
--							WorldBossStatus.db.global.bonusRollOptions.trackWeeklyQuests = value
--						end,
--					order=1,
--				},
----				trackedCurrencies = {
----					type = "multiselect",
----					name = L["Tracked Currencies"],
----					desc = L["Select the currencies you would like to track."],
----					width = "full",
----					--values = "GetCurrencyOptions",
----					--get = function(info, key)
----					--		return WorldBossStatus.db.global.bonusRollOptions.trackedCurrencies[trackableCurrencies[key].id]
----					--	end,
----					--set = function(info, key, value)
----					--		WorldBossStatus.db.global.bonusRollOptions.trackedCurrencies[trackableCurrencies[key].id] = value
----					--end,
----					order=2,
----				},

----				trackLegacyCurrency = {
----					type = "toggle",
----					name = L["Track legacy currencies"],
----					desc = L["Enable tracking of older legacy bonus roll currencies."],
----					--get = function(info)
----					--	return WorldBossStatus.db.global.bonusRollOptions.trackLegacyCurrencies
----					--end,
----					--set = function(info, value)
----					--	WorldBossStatus.db.global.bonusRollOptions.trackLegacyCurrencies = value
----					--end,
----					order=3,
----				},
----				trackedLegacyCurrencies = {
----					type = "multiselect",
----					name = L["Tracked Legacy Currencies"],
----					desc = L["Select the legacy currencies you would like to track."],
----					width = "full",
----					--values = "GetLegacyCurrencyOptions",
----					--get = function(info, key)
----					--		return WorldBossStatus.db.global.bonusRollOptions.trackedCurrencies[trackableCurrencies[key].id]
----					--	end,
----					--set = function(info, key, value)
----					--		WorldBossStatus.db.global.bonusRollOptions.trackedCurrencies[trackableCurrencies[key].id] = value
----					--end,
----					--disabled = function()
----					--	return not WorldBossStatus.db.global.bonusRollOptions.trackLegacyCurrencies
----					--end,
----					order=4,
----				},
--			}			
--		}
	}
}

--function WorldBossStatus.UpdateActiveWorldQuests()
--	local worldQuests = {}

--	for zoneIndex = 1, C_MapCanvas.GetNumZones(MAPID_BROKENISLES) do   
--		local zoneMapID, zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfo(MAPID_BROKENISLES, zoneIndex);

--		if zoneDepth <= 1 then
--			local questList = C_TaskQuest.GetQuestsForPlayerByMapID(zoneMapID, MAPID_BROKENISLES)
   
--			if questList then
--				for i = 1, #questList do  
--					local questId = questList[i].questId
--					local quest = {}

--					quest.questId = questId
--					quest.timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questId)
--					quest.zone = zoneName
--					quest.timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questId)

--					worldQuests[quest.questId] = quest
--				end
--			end
--		end
--	end

--end

--function WorldBossStatus:GetActiveWorldBosses()
--	local bossData = WorldBossStatus.bossData
--	local questsFound = {}
--	local questsLocation = {}
--	local activeWorldBosses = {}
	



--	for zoneIndex = 1, C_MapCanvas.GetNumZones(MAPID_BROKENISLES) do   
--		local zoneMapID, zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfo(MAPID_BROKENISLES, zoneIndex);

--		if zoneDepth <= 1 then
--			local questList = C_TaskQuest.GetQuestsForPlayerByMapID(zoneMapID, MAPID_BROKENISLES)
   
--			if questList then
--				for i = 1, #questList do      
--					timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questList[i].questId)               
--					tagId, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questList[i].questId);
--					questsFound[questList[i].questId] = time()
--					questsLocation[questList[i].questId] = zoneName
--				end
--			end
--		end
--	end

--	for _, category in pairs(bossData) do
--		for _, boss in pairs(category.bosses) do

--			if boss.questId then
--				if questsFound[boss.questId] or (boss.questId and IsQuestFlaggedCompleted(boss.questId)) then
--					activeWorldBosses[boss.name] = time()
--				end
--				if questsLocation[boss.questId] then
--					boss.location = questsLocation[boss.questId]
--				end
--			end
--		end
--	end

--	return activeWorldBosses
--end

local MyScanningTooltip = CreateFrame("GameTooltip", "MyScanningTooltip", UIParent, "GameTooltipTemplate")

local QuestTitleFromID = setmetatable({}, { __index = function(t, id)
	MyScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	MyScanningTooltip:SetHyperlink("quest:"..id)
	local title = MyScanningTooltipTextLeft1:GetText()
	MyScanningTooltip:Hide()
	if title and title ~= RETRIEVING_DATA then
		t[id] = title
		return title
	end
end })

function WorldBossStatus:GetCurrencyOptions()
--    local itemsList = {}
	
--    for key,value in pairs(trackableCurrencies) do
--		if not value.legacy then
--			 itemsList[key] = "|T"..value.texture..":14:14:0:0:64:64:4:60:4:60|t "..value.name
--		end
--    end

--    return itemsList
end

function WorldBossStatus:GetLegacyCurrencyOptions()
--    local itemsList = {}
	
--    for key,value in pairs(trackableCurrencies) do
--		if (value.legacy) then
--			itemsList[key] = "|T"..value.texture..":14:14:0:0:64:64:4:60:4:60|t "..value.name
--		end
--    end

--    return itemsList
end

function WorldBossStatus:GetBossOptions()
	local itemsList = {}
	
    for key,value in pairs(WOD_WORLD_BOSSES) do
		if not value.legacy then
			itemsList[key] = value.name
			WorldBossStatus:Print(key .. " = " .. value.name)				
		end
    end

	--for key, value in pairs(WORLD_BOSSES) do
	--	itemList[key] = value.name
	--	WorldBossStatus:Print(key .. " = " .. value.name)	
	--end

    return itemsList
end

function WorldBossStatus:GetWorldBossOptions()
	local itemsList = {}
	
  --  for key,value in pairs(WOD_WORLD_BOSSES) do
		--if not value.legacy then
		--	itemsList[key] = value.name
		--	WorldBossStatus:Print(key .. " = " .. value.name)				
		--end
  --  end

	for key, value in pairs(WORLD_BOSSES) do
		itemList[key] = value.name
		WorldBossStatus:Print(key .. " = " .. value.name)	
	end

    return itemsList
end

function WorldBossStatus:GetLegacyWorldBossOptions()
	local itemsList = {}
	
    for key,value in pairs(WOD_WORLD_BOSSES) do
		if value.legacy then
			itemsList[key] = value.name
		end
    end

    return itemsList

end

local function CleanupCharacters()
	local threshold = WorldBossStatus.db.global.characterOptions.inactivityThreshold * (24 * 60 * 60)	
	
	if not WorldBossStatus.db.global.characterOptions.removeInactive or threshold == 0 then
		return
	 end
	

	for realm in pairs(WorldBossStatus.db.global.realms) do
		local realmInfo = self.db.global.realms[realm]
		local characters = nil
		
		if realmInfo then
			local characters = realmInfo.characters
	
			for key,value in pairs(characters) do
				if value.lastUpdate and value.lastUpdate < time() - threshold then
					value = nil
				end
			end
			
		end
	end
	
end

local function ShowKill(boss, kill, lastReset)
	local subTooltip = WorldBossStatus.subTooltip
	local line = subTooltip:AddLine()
	local desc = ""
	local color = gray
	local bossTexture = textures.bossAvailable
	local rollTexture = ""
		
	if kill and kill.KillTime then		
		desc = string.lower(SecondsToTime(time() - kill.KillTime, false, true, 1).." ago")	
	end

	if (kill and kill.bonusRollTime and kill.bonusRollTime > lastReset) then
		local _, _, texture = GetCurrencyInfo(kill.bonusRollUsed or 1273)
		
		rollTexture = "|T"..texture..":16|t"					
	end

	if kill and (kill.KillTime == nil or kill.KillTime > lastReset) then	
		--desc = string.lower(SecondsToTime(time() - kill.KillTime, false, true, 2).." ago")
		bossTexture = textures.bossDefeated
		color = red
	end
	
	subTooltip:SetCell(line, 1, boss.name, nil, "LEFT")
	subTooltip:SetCell(line, 2, desc, nil, "RIGHT")	
	subTooltip:SetCell(line, 3, bossTexture, nil, "RIGHT", nil, nil, nil, nil, 20, 0)
	subTooltip:SetCell(line, 4, rollTexture, nil, "CENTER", nil, nil, nil, nil, 20, 0)
	subTooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
end

local function ShowBossKills(character, region)	
	local subTooltip = WorldBossStatus.subTooltip
	local lastReset = WorldBossStatus:GetWeeklyQuestResetTime() - 604800
	local _, _, texture = GetCurrencyInfo(region.bonusRollCurrencies[1] or "")
	local bonusRollTexture = "|T"..texture..":16|t"

	if LibQTip:IsAcquired("WBSsubTooltip") and subTooltip then
		subTooltip:Clear()
	else 
		subTooltip = LibQTip:Acquire("WBSsubTooltip", 4, "LEFT", "RIGHT", "CENTER", "CENTER")
		WorldBossStatus.subTooltip = subTooltip	
	end	

	subTooltip:ClearAllPoints()
	subTooltip:SetClampedToScreen(true)
	subTooltip:SetPoint("TOP", WorldBossStatus.tooltip, "TOP", 30, 0)
	subTooltip:SetPoint("RIGHT", WorldBossStatus.tooltip, "LEFT", -20, 0)

	line = subTooltip:AddHeader()	
	subTooltip:AddSeparator(6,0,0,0,0)

	subTooltip:SetCell(line, 1, region.name.." "..L["Bosses"])
	subTooltip:SetCellTextColor(line, 1, yellow.r, yellow.g, yellow.b)

	for _, boss in pairs(region.bosses) do
		local kill = nil

		if character.worldBossKills then
			kill = character.worldBossKills[boss.name]
		end
		if not kill and character.bossKills[boss.name] and character.bossKills[boss.name] > time() then
			kill = {}
		end
		
		if not boss.faction or character.faction == boss.faction then
		  ShowKill(boss, kill, lastReset)
		end
	end	

	subTooltip:AddSeparator(6,0,0,0,0)
	line = subTooltip:AddLine()
	subTooltip:SetCell(line, 1, format("Legend: %sDefeated  %s Bonus roll used", textures.bossDefeated, bonusRollTexture) , nil, LEFT, 3)


	subTooltip:Show()
end

local function ShowBonusRolls(character, currency)	
	local cost = nil
	local currencyInfo = character.currencies[currency.currencyId]

	if LibQTip:IsAcquired("WBSsubTooltip") and subTooltip then
		LibQTip:Release(subTooltip)
		subTooltip = nil		
	end	

	subTooltip = LibQTip:Acquire("WBSsubTooltip", 4, "LEFT", "RIGHT", "RIGHT")
	subTooltip:ClearAllPoints()
	subTooltip:SetClampedToScreen(true)
	--subTooltip:SmartAnchorTo(WorldBossStatus.tooltip)

	--subTooltip:SetPoint("LEFT", WorldBossStatus.tooltip, "RIGHT", 30, 0)
	subTooltip:SetPoint("TOP", WorldBossStatus.tooltip, "TOP", 30, 0)
	subTooltip:SetPoint("RIGHT", WorldBossStatus.tooltip, "LEFT", -20, 0)

	


	for _, quest in pairs (currency.quests) do
		if not quest.name then
			quest.name = QuestTitleFromID[quest.questId]
		end
	end

	local reset = WorldBossStatus:GetWeeklyQuestResetTime() - time()

	line = subTooltip:AddHeader()
	subTooltip:SetCell(line, 1, "|T"..currency.texture..":0|t "..currency.name)
	subTooltip:SetLineTextColor(line, yellow.r, yellow.g, yellow.b)
	subTooltip:AddSeparator(6,0,0,0,0)
	line = subTooltip:AddLine("Amount", currencyInfo.balance)
	line = subTooltip:AddLine("Earned this week")
	subTooltip:AddSeparator(3,0,0,0,0)
	line = subTooltip:AddLine("Weekly maximum", currency.weeklyMax)
	line = subTooltip:AddLine("Total maximum")
	subTooltip:AddSeparator(6,0,0,0,0)

	line = subTooltip:AddLine("Weekly Collection Quest", "Cost", "Status")
	subTooltip:SetLineTextColor(line, yellow.r, yellow.g, yellow.b)
	subTooltip:AddSeparator(3,0,0,0,0)


	for _, quest in pairs (currency.quests) do

		if quest.currencyId and quest.cost then
			_, _, texture = GetCurrencyInfo(quest.currencyId)
			cost = quest.cost.." |T"..texture..":0|t"
		elseif quest.cost then
			cost = quest.cost.." g"
		else
			cost = ""
		end

		if currencyInfo.collectionQuests and currencyInfo.collectionQuests[quest.questId] then
			line = subTooltip:AddLine(quest.name, cost, "Collected")
			subTooltip:SetLineTextColor(line, green.r, green.g, green.b)
		elseif currencyInfo.collectedThisWeek and quest.level <= currencyInfo.collectedThisWeek then
			line = subTooltip:AddLine(quest.name, cost, "Not available")
			subTooltip:SetLineTextColor(line, gray.r, gray.g, gray.b)
		else
			line = subTooltip:AddLine(quest.name, cost, "Available")
		end
	end

	subTooltip:AddSeparator(6,0,0,0,0)

	line = subTooltip:AddLine("Quests will reset in "..SecondsToTime(reset, true, true, 2))

	subTooltip:Show()
end



function WorldBossStatus:ShowSubTooltip(cell, info)	
	if not info then
		return
	end
	if info.type == "BOSSES" then
		ShowBossKills(info.character, info.region)
	elseif info.type == "BONUSROLLS" then
		--ShowBonusRolls(info.character, info.currency)
	end	
end

local function HideSubTooltip()
	local subTooltip = WorldBossStatus.subTooltip
	if subTooltip then
		LibQTip:Release(subTooltip)
		subTooltip = nil
	end
	GameTooltip:Hide()
	WorldBossStatus.subTooltip = subTooltip
end

function WorldBossStatus:DisplayCharacterInTooltip(characterName, characterInfo)
	local bossData = WorldBossStatus.bossData
	local lastReset = WorldBossStatus:GetWeeklyQuestResetTime() - 604800
	local tooltip = WorldBossStatus.tooltip
	local line = tooltip:AddLine()
	local factionIcon = ""
	local coins = 0
	local seals = 0

	if characterInfo.faction and characterInfo.faction == "Alliance" then
		factionIcon = textures.alliance
	elseif characterInfo.faction and characterInfo.faction == "Horde" then
		factionIcon = textures.horde
	end

	tooltip:SetCell(line, 2, factionIcon.." "..characterName)

	column = 2
		
	for _, currency in pairs(CURRENCIES) do					
		local currencyInfo = nil
		
		if characterInfo.currencies then 
			currencyInfo = characterInfo.currencies[currency.currencyId]
		end
		
		column = column + 1
		
		if currencyInfo then
			if currency.weeklyMax then
				tooltip:SetCell(line, column, currencyInfo.balance .. "  " .. currencyInfo.collectedThisWeek.."/"..currency.weeklyMax, nil, "RIGHT")
			else
				tooltip:SetCell(line, column, BreakUpLargeNumbers(currencyInfo.balance), nil, "RIGHT")
			end

		else
			tooltip:SetCell(line, column, "?", nil, "RIGHT")
		end

	end

	column = column + 1

	for _, category in pairs(bossData) do
		kills = 0

		for _, boss in pairs(category.bosses) do
			local kill = nil

			if characterInfo.worldBossKills then
				kill = characterInfo.worldBossKills[boss.name]
			end
			if not kill and characterInfo.bossKills[boss.name] and characterInfo.bossKills[boss.name] > time() then
				kill = {}
			end

			if kill and (kill.KillTime == nil or kill.KillTime > lastReset) then	
				kills = kills + 1
			end
		end

		if kills >= category.maxKills then
			tooltip:SetCell(line, column, textures.bossDefeated)
		else  
			tooltip:SetCell(line, column, kills.."/"..category.maxKills)
		end

		tooltip:SetCellScript(line, column, "OnEnter", function(self)
			local info = { type="BOSSES", character=characterInfo, region=category}
			WorldBossStatus:ShowSubTooltip(self, info)
		end)

		tooltip:SetCellScript(line, column, "OnLeave", HideSubTooltip)


		column = column+1

	end

	if characterInfo.class then
		local color = RAID_CLASS_COLORS[characterInfo.class]
		tooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	end	

end


function WorldBossStatus:IsShowMinimapButton(info)
	return not self.db.global.MinimapButton.hide
end

function WorldBossStatus:ToggleMinimapButton(info, value)
	self.db.global.MinimapButton.hide = not value

	if self.db.global.MinimapButton.hide then
		LDBIcon:Hide(addonName)
	else
		LDBIcon:Show(addonName)
	end

	LDBIcon:Refresh(addonName)
	LDBIcon:Refresh(addonName)
end

function WorldBossStatus:ShowOptions()
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function WorldBossStatus:OnInitialize()	
	self.db = LibStub("AceDB-3.0"):New("WorldBossStatusDB", defaults, true)
	WorldBossStatus.debug = false

	LDBIcon:Register(addonName, WorldBossStatusLauncher, self.db.global.MinimapButton)

	local wbscfg = LibStub("AceConfig-3.0")
	wbscfg:RegisterOptionsTable("World Boss Status", options)
	wbscfg:RegisterOptionsTable("World Boss Status Features", options.args.features)
	wbscfg:RegisterOptionsTable("World Boss Status Characters", options.args.characterOptions)
	--wbscfg:RegisterOptionsTable("World Boss Status Bosses", options.args.bossTracking)
	--wbscfg:RegisterOptionsTable("World Boss Status World Bosses", options.args.worldBossTracking)
	--wbscfg:RegisterOptionsTable("World Boss Status Bonus Rolls", options.args.bonusRollTracking)


	local wbsdia = LibStub("AceConfigDialog-3.0")

	self.optionsFrame =  wbsdia:AddToBlizOptions("World Boss Status Features", L["World Boss Status"])
	wbsdia:AddToBlizOptions("World Boss Status Characters", L["Characters"], L["World Boss Status"])
	--wbsdia:AddToBlizOptions("World Boss Status Bosses", L["Bosses"], L["World Boss Status"])
	--wbsdia:AddToBlizOptions("World Boss Status World Bosses", L["World Bosses"], L["World Boss Status"])
	--wbsdia:AddToBlizOptions("World Boss Status Bonus Rolls", L["Bonus Rolls"], L["World Boss Status"])

	--self:SetSinkStorage(self.db)

	self:RegisterChatCommand("wbs", "ChatCommand")
	self:RegisterChatCommand("worldbossstatus", "ChatCommand")


	RequestRaidInfo()
end

local function ShowHeader(tooltip, marker, headerName)
	local bossData = WorldBossStatus.bossData

	line = tooltip:AddHeader()

	if (marker) then
		tooltip:SetCell(line, 1, marker)
	end
	
	tooltip:SetCell(line, 2, headerName, nil, nil, nil, nil, nil, 50)
	tooltip:SetCellTextColor(line, 2, yellow.r, yellow.g, yellow.b)

	column = 2

	for _, currency in pairs(CURRENCIES) do
		column = column + 1
		tooltip:SetCell(line, column, "|T"..currency.texture..":0|t", nil, "RIGHT")
	end

	column = column + 1

	for _, category in pairs(bossData) do
		tooltip:SetCell(line, column, category.name, "CENTER")
		tooltip:SetCellTextColor(line, column, yellow.r, yellow.g, yellow.b)
		column = column+1
	end

	return line
end 

function WorldBossStatus:DisplayRealmInToolip(realmName)
	local realmInfo = self.db.global.realms[realmName]
	local characters = nil
	local collapsed = false
	local epoch = time() - (WorldBossStatus.db.global.characterOptions.inactivityThreshold * 24 * 60 * 60)

	if realmInfo then
		characters = realmInfo.characters
		collapsed = realmInfo.collapsed
	end

	local characterNames = {}
	local currentCharacterName = UnitName("player")
	local currentRealmName = GetRealmName()
	local tooltip = WorldBossStatus.tooltip
	local levelRestriction = WorldBossStatus.db.global.characterOptions.levelRestruction or false;
	local minimumLevel = 1

	if WorldBossStatus.db.global.characterOptions.levelRestriction then
		minimumLevel = WorldBossStatus.db.global.characterOptions.minimumLevel		
		if not minimumLevel then minimumLevel = 90 end
	end	
		
	if not characters then
		return 
	end

	for k,v in pairs(characters) do
		local inlcude = true
		if (realmName ~= currentRealmName or k ~= currentCharacterName) and 
		   (not WorldBossStatus.db.global.characterOptions.removeInactive or v.lastUpdate > epoch)  and
   		   (v.level >= minimumLevel) then
				table.insert(characterNames, k);
		end
	end

	if (table.getn(characterNames) == 0) then
		return
	end
			   
	table.sort(characterNames)

	tooltip:AddSeparator(2,0,0,0,0)

	if not collapsed then
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-MinusButton-Up:16|t", realmName)

		tooltip:AddSeparator(3,0,0,0,0)

		for k,v in pairs(characterNames) do
			WorldBossStatus:DisplayCharacterInTooltip(v, characters[v])
		end

		tooltip:AddSeparator(1, 1, 1, 1, 1.0)
	else
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-PlusButton-Up:16|t", realmName)
	end

	tooltip:SetCellTextColor(line, 2, yellow.r, yellow.g, yellow.b)	
	tooltip:SetCellScript(line, 1, "OnMouseUp", RealmOnClick, realmName)
end

function RealmOnClick(cell, realmName)
	WorldBossStatus.db.global.realms[realmName].collapsed = not WorldBossStatus.db.global.realms[realmName].collapsed
	WorldBossStatus:ShowToolTip()
end

function WorldBossStatus:ShowToolTip()
	local bossData = WorldBossStatus.bossData or WorldBossStatus:GetBossData()

	WorldBossStatus.bossData = bossData

	local tooltip = WorldBossStatus.tooltip
	local characterName = UnitName("player")
	local bossKills = WorldBossStatus:GetWorldBossKills()
	local characters = WorldBossStatus.db.realm.characters
	local class, className = UnitClass("player")
	local includeCharacters = WorldBossStatus.db.global.characterOptions.include or 3
	local showHint = WorldBossStatus.db.global.displayOptions.showHintLine

	if LibQTip:IsAcquired("WorldBossStatusTooltip") and tooltip then
		tooltip:Clear()
	else
		local columnCount = #bossData

		RequestLFDPlayerLockInfo()
		WorldBossStatus:UpdateWorldBossKills();

		columnCount = columnCount + 3
		
		for _, currency in pairs(CURRENCIES) do
			columnCount = columnCount + 1
		end
		tooltip = LibQTip:Acquire("WorldBossStatusTooltip", columnCount, "CENTER", "LEFT", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER")
		WorldBossStatus.tooltip = tooltip 
	end

	line = tooltip:AddHeader(" ")
	tooltip:SetCell(1, 1, "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:16|t "..L["World Boss Status"], nil, "LEFT", tooltip:GetColumnCount())
	tooltip:AddSeparator(6,0,0,0,0)
	ShowHeader(tooltip, nil, L["Character"])
	tooltip:AddSeparator(6,0,0,0,0)
			
	local info = WorldBossStatus:GetCharacterInfo()
	WorldBossStatus:DisplayCharacterInTooltip(characterName, info)
	tooltip:AddSeparator(6,0,0,0,0)
	tooltip:AddSeparator(1, 1, 1, 1, 1.0)

	if includeCharacters > 1 then
		WorldBossStatus:DisplayRealmInToolip(GetRealmName())
	end
			
	if includeCharacters == 3 then
		realmNames = {}
				
		for k,v in pairs(WorldBossStatus.db.global.realms) do
			if (k ~= GetRealmName()) then
				table.insert(realmNames, k);
			end
		end
				
		for k,v in pairs(realmNames) do
			WorldBossStatus:DisplayRealmInToolip(v)
		end
	end

	tooltip:AddSeparator(3,0,0,0,0)
	local reset = WorldBossStatus:GetWeeklyQuestResetTime() - time()
	line = tooltip:AddLine(" ")
	tooltip:SetCell(tooltip:GetLineCount(), 1, L["World bosses will reset in"] .. " "..SecondsToTime(reset, true, true, 2), nil, "LEFT", tooltip:GetColumnCount())
	if (frame) then
		tooltip:SetAutoHideDelay(0.01, frame)
		tooltip:SmartAnchorTo(frame)
	end 

	tooltip:UpdateScrolling()
	tooltip:Show()
end

function WorldBossStatus:GetRealmInfo(realmName)
	if not self.db.global.realms then
		self.db.global.realms = {}
	end

	local realmInfo = self.db.global.realms[realmName]
	
	if not realmInfo then
		realmInfo = {}
		realmInfo.characters = {}
	end

	return realmInfo
end

function WorldBossStatus:SaveCharacterInfo(info)
	local characterName = UnitName("player")
	local realmName = GetRealmName()	
	local realmInfo = WorldBossStatus:GetRealmInfo(realmName)
	local characterInfo = info or WorldBossStatus:GetCharacterInfo()

	realmInfo.characters[characterName]  = characterInfo

	self.db.global.realms[realmName] = realmInfo
end

function WorldBossStatus:GetCharacterInfo()
	local characterName = UnitName("player")
	local realmName = GetRealmName()
	local realmInfo = WorldBossStatus:GetRealmInfo(realmName)

	local characterInfo = realmInfo.characters[characterName] or {}
	local class, className = UnitClass("player")
	local level = UnitLevel("player")
	local englishFaction, localizedFaction = UnitFactionGroup("player")

	characterInfo.bossKills = WorldBossStatus:GetWorldBossKills()
	characterInfo.lastUpdate = time()
	characterInfo.class = className
	characterInfo.level = level
	characterInfo.faction = englishFaction
	characterInfo.currencies = WorldBossStatus:GetBonusRollsStatus()
	characterInfo.worldBossKills = characterInfo.worldBossKills or {}

	return characterInfo
end

function WorldBossStatus:GetBonusRollsStatus()
	currencies = {}	

	for _, currency in pairs(CURRENCIES) do
		local currencyInfo = {}		
		local _, balance, _, collectedThisWeek, weeklyMax, totalMax, _, _ = GetCurrencyInfo(currency.currencyId)
		local collectedFromQuests = 0

		if currency.quests then
			for _, quest in pairs(currency.quests) do						
				if IsQuestFlaggedCompleted(quest.questId) then
					collectedFromQuests = collectedFromQuests + 1					
				end
			end			

		end

		currencyInfo.collectedThisWeek = collectedThisWeek + collectedFromQuests
		currencyInfo.balance = balance
		currencyInfo.weeklyMax = weeklyMax
		currencyInfo.totalMax = totalMax
		currencyInfo.questReset = WorldBossStatus:GetWeeklyQuestResetTime()					
		currencies[currency.currencyId] = currencyInfo		
	end
	
	return currencies
end

function WorldBossStatus:GetRegion()


end

function WorldBossStatus:GetWeeklyQuestResetTime()
   local now = time()
   local region = GetCurrentRegion()
   local dayOffset = { 2, 1, 0, 6, 5, 4, 3 }
   local regionDayOffset = {{ 2, 1, 0, 6, 5, 4, 3 }, { 4, 3, 2, 1, 0, 6, 5 }, { 3, 2, 1, 0, 6, 5, 4 }, { 4, 3, 2, 1, 0, 6, 5 }, { 4, 3, 2, 1, 0, 6, 5 } }
   local nextDailyReset = GetQuestResetTime()
   local utc = date("!*t", now + nextDailyReset)      
   local reset = regionDayOffset[region][utc.wday] * 86400 + nextDailyReset
   
   return time() + reset  
end
 
function WorldBossStatus:GetWorldBossKills()
	local bossData = WorldBossStatus.bossData
	local bossKills = {}
	local expires = WorldBossStatus:GetWeeklyQuestResetTime()

	for i = 1, GetNumSavedWorldBosses() do
		local name, worldBossID, reset = GetSavedWorldBossInfo(i)
		local expires = time() + reset

		bossKills[name] = expires		
	end

	for _, category in pairs(bossData) do
		category.kills = 0
		for _, boss in pairs(category.bosses) do
			if boss.questId and boss.name and IsQuestFlaggedCompleted(boss.questId) then
				bossKills[boss.name] =  expires
			elseif boss.dungeonID and GetLFGDungeonRewards(boss.dungeonID) then
				bossKills[boss.name] =  time() + GetQuestResetTime()
			end
		end
	end

	return bossKills
end

function WorldBossStatus:ChatCommand(input)
	if not input or input:trim() == "" then 
		return
	end

	local command = input:lower() or nil

	if command == "debug on" then
		WorldBossStatus.debug = true
		WorldBossStatus:Print("Debug turned on")
	elseif command == "debug off" then
		WorldBossStatus.debug = false
		WorldBossStatus:Print("Debug turned off")
	else
		WorldBossStatus:Print("Unknown command: " .. command)
	end
end

function WorldBossStatus:UPDATE_INSTANCE_INFO()
	WorldBossStatus:SaveCharacterInfo()
	if LibQTip:IsAcquired("WorldBossStatusTooltip") and WorldBossStatus.tooltip then
		WorldBossStatus:ShowToolTip()
	end
end

function WorldBossStatus:LFG_UPDATE_RANDOM_INFO()
	WorldBossStatus:SaveCharacterInfo()
	if LibQTip:IsAcquired("WorldBossStatusTooltip") and WorldBossStatus.tooltip then
		WorldBossStatus:ShowToolTip()
	end
end

function WorldBossStatus:GetBossInfo(instance, name, questID)
	local bossData = WorldBossStatus.bossData
	local bossInfo = nil
	
	for _, category in pairs(bossData) do
		if category.name == instance or instance == nil then
			for _, boss in pairs(category.bosses) do
				if (name and boss.name == name) or (questID and questID == boss.questId) then
					bossInfo = boss	
					break		
				end
			end
		end
	end
	
	return bossInfo
end

function WorldBossStatus:BossKilled(boss)
	if not boss then 
		return
	end

	local now = time()
	local characterInfo = WorldBossStatus:GetCharacterInfo()
	local bossKill = characterInfo.worldBossKills[boss.name] or {}
	local bonusRollStatus = {lastBossKilled = boss.name, lastBossKilledAt = now}

	if WorldBossStatus.debug then
		WorldBossStatus:Print(" World boss killed: "..boss.name)	
	end
	
	bossKill.KillTime = now		
	characterInfo.worldBossKills[boss.name] = bossKill
	WorldBossStatus:SaveCharacterInfo(characterInfo)
	WorldBossStatus.BonusRollStatus = bonusRollStatus
end

function WorldBossStatus:BonusRollUsed()
	local now = time()
	local bonusRollStatus = WorldBossStatus.BonusRollStatus

	if bonusRollStatus then
		if WorldBossStatus.debug then
			WorldBossStatus:Print("Bonus roll for " ..bonusRollStatus.lastBossKilled .. " used!")
		end
		local characterInfo = WorldBossStatus:GetCharacterInfo()
		local bossKill = characterInfo.worldBossKills[bonusRollStatus.lastBossKilled] or {}

		bossKill.bonusRollUsed = bonusRollStatus.currencyID
		bossKill.bonusRollTime = now
		
		characterInfo.worldBossKills[bonusRollStatus.lastBossKilled] = bossKill
		WorldBossStatus:SaveCharacterInfo(characterInfo)	
	end
end

function WorldBossStatus:BOSS_KILL(event, id, name)
	local boss = WorldBossStatus:GetBossInfo(nil, name, nil)

	if WorldBossStatus.debug then
		WorldBossStatus:Print("BOSS_KILL event received for ID: " .. id or "" .. " and Name: " .. name or "")
	end

	if boss then
		WorldBossStatus:BossKilled(boss)
	end
end

function WorldBossStatus:BONUS_ROLL_ACTIVATE(event, ...)
	if WorldBossStatus.debug then
		WorldBossStatus:Print("BONUS_ROLL_ACTIVATE event received!")
	end

	if WorldBossStatus.BonusRollStatus then
		WorldBossStatus.BonusRollStatus.currencyID = BonusRollFrame.currencyID
	end
end

function WorldBossStatus:BONUS_ROLL_RESULT(event, rewardType, rewardLink, rewardQuantity, rewardSpecID)
	if WorldBossStatus.debug then
		WorldBossStatus:Print("BONUS_ROLL_RESULT event received!")	
	end

	WorldBossStatus:BonusRollUsed()
end

function WorldBossStatus:LFG_COMPLETION_REWARD()
	RequestLFDPlayerLockInfo()
end

function WorldBossStatus:QUEST_TURNED_IN(event, questID)
	if WorldBossStatus.debug then
		WorldBossStatus:Print("QUEST_TURNED_IN event received for quest ID: " ..  questID or "")
	end

	local boss = WorldBossStatus:GetBossInfo(nil, nil, questID)
	
	if boss then
		WorldBossStatus:BossKilled(boss)
	end
end


function WorldBossStatus:UpdateWorldBossKills()	
	RequestRaidInfo();		
end

function WorldBossStatus:PLAYER_LOGOUT()
	WorldBossStatus:UpdateWorldBossKills()
end

function WorldBossStatus:OnEnable()		
	WorldBossStatus:DoEnable()	
end

--local function CheckWorldBosses()
	

--	local bossData = WorldBossStatus.bossData
--	local activeBosses = WorldBossStatus:GetActiveWorldBosses()

--	WorldBossStatus:Print("Checking for World Bosses...")

--	for _, category in pairs(bossData) do
--		for _, boss in pairs(category.bosses) do
--			if boss.questId and activeBosses[boss.name] and not IsQuestFlaggedCompleted(boss.questId) then 
--				local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(boss.questId)
--				local bossname = colorise(boss.name, epic)
--				local text = ""
--				if boss.location then
--					text = format("A quest is available in %s for world boss %s! Go defeat it!", boss.location, bossname)
--				else
--					text = format("A quest is available for world boss %s! Go defeat it!", bossname)
--				end
--				WorldBossStatus:Print(text, 1, 1, 1)
--			end
--			WorldBossStatus:Print(boss.name)
--		end
--	end	

--end


function WorldBossStatus:DoEnable()
	self:RegisterEvent("UPDATE_INSTANCE_INFO")
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	self:RegisterEvent("LFG_COMPLETION_REWARD")	
	self:RegisterEvent("BONUS_ROLL_RESULT")
	self:RegisterEvent("BONUS_ROLL_ACTIVATE")	
	self:RegisterEvent("BOSS_KILL")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("PLAYER_LOGOUT")

	WorldBossStatus:GetSinkAce3OptionsDataTable()
	--WorldBossStatus:ScheduleTimer(CheckWorldBosses, 7)
end

function WorldBossStatus:OnDisable()
	Self:UnregisterEvent("UPDATE_INSTANCE_INFO")
	Self:UnregisterEvent("LFG_UPDATE_RANDOM_INFO")
	Self:UnregisterEvent("LFG_COMPLETION_REWARD")
	self:UnregisterEvent("BONUS_ROLL_RESULT")
	self:UnregisterEvent("BONUS_ROLL_ACTIVATE")
	self:UnregisterEvent("BOSS_KILL")
	self:UnregisterEvent("QUEST_TURNED_IN")
	self:UnregisterEvent("PLAYER_LOGOUT")
end
