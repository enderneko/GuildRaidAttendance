local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

-----------------------------------------
-- epgp options frame
-----------------------------------------
local epgpOptionsFrame = GRA:CreateFrame(L["EPGP Options"], "GRA_EPGPOptionsFrame", gra.mainFrame, 164, gra.mainFrame:GetHeight())
gra.epgpOptionsFrame = epgpOptionsFrame
epgpOptionsFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
epgpOptionsFrame.header.closeBtn:SetText("←")
local fontName = epgpOptionsFrame.header.closeBtn:GetFontString():GetFont()
epgpOptionsFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
epgpOptionsFrame.header.closeBtn:SetScript("OnClick", function() epgpOptionsFrame:Hide() gra.configFrame:Show() end)

local LGN = LibStub:GetLibrary("LibGuildNotes")
local function ResetEPGP()
	local players = GRA:GetPlayers()
	for _, player in pairs(players) do
		LGN:SetOfficerNote(player, "0,0")
	end
end

-----------------------------------------
-- enable epgp
-----------------------------------------
local function ShowMask(f)
	if f then
		-- show mask
		GRA:CreateMask(epgpOptionsFrame, L["EPGP is disabled"], {1, -40, -1, 1})
	else
		-- hide mask if exists
		if epgpOptionsFrame.mask then epgpOptionsFrame.mask:Hide() end
	end
end

local epgpCB = GRA:CreateCheckButton(epgpOptionsFrame, L["Enable EPGP"], nil, function(checked, cb)
	-- restore check stat
	cb:SetChecked(_G[GRA_R_Config]["useEPGP"])

	local text
	if _G[GRA_R_Config]["useEPGP"] then
		text = gra.colors.firebrick.s .. L["Disable EPGP?"]
	else
		text = gra.colors.firebrick.s .. L["Enable EPGP?"] .. "|r\n" .. L["EPGP system stores its data in officer notes.\nYou'd better back up your officer notes before using EPGP.\nAnd you should revoke the privilege to edit officer note from most of guild members."]
	end
	-- confirm box
	local confirm = GRA:CreateConfirmBox(epgpOptionsFrame, epgpOptionsFrame:GetWidth()-10, text, function()
		_G[GRA_R_Config]["useEPGP"] = not _G[GRA_R_Config]["useEPGP"]
		ShowMask(not _G[GRA_R_Config]["useEPGP"])
		cb:SetChecked(_G[GRA_R_Config]["useEPGP"])
		-- enable/disable EPGP
		GRA:SetEPGPEnabled(_G[GRA_R_Config]["useEPGP"])
	end)
	confirm:SetPoint("TOP", 0, -45)
end, "GRA_FONT_SMALL", L["Enable EPGP"], L["Check to use EPGP system for your raid team."])
epgpCB:SetPoint("TOPLEFT", 5, -14)

-----------------------------------------
-- baseGP
-----------------------------------------
local baseGPText = epgpOptionsFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
baseGPText:SetText("|cff80FF00"..L["Base GP"].."|r")
baseGPText:SetPoint("TOPLEFT", 5, -47)
GRA:CreateSeperator(epgpOptionsFrame, baseGPText)

local baseGPEditbox = GRA:CreateEditBox(epgpOptionsFrame, 120, 20, true, "GRA_FONT_SMALL")
baseGPEditbox:SetPoint("TOPLEFT", baseGPText, 0, -20)

local baseGPSetBtn = GRA:CreateButton(epgpOptionsFrame, L["Set"], nil, {35, 20})
baseGPSetBtn:SetPoint("LEFT", baseGPEditbox, "RIGHT", -1, 0)
baseGPSetBtn:SetScript("OnClick", function()
	baseGPEditbox:ClearFocus()
	local baseGP = baseGPEditbox:GetNumber()
	baseGPEditbox:SetNumber(baseGP)
	_G[GRA_R_Config]["raidInfo"]["EPGP"][1] = baseGP
	GRA:ShowNotificationString(gra.colors.firebrick.s .. L["Base GP has been set to "] .. baseGP, "TOPLEFT", baseGPEditbox, "BOTTOMLEFT", 0, -3)
	GRA:RecalcPR()

	gra.attendanceFrame:UpdateEPGPStrings()
end)

baseGPEditbox:SetScript("OnTextChanged", function()
	if baseGPEditbox:GetText() == "" then
		baseGPSetBtn:SetEnabled(false)
	else
		baseGPSetBtn:SetEnabled(tonumber(baseGPEditbox:GetText()) > 0)
	end
end)

-----------------------------------------
-- minEP
-----------------------------------------
local minEPText = epgpOptionsFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
minEPText:SetText("|cff80FF00"..L["Min EP"].."|r")
minEPText:SetPoint("TOPLEFT", 5, -107)
GRA:CreateSeperator(epgpOptionsFrame, minEPText)

local minEPEditBox = GRA:CreateEditBox(epgpOptionsFrame, 120, 20, true, "GRA_FONT_SMALL")
minEPEditBox:SetPoint("TOPLEFT", minEPText, 0, -20)

