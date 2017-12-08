local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- EP Award Frame
-----------------------------------------
local epReason, epValue, epSelected, epDate, epIndex, epFloatBtn = nil, nil, {}, nil, nil, nil

local epAwardFrame = GRA:CreateMovableFrame(L["EP Award"], "GRA_EPAwardFrame", 400, 400, nil, true, "DIALOG")
epAwardFrame:SetToplevel(true)
gra.epAwardFrame = epAwardFrame

local dateText = epAwardFrame.header:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
dateText:SetPoint("LEFT", 10, 0)

-- ep reason text
local epReasonText = epAwardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
epReasonText:SetText("|cff80FF00" .. L["Reason"])
epReasonText:SetPoint("TOPLEFT", 10, -10)

-- ep reason editbox
local epReasonEditBox = GRA:CreateEditBox(epAwardFrame, 160, 20)
epReasonEditBox:SetPoint("TOPLEFT", epReasonText, 10, -15)

-- ep value text
local epValueText = epAwardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
epValueText:SetText("|cff80FF00" .. L["Value"])
epValueText:SetPoint("LEFT", epReasonText, 200, 0)

local epValueEditBox = GRA:CreateEditBox(epAwardFrame, 160, 20)
epValueEditBox:SetPoint("TOPLEFT", epValueText, 10, -15)
epValueEditBox:SetScript("OnEnterPressed", function()
    local ex = epValueEditBox:GetText()
    if string.find(ex,"=") == 1 then
        ex = string.sub(ex, 2)
        local status, result = GRA:Calc(ex)
        if status then
            epValueEditBox:SetText(result)
            epValueEditBox:ClearFocus()
        else
            GRA:ShowNotificationString(gra.colors.firebrick.s .. result, "TOPLEFT", epValueEditBox, "BOTTOMLEFT", 0, -3)
        end
    else
        epValueEditBox:ClearFocus()
    end
end)

local attendeesText = epAwardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
attendeesText:SetText("|cff80FF00" .. L["Attendees"])
attendeesText:SetPoint("TOPLEFT", epReasonText, 0, -50)

local absenteesText = epAwardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
absenteesText:SetText("|cff80FF00" .. L["Absentees"])
-- absenteesText:SetPoint("TOPLEFT", epValueText, 0, -45)

local attendeeCBs, absenteeCBs = {}, {}

local awardBtn = GRA:CreateButton(epAwardFrame, L["Award EP"] .. "(0)", "red", {epAwardFrame:GetWidth(), 20}, "GRA_FONT_SMALL")
awardBtn:SetPoint("BOTTOM")
awardBtn:SetScript("OnClick", function()
    -- change officer note
    if epIndex then
        GRA:ModifyEP(epDate, epValue, epReason, epSelected, epIndex)
    else
        GRA:AwardEP(epDate, epValue, epReason, epSelected)
    end
    epAwardFrame:Hide()

    if epFloatBtn then epFloatBtn:Hide() end
end)

