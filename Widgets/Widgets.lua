local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- skin
-----------------------------------------
function GRA:StylizeFrame(frame, color, border, shadowOffset)
	if not color or type(color) ~= "table" then
		color = {.1, .1, .1, .9}
	end
	
	if not border or type(border) ~= "table" then
		border = {0, 0, 0, 1}
	end

	frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    frame:SetBackdropColor(unpack(color))
	frame:SetBackdropBorderColor(unpack(border))

	if shadowOffset then -- frame shadow
		local shadow = CreateFrame("Frame", nil, frame)
		shadow:SetBackdrop({edgeFile = "Interface\\Addons\\GuildRaidAttendance\\Media\\shadow.tga", edgeSize = 15})
		shadow:SetBackdropBorderColor(0, 0, 0, .5)
		shadow:SetPoint("TOP", 0, shadowOffset[1])
		shadow:SetPoint("BOTTOM", 0, shadowOffset[2])
		shadow:SetPoint("LEFT", shadowOffset[3], 0)
		shadow:SetPoint("RIGHT", shadowOffset[4], 0)
		shadow:SetFrameStrata("LOW")
	end
end

-----------------------------------------
-- frame
-----------------------------------------
function GRA:CreateFrame(title, name, parent, width, height)
	local f = CreateFrame("Frame", name, parent)
	f:Hide()
	GRA:StylizeFrame(f, nil, nil, {32, -11, -11, 11})
	f:EnableMouse(true)
	f:SetSize(width, height)

	f.header = CreateFrame("Frame", nil, f)
	f.header:EnableMouse(true)
	GRA:StylizeFrame(f.header, {.1, .1, .1, 1})
	f.header:SetPoint("TOPLEFT", f, 0, 21)
	f.header:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -1)

	f.header.text = f.header:CreateFontString(nil, "OVERLAY", "GRA_FONT_NORMAL")
	f.header.text:SetText(title)
	f.header.text:SetPoint("CENTER", f.header)

	f.header.closeBtn = GRA:CreateButton(f.header, "×", "red", {16, 16}, "GRA_FONT_BUTTON")
	f.header.closeBtn:SetPoint("RIGHT", f.header, -4, 0)
	f.header.closeBtn:SetScript("OnClick", function() f:Hide() end)

	return f
end

function GRA:CreateMovableFrame(title, name, width, height, font, frameStrata, frameLevel)
	local f = CreateFrame("Frame", name)
	f:EnableMouse(true)
	-- f:SetResizable(false)
	f:SetMovable(true)
	f:SetUserPlaced(true)
	f:SetFrameStrata(frameStrata or "HIGH")
	f:SetFrameLevel(frameLevel or 1)
	f:SetClampedToScreen(true)
	f:SetSize(width, height)
	f:SetPoint("CENTER")
	f:Hide()
	LPP:PixelPerfectScale(f)
	GRA:StylizeFrame(f, nil, nil, {31, -10, -10, 10})
	-- table.insert(UISpecialFrames, name) -- make it closable with the Escape key
	
	-- header
	local header = CreateFrame("Frame", nil, f)
	f.header = header
	header:EnableMouse(true)
	header:SetClampedToScreen(true)
	header:RegisterForDrag("LeftButton")
	header:SetScript("OnDragStart", function() f:StartMoving() end)
	header:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
	header:SetPoint("LEFT")
	header:SetPoint("RIGHT")
	header:SetPoint("BOTTOM", f, "TOP", 0, -1)
	header:SetHeight(22)
	-- header:SetPoint("TOPLEFT", f, 0, 21)
	-- header:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -1)
	GRA:StylizeFrame(header, {.1, .1, .1, 1})
	
	header.text = header:CreateFontString(nil, "OVERLAY", font or "GRA_FONT_NORMAL")
	header.text:SetText(title)
	header.text:SetPoint("CENTER", header)
	
	header.closeBtn = GRA:CreateButton(header, "×", "red", {16, 16}, "GRA_FONT_BUTTON")
	header.closeBtn:SetPoint("RIGHT", header, -4, 0)
	header.closeBtn:SetScript("OnClick", function() f:Hide() end)

	return f
end

-----------------------------------------
-- SetTooltip
-----------------------------------------
local function SetTooltip(widget, x, y, tipText1, tipText2, tipText3, tipText4, tipText5)
	if tipText1 then
		widget:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_TOPLEFT", x or 0, y or 0)
			GRA_Tooltip:AddLine(tipText1)
			if tipText2 then GRA_Tooltip:AddLine("|cffffffff" .. tipText2) end
			if tipText3 then GRA_Tooltip:AddLine("|cffffffff" .. tipText3) end
			if tipText4 then GRA_Tooltip:AddLine("|cffffffff" .. tipText4) end
			if tipText5 then GRA_Tooltip:AddLine("|cffffffff" .. tipText5) end
			GRA_Tooltip:Show()
		end)
		widget:HookScript("OnLeave", function(self)
			GRA_Tooltip:Hide()
		end)
	end
end

-----------------------------------------
-- editbox 2017-06-21 10:19:33
-----------------------------------------
function GRA:CreateEditBox(parent, width, height, isNumeric, font)
	if not font then font = "GRA_FONT_TEXT" end

	local eb = CreateFrame("EditBox", nil, parent)
	GRA:StylizeFrame(eb, {.1, .1, .1, .9})
	eb:SetFontObject(font)
	eb:SetMultiLine(false)
	eb:SetMaxLetters(0)
	eb:SetJustifyH("LEFT")
	eb:SetJustifyV("CENTER")
	eb:SetWidth(width)
	eb:SetHeight(height)
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetAutoFocus(false)
	eb:SetNumeric(isNumeric)
	eb:SetScript("OnEscapePressed", function() eb:ClearFocus() end)
	eb:SetScript("OnEnterPressed", function() eb:ClearFocus() end)
	eb:SetScript("OnEditFocusGained", function() eb:HighlightText() end)
	eb:SetScript("OnEditFocusLost", function() eb:HighlightText(0, 0) end)
	eb:SetScript("OnDisable", function() eb:SetTextColor(.7, .7, .7, 1) end)
	eb:SetScript("OnEnable", function() eb:SetTextColor(1, 1, 1, 1) end)

	return eb
end

