---@class GRA
local GRA = select(2, ...)
local L = GRA.L
---@class Funcs
local F = GRA.funcs
---@class AbstractWidgets
local AW = _G.AbstractWidgets

local lastFrame = nil

---------------------------------------------------------------------
-- main frame
---------------------------------------------------------------------
local mainFrame

local function UpdatePermission(isAdmin)
    if not mainFrame then return end

    if not IsInGuild() then
        AW.ShowMask(mainFrame, ERR_GUILD_PLAYER_NOT_IN_GUILD)
        return
    end

    if isAdmin == nil then
        if not GRA.vars.hasAdmin then
            AW.ShowMask(mainFrame, L["No Administrator"])
        else
            AW.HideMask(mainFrame)
        end
    else
        AW.HideMask(mainFrame)
    end
end
GRA.RegisterCallback("GRA_PERMISSION", "MainFrame_UpdatePermission", UpdatePermission)

local function CreateMainFrame()
    mainFrame = AW.CreateHeaderedFrame(AW.UIParent, "GRA_MainFrame", "Guild Raid Attendance", 600, 350)
    mainFrame:SetPoint("CENTER")

    mainFrame:SetScript("OnShow", function()
        UpdatePermission()
    end)
end

---------------------------------------------------------------------
-- guild motd
---------------------------------------------------------------------
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GUILD_MOTD_TEMPLATE = GUILD_MOTD_TEMPLATE

local guildMOTD
local function CreateGuildMOTD()
    guildMOTD = AW.CreateScrollText(mainFrame)
    AW.SetPoint(guildMOTD, "TOPLEFT", 5, -5)
    AW.SetPoint(guildMOTD, "TOPRIGHT", -5, -5)
    guildMOTD:SetText(format(GUILD_MOTD_TEMPLATE, GetGuildRosterMOTD()), "guild")

    -- update motd
    guildMOTD:RegisterEvent("GUILD_MOTD")
    guildMOTD:RegisterEvent("GUILD_ROSTER_UPDATE")
    guildMOTD:SetScript("OnEvent", function(self, event, arg)
        if event == "GUILD_ROSTER_UPDATE" then
            arg = GetGuildRosterMOTD()
        end

        guildMOTD:UnregisterEvent("GUILD_ROSTER_UPDATE") -- got motd, GUILD_ROSTER_UPDATE is no longer need
        guildMOTD:SetText(arg, "guild")
        guildMOTD:SetText(format(GUILD_MOTD_TEMPLATE, arg), "guild")
        GRA.Debug("|cff66CD00GUILD_MOTD:|r " .. arg)
    end)
end

---------------------------------------------------------------------
-- content
---------------------------------------------------------------------
local function CreateContentHolder()
    local holder = AW.CreateFrame(mainFrame, "GRA_MainFrame_ContentHolder", 20, 20)
    AW.SetPoint(holder, "TOPLEFT", 5, -30)
    AW.SetPoint(holder, "BOTTOMRIGHT", -5, 30)
    AW.SetDefaultBackdrop_NoBorder(holder)
    holder:SetBackdropColor(AW.GetColorRGB("green", 0.15))
end

---------------------------------------------------------------------
-- button
---------------------------------------------------------------------
local buttons = {}
local function CreateButtonHolder()
    local holder = AW.CreateFrame(mainFrame, "GRA_MainFrame_ButtonHolder", 20, 20)
    AW.SetPoint(holder, "BOTTOMLEFT", 5, 5)
    AW.SetPoint(holder, "BOTTOMRIGHT", -5, 5)

    -- config
    local config = AW.CreateButton(holder, L["Options"], "red", 70, 20)
    AW.SetPoint(config, "BOTTOMRIGHT")

    -- attendance
    buttons.attendance = AW.CreateButton(holder, L["Attendance Sheet"], "red_hover", 130, 20)
    AW.SetPoint(buttons.attendance, "BOTTOMLEFT")
    buttons.attendance.id = "attendance"

    -- logs
    buttons.raidLogs = AW.CreateButton(holder, L["Raid Logs"], "red_hover", 110, 20)
    AW.SetPoint(buttons.raidLogs, "BOTTOMLEFT", buttons.attendance, "BOTTOMRIGHT", 5, 0)
    buttons.raidLogs.id = "raidLogs"

    -- archived
    buttons.archivedLogs = AW.CreateButton(holder, L["Archived Logs"], "red_hover", 110, 20)
    AW.SetPoint(buttons.archivedLogs, "BOTTOMLEFT", buttons.raidLogs, "BOTTOMRIGHT", 5, 0)
    buttons.archivedLogs.id = "archivedLogs"

    -- group
    AW.CreateButtonGroup(buttons, function(id)
        GRA.Fire("ShowTab", id)
    end)