local minEPSetBtn = GRA:CreateButton(epgpOptionsFrame, L["Set"], nil, {35, 20})
minEPSetBtn:SetPoint("LEFT", minEPEditBox, "RIGHT", -1, 0)
minEPSetBtn:SetScript("OnClick", function()
	minEPEditBox:ClearFocus()
	local minEP = minEPEditBox:GetNumber()
	minEPEditBox:SetNumber(minEP)
	_G[GRA_R_Config]["raidInfo"]["EPGP"][2] = minEP
	GRA:ShowNotificationString(gra.colors.firebrick.s .. L["Min EP has been set to "] .. minEP, "TOPLEFT", minEPEditBox, "BOTTOMLEFT", 0, -3)
	GRA:RecalcPR()

	gra.attendanceFrame:UpdateEPGPStrings()
end)

-----------------------------------------
-- decay
-----------------------------------------
local decayText = epgpOptionsFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
decayText:SetText("|cff80FF00"..L["Decay"].."|r")
decayText:SetPoint("TOPLEFT", 5, -167)
GRA:CreateSeperator(epgpOptionsFrame, decayText)

local decayEditBox = GRA:CreateEditBox(epgpOptionsFrame, 76, 20, true, "GRA_FONT_SMALL")
decayEditBox:SetPoint("TOPLEFT", decayText, 0, -20)

local decaySetBtn = GRA:CreateButton(epgpOptionsFrame, L["Set"], nil, {35, 20})
decaySetBtn:SetPoint("LEFT", decayEditBox, "RIGHT", -1, 0)
decaySetBtn:SetScript("OnClick", function()
	decayEditBox:ClearFocus()
	local decay = decayEditBox:GetNumber()
	decayEditBox:SetNumber(decay)
	_G[GRA_R_Config]["raidInfo"]["EPGP"][3] = decay
	GRA:ShowNotificationString(gra.colors.firebrick.s .. L["Decay has been set to "] .. decay, "TOPLEFT", decayEditBox, "BOTTOMLEFT", 0, -3)

	gra.attendanceFrame:UpdateEPGPStrings()
end)

local decayBtn = GRA:CreateButton(epgpOptionsFrame, L["Decay"], "red", {45, 20})
decayBtn:SetPoint("LEFT", decaySetBtn, "RIGHT", -1, 0)
decayBtn:SetScript("OnClick", function()
	local confirm = GRA:CreateConfirmBox(epgpOptionsFrame, epgpOptionsFrame:GetWidth()-10, gra.colors.firebrick.s .. string.format(L["Decay EP and GP by %d%%?"], _G[GRA_R_Config]["raidInfo"]["EPGP"][3]), function()
		GRA:Decay()
		-- TODO: announce channel
    	SendChatMessage("GRA: " .. L["Decayed EP and GP by %d%%."]:format(_G[GRA_R_Config]["raidInfo"]["EPGP"][3]), "GUILD")
	end, true)
	confirm:SetPoint("TOPLEFT", decayEditBox, "BOTTOMLEFT", 0, -20)
end)

decayEditBox:SetScript("OnTextChanged", function()
	if decayEditBox:GetText() == "" then
		decaySetBtn:SetEnabled(false)
	else
		decaySetBtn:SetEnabled(decayEditBox:GetNumber() <= 100)
	end
end)

-----------------------------------------
-- announce
-----------------------------------------
-- TODO: announce channel

-----------------------------------------
-- reset
-----------------------------------------
local resetBtn = GRA:CreateButton(epgpOptionsFrame, L["Reset EPGP"], "red", {epgpOptionsFrame:GetWidth()-10, 20}, "GRA_FONT_SMALL")
resetBtn:SetPoint("BOTTOMLEFT", 5, 5)
resetBtn:SetScript("OnClick", function()
	local confirm = GRA:CreateConfirmBox(epgpOptionsFrame, epgpOptionsFrame:GetWidth()-10, gra.colors.firebrick.s .. L["Reset EP and GP?"], function()
		ResetEPGP()
	end, true)
	confirm:SetPoint("BOTTOM", resetBtn, "TOP", 0, 10)
end)

epgpOptionsFrame:SetScript("OnShow", function()
	epgpCB:SetChecked(_G[GRA_R_Config]["useEPGP"])
	ShowMask(not _G[GRA_R_Config]["useEPGP"])
	baseGPEditbox:SetText(_G[GRA_R_Config]["raidInfo"]["EPGP"][1])
	minEPEditBox:SetText(_G[GRA_R_Config]["raidInfo"]["EPGP"][2])
	decayEditBox:SetText(_G[GRA_R_Config]["raidInfo"]["EPGP"][3])
end)

epgpOptionsFrame:SetScript("OnHide", function()
	epgpOptionsFrame:Hide()
end)

if GRA:Debug() then
	-- GRA:StylizeFrame(epgpOptionsFrame, {0, .7, 0, .1}, {0, 0, 0, 1})
end