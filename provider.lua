local _, addon = ...

local provider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin)
provider:SetMatchWorldMapFilters(true)
provider:SetUsesSpellEffect(true)
provider:SetCheckBounties(true)

-- override GetPinTemplate to use our custom pin
function provider:GetPinTemplate()
	return 'BetterWorldQuestPinTemplate'
end

-- override ShouldShowQuest method to also show on parent maps
function provider:ShouldOverrideShowQuest(mapID) --, questInfo)
	local mapInfo = C_Map.GetMapInfo(mapID)
	return mapInfo.mapType == Enum.UIMapType.Continent
end

WorldMapFrame:AddDataProvider(provider)

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
	if dp.GetPinTemplate and dp.GetPinTemplate() == 'WorldMap_WorldQuestPinTemplate' then
		WorldMapFrame:RemoveDataProvider(dp)
	end
end

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
