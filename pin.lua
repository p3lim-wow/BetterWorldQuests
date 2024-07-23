local _, addon = ...

local FACTION_ASSAULT_ATLAS = UnitFactionGroup('player') == 'Horde' and 'worldquest-icon-horde' or 'worldquest-icon-alliance'

BetterWorldQuestPinMixin = CreateFromMixins(WorldMap_WorldQuestPinMixin)
function BetterWorldQuestPinMixin:OnLoad()
	WorldQuestPinMixin.OnLoad(self) -- super

	-- add our own widgets
	local Reward = self:CreateTexture(nil, 'OVERLAY')
	Reward:SetAllPoints()
	Reward:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	self.Reward = Reward

	local RewardMask = self:CreateMaskTexture()
	RewardMask:SetTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
	RewardMask:SetAllPoints(Reward)
	Reward:AddMaskTexture(RewardMask)

	local Border = self:CreateTexture(nil, 'OVERLAY', nil, 1)
	Border:SetAtlas('worldquest-emissary-ring')
	Border:SetPoint('TOPLEFT', -5, 5)
	Border:SetPoint('BOTTOMRIGHT', 5, -5)
	self.Border = Border

	local Indicator = self:CreateTexture(nil, 'OVERLAY', nil, 2)
	Indicator:SetPoint('CENTER', self, 'TOPLEFT')---9, 9)
	self.Indicator = Indicator

	local Reputation = self:CreateTexture(nil, 'OVERLAY', nil, 2)
	Reputation:SetPoint('CENTER', self, 'BOTTOM')
	Reputation:SetSize(16, 16)
	Reputation:SetAtlas('socialqueuing-icon-eye')
	Reputation:Hide()
	self.Reputation = Reputation

	local Bounty = self:CreateTexture(nil, 'OVERLAY', nil, 3)
	Bounty:SetAtlas('QuestNormal', true)
	Bounty:SetScale(0.65)
	Bounty:SetPoint('LEFT', self, 'RIGHT', -(Bounty:GetWidth() / 2), 0)
	self.Bounty = Bounty

	-- adjust existing widgets
	self.TrackedCheck:SetDrawLayer('OVERLAY', 7)
	self.Display:Hide()
	self.NormalTexture:SetAlpha(0)
	self.PushedTexture:SetAlpha(0)
end

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

function BetterWorldQuestPinMixin:RefreshVisuals()
	WorldMap_WorldQuestPinMixin.RefreshVisuals(self) -- super

	-- update scale
	if addon:IsParentMap(self:GetMap():GetMapID()) then
		self:SetScalingLimits(1, parentScale, parentScale + zoomFactor)
	else
		self:SetScalingLimits(1, mapScale, mapScale + zoomFactor)
	end

	-- fix underlay
	if self.UnderlayAtlas then
		self.UnderlayAtlas:SetScale(1.4)
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
	elseif #currencyRewards > 0 then
		self.Reward:SetTexture(currencyRewards[1].texture)
	elseif GetQuestLogRewardMoney(questID) > 0 then
		self.Reward:SetTexture([[Interface\Icons\INV_MISC_COIN_01]])
	else
		-- if there are no rewards just show the default wq icon
		self.Reward:SetAtlas('Worldquest-icon')
	end

	-- set world quest type indicator
	local questInfo = C_QuestLog.GetQuestTagInfo(questID)
	if questInfo then
		if questInfo.worldQuestType == Enum.QuestTagType.PvP then
			self.Indicator:SetAtlas('Warfronts-BaseMapIcons-Empty-Barracks-Minimap')
			self.Indicator:SetSize(25, 25)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.PetBattle then
			self.Indicator:SetAtlas('WildBattlePetCapturable')
			self.Indicator:SetSize(16, 16)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Profession then
			self.Indicator:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[questInfo.tradeskillLineID])
			self.Indicator:SetSize(16, 16)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Dungeon then
			self.Indicator:SetAtlas('Dungeon')
			self.Indicator:SetSize(26, 26)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Raid then
			self.Indicator:SetAtlas('Raid')
			self.Indicator:SetSize(26, 26)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.Invasion then
			self.Indicator:SetAtlas('worldquest-icon-burninglegion')
			self.Indicator:SetSize(16, 16)
			self.Indicator:Show()
		elseif questInfo.worldQuestType == Enum.QuestTagType.FactionAssault then
			self.Indicator:SetAtlas(FACTION_ASSAULT_ATLAS)
			self.Indicator:SetSize(14, 14)
			self.Indicator:Show()
		else
			self.Indicator:Hide()
		end
	else
		self.Indicator:Hide()
	end

	-- update bounty icon
	local bountyQuestID = self.dataProvider:GetBountyInfo()
	self.Bounty:SetShown(bountyQuestID and C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID))

	-- highlight reputation
	local _, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
	if factionID then
		local factionInfo = C_Reputation.GetFactionDataByID(factionID)
		if factionInfo and factionInfo.isWatched then
			self.Reputation:Show()
			return
		end
	end

	self.Reputation:Hide()
end

-- TODO: is this still needed?
BetterWorldQuestPinMixin.SetPassThroughButtons = function() end
