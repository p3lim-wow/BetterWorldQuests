local _, addon = ...
local HBD = LibStub('HereBeDragons-2.0')

local DRAGON_ISLES_MAPS = {
	[2022] = true, -- The Walking Shores
	[2023] = true, -- Ohn'ahran Plains
	[2024] = true, -- The Azure Span
	[2025] = true, -- Thaldraszus
}

local function updatePOIs(self)
	local map = self:GetMap()
	local mapID = map:GetMapID()
	if mapID == 1978 then -- Dragon Isles
		for childMapID in next, DRAGON_ISLES_MAPS do
			for _, poiID in next, C_AreaPoiInfo.GetAreaPOIForMap(childMapID) do
				local info = C_AreaPoiInfo.GetAreaPOIInfo(childMapID, poiID)
				if info and addon:startswith(info.atlasName, 'ElementalStorm') then
					local x, y = info.position:GetXY()
					info.dataProvider = self
					info.position:SetXY(HBD:TranslateZoneCoordinates(x, y, childMapID, mapID))
					map:AcquirePin(self:GetPinTemplate(), info)
				end
			end
		end
	end
end

for dp in next, WorldMapFrame.dataProviders do
	if not dp.GetPinTemplates and type(dp.GetPinTemplate) == 'function' then
		if dp:GetPinTemplate() == 'AreaPOIPinTemplate' then
			hooksecurefunc(dp, 'RefreshAllData', updatePOIs)
			break
		end
	end
end
