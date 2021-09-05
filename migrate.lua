local name = ...

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('ADDON_LOADED')
Handler:SetScript('OnEvent', function(_, _, addon)
	if addon ~= name then
		return
	end

	if BetterWorldQuestsMigrate then
		return
	else
		BetterWorldQuestsMigrate = true
	end

	print('|cff90ffffBetterWorldQuests|r no longer has helpers for quests.')
	print('Please see the addon named "Quest Automation" on CurseForge/WoWInterface.')
	print('This message will not be shown again.')

	Handler:UnregisterEvent('ADDON_LOADED')
end)