-----------------------------------------
-- button
-----------------------------------------
function GRA:CreateButton(parent, text, buttonColor, size, font, noBorder, ...)
	if not font then font = "GRA_FONT_SMALL" end

	local b = CreateFrame("Button", nil, parent)
	if parent then b:SetFrameLevel(parent:GetFrameLevel()+1) end
	b:SetText(text)
	b:SetSize(unpack(size))
	
	local color, hoverColor
	if buttonColor == "red" then
		color = {.6, .1, .1, .6}
		hoverColor = {.6, .1, .1, 1}
	elseif buttonColor == "green" then
		color = {.1, .6, .1, .6}
		hoverColor = {.1, .6, .1, 1}
	elseif buttonColor == "cyan" then
		color = {0, .9, .9, .6}
		hoverColor = {0, .9, .9, 1}
	elseif buttonColor == "blue" then
		color = {0, .5, .8, .6}
		hoverColor = {0, .5, .8, 1}
	elseif buttonColor == "blue-hover" then
		color = {.1, .1, .1, 1}
		hoverColor = {0, .5, .8, 1}
	elseif buttonColor == "yellow" then
		color = {.7, .7, 0, .6}
		hoverColor = {.7, .7, 0, 1}
	elseif buttonColor == "chartreuse" then
		color = {.5, 1, 0, .6}
		hoverColor = {.5, 1, 0, .8}
	elseif buttonColor == "magenta" then
		color = {.6, .1, .6, .6}
		hoverColor = {.6, .1, .6, 1}
	elseif buttonColor == "transparent" then -- drop down item
		color = {0, 0, 0, 0}
		hoverColor = {.5, 1, 0, .7}
	elseif buttonColor == "transparent-white" then -- drop down item
		color = {0, 0, 0, 0}
		hoverColor = {.4, .4, .4, .7}
	elseif buttonColor == "transparent-light" then -- list button
		color = {0, 0, 0, 0}
		hoverColor = {.5, 1, 0, .5}
	elseif buttonColor == "Credit" then
		color = {.1, .6, .95, .4}
		hoverColor = {.1, .6, .95, .65}
	elseif buttonColor == "Award" then
		color = {.1, .95, .2, .4}
		hoverColor = {.1, .95, .2, .65}
	elseif buttonColor == "Penalize" then
		color = {.95, .17, .2, .4}
		hoverColor = {.95, .17, .2, .65}
	elseif buttonColor == "none" then
		color = {0, 0, 0, 0}
	else
		color = {.1, .1, .1, .7}
		hoverColor = {.5, 1, 0, .6}
	end

	-- keep color & hoverColor
	b.color = color
	b.hoverColor = hoverColor

	local s = b:GetFontString()
	if s then
		s:SetWordWrap(false)
		-- s:SetWidth(size[1])
		s:SetPoint("LEFT")
		s:SetPoint("RIGHT")
	end
	
	if noBorder then
		b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
	else
		b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	end
	
	if buttonColor and string.find(buttonColor, "transparent") then -- drop down item
		-- b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
		if s then
			s:SetJustifyH("LEFT")
			s:SetPoint("LEFT", 5, 0)
			s:SetPoint("RIGHT", -5, 0)
		end
		b:SetBackdropBorderColor(1, 1, 1, 0)
		b:SetPushedTextOffset(0, 0)
	else
    	b:SetBackdropBorderColor(0, 0, 0, 1)
		b:SetPushedTextOffset(0, -1)
	end


	b:SetBackdropColor(unpack(color)) 
	b:SetDisabledFontObject("GRA_FONT_SMALL_DISABLED")
    b:SetNormalFontObject(font)
	b:SetHighlightFontObject(font)
	
	if buttonColor ~= "none" then
		b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(hoverColor)) end)
		b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(color)) end)
	end
	
	-- click sound
	b:SetScript("PostClick", function() PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON) end)

	SetTooltip(b, 0, 1, ...)

	return b
end

-----------------------------------------
-- square item button
-----------------------------------------
function GRA:CreateIconButton(parent, width, height, texture)
	local b = CreateFrame("Button", nil, parent)
    b:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
    b:SetBackdropBorderColor(0, 0, 0, 1)
	b:SetSize(width, height)

    b.tex = b:CreateTexture()
    b.tex:SetTexCoord(.08, .92, .08, .92)
    b.tex:SetSize(width - 2, height - 2)
    b.tex:SetPoint("CENTER")
	if texture then
		b.tex:SetTexture(texture)
	end
	
	function b:SetIcon(texture)
		b.tex:SetTexture(texture)
	end
	
	return b
end

-----------------------------------------
-- check button
-----------------------------------------
function GRA:CreateCheckButton(parent, label, color, onClick, font, ...)
	-- InterfaceOptionsCheckButtonTemplate --> FrameXML\InterfaceOptionsPanels.xml line 19
	-- OptionsBaseCheckButtonTemplate -->  FrameXML\OptionsPanelTemplates.xml line 10
	
	local cb = CreateFrame("CheckButton", nil, parent)
	cb.onClick = onClick
	cb:SetScript("OnClick", function(self)
		PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		if cb.onClick then cb.onClick(self:GetChecked() and true or false, self) end
	end)
	
	if font then
		cb.label = cb:CreateFontString(nil, "ARTWORK", font)
	else
		cb.label = cb:CreateFontString(nil, "ARTWORK", "GRA_FONT_TEXT")
	end
	cb.label:SetText(label)
	cb.label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
	if color then
		cb.label:SetTextColor(color.r, color.g, color.b)
	end
	
	cb:SetSize(16, 16)
	cb:SetHitRectInsets(0, -cb.label:GetStringWidth(), 0, 0)
	
	cb:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox\CheckBox-Normal-16x16]])
	-- cb:SetPushedTexture()
	cb:SetHighlightTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox\CheckBox-Highlight-16x16]], "ADD")
	cb:SetCheckedTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox\CheckBox-Checked-16x16]])
	cb:SetDisabledCheckedTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox\CheckBox-DisabledChecked-16x16]])
	
	SetTooltip(cb, 0, 0, ...)

	return cb
end

-----------------------------------------
-- slider 2017-06-12 10:37:48
-----------------------------------------
-- Interface\FrameXML\OptionsPanelTemplates.xml, line 76, OptionsSliderTemplate
function GRA:CreateSlider(parent, unit, low, high, length, step, onValueChangedFn, afterValueChangedFn, orientation)
    if not step then step = 1 end
	if not orientation then orientation = "HORIZONTAL" end
    local slider = CreateFrame("Slider", nil, parent)
	GRA:StylizeFrame(slider)
    slider:SetMinMaxValues(low, high)
	slider:SetValue(low)
    slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(true)
	slider:SetOrientation(orientation)

	if unit and orientation == "HORIZONTAL" then
		slider.text = slider:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
		slider.text:SetText(slider:GetValue() .. " " .. unit)
		slider.text:SetPoint("LEFT", slider, "RIGHT", 5, 0)
	end

	if orientation == "VERTICAL" then
		slider:SetSize(6, length)
		slider:SetThumbTexture([[Interface\AddOns\GuildRaidAttendance\Media\ThumbTextureV]])
	else
		slider:SetSize(length, 6)
		slider:SetThumbTexture([[Interface\AddOns\GuildRaidAttendance\Media\ThumbTextureH]])
	end
	
    -- if tooltip then slider.tooltipText = tooltip end

    slider:SetScript("OnValueChanged", function(self, value)
		if unit and orientation == "HORIZONTAL" then slider.text:SetText(value .. " " .. unit) end
        if onValueChangedFn then onValueChangedFn(value) end
	end)
	
	slider:SetScript("OnMouseUp", function(self, button)
		if afterValueChangedFn then afterValueChangedFn(slider:GetValue()) end
	end)
	
	return slider
end

