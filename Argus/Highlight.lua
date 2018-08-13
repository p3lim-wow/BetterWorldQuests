local GetZoneInfoAtPosition = select(2, ...).GetZoneInfoAtPosition

local function UpdateHighlight(Pin)
	-- update highlight based on custom data when hovering over a sub-zone
	local Map = Pin:GetMap()
	if(Map:GetMapID() == 905) then
		local atlas, offsetX, offsetY = GetZoneInfoAtPosition(Map:GetNormalizedCursorPosition())
		if(atlas) then
			local Texture = Pin.HighlightTexture
			Texture:ClearAllPoints()
			Texture:SetPoint('CENTER', offsetX, offsetY)
			Texture:SetAtlas(atlas)
			Texture:Show()
		else
			Pin.HighlightTexture:Hide()
		end
	end
end

for provider in next, WorldMapFrame.dataProviders do
	if(provider.pin and provider.pin:GetFrameLevelType() == 'PIN_FRAME_LEVEL_MAP_HIGHLIGHT') then
		hooksecurefunc(provider.pin, 'Refresh', UpdateHighlight)
	end
end
