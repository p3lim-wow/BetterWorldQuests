local _, addon = ...

local PARENT_MAPS = {
	-- list of all continents and their sub-zones that have world quests
	[2274] = { -- Khaz Algar
		[2248] = true, -- Isle of Dorn
		[2215] = true, -- Hallowfall
		[2214] = true, -- The Ringing Deeps
		[2255] = true, -- Azj-Kahet
		[2256] = true, -- Azj-Kahet - Lower (don't know how this works yet)
		[2213] = true, -- City of Threads (not really representable on Algar, TBD)
		[2216] = true, -- City of Threads - Lower (again, don't know how this works)
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
	},
}

function addon:IsParentMap(mapID)
	return not not PARENT_MAPS[mapID]
end

function addon:IsChildMap(parentMapID, mapID)
	return not not (PARENT_MAPS[parentMapID] and PARENT_MAPS[parentMapID][mapID])
end