end

-- local configBtn = GRA.CreateButton(mainFrame, L["Config"], "red", {55, 20}, "GRA_FONT_SMALL")
-- configBtn:SetPoint("BOTTOMRIGHT", -8, 5)
-- configBtn:SetScript("OnClick", function()
--     gra.importFrame:Hide()
--     gra.epgpOptionsFrame:Hide()
--     -- gra.dkpOptionsFrame:Hide()
--     gra.rosterEditorFrame:Hide()
--     gra.appearanceFrame:Hide()
--     if gra.configFrame:IsShown() then
--         gra.configFrame:Hide()
--     else
--         gra.configFrame:Show()
--     end
-- end)

-- local buttons = {}
-- local function HighlightButton(button)
--     for n, b in pairs(buttons) do
--         if n == button then
--             b:SetBackdropBorderColor(.5, 1, 0, 1)
--         else
--             b:SetBackdropBorderColor(0, 0, 0, 1)
--         end
--     end
-- end

-- buttons["attendanceSheetBtn"] = GRA.CreateButton(mainFrame, L["Attendance Sheet"], "red", {100, 20}, "GRA_FONT_SMALL")
-- buttons["attendanceSheetBtn"]:SetPoint("BOTTOMLEFT", 8, 5)
-- buttons["attendanceSheetBtn"]:SetScript("OnClick", function()
--     HighlightButton("attendanceSheetBtn")
--     lastFrame = gra.attendanceFrame
--     gra.attendanceFrame:Show()
--     gra.calenderFrame:Hide()
--     gra.raidLogsFrame:Hide()
--     gra.archivedLogsFrame:Hide()
-- end)

-- buttons["raidLogsBtn"] = GRA.CreateButton(mainFrame, L["Raid Logs"], "red", {100, 20}, "GRA_FONT_SMALL")
-- buttons["raidLogsBtn"]:SetPoint("LEFT", buttons["attendanceSheetBtn"], "RIGHT", 5, 0)
-- buttons["raidLogsBtn"]:SetScript("OnClick", function()
--     HighlightButton("raidLogsBtn")
--     lastFrame = gra.raidLogsFrame
--     gra.attendanceFrame:Hide()
--     gra.calenderFrame:Hide()
--     gra.raidLogsFrame:Show()
--     gra.archivedLogsFrame:Hide()
-- end)

-- buttons["archivedLogsBtn"] = GRA.CreateButton(mainFrame, L["Archived Logs"].." (BETA)", "red", {100, 20}, "GRA_FONT_SMALL")
-- buttons["archivedLogsBtn"]:SetPoint("LEFT", buttons["raidLogsBtn"], "RIGHT", 5, 0)
-- buttons["archivedLogsBtn"]:SetScript("OnClick", function()
--     HighlightButton("archivedLogsBtn")
--     lastFrame = gra.archivedLogsFrame
--     gra.attendanceFrame:Hide()
--     gra.calenderFrame:Hide()
--     gra.raidLogsFrame:Hide()
--     gra.archivedLogsFrame:Show()
-- end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function F.ToggleGRA()
    if not mainFrame then
        CreateMainFrame()
        CreateGuildMOTD()
        CreateContentHolder()
        CreateButtonHolder()
        buttons.attendance:SlientClick()
    end

    if mainFrame:IsVisible() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- buttons["calenderBtn"] = GRA.CreateButton(mainFrame, L["Calender"], "red", {100, 20}, "GRA_FONT_SMALL")
-- buttons["calenderBtn"]:SetPoint("LEFT", buttons["raidLogsBtn"], "RIGHT", 5, 0)
-- buttons["calenderBtn"]:SetScript("OnClick", function()
-- 	HighlightButton("calenderBtn")
-- 	lastFrame = gra.calenderFrame
-- 	gra.attendanceFrame:Hide()
-- 	gra.raidLogsFrame:Hide()
-- 	gra.calenderFrame:Show()
-- end)

--[[
---------------------------------------------------------------------
-- top buttons
---------------------------------------------------------------------
-- track button, change text and color OnClick
local trackBtn = GRA.CreateButton(mainFrame.header, "TRACK", nil, {60, 22}, "GRA_FONT_PIXEL")
trackBtn:SetPoint("LEFT", mainFrame.header)
trackBtn:SetScript("OnClick", function()
    if gra.isTracking then
        GRA.StopTracking()
    else
        GRA.StartTracking()
    end
end)
trackBtn:Hide()

GRA.RegisterCallback("GRA_TRACK",  "Main_TrackStatus", function(raidDate)
    if raidDate then
        trackBtn:GetFontString():SetText("TRACKING...")
        trackBtn:SetBackdropColor(.5, 1, 0, .5)
        trackBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .7) end)
        trackBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(.5, 1, 0, .5) end)
    else
        trackBtn:GetFontString():SetText("TRACK")
        trackBtn:SetBackdropColor(.1, .1, .1, .7)
        trackBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .6) end)
        trackBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(.1, .1, .1, .7) end)
    end
