local _, addon = ...
local L = addon.L

local function formatPercentage(value)
	return _G.PERCENTAGE_STRING:format(math.floor((value * 100) + 0.5))
end

addon:RegisterSettings('BetterWorldQuestsDB', {
	{
		key = 'mapScale',
		type = 'slider',
		title = L['Map pin scale'],
		tooltip = L['The scale of world quest pins on the current map'],
		default = 0.4,
		minValue = 0.1,
		maxValue = 1,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'parentScale',
		type = 'slider',
		title = L['Overview pin scale'],
		tooltip = L['The scale of world quest pins on a parent/continent map'],
		default = 0.3,
		minValue = 0.1,
		maxValue = 1,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'zoomFactor',
		type = 'slider',
		title = L['Pin size zoom factor'],
		tooltip = L['How much extra scale to apply when map is zoomed'],
		default = 0.1,
		minValue = 0,
		maxValue = 1,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
})

addon:RegisterSettingsSlash('/betterworldquests', '/bwq')
