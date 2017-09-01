local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")
WorldBossStatus = LibStub("AceAddon-3.0"):NewAddon("WorldBossStatus", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "LibSink-2.0");

local textures = {}
--local subTooltip = nil


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

local WORLD_BOSSES = { {instanceId = 822,                                  -- Broken Isles
						bonusRollCurrencies = {1273},
					    maxKills = 1,
						bosses = { {encounterId = 1790, questId = 43512},  -- Ana-Mouz
								   {encounterId = 1774, questId = 43193},  -- Calamir
								   {encounterId = 1789, questId = 43448},  -- Drugon the Frostblood
								   {encounterId = 1795, questId = 43985},  -- Flotsam
							       {encounterId = 1770, questId = 42819},  -- Humongris 
								   {encounterId = 1769, questId = 43192},  -- Levantus
        						   {encounterId = 1783, questId = 43513},  -- Na'zak the Fiend
						     	   {encounterId = 1749, questId = 42270},  -- Nithogg
    							   {encounterId = 1763, questId = 42779},  -- Shar'thos
           						   {encounterId = 1756, questId = 42269},  -- The Soultakers
						 		   {encounterId = 1796, questId = 44287},  -- Withered'Jim
								   {encounterId = 1956, questId = 47061},  -- Apocron
								   {encounterId = 1883, questId = 46947},  -- Brutallus
								   {encounterId = 1884, questId = 46948},  -- Malificus
								   {encounterId = 1885, questId = 46945},  -- Si'vash
								   {name = "Kosumoth", questId = 43798}	 -- Kosumoth
	 				             }
					   },
					   {instanceId = 557,                                  -- Draenor 
						bonusRollCurrencies = {1129, 994},
					    maxKills = 4,                               
					    bosses = { {encounterId = 1452, questId = 94015 }, -- Supreme Lord Kazzak
						     	   {encounterId = 1262, questId = 37464 }, -- Rukhmar
						 		   {encounterId = 1211, questId = 37462 }, -- Tarlna the Ageless
								   {encounterId = 1291, questId = 37462 }  -- Drov the Ruiner
	 				             }
					   },
					   {instanceId = 322,                                  -- Panderia
						bonusRollCurrencies = {776, 752, 697},
					    maxKills = 6,                              
					    bosses = { {encounterId = 861},                    -- Ordos
								   {name = L["The Celestials"]},           -- The Celestials 
						     	   {encounterId = 826},                    -- Oondasta
						 		   {encounterId = 814},                    -- Nalak
								   {encounterId = 725},                    -- Salyisis's Warband
								   {encounterId = 691}                     -- Sha of Anger
	 				             }
					   }
}

local HOLIDAY_BOSS = {}

local CURRENCIES = {	{currencyId = 1273,														  -- Seal of Broken Fate
						 weeklyMax = 3,
						 quests = {	{questId = 43895, level = 1, cost = 1000},					  -- Sealing Fate: Gold
							 		{questId = 43896, level = 2, cost = 2000},					  -- Sealing Fate: Piles of Gold
									{questId = 43897, level = 3, cost = 4000},					  -- Sealing Fate: Immense Fortune of Gold
									{questId = 43892, level = 1, cost = 1000, currencyId = 1220}, -- Sealing Fate: Order Resources
									{questId = 43893, level = 2, cost = 2000, currencyId = 1220}, -- Sealing Fate: Stashed Order Resources
									{questId = 43894, level = 3, cost = 4000, currencyId = 1220}, -- Sealing Fate: Extraneous Order Resources
									{questId = 43510}											  -- Class Hall
								  }
						},
						{currencyId = 1220},													  -- Order Resources						 						
						{currencyId = 1155}														  -- Ancient Mana
}


local MAPID_BROKENISLES = 1007
local isInitialized = false
	 
						   
for key, currency in pairs(CURRENCIES) do
	if not currency.name and currency.currencyId then
		currency.name, _, currency.texture = GetCurrencyInfo(currency.currencyId)	
	end
end

