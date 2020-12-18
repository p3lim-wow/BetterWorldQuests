local Handler = CreateFrame('Frame')
Handler:RegisterEvent('QUEST_LOG_UPDATE')
Handler:RegisterEvent('QUEST_ACCEPTED')
Handler:SetScript('OnEvent', function(self, event, ...)
	if event == 'QUEST_LOG_UPDATE' then
		if C_QuestLog.IsOnQuest(60739) then
			self:Watch()
		end
	elseif event == 'QUEST_ACCEPTED' then
		local _, questID = ...
		if questID == 60739 then
			self:Watch()
		end
	elseif event == 'QUEST_REMOVED' then
		local questID = ...
		if(questID == 60739) then
			self:Unwatch()
		end
	elseif event == 'UPDATE_MOUSEOVER_UNIT' then
		local unitGUID = UnitGUID('mouseover')
		if unitGUID then
			local mouseNPC = tonumber((string.match(unitGUID, 'Creature%-.-%-.-%-.-%-.-%-(.-)%-')))
			if mouseNPC == 170080 and GetRaidTargetIndex('mouseover') ~= 8 then
				SetRaidTarget('mouseover', 8)
			end
		end
	end
end)

function Handler:Watch()
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:RegisterEvent('QUEST_REMOVED')
end

function Handler:Unwatch()
	self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:UnregisterEvent('QUEST_REMOVED')
end
