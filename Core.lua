---@class GRA
local GRA = select(2, ...)
_G.GRA = GRA

---@class BFI
---@field L table
---@field vars table
---@field funcs Funcs

GRA.vars = {}
GRA.funcs = {}

local L = GRA.L
local F = GRA.funcs
---@class AbstractWidgets
local AW = _G.AbstractWidgets

---------------------------------------------------------------------
-- debug
---------------------------------------------------------------------
--@debug@
local debugMode = true
--@end-debug@
function GRA.Debug(arg, ...)
    if debugMode then
        if type(arg) == "string" or type(arg) == "number" then
            print(arg)
        elseif type(arg) == "function" then
            arg(...)
        elseif arg == nil then
            return true
        end
    end
end

function GRA.Print(msg)
    -- old 80FF00
    print("|cff03FC9C[GRA]|r " .. msg)
end

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
local region = string.lower(GetCVar("portal"))
if region == "cn" or region == "tw" or region == "kr" then
    GRA.vars.RAID_LOCKOUTS_RESET = 4 -- Thursday
elseif region == "eu" then
    GRA.vars.RAID_LOCKOUTS_RESET = 3 -- Wednesday
else -- us
    GRA.vars.RAID_LOCKOUTS_RESET = 2 -- Tuesday
end

GRA.vars.CLASS_ORDER = {"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}

---------------------------------------------------------------------
-- colors
---------------------------------------------------------------------
AW.AddColor("GRA", {0.01, 0.99, 0.61, 1})

---------------------------------------------------------------------
-- size
---------------------------------------------------------------------
-- gra.sizes = {
--     normal = {
--         fontSize = 11,
--         height = 20,
--         -- button_main = {100, 20},
--         -- button_track = {60, 22},
--         -- button_close = {16, 16},
--         grid_name = 95,
--         grid_others = 50,
--         grid_dates = 30,
--         mainFrame = {620, 445},
--         raidLogsFrame = {720, 445},
--         archivedLogsFrame = {720, 445},
--     },
--     large = {
--         fontSize = 13,
--         height = 24,
--         button_main = {120, 24},
--         button_track = {80, 26},
--         button_close = {20, 20},
--         button_raidLogs = {84, 24},
--         button_attendanceEditor = {122, 22},
--         button_datePicker = {84, 24},
--         button_datePicker_inner = {34, 24},
--         button_datePicker_outter = {232, 183},
--         button_refresh = {66, 24},
--         grid_name = 90,
--         grid_others = 54,
--         grid_dates = 36,
--         mainFrame = {770, 497},
--         attendanceFrame = {-34, 422}, -- point, height
--         raidLogsFrame = {-34, 429}, -- point, height
--         raidLogsFrame_list = {-20, 28, 87}, -- top, bottom, width
--     },
--     extraLarge = {
--         fontSize = 15,
--         height = 28,
--     }
-- }
-- gra.size = gra.sizes.normal

---------------------------------------------------------------------
-- font
---------------------------------------------------------------------
GRA_FORCE_ENGLISH = false
---------------------------------------------------------------------
-- local font = "Interface\\AddOns\\GuildRaidAttendance\\Media\\Fonts\\calibrib.ttf"
-- local useGameFont = false
-- if GetLocale() == "zhCN" or GetLocale() == "zhTW" or GetLocale() == "koKR" then
--     useGameFont = true
-- end

-- -- tooltip
-- local font_tooltip_normal = CreateFont("GRA_FONT_TOOLTIP_NORMAL")
-- font_tooltip_normal:SetFont(GameTooltipText:GetFont(), 13)
-- font_tooltip_normal:SetTextColor(1, 1, 1, 1)
-- font_tooltip_normal:SetShadowColor(0, 0, 0)
-- font_tooltip_normal:SetShadowOffset(1, -1)
-- font_tooltip_normal:SetJustifyH("LEFT")
-- font_tooltip_normal:SetJustifyV("MIDDLE")

-- local font_tooltip_small = CreateFont("GRA_FONT_TOOLTIP_SMALL")
-- font_tooltip_small:SetFont(GameTooltipText:GetFont(), 11)
-- font_tooltip_small:SetTextColor(1, 1, 1, 1)
-- font_tooltip_small:SetShadowColor(0, 0, 0)
-- font_tooltip_small:SetShadowOffset(1, -1)
-- font_tooltip_small:SetJustifyH("LEFT")
-- font_tooltip_small:SetJustifyV("MIDDLE")

-- -- text
-- local font_text = CreateFont("GRA_FONT_TEXT")
-- font_text:SetFont(useGameFont and GameFontNormal:GetFont() or font, 11)
-- font_text:SetTextColor(1, 1, 1, 1)
-- font_text:SetShadowColor(0, 0, 0)
-- font_text:SetShadowOffset(1, -1)
-- font_text:SetJustifyH("LEFT")

-- local font_text2 = CreateFont("GRA_FONT_TEXT2")
-- font_text2:SetFont(useGameFont and GameFontNormal:GetFont() or font, 12)
-- font_text2:SetTextColor(1, 1, 1, 1)
-- font_text2:SetShadowColor(0, 0, 0)
-- font_text2:SetShadowOffset(1, -1)
-- font_text2:SetJustifyH("LEFT")

-- local font_text3 = CreateFont("GRA_FONT_TEXT3")
-- font_text3:SetFont(useGameFont and GameFontNormal:GetFont() or font, 13)
-- font_text3:SetTextColor(.5, .9, 0, 1)
-- font_text3:SetShadowColor(0, 0, 0)
-- font_text3:SetShadowOffset(1, -1)
-- font_text3:SetJustifyH("LEFT")

-- -- small button
-- local font_small = CreateFont("GRA_FONT_SMALL")
-- font_small:SetFont((useGameFont and not GRA_FORCE_ENGLISH) and GameFontNormal:GetFont() or font, 11)
-- font_small:SetTextColor(1, 1, 1, 1)
-- font_small:SetShadowColor(0, 0, 0)
-- font_small:SetShadowOffset(1, -1)
-- font_small:SetJustifyH("CENTER")

-- local font_small_disabled = CreateFont("GRA_FONT_SMALL_DISABLED")
-- font_small_disabled:SetFont((useGameFont and not GRA_FORCE_ENGLISH) and GameFontNormal:GetFont() or font, 11)
-- font_small_disabled:SetTextColor(.4, .4, .4, 1)
-- font_small_disabled:SetShadowColor(0, 0, 0)
-- font_small_disabled:SetShadowOffset(1, -1)
-- font_small_disabled:SetJustifyH("CENTER")

-- -- header
-- local font_normal = CreateFont("GRA_FONT_NORMAL")
-- font_normal:SetFont((useGameFont and not GRA_FORCE_ENGLISH) and GameFontNormal:GetFont() or font, 13)
-- font_normal:SetTextColor(.5, 1, 0, 1)
-- font_normal:SetShadowColor(0, 0, 0)
-- font_normal:SetShadowOffset(1, -1)
-- font_normal:SetJustifyH("CENTER")

-- local font_title = CreateFont("GRA_FONT_TITLE")
-- font_title:SetFont(font, 13)
-- font_title:SetTextColor(.5, 1, 0, 1)
-- font_title:SetShadowColor(0, 0, 0)
-- font_title:SetShadowOffset(1, -1)
-- font_title:SetJustifyH("CENTER")

-- -- large button
-- local font_large_button = CreateFont("GRA_FONT_BUTTON")
-- font_large_button:SetFont(font, 15)
-- font_large_button:SetTextColor(1, 1, 1, 1)
-- font_large_button:SetShadowColor(0, 0, 0)
-- font_large_button:SetShadowOffset(1, -1)
-- font_large_button:SetJustifyH("CENTER")

-- -- grid text
-- local fontGRA_Rosterid = CreateFont("GRA_FONTGRA_RosterID")
-- fontGRA_Rosterid:SetFont(font, 11)
-- fontGRA_Rosterid:SetTextColor(1, 1, 1, 1)
-- fontGRA_Rosterid:SetShadowColor(0, 0, 0)
-- fontGRA_Rosterid:SetShadowOffset(1, -1)
-- fontGRA_Rosterid:SetJustifyH("CENTER")

-- local font_pixel = CreateFont("GRA_FONT_PIXEL")
-- font_pixel:SetFont("Interface\\AddOns\\GuildRaidAttendance\\Media\\Fonts\\SWF!T___.TTF", 6, "MONOCHROME")
-- font_pixel:SetTextColor(1, 1, 1, 1)
-- font_pixel:SetShadowColor(0, 0, 0)
-- font_pixel:SetShadowOffset(1, -1)
-- font_pixel:SetJustifyH("CENTER")

-- -- loot frame ilvl
-- -- local font_loot = CreateFont("GRA_FONT_LOOT")
-- -- font_loot:SetFont(font, 10, "OUTLINE")
-- -- font_loot:SetJustifyH("CENTER")

-- -- force update font!!!
-- function GRA.UpdateFont()
--     -- update font & fontsize
--     if GRA_A_Vars["useGameFont"] then
--         GRA_FONT_SMALL:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
--         GRA_FONT_SMALL_DISABLED:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
--         GRA_FONT_NORMAL:SetFont(GameFontNormal:GetFont(), gra.size.fontSize + 2)
--         GRA_FONT_TEXT:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
--         GRA_FONT_TEXT2:SetFont(GameFontNormal:GetFont(), gra.size.fontSize + 1)
--         GRA_FONT_TEXT3:SetFont(GameFontNormal:GetFont(), gra.size.fontSize + 2)
--         GRA_FONT_TITLE:SetFont(GameFontNormal:GetFont(), gra.size.fontSize + 2)
--         GRA_FONTGRA_RosterID:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
--     else
--         GRA_FONT_TOOLTIP_NORMAL:SetFont(GRA_FONT_TOOLTIP_NORMAL:GetFont(), gra.size.fontSize + 2)
--         GRA_FONT_TOOLTIP_SMALL:SetFont(GRA_FONT_TOOLTIP_SMALL:GetFont(), gra.size.fontSize)
--         GRA_FONT_SMALL:SetFont(GRA_FONT_SMALL:GetFont(), gra.size.fontSize)
--         GRA_FONT_SMALL_DISABLED:SetFont(GRA_FONT_SMALL_DISABLED:GetFont(), gra.size.fontSize)
--         GRA_FONT_NORMAL:SetFont(GRA_FONT_NORMAL:GetFont(), gra.size.fontSize + 2)
--         GRA_FONT_TEXT:SetFont(GRA_FONT_TEXT:GetFont(), gra.size.fontSize)
--         GRA_FONT_TEXT2:SetFont(GRA_FONT_TEXT2:GetFont(), gra.size.fontSize + 1)
--         GRA_FONT_TEXT3:SetFont(GRA_FONT_TEXT3:GetFont(), gra.size.fontSize + 2)
--         GRA_FONT_TITLE:SetFont(GRA_FONT_TITLE:GetFont(), gra.size.fontSize + 2)
--         GRA_FONT_BUTTON:SetFont(GRA_FONT_BUTTON:GetFont(), gra.size.fontSize + 4)
--         GRA_FONTGRA_RosterID:SetFont(GRA_FONTGRA_RosterID:GetFont(), gra.size.fontSize)
--         GRA_FONT_PIXEL:SetFont(GRA_FONT_PIXEL:GetFont(), gra.size.fontSize - 5, "MONOCHROME")
--     end
-- end

---------------------------------------------------------------------
-- LDB
---------------------------------------------------------------------
local icon = LibStub("LibDBIcon-1.0")
local GRA_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRaidAttendance", {
    type = "data source",
    text = "|cff03fc9cGuild|r Raid Attendance",
    icon = "Interface\\AddOns\\GuildRaidAttendance\\Media\\minimap",
    OnClick = function()
        if GRA_MainFrame:IsVisible() then
            GRA_MainFrame:Hide()
        else
            GRA_MainFrame:Show()
        end
    end,
})