-----------------------------------------
-- Date Picker
-----------------------------------------
function GRA:CreateDatePicker(parent, width, height, onDateChanged, color)
	local datePicker = GRA:CreateButton(parent, "Date Picker", color, {width, height}, "GRA_FONT_GRID")
	
	local yearSet, monthSet, daySet, year, month, numDays, firstWeekday
	
	function datePicker:SetDate(d)
		local t, tbl = GRA:DateToTime(d)
		datePicker:SetText(date("%x", t))
		monthSet, yearSet, numDays, firstWeekday = CalendarGetAbsMonth(tbl.month, tbl.year)
		daySet = tbl.day
		year = yearSet
		month = monthSet
	end

	function datePicker:GetDate()
		return yearSet..string.format("%02d", monthSet)..string.format("%02d", daySet)
	end

	-- self init
	datePicker:SetDate(GRA:Date())

	local calendar = CreateFrame("Frame", nil, parent)
	calendar:Hide()
	calendar:EnableMouse(true)
	calendar:SetSize(190, 155)
	calendar:SetFrameStrata("DIALOG")
	calendar:SetPoint("BOTTOM", datePicker, "TOP", 0, 1)
	GRA:StylizeFrame(calendar)

	-- year month selector
	local pMonth = GRA:CreateButton(calendar, "<", nil, {28, 20}, "GRA_FONT_GRID")
	local dateFS = calendar:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	local nMonth = GRA:CreateButton(calendar, ">", nil, {28, 20}, "GRA_FONT_GRID")
	pMonth:SetPoint("TOPLEFT")
	nMonth:SetPoint("TOPRIGHT")
	dateFS:SetPoint("LEFT", pMonth, "RIGHT")
	dateFS:SetPoint("RIGHT", nMonth, "LEFT")

	-- header
	local last = nil
	local headers = {}
	for i = 1, 7 do
		local w = {L["Sun"], L["Mon"], L["Tue"], L["Wed"], L["Thu"], L["Fri"], L["Sat"]}
		local s = calendar:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
		table.insert(headers, s)
		s:SetText(w[i])
		s:SetWidth(28)

		if last then
			s:SetPoint("LEFT", last, "RIGHT", -1, 0)
		else
			s:SetPoint("TOPLEFT", 0, -25)
		end
		last = s
	end

	local dateBtns = {}
	for i = 1, 42 do
		dateBtns[i] = GRA:CreateButton(calendar, "", nil, {28, 20}, "GRA_FONT_GRID")
		dateBtns[i]:SetScript("OnClick", function(self)
			calendar:Hide()
			-- date string 20170728
			local d = year..string.format("%02d", month)..string.format("%02d", self:GetText())
			-- set selected (highlight)
			datePicker:SetDate(d)
			if onDateChanged then onDateChanged(d) end
		end)

		if i == 1 then
			dateBtns[i]:SetPoint("TOPLEFT", 0, -40)
		elseif i % 7 == 1 then
			-- local y = -(math.modf(i / 7) * 19) - 40
			-- dateBtns[i]:SetPoint("TOPLEFT", 0, y)
			dateBtns[i]:SetPoint("TOP", dateBtns[i - 7], "BOTTOM", 0, 1)
		else
			dateBtns[i]:SetPoint("LEFT", dateBtns[i - 1], "RIGHT", -1, 0)
		end
	end

	local function FillCalendar()
		dateFS:SetText(({CalendarGetMonthNames()})[month] .. ", " .. year)

		local d = 1
		for i = 1, 42 do
			if i < firstWeekday or i >= firstWeekday + numDays then
				dateBtns[i]:SetEnabled(false)
				dateBtns[i]:SetText("")
			else
				dateBtns[i]:SetEnabled(true)
				dateBtns[i]:SetText(d)
				-- highlight selected
				if yearSet == year and monthSet == month and daySet == d then
					dateBtns[i]:GetFontString():SetTextColor(1, .12, .12)
				else
					dateBtns[i]:GetFontString():SetTextColor(1, 1, 1)
				end
				d = d + 1
			end
		end
	end

	calendar:SetScript("OnShow", function()
		FillCalendar()
	end)

	-- previous month
	pMonth:SetScript("OnClick", function()
		month = month - 1
		if month == 0 then
			year = year - 1
			month = 12
		end
		month, year, numDays, firstWeekday = CalendarGetAbsMonth(month, year)
		FillCalendar()
	end)

	-- next month
	nMonth:SetScript("OnClick", function()
		month = month + 1
		if month == 13 then
			year = year + 1
			month = 1
		end
		month, year, numDays, firstWeekday = CalendarGetAbsMonth(month, year)
		FillCalendar()
	end)

	datePicker:SetScript("OnClick", function()
		if calendar:IsVisible() then
			calendar:Hide()
		else
			calendar:Show()
		end
	end)

	datePicker:SetScript("OnHide", function() calendar:Hide() end)

	function datePicker:Resize(cWidth, cHeight, bWidth, bHeight)
		calendar:SetSize(cWidth, cHeight)
		pMonth:SetSize(bWidth, bHeight)
		nMonth:SetSize(bWidth, bHeight)
		headers[1]:SetPoint("TOPLEFT", 0, -25-(gra.size.height-20))
		for _, s in pairs(headers) do
			s:SetWidth(bWidth)
		end
		for _, b in pairs(dateBtns) do
			b:SetSize(bWidth, bHeight)
		end
		dateBtns[1]:SetPoint("TOPLEFT", 0, -40-(gra.size.height-20))
	end

	return datePicker
end

-----------------------------------------
-- attendance sheet frame 2017-07-28 11:48:11
-----------------------------------------
function GRA:CreateGrid(frame, width, text, color, highlight, ...)
	local grid = CreateFrame("Button", nil, frame)
	grid:SetSize(width, gra.size.height)
	grid:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	if color then
		grid:SetBackdropColor(unpack(color))
	else
		grid:SetBackdropColor(0, 0, 0, 0)
	end
	grid:SetBackdropBorderColor(0, 0, 0, 0)

	grid:SetText(text)
	grid:GetFontString():SetWidth(width)
	if not string.find(text, "\n") then
		grid:GetFontString():SetWordWrap(false)
	end
	grid:SetPushedTextOffset(0, 0)
	grid:SetNormalFontObject("GRA_FONT_SMALL")

	function grid:Highlight()
		-- save current color
		grid.bColor = {grid:GetBackdropColor()} 
		grid:SetBackdropColor(grid.bColor[1], grid.bColor[2], grid.bColor[3], .6)
	end
		
	function grid:Unhighlight()
		grid:SetBackdropColor(unpack(grid.bColor))
	end

	if highlight then -- highlight onMouseOver
		grid:SetScript("OnEnter", function() 
			grid:Highlight()
		end)
		grid:SetScript("OnLeave", function() grid:Unhighlight() end)
	end

	if frame:GetObjectType() == "Button" then -- used for row highlight
		grid:SetFrameLevel(6)
		grid:HookScript("OnEnter", function() frame:SetBackdropColor(.5, .5, .5, .1) end)
		grid:HookScript("OnLeave", function() frame:SetBackdropColor(0, 0, 0, 0) end)

		function grid:SetAttendance(att)
			if att == nil then
				grid:SetBackdropColor(.7, .7, .7, .1)
			elseif att == "PRESENT" then
				grid:SetBackdropColor(0, 1, 0, .2)
			elseif att == "LATE" then
				grid:SetBackdropColor(1, 1, 0, .2)
			elseif att == "ABSENT" then
				grid:SetBackdropColor(1, 0, 0, .2)
			else  -- on leave
				grid:SetBackdropColor(1, 0, 1, .2)
			end
		end
	end

	-- grid.onEnter = grid:GetScript("OnEnter")
	-- grid.onLeave = grid:GetScript("OnLeave")

	SetTooltip(grid, 0, 0, ...)

	return grid
end

