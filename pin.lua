local _, addon = ...

local FACTION_ASSAULT_ATLAS = UnitFactionGroup('player') == 'Horde' and 'worldquest-icon-horde' or 'worldquest-icon-alliance'

local mapScale, parentScale, zoomFactor
addon:RegisterOptionCallback('mapScale', function(value)
	mapScale = value
end)
addon:RegisterOptionCallback('parentScale', function(value)
	parentScale = value
end)
addon:RegisterOptionCallback('zoomFactor', function(value)
	zoomFactor = value
end)

BetterWorldQuestPinMixin = CreateFromMixins(WorldMap_WorldQuestPinMixin)
function BetterWorldQuestPinMixin:OnLoad()
	WorldMap_WorldQuestPinMixin.OnLoad(self) -- super

	-- recreate WorldQuestPinTemplate regions
	local TrackedCheck = self:CreateTexture(nil, 'OVERLAY', nil, 7)
	TrackedCheck:SetPoint('BOTTOM', self, 'BOTTOMRIGHT', 0, -2)
	TrackedCheck:SetAtlas('worldquest-emissary-tracker-checkmark', true)
	TrackedCheck:Hide()
	self.TrackedCheck = TrackedCheck

	local TimeLowFrame = CreateFrame('Frame', nil, self)
	TimeLowFrame:SetPoint('CENTER', 9, -9)
	TimeLowFrame:SetSize(22, 22)
	TimeLowFrame:Hide()
	self.TimeLowFrame = TimeLowFrame

	local TimeLowIcon = TimeLowFrame:CreateTexture(nil, 'OVERLAY')
	TimeLowIcon:SetAllPoints()
	TimeLowIcon:SetAtlas('worldquest-icon-clock')
	TimeLowFrame.Icon = TimeLowIcon

	-- add our own widgets
	local Reward = self:CreateTexture(nil, 'OVERLAY')
	Reward:SetPoint('CENTER', self.PushedTexture)
	Reward:SetSize(self:GetWidth() - 4, self:GetHeight() - 4)
	Reward:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	self.Reward = Reward

	local RewardMask = self:CreateMaskTexture()
	RewardMask:SetTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
	RewardMask:SetAllPoints(Reward)
	Reward:AddMaskTexture(RewardMask)

	local Indicator = self:CreateTexture(nil, 'OVERLAY', nil, 2)
	Indicator:SetPoint('CENTER', self, 'TOPLEFT', 4, -4)
	self.Indicator = Indicator

	local Reputation = self:CreateTexture(nil, 'OVERLAY', nil, 2)
	Reputation:SetPoint('CENTER', self, 'BOTTOM', 0, 2)
	Reputation:SetSize(10, 10)
	Reputation:SetAtlas('socialqueuing-icon-eye')
	Reputation:Hide()
	self.Reputation = Reputation

	local Bounty = self:CreateTexture(nil, 'OVERLAY', nil, 3)
	Bounty:SetAtlas('QuestNormal', true)
	Bounty:SetScale(0.65)
	Bounty:SetPoint('LEFT', self, 'RIGHT', -(Bounty:GetWidth() / 2), 0)
	self.Bounty = Bounty
end

function BetterWorldQuestPinMixin:RefreshVisuals()
	WorldMap_WorldQuestPinMixin.RefreshVisuals(self) -- super

	-- hide optional elements by default
	self.Bounty:Hide()
	self.Reward:Hide()
	self.Reputation:Hide()
	self.Indicator:Hide()
	self.Display.Icon:Hide()

	-- update scale
	local mapID = self:GetMap():GetMapID()
	if mapID == 947 then
		self:SetScalingLimits(1, parentScale / 2, (parentScale / 2) + zoomFactor)
	elseif addon:IsParentMap(mapID) then
		self:SetScalingLimits(1, parentScale, parentScale + zoomFactor)
	else
		self:SetScalingLimits(1, mapScale, mapScale + zoomFactor)
	end

	-- uniform coloring
	if self:IsSelected() then
		self.NormalTexture:SetAtlas('worldquest-questmarker-epic-supertracked', true)
	else
		self.NormalTexture:SetAtlas('worldquest-questmarker-epic', true)
	end

	-- set reward icon
	local questID = self.questID
	local currencyRewards = C_QuestLog.GetQuestRewardCurrencies(questID)
	if GetNumQuestLogRewards(questID) > 0 then
		local _, texture, _, _, _, itemID = GetQuestLogRewardInfo(1, questID)
		if C_Item.IsAnimaItemByID(itemID) then
			texture = 3528287 -- from item "Resonating Anima Core"
		end

		self.Reward:SetTexture(texture)
		self.Reward:Show()
	elseif #currencyRewards > 0 then
		self.Reward:SetTexture(currencyRewards[1].texture)
		self.Reward:Show()
	elseif GetQuestLogRewardMoney(questID) > 0 then
		self.Reward:SetTexture([[Interface\Icons\INV_MISC_COIN_01]])
		self.Reward:Show()
	else
		-- if there are no rewards just show the default icon
		self.Display.Icon:Show()
	end

	-- set world quest type indicator
	local questInfo = C_QuestLog.GetQuestTagInfo(questID)
	if questInfo then
		if questInfo.worldQuestType == Enum.QuestTagType.PvP then
			self.Indicator:SetAtlas('Warfronts-BaseMapIcons-Empty-Barracks-Minimap')
			self.Indicator:SetSize(18, 18)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.PetBattle then
			self.Indicator:SetAtlas('WildBattlePetCapturable')
			self.Indicator:SetSize(10, 10)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Profession then
			self.Indicator:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[questInfo.tradeskillLineID])
			self.Indicator:SetSize(10, 10)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Dungeon then
			self.Indicator:SetAtlas('Dungeon')
			self.Indicator:SetSize(20, 20)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Raid then
			self.Indicator:SetAtlas('Raid')
			self.Indicator:SetSize(20, 20)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Invasion then
			self.Indicator:SetAtlas('worldquest-icon-burninglegion')
			self.Indicator:SetSize(10, 10)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.FactionAssault then
			self.Indicator:SetAtlas(FACTION_ASSAULT_ATLAS)
			self.Indicator:SetSize(10, 10)
			self.Indicator:Show()
		end
	end

	-- update bounty icon
	local bountyQuestID = self.dataProvider:GetBountyInfo()
	if bountyQuestID and C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID) then
		self.Bounty:Show()
	end

	-- highlight reputation
	local _, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
	if factionID then
		local factionInfo = C_Reputation.GetFactionDataByID(factionID)
		if factionInfo and factionInfo.isWatched then
			self.Reputation:Show()
		end
	end
end

function BetterWorldQuestPinMixin:AddIconWidgets()
	-- remove the obnoxious glow behind world bosses
end

function BetterWorldQuestPinMixin:SetPassThroughButtons()
	-- https://github.com/Stanzilla/WoWUIBugs/issues/453
end
