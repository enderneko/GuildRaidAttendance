local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

-----------------------------------------
-- config frame 
-----------------------------------------
local configFrame = GRA:CreateFrame(L["Config"], "GRA_ConfigFrame", gra.mainFrame, 191, gra.mainFrame:GetHeight())
gra.configFrame = configFrame
configFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)

-----------------------------------------
-- roster settings
-----------------------------------------
local rosterSection = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
rosterSection:SetText("|cff80FF00"..L["Roster"].."|r")
rosterSection:SetPoint("TOPLEFT", 5, -5)
GRA:CreateSeparator(configFrame, rosterSection)

-- for showing mask
local rosterFrame = CreateFrame("Frame", nil, configFrame)
rosterFrame:SetPoint("TOPLEFT", rosterSection, 0, -20)
rosterFrame:SetPoint("BOTTOMRIGHT", rosterSection, "TOPLEFT", configFrame:GetWidth()-10, -80)
-----------------------------------------
-- roster settings (user)
-----------------------------------------
local rosterUserFrame = CreateFrame("Frame", nil, rosterFrame)
rosterUserFrame:SetAllPoints(rosterFrame)
rosterUserFrame:Hide()

local rosterUserMinimalModeCB = GRA:CreateCheckButton(rosterUserFrame, L["Minimal Mode"], nil, function(checked, cb)
	cb:SetChecked(GRA_Variables["minimalMode"])
	local text 
	if GRA_Variables["minimalMode"] then
		text = L["Switch to full mode?"]
	else
		text = L["Switch to minimal mode?\nYou cannot receive raid logs in this mode."]
	end
	
	local confirm = GRA:CreateConfirmPopup(configFrame, configFrame:GetWidth()-10, text, function()
		GRA_Variables["minimalMode"] = not GRA_Variables["minimalMode"]
		cb:SetChecked(GRA_Variables["minimalMode"])
		GRA:FireEvent("GRA_MINI", GRA_Variables["minimalMode"])
	end, true)
	confirm:SetPoint("TOP", 0, -45)
end, "GRA_FONT_SMALL")
rosterUserMinimalModeCB:SetPoint("TOPLEFT")

local rosterUserLastUpdatedText = rosterUserFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
rosterUserLastUpdatedText:SetJustifyH("LEFT")
rosterUserLastUpdatedText:SetJustifyV("MIDDLE")
rosterUserLastUpdatedText:SetPoint("TOPLEFT", 0, -20)
rosterUserLastUpdatedText:SetWidth(rosterUserFrame:GetWidth())
rosterUserLastUpdatedText:SetWordWrap(false)

-----------------------------------------
-- roster settings (admin)
-----------------------------------------
local rosterAdminFrame = CreateFrame("Frame", nil, rosterFrame)
rosterAdminFrame:SetAllPoints(rosterFrame)
rosterAdminFrame:Hide()

local editBtn = GRA:CreateButton(rosterAdminFrame, L["Edit"], nil, {61, 18}, "GRA_FONT_SMALL")
editBtn:SetPoint("TOPLEFT")
editBtn:SetScript("OnClick", function()
	configFrame:Hide()
	gra.rosterEditorFrame:Show()
end)

local importBtn = GRA:CreateButton(rosterAdminFrame, L["Import"], nil, {61, 18}, "GRA_FONT_SMALL")
importBtn:SetPoint("LEFT", editBtn, "RIGHT", -1, 0)
importBtn:SetScript("OnClick", function()
	configFrame:Hide()
	gra.importFrame:Show()
end)

local sendRosterBtn = GRA:CreateButton(rosterAdminFrame, L["Send"], nil, {61, 18}, "GRA_FONT_SMALL", false,
	L["Send roster data to raid members"],
	L["GRA must be installed to receive data."],
	L["Raid members data (including attendance rate)."],
	gra.colors.firebrick.s .. L["Raid schedule settings."],
	gra.colors.firebrick.s .. L["Loot system settings (important)."])
sendRosterBtn:SetPoint("LEFT", importBtn, "RIGHT", -1, 0)
sendRosterBtn:SetScript("OnClick", function()
	local confirm = GRA:CreateConfirmPopup(configFrame, configFrame:GetWidth()-10, L["Send raid roster data to raid/party members?"], function()
		GRA:SendRosterToRaid()
	end, true)
	confirm:SetPoint("TOPRIGHT", sendRosterBtn)
end)