function GRA:CreateRow(frame, width, mainName, onDoubleClick)
	local row = CreateFrame("Button", nil, frame)
	row:SetFrameLevel(5)
	row:SetSize(width, gra.size.height)
	row:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	row:SetBackdropColor(0, 0, 0, 0) 
    row:SetBackdropBorderColor(0, 0, 0, 1)
	
	row.nameGrid = GRA:CreateGrid(row, gra.size.grid_name, GRA:GetClassColoredName(mainName), {.7,.7,.7,.1})
	row.nameGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.nameGrid:GetFontString():ClearAllPoints()
	row.nameGrid:GetFontString():SetPoint("LEFT", 20, 0)
	row.nameGrid:SetNormalFontObject("GRA_FONT_TEXT")
	row.nameGrid:SetPoint("TOPLEFT")
	row.nameGrid:SetScript("OnDoubleClick", function(self, button)
		if button == "LeftButton" and onDoubleClick then
			onDoubleClick()
		end
	end)

	row.primaryRole = GRA:CreateButton(row.nameGrid, "", "none", {16, 16})
	row.primaryRole:SetAlpha(.7)
	row.primaryRole:SetPoint("LEFT", 2, 0)
	row.primaryRole:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .1) end)
	row.primaryRole:SetScript("OnLeave", function() row:SetBackdropColor(0, 0, 0, 0) end)
	row.primaryRole:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\Roles\]] .. (_G[GRA_R_Roster][mainName]["role"] or "DPS"))

	-- ep
	row.epGrid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1})
	row.epGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.epGrid:SetNormalFontObject("GRA_FONT_GRID")

	-- gp
	row.gpGrid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1})
	row.gpGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.gpGrid:SetNormalFontObject("GRA_FONT_GRID")

	-- pr
	row.prGrid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1})
	row.prGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.prGrid:SetNormalFontObject("GRA_FONT_GRID")

	-- current
	row.currentGrid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1})
	row.currentGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.currentGrid:SetNormalFontObject("GRA_FONT_GRID")

	-- spent
	row.spentGrid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1})
	row.spentGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.spentGrid:SetNormalFontObject("GRA_FONT_GRID")

	-- total
	row.totalGrid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1})
	row.totalGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.totalGrid:SetNormalFontObject("GRA_FONT_GRID")
	
	-- ar 30
	row.ar30Grid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1}, true)
	row.ar30Grid:SetBackdropBorderColor(0, 0, 0, 1)
	row.ar30Grid:SetNormalFontObject("GRA_FONT_GRID")

	-- ar 60
	row.ar60Grid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1}, true)
	row.ar60Grid:SetBackdropBorderColor(0, 0, 0, 1)
	row.ar60Grid:SetNormalFontObject("GRA_FONT_GRID")

	-- ar 90
	row.ar90Grid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1}, true)
	row.ar90Grid:SetBackdropBorderColor(0, 0, 0, 1)
	row.ar90Grid:SetNormalFontObject("GRA_FONT_GRID")

	-- ar lifetime
	row.arLifetimeGrid = GRA:CreateGrid(row, gra.size.grid_others, " ", {.7,.7,.7,.1}, true)
	row.arLifetimeGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.arLifetimeGrid:SetNormalFontObject("GRA_FONT_GRID")

	-- columns: EP GP PR AR(30d) AR(60d) AR(90d) AR(lifetime)
	local lastColumn
	function row:SetColumns()
		lastColumn = row.nameGrid
		if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
			row.epGrid:SetPoint("TOPLEFT", row.nameGrid, "TOPRIGHT", -1, 0)
			row.epGrid:Show()
			row.gpGrid:SetPoint("TOPLEFT", row.epGrid, "TOPRIGHT", -1, 0)
			row.gpGrid:Show()
			row.prGrid:SetPoint("TOPLEFT", row.gpGrid, "TOPRIGHT", -1, 0)
			row.prGrid:Show()
			lastColumn = row.prGrid

			row.currentGrid:Hide()
			row.spentGrid:Hide()
			row.totalGrid:Hide()
		elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
			row.currentGrid:SetPoint("TOPLEFT", row.nameGrid, "TOPRIGHT", -1, 0)
			row.currentGrid:Show()
			row.spentGrid:SetPoint("TOPLEFT", row.currentGrid, "TOPRIGHT", -1, 0)
			row.spentGrid:Show()
			row.totalGrid:SetPoint("TOPLEFT", row.spentGrid, "TOPRIGHT", -1, 0)
			row.totalGrid:Show()
			lastColumn = row.totalGrid

			row.epGrid:Hide()
			row.gpGrid:Hide()
			row.prGrid:Hide()
		else
			row.epGrid:Hide()
			row.gpGrid:Hide()
			row.prGrid:Hide()
			row.currentGrid:Hide()
			row.spentGrid:Hide()
			row.totalGrid:Hide()
		end

		if GRA_Variables["columns"]["AR_30"] then
			row.ar30Grid:SetPoint("TOPLEFT", lastColumn, "TOPRIGHT", -1, 0)
			row.ar30Grid:Show()
			lastColumn = row.ar30Grid
		else
			row.ar30Grid:Hide()
		end

		if GRA_Variables["columns"]["AR_60"] then
			row.ar60Grid:SetPoint("TOPLEFT", lastColumn, "TOPRIGHT", -1, 0)
			row.ar60Grid:Show()
			lastColumn = row.ar60Grid
		else
			row.ar60Grid:Hide()
		end

		if GRA_Variables["columns"]["AR_90"] then
			row.ar90Grid:SetPoint("TOPLEFT", lastColumn, "TOPRIGHT", -1, 0)
			row.ar90Grid:Show()
			lastColumn = row.ar90Grid
		else
			row.ar90Grid:Hide()
		end

		if GRA_Variables["columns"]["AR_Lifetime"] then
			row.arLifetimeGrid:SetPoint("TOPLEFT", lastColumn, "TOPRIGHT", -1, 0)
			row.arLifetimeGrid:Show()
			lastColumn = row.arLifetimeGrid
		else
			row.arLifetimeGrid:Hide()
		end

		if row.dateGrids[1] then -- dateGrids created
			row.dateGrids[1]:SetPoint("TOPLEFT", lastColumn, "TOPRIGHT", -1, 0)
		end
	end
	
	row.dateGrids = {}
	row:SetColumns()
	function row:CreateGrid(n)
		for i = 1, n do
			local grid = GRA:CreateGrid(row, gra.size.grid_dates, " ", {.7,.7,.7,.1}, true)
			if i == 1 then
				grid:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
			else
				grid:SetPoint("LEFT", row.dateGrids[i-1], "RIGHT", -1, 0)
			end
			grid:SetBackdropBorderColor(0, 0, 0, 1)
			grid:SetNormalFontObject("GRA_FONT_GRID")
			table.insert(row.dateGrids, grid)
		end
	end
	
	row:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, .5, .5, .1) end)
	row:SetScript("OnLeave", function(self) self:SetBackdropColor(0, 0, 0, 0) end)

	function row:AddAlt(altName)
		if not row.alts then row.alts = {} end
		row.alts[altName] = {}
		row.alts[altName].dateGrids = {}

		local altsNum = GRA:Getn(row.alts)
		local height = (altsNum + 1) * gra.size.height - altsNum
		row:SetHeight(height)
		row.epGrid:SetHeight(height)
		row.gpGrid:SetHeight(height)
		row.prGrid:SetHeight(height)
		row.currentGrid:SetHeight(height)
		row.spentGrid:SetHeight(height)
		row.totalGrid:SetHeight(height)
		row.ar30Grid:SetHeight(height)
		row.ar60Grid:SetHeight(height)
		row.ar90Grid:SetHeight(height)
		row.arLifetimeGrid:SetHeight(height)
		
		-- nameGrid
		row.alts[altName].nameGrid = GRA:CreateGrid(row, gra.size.grid_name, GRA:GetClassColoredName(altName), {.7,.7,.7,.1})
		row.alts[altName].nameGrid:SetBackdropBorderColor(0, 0, 0, 1)
		row.alts[altName].nameGrid:GetFontString():ClearAllPoints()
		row.alts[altName].nameGrid:GetFontString():SetPoint("LEFT", 20, 0)
		row.alts[altName].nameGrid:SetNormalFontObject("GRA_FONT_TEXT")
		row.alts[altName].nameGrid:SetPoint("TOP", row.nameGrid, 0, - altsNum * gra.size.height + altsNum)

		-- primaryRole
		row.alts[altName].primaryRole = GRA:CreateButton(row.alts[altName].nameGrid, "", "none", {16, 16})
		row.alts[altName].primaryRole:SetAlpha(.7)
		row.alts[altName].primaryRole:SetPoint("LEFT", 2, 0)
		row.alts[altName].primaryRole:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .1) end)
		row.alts[altName].primaryRole:SetScript("OnLeave", function() row:SetBackdropColor(0, 0, 0, 0) end)
		row.alts[altName].primaryRole:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\Roles\]] .. (_G[GRA_R_Roster][altName]["role"] or "DPS"))

		-- dateGrids
		for i = 1, #row.dateGrids do
			local grid = GRA:CreateGrid(row, gra.size.grid_dates, " ", {.7,.7,.7,.1})
			if i == 1 then
				grid:SetPoint("TOPLEFT", lastColumn, "TOPRIGHT", -1, - altsNum * gra.size.height + altsNum)
			else
				grid:SetPoint("LEFT", row.alts[altName].dateGrids[i-1], "RIGHT", -1, 0)
			end
			grid:SetBackdropBorderColor(0, 0, 0, 1)
			grid:SetNormalFontObject("GRA_FONT_GRID")
			table.insert(row.alts[altName].dateGrids, grid)

			-- highlight
			row.dateGrids[i]:HookScript("OnEnter", function()
				grid:Highlight()
			end)
			row.dateGrids[i]:HookScript("OnLeave", function()
				grid:Unhighlight()
			end)

			grid:HookScript("OnEnter", function()
				-- get the newest OnEnter
				row.dateGrids[i]:GetScript("OnEnter")()
			end)
			grid:HookScript("OnLeave", function()
				-- get the newest OnEnter
				row.dateGrids[i]:GetScript("OnLeave")()
			end)
		end
	end
	
	return row
