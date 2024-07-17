std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'631', -- line is too long
}

exclude_files = {}

globals = {
	-- exposed globals
	'BetterWorldQuestPinMixin',
}

read_globals = {
	-- FrameXML objects
	'WorldMap_WorldQuestPinMixin',
	'WorldMapFrame',
	'WorldMapPOIQuantizerMixin',
	'WorldQuestDataProviderMixin',
	'WorldQuestPinMixin',

	-- FrameXML constants
	'WORLD_QUEST_ICONS_BY_PROFESSION',

	-- FrameXML functions
	'CreateFromMixins',
	'GetQuestsForPlayerByMapIDCached',
	'MapUtil',
	'QuestUtils_IsQuestWorldQuest',

	-- namespaces
	'C_AreaPoiInfo',
	'C_CVar',
	'C_Item',
	'C_QuestLog',
	'C_Reputation',
	'C_TaskQuest',
	'Enum',

	-- API
	'GetNumQuestLogRewardCurrencies',
	'GetNumQuestLogRewards',
	'GetQuestLogRewardCurrencyInfo',
	'GetQuestLogRewardInfo',
	'GetQuestLogRewardMoney',
	'HaveQuestData',
	'IsAltKeyDown',
	'UnitFactionGroup',
	'hooksecurefunc',

	-- exposed from other addons
	'LibStub',
}
