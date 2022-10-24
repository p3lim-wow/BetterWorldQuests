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
}

read_globals = {
	-- FrameXML objects
	'AreaLabelFrameMixin', -- AddOns/Blizzard_SharedMapDataProviders/AreaLabelDataProvider.lua
	'MapCanvasDataProviderMixin', -- AddOns/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua
	'MapCanvasMixin', -- AddOns/Blizzard_MapCanvas/Blizzard_MapCanvas.lua
	'WorldMapFrame', -- AddOns/Blizzard_WorldMap/Blizzard_WorldMap.xml
	'WorldMap_WorldQuestPinMixin', -- AddOns/Blizzard_WorldMap/WM_WorldQuestDataProvider.lua
	'WorldQuestDataProviderMixin', -- AddOns/Blizzard_SharedMapDataProviders/WorldQuestDataProvider.lua
	'WorldQuestPinMixin', -- AddOns/Blizzard_SharedMapDataProviders/WorldQuestDataProvider.lua

	-- FrameXML functions
	'GetRelativeDifficultyColor', -- FrameXML/UIParent.lua
	'ConvertRGBtoColorString', -- FrameXML/UIParent.lua
	'QuestUtils_IsQuestWorldQuest', -- FrameXML/QuestUtils.lua

	-- FrameXML constants
	'MAP_AREA_LABEL_TYPE', -- AddOns/Blizzard_SharedMapDataProviders/AreaLabelDataProvider.lua
	'QuestDifficultyColors', -- FrameXML/Constants.lua
	'WORLD_QUEST_ICONS_BY_PROFESSION', -- FrameXML/Constants.lua

	-- SharedXML objects
	'FONT_COLOR_CODE_CLOSE', -- SharedXML/SharedColorConstants.lua

	-- SharedXML functions
	'CreateFromMixins', -- SharedXML/Mixin.lua
	'CreateVector2D', -- SharedXML/Vector2D.lua

	-- GlobalStrings
	'WORLD_MAP_WILDBATTLEPET_LEVEL',

	-- namespaces
	'Enum',
	'C_AreaPoiInfo',
	'C_Map',
	'C_PetJournal',
	'C_QuestLog',
	'C_TaskQuest',

	-- API
	'hooksecurefunc',
	'CreateFrame',
	'GetCVarBool',
	'HaveQuestData',
	'UnitFactionGroup',
	'GetQuestLogRewardInfo',
	'GetNumQuestLogRewards',
	'GetNumQuestLogRewardCurrencies',
	'GetQuestLogRewardCurrencyInfo',
	'GetQuestLogRewardMoney',
	'SetPortraitToTexture',
}
