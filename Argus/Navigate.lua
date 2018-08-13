local GetZoneInfoAtPosition = select(2, ...).GetZoneInfoAtPosition

-- override navigation so we can use our custom sub-zone positions
function WorldMapFrame:NavigateToCursor()
	if(self:GetMapID() == 905) then
		local _, _, _, mapID = GetZoneInfoAtPosition(self:GetNormalizedCursorPosition())
		if(mapID) then
			-- for some reason the NavigateToMap method doesn't work
			self:SetMapID(mapID)
			self:RefreshDetailLayers()
		end
	else
		-- let the default handler run
		MapCanvasMixin.NavigateToCursor(self)
	end
end
