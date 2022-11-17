local PARENT_MAPS = {
	-- list of all continents and their sub-zones that have world quests
	[1978] = { -- Dragon Isles
		[2022] = true, -- The Walking Shores
		[2023] = true, -- Ohn'ahran Plains
		[2024] = true, -- The Azure Span
		[2025] = true, -- Thaldraszus
	},
	[1550] = { -- Shadowlands
		[1525] = true, -- Revendreth
		[1533] = true, -- Bastion
		[1536] = true, -- Maldraxxus
		[1565] = true, -- Ardenwald
		[1543] = true, -- The Maw
	},
	[619] = { -- Broken Isles
		[630] = true, -- Azsuna
		[641] = true, -- Val'sharah
		[650] = true, -- Highmountain
		[634] = true, -- Stormheim
		[680] = true, -- Suramar
		[627] = true, -- Dalaran
		[790] = true, -- Eye of Azshara (world version)
		[646] = true, -- Broken Shore
	},
	[875] = { -- Zandalar
		[862] = true, -- Zuldazar
		[864] = true, -- Vol'Dun
		[863] = true, -- Nazmir
	},
	[876] = { -- Kul Tiras
		[895] = true, -- Tiragarde Sound
		[896] = true, -- Drustvar
		[942] = true, -- Stormsong Valley
	},
	[13] = { -- Eastern Kingdoms
		[14] = true, -- Arathi Highlands (Warfronts)
	},
	[12] = { -- Kalimdor
		[62] = true, -- Darkshore (Warfronts)
	},
}

local FACTION_ASSAULT_ATLAS = UnitFactionGroup('player') == 'Horde' and 'worldquest-icon-horde' or 'worldquest-icon-alliance'

-- create a new data provider that will display the world quests on zones from the list above,
-- based on WorldQuestDataProviderMixin
local DataProvider = CreateFromMixins(WorldQuestDataProviderMixin)
DataProvider:SetMatchWorldMapFilters(true)
DataProvider:SetUsesSpellEffect(true)
DataProvider:SetCheckBounties(true)
DataProvider:SetMarkActiveQuests(true)

function DataProvider:GetPinTemplate()
	-- we use our own copy of the WorldMap_WorldQuestPinTemplate template to avoid interference
	return 'BetterWorldQuestPinTemplate'
end

function DataProvider:ShouldShowQuest(questInfo)
	local questID = questInfo.questId
	if self.focusedQuestID or self:IsQuestSuppressed(questID) then
		return false
	else
		-- returns true if the given quest is a world quest on one of the maps in our list
		local mapID = self:GetMap():GetMapID()
		local questMapID = questInfo.mapID
		if mapID == questMapID or (PARENT_MAPS[mapID] and PARENT_MAPS[mapID][questMapID]) then
			return HaveQuestData(questID) and QuestUtils_IsQuestWorldQuest(questID)
		end
	end
end

function DataProvider:RefreshAllData()
	-- map is updated, draw world quest pins
	local pinsToRemove = {}
	for questID in next, self.activePins do
		-- mark all pins for removal
		pinsToRemove[questID] = true
	end

	local Map = self:GetMap()
	local mapID = Map:GetMapID()

	local quests = mapID and C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
	if quests then
		for _, questInfo in next, quests do
			if self:ShouldShowQuest(questInfo) and self:DoesWorldQuestInfoPassFilters(questInfo) then
				local questID = questInfo.questId
				pinsToRemove[questID] = nil -- unmark the pin for removal

				local Pin = self.activePins[questID]
				if Pin then
					-- update existing pin
					Pin:RefreshVisuals()
					Pin:SetPosition(questInfo.x, questInfo.y)

					if self.pingPin and self.pingPin:IsAttachedToQuest(questID) then
						self.pingPin:SetScalingLimits(1, 1, 1)
						self.pingPin:SetPosition(questInfo.x, questInfo.y)
					end
				else
					-- create a new pin
					self.activePins[questID] = self:AddWorldQuest(questInfo)
				end
			end
		end
	end

	for questID in next, pinsToRemove do
		-- iterate and remove all pins marked for removal
		if self.pingPin and self.pingPin:IsAttachedToQuest(questID) then
			self.pingPin:Stop()
		end

		Map:RemovePin(self.activePins[questID])
		self.activePins[questID] = nil
	end

	-- trigger callbacks like WorldQuestDataProviderMixin.RefreshAllData does
	Map:TriggerEvent('WorldQuestUpdate', Map:GetNumActivePinsByTemplate(self:GetPinTemplate()))
