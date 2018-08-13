local _, ns = ...
local GetZoneInfoAtPosition = ns.GetZoneInfoAtPosition
local GetZoneDescription = ns.GetZoneDescription
local GetZoneName = ns.GetZoneName

local function AreaLabelOnUpdate(self)
	local Map = self.dataProvider:GetMap()
	local mapID = Map:GetMapID()
	if(mapID == 905) then
		-- update title on Argus sub-zones
		local _, _, _, zoneMapID = GetZoneInfoAtPosition(Map:GetNormalizedCursorPosition())
		if(zoneMapID) then
			self:SetLabel(MAP_AREA_LABEL_TYPE.AREA_NAME, GetZoneName(zoneMapID), GetZoneDescription(zoneMapID))
		else
			self:ClearLabel(MAP_AREA_LABEL_TYPE.AREA_NAME)
		end

		self:EvaluateLabels()
	else
		-- let the default handler run
		AreaLabelFrameMixin.OnUpdate(self)
	end
end

for provider in next, WorldMapFrame.dataProviders do
	if(provider.setAreaLabelCallback) then
		provider.Label:SetScript('OnUpdate', AreaLabelOnUpdate)
	end
end
