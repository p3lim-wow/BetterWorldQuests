local _, ns = ...

local function IsPointInTriangle(x, y, p)
	local b1 = ((x - p[2].x) * (p[1].y - p[2].y) - (p[1].x - p[2].x) * (y - p[2].y)) < 0
	local b2 = ((x - p[3].x) * (p[2].y - p[3].y) - (p[2].x - p[3].x) * (y - p[3].y)) < 0
	local b3 = ((x - p[1].x) * (p[3].y - p[1].y) - (p[3].x - p[1].x) * (y - p[1].y)) < 0

	return ((b1 == b2) and (b2 == b3))
end

local function GetMapData(mapID)
	-- the last two returns are approximated offsets for the highlight texture, from center
	if(mapID == 882) then
		return 'MacAree_Highlight', 0, 120, mapID
	elseif(mapID == 885) then
		return 'AntoranWastes_Highlight', -300, -200, mapID
	elseif(mapID == 830) then
		return 'Krokuun_Highlight', 350, -100, mapID
	end
end

local V = CreateVector2D
local zonePoints = {
	-- custom triangle points to make up an approximated area for each Argus sub-zone on
	-- our "custom" Argus map art
	[885] = {V(0.09, 0.99), V(0.26, 0.30), V(0.50, 0.99)}, -- Antoran Wastes
	[882] = {V(0.15, 0.01), V(0.75, 0.01), V(0.50, 0.70)}, -- Mac'Aree
	[830] = {V(0.82, 0.25), V(0.99, 0.99), V(0.50, 0.99)}, -- Krokuun
}

function ns.GetZoneInfoAtPosition(cX, cY)
	for mapID, points in next, zonePoints do
		if(IsPointInTriangle(cX, cY, points)) then
			return GetMapData(mapID)
		end
	end
end

local DIFF_DESC = WORLD_MAP_WILDBATTLEPET_LEVEL .. '%s(%s-%s)' .. FONT_COLOR_CODE_CLOSE
local SAME_DESC = WORLD_MAP_WILDBATTLEPET_LEVEL .. '%s(%s)' .. FONT_COLOR_CODE_CLOSE

function ns.GetZoneDescription(mapID)
	-- Argus sub-zones doesn't have player level recommendations, so just return pet battle info
	-- this is pretty much a copy-paste from AreaLabelFrameMixin.OnUpdate
	local _, _, _, _, locked = C_PetJournal.GetPetLoadOutInfo(1) -- TODO: cache
	if(not locked and GetCVarBool('showTamers')) then -- TODO: cache
		local _, _, petMinLevel, petMaxLevel = C_Map.GetMapLevels(mapID)
		if(petMinLevel and petMaxLevel and petMinLevel > 0 and petMaxLevel > 0) then
			local teamLevel = C_PetJournal.GetPetTeamAverageLevel() -- TODO: cache
			local color
			if(teamLevel) then
				if(teamLevel < petMinLevel) then
					color = GetRelativeDifficultyColor(teamLevel, petMinLevel + 2)
				elseif(teamLevel > petMaxLevel) then
					color = GetRelativeDifficultyColor(teamLevel, petMaxLevel)
				else
					color = QuestDifficultyColors.difficult
				end
			else
				color = QuestDifficultyColors.header
			end

			if(petMinLevel ~= petMaxLevel) then
				return DIFF_DESC:format(ConvertRGBtoColorString(color), petMinLevel, petMaxLevel)
			else
				return SAME_DESC:format(ConvertRGBtoColorString(color), petMaxLevel)
			end
		end
	end

	-- empty for no pet battles
	return ''
end

-- cache map data to avoid calling API every time
local zoneNames = {
	[882] = C_Map.GetMapInfo(882).name,
	[885] = C_Map.GetMapInfo(885).name,
	[830] = C_Map.GetMapInfo(830).name,
}

function ns.GetZoneName(mapID)
	return zoneNames[mapID]
end
