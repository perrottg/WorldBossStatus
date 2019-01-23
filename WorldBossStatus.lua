local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")
WorldBossStatus = LibStub("AceAddon-3.0"):NewAddon("WorldBossStatus", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "LibSink-2.0", 
	"AceComm-3.0", "AceSerializer-3.0");

local textures = {}

textures.worldBossStatus = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8.png"
textures.alliance = "|TInterface\\FriendsFrame\\PlusManz-Alliance:18|t"
textures.horde = "|TInterface\\FriendsFrame\\PlusManz-Horde:18|t"
textures.bossDefeated = "|TInterface\\WorldMap\\Skull_64Red:18|t"
textures.bossStatus = "|TInterface\\WorldMap\\Skull_64Red:18|t"
textures.bossAvailable = "|TInterface\\WorldMap\\Skull_64Grey:18|t"
textures.bossInactive = "|TInterface\\WorldMap\\Skull_64Grey:18|t"
textures.quest = "|TInterface\\Minimap\\OBJECTICONS:20:20:0:0:256:192:32:64:20:48|t"
textures.toy = "|TInterface\\Icons\\INV_Misc_Toy_03:18|t"
textures.mount = "|TInterface\\Icons\\Ability_mount_ridinghorse:18|t"
textures.pet = "|TInterface\\Icons\\INV_Box_PetCarrier_01:18|t"
textures.gear = "|TInterface\\WorldMap\\Gear_64Grey:18|t"
textures.tick = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:16|t"
--textures.bonusRoll = "|TInterface\\Icons\\INV_Misc_CuriousCoin:18|t"
--textures.bonusRoll = "|TInterface\\Icons\\Ability_TitanKeeper_CleansingOrb:16:16|t"
textures.bonusRoll = "|TInterface\\BUTTONS\\UI-GroupLoot-Dice-Up:16:16|t"

local addonName = "WorldBossStatus"
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local LibQTip = LibStub('LibQTip-1.0')

local colors = {
	rare = { r = 0, g = 0.44, b = 0.87},
	epic = { r = 0.63921568627451, g = 0.2078431372549, b = 0.93333333333333 },
	white = { r = 1.0, g = 1.0, b = 1.0 },
	yellow = { r = 1.0, g = 1.0, b = 0.2 }
}

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

local function CleanupCharacters()
	local options = WorldBossStatus:GetGlobalOptions()
	local threshold = options.characterOptions.inactivityThreshold * (24 * 60 * 60)	
	
	if options.characterOptions.removeInactive or threshold == 0 then
		return
	 end
	

	for realm in pairs(options.realms) do
		local realmInfo = options.realms[realm]
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

local function GetCurrentKillStatus(boss, bossStatus)
	local nextReset, interval = WorldBossStatus:GetBossResetInfo(boss)
	local killed, bonusRollUsed, eligible

	if bossStatus then
		eligible = bossStatus.eligible
		if bossStatus.lastUpdated and nextReset then 
			killed = bossStatus.killed and bossStatus.lastUpdated > nextReset - interval
			bonusRollUsed = bossStatus.BonusRollUsed and bossStatus.lastUpdated > nextReset - interval
		else
			killed = bossStatus.killed
			bonusRollUsed = bossStatus.bonusRollUsed
		end
	else
		killed = false
		bonusRollUsed = false
		eligible = true
	end

	return killed, bonusRollUsed, eligible
end

local function ShowKill(boss, bossStatus)
	local subTooltip = WorldBossStatus.subTooltip
	local line = subTooltip:AddLine()
	local color = gray
	local bossTexture = textures.bossInactive
	local rollTexture = ""
	local killed, bonusRollUsed, eligible = GetCurrentKillStatus(boss, bossStatus)

	if killed then 
		bossTexture = textures.bossDefeated
		color = red

		if bonusRollUsed then			
			rollTexture = textures.bonusRoll			
		end
	elseif boss.active and eligible then
		color = white
		bossTexture = textures.bossAvailable
	end
	
	subTooltip:SetCell(line, 1, boss.displayName or boss.name, nil, "LEFT")
	subTooltip:SetCell(line, 2, boss.location or '', nil, "LEFT")
	subTooltip:SetCell(line, 4, bossTexture, nil, "CENTER", nil, nil, nil, nil, 20, 0)
	subTooltip:SetCell(line, 5, rollTexture, nil, "CENTER", nil, nil, nil, nil, 20, 0)
	subTooltip:SetCellTextColor(line, 1, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 3, color.r, color.g, color.b)