local exportBtn = GRA:CreateButton(rosterAdminFrame, L["Export CSV"], "red", {91, 20}, "GRA_FONT_SMALL")
exportBtn:SetPoint("TOPLEFT", editBtn, "BOTTOMLEFT", 0, -5)
exportBtn:SetScript("OnClick", function()
	GRA:ShowExportFrame()
end)

local epgpOptionsBtn = GRA:CreateButton(rosterAdminFrame, L["EPGP Options"], "red", {91, 20}, "GRA_FONT_SMALL")
epgpOptionsBtn:SetPoint("LEFT", exportBtn, "RIGHT", -1, 0)
epgpOptionsBtn:SetScript("OnClick", function()
	configFrame:Hide()
	gra.epgpOptionsFrame:Show()
end)
epgpOptionsBtn:SetEnabled(true)

--[[
local dkpOptionsBtn = GRA:CreateButton(rosterAdminFrame, L["DKP Options"], "red", {91, 20}, "GRA_FONT_SMALL")
dkpOptionsBtn:SetPoint("LEFT", epgpOptionsBtn, "RIGHT", -1, 0)
dkpOptionsBtn:SetScript("OnClick", function()
	configFrame:Hide()
	gra.dkpOptionsFrame:Show()
end)
dkpOptionsBtn:SetEnabled(true)
]]

-----------------------------------------
-- attendance sheet settings
-----------------------------------------
local sheetSection = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
sheetSection:SetText("|cff80FF00"..L["Attendance Sheet"].."|r")
sheetSection:SetPoint("TOPLEFT", 5, -95)
GRA:CreateSeparator(configFrame, sheetSection)

local sheetText = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
sheetText:SetJustifyH("LEFT")
sheetText:SetJustifyV("TOP")
sheetText:SetText(L["Date Columns"])
sheetText:SetPoint("TOPLEFT", sheetSection, 0, -20)
sheetText:SetWidth(configFrame:GetWidth()-10)
sheetText:SetWordWrap(false)

-- if sheetText:IsTruncated() then print("") end

-- Weekdays -----------------------------
local daysFrame = CreateFrame("Frame", nil, configFrame)
-- GRA:StylizeFrame(daysFrame)
daysFrame:SetSize(configFrame:GetWidth()-10, 42)
daysFrame:SetPoint("TOPLEFT", sheetSection, 0, -33)

local days = {} -- {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
days[1] = GRA:CreateCheckButton(daysFrame, L["Sun"], nil, nil, "GRA_FONT_SMALL")
days[2] = GRA:CreateCheckButton(daysFrame, L["Mon"], nil, nil, "GRA_FONT_SMALL")
days[3] = GRA:CreateCheckButton(daysFrame, L["Tue"], nil, nil, "GRA_FONT_SMALL")
days[4] = GRA:CreateCheckButton(daysFrame, L["Wed"], nil, nil, "GRA_FONT_SMALL")
days[5] = GRA:CreateCheckButton(daysFrame, L["Thu"], nil, nil, "GRA_FONT_SMALL")
days[6] = GRA:CreateCheckButton(daysFrame, L["Fri"], nil, nil, "GRA_FONT_SMALL")
days[7] = GRA:CreateCheckButton(daysFrame, L["Sat"], nil, nil, "GRA_FONT_SMALL")

-- highlight the RAID_LOCKOUTS_RESET day
days[gra.RAID_LOCKOUTS_RESET].label:SetTextColor(1, .2, .2)

local temp = gra.RAID_LOCKOUTS_RESET
for i = 1, 7 do
	if i == 1 then days[temp]:SetPoint("TOPLEFT", 0, -2)
	elseif i == 2 then days[temp]:SetPoint("TOPLEFT", 45, -2)
	elseif i == 3 then days[temp]:SetPoint("TOPLEFT", 90, -2)
	elseif i == 4 then days[temp]:SetPoint("TOPLEFT", 135, -2)
	elseif i == 5 then days[temp]:SetPoint("TOPLEFT", 0, -22)
	elseif i == 6 then days[temp]:SetPoint("TOPLEFT", 45, -22)
	elseif i == 7 then days[temp]:SetPoint("TOPLEFT", 90, -22)
	end
	temp = (temp == 7) and 1 or (temp + 1)
end
-----------------------------------------

local setBtn = GRA:CreateButton(configFrame, "", nil, {18, 18}, "GRA_FONT_SMALL")
-- setBtn:SetPoint("TOPRIGHT", daysFrame, "BOTTOMRIGHT", 0, -2)
setBtn:SetPoint("BOTTOMRIGHT", daysFrame, -27, 3)
setBtn:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\RefreshArrow]])
setBtn:SetPushedTexture([[Interface\AddOns\GuildRaidAttendance\Media\RefreshArrowPushed]])
setBtn:SetDisabledTexture([[Interface\AddOns\GuildRaidAttendance\Media\RefreshArrowDisabled]])
setBtn:SetScript("OnClick", function()
	local temp = {}
	for i = 1, 7 do
		if days[i]:GetChecked() then -- checked
			table.insert(temp, i)
		end
	end
	if #temp == 0 then -- select none
		temp = {gra.RAID_LOCKOUTS_RESET}
		days[gra.RAID_LOCKOUTS_RESET]:SetChecked(true) -- force
	end 
	_G[GRA_R_Config]["raidInfo"]["days"] = temp
	GRA:Debug("raidInfo: " .. GRA:TableToString(temp))

	GRA:ShowAttendanceSheet()
end)