for _, region in pairs(WORLD_BOSSES) do
	region.name = EJ_GetInstanceInfo(region.instanceId)
	for _, boss in pairs(region.bosses) do
		if region.instanceId == 322 then
			if not boss.name and boss.encounterId then
				_, boss.name = EJ_GetCreatureInfo(1, boss.encounterId)    
			end
		else
			if not boss.name and boss.encounterId then 
				boss.name = EJ_GetEncounterInfo(boss.encounterId)
			end			
		end
		if not boss.displayName and boss.encounterId then
			boss.displayName = EJ_GetEncounterInfo(boss.encounterId)
		elseif not boss.displayName and boss.name then
			boss.displayName = boss.name
		end
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
			minimumLevel = 100,
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
							step = 1, min = 1, max = 110,
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

function WorldBossStatus.UpdateActiveWorldQuests()
	local worldQuests = {}

	for zoneIndex = 1, C_MapCanvas.GetNumZones(MAPID_BROKENISLES) do   
		local zoneMapID, zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfo(MAPID_BROKENISLES, zoneIndex);

		if zoneDepth <= 1 then
			local questList = C_TaskQuest.GetQuestsForPlayerByMapID(zoneMapID, MAPID_BROKENISLES)
   
			if questList then
				for i = 1, #questList do  
					local questId = questList[i].questId
					local quest = {}

					quest.questId = questId
					quest.timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questId)
					quest.zone = zoneName
					quest.timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questId)

					worldQuests[quest.questId] = quest
				end
			end
		end
	end

end

function WorldBossStatus:GetActiveWorldBosses()

	local questsFound = {}
	local questsLocation = {}
	local activeWorldBosses = {}
	



	for zoneIndex = 1, C_MapCanvas.GetNumZones(MAPID_BROKENISLES) do   
		local zoneMapID, zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfo(MAPID_BROKENISLES, zoneIndex);

		if zoneDepth <= 1 then
			local questList = C_TaskQuest.GetQuestsForPlayerByMapID(zoneMapID, MAPID_BROKENISLES)
   
			if questList then
				for i = 1, #questList do      
					timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questList[i].questId)               
					tagId, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questList[i].questId);
					questsFound[questList[i].questId] = time()
					questsLocation[questList[i].questId] = zoneName
				end
			end
		end
	end

	for _, region in pairs(WORLD_BOSSES) do
		for _, boss in pairs(region.bosses) do
			if not boss.name and boss.encounterId then 
				boss.name = EJ_GetEncounterInfo(boss.encounterId)
			end
			if questsFound[boss.questId] or (boss.questId and IsQuestFlaggedCompleted(boss.questId)) then
				activeWorldBosses[boss.name] = time()
			end
			if questsLocation[boss.questId] then
				boss.location = questsLocation[boss.questId]
			end
		end
	end

	return activeWorldBosses
end

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
	
	subTooltip:SetCell(line, 1, boss.displayName, nil, "LEFT")
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



	--line = subTooltip:AddHeader("Boss", "Last Defeated")
	--subTooltip:SetLineTextColor(line, yellow.r, yellow.g, yellow.b)

	--subTooltip:SetCell(line, 1, "Boss") --  , nil, nil, nil, nil, nil, 50)
	--subTooltip:SetCellTextColor(line, 1, yellow.r, yellow.g, yellow.b)
	--subTooltip:SetCell(line, 2, "Last Defeated") --  , nil, nil, nil, nil, nil, 50)
	--subTooltip:SetCellTextColor(line, 2, yellow.r, yellow.g, yellow.b)
	--subTooltip:SetCell(line, 1, "World Boss") --  , nil, nil, nil, nil, nil, 50)
	--tooltip:SetCellTextColor(line, 1, yellow.r, yellow.g, yellow.b)
	--subTooltip:AddSeparator(6,0,0,0,0)


	for _, boss in pairs(region.bosses) do
		local kill = nil

		if character.worldBossKills then
			kill = character.worldBossKills[boss.name]
		end
		if not kill and character.bossKills[boss.name] and character.bossKills[boss.name] > time() then
			kill = {}
		end
		
		ShowKill(boss, kill, lastReset)
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





--	subTooltip:SetCell(line, 1, "Bonus Roll Weekly Quests")
--	subTooltip:SetLineTextColor(line, yellow.r, yellow.g, yellow.b)


