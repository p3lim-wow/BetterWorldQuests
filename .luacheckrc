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

globals = {
	-- exposed globals
	'BetterWorldQuestPinMixin',
}

read_globals = {
	-- FrameXML objects
	'AreaPOIDataProviderMixin',
	'AreaPOIEventDataProviderMixin',
	'WorldMap_WorldQuestDataProviderMixin',
	'WorldMap_WorldQuestPinMixin',
	'WorldMapFrame',
	'WorldQuestDataProviderMixin',

	-- FrameXML constants
	'WORLD_QUEST_ICONS_BY_PROFESSION',

	-- FrameXML functions
	'CreateFromMixins',
	'GetAreaPOIsForPlayerByMapIDCached',

	-- GlobalStrings
	'PERCENTAGE_STRING',
	'NEVER',
	'ALT_KEY',
	'CTRL_KEY',
	'SHIFT_KEY',

	-- namespaces
	'C_AreaPoiInfo',
	'C_Item',
	'C_Map',
	'C_QuestLog',
	'C_Reputation',
	'C_TaskQuest',
	'Enum',

	-- API
	'CreateFrame',
	'GetNumQuestLogRewards',
	'GetQuestLogRewardInfo',
	'GetQuestLogRewardMoney',
	'IsAltKeyDown',
	'IsControlKeyDown',
	'IsShiftKeyDown',
	'UnitFactionGroup',
	'hooksecurefunc',

	-- exposed from other addons
	'LibStub',
}