---------------------------------------------------------------------
-- loaded
---------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

-- initialize!
function frame:ADDON_LOADED(arg1)
    if arg1 == "GuildRaidAttendance" then
        frame:UnregisterEvent("ADDON_LOADED")

        -- account saved variables
        if type(GRA_A_Vars) ~= "table" then GRA_A_Vars = {} end
        if type(GRA_A_Logs) ~= "table" then GRA_A_Logs = {} end
        if type(GRA_A_Archived) ~= "table" then GRA_A_Archived = {} end
        if type(GRA_A_Roster) ~= "table" then GRA_A_Roster = {} end
        if type(GRA_A_Config) ~= "table" then GRA_A_Config = {} end
        -- character saved variables
        if type(GRA_C_Vars) ~= "table" then GRA_C_Vars = {} end
        if type(GRA_C_Logs) ~= "table" then GRA_C_Logs = {} end
        if type(GRA_C_Archived) ~= "table" then GRA_C_Archived = {} end
        if type(GRA_C_Roster) ~= "table" then GRA_C_Roster = {} end
        if type(GRA_C_Config) ~= "table" then GRA_C_Config = {} end

        if type(GRA_C_Vars.useAccountProfile) ~= "boolean" then
            GRA_C_Vars.useAccountProfile = true
        end

        -- init RUNTIME tables
        if GRA_C_Vars.useAccountProfile then
            GRA_Logs = GRA_A_Logs
            GRA_Archived = GRA_A_Archived
            GRA_Roster = GRA_A_Roster
            GRA_Config = GRA_A_Config
        else
            GRA_Logs = GRA_C_Logs
            GRA_Archived = GRA_C_Archived
            GRA_Roster = GRA_C_Roster
            GRA_Config = GRA_C_Config
        end

        ---------------------------------------------------------------------
        --! GRA_A_Vars
        -- help viewed
        if type(GRA_A_Vars.helpViewed) ~= "boolean" then
            GRA_A_Vars.helpViewed = false
        end
        -- changelogs viewed
        if type(GRA_A_Vars.changelogsViewed) ~= "string" then
            GRA_A_Vars.whatsNewViewed = ""
        end
        -- scale
        if type(GRA_A_Vars.scale) ~= "number" then
            GRA_A_Vars.scale = 1
        end
        -- GRA.SetScale(GRA_A_Vars["scaleFactor"])
        -- minimap
        if type(GRA_A_Vars.minimap) ~= "table" then
            GRA_A_Vars.minimap = {hide = false}
        end
        icon:Register("GuildRaidAttendance", GRA_LDB, GRA_A_Vars.minimap)
        -- minimal mode
        if type(GRA_A_Vars.minimalMode) ~= "boolean" then
            GRA_A_Vars.minimalMode = false
        end
        -- sheet columns
        if type(GRA_A_Vars.columns) ~= "table" then
            GRA_A_Vars.columns = {
                AR_30 = false,
                AR_60 = false,
                AR_90 = false,
                AR_Total = false,
                Sit_Out = false,
            }
        end
        -- sort
        if type(GRA_A_Vars.sortKey) ~= "string" then
            GRA_A_Vars.sortKey = "name"
        end
        ---------------------------------------------------------------------

        ---------------------------------------------------------------------
        --! GRA_Config
        -- raid info
        if type(GRA_Config.raidInfo) ~= "table" then
            GRA_Config.raidInfo = {
                EPGP = {
                    baseGP = 100,
                    minEP = 0,
                    decay = 10,
                },
                DKP = 0,
                days = {GRA.vars.RAID_LOCKOUTS_RESET, GRA.vars.RAID_LOCKOUTS_RESET + 1, GRA.vars.RAID_LOCKOUTS_RESET + 2},
                startTime = "20:30",
                endTime = "23:00",
                system = "",
            }
        end
        -- sheet start date
        if type(GRA_Config.startDate) ~= "string" then
            GRA_Config.startDate = F.GetLockoutsResetDate() -- this lockouts reset day
        end
        -- loot distr tool
        if type(GRA_Config.enableLootDistr) ~= "boolean" then
            GRA_Config.enableLootDistr = false
        end
        -- reply buttons
        if type(GRA_Config.replies) ~= "table" then
            GRA_Config.replies = {"configure", "your", "buttons"}
        end
        -- quick notes
        if type(GRA_Config.notes) ~= "table" then
            GRA_Config.notes = {"BiS", "4p", "2p"}
        end
        -- attendance rate calculation method
        if type(GRA_Config.arCalcMethod) ~= "string" then
            GRA_Config.arCalcMethod = "A"
        end
        ---------------------------------------------------------------------

        GRA.version = C_AddOns.GetAddOnMetadata("GuildRaidAttendance", "version")
        -- GRA.UpdateFont()
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