end

local function ShowBossKills(character, region)	
	local subTooltip = WorldBossStatus.subTooltip
	local nextReset = WorldBossStatus:GetNextReset()
	local status = character.status or {}
	local texture = ""
	local footer = ""

	if LibQTip:IsAcquired("WBSsubTooltip") and subTooltip then
		subTooltip:Clear()
	else 
		subTooltip = LibQTip:Acquire("WBSsubTooltip", 5, "LEFT", "LEFT", "LEFT", "RIGHT", "CENTER", "CENTER")
		WorldBossStatus.subTooltip = subTooltip	
	end	

	subTooltip:ClearAllPoints()
	subTooltip:SetClampedToScreen(true)
	subTooltip:SetPoint("TOP", WorldBossStatus.tooltip, "TOP", 30, 0)
	subTooltip:SetPoint("RIGHT", WorldBossStatus.tooltip, "LEFT", -20, 0)

	line = subTooltip:AddHeader(colorise(region.title, colors.yellow))	
	subTooltip:AddSeparator(6,0,0,0,0)

	line = subTooltip:AddLine(colorise('NPC', colors.yellow), colorise('Location', colors.yellow), nil, colorise('Status',colors.yellow))
	subTooltip:AddSeparator(1, 1, 1, 1, 1.0)
	subTooltip:AddSeparator(3,0,0,0,0)

	for _, boss in pairs(region.bosses) do
		local bossStatus = status[boss.index]

		--local killed, killTime, bonusRollUsed = GetCurrentKillStatus(boss, character.worldBossKills[boss.name], character.bossKills[boss.name])
				
		if not boss.faction or character.faction == boss.faction then
			--ShowKill(boss, killed, killInfo, region.showLocations, region.showDrops)

			--ShowKill(boss, killed, killTime, bonusRollUsed, region.showLocations, region.showDrops)
			ShowKill(boss, bossStatus)
		end
	end	

	subTooltip:AddSeparator(6,0,0,0,0)
	line = subTooltip:AddLine()

	footer = format("Legend: %sDefeated  %sBonus roll used", textures.bossDefeated, textures.bonusRoll)

	subTooltip:SetCell(line, 1, footer , nil, LEFT, 3)

	subTooltip:Show()
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

function WorldBossStatus:ShowSubTooltip(cell, info)
	local character = info.character
	local category = info.region

	ShowBossKills(character, category)
end