-- columns ------------------------------
local columnText = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
columnText:SetText(L["Attendance Rate Columns"])
columnText:SetPoint("TOPLEFT", daysFrame, "BOTTOMLEFT", 0, -4)

local ar30CB = GRA:CreateCheckButton(daysFrame, L["30 days"], nil, function(checked)
	GRA_Variables["columns"]["AR_30"] = checked
	GRA:SetColumns()
end, "GRA_FONT_SMALL")

local ar60CB = GRA:CreateCheckButton(daysFrame, L["60 days"], nil, function(checked)
	GRA_Variables["columns"]["AR_60"] = checked
	GRA:SetColumns()
end, "GRA_FONT_SMALL")

local ar90CB = GRA:CreateCheckButton(daysFrame, L["90 days"], nil, function(checked)
	GRA_Variables["columns"]["AR_90"] = checked
	GRA:SetColumns()
end, "GRA_FONT_SMALL")

local arCB = GRA:CreateCheckButton(daysFrame, L["Lifetime"], nil, function(checked)
	GRA_Variables["columns"]["AR_Lifetime"] = checked
	GRA:SetColumns()
end, "GRA_FONT_SMALL")

local sitOutCB = GRA:CreateCheckButton(daysFrame, L["Sit Out"], nil, function(checked)
	GRA_Variables["columns"]["Sit_Out"] = checked
	GRA:SetColumns()
end, "GRA_FONT_SMALL")

ar30CB:SetPoint("TOPLEFT", columnText, "BOTTOMLEFT", 0, -4)
ar60CB:SetPoint("LEFT", ar30CB, "RIGHT", 67, 0)
ar90CB:SetPoint("TOPLEFT", columnText, "BOTTOMLEFT", 0, -24)
arCB:SetPoint("LEFT", ar90CB, "RIGHT", 67, 0)
sitOutCB:SetPoint("TOPLEFT", columnText, "BOTTOMLEFT", 0, -44)

-- AR calculation -----------------------
local arCalculationText = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
arCalculationText:Hide()
arCalculationText:SetPoint("TOPLEFT", daysFrame, "BOTTOMLEFT", 0, -82)
arCalculationText:SetText(L["AR Calculation Method"] .. ": ")

local arcmBtn2 = GRA:CreateButton(configFrame, L["B"], nil, {25, 18}, "GRA_FONT_SMALL", false,
	L["Method"] .. " B", L["AR = PRESENT / ALL RAID DAYS"])
arcmBtn2:Hide()
arcmBtn2:SetPoint("TOPRIGHT", daysFrame, "BOTTOMRIGHT", 0, -78) -- not point to arCalculationText to make pixelperfectpoint

local arcmBtn1 = GRA:CreateButton(configFrame, L["A"], nil, {25, 18}, "GRA_FONT_SMALL", false,
	L["Method"] .. " A", L["AR = PRESENT / (PRESENT + ABSENT)"])
arcmBtn1:Hide()
arcmBtn1:SetPoint("RIGHT", arcmBtn2, "LEFT", 1, 0)

local function SetARCalculationMethod(method)
	if _G[GRA_R_Config]["arCalculationMethod"] ~= method then
		_G[GRA_R_Config]["arCalculationMethod"] = method
		GRA:FireEvent("GRA_ARCM", method)
		GRA:Print(L["Attendance rate calculation method has been changed."])
	end