end)

-- invite button
local inviteBtn = GRA.CreateButton(mainFrame.header, "INVITE", "red-hover", {60, 22}, "GRA_FONT_PIXEL")
inviteBtn:SetPoint("LEFT", trackBtn, "RIGHT", -1, 0)
inviteBtn:Hide()

inviteBtn:SetScript("OnClick", function()
    C_PartyInfo.ConvertToRaid()
    inviteBtn:RegisterEvent("GROUP_ROSTER_UPDATE")

    local onlineMembers = GRA.GetGuildOnlineRoster()
    local myName = strjoin("-", UnitFullName("player"))

    for n, _ in pairs(GRA_Roster) do
        if n ~= myName and onlineMembers[n] and not(UnitInParty(GRA.GetShortName(n)) or UnitInRaid(GRA.GetShortName(n))) then
            C_PartyInfo.InviteUnit(n)
        end
    end
    wipe(onlineMembers)
end)

inviteBtn:SetScript("OnEvent", function()
    if not IsInRaid() then
        C_PartyInfo.ConvertToRaid()
        inviteBtn:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end
end)

GRA.RegisterCallback("GRA_PERMISSION", "MainFrame_CheckPermissions", function(isAdmin)
    if isAdmin then
        trackBtn:Show()
        inviteBtn:Show()
    end
end)

---------------------------------------------------------------------
-- script
---------------------------------------------------------------------
local function EnableMiniMode(f)
    if f then
        buttons["attendanceSheetBtn"]:Hide()
        buttons["raidLogsBtn"]:Hide()
        buttons["archivedLogsBtn"]:Hide()
        buttons["attendanceSheetBtn"]:Click()
    else
        buttons["attendanceSheetBtn"]:Show()
        buttons["raidLogsBtn"]:Show()
        buttons["archivedLogsBtn"]:Show()
    end
end

GRA.RegisterCallback("GRA_MINI", "MiniMode", function(enabled)
    EnableMiniMode(enabled)
end)

mainFrame:SetScript("OnShow", function(self)
    GRA.UpdateFont()
    EnableMiniMode(GRA_Variables["minimalMode"])
    LPP:PixelPerfectPoint(mainFrame)

    if not IsInGuild() then
        GRA.CreateMask(mainFrame, GRA_FORCE_ENGLISH and "You are not in a guild." or ERR_GUILD_PLAYER_NOT_IN_GUILD, {1, -1, -1, 1})
        return
    end

    if lastFrame then
        lastFrame:Show()
    else
        HighlightButton("attendanceSheetBtn")
        gra.attendanceFrame:Show()
    end
end)

-- OnHide:
mainFrame:SetScript("OnHide", function()

end)

---------------------------------------------------------------------
-- resize
---------------------------------------------------------------------
function mainFrame:Resize()
    mainFrame:SetSize(unpack(gra.size.mainFrame))
    mainFrame.header:SetHeight(gra.size.height+2)
    mainFrame.header.closeBtn:SetSize(unpack(gra.size.button_close))
    for _, b in pairs(buttons) do
        b:SetSize(unpack(gra.size.button_main))
    end
    configBtn:SetSize(unpack(gra.size.button_main))
    trackBtn:SetSize(unpack(gra.size.button_track))
end
]]