end

-----------------------------------------
-- raid logs frame
-----------------------------------------
function GRA:CreateListButton(parent, text, color, size, font)
	local b = GRA:CreateButton(parent, text, color, size, font)
	b:SetPushedTextOffset(0, 0)
	b.isSelected = false

	function b:Select()
		b:SetBackdropColor(unpack(b.hoverColor))
		b:SetScript("OnEnter", function() end)
		b:SetScript("OnLeave", function() end)
		b.isSelected = true
	end

	function b:Deselect()
		b:SetBackdropColor(unpack(b.color))
		b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(b.hoverColor)) end)
		b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(b.color)) end)
		b.isSelected = false
	end

	b:SetScript("OnClick", function()
		if not IsShiftKeyDown() and not IsControlKeyDown() then
			b:Select()
		end
	end)

	return b
end

function GRA:CreateRow_AttendanceEditor(parent, width, name, attendance, note, joinTime)
	local row = CreateFrame("Button", nil, parent)
	row:SetFrameLevel(5)
	row:SetSize(width, 20)
	row:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	row:SetBackdropColor(0, 0, 0, 0) 
    row:SetBackdropBorderColor(0, 0, 0, 1)
	
	row.nameGrid = GRA:CreateGrid(row, gra.size.grid_name - 15, GRA:GetClassColoredName(name), {.7,.7,.7,.1})
	row.nameGrid:SetBackdropBorderColor(0, 0, 0, .35)
	row.nameGrid:GetFontString():ClearAllPoints()
	row.nameGrid:GetFontString():SetPoint("LEFT", 5, 0)
	row.nameGrid:SetNormalFontObject("GRA_FONT_TEXT")
	row.nameGrid:SetPoint("LEFT")

	row.attendanceGrid = GRA:CreateGrid(row, 60, " ", {.7,.7,.7,.1})
	row.attendanceGrid:SetBackdropBorderColor(0, 0, 0, 1)
	row.attendanceGrid:SetPoint("LEFT", row.nameGrid, "RIGHT", -1, 0)
	row.attendanceGrid:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .1) end)
	row.attendanceGrid:SetScript("OnLeave", function() row:SetBackdropColor(0, 0, 0, 0) end)
	
	row.joinTimeEditBox = GRA:CreateEditBox(row, 60, 20)
	row.joinTimeEditBox:SetJustifyH("CENTER")
	GRA:StylizeFrame(row.joinTimeEditBox, {.7,.7,.7,.1})
	row.joinTimeEditBox:SetPoint("LEFT", row.attendanceGrid, "RIGHT", -1, 0)
	row.joinTimeEditBox:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .1) end)
	row.joinTimeEditBox:SetScript("OnLeave", function() row:SetBackdropColor(0, 0, 0, 0) end)
	row.joinTimeEditBox:Hide()
	-- row.joinTimeEditBox:SetPoint("RIGHT")

	row.noteEditBox = GRA:CreateEditBox(row, 100, 20)
	GRA:StylizeFrame(row.noteEditBox, {.7,.7,.7,.1})
	row.noteEditBox:SetPoint("LEFT", row.attendanceGrid, "RIGHT", -1, 0)
	row.noteEditBox:SetPoint("RIGHT")
	row.noteEditBox:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .1) end)
	row.noteEditBox:SetScript("OnLeave", function() row:SetBackdropColor(0, 0, 0, 0) end)

	function row:SetJoinTimeVisible(v)
		if v then
			row.joinTimeEditBox:Show()
			row.noteEditBox:SetPoint("LEFT", row.joinTimeEditBox, "RIGHT", -1, 0)
		else
			row.joinTimeEditBox:Hide()
			row.noteEditBox:SetPoint("LEFT", row.attendanceGrid, "RIGHT", -1, 0)
		end
	end

	function row:SetRowInfo(att, nt, jt)
		local attendanceText
		row.attendance = att -- sort key
		row.joinTime = jt
		row.note = nt

		if att == "PRESENT" or att == "LATE" then
			row.attendance = "PRESENT"
			attendanceText = L["Present"]
			row.attendanceGrid:GetFontString():SetTextColor(0, 1, 0, .9)
		elseif att == "ABSENT" then
			attendanceText = L["Absent"]
			row.attendanceGrid:GetFontString():SetTextColor(1, 0, 0, .9)
		elseif att == "ONLEAVE" then
			attendanceText = L["On Leave"]
			row.attendanceGrid:GetFontString():SetTextColor(1, 0, 1, .9)
		else -- ignored
			attendanceText = L["Ignored"]
			row.attendanceGrid:GetFontString():SetTextColor(.7, .7, .7, 1)
		end
		row.attendanceGrid:SetText(attendanceText)
		
		row.noteEditBox:SetText(nt or "")

		if jt then
			row:SetJoinTimeVisible(true)
			row.joinTimeEditBox:SetText(GRA:SecondsToTime(jt))
		else
			row:SetJoinTimeVisible(false)
		end
		
		if att == "IGNORED" then
			row.noteEditBox:SetEnabled(false)
		else
			if not _G[GRA_R_Roster][name]["altOf"] then
				row.noteEditBox:SetEnabled(true)
			else
				row.noteEditBox:SetEnabled(false)
				row.noteEditBox:SetText(L["Not available for alts"])
			end
		end
		-- let the first letter be first
		row.noteEditBox:SetCursorPosition(0)
	end
	row:SetRowInfo(attendance, note, joinTime)

	function row:SetChanged(changed)
		if changed then
			GRA:StylizeFrame(row.nameGrid, {1, .3, .3, .2})
			GRA:StylizeFrame(row.attendanceGrid, {1, .3, .3, .2})
			GRA:StylizeFrame(row.joinTimeEditBox, {1, .3, .3, .2})
			GRA:StylizeFrame(row.noteEditBox, {1, .3, .3, .2})
		else
			GRA:StylizeFrame(row.nameGrid, {.7,.7,.7,.1})
			GRA:StylizeFrame(row.attendanceGrid, {.7,.7,.7,.1})
			GRA:StylizeFrame(row.joinTimeEditBox, {.7,.7,.7,.1})
			GRA:StylizeFrame(row.noteEditBox, {.7,.7,.7,.1})
		end
	end

	return row
