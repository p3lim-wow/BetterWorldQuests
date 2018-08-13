-- display Greater Invasion Points on the map
local function UpdatePOIs(self)
	local Map = self:GetMap()
	if(Map:GetMapID() == 905) then
		self:RemoveAllData()

		for _, id in next, C_AreaPoiInfo.GetAreaPOIForMap(994) do
			local info = C_AreaPoiInfo.GetAreaPOIInfo(994, id)
			if(info and info.atlasName == 'poi-rift2') then
				Map:AcquirePin(self:GetPinTemplate(), info)
			end
		end
	end
end

for provider in next, WorldMapFrame.dataProviders do
	if(provider.GetPinTemplate and provider:GetPinTemplate() == 'AreaPOIPinTemplate') then
		hooksecurefunc(provider, 'RefreshAllData', UpdatePOIs)
	end
end
