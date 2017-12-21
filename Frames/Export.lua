local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local exportFrame = GRA:CreateMovableFrame(L["Export"], "GRA_ExportFrame", 400, 400, nil, "DIALOG")
exportFrame:SetToplevel(true)
gra.exportFrame = exportFrame

local eb = CreateFrame("EditBox", nil, exportFrame)
GRA:StylizeFrame(eb, {.1, .1, .1, .9})
eb:SetFontObject("GRA_FONT_TEXT")
eb:SetJustifyH("LEFT")
eb:SetJustifyV("CENTER")
eb:SetMultiLine(true)
eb:SetMaxLetters(0)
eb:SetTextInsets(5, 5, 5, 5)
eb:SetPoint("TOPLEFT", 8, -8)
eb:SetPoint("BOTTOMRIGHT", -8, 8)

exportFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(exportFrame)
    eb:Insert(strjoin(",", L["Name"], "EP", "GP", "PR", "AR", L["Present"], L["Absent"], L["Late"], L["On Leave"], L["Loots"]))
    eb:Insert("\n")
    for name, t in pairs(_G[GRA_R_Roster]) do
        local ar = tonumber(format("%.1f", t["attLifetime"][1]/(t["attLifetime"][1]+t["attLifetime"][2])*100)) or 0
        eb:Insert(strjoin(",", name, t["EP"], t["GP"], GRA:GetPR(name), ar.."%", t["attLifetime"][1], t["attLifetime"][2], t["attLifetime"][3], t["attLifetime"][4], 0))
        eb:Insert("\n")
    end
end)

exportFrame:SetScript("OnHide", function()
    eb:SetText("")
end)