end

-----------------------------------------
-- detail button (raid logs frame)
-----------------------------------------
function GRA:CreateDetailButton(parent, detailTable, font)
	if string.find(detailTable[1], "DKP") then return end
	-- {"EP"/"GP", ep/gp, reason(string)/itemLink, {playerName...}},
	if not font then font = "GRA_FONT_SMALL" end
	local hoverColor, borderColor, textColor
	if detailTable[1] == "GP" then
		hoverColor = {.1, .6, .95, .3}
		borderColor = {.1, .6, .95, .6}
		textColor = {.16, .56, .95, 1}
	elseif detailTable[1] == "EP" then
		hoverColor = {.1, .95, .2, .3}
		borderColor = {.1, .95, .2, .6}
		textColor = {.1, .95, .2, 1}
	else
		hoverColor = {.95, .17, .2, .3}
		borderColor = {.95, .17, .2, .6}
		textColor = {.95, .2, .2, 1}
	end

	local b = CreateFrame("Button", nil, parent)
	b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	b:SetBackdropColor(0, 0, 0, 0)
	b:SetBackdropBorderColor(unpack(borderColor))
	b:SetPushedTextOffset(0, 0)
	b:SetSize(gra.size.height, gra.size.height)

	local tex1 = b:CreateTexture()
	tex1:SetColorTexture(unpack(borderColor))
	tex1:SetSize(1, gra.size.height)
	local tex2 = b:CreateTexture()
	tex2:SetColorTexture(unpack(borderColor))
	tex2:SetSize(1, gra.size.height)
	local tex3 = b:CreateTexture()
	tex3:SetColorTexture(unpack(borderColor))
	tex3:SetSize(1, gra.size.height)
	local tex4 = b:CreateTexture() -- for GP
	tex4:SetColorTexture(unpack(borderColor))
	tex4:SetSize(1, gra.size.height)

	b.typeText = b:CreateFontString(nil, "OVERLAY", font)
	b.typeText:SetTextColor(unpack(textColor))
	b.typeText:SetPoint("LEFT", 5, 0)
	-- b.typeText:SetPoint("RIGHT", b, "LEFT", 50, 0)
	b.typeText:SetWidth(18)
	b.typeText:SetJustifyH("LEFT")
	b.typeText:SetWordWrap(false)
	tex1:SetPoint("RIGHT", b.typeText, 3, 0)

	b.valueText = b:CreateFontString(nil, "OVERLAY", font)
	b.valueText:SetTextColor(unpack(textColor))
	b.valueText:SetPoint("LEFT", b.typeText, "RIGHT", 5, 0)
	b.valueText:SetWidth(45)
	b.valueText:SetJustifyH("LEFT")
	b.valueText:SetWordWrap(false)
	tex2:SetPoint("RIGHT", b.valueText, 3, 0)

	b.reasonText = b:CreateFontString(nil, "OVERLAY", font)
	b.reasonText:SetTextColor(unpack(textColor))
	b.reasonText:SetPoint("LEFT", b.valueText, "RIGHT", 5, 0)
	b.reasonText:SetWidth(130)
	b.reasonText:SetJustifyH("LEFT")
	b.reasonText:SetWordWrap(false)
	tex3:SetPoint("RIGHT", b.reasonText, 3, 0)

	b.playerText = b:CreateFontString(nil, "OVERLAY", font)
	b.playerText:SetTextColor(unpack(textColor))
	b.playerText:SetPoint("LEFT", b.reasonText, "RIGHT", 5, 0)
	b.playerText:SetJustifyH("LEFT")
	b.playerText:SetWordWrap(false)

	b.noteText = b:CreateFontString(nil, "OVERLAY", font)
	b.noteText:SetTextColor(unpack(textColor))
	b.noteText:SetJustifyH("LEFT")
	b.noteText:SetWordWrap(false)

	if string.find(detailTable[1], "P") == 1 then
		b.typeText:SetText(string.sub(detailTable[1], 2, 3))
	else
		b.typeText:SetText(detailTable[1])
	end
	b.valueText:SetText(detailTable[2])
	b.reasonText:SetText(detailTable[3])

	if detailTable[1] == "GP" then
		b.playerText:SetWidth(80)
		tex4:SetPoint("RIGHT", b.playerText, 3, 0)
		b.noteText:SetPoint("LEFT", b.playerText, "RIGHT", 5, 0)
		b.noteText:SetPoint("RIGHT", -5, 0)
		if detailTable[5] and detailTable[5] ~= "" then
			b.noteText:SetText(detailTable[5])
		else
			tex4:Hide()
		end
	else
		b.playerText:SetPoint("RIGHT", -5, 0)
	end

	local playerText = ""
	if type(detailTable[4]) == "string" then -- gp name
		playerText = GRA:GetShortName(detailTable[4])
	else -- names
		for _, name in pairs(detailTable[4]) do
			playerText = playerText .. GRA:GetShortName(name) .. " "
		end
	end
	b.playerText:SetText(playerText)

	b:SetScript("OnEnter", function()
		b.typeText:SetTextColor(1, 1, 1, 1)
		b.valueText:SetTextColor(1, 1, 1, 1)
		b.reasonText:SetTextColor(1, 1, 1, 1)
		b.playerText:SetTextColor(1, 1, 1, 1)
		b.noteText:SetTextColor(1, 1, 1, 1)
		b:SetBackdropColor(unpack(hoverColor))
	end)

	b:SetScript("OnLeave", function()
		b.typeText:SetTextColor(unpack(textColor))
		b.valueText:SetTextColor(unpack(textColor))
		b.reasonText:SetTextColor(unpack(textColor))
		b.playerText:SetTextColor(unpack(textColor))
		b.noteText:SetTextColor(unpack(textColor))
		b:SetBackdropColor(0, 0, 0, 0)
	end)


	b.deleteBtn = CreateFrame("Button", nil, b)
	b.deleteBtn:SetSize(gra.size.height, gra.size.height)
	b.deleteBtn:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	b.deleteBtn:SetBackdropColor(unpack(hoverColor))
	b.deleteBtn:SetBackdropBorderColor(unpack(borderColor))
	b.deleteBtn:SetText("×")
	b.deleteBtn:SetNormalFontObject("GRA_FONT_BUTTON")
	b.deleteBtn:SetPushedTextOffset(0, -1)
	b.deleteBtn:SetPoint("RIGHT")
	b.deleteBtn:SetScript("OnEnter", function()
		b.typeText:SetTextColor(1, 1, 1, 1)
		b.valueText:SetTextColor(1, 1, 1, 1)
		b.reasonText:SetTextColor(1, 1, 1, 1)
		b.playerText:SetTextColor(1, 1, 1, 1)
		b.noteText:SetTextColor(1, 1, 1, 1)
		b:SetBackdropColor(unpack(hoverColor))
	end)
	b.deleteBtn:SetScript("OnLeave", function()
		b.typeText:SetTextColor(unpack(textColor))
		b.valueText:SetTextColor(unpack(textColor))
		b.reasonText:SetTextColor(unpack(textColor))
		b.playerText:SetTextColor(unpack(textColor))
		b.noteText:SetTextColor(unpack(textColor))
		b:SetBackdropColor(0, 0, 0, 0)
	end)
	
	b.deleteBtn:Hide()

	return b
end

