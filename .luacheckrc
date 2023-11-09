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
	-- savedvariables
	'BetterWorldQuestsMigrate',

	-- exposed globals
	'BetterWorldQuestPinMixin',
}

read_globals = {
	-- FrameXML objects
	'WorldMapFrame', -- AddOns/Blizzard_WorldMap/Blizzard_WorldMap.xml
	'WorldMap_WorldQuestPinMixin', -- AddOns/Blizzard_WorldMap/WM_WorldQuestDataProvider.lua
	'WorldQuestDataProviderMixin', -- AddOns/Blizzard_SharedMapDataProviders/WorldQuestDataProvider.lua
	'WorldQuestPinMixin', -- AddOns/Blizzard_SharedMapDataProviders/WorldQuestDataProvider.lua

	-- FrameXML constants
	'WORLD_QUEST_ICONS_BY_PROFESSION', -- FrameXML/Constants.lua

	-- SharedXML functions
	'CreateFromMixins', -- SharedXML/Mixin.lua

	-- namespaces
	'Enum',
	'C_AreaPoiInfo',
	'C_CVar',
	'C_QuestLog',
	'C_TaskQuest',
	'C_Item',

	-- API
	'hooksecurefunc',
	'CreateFrame',
	'HaveQuestData',
	'UnitFactionGroup',
	'GetQuestLogRewardInfo',
	'GetNumQuestLogRewards',
	'GetNumQuestLogRewardCurrencies',
	'GetQuestLogRewardCurrencyInfo',
	'GetQuestLogRewardMoney',
	'SetPortraitToTexture',
	'IsAltKeyDown',

	-- exposed from other addons
	'LibStub',
}