function WorldBossStatus:DisplayCharacterInTooltip(characterName, characterInfo)
	local bossData = WorldBossStatus:GetBossData()
	local nextReset = WorldBossStatus:GetNextReset()
	local tooltip = WorldBossStatus.tooltip
	local line = tooltip:AddLine()
	local factionIcon = ""
	local coins = 0
	local seals = 0
	local status = characterInfo.status or {}

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
				--if currencyInfo.collectedThisWeek == currency.weeklyMax then
				--	tooltip:SetCell(line, column, textures.tick, nil, "RIGHT")
				--else
					tooltip:SetCell(line, column, currencyInfo.balance .. "  " .. currencyInfo.collectedThisWeek.."/"..currency.weeklyMax, nil, "RIGHT")
				--end
			else
				tooltip:SetCell(line, column, BreakUpLargeNumbers(currencyInfo.balance), nil, "RIGHT")
			end

		else
			tooltip:SetCell(line, column, "?", nil, "RIGHT")
		end

	end

	column = column + 1

	for _, category in pairs(bossData) do
		local eligibleBosses = 0
		local kills = 0

		for _, boss in pairs(category.bosses) do
			local bossStatus = status[boss.index]
			local killed, _, eligible = GetCurrentKillStatus(boss, bossStatus)

			if boss.active and eligible then
				eligibleBosses = eligibleBosses + 1
			end

			if killed then
				kills = kills + 1
			end
		end

		if eligibleBosses == 0 then
			tooltip:SetCell(line, column, textures.bossInactive)
		elseif kills >= eligibleBosses then
			tooltip:SetCell(line, column, textures.bossDefeated)
		else  
			tooltip:SetCell(line, column, kills.."/"..eligibleBosses)
		end

		tooltip:SetCellScript(line, column, "OnEnter", function(self)
			local info = { character=characterInfo, region=category}
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

--function WorldBossStatus:ShowOptions()
--	InterfaceOptionsFrame_OpenToCategory(WorldBossStatus.optionsFrame)
--	InterfaceOptionsFrame_OpenToCategory(WorldBossStatus.OptionsFrame)
--end

local function CheckUpgradeStatus()
	local thisVersion = GetAddOnMetadata(addonName, "Version")
	local savedVersion = WorldBossStatus.db.global.version

	if thisVersion ~= savedVersion then
		local realms = WorldBossStatus.db.global.realms

		if WorldBossStatus.debug then
			WorldBossStatus:Print("Performing upgrade from pervious version!")
		end

		for _,realm in pairs(realms) do
			for _, character in pairs(realm.characters) do
				status = character.status

				if not status then
					local status = {}
					local bossData = WorldBossStatus:GetBossData()

					for key, boss in pairs(bossData) do
						bossStatus = {}

						if character.worldBossKills then
							local worldBossKills = character.worldBossKills
				
							if worldBossKills[boss.name] then								
								bossStatus.eligible = true
								bossStatus.killed = true
								bossStatus.lastUpdated = worldBossKills[boss.name].KillTime or worldBossKills[boss.name].bonusRollTime
								bossStatus.bonusRollUsed = worldBossKills[boss.name].bonusRollTime ~= nil
							end
						elseif character.bossKills then
							local bossKills = character.bossKills
				
							if  bossKills[boss.name] then
								bossStatus.eligible = true
								bossStatus.killed = bossKills[boss.name] == nextReset
								bossStatus.lastUpdated = now()
				
							end
						end

						status[boss.index] = bossStatus
					end

					character.status = status					
					character.worldBossKills = nil
					characer.bossKills = nil
					WorldBossStatus.db.global.realms[realm.name].characters[characer.name] = characer
				end
			end
		end
	end
	
	WorldBossStatus.db.global.version = thisVersion
end

function WorldBossStatus:OnInitialize()	
	self.db = LibStub("AceDB-3.0"):New("WorldBossStatusDB", defaults, true)
	self.debug = self.db.global.debug

	LDBIcon:Register(addonName, WorldBossStatusLauncher, self.db.global.MinimapButton)

	self:InitializeOptions()
    self:RegisterChatCommand("wbs", "ChatCommand")
	self:RegisterChatCommand(addonName, "ChatCommand")

	--CheckUpgradeStatus()

	RequestRaidInfo()
end

local function ShowHeader(tooltip, marker, headerName)
	local bossData = WorldBossStatus:GetBossData()

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
	local bossData = WorldBossStatus:GetBossData()
	local tooltip = WorldBossStatus.tooltip
	local characterName = UnitName("player")
	local characters = WorldBossStatus.db.realm.characters
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
	local reset = WorldBossStatus:GetNextReset()[2] - time()
	line = tooltip:AddLine(" ")
	tooltip:SetCell(tooltip:GetLineCount(), 1, L["World bosses will reset in"] .. " "..SecondsToTime(reset, true, true, 2), nil, "LEFT", tooltip:GetColumnCount()-2)
	--tooltip:SetCell(tooltip:GetLineCount(), tooltip:GetColumnCount()-1, textures.gear, nil, "RIGHT",2)
	--tooltip:SetCellScript(tooltip:GetLineCount(), tooltip:GetColumnCount()-1, "OnMouseUp", "ShowOptions")
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

local function UpdateStatusForCharacter(currentStatus)
	local status = currentStatus or {}
	local bossData = WorldBossStatus:GetBossData()	
	local now = time()

	for _, category in pairs(bossData) do
		for _, boss in pairs(category.bosses) do
			local bossStatus = status[boss.index] or {}
			local prerequisite = boss.prerequisite or {}

			bossStatus.killed = (boss.trackingID and IsQuestFlaggedCompleted(boss.trackingID)) or
				(boss.dungeonID and GetLFGDungeonRewards(boss.dungeonID))
			bossStatus.eligible = (not prerequisite[UnitFactionGroup("player")] or IsQuestFlaggedCompleted(prerequisite[UnitFactionGroup("player")])) and
				(not prerequisite.level or UnitLevel("player") >= prerequisite.level)
			bossStatus.bonusRollUsed = boss.bonusRollID and IsQuestFlaggedCompleted(boss.bonusRollID)
			bossStatus.lastUpdated = now

			status[boss.index] = bossStatus
		end
	end

	return status
end

function WorldBossStatus:SaveCharacterInfo(info)
	local characterName = UnitName("player")
	local realmName = GetRealmName()	
	local realmInfo = self:GetRealmInfo(realmName)
	local characterInfo = info or self:GetCharacterInfo()

	realmInfo.characters[characterName]  = characterInfo

	self.db.global.realms[realmName] = realmInfo
end

function WorldBossStatus:GetCharacterInfo()
	local realmInfo = WorldBossStatus:GetRealmInfo(GetRealmName())
	local characterInfo = realmInfo.characters[UnitName("player")] or {}
	local _, className = UnitClass("player")

	characterInfo.lastUpdate = time()
	characterInfo.class = className
	characterInfo.level = UnitLevel("player")
	characterInfo.faction = UnitFactionGroup("player")
	characterInfo.currencies = WorldBossStatus:GetBonusRollsStatus()
	characterInfo.status = UpdateStatusForCharacter(characterInfo.status)

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
		currencyInfo.questReset = WorldBossStatus:GetNextReset()[2]				
		currencies[currency.currencyId] = currencyInfo		
	end
	
	return currencies
end

function WorldBossStatus:GetRegion()


end

function WorldBossStatus:ChatCommand(input)
	if not input or input:trim() == "" then 
		return
	end

	local command = input:lower() or nil

	if command == "debug on" then
		self.debug = true
		self:Print("Debug turned on")
	elseif command == "debug off" then
		self.debug = false
		self:Print("Debug turned off")
	else
		self:Print("Unknown command: " .. command)
	end
	
	self.db.global.debug = self.debug
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
	local bossData = WorldBossStatus:GetBossData()
	local bossInfo = nil
	
	for _, category in pairs(bossData) do
		if category.name == instance or instance == nil then
			for _, boss in pairs(category.bosses) do
				if (name and boss.name == name) or (questID and questID == boss.trackingID) then
					bossInfo = boss	
					break		
				end
			end
		end
	end
	
	return bossInfo
end

function WorldBossStatus:BOSS_KILL(event, id, name)
	if WorldBossStatus.debug then
		WorldBossStatus:Print("BOSS_KILL event received for ID: " .. id or "" .. " and Name: " .. name or "")
	end

	local boss = WorldBossStatus:GetBossInfo(nil, name, nil)

	if boss then
		WorldBossStatus:SaveCharacterInfo()
		if WorldBossStatus.debug then
			WorldBossStatus:Print(" World boss killed: "..boss.name)	
		end
	end
end

function WorldBossStatus:BONUS_ROLL_RESULT(event, rewardType, rewardLink, rewardQuantity, rewardSpecID)
	if WorldBossStatus.debug then
		WorldBossStatus:Print("BONUS_ROLL_RESULT event received!")	
	end

	
end

function WorldBossStatus:LFG_COMPLETION_REWARD()
	RequestLFDPlayerLockInfo()
end

function WorldBossStatus:QUEST_TURNED_IN(event, questID)
	if WorldBossStatus.debug then
		WorldBossStatus:Print("QUEST_TURNED_IN event received for quest ID: " ..  questID or "")
	end

	WorldBossStatus:SaveCharacterInfo()
end

function WorldBossStatus:UpdateWorldBossKills()	
	RequestRaidInfo();		
end

function WorldBossStatus:PLAYER_LOGOUT()
	if WorldBossStatus.debug then
		WorldBossStatus:Print("PLAYER_LOGOUT event received for quest ID: " ..  questID or "")
	end

	WorldBossStatus:UpdateWorldBossKills()
end

local function CheckWorldBosses()	
	local bossData = WorldBossStatus:GetBossData()

	for _, category in pairs(bossData) do
		if not category.legacy then
			for _, boss in pairs(category.bosses) do
				if boss.worldQuestID and boss.active and not IsQuestFlaggedCompleted(boss.trackingID) then 
					local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(boss.worldQuestID)
					local bossname = colorise(boss.name, epic)
					local text = ""
					if timeLeft then
						text = format("A quest is available for world boss %s! You have %s to defeat it!", bossname, SecondsToTime(timeLeft * 60, true, true, 2))
					else
						text = format("A quest is available for world boss %s! Go defeat it!", bossname)
					end
					WorldBossStatus:Print(text)
				end
			end
		end
	end
end

local function VersionCheck(aVersion)
	if not aVersion or string.len(aVersion) == 0 then return end

	if string.sub(aVersion, 1, 1) == "@" and string.sub(aVersion, string.len(aVersion)) == "@" then
		if WorldBossStatus.debug then
			WorldBossStatus:Print("Ignoring DEV release.")
		end
	else
		local currentVersion = GetAddOnMetadata(addonName, "Version")

		if (aVersion > currentVersion) then
			WorldBossStatus:Print("A new version ["..aVersion.."] of World Boss Status is available to download.")
		else
			if WorldBossStatus.debug then
				WorldBossStatus:Print("Ignoring same version ["..aVersion.."] release.")
			end
		end
	end
end

local function SendComms(aChannel)
	local bossData = WorldBossStatus:GetBossData()
	local message = {}
	local version = GetAddOnMetadata(addonName, "Version")

	message.version = version
	message.lastSeen =WorldBossStatus:GetLastSeenData(true)

	message = WorldBossStatus:Serialize(message)

	WorldBossStatus:SendCommMessage(addonName, message, aChannel)

	if WorldBossStatus.debug then
		WorldBossStatus:Print("Sent comms to "..aChannel.." channel. ["..version.."]")
	end
end

local function DelayedSendComms(aChannel)
	if WorldBossStatus:TimeLeft(WorldBossStatus.sendCommsTimer) == 0 then
		WorldBossStatus.sendCommsTimer = WorldBossStatus:ScheduleTimer(SendComms, 5, aChannel)
	end
end

function WorldBossStatus:ReceiveComms(aPrefix, aMessage, aChannel, aSender)
	if aSender ~= UnitName("player") then
		local success, message = self:Deserialize(aMessage)

		if self.debug then 
			if success then
			
				self:Print("Received comms from "..aSender.." [" ..message.version.."] on the "..aChannel.." channel and deserialized succesully!")
			else
				self:Print("Received comms from "..aSender.." on the "..aChannel.." channel but did not deserialize!")
			end
		end

		if success then
			self:UpdateLastSeenData(message.lastSeen)
			VersionCheck(message.version)
		end		
	end
end

function WorldBossStatus:RAID_ROSTER_UPDATE(event, ...)
	if self.debug then 
		self:Print("Received event RAID_ROSTER_UPDATE")
	end
	DelayedSendComms("RAID")

end

function WorldBossStatus:GROUP_ROSTER_UPDATE(event, ...)
	if self.debug then
		self:Print("Received event GROUP_ROSTER_UPDATE.")
	end
	if IsInRaid() then
		DelayedSendComms("RAID")
	else
		DelayedSendComms("PARTY")
	end
end

function WorldBossStatus:GUILD_ROSTER_UPDATE(event, ...)
	if self.debug then
		self:Print("Received event GUILD_ROSTER_UPDATE.")
	end
	DelayedSendComms("GUILD")
end

function WorldBossStatus:OnEnable()	
	self:RegisterEvent("UPDATE_INSTANCE_INFO")
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	self:RegisterEvent("LFG_COMPLETION_REWARD")	
	self:RegisterEvent("BONUS_ROLL_RESULT")
	self:RegisterEvent("BOSS_KILL")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")

	self:RegisterComm(addonName, "ReceiveComms")

	self:GetSinkAce3OptionsDataTable()
	self:ScheduleTimer(CheckWorldBosses, 10)
end

function WorldBossStatus:OnDisable()
	self:UnregisterEvent("UPDATE_INSTANCE_INFO")
	self:UnregisterEvent("LFG_UPDATE_RANDOM_INFO")
	self:UnregisterEvent("LFG_COMPLETION_REWARD")
	self:UnregisterEvent("BONUS_ROLL_RESULT")
	self:UnregisterEvent("BOSS_KILL")
	self:UnregisterEvent("QUEST_TURNED_IN")
	self:UnregisterEvent("PLAYER_LOGOUT")
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
end
