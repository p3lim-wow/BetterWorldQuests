-- display group members on the map
local function UpdateGroupMembers(self)
	local Map = self:GetMap()
	if(Map:GetMapID() == 905) then
		if(C_Map.GetMapDisplayInfo(994)) then
			self:Hide()
		else
			self:SetUiMapID(994)
			self:Show()

			if(self.dataProvider:ShouldShowUnit('player')) then
				self:StartPlayerPing(2, 0.25)
			end
		end
	end
end

for provider in next, WorldMapFrame.dataProviders do
	if(provider.ShouldShowUnit) then
		hooksecurefunc(provider.pin, 'OnMapChanged', UpdateGroupMembers)
	end
end
