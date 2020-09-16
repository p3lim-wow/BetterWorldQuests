-- display the Vindicaar the player is on, just so it doesn't look like the player is floating in mid-air
local faction = UnitFactionGroup('player') -- players don't just change faction willy nilly, cache it
local function UpdateVindicaar(self)
	local Map = self:GetMap()
	if(Map:GetMapID() == 905) then
		self:RemoveAllData()

		if(NumTaxiNodes() == 0) then
			-- only show if we're not viewing taxi destinations
			for _, info in next, C_TaxiMap.GetTaxiNodesForMap(994) do
				if(self:ShouldShowTaxiNode(faction, info)) then
					if(info.textureKitPrefix and info.textureKitPrefix:find('Vindicaar') and info.atlasName == 'TaxiNode_Neutral') then
						Map:AcquirePin('FlightPointPinTemplate', info) -- TODO: SetSize(39, 42)
					end
				end
			end
		end
	end
end

for provider in next, WorldMapFrame.dataProviders do
	if(provider.ShouldShowTaxiNode) then
		hooksecurefunc(provider, 'RefreshAllData', UpdateVindicaar)

		-- hide the Vindicaar when opening a taxi map
		provider:RegisterEvent('TAXIMAP_OPENED')
		provider.OnEvent = UpdateVindicaar
	end
end
