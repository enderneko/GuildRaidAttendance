local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

---------------------------------------------------------------------
-- Award Frame
---------------------------------------------------------------------
local aReason, aValue, aSelected, aDate, aIndex, aFloatBtn = nil, nil, {}, nil, nil, nil

local awardFrame = GRA.CreateMovableFrame("XX Award", "GRA_AwardFrame", 400, 400, nil, "DIALOG")
awardFrame:SetToplevel(true)
gra.awardFrame = awardFrame

local dateText = awardFrame.header:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
dateText:SetPoint("LEFT", 10, 0)

-- reason text
local aReasonText = awardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
aReasonText:SetText("|cff80FF00" .. L["Reason"])
aReasonText:SetPoint("TOPLEFT", 10, -10)

-- reason editbox
local aReasonEditBox = GRA.CreateEditBox(awardFrame, 160, 20)
aReasonEditBox:SetPoint("TOPLEFT", aReasonText, 10, -15)

-- value text
local aValueText = awardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
aValueText:SetText("|cff80FF00" .. L["Value"])
aValueText:SetPoint("LEFT", aReasonText, 200, 0)

local aValueEditBox = GRA.CreateEditBox(awardFrame, 160, 20)
aValueEditBox:SetPoint("TOPLEFT", aValueText, 10, -15)
aValueEditBox:SetScript("OnEnterPressed", function()
    local ex = aValueEditBox:GetText()
    if string.find(ex,"=") == 1 then
        ex = string.sub(ex, 2)
        local status, result = GRA.Calc(ex)
        if status then
            aValueEditBox:SetText(result)
            aValueEditBox:ClearFocus()
        else
            GRA.ShowNotificationString(awardFrame, gra.colors.firebrick.s .. result, "TOPLEFT", aValueEditBox, "BOTTOMLEFT", 0, -3)
        end
    else
        aValueEditBox:ClearFocus()
    end
end)

local attendeesText = awardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
attendeesText:SetText("|cff80FF00" .. L["Attendees"])
attendeesText:SetPoint("TOPLEFT", aReasonText, 0, -50)

-- local absenteesText = awardFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
-- absenteesText:SetText("|cff80FF00" .. L["Absentees"])
-- absenteesText:SetPoint("TOPLEFT", aValueText, 0, -45)

local attendeeCBs, absenteeCBs = {}, {}

local awardBtn = GRA.CreateButton(awardFrame, "Award XX" .. "(0)", "red", {awardFrame:GetWidth(), 20}, "GRA_FONT_SMALL")
awardBtn:SetPoint("BOTTOM")
awardBtn:SetScript("OnClick", function()
    -- change officer note
    if GRA_Config["raidInfo"]["system"] == "EPGP" then
        if aIndex then
            GRA.ModifyEP(aDate, aValue, aReason, aSelected, aIndex)
        else
            GRA.AwardEP(aDate, aValue, aReason, aSelected)
        end
    else -- dkp
        if aIndex then
            GRA.ModifyDKP_A(aDate, aValue, aReason, aSelected, aIndex)
        else
            GRA.AwardDKP(aDate, aValue, aReason, aSelected)
        end
    end
    awardFrame:Hide()

    if aFloatBtn then aFloatBtn:Hide() end
end)

