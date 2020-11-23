local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- Penalize Frame
-----------------------------------------
local pType, pReason, pValue, pSelected, pDate, pIndex = nil, nil, nil, {}, nil, nil

local penalizeFrame = GRA:CreateMovableFrame(L["Penalize"], "GRA_PenalizeFrame", 400, 400, nil, "DIALOG")
penalizeFrame:SetToplevel(true)
gra.penalizeFrame = penalizeFrame

local dateText = penalizeFrame.header:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
dateText:SetPoint("LEFT", 10, 0)

-- penalize reason text
local pReasonText = penalizeFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
pReasonText:SetText("|cff80FF00" .. L["Reason"])
pReasonText:SetPoint("TOPLEFT", 10, -10)

-- penalize reason editbox
local pReasonEditBox = GRA:CreateEditBox(penalizeFrame, 160, 20)
pReasonEditBox:SetPoint("TOPLEFT", pReasonText, 10, -15)

-- penalize value text
local pValueText = penalizeFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
pValueText:SetText("|cff80FF00" .. L["Value"])
pValueText:SetPoint("LEFT", pReasonText, 200, 0)

local pValueEditBox = GRA:CreateEditBox(penalizeFrame, 122, 20)
pValueEditBox:SetPoint("TOPLEFT", pValueText, 10, -15)
pValueEditBox:SetNumeric(true) -- only accept positive number

-- epgp buttons
local epButton = GRA:CreateButton(penalizeFrame, "EP", nil, {20, 20}, "GRA_FONT_SMALL")
epButton:SetPoint("LEFT", pValueEditBox, "RIGHT", -1, 0)

local gpButton = GRA:CreateButton(penalizeFrame, "GP", nil, {20, 20}, "GRA_FONT_SMALL")
gpButton:SetPoint("LEFT", epButton, "RIGHT", -1, 0)

epButton:SetScript("OnClick", function()
    pType = "PEP"
    epButton:SetBackdropColor(.5, 1, 0, .6)
    epButton:SetScript("OnEnter", nil)
    epButton:SetScript("OnLeave", nil)
    gpButton:SetBackdropColor(.17, .17, .17, .6)
    gpButton:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .6) end)
    gpButton:SetScript("OnLeave", function(self) self:SetBackdropColor(.17, .17, .17, .6) end)
end)

gpButton:SetScript("OnClick", function()
    pType = "PGP"
    gpButton:SetBackdropColor(.5, 1, 0, .6)
    gpButton:SetScript("OnEnter", nil)
    gpButton:SetScript("OnLeave", nil)
    epButton:SetBackdropColor(.17, .17, .17, .6)
    epButton:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .6) end)
    epButton:SetScript("OnLeave", function(self) self:SetBackdropColor(.17, .17, .17, .6) end)
end)

local attendeesText = penalizeFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
attendeesText:SetText("|cff80FF00" .. L["Attendees"])
attendeesText:SetPoint("TOPLEFT", pReasonText, 0, -50)

local absenteesText = penalizeFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
absenteesText:SetText("|cff80FF00" .. L["Absentees"])
-- absenteesText:SetPoint("TOPLEFT", pValueText, 0, -45)

local attendeeCBs, absenteeCBs = {}, {}

local penalizeBtn = GRA:CreateButton(penalizeFrame, L["Guilty!"] .. "(0)", "red", {penalizeFrame:GetWidth(), 20}, "GRA_FONT_SMALL")
penalizeBtn:SetPoint("BOTTOM")
penalizeBtn:SetScript("OnClick", function()
    -- change officer note
    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        if pIndex then
            GRA:ModifyPenalizeEPGP(pDate, pType, pValue, pReason, pSelected, pIndex)
        else
            GRA:PenalizeEPGP(pDate, pType, pValue, pReason, pSelected)
        end
    else -- dkp
        if pIndex then
            GRA:ModifyPenalizeDKP(pDate, pValue, pReason, pSelected, pIndex)
        else
            GRA:PenalizeDKP(pDate, pValue, pReason, pSelected)
        end
    end
    penalizeFrame:Hide()
end)

local function SortByClass(t)
	table.sort(t, function(a, b)
		if a[2] ~= b[2] then
			return GRA:GetIndex(gra.CLASS_ORDER, a[2]) < GRA:GetIndex(gra.CLASS_ORDER, b[2])
		else
            return a[1] < b[1]
		end
	end)
