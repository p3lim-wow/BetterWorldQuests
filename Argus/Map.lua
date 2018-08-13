local tiles = {}
do
	-- create tiles based on map ID 994, an alternative art set for Argus used in the taxi UI,
	-- which are drawn one level above the original map canvas
	-- method is based on MapCanvasDetailLayerMixin.RefreshDetailTiles
	local textures = C_Map.GetMapArtLayerTextures(994, 1)
	local layer = C_Map.GetMapArtLayers(994)[1]
	local tileSize = 70 -- we can't use the tile size provided by GetMapArtLayers, it's too big

	for col = 1, math.ceil(layer.layerHeight / layer.tileHeight) do
		for row = 1, math.ceil(layer.layerWidth / layer.tileWidth) do
			local Tile = WorldMapFrame:GetCanvas():CreateTexture(nil, 'BACKGROUND', -7)
			Tile:SetSize(tileSize, tileSize)
			Tile:SetPoint('TOPLEFT', tileSize * (row - 1), -tileSize * (col - 1))
			Tile:SetTexture(textures[#tiles + 1], nil, nil, 'TRILINEAR')
			Tile:SetAlpha(0)

			tiles[#tiles + 1] = Tile
		end
	end
end

-- data providers are typically used for pins, but can just as well be used for anything on the map
local ArgusCanvas = CreateFromMixins(MapCanvasDataProviderMixin)
function ArgusCanvas:RefreshAllData()
	-- this method triggers when there is a map change
	local shouldShow = self:GetMap():GetMapID() == 905
	for _, Tile in next, tiles do
		Tile:SetAlpha(shouldShow and 1 or 0)
	end
end

WorldMapFrame:AddDataProvider(ArgusCanvas)