end
local arcms = GRA:CreateButtonGroup(SetARCalculationMethod, arcmBtn1, arcmBtn2)

-- raid hours ---------------------------
local raidHoursTitle = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
raidHoursTitle:SetPoint("TOPLEFT", daysFrame, "BOTTOMLEFT", 0, -82)
raidHoursTitle:SetText(L["Raid Hours"] .. ": ")

local raidHoursText = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
raidHoursText:Hide()
raidHoursText:SetPoint("LEFT", raidHoursTitle, "RIGHT", 5, 0)

local raidStartTimeEditBox, raidEndTimeEditBox, rstConfirmBtn, retConfirmBtn = GRA:CreateRaidHoursEditBox(configFrame, 
function(startTime)
	_G[GRA_R_Config]["raidInfo"]["startTime"] = startTime
end, function(endTime)
	_G[GRA_R_Config]["raidInfo"]["endTime"] = endTime
end)

rstConfirmBtn:HookScript("OnClick", function()
	GRA:ShowNotificationString(configFrame, gra.colors.firebrick.s .. L["Raid hours has been updated."], "TOPRIGHT", raidEndTimeEditBox, "BOTTOMRIGHT", 0, -5)
end)

retConfirmBtn:HookScript("OnClick", function()
	GRA:ShowNotificationString(configFrame, gra.colors.firebrick.s .. L["Raid hours has been updated."], "TOPRIGHT", raidEndTimeEditBox, "BOTTOMRIGHT", 0, -5)
end)

raidEndTimeEditBox:Hide()
raidEndTimeEditBox:SetPoint("TOPRIGHT", daysFrame, "BOTTOMRIGHT", 0, -78) -- not point to raidHoursTitle to make pixelperfectpoint
raidStartTimeEditBox:Hide()
raidStartTimeEditBox:SetPoint("RIGHT", raidEndTimeEditBox, "LEFT", -12, 0)

rstConfirmBtn:ClearAllPoints()
rstConfirmBtn:SetPoint("TOP", raidStartTimeEditBox, "BOTTOM", 0, 1)
rstConfirmBtn:SetSize(50, 15)
retConfirmBtn:ClearAllPoints()
retConfirmBtn:SetPoint("TOP", raidEndTimeEditBox, "BOTTOM", 0, 1)
retConfirmBtn:SetSize(50, 15)

local raidHoursTo = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
raidHoursTo:SetText("-")
raidHoursTo:Hide()
raidHoursTo:SetPoint("RIGHT", raidEndTimeEditBox, "LEFT", -3, 0)

raidStartTimeEditBox:SetScript("OnEnter", function(self)
	GRA_Tooltip:SetOwner(self, "ANCHOR_TOP", 0, 1)
	GRA_Tooltip:AddLine(L["Raid Start Time"])
	GRA_Tooltip:AddLine(L["Join after \"Raid Start Time\" means the member is late.\n\nIt's used as default raid start time for each day, you can set a different time in attendance editor."], 1, 1, 1, true)
	GRA_Tooltip:SetWidth(250)
	GRA_Tooltip:Show()
end)

raidEndTimeEditBox:SetScript("OnEnter", function(self)
	GRA_Tooltip:SetOwner(self, "ANCHOR_TOP", 0, 1)
	GRA_Tooltip:AddLine(L["Raid End Time"])
	GRA_Tooltip:AddLine(L["Leave before \"Raid End Time\" means the member leaves early.\n\nIt's used as default raid end time for each day, you can set a different time in attendance editor."], 1, 1, 1, true)
	GRA_Tooltip:SetWidth(250)
	GRA_Tooltip:Show()
end)
----------------------------------------

local function RefreshRaidSchedule()
	for i = 1, 7 do
		if GRA:TContains(_G[GRA_R_Config]["raidInfo"]["days"], i) then -- raid day
			days[i]:SetChecked(true)
		else
			days[i]:SetChecked(false)
		end
	end

	local startTime = _G[GRA_R_Config]["raidInfo"]["startTime"]
	local endTime = _G[GRA_R_Config]["raidInfo"]["endTime"]
	if startTime and endTime then
		raidStartTimeEditBox:SetText(startTime)
		raidEndTimeEditBox:SetText(endTime)
		raidHoursText:SetText("|cff0080FF" .. startTime .. " - " .. endTime)
	end
end