--	line = subTooltip:AddLine(" |T"..currency.texture..":0|t "..currency.name, currencyInfo.balance)
--	subTooltip:AddSeparator(6,0,0,0,0)

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

--			tooltip:SetCellScript(line, column, "OnEnter", ShowSubTooltip, { type="BONUSROLLS", character=characterInfo, currency=currency})
--			tooltip:SetCellScript(line, column, "OnLeave", HideSubTooltip)
		else
			tooltip:SetCell(line, column, "?", nil, "RIGHT")
		end

	end

	column = column + 1

	if HOLIDAY_BOSS and not WorldBossStatus.db.global.bossOptions.disableHoldidayBossTracking then
		local boss = HOLIDAY_BOSS
		local defeated = (characterInfo.holidayBossKills and characterInfo.holidayBossKills[boss] and characterInfo.holidayBossKills[boss] > time())

			if defeated then 
				tooltip:SetCell(line, column, textures.bossDefeated)
			else
				tooltip:SetCell(line, column, textures.bossAvailable )
			end

			if characterInfo.class then
				local color = RAID_CLASS_COLORS[characterInfo.class]
				tooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
			end

			column = column+1
	end

	for _, region in pairs(WORLD_BOSSES) do
		kills = 0

		--for _, boss in pairs (region.bosses) do
		--	if characterInfo.bossKills[boss.name] and characterInfo.bossKills[boss.name] > time() then
		--		kills = kills + 1
		--	end
		--end


		for _, boss in pairs(region.bosses) do
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
		

		if kills >= region.maxKills then
			tooltip:SetCell(line, column, textures.bossDefeated)
		else  
			--tooltip:SetCell(line, column, textures.bossAvailable)
			tooltip:SetCell(line, column, kills.."/"..region.maxKills)
		end

		--tooltip:SetCellScript(line, column, "OnEnter", WorldBossStatus:ShowSubTooltip, { type="BOSSES", character=characterInfo, region=region})

		tooltip:SetCellScript(line, column, "OnEnter", function(self)
			local info = { type="BOSSES", character=characterInfo, region=region}
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
		--tooltip:SetCell(line, column, GetCurrencyLink(currency.currencyId), nil, "RIGHT")
	end

	column = column + 1

	if HOLIDAY_BOSS and not WorldBossStatus.db.global.bossOptions.disableHoldidayBossTracking then
		tooltip:SetCell(line, column, HOLIDAY_BOSS, "CENTER")
		tooltip:SetCellTextColor(line, column, yellow.r, yellow.g, yellow.b)
		column = column+1
	end

	for _, region in pairs(WORLD_BOSSES) do
		tooltip:SetCell(line, column, region.name, "CENTER")
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
	local tooltip = WorldBossStatus.tooltip
	local characterName = UnitName("player")
	local bossKills = WorldBossStatus:GetWorldBossKills()
	local holidayBossKills = WorldBossStatus:GetHolidayBossKills()
	local characters = WorldBossStatus.db.realm.characters
	local class, className = UnitClass("player")
	local includeCharacters = WorldBossStatus.db.global.characterOptions.include or 3
	local showHint = WorldBossStatus.db.global.displayOptions.showHintLine

	if LibQTip:IsAcquired("WorldBossStatusTooltip") and tooltip then
		tooltip:Clear()
	else
		local columnCount = 3

		RequestLFDPlayerLockInfo()
		WorldBossStatus:UpdateWorldBossKills();

		if HOLIDAY_BOSS and not WorldBossStatus.db.global.bossOptions.disableHoldidayBossTracking then
			columnCount = columnCount + 1
		end
		
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
	characterInfo.holidayBossKills = WorldBossStatus:GetHolidayBossKills()
	characterInfo.lastUpdate = time()
	characterInfo.class = className
	characterInfo.level = level
	characterInfo.faction = englishFaction
	characterInfo.currencies = WorldBossStatus:GetBonusRollsStatus()
	characterInfo.worldBossKills = characterInfo.worldBossKills or {}

	return characterInfo
end

function WorldBossStatus:GetHolidayBossKills()
	local holidayBossStatus = {}
	local num = GetNumRandomDungeons()
	HOLIDAY_BOSS = nil

	--RequestLFDPlayerLockInfo()

	for i=1, num do 
		local dungeonID, name = GetLFGRandomDungeonInfo(i);
		local _, _, _, _, _, _, _, _, _, _, _, _, _,desc, isHoliday = GetLFGDungeonInfo(dungeonID)

		if isHoliday and dungeonID ~= 828  and desc ~= "" then		
			local doneToday = GetLFGDungeonRewards(dungeonID)
			HOLIDAY_BOSS = name
			if doneToday then			
				local expires = time() + GetQuestResetTime()
				holidayBossStatus[name] = expires	
			end
		end 
	end

	return holidayBossStatus
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
	local bossKills = {}
	local expires = WorldBossStatus:GetWeeklyQuestResetTime()

	for i = 1, GetNumSavedWorldBosses() do
		local name, worldBossID, reset = GetSavedWorldBossInfo(i)
		local expires = time() + reset

		bossKills[name] = expires		
	end

	for _, region in pairs(WORLD_BOSSES) do
		region.kills = 0
		for _, boss in pairs(region.bosses) do
			if boss.questId and boss.name and IsQuestFlaggedCompleted(boss.questId) then
				bossKills[boss.name] =  expires
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
	local bossInfo = nil
	
	for _, region in pairs(WORLD_BOSSES) do
		if region.name == instance or instance == nil then
			for _, boss in pairs(region.bosses) do
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


oldLogout = Logout;
oldQuit = Quit;

function WorldBossStatus:UpdateWorldBossKills()	
	RequestRaidInfo();		
end


function Quit()
	WorldBossStatus:UpdateWorldBossKills()
	oldQuit();
end

function Logout()
	WorldBossStatus:UpdateWorldBossKills()
	oldLogout();
end

function WorldBossStatus:OnEnable()		
	WorldBossStatus:DoEnable()	
end

local function CheckWorldBosses()
	local activeBosses = WorldBossStatus:GetActiveWorldBosses()

	for _, region in pairs(WORLD_BOSSES) do
		region.name = EJ_GetInstanceInfo(region.instanceId)
		for _, boss in pairs(region.bosses) do
			if activeBosses[boss.name] and not IsQuestFlaggedCompleted(boss.questId) then 
				local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(boss.questId)
				--local dd = SecondsToTime(timeLeft * 60, true, true, 2)
				local bossname = colorise(boss.name, epic)
				local text = ""
				if boss.location then
					text = format("A quest is available in %s for world boss %s! Go defeat it!", boss.location, bossname)
					--text = format("A quest is available in %s for world boss %s! You have %s to complete it.", boss.location, bossname, dd)
				else
					text = format("A quest is available for world boss %s! Go defeat it!", bossname)
				end
				WorldBossStatus:Pour(text, 1, 1, 1)
			end
		end
	end	
end


function WorldBossStatus:DoEnable()
	self:RegisterEvent("UPDATE_INSTANCE_INFO")
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	self:RegisterEvent("LFG_COMPLETION_REWARD")	
	self:RegisterEvent("BONUS_ROLL_RESULT")
	self:RegisterEvent("BONUS_ROLL_ACTIVATE")	
	self:RegisterEvent("BOSS_KILL")
	self:RegisterEvent("QUEST_TURNED_IN")

	WorldBossStatus:GetSinkAce3OptionsDataTable()
	WorldBossStatus:ScheduleTimer(CheckWorldBosses, 7)
end

function WorldBossStatus:OnDisable()
	Self:UnregisterEvent("UPDATE_INSTANCE_INFO")
	Self:UnregisterEvent("LFG_UPDATE_RANDOM_INFO")
	Self:UnregisterEvent("LFG_COMPLETION_REWARD")
	self:UnregisterEvent("BONUS_ROLL_RESULT")
	self:UnregisterEvent("BONUS_ROLL_ACTIVATE")
	self:UnregisterEvent("BOSS_KILL")
	self:UnregisterEvent("QUEST_TURNED_IN")
end
