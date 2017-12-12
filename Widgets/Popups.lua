local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")
local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")

-----------------------------------------
-- popup anchor
-----------------------------------------
local popupsAnchor = CreateFrame("Frame", "GRA_PopupsAnchor")
GRA:StylizeFrame(popupsAnchor, {.1, .1, .1, .5}, {0, 0, 0, .5})
popupsAnchor:SetSize(200, 300)
popupsAnchor:Hide()
popupsAnchor:SetPoint("LEFT", 20, 0)
popupsAnchor:EnableMouse(true)
popupsAnchor:SetMovable(true)
popupsAnchor:SetUserPlaced(true)
popupsAnchor:SetClampedToScreen(true)
popupsAnchor:RegisterForDrag("LeftButton")
LPP:PixelPerfectScale(popupsAnchor)
popupsAnchor:SetScript("OnDragStart", function() popupsAnchor:StartMoving() end)
popupsAnchor:SetScript("OnDragStop", function() popupsAnchor:StopMovingOrSizing() end)
popupsAnchor:RegisterEvent("VARIABLES_LOADED")
popupsAnchor:SetScript("OnEvent", function()
	LPP:PixelPerfectPoint(popupsAnchor)
end)

popupsAnchor.text = popupsAnchor:CreateFontString(nil, "OVERLAY", "GRA_FONT_TITLE")
popupsAnchor.text:SetPoint("TOPLEFT")
popupsAnchor.text:SetText("GRA Popups Anchor")

function GRA:ShowHidePopupsAnchor()
	if popupsAnchor:IsShown() then
		popupsAnchor:Hide()
		LPP:PixelPerfectPoint(popupsAnchor)
	else
		popupsAnchor:Show()
	end
end

