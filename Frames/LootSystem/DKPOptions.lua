local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

-----------------------------------------
-- dkp options frame
-----------------------------------------
local dkpOptionsFrame = GRA:CreateFrame(L["DKP Options"], "GRA_DKPOptionsFrame", gra.mainFrame, 164, gra.mainFrame:GetHeight())
gra.dkpOptionsFrame = dkpOptionsFrame
dkpOptionsFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
dkpOptionsFrame.header.closeBtn:SetText("←")
local fontName = dkpOptionsFrame.header.closeBtn:GetFontString():GetFont()
dkpOptionsFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
dkpOptionsFrame.header.closeBtn:SetScript("OnClick", function() dkpOptionsFrame:Hide() gra.configFrame:Show() end)

-----------------------------------------
-- enable dkp
-----------------------------------------
local function ShowMask(f)
	if f then
		-- show mask
		GRA:CreateMask(dkpOptionsFrame, L["DKP is disabled"], {1, -40, -1, 1})
	else
		-- hide mask if exists
		if dkpOptionsFrame.mask then dkpOptionsFrame.mask:Hide() end
	end
end

local dkpCB = GRA:CreateCheckButton(dkpOptionsFrame, L["Enable DKP"], nil, function(checked, cb)
	-- restore check stat
	cb:SetChecked(_G[GRA_R_Config]["raidInfo"]["system"] == "DKP")

	local text
	if _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
		text = gra.colors.firebrick.s .. L["Disable DKP?"]
	else
		text = gra.colors.firebrick.s .. L["Enable DKP?"] .. "|r\n" .. L["DKP system stores its data in officer notes.\nYou'd better back up your officer notes before using DKP.\nAnd you should revoke the privilege to edit officer note from most of guild members."]
	end
	-- confirm box
	local confirm = GRA:CreateConfirmPopup(dkpOptionsFrame, dkpOptionsFrame:GetWidth()-10, text, function()
		_G[GRA_R_Config]["raidInfo"]["system"] = (_G[GRA_R_Config]["raidInfo"]["system"] == "DKP") and "" or "DKP"
		ShowMask(_G[GRA_R_Config]["raidInfo"]["system"] ~= "DKP")
		cb:SetChecked(_G[GRA_R_Config]["raidInfo"]["system"] == "DKP")
		-- enable/disable DKP
		GRA:SetDKPEnabled(_G[GRA_R_Config]["raidInfo"]["system"] == "DKP")
	end)
	confirm:SetPoint("TOP", 0, -45)
end, "GRA_FONT_SMALL", L["Enable DKP"], L["Check to use DKP system for your raid team."])
dkpCB:SetPoint("TOPLEFT", 5, -14)

-----------------------------------------
-- sheet column
-----------------------------------------
-- local columnText = dkpOptionsFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
-- columnText:SetText("|cff80FF00"..L["Columns"].."|r")
-- columnText:SetPoint("TOPLEFT", 5, -47)
-- GRA:CreateSeperator(dkpOptionsFrame, columnText)

-- local showTotal = GRA:CreateCheckButton(dkpOptionsFrame, L["Enable DKP"], nil, function(checked, cb)

-- end)

-- local showSpent = GRA:CreateCheckButton(dkpOptionsFrame, L["Enable DKP"], nil, function(checked, cb)

-- end)

-----------------------------------------
-- decay
-----------------------------------------
local decayText = dkpOptionsFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
decayText:SetText("|cff80FF00"..L["Decay"].."|r")
decayText:SetPoint("TOPLEFT", 5, -47)
GRA:CreateSeperator(dkpOptionsFrame, decayText)

local decayEditBox = GRA:CreateEditBox(dkpOptionsFrame, 120, 20, true, "GRA_FONT_SMALL")
decayEditBox:SetPoint("TOPLEFT", decayText, 0, -20)

local decaySetBtn = GRA:CreateButton(dkpOptionsFrame, L["Set"], nil, {35, 20})
decaySetBtn:SetPoint("LEFT", decayEditBox, "RIGHT", -1, 0)
decaySetBtn:SetScript("OnClick", function()
	decayEditBox:ClearFocus()
	local decay = decayEditBox:GetNumber()
	decayEditBox:SetNumber(decay)
	_G[GRA_R_Config]["raidInfo"]["DKP"] = decay
	GRA:ShowNotificationString(dkpOptionsFrame, gra.colors.firebrick.s .. L["Decay has been set to "] .. decay .. "%", "TOPLEFT", decayEditBox, "BOTTOMLEFT", 0, -3)

	gra.attendanceFrame:UpdateRaidInfoStrings()
end)

