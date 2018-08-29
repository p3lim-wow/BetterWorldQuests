local barrels = {}
local quests = {
	[45068] = true,
	[45069] = true,
	[45070] = true,
	[45071] = true,
	[45072] = true,
}

local function tSize(t)
	-- would really like Lua 5.2 for this :/
	local size = 0
	for _ in next, t do
		size = size + 1
	end
	return size
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')
Handler:SetScript('OnEvent', function(self, event, ...)
	if(event == 'UPDATE_OVERRIDE_ACTIONBAR') then
		if(HasExtraActionBar()) then
			local _, spellID = GetActionInfo(ExtraActionButton1.action)
			if(spellID ==  230884) then
				self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
				self:RegisterEvent('QUEST_REMOVED')
			end
		end
	elseif(event == 'QUEST_REMOVED') then
		local questID = ...
		if(quests[questID]) then
			table.wipe(barrels)
			self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
			self:UnregisterEvent(event)
		end
	elseif(event == 'UPDATE_MOUSEOVER_UNIT') then
		local guid = UnitGUID('mouseover')
		if(guid) then
			if(tonumber((string.match(guid, 'Create%-.-%-.-%-.-%-.-%-(.-)%-'))) == 115947) then
				if(not barrels[guid]) then
					local index = (tSize(barrels) % 8) + 1
					barrels[guid] = index

					if(GetRaidTargetIndex('mouseover') ~= index) then
						SetRaidTarget('mouseover', index)
					end
				end
			end
		end
	end
end)
