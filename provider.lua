local _, addon = ...

local HBD = LibStub('HereBeDragons-2.0')
local PARENT_MAPS = {
	-- list of all continents and their sub-zones that have world quests
	[2274] = { -- Khaz Algar
		[2248] = true, -- Isle of Dorn
		[2215] = true, -- Hallowfall
		[2214] = true, -- The Ringing Deeps
		[2255] = true, -- Azj-Kahet
		[2256] = true, -- Azj-Kahet - Lower (don't know how this works yet)
		[2213] = true, -- City of Threads (not really representable on Algar, TBD)
		[2216] = true, -- City of Threads - Lower (again, don't know how this works)
	},
	[1978] = { -- Dragon Isles
		[2022] = true, -- The Walking Shores
		[2023] = true, -- Ohn'ahran Plains
		[2024] = true, -- The Azure Span
		[2025] = true, -- Thaldraszus
		[2151] = true, -- The Forbidden Reach
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

function addon:IsParentMap(mapID)
	return not not PARENT_MAPS[mapID]
end

local provider = CreateFromMixins(WorldQuestDataProviderMixin)
provider:SetMatchWorldMapFilters(true)
provider:SetUsesSpellEffect(true)
provider:SetCheckBounties(true)
-- provider:SetMarkActiveQuests(true) -- unused in TWW

-- override GetPinTemplate to use our custom pin
function provider:GetPinTemplate()
	return 'BetterWorldQuestPinTemplate'
end

-- override ShouldShowQuest method to also show on parent maps
function provider:ShouldShowQuest(questInfo)
	if WorldQuestDataProviderMixin.ShouldShowQuest(self, questInfo) then -- super
		local mapID = self:GetMap():GetMapID()
		local questMapID = questInfo.mapID
		return mapID == questMapID or (PARENT_MAPS[mapID] and PARENT_MAPS[mapID][questMapID])
	end
end

local function getMapQuests(mapID)
	if not mapID then
		-- there are actually invalid maps, let's ignore them
		return
	end

	local mapQuests = GetQuestsForPlayerByMapIDCached(mapID)
	if not mapQuests then
		mapQuests = {}
	end

	if mapID == 1978 or mapID == 2025 then
		-- primalist maps are off-set and can't translate, translate them nearby on parent map
		local quests = GetQuestsForPlayerByMapIDCached(2085)
		if quests then
			for index, questInfo in next, quests do
				questInfo.mapID = 2025 -- move it to the Thaldraszus map

				-- adjust coordinates based on display map
				if mapID == 1978 then
					questInfo.x = 0.67 + (((index - 1) * 10) / 100)
					questInfo.y = 0.59
				else
					questInfo.x = 0.7 + (((index - 1) * 10) / 100)
					questInfo.y = 0.8
				end

				table.insert(mapQuests, questInfo)
			end
		end
	end

	if mapID == 13 then
		-- stranglethorn is split into subzones, let's translate them
		local quests = GetQuestsForPlayerByMapIDCached(210)
		if quests then
			for _, questInfo in next, quests do
				questInfo.mapID = 13 -- move it to the Eastern Kalimdor map
				questInfo.x, questInfo.y = HBD:TranslateZoneCoordinates(questInfo.x, questInfo.y, questInfo.mapID, 13)
				-- TODO: do we need HBD for this?

				table.insert(mapQuests, questInfo)
			end
		end
	end

	return mapQuests
end

-- override RefreshAllData to fine-control which quests should show (it's otherwise identical)
function provider:RefreshAllData()
	-- this if from WorldQuestDataProviderMixin.RefreshAllData
	local pinsToRemove = {}
	for questID in next, self.activePins do
		pinsToRemove[questID] = true
	end

	local taskInfo
	local mapCanvas = self:GetMap()

	local mapID = mapCanvas:GetMapID()
	if mapID then
		-- this is the only part that is overridden
		-- taskInfo = GetQuestsForPlayerByMapIDCached(mapID)
		taskInfo = getMapQuests(mapID)
		self.matchWorldMapFilters = MapUtil.MapShouldShowWorldQuestFilters(mapID)
	end

	if taskInfo and C_CVar.GetCVarBool('questPOIWQ') then
		for _, info in next, taskInfo do
			if self:ShouldOverrideShowQuest(mapID, info.questId) or self:ShouldShowQuest(info) and HaveQuestData(info.questId) then
				if QuestUtils_IsQuestWorldQuest(info.questId) then
					if self:DoesWorldQuestInfoPassFilters(info) then
						pinsToRemove[info.questId] = nil

						local pin = self.activePins[info.questId]
						if pin then
							pin:RefreshVisuals()
							pin.numObjectives = info.numObjectives
							pin:SetPosition(info.x, info.y)
							pin:AddIconWidgets()

							if self.pingPin and self.pingPin:GetID() == info.questId then
								self.pingPin:SetPosition(info.x, info.y)
							end
						else
							self.activePins[info.questId] = self:AddWorldQuest(info)
						end
					end
				end
			end
		end
	end

	for questID in next, pinsToRemove do
		if self.pingPin and self.pingPin:GetID() == questID then
			self.pingPin:Stop()
		end

		mapCanvas:RemovePin(self.activePins[questID])
		self.activePins[questID] = nil
	end

	mapCanvas:TriggerEvent('WorldQuestUpdate', mapCanvas:GetNumActivePinsByTemplate(self:GetPinTemplate()))

	-- this is from WorldMap_WorldQuestDataProviderMixin.RefreshAllData, + OnAdded
	if not self.poiQuantizer then
		self.poiQuantizer = CreateFromMixins(WorldMapPOIQuantizerMixin)
		self.poiQuantizer.size = 75
		self.poiQuantizer:OnLoad(self.poiQuantizer.size, self.poiQuantizer.size)
	end

	self.poiQuantizer:ClearAndQuantize(self.activePins)
	for _, pin in next, self.activePins do
		pin:SetPosition(pin.quantizedX or pin.normalizedX, pin.quantizedY or pin.normalizedY)
	end
end

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
	if dp.GetPinTemplate and dp.GetPinTemplate() == 'WorldMap_WorldQuestPinTemplate' then
		WorldMapFrame:RemoveDataProvider(dp)
	end
end

-- add our own provider
WorldMapFrame:AddDataProvider(provider)

-- change visibility with alt key
local function toggleVisibility(state)
	for pin in WorldMapFrame:EnumeratePinsByTemplate(provider:GetPinTemplate()) do
		pin:SetShown(state)
	end
end

function addon:MODIFIER_STATE_CHANGED()
	if WorldMapFrame:IsShown() then
		toggleVisibility(not IsAltKeyDown())
	end
end

WorldMapFrame:HookScript('OnHide', function()
	toggleVisibility(true)
end)
