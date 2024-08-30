local _, addon = ...

local CONTINENTS = {
	-- list of all continents and their sub-zones that have world quests
	[2274] = { -- Khaz Algar
		[2248] = true, -- Isle of Dorn
		[2215] = true, -- Hallowfall
		[2214] = true, -- The Ringing Deeps
		[2255] = true, -- Azj-Kahet
		[2256] = true, -- Azj-Kahet - Lower
		[2213] = true, -- City of Threads
		[2216] = true, -- City of Threads - Lower
	},
	[1978] = { -- Dragon Isles
		[2022] = true, -- The Walking Shores
		[2023] = true, -- Ohn'ahran Plains
		[2024] = true, -- The Azure Span
		[2025] = true, -- Thaldraszus
		[2151] = true, -- The Forbidden Reach
	},
	[1550] = { -- Shadowlands
		[1525] = true, -- Revendreth
		[1533] = true, -- Bastion
		[1536] = true, -- Maldraxxus
		[1565] = true, -- Ardenwald
		[1543] = true, -- The Maw
	},
	[619] = { -- Broken Isles
		[630] = true, -- Azsuna
		[641] = true, -- Val'sharah
		[650] = true, -- Highmountain
		[634] = true, -- Stormheim
		[680] = true, -- Suramar
		[627] = true, -- Dalaran
		[790] = true, -- Eye of Azshara (world version)
		[646] = true, -- Broken Shore
	},
	[424] = { -- Pandaria
		[1530] = true, -- Vale of Eternal Blossoms (BfA)
	},
	[875] = { -- Zandalar
		[862] = true, -- Zuldazar
		[864] = true, -- Vol'Dun
		[863] = true, -- Nazmir
	},
	[876] = { -- Kul Tiras
		[895] = true, -- Tiragarde Sound
		[896] = true, -- Drustvar
		[942] = true, -- Stormsong Valley
	},
	[13] = { -- Eastern Kingdoms
		[14] = true, -- Arathi Highlands (Warfronts)
	},
	[12] = { -- Kalimdor
		[62] = true, -- Darkshore (Warfronts)
		[1527] = true, -- Uldum (BfA)
	},
	[947] = { -- Azeroth
		[13] = true, -- Eastern Kingdoms
		[12] = true, -- Kalimdor
		[619] = true, -- Broken Isles
		[875] = true, -- Zandalar
		[876] = true, -- Kul Tiras
		[424] = true, -- Pandaria
		[1978] = true, -- Dragon Isles
		[2274] = true, -- Khaz Algar
	},
}

function addon:IsParentMap(mapID)
	return not not CONTINENTS[mapID]
end

function addon:IsChildMap(parentMapID, mapID)
	local mapInfo = C_Map.GetMapInfo(mapID)
	return parentMapID and mapID and mapInfo and mapInfo.parentMapID and mapInfo.parentMapID == parentMapID
end
