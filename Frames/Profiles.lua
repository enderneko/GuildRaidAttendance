local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local profilesFrame = GRA:CreateFrame(L["Profiles"], "GRA_ProfilesFrame", gra.configFrame, 191, 190)
gra.profilesFrame = profilesFrame
profilesFrame:SetPoint("BOTTOMLEFT", gra.configFrame, "BOTTOMRIGHT", 2, 0)

local currentProfile = profilesFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
currentProfile:SetPoint("TOPLEFT", 5, -5)

-----------------------------------------
-- tips
-----------------------------------------
local tips1 = profilesFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
tips1:SetPoint("TOPLEFT", currentProfile, "BOTTOMLEFT", 0, -15)
tips1:SetText(gra.colors.firebrick.s .. L["Back it up before you lose it!"])

local tips2Frame = CreateFrame("Frame", nil, profilesFrame)
tips2Frame:SetSize(profilesFrame:GetWidth()-10, 15)
tips2Frame:SetPoint("TOPLEFT", tips1, "BOTTOMLEFT", 0, -5)
-- GRA:StylizeFrame(tips2Frame, {0, .7, 0, .1}, {0, 0, 0, 1})
local tips2 = tips2Frame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
tips2:SetWordWrap(false)
tips2:SetPoint("LEFT")
tips2:SetPoint("RIGHT")
local tips2Text = "World of Warcraft/WTF/Account/" .. gra.colors.firebrick.s .. L["ACCOUNTNAME"] .. "|r/SavedVariables/" .. gra.colors.firebrick.s .. "GuildRaidAttendance.lua"
tips2:SetText(L["Account Profile: "] .. gra.colors.grey.s .. tips2Text)
tips2Frame:SetScript("OnEnter", function()
    GRA_Tooltip:SetOwner(tips2Frame, "ANCHOR_NONE")
    GRA_Tooltip:AddLine(L["Account Profile: "])
    GRA_Tooltip:AddLine(tips2Text, 1, 1, 1)
    GRA_Tooltip:SetPoint("BOTTOM", tips2Frame, "TOP")
    GRA_Tooltip:Show()
end)
tips2Frame:SetScript("OnLeave", function()
    GRA_Tooltip:Hide()
end)

local tips3Frame = CreateFrame("Frame", nil, profilesFrame)
tips3Frame:SetSize(profilesFrame:GetWidth()-10, 15)
tips3Frame:SetPoint("TOPLEFT", tips2Frame, "BOTTOMLEFT", 0, -5)
-- GRA:StylizeFrame(tips3Frame, {0, .7, 0, .1}, {0, 0, 0, 1})
local tips3 = tips3Frame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
tips3:SetWordWrap(false)
tips3:SetPoint("LEFT")
tips3:SetPoint("RIGHT")
local tips3Text = "World of Warcraft/WTF/Account/" .. gra.colors.firebrick.s .. L["ACCOUNTNAME"] .. "|r/" .. gra.colors.firebrick.s .. L["REALMNAME"] .. "|r/" .. gra.colors.firebrick.s .. L["CHARNAME"] .. "|r/SavedVariables/" .. gra.colors.firebrick.s .. "GuildRaidAttendance.lua"
tips3:SetText(L["Character Profile: "] .. gra.colors.grey.s .. tips3Text)
tips3Frame:SetScript("OnEnter", function()
    GRA_Tooltip:SetOwner(tips3Frame, "ANCHOR_NONE")
    GRA_Tooltip:AddLine(L["Character Profile: "])
    GRA_Tooltip:AddLine(tips3Text, 1, 1, 1)
    GRA_Tooltip:SetPoint("BOTTOM", tips3Frame, "TOP")
    GRA_Tooltip:Show()
end)
tips3Frame:SetScript("OnLeave", function()
    GRA_Tooltip:Hide()
end)

-----------------------------------------
-- reset
-----------------------------------------
local resetBtn = GRA:CreateButton(profilesFrame, L["Reset Current Profile"], "red", {profilesFrame:GetWidth()-10, 20}, "GRA_FONT_SMALL")
resetBtn:SetPoint("BOTTOM", 0, 5)
resetBtn:SetScript("OnClick", function()
	local confirm = GRA:CreateConfirmBox(profilesFrame, profilesFrame:GetWidth()-10, gra.colors.firebrick.s .. L["Reset current profile?"] .. "|r \n" .. L["Including roster, logs and settings."], function()
		_G[GRA_R_RaidLogs] = nil
		_G[GRA_R_Roster] = nil
		_G[GRA_R_Config] = nil
		ReloadUI()
	end, true)
	confirm:SetPoint("CENTER", profilesFrame)
end)

-----------------------------------------
-- switch
-----------------------------------------
local profileToSwitchTo
local switchAndOverrideBtn = GRA:CreateButton(profilesFrame, L["Switch And Override"], "blue", {profilesFrame:GetWidth()-10, 20})
switchAndOverrideBtn:SetPoint("BOTTOM", resetBtn, "TOP", 0, 5)
switchAndOverrideBtn:SetScript("OnClick", function()
    local confirm = GRA:CreateConfirmBox(profilesFrame, profilesFrame:GetWidth()-10, (L["Switch to %s profile?"]):format(profileToSwitchTo) .. "\n" .. L["Override %s profile with current profile."]:format(profileToSwitchTo), function()
        -- override
        if GRA_Variables["useAccountProfile"] then
            GRA_RaidLogs = GRA_A_RaidLogs
            GRA_Roster = GRA_A_Roster
            GRA_Config = GRA_A_Config
        else
            GRA_A_RaidLogs = GRA_RaidLogs
            GRA_A_Roster = GRA_Roster
            GRA_A_Config = GRA_Config
        end

        GRA_Variables["useAccountProfile"] = not GRA_Variables["useAccountProfile"]
		ReloadUI()
	end, true)
	confirm:SetPoint("CENTER", profilesFrame)
end)

local switchBtn = GRA:CreateButton(profilesFrame, L["Switch"], "blue", {profilesFrame:GetWidth()-10, 20})
switchBtn:SetPoint("BOTTOM", switchAndOverrideBtn, "TOP", 0, 5)
switchBtn:SetScript("OnClick", function()
    local confirm = GRA:CreateConfirmBox(profilesFrame, profilesFrame:GetWidth()-10, (L["Switch to %s profile?"]):format(profileToSwitchTo), function()
		GRA_Variables["useAccountProfile"] = not GRA_Variables["useAccountProfile"]
		ReloadUI()
	end, true)
	confirm:SetPoint("CENTER", profilesFrame)
end)

local switchTo = profilesFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
switchTo:SetPoint("BOTTOMLEFT", switchBtn, "TOPLEFT", 0, 5)

-----------------------------------------
-- show/hide
-----------------------------------------
profilesFrame:SetScript("OnShow", function()
    currentProfile:SetText(gra.colors.chartreuse.s .. L["Current Profile: "] .. gra.colors.firebrick.s .. (GRA_Variables["useAccountProfile"] and L["Account"] or L["Character"]))
    profileToSwitchTo = gra.colors.firebrick.s .. (GRA_Variables["useAccountProfile"] and L["Character"] or L["Account"]) .. "|r"
    switchTo:SetText(L["Switch to %s profile"]:format(profileToSwitchTo))
end)

profilesFrame:SetScript("OnHide", function()
    profilesFrame:Hide()
end)