function GRA:CreateDetailButton_DKP(parent, detailTable, font)
	if not string.find(detailTable[1], "DKP") then return end
	-- {"DKP_A"/"DKP_C"/"DKP_P", value, reason(string)/itemLink/reason(string), {playerName...}},
	if not font then font = "GRA_FONT_SMALL" end
	local hoverColor, borderColor, textColor
	if detailTable[1] == "DKP_C" then
		hoverColor = {.1, .6, .95, .3}
		borderColor = {.1, .6, .95, .6}
		textColor = {.16, .56, .95, 1}
	elseif detailTable[1] == "DKP_A" then
		hoverColor = {.1, .95, .2, .3}
		borderColor = {.1, .95, .2, .6}
		textColor = {.1, .95, .2, 1}
	else -- DKP_P
		hoverColor = {.95, .17, .2, .3}
		borderColor = {.95, .17, .2, .6}
		textColor = {.95, .2, .2, 1}
	end

	local b = CreateFrame("Button", nil, parent)
	b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	b:SetBackdropColor(0, 0, 0, 0)
	b:SetBackdropBorderColor(unpack(borderColor))
	b:SetPushedTextOffset(0, 0)
	b:SetSize(gra.size.height, gra.size.height)

	local tex1 = b:CreateTexture()
	tex1:SetColorTexture(unpack(borderColor))
	tex1:SetSize(1, gra.size.height)
	local tex2 = b:CreateTexture()
	tex2:SetColorTexture(unpack(borderColor))
	tex2:SetSize(1, gra.size.height)
	local tex3 = b:CreateTexture()
	tex3:SetColorTexture(unpack(borderColor))
	tex3:SetSize(1, gra.size.height)
	local tex4 = b:CreateTexture() -- for DKP_C
	tex4:SetColorTexture(unpack(borderColor))
	tex4:SetSize(1, gra.size.height)

	b.typeText = b:CreateFontString(nil, "OVERLAY", font)
	b.typeText:SetTextColor(unpack(textColor))
	b.typeText:SetPoint("LEFT", 5, 0)
	-- b.typeText:SetPoint("RIGHT", b, "LEFT", 50, 0)
	b.typeText:SetWidth(25)
	b.typeText:SetJustifyH("LEFT")
	b.typeText:SetWordWrap(false)
	tex1:SetPoint("RIGHT", b.typeText, 3, 0)

	b.valueText = b:CreateFontString(nil, "OVERLAY", font)
	b.valueText:SetTextColor(unpack(textColor))
	b.valueText:SetPoint("LEFT", b.typeText, "RIGHT", 5, 0)
	b.valueText:SetWidth(45)
	b.valueText:SetJustifyH("LEFT")
	b.valueText:SetWordWrap(false)
	tex2:SetPoint("RIGHT", b.valueText, 3, 0)

	b.reasonText = b:CreateFontString(nil, "OVERLAY", font)
	b.reasonText:SetTextColor(unpack(textColor))
	b.reasonText:SetPoint("LEFT", b.valueText, "RIGHT", 5, 0)
	b.reasonText:SetWidth(130)
	b.reasonText:SetJustifyH("LEFT")
	b.reasonText:SetWordWrap(false)
	tex3:SetPoint("RIGHT", b.reasonText, 3, 0)

	b.playerText = b:CreateFontString(nil, "OVERLAY", font)
	b.playerText:SetTextColor(unpack(textColor))
	b.playerText:SetPoint("LEFT", b.reasonText, "RIGHT", 5, 0)
	b.playerText:SetJustifyH("LEFT")
	b.playerText:SetWordWrap(false)
	
	b.noteText = b:CreateFontString(nil, "OVERLAY", font)
	b.noteText:SetTextColor(unpack(textColor))
	b.noteText:SetJustifyH("LEFT")
	b.noteText:SetWordWrap(false)
	
	b.typeText:SetText("DKP")
	if detailTable[1] == "DKP_C" then
		b.valueText:SetText(-detailTable[2])
		b.playerText:SetWidth(80)
		tex4:SetPoint("RIGHT", b.playerText, 3, 0)
		b.noteText:SetPoint("LEFT", b.playerText, "RIGHT", 5, 0)
		b.noteText:SetPoint("RIGHT", -5, 0)
		if detailTable[5] and detailTable[5] ~= "" then
			b.noteText:SetText(detailTable[5])
		else
			tex4:Hide()
		end
	else
		b.valueText:SetText(detailTable[2])
		b.playerText:SetPoint("RIGHT", -5, 0)
	end
	b.reasonText:SetText(detailTable[3])

	local playerText = ""
	if type(detailTable[4]) == "string" then -- looter name
		playerText = GRA:GetShortName(detailTable[4])
	else -- names
		for _, name in pairs(detailTable[4]) do
			playerText = playerText .. GRA:GetShortName(name) .. " "
		end
	end
	b.playerText:SetText(playerText)

	b:SetScript("OnEnter", function()
		b.typeText:SetTextColor(1, 1, 1, 1)
		b.valueText:SetTextColor(1, 1, 1, 1)
		b.reasonText:SetTextColor(1, 1, 1, 1)
		b.playerText:SetTextColor(1, 1, 1, 1)
		b.noteText:SetTextColor(1, 1, 1, 1)
		b:SetBackdropColor(unpack(hoverColor))
	end)

	b:SetScript("OnLeave", function()
		b.typeText:SetTextColor(unpack(textColor))
		b.valueText:SetTextColor(unpack(textColor))
		b.reasonText:SetTextColor(unpack(textColor))
		b.playerText:SetTextColor(unpack(textColor))
		b.noteText:SetTextColor(unpack(textColor))
		b:SetBackdropColor(0, 0, 0, 0)
	end)


	b.deleteBtn = CreateFrame("Button", nil, b)
	b.deleteBtn:SetSize(gra.size.height, gra.size.height)
	b.deleteBtn:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	b.deleteBtn:SetBackdropColor(unpack(hoverColor))
	b.deleteBtn:SetBackdropBorderColor(unpack(borderColor))
	b.deleteBtn:SetText("×")
	b.deleteBtn:SetNormalFontObject("GRA_FONT_BUTTON")
	b.deleteBtn:SetPushedTextOffset(0, -1)
	b.deleteBtn:SetPoint("RIGHT")
	b.deleteBtn:SetScript("OnEnter", function()
		b.typeText:SetTextColor(1, 1, 1, 1)
		b.valueText:SetTextColor(1, 1, 1, 1)
		b.reasonText:SetTextColor(1, 1, 1, 1)
		b.playerText:SetTextColor(1, 1, 1, 1)
		b.noteText:SetTextColor(1, 1, 1, 1)
		b:SetBackdropColor(unpack(hoverColor))
	end)
	b.deleteBtn:SetScript("OnLeave", function()
		b.typeText:SetTextColor(unpack(textColor))
		b.valueText:SetTextColor(unpack(textColor))
		b.reasonText:SetTextColor(unpack(textColor))
		b.playerText:SetTextColor(unpack(textColor))
		b.noteText:SetTextColor(unpack(textColor))
		b:SetBackdropColor(0, 0, 0, 0)
	end)
	
	b.deleteBtn:Hide()

	return b
end

