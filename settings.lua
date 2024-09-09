local addonName, addon = ...
local L = addon.L

local function formatPercentage(value)
	return PERCENTAGE_STRING:format(math.floor((value * 100) + 0.5))
end

local settings = {
	{
		key = 'mapScale',
		type = 'slider',
		title = L['Map pin scale'],
		tooltip = L['The scale of world quest pins on the current map'],
		default = 1.25,
		minValue = 0.1,
		maxValue = 3,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'parentScale',
		type = 'slider',
		title = L['Overview pin scale'],
		tooltip = L['The scale of world quest pins on a parent/continent map'],
		default = 1,
		minValue = 0.1,
		maxValue = 3,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'zoomFactor',
		type = 'slider',
		title = L['Pin size zoom factor'],
		tooltip = L['How much extra scale to apply when map is zoomed'],
		default = 0.5,
		minValue = 0,
		maxValue = 1,
		valueStep = 0.01,
		valueFormat = formatPercentage,
	},
	{
		key = 'showEvents',
		type = 'toggle',
		title = L['Show events on continent'],
		default = false,
	},
	{
		key = 'showAzeroth',
		type = 'toggle',
		title = L['Show on Azeroth'],
		default = false,
	},
	{
		key = 'hideModifier',
		type = 'menu',
		title = L['Hold key to hide'],
		tooltip = L['Hold this key to temporarily hide all world quests'],
		default = 'ALT',
		options = {
			NEVER = NEVER,
			ALT = ALT_KEY,
			CTRL = CTRL_KEY,
			SHIFT = SHIFT_KEY,
		},
	},
}

addon:RegisterSettings('BetterWorldQuestsDB', settings)
addon:RegisterSettingsSlash('/betterworldquests', '/bwq')

-- custom menu element for a slider
-- since the slider needs to be quite wide in order to be functional it's added to a sub-menu
local function createSlider(root, name, getter, setter, minValue, maxValue, steps, formatter)
	local element = root:CreateButton(name):CreateFrame()
	element:AddInitializer(function(frame)
		local slider = frame:AttachTemplate('MinimalSliderWithSteppersTemplate')
		slider:SetPoint('TOPLEFT', 0, -1)
		slider:SetSize(150, 25)
		slider:RegisterCallback('OnValueChanged', setter, frame)
		slider:Init(getter(), minValue, maxValue, (maxValue - minValue) / steps, {
			[MinimalSliderWithSteppersMixin.Label.Right] = formatter
		})

		-- there's no way to properly reset an element from the menu, so we'll need to use
		-- a dummy element we can hook OnHide onto, and also to increase the total width
		-- of the element so the right label doesn't go out of the bounds of the menu.
		-- see https://github.com/Stanzilla/WoWUIBugs/issues/652
		local dummy = frame:AttachFrame('Frame')
		dummy:SetPoint('TOPLEFT', slider)
		dummy:SetPoint('BOTTOMLEFT', slider)
		dummy:SetWidth(180)
		dummy:SetScript('OnHide', function()
			slider:UnregisterCallback('OnValueChanged', frame)
			slider:Release()
		end)
	end)

	return element
end

-- inject some of the settings into the tracking menu
Menu.ModifyMenu('MENU_WORLD_MAP_TRACKING', function(_, root)
	root:CreateDivider()
	root:CreateTitle((addonName:gsub('(%l)(%u)', '%1 %2')) .. HEADER_COLON)

	for _, setting in next, settings do
		if setting.type == 'toggle' then
			root:CreateCheckbox(setting.title, function()
				return addon:GetOption(setting.key)
			end, function()
				addon:SetOption(setting.key, not addon:GetOption(setting.key))
			end)
		elseif setting.type == 'slider' then
			createSlider(root, setting.title, function()
				return addon:GetOption(setting.key)
			end, function(_, value)
				addon:SetOption(setting.key, value)
			end, setting.minValue, setting.maxValue, setting.valueStep, setting.valueFormat)
		end
	end
end)