-----------------------------------------
-- popup
-----------------------------------------
local popups = {}
-- TODO: animation slide
-- show popups (up to newest 5)
local function ShowPopups()
	for i = 1, (#popups > 5 and 5 or #popups) do
		popups[i]:ClearAllPoints()
		if i == 1 then
			-- popups[i]:SetPoint("LEFT", UIParent, 10, 0)
			popups[i]:SetPoint("TOPLEFT", popupsAnchor, 0, -30)
		else
			popups[i]:SetPoint("TOP", popups[i - 1], "BOTTOM", 0, -5)
		end
		popups[i]:Show()
	end
end

-- create popup
function GRA:CreatePopup(text)
	local frame = CreateFrame("Frame")
	GRA:StylizeFrame(frame, {.1, .1, .1, .95}, nil, {11, -11, -11, 11})
	frame:SetSize(200, 25)
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")
	LPP:PixelPerfectScale(frame)
	frame:Hide()
	table.insert(popups, frame)
	frame.posInTable = #popups

	local str = frame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
	str:SetWordWrap(false)
	str:SetSpacing(3)
	str:SetJustifyH("CENTER")
	str:SetText(text)
	str:SetPoint("LEFT", 5, 0)
	str:SetPoint("RIGHT", -5, 0)

	frame:SetScript("OnHide", function()
		table.remove(popups, frame.posInTable)
		for i = frame.posInTable, #popups do
			popups[i].posInTable = popups[i].posInTable - 1
		end
		C_Timer.After(.2, function() ShowPopups() end)
	end)

	-- fade-in effect
	frame.fadeIn = frame:CreateAnimationGroup()
	local fadeInAlpha = frame.fadeIn:CreateAnimation("Alpha")
	fadeInAlpha:SetFromAlpha(0)
	fadeInAlpha:SetToAlpha(1)
	fadeInAlpha:SetDuration(.3)
	
	-- auto hide in 7
	frame.fadeIn:SetScript("OnFinished", function()
		C_Timer.After(7, function() frame.fadeOut:Play() end)
	end)

	-- fade-out effect
	frame.fadeOut = frame:CreateAnimationGroup()
	local fadeOutAlpha = frame.fadeOut:CreateAnimation("Alpha")
	fadeOutAlpha:SetFromAlpha(1)
	fadeOutAlpha:SetToAlpha(0)
	fadeOutAlpha:SetDuration(.3)

	frame.fadeOut:SetScript("OnFinished", function()
		frame:Hide()
	end)

	frame:SetScript("OnShow", function()
		frame.fadeIn:Play()
	end)
	
	ShowPopups()
end


function GRA:CreatePopupWithButton(text, onAccept, onDecline)
	-- GRA:Debug("|cff87CEEBGRA:CreatePopup: |r" .. text)
	local frame = CreateFrame("Frame")
	GRA:StylizeFrame(frame, {.1, .1, .1, .95}, nil, {11, -11, -11, 11})
	frame:SetSize(200, 50)
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")
	LPP:PixelPerfectScale(frame)
	frame:Hide()
	table.insert(popups, frame)
	frame.posInTable = #popups
	
	local str = frame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
	str:SetWordWrap(true)
	str:SetSpacing(3)
	str:SetJustifyH("CENTER")
	str:SetText(text)
	str:SetPoint("TOPLEFT", 5, -5)
	str:SetPoint("BOTTOMRIGHT", -5, 20)
	
	-- yes
	local button1 = GRA:CreateButton(frame, L["Yes"], "green", {35, 15}, "GRA_FONT_SMALL")
	button1:SetPoint("BOTTOMRIGHT", -34, 0)
	button1:SetScript("OnClick", function()
		if onAccept then onAccept() end
		frame.fadeOut:Play()
	end)
	
	-- no
	local button2 = GRA:CreateButton(frame, L["No"], "red", {35, 15}, "GRA_FONT_SMALL")
	button2:SetPoint("LEFT", button1, "RIGHT", -1, 0)
	button2:SetScript("OnClick", function()
		if onDecline then onDecline() end
		frame.fadeOut:Play()
	end)

	frame:SetScript("OnHide", function()
		table.remove(popups, frame.posInTable)
		for i = frame.posInTable, #popups do
			popups[i].posInTable = popups[i].posInTable - 1
		end
		C_Timer.After(.2, function() ShowPopups() end)
	end)

	-- fade-in effect
	frame.fadeIn = frame:CreateAnimationGroup()
	local fadeInAlpha = frame.fadeIn:CreateAnimation("Alpha")
	fadeInAlpha:SetFromAlpha(0)
	fadeInAlpha:SetToAlpha(1)
	fadeInAlpha:SetDuration(.3)

	-- fade-out effect
	frame.fadeOut = frame:CreateAnimationGroup()
	local fadeOutAlpha = frame.fadeOut:CreateAnimation("Alpha")
	fadeOutAlpha:SetFromAlpha(1)
	fadeOutAlpha:SetToAlpha(0)
	fadeOutAlpha:SetDuration(.3)

	frame.fadeOut:SetScript("OnFinished", function()
		frame:Hide()
	end)

	frame:SetScript("OnShow", function()
		frame.fadeIn:Play()
	end)
	
	ShowPopups()
end

-- popup altert (without "yes"/"no" button)
-- function GRA:CreatePopupAlert()

-- end

-----------------------------------------
-- data transfer popup
-----------------------------------------
function GRA:CreateDataTransferPopup(text, total, onHide)
	if not total then total = 0 end

	local frame = CreateFrame("Frame")
	GRA:StylizeFrame(frame, {.1, .1, .1, .95}, nil, {11, -11, -11, 11})
	frame:SetSize(200, 50)
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")
	LPP:PixelPerfectScale(frame)
	frame:Hide()
	table.insert(popups, frame)
	frame.posInTable = #popups

	local str = frame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
	str:SetWordWrap(true)
	str:SetSpacing(3)
	str:SetJustifyH("CENTER")
	str:SetText(text)
	str:SetPoint("TOPLEFT", 5, -5)
	str:SetPoint("BOTTOMRIGHT", -5, 20)

	local bar = CreateFrame("StatusBar", nil, frame)
	LSSB:SmoothBar(bar) -- smooth progress bar
	bar.tex = bar:CreateTexture()
	bar.tex:SetColorTexture(.5, 1, 0, .8)
	bar:SetStatusBarTexture(bar.tex)
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:SetMinMaxValues(0, total)
	bar:SetValue(0)
	bar:SetHeight(5)
	bar:SetPoint("BOTTOMLEFT", frame, 5, 5)
	bar:SetPoint("BOTTOMRIGHT", frame, -5, 5)
	bar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = -1})
	bar:SetBackdropColor(.07, .07, .07, .9)
	bar:SetBackdropBorderColor(0, 0, 0, 1)

	bar.text = bar:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
	bar.text:SetJustifyH("RIGHT")
	bar.text:SetJustifyV("MIDDLE")
	bar.text:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 2)
	
	bar:SetScript("OnValueChanged", function(self, value)
		-- update text
		bar.text:SetText(math.floor(value) .. "/" .. total)
		-- hide self on finished (5s delayed)
		if bar:GetValue() == total then
			C_Timer.After(5, function()
        		frame.fadeOut:Play()
			end)
		end
	end)

	function frame:SetValue(value)
		bar:SetValue(value)
	end

	-- test
	function frame:Test(testMode)
		if testMode then
			local increase = true
			frame:SetScript("OnUpdate", function()
				local newValue
				if increase then
					newValue = bar:GetValue()+1
				else
					newValue = bar:GetValue()-1
				end

				if newValue >= total then
					newValue = total
					increase = false
				elseif newValue <= 0 then
					newValue = 0
					increase = true
				end
				bar:SetValue(newValue)
			end)
		else
			frame:SetScript("OnUpdate", nil)
		end
	end

	frame:SetScript("OnHide", function()
		table.remove(popups, frame.posInTable)
		for i = frame.posInTable, #popups do
			popups[i].posInTable = popups[i].posInTable - 1
		end
		C_Timer.After(.2, function() ShowPopups() end)
		if onHide then onHide() end
	end)

	-- fade-in effect
	frame.fadeIn = frame:CreateAnimationGroup()
	local fadeInAlpha = frame.fadeIn:CreateAnimation("Alpha")
	fadeInAlpha:SetFromAlpha(0)
	fadeInAlpha:SetToAlpha(1)
	fadeInAlpha:SetDuration(.3)

	-- fade-out effect
	frame.fadeOut = frame:CreateAnimationGroup()
	local fadeOutAlpha = frame.fadeOut:CreateAnimation("Alpha")
	fadeOutAlpha:SetFromAlpha(1)
	fadeOutAlpha:SetToAlpha(0)
	fadeOutAlpha:SetDuration(.3)

	frame.fadeOut:SetScript("OnFinished", function()
		frame:Hide()
	end)

	frame:SetScript("OnShow", function()
		frame.fadeIn:Play()
	end)
	
	ShowPopups()

	return frame