function GRA:CreateDetailButton_LC(parent, detailTable, font)
	-- 为了兼容性，假装为GP
	-- {"GP", 0, itemLink, playerName, note},
	if detailTable[1] ~= "GP" then return end
	if not font then font = "GRA_FONT_SMALL" end
	local hoverColor, borderColor, textColor
	hoverColor = {.1, .6, .95, .3}
	borderColor = {.1, .6, .95, .6}
	textColor = {.16, .56, .95, 1}

	local b = CreateFrame("Button", nil, parent)
	b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	b:SetBackdropColor(0, 0, 0, 0)
	b:SetBackdropBorderColor(unpack(borderColor))
	b:SetPushedTextOffset(0, 0)
	b:SetSize(20, 20)

	local tex1 = b:CreateTexture()
	tex1:SetColorTexture(unpack(borderColor))
	tex1:SetSize(1, 20)
	local tex2 = b:CreateTexture()
	tex2:SetColorTexture(unpack(borderColor))
	tex2:SetSize(1, 20)


	b.itemText = b:CreateFontString(nil, "OVERLAY", font)
	b.itemText:SetTextColor(unpack(textColor))
	b.itemText:SetPoint("LEFT", 5, 0)
	b.itemText:SetWidth(160)
	b.itemText:SetJustifyH("LEFT")
	b.itemText:SetWordWrap(false)
	tex1:SetPoint("RIGHT", b.itemText, 3, 0)

	b.playerText = b:CreateFontString(nil, "OVERLAY", font)
	b.playerText:SetTextColor(unpack(textColor))
	b.playerText:SetPoint("LEFT", b.itemText, "RIGHT", 5, 0)
	b.playerText:SetWidth(80)
	b.playerText:SetJustifyH("LEFT")
	b.playerText:SetWordWrap(false)
	tex2:SetPoint("RIGHT", b.playerText, 3, 0)

	b.noteText = b:CreateFontString(nil, "OVERLAY", font)
	b.noteText:SetTextColor(unpack(textColor))
	b.noteText:SetPoint("LEFT", b.playerText, "RIGHT", 5, 0)
	b.noteText:SetPoint("RIGHT", -5, 0)
	b.noteText:SetJustifyH("LEFT")
	b.noteText:SetWordWrap(false)

	b.itemText:SetText(detailTable[3])
	if type(detailTable[4]) == "table" then -- EPGP/DKP mass award credit
		b.playerText:SetText("EPGP/DKP data")
	else -- string
		b.playerText:SetText(GRA:GetShortName(detailTable[4]))
	end

	if detailTable[5] and detailTable[5] ~= "" then
		b.noteText:SetText(detailTable[5])
	else
		tex2:Hide()
	end

	b:SetScript("OnEnter", function()
		b.itemText:SetTextColor(1, 1, 1, 1)
		b.playerText:SetTextColor(1, 1, 1, 1)
		b.noteText:SetTextColor(1, 1, 1, 1)
		b:SetBackdropColor(unpack(hoverColor))
	end)

	b:SetScript("OnLeave", function()
		b.itemText:SetTextColor(unpack(textColor))
		b.playerText:SetTextColor(unpack(textColor))
		b.noteText:SetTextColor(unpack(textColor))
		b:SetBackdropColor(0, 0, 0, 0)
	end)


	b.deleteBtn = CreateFrame("Button", nil, b)
	b.deleteBtn:SetSize(20, 20)
	b.deleteBtn:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	b.deleteBtn:SetBackdropColor(unpack(hoverColor))
	b.deleteBtn:SetBackdropBorderColor(unpack(borderColor))
	b.deleteBtn:SetText("×")
	b.deleteBtn:SetNormalFontObject("GRA_FONT_BUTTON")
	b.deleteBtn:SetPushedTextOffset(0, -1)
	b.deleteBtn:SetPoint("RIGHT")
	b.deleteBtn:SetScript("OnEnter", function()
		b.itemText:SetTextColor(1, 1, 1, 1)
		b.playerText:SetTextColor(1, 1, 1, 1)
		b.noteText:SetTextColor(1, 1, 1, 1)
		b:SetBackdropColor(unpack(hoverColor))
	end)
	b.deleteBtn:SetScript("OnLeave", function()
		b.itemText:SetTextColor(unpack(textColor))
		b.playerText:SetTextColor(unpack(textColor))
		b.noteText:SetTextColor(unpack(textColor))
		b:SetBackdropColor(0, 0, 0, 0)
	end)
	
	b.deleteBtn:Hide()

	return b
end

-----------------------------------------
-- mask
-----------------------------------------
function GRA:CreateMask(parent, text, points) -- points = {topleftX, topleftY, bottomrightX, bottomrightY}
	if not parent.mask then -- not init
		parent.mask = CreateFrame("Frame", nil, parent)
		GRA:StylizeFrame(parent.mask, {.15, .15, .15, .5}, {0, 0, 0, 0})
		parent.mask:SetFrameStrata("HIGH")
		parent.mask:SetFrameLevel(100)
		parent.mask:EnableMouse(true) -- can't click-through
		-- parent.mask:EnableMouseWheel(true)

		parent.mask.text = parent.mask:CreateFontString(nil, "ARTWORK", "GRA_FONT_SMALL")
		parent.mask.text:SetTextColor(1, .2, .2)
		parent.mask.text:SetPoint("CENTER")

		-- parent.mask:SetScript("OnUpdate", function()
		-- 	if not parent:IsVisible() then
		-- 		parent.mask:Hide()
		-- 	end
		-- end)
	end

	if not text then text = "" end
	parent.mask.text:SetText(text)

	parent.mask:ClearAllPoints() -- prepare for SetPoint()
	if points then
		local tlX, tlY, brX, brY = unpack(points)
		parent.mask:SetPoint("TOPLEFT", tlX, tlY)
		parent.mask:SetPoint("BOTTOMRIGHT", brX, brY)
	else
		parent.mask:SetAllPoints(parent) -- anchor points are set to those of its "parent"
	end
	parent.mask:Show()
end

-----------------------------------------
-- seperator
-----------------------------------------
function GRA:CreateSeperator(parent, relativeTo, x, y, width ,color)
	if not color then color = {.5, 1, 0, .7} end
	if not width then width = parent:GetWidth()-10 end
	if not x then x = 0 end
	if not y then y = -3 end

	local line = parent:CreateTexture()
	line:SetSize(width, 1)
	line:SetColorTexture(unpack(color))
	line:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", x, y)
	local shadow = parent:CreateTexture()
	shadow:SetSize(width, 1)
	shadow:SetColorTexture(0, 0, 0, 1)
	shadow:SetPoint("TOPLEFT", line, 1, -1)
end

---------------------------------------------------------------
-- notification (fade-in fade-out string) 2017-06-21 11:48:05
---------------------------------------------------------------
function GRA:ShowNotificationString(text, point, parent, relativePoint, x, y)
	if not parent.notificationString then
		parent.notificationString = parent:CreateFontString(nil, "ARTWORK", "GRA_FONT_SMALL")

		parent.notificationString.animationGroup = parent.notificationString:CreateAnimationGroup()
		local fadeIn = parent.notificationString.animationGroup:CreateAnimation("Alpha")
		fadeIn:SetOrder(0)
		fadeIn:SetFromAlpha(0)
		fadeIn:SetToAlpha(1)
		fadeIn:SetDuration(.5)
		fadeIn:SetEndDelay(4)
		local fadeOut = parent.notificationString.animationGroup:CreateAnimation("Alpha")
		fadeOut:SetOrder(1)
		fadeOut:SetFromAlpha(1)
		fadeOut:SetToAlpha(0)
		fadeOut:SetDuration(.5)

		parent.notificationString.animationGroup:SetScript("OnFinished", function()
			parent.notificationString:Hide()
		end)

		parent.notificationString.animationGroup:SetScript("OnPlay", function()
			parent.notificationString:Show()
		end)
	end

	parent.notificationString.animationGroup:Stop()
	parent.notificationString:SetText(text)
	parent.notificationString:SetPoint(point, parent, relativePoint, x, y)
	parent.notificationString.animationGroup:Play()
end