-----------------------------------------
-- misc
-----------------------------------------
local miscSection = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
miscSection:SetText("|cff80FF00"..L["Misc"].."|r")
miscSection:SetPoint("TOPLEFT", 5, -320)
GRA:CreateSeparator(configFrame, miscSection)

local appearanceBtn = GRA:CreateButton(configFrame, L["Appearance"], "red", {91, 20}, "GRA_FONT_SMALL")
appearanceBtn:SetPoint("TOPLEFT", miscSection, 0, -20)
appearanceBtn:SetScript("OnClick", function()
	configFrame:Hide()
	gra.appearanceFrame:Show()
end)

local lootDistrBtn = GRA:CreateButton(configFrame, L["Loot Distr"], "red", {91, 20}, "GRA_FONT_SMALL")
lootDistrBtn:SetPoint("LEFT", appearanceBtn, "RIGHT", -1, 0)
lootDistrBtn:SetScript("OnClick", function()
	gra.profilesFrame:Hide()
	if gra.lootDistrConfigFrame:IsVisible() then
		gra.lootDistrConfigFrame:Hide()
	else
		gra.lootDistrConfigFrame:Show()
	end
end)
lootDistrBtn:SetEnabled(false)

-- String: version
local version = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
version:SetPoint("TOPLEFT", miscSection, 0, -45)

-- String: memUsage
local memUsage = configFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
memUsage:SetPoint("TOPLEFT", miscSection, 0, -60)
local memUsageTimer

-----------------------------------------
-- help, anchor, profile
-----------------------------------------
local profilesBtn = GRA:CreateButton(configFrame, L["Profiles"], "red", {57, 20}, "GRA_FONT_SMALL")
profilesBtn:SetPoint("BOTTOMRIGHT", -5, 5)
profilesBtn:SetScript("OnClick", function()
	-- gra.lootDistrConfigFrame:Hide()
	if gra.profilesFrame:IsVisible() then
		gra.profilesFrame:Hide()
	else
		gra.profilesFrame:Show()
	end
end)

local anchorBtn = GRA:CreateButton(configFrame, L["Anchor"], "red", {57, 20}, "GRA_FONT_SMALL")
anchorBtn:SetPoint("RIGHT", profilesBtn, "LEFT", -5, 0)
anchorBtn:SetScript("OnClick", function()
	GRA:ShowHidePopupsAnchor()
	-- GRA:ShowHideFloatButtonsAnchor()
end)

local helpBtn = GRA:CreateButton(configFrame, L["Help"], "red", {57, 20}, "GRA_FONT_SMALL")
helpBtn:SetPoint("RIGHT", anchorBtn, "LEFT", -5, 0)
helpBtn:SetScript("OnClick", function()
	-- configFrame:Hide()
	gra.helpFrame:Show()
	ActionButton_HideOverlayGlow(helpBtn)
	-- GRA_A_Variables["helpViewed"] = true -- TODO: take it back when help is complete
end)

-----------------------------------------
-- permission control
-----------------------------------------
-- permission check mask
GRA:CreateMask(rosterFrame, L["Checking Permissions..."])
GRA:RegisterEvent("GRA_PERMISSION", "ConfigFrame_CheckPermissions", function(isAdmin)
	rosterFrame.mask:Hide()
	if isAdmin then
		rosterAdminFrame:Show()
		rosterUserFrame:Hide()
		arCalculationText:Show()
		arcmBtn1:Show()
		arcmBtn2:Show()
		raidHoursTitle:ClearAllPoints()
		raidHoursTitle:SetPoint("TOPLEFT", daysFrame, "BOTTOMLEFT", 0, -102)
		raidEndTimeEditBox:ClearAllPoints()
		raidEndTimeEditBox:SetPoint("TOPRIGHT", daysFrame, "BOTTOMRIGHT", 0, -98)
		raidStartTimeEditBox:Show()
		raidEndTimeEditBox:Show()
		raidHoursTo:Show()
		raidHoursText:Hide()
	else -- is not admin
		rosterUserFrame:Show()
		rosterAdminFrame:Hide()
		arCalculationText:Hide()
		arcmBtn1:Hide()
		arcmBtn2:Hide()
		raidHoursTitle:ClearAllPoints()
		raidHoursTitle:SetPoint("TOPLEFT", daysFrame, "BOTTOMLEFT", 0, -82)
		raidHoursText:Show()
		raidStartTimeEditBox:Hide()
		raidEndTimeEditBox:Hide()
		raidHoursTo:Hide()
	end
end)

