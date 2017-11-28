local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- get started frame
-----------------------------------------
local getStartedFrame = CreateFrame("Frame", "GRA_GetStartedFrame", gra.mainFrame)
GRA:StylizeFrame(getStartedFrame)
getStartedFrame:SetPoint("TOP", gra.mainFrame, "BOTTOM", 0, 1)
getStartedFrame:SetPoint("LEFT")
getStartedFrame:SetPoint("RIGHT")
-- getStartedFrame:SetSize(gra.mainFrame:GetWidth(), 35)
getStartedFrame:SetHeight(35)
getStartedFrame:SetFrameLevel(110)
getStartedFrame:Hide()
gra.getStartedFrame = getStartedFrame

local closeBtn = GRA:CreateButton(getStartedFrame, "×", "red", {16, 16}, "GRA_FONT_BUTTON")
closeBtn:SetScript("OnClick", function() getStartedFrame:Hide() end)
closeBtn:SetPoint("TOPRIGHT")

local text = getStartedFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
text:SetText(L["In order to use GRA, your guild must have an admin.\nTo assign an admin, Add a newline for example: #GRA:Archimonde to guild information (no spaces)."])
-- text:SetTextColor(1, .2, .2)
text:SetPoint("LEFT", 8, 0)
text:SetPoint("RIGHT", -20, 0)
text:SetJustifyH("LEFT")
text:SetSpacing(3)

getStartedFrame:SetScript("OnUpdate", function()
	getStartedFrame:SetHeight(text:GetStringHeight() + 18)
end)

GRA:RegisterEvent("GRA_PERMISSION", "CheckAdmin", function(isAdmin)
	if isAdmin == nil then
		getStartedFrame:Show()
	end
end)