decayEditBox:SetScript("OnTextChanged", function()
	if decayEditBox:GetText() == "" then
		decaySetBtn:SetEnabled(false)
	else
		decaySetBtn:SetEnabled(decayEditBox:GetNumber() <= 100)
	end
end)

local decayNowEditBox = GRA:CreateEditBox(dkpOptionsFrame, 75, 20, true, "GRA_FONT_SMALL")
decayNowEditBox:SetPoint("TOPLEFT", decayText, 0, -60)

local decayNowBtn = GRA:CreateButton(dkpOptionsFrame, L["Decay Now!"], "red", {80, 20})
decayNowBtn:SetPoint("LEFT", decayNowEditBox, "RIGHT", -1, 0)
decayNowBtn:SetScript("OnClick", function()
	decayNowEditBox:ClearFocus()
	local decayP = (decayNowEditBox:GetNumber() >= 100) and 100 or decayNowEditBox:GetNumber()
	if decayP == 0 then return end

	local confirm = GRA:CreateConfirmPopup(dkpOptionsFrame, dkpOptionsFrame:GetWidth()-10, gra.colors.firebrick.s .. string.format(L["Decay DKP by %d%%?"], decayP), function()
		GRA:DecayDKP(decayP)
    	SendChatMessage("GRA: " .. L["Decayed DKP by %d%%."]:format(decayP), "GUILD")
	end, true)
	confirm:SetPoint("TOPLEFT", decayNowEditBox)
end)

-----------------------------------------
-- decay static popup
-----------------------------------------
GRA:RegisterEvent("GRA_PERMISSION", "DecayDKP_CheckPermissions", function(isAdmin)
	-- _G[GRA_R_Config]["lastDecayed"] = "20171130"
	if (not isAdmin) or (_G[GRA_R_Config]["raidInfo"]["system"] ~= "DKP") or (_G[GRA_R_Config]["raidInfo"]["DKP"] == 0) then return end

	local current = GRA:GetLockoutsResetDate()
	-- init
	_G[GRA_R_Config]["lastDecayed"] = _G[GRA_R_Config]["lastDecayed"] or current
	
	if _G[GRA_R_Config]["lastDecayed"] < current then
		if current == GRA:Date() then -- reset day, but may not reset yet
			local resetDay = date("%Y%m%d", time() + GetQuestResetTime())
			if resetDay == current then return end -- not reset yet
		end

		C_Timer.After(2, function()
			local decayP = _G[GRA_R_Config]["raidInfo"]["DKP"]
			GRA:CreateStaticPopup(L["Decay DKP"], L["Decay DKP by %d%%?"]:format(decayP)
			.. "\n" .. gra.colors.grey.s .. L["Yes - Decay DKP now.\nNo - Don't ask again this week."], function()
				_G[GRA_R_Config]["lastDecayed"] = current
				GRA:DecayDKP(decayP)
				SendChatMessage("GRA: " .. L["Decayed DKP by %d%%."]:format(decayP), "GUILD")
			end, function()
				_G[GRA_R_Config]["lastDecayed"] = current
			end)
		end)
	end
end)

-----------------------------------------
-- reset
-----------------------------------------
local resetBtn = GRA:CreateButton(dkpOptionsFrame, L["Reset DKP"], "red", {dkpOptionsFrame:GetWidth()-10, 20}, "GRA_FONT_SMALL")
resetBtn:SetPoint("BOTTOMLEFT", 5, 5)
resetBtn:SetScript("OnClick", function()
	local confirm = GRA:CreateConfirmPopup(dkpOptionsFrame, dkpOptionsFrame:GetWidth()-10, gra.colors.firebrick.s .. L["Reset DKP?"], function()
		GRA:ResetDKP()
	end, true)
	confirm:SetPoint("BOTTOM", resetBtn, "TOP", 0, 10)
end)

dkpOptionsFrame:SetScript("OnShow", function()
	dkpCB:SetChecked(_G[GRA_R_Config]["raidInfo"]["system"] == "DKP")
	ShowMask(not (_G[GRA_R_Config]["raidInfo"]["system"] == "DKP"))
	decayEditBox:SetText(_G[GRA_R_Config]["raidInfo"]["DKP"])
end)

dkpOptionsFrame:SetScript("OnHide", function()
	dkpOptionsFrame:Hide()
end)