local system
local function UpdateAwardBtnText()
    awardBtn:SetText((aIndex and L["Modify " .. system] or L["Award " .. system]) .. " (" .. #aSelected .. ")")
end

local unSelectAllAttendees = GRA.CreateButton(awardFrame, L["Unselect All"], nil, {70, 16}, "GRA_FONT_SMALL")
unSelectAllAttendees:SetPoint("LEFT", attendeesText, 140, 0)
unSelectAllAttendees:SetScript("OnClick", function()
    -- aSelected = {}
    for name, cb in pairs(attendeeCBs) do
        if cb:IsShown() then -- only select shown cbs
            cb:SetChecked(false)
            GRA.Remove(aSelected, name)
        end
    end
    UpdateAwardBtnText()
end)

local selectAllAttendees = GRA.CreateButton(awardFrame, L["Select All"], nil, {70, 16}, "GRA_FONT_SMALL")
selectAllAttendees:SetPoint("RIGHT", unSelectAllAttendees, "LEFT", -5, 0)
selectAllAttendees:SetScript("OnClick", function()
    -- print(GRA.TableToString(aSelected))
    -- aSelected = {}
    for name, cb in pairs(attendeeCBs) do
        if cb:IsShown() then -- only select shown cbs
            cb:SetChecked(true)
            if not GRA.TContains(aSelected, name) then
                table.insert(aSelected, name)
            end
        end
    end
    UpdateAwardBtnText()
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
---------------------------------------------------------------------

local function SortByClass(t)
	table.sort(t, function(a, b)
		if a[2] ~= b[2] then
			return GRA.GetIndex(gra.CLASS_ORDER, a[2]) < GRA.GetIndex(gra.CLASS_ORDER, b[2])
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
        if GRA_Roster[n] then -- ignore deleted
            table.insert(sorted, {n, GRA_Roster[n]["class"], GRA.GetShortName(n)}) -- {"fullName", "class", "shortName"}
        end
    end
    SortByClass(sorted)

    for _, t in pairs(sorted) do
        -- create cbs
        if not cbTbl[t[1]] then
            cbTbl[t[1]] = GRA.CreateCheckButton(awardFrame, t[3], RAID_CLASS_COLORS[t[2]], function(checked)
                if checked then
                    table.insert(aSelected, t[1])
                else
                    GRA.Remove(aSelected, t[1])
                end
                UpdateAwardBtnText()
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

function GRA.ShowAwardFrame(d, reason, value, selected, index, floatBtn)
    aDate = d
    aIndex = index
    aFloatBtn = floatBtn

    aReasonEditBox:SetText(reason or "")
    aValueEditBox:SetText(value or "")
    -- selected == {} --> unselect all
    if not selected then selected = {} end

    local attendees = GRA.GetAttendeesAndAbsentees(GRA_Logs[d], true)
    CreatePlayerCheckBoxes(attendeesText, attendees, attendeeCBs)
    -- absenteesText:SetPoint("TOPLEFT", attendeesText, 0, -ceil(GRA.Getn(attendees)/4)*26-20)
    -- CreatePlayerCheckBoxes(absenteesText, absentees, absenteeCBs)

    awardFrame:SetHeight(100 + ceil(GRA.Getn(attendees)/4)*26)

    -- update cb state
    for name, cb in pairs(attendeeCBs) do
        if GRA.TContains(selected, name) then
            cb:SetChecked(true)
        else
            cb:SetChecked(false)
        end
    end

    for name, cb in pairs(absenteeCBs) do
        if GRA.TContains(selected, name) then
            cb:SetChecked(true)
        else
            cb:SetChecked(false)
        end
    end

    aSelected = GRA.Copy(selected)

    if GRA_Config["raidInfo"]["system"] == "EPGP" then
        system = "EP"
    else -- dkp
        system = "DKP"
    end
    awardFrame.header.text:SetText(L[system .. " Award"])
    UpdateAwardBtnText()

    dateText:SetText(gra.colors.grey.s .. date("%x", GRA.DateToSeconds(d)))

    awardFrame:Show()
end

-- validation
awardFrame:SetScript("OnUpdate", function()
    aReason = aReasonEditBox:GetText()
    aValue = tonumber(aValueEditBox:GetText())
    if aValue ~= nil and aValue ~= 0 and aReason ~= "" and #aSelected ~= 0 then
        awardBtn:SetEnabled(true)
    else
        awardBtn:SetEnabled(false)
    end
end)

awardFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(awardFrame)
    gra.creditFrame:Hide()
    gra.penalizeFrame:Hide()
end)