end

WorldMapFrame:AddDataProvider(DataProvider)

BetterWorldQuestPinMixin = CreateFromMixins(WorldMap_WorldQuestPinMixin)
function BetterWorldQuestPinMixin:OnLoad()
	WorldQuestPinMixin.OnLoad(self)

	-- create any extra widgets we need if they don't already exist
	local Border = self:CreateTexture(nil, 'OVERLAY', nil, 1)
	Border:SetPoint('CENTER', 0, -3)
	Border:SetAtlas('worldquest-emissary-ring')
	Border:SetSize(72, 72)
	self.Border = Border

	-- create the indicator on a subframe so highlights don't overlap
	local Indicator = CreateFrame('Frame', nil, self):CreateTexture(nil, 'OVERLAY', nil, 2)
	Indicator:SetPoint('CENTER', self, -19, 19)
	Indicator:SetSize(44, 44)
	self.Indicator = Indicator

	local Bounty = self:CreateTexture(nil, 'OVERLAY', nil, 2)
	Bounty:SetSize(44, 44)
	Bounty:SetAtlas('QuestNormal')
	Bounty:SetPoint('CENTER', 22, 0)
	self.Bounty = Bounty

	-- make sure the tracked check mark doesn't appear underneath any of our widgets
	self.TrackedCheck:SetDrawLayer('OVERLAY', 3)
end

local function IsParentMap(mapID)
	return not not PARENT_MAPS[mapID]
end

function BetterWorldQuestPinMixin:RefreshVisuals()
	WorldMap_WorldQuestPinMixin.RefreshVisuals(self)

	-- update scale
	if IsParentMap(self:GetMap():GetMapID()) then
		self:SetScalingLimits(1, 0.3, 0.5)
	else
		self:SetScalingLimits(1, 0.425, 0.425)
	end

	-- hide frames we don't want to use
	self.BountyRing:Hide()

	-- set texture to the item/currency/value it rewards
	local questID = self.questID
	if GetNumQuestLogRewards(questID) > 0 then
		local _, texture, _, _, _, itemID = GetQuestLogRewardInfo(1, questID)
		if C_Item.IsAnimaItemByID(itemID) then
			texture = 3528287 -- from item "Resonating Anima Core"
		end

		SetPortraitToTexture(self.Texture, texture)
		self.Texture:SetSize(self:GetSize())
	elseif GetNumQuestLogRewardCurrencies(questID) > 0 then
		local _, texture = GetQuestLogRewardCurrencyInfo(1, questID)
		SetPortraitToTexture(self.Texture, texture)
		self.Texture:SetSize(self:GetSize())
	elseif GetQuestLogRewardMoney(questID) > 0 then
		SetPortraitToTexture(self.Texture, [[Interface\Icons\inv_misc_coin_01]])
		self.Texture:SetSize(self:GetSize())
	end

	-- update our own widgets
	local bountyQuestID = self.dataProvider:GetBountyInfo()
	self.Bounty:SetShown(bountyQuestID and C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID))

	local questInfo = C_QuestLog.GetQuestTagInfo(questID)
	if questInfo.worldQuestType == Enum.QuestTagType.PvP then
		self.Indicator:SetAtlas('Warfronts-BaseMapIcons-Empty-Barracks-Minimap')
		self.Indicator:SetSize(58, 58)
		self.Indicator:Show()
	else
		self.Indicator:SetSize(44, 44)
		if questInfo.worldQuestType == Enum.QuestTagType.PetBattle then
			self.Indicator:SetAtlas('WildBattlePetCapturable')
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Profession then
			self.Indicator:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[questInfo.tradeskillLineID])
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Dungeon then
			self.Indicator:SetAtlas('Dungeon')
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Raid then
			self.Indicator:SetAtlas('Raid')
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Invasion then
			self.Indicator:SetAtlas('worldquest-icon-burninglegion')
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.FactionAssault then
			self.Indicator:SetAtlas(FACTION_ASSAULT_ATLAS)
			self.Indicator:SetSize(38, 38)
			self.Indicator:Show()
		else
			self.Indicator:Hide()
		end
	end
end

-- we need to remove the default data provider mixin
for provider in next, WorldMapFrame.dataProviders do
	if provider.GetPinTemplate and provider.GetPinTemplate() == 'WorldMap_WorldQuestPinTemplate' then
		WorldMapFrame:RemoveDataProvider(provider)
	end
end