end

-----------------------------------------
-- data transfer popup (sender-side)
-----------------------------------------
--[===[
local sendPopups, sendPopupsIndex = {}, {}
local function ShowSendPopups()
	for k, n in pairs(sendPopupsIndex) do
		sendPopups[n]:ClearAllPoints()
		if k % 14 == 1 then
			sendPopups[n]:SetPoint("TOPRIGHT", gra.mainFrame, "TOPLEFT", - 82 * math.modf(k / 14) - 2, 21)
		else
			sendPopups[n]:SetPoint("TOP", sendPopups[sendPopupsIndex[k - 1]], "BOTTOM", 0, -2)
		end
		-- validate
		if not sendPopups[n]:IsShown() then
			sendPopups[n]:Show()
			sendPopups[n].fadeIn:Play()
		end
	end
end

function GRA:CheckSendFinished()
	if #sendPopupsIndex == 0 then
		return true
	else
		return false
	end
end

function GRA:CreateDataTransferSendPopup(name, total, onHide)
	if sendPopups[name] then return sendPopups[name] end -- exists

	if not total then total = 0 end

	local frame = CreateFrame("Frame", nil, gra.mainFrame)
	GRA:StylizeFrame(frame, {.1, .1, .1, .95}, nil, {11, -11, -11, 11})
	frame:SetSize(80, 29)
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")
	frame:Hide()
	LPP:PixelPerfectScale(frame)
	table.insert(sendPopupsIndex, name)
	frame.posInTable = #sendPopupsIndex
	sendPopups[name] = frame

	local str = frame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
	str:SetWordWrap(true)
	str:SetSpacing(3)
	str:SetJustifyH("CENTER")
	str:SetText(GRA:GetClassColoredName(name, select(2, UnitClass(name))))
	str:SetPoint("TOPLEFT", 5, -5)
	str:SetPoint("TOPRIGHT", -5, -5)

	local bar = CreateFrame("StatusBar", nil, frame)
	LSSB:SmoothBar(bar)
	bar.tex = bar:CreateTexture()
	bar.tex:SetColorTexture(.5, 1, 0, .8)
	bar:SetStatusBarTexture(bar.tex)
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:SetMinMaxValues(0, total)
	bar:SetValue(0)
	bar:SetHeight(3)
	bar:SetPoint("BOTTOMLEFT", frame, 5, 5)
	bar:SetPoint("BOTTOMRIGHT", frame, -5, 5)
	bar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = -1})
	bar:SetBackdropColor(.07, .07, .07, .9)
	bar:SetBackdropBorderColor(0, 0, 0, 1)

	bar:SetScript("OnValueChanged", function()
		if bar:GetValue() == total then
			C_Timer.After(5, function()
        		frame.fadeOut:Play()
			end)
		end
	end)

	function frame:SetValue(value)
		bar:SetValue(value)
	end

	-- test
	function frame:Test(testMode)
		if testMode then
			local increase = true
			frame:SetScript("OnUpdate", function()
				local newValue
				if increase then
					newValue = bar:GetValue()+1
				else
					newValue = bar:GetValue()-1
				end

				if newValue >= total then
					newValue = total
					increase = false
				elseif newValue <= 0 then
					newValue = 0
					increase = true
				end
				bar:SetValue(newValue)
			end)
		else
			frame:SetScript("OnUpdate", nil)
		end
	end

		-- fade-in effect
	frame.fadeIn = frame:CreateAnimationGroup()
	local fadeInAlpha = frame.fadeIn:CreateAnimation("Alpha")
	fadeInAlpha:SetFromAlpha(0)
	fadeInAlpha:SetToAlpha(1)
	fadeInAlpha:SetDuration(.3)

	-- frame.fadeIn:SetScript("OnFinished", function()
	-- 	frame:Show()
	-- end)

	-- fade-out effect
	frame.fadeOut = frame:CreateAnimationGroup()
	local fadeOutAlpha = frame.fadeOut:CreateAnimation("Alpha")
	fadeOutAlpha:SetFromAlpha(1)
	fadeOutAlpha:SetToAlpha(0)
	fadeOutAlpha:SetDuration(.3)

	frame.fadeOut:SetScript("OnFinished", function()
		frame:Hide()

		table.remove(sendPopupsIndex, frame.posInTable)
		sendPopups = GRA:RemoveElementsByKeys(sendPopups, {name})
		for i = frame.posInTable, #sendPopupsIndex do
			sendPopups[sendPopupsIndex[i]].posInTable = sendPopups[sendPopupsIndex[i]].posInTable - 1
		end
		C_Timer.After(.2, function() ShowSendPopups() end)
		if onHide then onHide() end
	end)

	-- frame:SetScript("OnHide", function()
	-- end)

	-- frame:SetScript("OnShow", function()
	-- 	frame.fadeIn:Play()
	-- end)

	ShowSendPopups()

	return frame
