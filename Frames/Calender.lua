local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- calender frame
-----------------------------------------
local calenderFrame = CreateFrame("Frame", "GRA_CalenderFrame", gra.mainFrame)
calenderFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, -30)
calenderFrame:SetPoint("TOPRIGHT", gra.mainFrame, -8, -30)
calenderFrame:SetHeight(331)
calenderFrame:Hide()
gra.calenderFrame = calenderFrame

calenderFrame:SetScript("OnShow", function()
	LPP:PixelPerfectPoint(gra.mainFrame)
	gra.mainFrame:SetWidth(620)
end)

if GRA:Debug() then
	GRA:StylizeFrame(calenderFrame, {0, .7, 0, .1}, {0, 0, 0, 1})
end