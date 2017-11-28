local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-------------------------------------------------
-- tooltip 2017-06-13 23:06:54
-------------------------------------------------
-- http://wow.gamepedia.com/UIOBJECT_GameTooltip
function GRA:CreateTooltip(name)
    if not name or name == "" then return end
    local tooltip = CreateFrame("GameTooltip", name, nil, "GRATooltipTemplate")
    -- local tooltip = CreateFrame("GameTooltip", name)
    tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    tooltip:SetBackdropColor(.1, .1, .1, .92)
	tooltip:SetBackdropBorderColor(0, 0, 0, 1)
    tooltip:SetFrameStrata("TOOLTIP")
    -- tooltip:SetClampedToScreen(true)
    LPP:PixelPerfectScale(tooltip)
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")

    -- Allow tooltip SetX() methods to dynamically add new lines based on these
    -- tooltip:AddFontStrings(
    --     tooltip:CreateFontString("$parentTextLeft1", "ARTWORK", "GRA_FONT_TOOLTIP"),
    --     tooltip:CreateFontString("$parentTextRight1", "ARTWORK", "GRA_FONT_TOOLTIP")
    -- )

    -- change first line (title) text font size to 13
    _G[name .. "TextLeft1"]:SetFont(GameTooltipText:GetFont(), 13)
    _G[name .. "TextRight1"]:SetFont(GameTooltipText:GetFont(), 13)
    -- correct width at first
    _G[name .. "TextRight1"]:Hide()

    tooltip:SetScript("OnTooltipCleared", function()
        -- reset border color
        tooltip:SetBackdropBorderColor(0, 0, 0, 1)
    end)

    tooltip:SetScript("OnTooltipSetItem", function()
        -- color border with item quality color
        tooltip:SetBackdropBorderColor(_G[name .. "TextLeft1"]:GetTextColor())
    end)

    tooltip:SetScript("OnHide", function()
        -- SetX with invalid data may or may not clear the tooltip's contents.
        tooltip:ClearLines()
        -- prepare for the next SetX()
    end)

    return tooltip
end

gra.tooltip = GRA:CreateTooltip("GRA_Tooltip")
GRA:CreateTooltip("GRA_ScanningTooltip")