end
]===]

-----------------------------------------
-- static popup dialog
-----------------------------------------
function GRA:CreateStaticPopup(title, text, onAccept, onDecline) -- button1Text, button2Text
	if not gra.staticPopup then
		gra.staticPopup = CreateFrame("Frame", "GRA_StaticPopup")
		gra.staticPopup:Hide()
		GRA:StylizeFrame(gra.staticPopup, {.1, .1, .1, .95}, nil, {11, -11, -11, 11})
		gra.staticPopup:SetSize(220, 100)
		gra.staticPopup:SetPoint("CENTER", 0, 100)
		gra.staticPopup:SetFrameStrata("DIALOG")
		gra.staticPopup:SetFrameLevel(20)
		gra.staticPopup:SetToplevel(true)
		LPP:PixelPerfectScale(gra.staticPopup)
		gra.staticPopup:EnableMouse(true)

		gra.staticPopup:SetScript("OnShow", function() LPP:PixelPerfectPoint(gra.staticPopup) end)
		
		gra.staticPopup.titleFS = gra.staticPopup:CreateFontString(nil, "OVERLAY", "GRA_FONT_NORMAL")
		gra.staticPopup.titleFS:SetJustifyH("LEFT")
		gra.staticPopup.titleFS:SetPoint("TOPLEFT", 10, -5)
		gra.staticPopup.titleFS:SetPoint("TOPRIGHT", -10, -5)

		local sep = gra.staticPopup:CreateTexture()
		sep:SetSize(gra.staticPopup:GetWidth()-10, 1)
		sep:SetColorTexture(.5, 1, 0, .7)
		sep:SetPoint("TOP", 0, -20)

		local shadow = gra.staticPopup:CreateTexture()
		shadow:SetSize(gra.staticPopup:GetWidth()-10, 1)
		shadow:SetColorTexture(0, 0, 0, 1)
		shadow:SetPoint("TOPLEFT", sep, 1, -1)

		gra.staticPopup.textFS = gra.staticPopup:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
		gra.staticPopup.textFS:SetWordWrap(true)
		gra.staticPopup.textFS:SetSpacing(3)
		gra.staticPopup.textFS:SetJustifyH("LEFT")
		gra.staticPopup.textFS:SetJustifyV("MIDDLE")
		gra.staticPopup.textFS:SetPoint("TOPLEFT", 10, -30)
		-- gra.staticPopup.textFS:SetPoint("BOTTOMRIGHT", -10, 30)
		gra.staticPopup.textFS:SetPoint("TOPRIGHT", -10, -30)

		-- no
		gra.staticPopup.button2 = GRA:CreateButton(gra.staticPopup, L["No"], "red", {45, 18}, "GRA_FONT_SMALL")
		gra.staticPopup.button2:SetPoint("BOTTOMRIGHT")
		
		-- yes
		gra.staticPopup.button1 = GRA:CreateButton(gra.staticPopup, L["Yes"], "green", {45, 18}, "GRA_FONT_SMALL")
		gra.staticPopup.button1:SetPoint("RIGHT", gra.staticPopup.button2, "LEFT", 1, 0)
	end

	gra.staticPopup.titleFS:SetText(title)
	gra.staticPopup.textFS:SetText(text)
	-- auto height
	local newHeight = GRA:Round(gra.staticPopup.textFS:GetHeight() + 55)
	gra.staticPopup:SetHeight((newHeight > 100) and newHeight or 100)

	gra.staticPopup.button1:SetScript("OnClick", function()
		if onAccept then onAccept() else --[[do nothing]] end
		gra.staticPopup:Hide()
	end)
	
	gra.staticPopup.button2:SetScript("OnClick", function() 
		if onDecline then onDecline() else --[[do nothing]] end
		gra.staticPopup:Hide()
	end)
	gra.staticPopup:Show()
