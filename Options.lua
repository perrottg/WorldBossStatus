local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")

local selectedRealm = nil
local selectedCharacter = nil

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
}

local optionsTable = {
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
							step = 1, min = 1, max = 60,
							order = 2,
							get = function(info)
								if WorldBossStatus.db.global.characterOptions.minimumLevel > 60 then
									WorldBossStatus.db.global.characterOptions.minimumLevel = 60
								end
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
                holidyBossesOptions = {
					type = 'group',
					inline = true,
					name = "Holiday Bosses",
					desc = "",
					order = 1,
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
                        }	
                    }
                },
                trackedBossesOptions = {
                    type = "multiselect",                
                    name = L["Tracked Bosses"],
                    desc = L["Select the world bosses you would like to track."],
                    width = "full",
                    values = function()
                        local list = {}
                        
                        for i = GetAccountExpansionLevel(), 4, -1 do
                            list[100-i] = _G["EXPANSION_NAME"..i]
                        end

                        return list
                    end,
                    get = function(info, key)  
                        local  ignoredExpansions = WorldBossStatus.db.global.bossOptions.ignoredExpansions or {}                                             
                        return not ignoredExpansions[100-key]
                    end,
                    set = function(info, key, value)         
                        WorldBossStatus.db.global.bossOptions.ignoredExpansions = WorldBossStatus.db.global.bossOptions.ignoredExpansions or {}             
						WorldBossStatus.db.global.bossOptions.ignoredExpansions[100-key] = not value
						--WorldBossStatus:GetBossData(true)

                        --if value and value < GetAccountExpansionLevel() then
                        --    WorldBossStatus.db.global.bossOptions.trackLegacyBosses = true
                        --end
                    end,
                    order=2
                }
			}
        },
	}
}

function WorldBossStatus:InitializeOptions()
    local wbscfg = LibStub("AceConfig-3.0") 
	wbscfg:RegisterOptionsTable("World Boss Status", optionsTable)
	wbscfg:RegisterOptionsTable("World Boss Status Features", optionsTable.args.features)
	wbscfg:RegisterOptionsTable("World Boss Status Characters", optionsTable.args.characterOptions)
    wbscfg:RegisterOptionsTable("World Boss Status Bosses", optionsTable.args.bossTracking)
    --wbscfg:RegisterOptionsTable("World Boss Status Rares", optionsTable.args.rareOptions)
    
    local wbsdia = LibStub("AceConfigDialog-3.0")
    WorldBossStatus.optionsFrame =  wbsdia:AddToBlizOptions("World Boss Status Features", L["World Boss Status"])
	wbsdia:AddToBlizOptions("World Boss Status Characters", L["Characters"], L["World Boss Status"])
    wbsdia:AddToBlizOptions("World Boss Status Bosses", L["Bosses"], L["World Boss Status"])
    --wbsdia:AddToBlizOptions("World Boss Status Rares", L["Rares"], L["World Boss Status"])


    --WorldBossStatus.optionsFrame.general.default = 
      --function() WorldBossStatus:SetDefaultOptions() end;
end

function WorldBossStatus:ShowOptions()
	InterfaceOptionsFrame_OpenToCategory(L["World Boss Status"])
	InterfaceOptionsFrame_OpenToCategory(L["World Boss Status"])
    WorldBossStatus:GetBossData(true)
end

function WorldBossStatus:GetDefaults()
    return defaults
end

function WorldBossStatus:GetOptions()
    local options = WorldBossStatus.db.global.options

    if not options then
        options = WorldBossStatus:GetDefaults()
    end

    return options
end

function WorldBossStatus:SetOptions(options)
    WorldBossStatus.db.global.options = options
end

function WorldBossStatus:SetDefaultOptions()
    WorldBossStatus.db.global.options = defaults

    LibStub("AceConfigRegistry-3.0"):NotifyChange(L["World Boss Status"]);
end