local unSelectAllAttendees = GRA:CreateButton(epAwardFrame, L["Unselect All"], nil, {70, 16}, "GRA_FONT_SMALL")
unSelectAllAttendees:SetPoint("LEFT", attendeesText, 140, 0)
unSelectAllAttendees:SetScript("OnClick", function()
    -- epSelected = {}
    for name, cb in pairs(attendeeCBs) do
        if cb:IsShown() then -- only select shown cbs
            cb:SetChecked(false)
            GRA:Remove(epSelected, name)
        end
    end
    awardBtn:SetText((epIndex and L["Modify EP"] or L["Award EP"]) .. " (" .. #epSelected .. ")")
end)

local selectAllAttendees = GRA:CreateButton(epAwardFrame, L["Select All"], nil, {70, 16}, "GRA_FONT_SMALL")
selectAllAttendees:SetPoint("RIGHT", unSelectAllAttendees, "LEFT", -5, 0)
selectAllAttendees:SetScript("OnClick", function()
    -- print(GRA:TableToString(epSelected))
    -- epSelected = {}
    for name, cb in pairs(attendeeCBs) do
        if cb:IsShown() then -- only select shown cbs
            cb:SetChecked(true)
            if tContains(epSelected, name) ~= 1 then
                table.insert(epSelected, name)
            end
        end
    end
    awardBtn:SetText((epIndex and L["Modify EP"] or L["Award EP"]) .. " (" .. #epSelected .. ")")
end)

-- test ------------------------------------------
-- local attendees = {}
-- local classes = {"WARRIOR", "HUNTER", "SHAMAN", "MONK", "ROGUE", "MAGE", "DRUID", "DEATHKNIGHT", "PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"}
-- for i = 1, random(20, 40) do
--     local name = ""
--     for j = 1, random(3, 12) do
--         name = name .. string.char(random(97, 122))
--     end
--     attendees[name] = {"", classes[random(1, 12)]}
-- end
--------------------------------------------------

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
    for k, _ in pairs(playerTbl) do
        if _G[GRA_R_Roster][k] then -- ignore deleted
            table.insert(sorted, {k, _G[GRA_R_Roster][k]["class"], GRA:GetShortName(k)}) -- {"fullName", "class", "shortName"}
        end
    end
    SortByClass(sorted)

    for _, t in pairs(sorted) do
        -- create cbs
        if not cbTbl[t[1]] then
            cbTbl[t[1]] = GRA:CreateCheckButton(epAwardFrame, t[3], RAID_CLASS_COLORS[t[2]], function(checked)
                if checked then
                    table.insert(epSelected, t[1])
                else
                    GRA:Remove(epSelected, t[1])
                end
                awardBtn:SetText((epIndex and L["Modify EP"] or L["Award EP"]) .. " (" .. #epSelected .. ")")
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

function GRA:ShowEPAwardFrame(d, reason, ep, selected, attendees, absentees, index, floatBtn)
    if epAwardFrame:IsShown() then epAwardFrame:Hide() end

    epDate = d
    epIndex = index
    epFloatBtn = floatBtn

    epReasonEditBox:SetText(reason and reason or "")
    epValueEditBox:SetText(ep and ep or "")
    -- selected == {} --> unselect all
    if not selected then selected = {} end

    CreatePlayerCheckBoxes(attendeesText, attendees, attendeeCBs)
    -- absenteesText:SetPoint("TOPLEFT", attendeesText, 0, -ceil(GRA:Getn(attendeeCBs)/4)*26-20)
    absenteesText:SetPoint("TOPLEFT", attendeesText, 0, -ceil(GRA:Getn(attendees)/4)*26-20)
    CreatePlayerCheckBoxes(absenteesText, absentees, absenteeCBs)

    -- epAwardFrame:SetHeight(120 + ceil(GRA:Getn(attendeeCBs)/4)*26 + ceil(GRA:Getn(absenteeCBs)/4)*26)
    epAwardFrame:SetHeight(120 + ceil(GRA:Getn(attendees)/4)*26 + ceil(GRA:Getn(absentees)/4)*26)

    epAwardFrame:Show()

    -- update cb state
    for name, cb in pairs(attendeeCBs) do
        if tContains(selected, name) then
            cb:SetChecked(true)
        else
            cb:SetChecked(false)
        end
    end

    for name, cb in pairs(absenteeCBs) do
        if tContains(selected, name) then
            cb:SetChecked(true)
        else
            cb:SetChecked(false)
        end
    end

    epSelected = GRA:Copy(selected)

    awardBtn:SetText((epIndex and L["Modify EP"] or L["Award EP"]) .. " (" .. #epSelected .. ")")

    dateText:SetText(gra.colors.grey.s .. date("%x", GRA:DateToTime(d)))
end

-- validation
epAwardFrame:SetScript("OnUpdate", function()
    epReason = epReasonEditBox:GetText()
    epValue = tonumber(epValueEditBox:GetText())
    if epValue ~= nil and epValue ~= 0 and epReason ~= "" and #epSelected ~= 0 then
        awardBtn:SetEnabled(true)
    else
        awardBtn:SetEnabled(false)
    end
end)

epAwardFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(epAwardFrame)
    gra.gpCreditFrame:Hide()
    gra.penalizeFrame:Hide()
end)