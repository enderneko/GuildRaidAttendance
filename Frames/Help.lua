local addonName, addonTable = ...
local GRA, gra = unpack(addonTable)
local L = addonTable.L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-- TODO: incomplete
local helpFrame = GRA:CreateMovableFrame("GRA " .. L["Help"] .. " (OUTDATED)", "GRA_HelpFrame", 550, 400, "GRA_FONT_NORMAL", "HIGH")
gra.helpFrame = helpFrame
helpFrame:SetToplevel(true)
helpFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(helpFrame)
end)

--------------------------------------------------------
-- list
--------------------------------------------------------
local listRegion = CreateFrame("Frame", nil ,helpFrame)
GRA:StylizeFrame(listRegion, {.15, .15, .15, .7})
listRegion:SetPoint("TOPLEFT")
listRegion:SetPoint("BOTTOMRIGHT", helpFrame, "BOTTOMLEFT", 150, 0)

-- local listScroll = GRA:CreateScrollFrame(listRegion)
-- listScroll:SetScrollStep(19)

local list = CreateFrame("SimpleHTML", nil, listRegion)
list:SetSize(130, 300)
list:SetPoint("TOP")
list:SetFontObject("p", "GRA_FONT_TEXT2")
-- list:SetFont("p", "Interface\\AddOns\\GuildRaidAttendance\\Media\\Fonts\\calibrib.ttf", 12)
list:SetSpacing("p", 7)
-- list:SetHyperlinksEnabled(true)
list:SetHyperlinkFormat("|H%s|h|cFF80E600%s|r|h")

list:SetText([[
    <html><body>
    <p></p>
    <p><a href="GET_STARTED:480">]]..L["Get Started"]..[[</a></p>
    <p><a href="EPGP_OPTIONS">]]..L["EPGP Options"]..[[</a></p>
    <p><a href="START_TRACKING">]]..L["Start Tracking"]..[[</a></p>
    <p><a href="ROSTER:420">]]..L["Roster"]..[[</a></p>
    <p><a href="RAID_LOGS:450">]]..L["Raid Logs"]..[[</a></p>
    <p><a href="RAID_LOG_ENTRIES:520">]]..L["Raid Log Entries"]..[[</a></p>
    <p><a href="EDIT_ATTENDANCE">]]..L["Edit Attendance"]..[[</a></p>
    <p><a href="LOOT_DISTRIBUTION_TOOL:970">]]..L["Loot Distribution Tool"]..[[</a></p>
    <p><a href="SLASH_COMMANDS">]]..L["Slash Commands"]..[[</a></p>
    <p><a href="ABOUT">]]..L["About"]..[[</a></p>
    </body></html>
]])

--------------------------------------------------------
-- content
--------------------------------------------------------
local contentRegion = CreateFrame("Frame", nil ,helpFrame)
contentRegion:SetPoint("TOPLEFT", 149, 0)
contentRegion:SetPoint("BOTTOMRIGHT")

local contentScroll = GRA:CreateScrollFrame(contentRegion)

local content = CreateFrame("SimpleHTML", nil, contentScroll.content)
content:SetResizable(true)
content:SetPoint("TOPLEFT", 15, 0)
content:SetSize(370, 20)

content:SetSpacing("h1", 7)
content:SetSpacing("h2", 7)
content:SetSpacing("p", 7)
content:SetFontObject("h1", "GRA_FONT_TEXT3")
content:SetFontObject("p", "GRA_FONT_TEXT")
-- content:SetHyperlinkFormat("|H%s|h|cffffa0b4%s|r|h")
content:SetHyperlinkFormat("|H%s|h"..gra.colors.yellow.s.."%s|r|h")

-- content:SetText([[
--     <html><body>
--     <h1>SimpleHTML Demo: Ambush</h1>
--     <img src="Interface\Icons\Ability_Ambush" width="32" height="32" align="right"/>
--     <p align="center">|cffee4400'You think this hurts? Just wait.'|r</p>
--     <br/><br/>
--     <p>Among every ability a rogue has at his disposal,<br/>
--     Ambush is without a doubt the hardest hitting Rogue ability.</p>
--     </body></html>
-- ]])

local about = [[
    <html><body>
    <p></p>
    <p>]]..L["Click on |cffffd100yellow text|r to copy it."]..[[</p>
    <h1>]]..L["Author"]..[[</h1>
    <img src="Interface\AddOns\GuildRaidAttendance\Media\author" height="16" align="left"/>
    <p></p>
    <p></p>
    <p><a href="link">]]..GetAddOnMetadata(addonName, "X-Email")..[[</a></p>
    <br/>
    <h1>]]..L["Websites"]..[[</h1>
    <img src="Interface\AddOns\GuildRaidAttendance\Media\curseforge-logo" height="16" align="left"/>
    <p></p>
    <p></p>
    <p><a href="link">]]..GetAddOnMetadata(addonName, "X-Website")..[[</a></p>
    <p></p>
    <p>]]..L["Please leave me a pm on curseforge if you want to help with the localization."]..[[</p>
    <p></p>
    <p>]]..L["Submit a ticket here %s, let me know what you need or what bugs you've found."]:format([[<a href="link">]]..GetAddOnMetadata(addonName, "X-Issues")..[[</a>]])..[[</p>
    <br/>
    <h1>]]..L["Translators"]..[[</h1>
    </body></html>
]]

content:SetHeight(390)
content:SetText(about)

--------------------------------------------------------
-- on click
--------------------------------------------------------
local copyEB = GRA:CreateEditBox(contentRegion, 200, 20)
copyEB:Hide()
copyEB:SetFrameStrata("DIALOG")
GRA:StylizeFrame(copyEB, {.1, .1, .1, 1}, {1, .82, 0, 1})
copyEB:SetScript("OnShow", function() copyEB:SetFocus(true) end)
copyEB:SetScript("OnEditFocusLost", function() copyEB:Hide() end)

list:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
    local page, height = strsplit(":", linkData)
    content:SetHeight(height or 400)
    contentScroll:ResetScroll()
    contentScroll:ResetHeight()
    if page == "ABOUT" then
        content:SetText(about)
    else
        content:SetText([[
            <html><body>
            <p></p>]] .. 
            L[page] .. 
            [[</body></html>
        ]])
    end
    copyEB:Hide()
end)

content:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
    local page, height = strsplit(":", linkData)
    if page == "link" then
        copyEB:SetText(link)
        copyEB:SetCursorPosition(0)
        copyEB:HighlightText()
        copyEB:ClearAllPoints()
        local x, y = GRA:GetCursorPosition()
        copyEB:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        copyEB:Show()
    else
        content:SetHeight(height or 390)
        contentScroll:ResetScroll()
        contentScroll:ResetHeight()
        content:SetText([[
            <html><body>
            <p></p>]] .. 
            L[page] .. 
            [[</body></html>
        ]])
        copyEB:Hide()
    end
end)