---------------------------------------------------------------------
-- slash command
---------------------------------------------------------------------
local num = 1

SLASH_GUILDRAIDATTENDANCE1 = "/gra"
function SlashCmdList.GUILDRAIDATTENDANCE(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    if command == "" then
        GRA_MainFrame:Show()
    elseif command == "anchor" then
        F.ShowHidePopupsAnchor()
    elseif command == "exportlocale" then
        local f = GRA.CreateFrame("Export Locale", nil, UIParent, 300, 400)
        f:SetPoint("CENTER")

        local eb = CreateFrame("EditBox", nil, f)
        GRA.StylizeFrame(eb, {.1, .1, .1, .9})
        eb:SetFontObject("GRA_FONT_TEXT")
        eb:SetMultiLine(true)
        eb:SetMaxLetters(0)
        eb:SetJustifyH("LEFT")
        eb:SetJustifyV("TOP")
        eb:SetTextInsets(5, 30, 0, 0)
        eb:SetAutoFocus(false)
        eb:SetSize(300, 400)

        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 5, -5)
        scroll:SetPoint("BOTTOMRIGHT", -25, 5)
        scroll:SetScrollChild(eb)

        local text = ""
        for k, v in pairs(E.L) do
            text = text .. "L[\"" .. k .. "\"] = \"" .. v .. "\"\n"
        end
        eb:SetText(text)
        f:Show()
    elseif command == "minimap" then
        GRA_A_Vars.minimap.hide = not GRA_A_Vars.minimap.hide
        if GRA_A_Vars.minimap.hide then
            icon:Hide("GuildRaidAttendance")
        else
            icon:Show("GuildRaidAttendance")
        end
    elseif command == "loot" then
        GRA_DistributionFrame:Show()
    else
        GRA.Print(L["Unknown command"] .. ".")
    end
end