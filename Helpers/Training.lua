local L = select(2, ...).L

local MESSAGE = 'Stand in circle and spam <SpaceBar> to complete!'
local BUTTON = 'ACTIONBUTTON%d'

local actionMessages = {}
local actionResetSpells = {}
local quests = {
	[59585] = { -- We'll Make an Aspirant Out of You, Bastion
		trainer = L['Trainer Ikaros'],
		spells = {
			-- buffID = {actionSpellID = actionIndex}
			[321842] = {
				[321843] = 1, -- Strike
				[321844] = 2, -- Sweep
				[321847] = 3, -- Parry
			},
			[341925] = {
				[341931] = 1, -- Slash
				[341928] = 2, -- Bash
				[341929] = 3, -- Block
			},
			[341985] = {
				[342000] = 1, -- Jab
				[342001] = 2, -- Kick
				[342002] = 3, -- Dodge
			},
		}
	},
	[64271] = { -- A More Civilized Way, Korthia
		trainer = L['Nadjia the Mistblade'],
		spells = {
			-- buffID = {actionSpellID = actionIndex}
			[355677] = {
				[355834] = 1, -- Lunge
				[355835] = 2, -- Parry
				[355836] = 3, -- Riposte
			},
		}
	},
}

local function GetNPCIDByGUID(guid)
	return guid and (tonumber((string.match(guid, 'Creature%-.-%-.-%-.-%-.-%-(.-)%-')) or ''))
end

local function auraFilter(a, _, _, _, _, _, _, _, _, _, _, _, b)
	return a == b
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('QUEST_LOG_UPDATE')
Handler:RegisterEvent('QUEST_ACCEPTED')
Handler:SetScript('OnEvent', function(self, event, ...)
	if event == 'QUEST_LOG_UPDATE' then
		for questID, questData in next, quests do
			if C_QuestLog.IsOnQuest(questID) then
				self:Watch(questData)
				return
			end
		end

		self:Unwatch()
	elseif event == 'QUEST_ACCEPTED' then
		local _, questID = ...
		local questData = quests[questID]
		if questData then
			self:Watch(questData)
		end
	elseif(event == 'QUEST_REMOVED') then
		local questID = ...
		if quests[questID] then
			self:Unwatch()
		end
	elseif event == 'UNIT_AURA' then
		for buff, spellSet in next, self.questData.spells do
			if AuraUtil.FindAura(auraFilter, 'player', 'HELPFUL', buff) then
				self:Control(spellSet)
				return
			else
				self:Uncontrol()
			end
		end
	elseif event == 'CHAT_MSG_MONSTER_SAY' then
		local msg, sender = ...
		if self.questData.trainer == sender then
			local actionID
			for actionName, actionIndex in next, actionMessages do
				if (msg:gsub('%.', '')):match(actionName) then
					actionID = actionIndex
				end
			end

			if actionID then
				C_Timer.After(0.5, function()
					-- wait a split second to get "Perfect"
					ClearOverrideBindings(self)
					SetOverrideBinding(self, true, 'SPACE', BUTTON:format(actionID))
				end)
			end
		end
	elseif event == 'UNIT_SPELLCAST_SUCCEEDED' then
		local _, _, spellID = ...
		if actionResetSpells[spellID] then
			ClearOverrideBindings(self)

			-- bind to something useless to avoid spamming jump
			SetOverrideBinding(self, true, 'SPACE', BUTTON:format(4))
		end
	elseif(event == 'PLAYER_REGEN_ENABLED') then
		ClearOverrideBindings(self)
		self:UnregisterEvent(event)
	end
end)

function Handler:Watch(questData)
	self:RegisterUnitEvent('UNIT_AURA', 'player')
	self:RegisterEvent('QUEST_REMOVED')

	self.questData = questData
end

function Handler:Unwatch()
	self:UnregisterEvent('UNIT_AURA')
	self:UnregisterEvent('QUEST_REMOVED')
	self:Uncontrol()

	self.questData = nil
end

function Handler:Control(spellSet)
	table.wipe(actionMessages)
	table.wipe(actionResetSpells)
	for spellID, actionIndex in next, spellSet do
		actionMessages[(GetSpellInfo(spellID))] = actionIndex
		actionResetSpells[spellID] = true
	end

	-- bind to something useless to avoid spamming jump
	SetOverrideBinding(self, true, 'SPACE', BUTTON:format(4))

	self:Message()

	self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
	self:RegisterEvent('CHAT_MSG_MONSTER_SAY')
end

function Handler:Uncontrol()
	self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	self:UnregisterEvent('CHAT_MSG_MONSTER_SAY')

	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		ClearOverrideBindings(self)
	end
end

function Handler:Message()
	for i = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, MESSAGE, ChatTypeInfo.RAID_WARNING)
	end
end
