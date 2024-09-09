local _, addon = ...

local SPECIAL_ASSIGNMENT_WIDGET_SET = 1108

local provider = CreateFromMixins(AreaPOIDataProviderMixin)
function provider:GetPinTemplate()
	return 'BetterWorldQuestPOITemplate'
end

function provider:RefreshAllData()
	self:RemoveAllData()

	local map = self:GetMap()
	local mapID = map:GetMapID()

	if mapID == 947 then
		return
	end

	if addon:IsParentMap(mapID) then
		for _, mapInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
			if mapInfo.flags == 6 or mapInfo.flags == 4 then -- TODO: do bitwise compare with 0x04
				-- copy from AreaPOIDataProviderMixin
				for _, poiID in next, GetAreaPOIsForPlayerByMapIDCached(mapInfo.mapID) do
					local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, poiID)
					if poiInfo and poiInfo.tooltipWidgetSet == SPECIAL_ASSIGNMENT_WIDGET_SET then
						poiInfo.dataProvider = self

						-- translate position
						poiInfo.position = addon:TranslatePosition(poiInfo.position, mapInfo.mapID, mapID)

						if poiInfo.position then
							map:AcquirePin(self:GetPinTemplate(), poiInfo)
						end
					end
				end
			end
		end
	end
end

WorldMapFrame:AddDataProvider(provider)

-- hook into changes
local function updateVisuals()
	-- update pins on changes
	if WorldMapFrame:IsShown() then
		provider:RefreshAllData()
	end
end

addon:RegisterOptionCallback('showEvents', updateVisuals)

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

	for pin in WorldMapFrame:EnumeratePinsByTemplate('AreaPOIPinTemplate') do
		local poiInfo = pin:GetPoiInfo()
		if poiInfo and poiInfo.tooltipWidgetSet == SPECIAL_ASSIGNMENT_WIDGET_SET then
			pin:SetShown(state)
		end
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
