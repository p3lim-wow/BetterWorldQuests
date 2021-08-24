-- not really a quest, but easily automated

local MESSAGE = 'Spam <SpaceBar> to complete!'
local BUTTON = 'ACTIONBUTTON%d'

local taming
local Handler = CreateFrame('Frame')
Handler:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
Handler:SetScript('OnEvent', function(self, event, unit, _, spellID)
	if event == 'UNIT_SPELLCAST_SUCCEEDED' then
		if spellID == 356137 then
			-- Taming the Wilderling
			for i = 1, 2 do
				RaidNotice_AddMessage(RaidWarningFrame, MESSAGE, ChatTypeInfo.RAID_WARNING)
			end

			self:RegisterEvent('UNIT_EXITED_VEHICLE')
			taming = true
		elseif taming and spellID == 356151 then
			-- Hold Tight
			ClearOverrideBindings(self)
		elseif taming and spellID == 356148 then
			-- this is cast whenever the wilderling gets a speedboost
			SetOverrideBinding(self, true, 'SPACE', BUTTON:format(1))
		end
	elseif event == 'UNIT_EXITED_VEHICLE' then
		-- just make sure we dont deadlock
		ClearOverrideBindings(self)

		-- and cleanup
		self:UnregisterEvent(event)
		taming = false
	end
end)

-- TODO: detect whenever we're done and exit the mount
