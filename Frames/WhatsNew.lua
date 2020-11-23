local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local whatsNewFrame = GRA:CreateMovableFrame(L["What's New"], "GRA_WhatsNewFrame", 450, 350, "GRA_FONT_NORMAL", "HIGH")
gra.whatsNewFrame = whatsNewFrame
whatsNewFrame:SetToplevel(true)

whatsNewFrame.header.closeBtn:HookScript("OnClick", function()
    GRA_A_Variables["whatsNewViewed"] = gra.version
end)

local content = CreateFrame("SimpleHTML", nil, whatsNewFrame)
content:SetResizable(true)
content:SetSpacing("h1", 7)
content:SetSpacing("p", 7)
content:SetFontObject("h1", "GRA_FONT_TEXT3")
content:SetFontObject("p", "GRA_FONT_TEXT")
content:SetPoint("TOPLEFT", 10, -10)
content:SetPoint("BOTTOMRIGHT", -10, 10)
content:SetWidth(whatsNewFrame:GetWidth() - 20)

whatsNewFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(whatsNewFrame)
    content:SetText("<html><body>" .. L[gra.version] .. "</body></html>")
end)

gra.mainFrame:HookScript("OnShow", function()
    if GRA_A_Variables["whatsNewViewed"] ~= gra.version then

        -- current version has About content
        if L[gra.version] ~= gra.version then
            whatsNewFrame:Show()
            whatsNewFrame:SetPoint("CENTER", gra.mainFrame)
            whatsNewFrame.header.text:SetText(L["What's New in"] .. " " .. gra.version)
        end
    end
end)