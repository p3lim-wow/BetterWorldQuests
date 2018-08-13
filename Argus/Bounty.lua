-- move the bounties so they don't overlap the sub-zones
local TOPRIGHT = LE_MAP_OVERLAY_DISPLAY_LOCATION_TOP_RIGHT
hooksecurefunc(WorldMapFrame, 'SetOverlayFrameLocation', function(Map, overlayFrame, location)
	if(Map:GetMapID() == 905 and overlayFrame.AreBountiesAvailable and location ~= TOPRIGHT) then
		Map:SetOverlayFrameLocation(overlayFrame, TOPRIGHT)
	end
end)