end

-----------------------------------------
-- create popup (delete/edit/... confirm) with mask
-----------------------------------------
function GRA:CreateConfirmBox(parent, width, text, onAccept, mask)
	if not parent.confirmBox then -- not init
		parent.confirmBox = CreateFrame("Frame", nil, parent)
		parent.confirmBox:SetSize(width, 100)
		GRA:StylizeFrame(parent.confirmBox, {.05, .05, .05, .95}, {0, .7, 1, .7})
		parent.confirmBox:SetFrameStrata("DIALOG")
		parent.confirmBox:SetFrameLevel(2)
		
		parent.confirmBox:SetScript("OnHide", function()
			parent.confirmBox:Hide()
			-- hide mask
			if mask and parent.mask then parent.mask:Hide() end
			-- hide check button if exists, reset height
			-- if parent.confirmBox.cb then
			-- 	parent.confirmBox.cb:ClearAllPoints()
			-- 	parent.confirmBox.cb:Hide()
			-- 	parent.confirmBox:SetHeight(50)
			-- end
		end)

		parent.confirmBox:SetScript("OnShow", function ()
			-- local newHeight = GRA:Round(parent.confirmBox.text:GetHeight() + 30)
			-- parent.confirmBox:SetHeight(newHeight)
		end)
		
		parent.confirmBox.text = parent.confirmBox:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
		parent.confirmBox.text:SetWordWrap(true)
		parent.confirmBox.text:SetSpacing(3)
		parent.confirmBox.text:SetJustifyH("CENTER")
		-- parent.confirmBox.text:SetJustifyV("MIDDLE")
		parent.confirmBox.text:SetPoint("TOPLEFT", 5, -8)
		parent.confirmBox.text:SetPoint("TOPRIGHT", -5, -8)
		-- parent.confirmBox.text:SetPoint("BOTTOMRIGHT", -5, 8)
		
		-- yes
		parent.confirmBox.button1 = GRA:CreateButton(parent.confirmBox, L["Yes"], "green", {35, 15}, "GRA_FONT_SMALL")
		-- button1:SetPoint("BOTTOMRIGHT", -45, 0)
		parent.confirmBox.button1:SetPoint("BOTTOMRIGHT", -34, 0)
		parent.confirmBox.button1:SetBackdropBorderColor(0, .7, 1, .7)
		-- no
		parent.confirmBox.button2 = GRA:CreateButton(parent.confirmBox, L["No"], "red", {35, 15}, "GRA_FONT_SMALL")
		parent.confirmBox.button2:SetPoint("LEFT", parent.confirmBox.button1, "RIGHT", -1, 0)
		parent.confirmBox.button2:SetBackdropBorderColor(0, .7, 1, .7)
		
		-- TODO: add check button on confirmBox
		--[[
		function parent.confirmBox:SetCheckButton(label, onClick)
			if not parent.confirmBox.cb then -- create
				parent.confirmBox.cb = GRA:CreateCheckButton(parent.confirmBox, label, {r=.7, g=.7, b=.7}, onClick, "GRA_FONT_SMALL")
			else -- reuse
				parent.confirmBox.cb.label:SetText(label)
				parent.confirmBox.cb.onClick = onClick
			end
			
			-- space for check button
			parent.confirmBox:SetHeight(70)
			parent.confirmBox.cb:SetPoint("TOPLEFT", parent.confirmBox, GRA:Round((width-(parent.confirmBox.cb.label:GetStringWidth()+32))/2), -25)
			parent.confirmBox.cb:SetChecked(false)
			parent.confirmBox.cb:Show()
		end
		]]
	end

	if mask then -- show mask?
		GRA:CreateMask(parent)
	end

	parent.confirmBox.button1:SetScript("OnClick", function()
		if onAccept then onAccept() end
		-- hide mask
		if mask and parent.mask then parent.mask:Hide() end
		parent.confirmBox:Hide()
	end)

	parent.confirmBox.button2:SetScript("OnClick", function()
		-- hide mask
		if mask and parent.mask then parent.mask:Hide() end
		parent.confirmBox:Hide()
	end)
	
	parent.confirmBox:SetWidth(width)
	parent.confirmBox.text:SetText(text)
	-- TODO: fix this bug
	parent.confirmBox:SetScript("OnUpdate", function(self, elapsed)
		-- local newHeight = GRA:Round(parent.confirmBox.text:GetHeight() + 30)
		local newHeight = parent.confirmBox.text:GetNumLines() * 15 + 25
		parent.confirmBox:SetHeight(newHeight)

		-- parent.confirmBox:SetScript("OnUpdate", nil)
	end)

	parent.confirmBox:ClearAllPoints() -- prepare for SetPoint()
	parent.confirmBox:Show()
	
	return parent.confirmBox
