local pins = {}

local ARGUS = 905

local function OnDataRefreshed(self)
	local Map = self:GetMap()
	if(Map:GetMapID() == ARGUS) then
		local taxiNodes = C_TaxiMap.GetAllTaxiNodes(ARGUS)
		for index, taxiNodeData in next, taxiNodes do
			local Pin = Map:AcquirePin('FlightMap_FlightPointPinTemplate')
			self.slotIndexToPin[taxiNodeData.slotIndex] = Pin

			Pin:SetPosition(taxiNodeData.position:GetXY())
			Pin.taxiNodeData = taxiNodeData
			Pin.owner = self
			Pin.linkedPins = {}
			Pin:SetFlightPathStyle(taxiNodeData.textureKitPrefix, taxiNodeData.state)
			Pin:UpdatePinSize(taxiNodeData.state)
			Pin:UseFrameLevelType('PIN_FRAME_LEVEL_TOPMOST')
			Pin:SetShown(taxiNodeData.state ~= Enum.FlightPathState.Unreachable)
		end
	end
end

local function Inject()
	for provider in next, WorldMapFrame.dataProviders do
		if(provider.AddFlightNode) then
			hooksecurefunc(provider, 'RefreshAllData', OnDataRefreshed)
			return
		end
	end
end

if(IsAddOnLoaded('WorldFlightMap')) then
	Inject()
else
	local Handler = CreateFrame('Frame')
	Handler:RegisterEvent('ADDON_LOADED')
	Handler:SetScript('OnEvent', function(self, event, addOnName)
		if(addOnName == 'WorldFlightMap') then
			Inject()
			self:UnregisterEvent(event)
		end
	end)
end
