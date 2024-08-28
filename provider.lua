local _, addon = ...

local provider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin)
provider:SetMatchWorldMapFilters(true)
provider:SetUsesSpellEffect(true)
provider:SetCheckBounties(true)

-- override GetPinTemplate to use our custom pin
function provider:GetPinTemplate()
	return 'BetterWorldQuestPinTemplate'
end

-- override ShouldOverrideShowQuest method to show pins on continent maps
function provider:ShouldOverrideShowQuest(mapID) --, questInfo)
	local mapInfo = C_Map.GetMapInfo(mapID)
	return mapInfo.mapType == Enum.UIMapType.Continent
end

-- override ShouldShowQuest method to show pins on parent maps
function provider:ShouldShowQuest(questInfo)
	if WorldQuestDataProviderMixin.ShouldShowQuest(self, questInfo) then -- super
		return true
	end

	return addon:IsChildMap(self:GetMap():GetMapID(), questInfo.mapID)
end

WorldMapFrame:AddDataProvider(provider)

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
	if dp.GetPinTemplate and dp.GetPinTemplate() == 'WorldMap_WorldQuestPinTemplate' then
		WorldMapFrame:RemoveDataProvider(dp)
	end
end

-- change visibility
local modifier
local function toggleVisibility()
	local state = true
	if modifier == 'ALT' then
		state = not IsAltKeyDown()
	elseif modifier == 'SHIFT' then
		state = not IsShiftKeyDown()
	elseif modifier == 'CTRL' then
		state = not IsControlKeyDown()
	end

	for pin in WorldMapFrame:EnumeratePinsByTemplate(provider:GetPinTemplate()) do
		pin:SetShown(state)
	end
end

WorldMapFrame:HookScript('OnHide', function()
	toggleVisibility()
end)

addon:RegisterOptionCallback('hideModifier', function(value)
	if value == 'NEVER' then
		if addon:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
			addon:UnregisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
		end

		modifier = nil
		toggleVisibility()
	else
		if not addon:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
			addon:RegisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
		end

		modifier = value
	end
end)