end

-----------------------------------------
-- popup selector
-----------------------------------------
function GRA:CreatePopupSelector(parent, width, items, orientation)
	if not gra.popupSelector then
		gra.popupSelector = CreateFrame("Frame", "GRA_PopupSelector")
		GRA:StylizeFrame(gra.popupSelector)
		gra.popupSelector:SetFrameStrata("DIALOG")

		gra.popupSelector:SetScript("OnHide", function(self)
			self:Hide()
		end)
	end

	for _, b in pairs({gra.popupSelector:GetChildren()}) do
		b:ClearAllPoints()
		b:SetParent(nil)
		b:Hide()
	end

	local last
	for _, item in pairs(items) do
		local b = GRA:CreateButton(gra.popupSelector, item.text, item.color, {width, 20})
		b:SetPushedTextOffset(0, 0)
		b:SetScript("OnClick", function() item.onClick() gra.popupSelector:Hide() end)
		if last then
			if orientation == "VERTICAL" then
				b:SetPoint("TOP", last, "BOTTOM", 0, 1)
			else
				b:SetPoint("LEFT", last, "RIGHT", -1, 0)
			end
		else
			if orientation == "VERTICAL" then
				b:SetPoint("TOP")
			else
				b:SetPoint("LEFT")
			end
		end
		last = b
	end

	if orientation == "VERTICAL" then
		gra.popupSelector:SetSize(width, #items * 19 + 1)
	else
		gra.popupSelector:SetSize(#items * (width-1) + 1, 20)
	end
	gra.popupSelector:ClearAllPoints()
	gra.popupSelector:SetParent(parent)
	gra.popupSelector:Show()

	return gra.popupSelector
end

-----------------------------------------
-- popup edit box
-----------------------------------------
function GRA:CreatePopupEditBox(parent, width, height, onClick)
	if not gra.popupEditBox then
		gra.popupEditBox = CreateFrame("Frame", "GRA_PopupEditBox")
		gra.popupEditBox:SetSize(width, height)
		GRA:StylizeFrame(gra.popupEditBox, {.1, .1, .1, .9}, {.5, 1, 0, .7})
		
		gra.popupEditBox:SetScript("OnHide", function(self)
			self:Hide() -- hide self when parent hides
		end)

		local eb = CreateFrame("EditBox", nil, gra.popupEditBox)
		gra.popupEditBox.editBox = eb
		eb:SetFontObject("GRA_FONT_TEXT")
		eb:SetMultiLine(false)
		eb:SetMaxLetters(0)
		eb:SetHeight(height-2)
		eb:SetTextInsets(5, 5, 0, 0)
		GRA:StylizeFrame(eb, {.1, .1, .1, .9})
		
		local cancelBtn = GRA:CreateButton(gra.popupEditBox, "×", "red", {height-2, height-2}, "GRA_FONT_BUTTON")
		gra.popupEditBox.cancelBtn = cancelBtn
		cancelBtn:SetPoint("RIGHT", -1, 0)
		cancelBtn:SetScript("OnClick", function()
			-- PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			eb:SetText("")
			gra.popupEditBox:Hide()
		end)

		local acceptBtn = GRA:CreateButton(gra.popupEditBox, "√", "green", {height-2, height-2}, "GRA_FONT_SMALL")
		gra.popupEditBox.acceptBtn = acceptBtn
		acceptBtn:SetPoint("RIGHT", cancelBtn, "LEFT", 1, 0)

		eb:SetPoint("TOPLEFT", 1, -1)
		eb:SetPoint("BOTTOMRIGHT", acceptBtn, "BOTTOMLEFT", 1, 0)
		
		eb:SetScript("OnEscapePressed", function()
			eb:SetText("")
			gra.popupEditBox:Hide()
		end)
		
		eb:SetScript("OnEnterPressed", function()
			acceptBtn:Click("LeftButton", true) -- click acceptBtn
		end)

		function gra.popupEditBox:SetText(text)
			eb:SetText(text)
		end
	end
	
	gra.popupEditBox.acceptBtn:SetScript("OnClick", function()
		-- PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
		-- GRA:Debug("editbox: " .. gra.popupEditBox.editBox:GetText())
		if onClick then onClick(string.trim(gra.popupEditBox.editBox:GetText())) end
		gra.popupEditBox:Hide()
		gra.popupEditBox.editBox:SetText("")
	end)
	
	-- set parent(for hiding) & size
	gra.popupEditBox:ClearAllPoints()
	gra.popupEditBox:SetParent(parent)
	gra.popupEditBox:SetSize(width, height)
	gra.popupEditBox:Show()
	
	gra.popupEditBox:SetFrameStrata("DIALOG")
	return gra.popupEditBox
end
