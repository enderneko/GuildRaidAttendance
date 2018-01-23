local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local appearanceFrame = GRA:CreateFrame(L["Appearance"] .. " (Beta)", "GRA_AppearanceFrame", gra.mainFrame, 151, gra.mainFrame:GetHeight())
gra.appearanceFrame = appearanceFrame
appearanceFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
appearanceFrame.header.closeBtn:SetText("←")
local fontName = appearanceFrame.header.closeBtn:GetFontString():GetFont()
appearanceFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
appearanceFrame.header.closeBtn:SetScript("OnClick", function() appearanceFrame:Hide() gra.configFrame:Show() end)

local reloadBtn = GRA:CreateButton(appearanceFrame, L["Reload UI"], "red", {appearanceFrame:GetWidth()-10, 20}, "GRA_FONT_SMALL")
reloadBtn:SetPoint("BOTTOM", 0, 5)
reloadBtn:SetScript("OnClick", function()
    ReloadUI()
end)

local tip1 = appearanceFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
tip1:SetJustifyH("LEFT")
tip1:SetSpacing(3)
tip1:SetPoint("TOPLEFT", 5, -5)
tip1:SetPoint("TOPRIGHT", -5, -5)
tip1:SetText(gra.colors.firebrick.s .. L["Run WoW in full screen mode, if you want GRA to be pixel perfect."])

local tip2 = appearanceFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
tip2:SetJustifyH("LEFT")
tip2:SetSpacing(3)
tip2:SetPoint("BOTTOMLEFT", reloadBtn, "TOPLEFT", 0, 5)
tip2:SetPoint("BOTTOMRIGHT", reloadBtn, "TOPRIGHT", 0, 5)
tip2:SetText(gra.colors.firebrick.s .. L["Most of the settings above require a UI reload."])

-----------------------------------------
-- font
-----------------------------------------
local fontSection = appearanceFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
fontSection:SetText("|cff80FF00"..L["Font"].."|r")
fontSection:SetPoint("TOPLEFT", 5, -50)
GRA:CreateSeperator(appearanceFrame, fontSection)

-- CheckButton: use game font
local fontCB = GRA:CreateCheckButton(appearanceFrame, L["Use Game Font"], nil, function(checked)
	GRA_A_Variables["useGameFont"] = checked
end, "GRA_FONT_SMALL")
fontCB:SetPoint("TOPLEFT", fontSection, 0, -20)

-----------------------------------------
-- size
-----------------------------------------
local sizeSection = appearanceFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
sizeSection:SetText("|cff80FF00"..L["Frame Size"].."|r")
sizeSection:SetPoint("TOPLEFT", 5, -120)
GRA:CreateSeperator(appearanceFrame, sizeSection)

local sizeDropDown = GRA:CreateDropDownMenu(appearanceFrame, appearanceFrame:GetWidth()-10)
sizeDropDown:SetPoint("TOPLEFT", sizeSection, "BOTTOMLEFT", 0, -10)
sizeDropDown:SetEnabled(false)

-----------------------------------------
-- scale
-----------------------------------------
function GRA:GetScale()
    return LPP:GetPixelPerfectScale() * GRA_A_Variables["scaleFactor"]
end

function GRA:GetCursorPosition()
    local x, y = GetCursorPosition()
    return x / GRA:GetScale(), y / GRA:GetScale()
end

function GRA:SetScale(factor)
    GRA_A_Variables["scaleFactor"] = factor
    local scale = LPP:GetPixelPerfectScale() * factor
    -- tooltips
    GRA_Tooltip:SetScale(scale)
    GRA_ShoppingTooltip1:SetScale(scale)
    GRA_ShoppingTooltip2:SetScale(scale)
    GRA_RecordLootTooltip:SetScale(scale)
    GRA_CreditTooltip:SetScale(scale)
    -- frames
    gra.mainFrame:SetScale(scale)
    gra.awardFrame:SetScale(scale)
    gra.creditFrame:SetScale(scale)
    gra.penalizeFrame:SetScale(scale)
    gra.recordLootFrame:SetScale(scale)
    gra.helpFrame:SetScale(scale)
    -- loot distr
    gra.distributionFrame:SetScale(scale)
    gra.lootFrame:SetScale(scale)
    -- popup
    gra.popupsAnchor:SetScale(scale)
    -- static popup
    if gra.staticPopup then gra.staticPopup:SetScale(scale) end
    -- popup selector
    if gra.popupSelector then gra.popupSelector:SetScale(scale) end
    -- context menu
    if gra.contextMenu then gra.contextMenu:SetScale(scale) end
    -- float buttons
    gra.floatButtonsAnchor:SetScale(scale)
end

local scaleSection = appearanceFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
scaleSection:SetText("|cff80FF00"..L["Frame Scale"].."|r")
scaleSection:SetPoint("TOPLEFT", 5, -190)
GRA:CreateSeperator(appearanceFrame, scaleSection)

local scaleDropDown = GRA:CreateDropDownMenu(appearanceFrame, appearanceFrame:GetWidth()-10)
scaleDropDown:SetPoint("TOPLEFT", scaleSection, "BOTTOMLEFT", 0, -10)

local scaleTip = appearanceFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
scaleTip:SetJustifyH("LEFT")
scaleTip:SetSpacing(3)
scaleTip:SetPoint("TOPLEFT", scaleDropDown, "BOTTOMLEFT", 0, -5)
scaleTip:SetPoint("TOPRIGHT", scaleDropDown, "BOTTOMRIGHT", 0, -5)
scaleTip:SetText(L["Use %s to reset scale."]:format(gra.colors.firebrick.s .. "/gra resetscale|r"))

local indices = {1, 1.5, 2, 2.5, 3, 4}
local scaleFactors = {
    [1] = "100% " .. L["(Pixel Perfect)"],
    [1.5] = "150%",
    [2] = "200% " .. L["(Pixel Perfect)"],
    [2.5] = "250%",
    [3] = "300%",
    [4] = "400% " .. L["(Pixel Perfect)"],
}

local items = {}
for _, factor in pairs(indices) do
    table.insert(items, {
        ["text"] = scaleFactors[factor],
        ["onClick"] = function()
            GRA:SetScale(factor)
        end,
    })
end

scaleDropDown:SetItems(items)

-----------------------------------------
-- OnShow/Hide
-----------------------------------------
appearanceFrame:SetScript("OnShow", function()
    fontCB:SetChecked(GRA_A_Variables["useGameFont"])
    scaleDropDown:SetSelected(scaleFactors[GRA_A_Variables["scaleFactor"]])
end)

appearanceFrame:SetScript("OnHide", function(self)
	self:Hide()
end)