local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- announcement frame
-----------------------------------------
local announcementsFrame = CreateFrame("Frame", "GRA_AnnouncementsFrame", gra.mainFrame)
announcementsFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, -30)
announcementsFrame:SetPoint("TOPRIGHT", gra.mainFrame, -8, -30)
announcementsFrame:SetHeight(331)
announcementsFrame:Hide()
gra.announcementsFrame = announcementsFrame

announcementsFrame:SetScript("OnShow", function()
	LPP:PixelPerfectPoint(gra.mainFrame)
	gra.mainFrame:SetWidth(620)
end)

if GRA:Debug() then
	GRA:StylizeFrame(announcementsFrame, {0, .7, 0, .1}, {0, 0, 0, 1})
end