configFrame:SetScript("OnUpdate", function(self, elapsed)
	local f = GRA:Getn(_G[GRA_R_Roster]) ~= 0
	editBtn:SetEnabled(f)
	-- disabled while sending
	sendRosterBtn:SetEnabled(f and IsInGroup("LE_PARTY_CATEGORY_HOME") and not gra.sending)
end)

-----------------------------------------
-- _G[GRA_R_Roster] & _G[GRA_R_Config]["raidInfo"] received
-----------------------------------------
GRA:RegisterEvent("GRA_R_DONE", "ConfigFrame_RosterReceived", function()
	GRA:Print(L["Raid roster has been received."])
	_G[GRA_R_Config]["lastUpdatedTime"] = date("%x")
	rosterUserLastUpdatedText:SetText(L["Last updated time: "] .. "|cff0080FF" .. _G[GRA_R_Config]["lastUpdatedTime"])
	-- set loot system
	if _G[GRA_R_Config]["raidInfo"]["system"] == "" then
		GRA:FireEvent("GRA_SYSTEM", "")
	elseif _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
		GRA:SetEPGPEnabled(true)
	else -- dkp
		GRA:SetDKPEnabled(true)
	end
	RefreshRaidSchedule()
	GRA:ShowAttendanceSheet()
end)

-----------------------------------------
-- OnShow & OnHide
-----------------------------------------
local function EnableMiniMode(f)
	for i = 1, 7 do
		days[i]:SetEnabled(not f)
	end
	setBtn:SetEnabled(not f)

	if _G[GRA_R_Config]["raidInfo"]["system"] == "" then
		ar30CB:SetEnabled(not f)
		ar60CB:SetEnabled(not f)
		ar90CB:SetEnabled(not f)
		arCB:SetEnabled(not f)
		sitOutCB:SetEnabled(not f)

		if f then
			ar30CB:SetChecked(true)
			ar60CB:SetChecked(true)
			ar90CB:SetChecked(true)
			arCB:SetChecked(true)
			sitOutCB:SetChecked(true)
			GRA_Variables["columns"]["AR_30"] = true
			GRA_Variables["columns"]["AR_60"] = true
			GRA_Variables["columns"]["AR_90"] = true
			GRA_Variables["columns"]["AR_Lifetime"] = true
			GRA_Variables["columns"]["Sit_Out"] = true
			GRA:SetColumns()
		end
	end
end

GRA:RegisterEvent("GRA_MINI", "ConfigFrame_MiniMode", function(enabled)
	EnableMiniMode(enabled)
end)

configFrame:SetScript("OnShow", function(self)
	if not GRA_A_Variables["helpViewed"] then
		-- ActionButton_ShowOverlayGlow(helpBtn) -- TODO: take it back when help is complete
	end
	EnableMiniMode(GRA_Variables["minimalMode"])
	rosterUserLastUpdatedText:SetText(L["Last updated time: "] .. "|cff0080FF" .. (_G[GRA_R_Config]["lastUpdatedTime"] or L["never"]))
	rosterUserMinimalModeCB:SetChecked(GRA_Variables["minimalMode"])

	RefreshRaidSchedule()
	arcms.HighlightButton(_G[GRA_R_Config]["arCalculationMethod"])

	ar30CB:SetChecked(GRA_Variables["columns"]["AR_30"])
	ar60CB:SetChecked(GRA_Variables["columns"]["AR_60"])
	ar90CB:SetChecked(GRA_Variables["columns"]["AR_90"])
	arCB:SetChecked(GRA_Variables["columns"]["AR_Lifetime"])
	sitOutCB:SetChecked(GRA_Variables["columns"]["Sit_Out"])

	-- misc
	version:SetText(L["Version"] .. ": |cff0080FF" .. gra.version)

	UpdateAddOnMemoryUsage()
	memUsage:SetText(string.format(L["Memory usage"] .. ": |cff0080FF%.2f KB", GetAddOnMemoryUsage("GuildRaidAttendance")))
	memUsageTimer = C_Timer.NewTicker(10, function()
		UpdateAddOnMemoryUsage()
		memUsage:SetText(string.format(L["Memory usage"] .. ": |cff0080FF%.2f KB", GetAddOnMemoryUsage("GuildRaidAttendance")))
	end)
end)

configFrame:SetScript("OnHide", function(self)
	self:Hide()
	memUsageTimer:Cancel()
	memUsageTimer = nil
end)