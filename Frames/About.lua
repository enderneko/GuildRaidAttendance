local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local aboutFrame = GRA:CreateMovableFrame(L["About"], "GRA_AboutFrame", 450, 350, "GRA_FONT_NORMAL", "HIGH")
gra.aboutFrame = aboutFrame
aboutFrame:SetToplevel(true)

local content = CreateFrame("SimpleHTML", nil, aboutFrame)
content:SetResizable(true)
content:SetSpacing("h1", 7)
content:SetSpacing("p", 7)
content:SetFontObject("h1", "GRA_FONT_TEXT3")
content:SetFontObject("p", "GRA_FONT_TEXT")
content:SetPoint("TOPLEFT", 10, -10)
content:SetPoint("BOTTOMRIGHT", -10, 10)
content:SetWidth(aboutFrame:GetWidth() - 20)

aboutFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(aboutFrame)
    content:SetText("<html><body>" .. L[gra.version] .. "</body></html>")
end)

gra.mainFrame:HookScript("OnShow", function()
    if GRA_A_Variables["aboutViewed"] ~= gra.version then
        GRA_A_Variables["aboutViewed"] = gra.version

        -- current version has About content
        if L[gra.version] ~= gra.version then
            aboutFrame:Show()
            aboutFrame:SetPoint("CENTER", gra.mainFrame)
            aboutFrame.header.text:SetText(L["About"] .. " " .. gra.version)
        end
    end
end)