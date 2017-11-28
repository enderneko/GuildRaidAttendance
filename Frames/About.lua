local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

--------------------------------------------
-- about frame
--------------------------------------------
local aboutFrame = GRA:CreateFrame(L["About"], "GRA_AboutFrame", gra.mainFrame, 191, gra.mainFrame:GetHeight())
gra.aboutFrame = aboutFrame
aboutFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)

-- author
local authorSection = aboutFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
authorSection:SetText("|cff80FF00"..L["Author"].."|r")
authorSection:SetPoint("TOPLEFT", 5, -5)
GRA:CreateSeperator(aboutFrame, authorSection)

local author = aboutFrame:CreateTexture()
author:SetTexture([[Interface\AddOns\GuildRaidAttendance\Media\author]])
author:SetSize(128, 16)
author:SetPoint("TOPLEFT", authorSection, 0, -18)

-- translators
local translatorSection = aboutFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
translatorSection:SetText("|cff80FF00"..L["Translators"].."|r")
translatorSection:SetPoint("TOPLEFT", 5, -70)
GRA:CreateSeperator(aboutFrame, translatorSection)

-- websites
local websiteSection = aboutFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
websiteSection:SetText("|cff80FF00"..L["Websites"].."|r")
websiteSection:SetPoint("TOPLEFT", 5, -250)
GRA:CreateSeperator(aboutFrame, websiteSection)

local curseLogo = aboutFrame:CreateTexture()
curseLogo:SetTexture([[Interface\AddOns\GuildRaidAttendance\Media\curse-logo]])
curseLogo:SetSize(128, 16)
curseLogo:SetPoint("TOPLEFT", websiteSection, 0, -20)

local curseLink = GRA:CreateEditBox(aboutFrame, aboutFrame:GetWidth()-10, 20, false, "GRA_FONT_SMALL")
curseLink:SetPoint("TOPLEFT", curseLogo, 0, -20)
curseLink:SetScript("OnTextChanged", function()
	curseLink:SetText([[https://mods.curse.com/addons/wow/guild-raid-attendance]])
	curseLink:SetCursorPosition(0)
end)

local curseforgeLogo = aboutFrame:CreateTexture()
curseforgeLogo:SetTexture([[Interface\AddOns\GuildRaidAttendance\Media\curseforge-logo]])
curseforgeLogo:SetSize(128, 16)
curseforgeLogo:SetPoint("TOPLEFT", websiteSection, 0, -70)

local curseforgeLink = GRA:CreateEditBox(aboutFrame, aboutFrame:GetWidth()-10, 20, false, "GRA_FONT_SMALL")
curseforgeLink:SetPoint("TOPLEFT", curseforgeLogo, 0, -20)
curseforgeLink:SetScript("OnTextChanged", function()
	curseforgeLink:SetText([[https://www.curseforge.com/wow/addons/guild-raid-attendance]])
	curseforgeLink:SetCursorPosition(0)
end)

aboutFrame:SetScript("OnHide", function(self)
	self:Hide()
end)