end

local function CreatePlayerCheckBoxes(point, playerTbl, cbTbl)
    local lastCB, count = nil, 0
    -- sort gra.attendees k1:class k2:name
    local sorted = {}
    for _, n in pairs(playerTbl) do
        if _G[GRA_R_Roster][n] then -- ignore deleted
            table.insert(sorted, {n, _G[GRA_R_Roster][n]["class"], GRA:GetShortName(n)}) -- {"fullName", "class", "shortName"}
        end
    end
    SortByClass(sorted)

    for _, t in pairs(sorted) do
        -- create cbs
        if not cbTbl[t[1]] then
            cbTbl[t[1]] = GRA:CreateCheckButton(penalizeFrame, t[3], RAID_CLASS_COLORS[t[2]], function(checked)
                if checked then
                    table.insert(pSelected, t[1])
                else
                    GRA:Remove(pSelected, t[1])
                end
                penalizeBtn:SetText(L["Guilty!"] .. " (" .. #pSelected .. ")")
            end)
            cbTbl[t[1]].label:SetWidth(70)
            cbTbl[t[1]].label:SetWordWrap(false)
            cbTbl[t[1]]:SetScript("OnHide", function(self)
                self:SetChecked(false)
                self:Hide()
                self:ClearAllPoints() -- prepare for next SetPoint
            end)
        end
        
        -- SetPoint
        count = count + 1
        if lastCB then
            if count % 4 == 1 then
                cbTbl[t[1]]:SetPoint("TOPLEFT", point, 9, -19-26*floor(count/4))
            else
                cbTbl[t[1]]:SetPoint("LEFT", lastCB, "RIGHT", 72, 0)
            end
        else
            cbTbl[t[1]]:SetPoint("TOPLEFT", point, 9, -19)
        end
        lastCB = cbTbl[t[1]]
        cbTbl[t[1]]:Show()
    end
end

function GRA:ShowPenalizeFrame(d, type, reason, value, selected, index)
    pDate = d
    pIndex = index
    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        epButton:Show()
        gpButton:Show()
        pValueEditBox:SetWidth(122)
        pType = type or "PGP"
        if pType == "PGP" then gpButton:Click() else epButton:Click() end
    else -- dkp
        epButton:Hide()
        gpButton:Hide()
        pValueEditBox:SetWidth(160)
    end

    pReasonEditBox:SetText(reason or "")
    pValueEditBox:SetText(value and abs(value) or "")
    -- selected == {} --> unselect all
    if not selected then selected = {} end

    local attendees, absentees = GRA:GetAttendeesAndAbsentees(_G[GRA_R_RaidLogs][d], true)
    CreatePlayerCheckBoxes(attendeesText, attendees, attendeeCBs)
    absenteesText:SetPoint("TOPLEFT", attendeesText, 0, -ceil(GRA:Getn(attendees)/4)*26-20)
    CreatePlayerCheckBoxes(absenteesText, absentees, absenteeCBs)

    penalizeFrame:SetHeight(120 + ceil(GRA:Getn(attendees)/4)*26 + ceil(GRA:Getn(absentees)/4)*26)

    -- update cb state
    for name, cb in pairs(attendeeCBs) do
        if GRA:TContains(selected, name) then
            cb:SetChecked(true)
        else
            cb:SetChecked(false)
        end
    end

    for name, cb in pairs(absenteeCBs) do
        if GRA:TContains(selected, name) then
            cb:SetChecked(true)
        else
            cb:SetChecked(false)
        end
    end

    pSelected = GRA:Copy(selected)

    penalizeBtn:SetText(L["Guilty!"] .. " (" .. #pSelected .. ")")

    dateText:SetText(gra.colors.grey.s .. date("%x", GRA:DateToSeconds(d)))

    penalizeFrame:Show()
end

-- validation
penalizeFrame:SetScript("OnUpdate", function()
    pReason = pReasonEditBox:GetText()
    pValue = tonumber(pValueEditBox:GetText())
    if pValue ~= nil and pValue ~= 0 and pReason ~= "" and #pSelected ~= 0 then
        penalizeBtn:SetEnabled(true)
    else
        penalizeBtn:SetEnabled(false)
    end
end)

penalizeFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(penalizeFrame)
    gra.creditFrame:Hide()
    gra.awardFrame:Hide()
end)