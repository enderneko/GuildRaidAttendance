local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local dateString, dateButton
local attendanceEditor = GRA:CreateFrame(L["Attendance Editor"], "GRA_AttendanceEditor", gra.mainFrame, 300, gra.mainFrame:GetHeight())
gra.attendanceEditor = attendanceEditor
attendanceEditor:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
attendanceEditor:Hide()
-- help button
attendanceEditor.header.helpBtn = GRA:CreateButton(attendanceEditor.header, "?", "red", {16, 16}, "GRA_FONT_BUTTON")
attendanceEditor.header.helpBtn:SetPoint("RIGHT", attendanceEditor.header.closeBtn, "LEFT", 1, 0)
local fontName = GRA_FONT_BUTTON:GetFont()
attendanceEditor.header.helpBtn:GetFontString():SetFont(fontName, 12)

attendanceEditor.header.helpBtn:HookScript("OnEnter", function()
    GRA_Tooltip:SetOwner(attendanceEditor.header, "ANCHOR_TOPRIGHT", 0, 1)
    GRA_Tooltip:AddLine(L["Attendance Editor Help"])
    GRA_Tooltip:AddLine(L["Double-click on the second column: "] .. "|cffffffff" .. L["Select attendance status."])
    GRA_Tooltip:AddLine(L["Click on the third column: "] .. "|cffffffff" .. L["Set join time (Present) / note (Absent)."])
    GRA_Tooltip:Show()
end)

attendanceEditor.header.helpBtn:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

local raidDateText = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
raidDateText:SetPoint("TOPLEFT", 5, -10)

local raidStartTimeEditBox = GRA:CreateEditBox(attendanceEditor, 70, 20, false, "GRA_FONT_SMALL")
raidStartTimeEditBox:SetJustifyH("CENTER")
raidStartTimeEditBox:SetPoint("TOPRIGHT", attendanceEditor, -5, -5)

local raidStartTimeText = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
raidStartTimeText:SetPoint("RIGHT", raidStartTimeEditBox, "LEFT", -5, 0)
raidStartTimeText:SetText("|cff80FF00" .. L["Raid Start Time"] .. ": ")

local RSTComfirmBtn = GRA:CreateButton(raidStartTimeEditBox, L["OK"], "blue", {20, 20}, "GRA_FONT_SMALL")
RSTComfirmBtn:SetPoint("RIGHT", raidStartTimeEditBox)
RSTComfirmBtn:Hide()
RSTComfirmBtn:SetScript("OnClick", function()
	local h, m = string.split(":", raidStartTimeEditBox:GetText())
	local startTime = string.format("%02d", h) .. ":" .. string.format("%02d", m)

	_G[GRA_R_RaidLogs][dateString]["startTime"] = startTime
    -- update attendance sheet column
    GRA:FireEvent("GRA_ST_UPDATE", dateString)

	raidStartTimeEditBox:SetText(startTime)

	raidStartTimeEditBox:ClearFocus()
	RSTComfirmBtn:Hide()
end)

raidStartTimeEditBox:SetScript("OnTextChanged", function(self, userInput)
	if not userInput then return end
	-- check time validity
	local h, m = string.split(":", raidStartTimeEditBox:GetText())
	h, m = tonumber(h), tonumber(m)
	if h and m and h >= 0 and h <= 23 and m >= 0 and m <= 59 then
		RSTComfirmBtn:Show()
		GRA:StylizeFrame(raidStartTimeEditBox, {.1, .1, .1, .9})
	else
		RSTComfirmBtn:Hide()
		GRA:StylizeFrame(raidStartTimeEditBox, {.1, .1, .1, .9}, {1, 0, 0, 1})
	end
end)

-- next OnShow, its data MUST be valid
raidStartTimeEditBox:SetScript("OnHide", function()
	RSTComfirmBtn:Hide()
	GRA:StylizeFrame(raidStartTimeEditBox, {.1, .1, .1, .9})
end)
 
local scroll = GRA:CreateScrollFrame(attendanceEditor, -28, 29)
GRA:StylizeFrame(scroll, {0, 0, 0, 0})
scroll:SetScrollStep(19)

local SaveChanges
local saveBtn = GRA:CreateButton(attendanceEditor, L["Save All Changes"], "green", {143, 20})
saveBtn:SetPoint("BOTTOMLEFT", 5, 5)
saveBtn:SetScript("OnClick", function()
    SaveChanges()
end)

local DiscardChanges
local discardBtn = GRA:CreateButton(attendanceEditor, L["Discard All Changes"], "red", {143, 20})
discardBtn:SetPoint("BOTTOMRIGHT", -5, 5)
discardBtn:SetScript("OnClick", function()
    DiscardChanges()
end)

-- attendances: _G[GRA_R_RaidLogs] data
-- changes: changed data
-- rows: row buttons, used for highlighting and discarding changes
local attendances, changes, rows = {}, {}, {}
local function CheckAttendances(d)
    attendances = {}
    for n, _ in pairs(_G[GRA_R_Roster]) do
        if _G[GRA_R_RaidLogs][d]["attendees"][n] then -- present
            attendances[n] = {L["Present"], _G[GRA_R_RaidLogs][d]["attendees"][n][2]}
        elseif _G[GRA_R_RaidLogs][d]["absentees"][n] then -- absent
            attendances[n] = {L["Absent"], _G[GRA_R_RaidLogs][d]["absentees"][n]}
        else -- ignored
            attendances[n] = {L["Ignored"]}
        end
    end
end

-- set player attendance: on changed, save to changes(table)
local function SetPlayerAttendance(name, raidDate, attendance, reason)
    local changed = false

    if attendance then
        -- attendance changed
        if attendance ~= attendances[name][1] then 
            if not changes[name] then changes[name] = {} end
            changes[name][1] = attendance
            changed = true
        else
            changes = GRA:RemoveElementsByKeys(changes, {name})
            changed = false
        end
    end

    if reason then
        -- absent reason / join time changed
        if reason ~= attendances[name][2] then
            -- print(reason)
            -- print(attendances[name][2])
            if not changes[name] then changes[name] = {} end
            changes[name][1] = attendance
            changes[name][2] = reason
            changed = true
        else
            changes = GRA:RemoveElementsByKeys(changes, {name})
            changed = false
        end
    end

    -- texplore(changes)
    return changed
end

-- set attendance text color
local function SetAttendanceColor(g)
    if g:GetText() == L["Present"] then
        g:GetFontString():SetTextColor(0, 1, 0, .8)
    elseif g:GetText() == L["Absent"] then
        g:GetFontString():SetTextColor(1, 0, 0, .8)
    else -- ignored
        g:GetFontString():SetTextColor(.7, .7, .7, .8)
    end
end

SaveChanges = function()
    for n, t in pairs(changes) do
        -- delete original data
        if attendances[n][1] == L["Present"] then
            _G[GRA_R_RaidLogs][dateString]["attendees"] = GRA:RemoveElementsByKeys(_G[GRA_R_RaidLogs][dateString]["attendees"], {n})
        elseif attendances[n][1] == L["Absent"] then
            _G[GRA_R_RaidLogs][dateString]["absentees"] = GRA:RemoveElementsByKeys(_G[GRA_R_RaidLogs][dateString]["absentees"], {n})
        end

        if changes[n][1] == L["Present"] then
            -- save to attendees
            _G[GRA_R_RaidLogs][dateString]["attendees"][n] = {GRA:IsLate(changes[n][2], dateString.._G[GRA_R_Config]["raidInfo"]["startTime"]), changes[n][2]}
        elseif changes[n][1] == L["Absent"] then
            -- save to absentees
            _G[GRA_R_RaidLogs][dateString]["absentees"][n] = changes[n][2] or ""
        end

        GRA:StylizeFrame(rows[n].nameGrid, {.7,.7,.7,.1})
        GRA:StylizeFrame(rows[n].attendanceGrid, {.7,.7,.7,.1})
        GRA:StylizeFrame(rows[n].reasonEditBox, {.7,.7,.7,.1})
    end

    changes = {}
    -- refresh date detail
    dateButton:Click()
    GRA:Print(L["Saved all attendance changes on %s."]:format(date("%x", GRA:DateToTime(dateString))))
    -- re-check attendances
    CheckAttendances(dateString)
    -- update attendance sheet & raid logs
    GRA:FireEvent("GRA_RAIDLOGS", dateString)
end

DiscardChanges = function()
    for n, _ in pairs(changes) do
        rows[n].attendanceGrid:SetText(attendances[n][1])
        if attendances[n][1] == L["Present"] then
            rows[n].reasonEditBox:SetText(GRA:SecondsToTime(attendances[n][2]))
        else
            rows[n].reasonEditBox:SetText(attendances[n][2] or "")
        end
        SetAttendanceColor(rows[n].attendanceGrid)
        GRA:StylizeFrame(rows[n].nameGrid, {.7,.7,.7,.1})
        GRA:StylizeFrame(rows[n].attendanceGrid, {.7,.7,.7,.1})
        GRA:StylizeFrame(rows[n].reasonEditBox, {.7,.7,.7,.1})
    end

    changes = {}
    GRA:Print(L["Discarded all member changes on %s."]:format(date("%x", GRA:DateToTime(dateString))))
end

function GRA:ShowAttendanceEditor(d, b)
    dateButton = b
    dateString = d
    raidDateText:SetText("|cff80FF00" .. L["Raid Date: "] .. "|r" .. date("%x", GRA:DateToTime(d)))
    raidStartTimeEditBox:SetText(_G[GRA_R_RaidLogs][d]["startTime"] or _G[GRA_R_Config]["raidInfo"]["startTime"])

    scroll:Reset()
    rows = {}

    -- check attendances from _G[GRA_R_RaidLogs][d]
    CheckAttendances(d)
    local last
    for n, t in pairs(attendances) do
        local row = GRA:CreateRow_MemberEditor(scroll.content, attendanceEditor:GetWidth(), GRA:GetClassColoredName(n))
        scroll:SetWidgetAutoWidth(row)
        rows[n] = row

        row.attendanceGrid:SetText(t[1])
        -- text color
        SetAttendanceColor(row.attendanceGrid)
        -- set attendance
        row.attendanceGrid:SetScript("OnDoubleClick", function()
            local items = {
                {
                    ["text"] = L["Present"],
                    ["color"] = "green",
                    ["onClick"] = function()
                        if row.attendanceGrid:GetText() ~= L["Present"] then
                            row.reasonEditBox:SetText(_G[GRA_R_Config]["raidInfo"]["startTime"])
                        end
                        row.attendanceGrid:SetText(L["Present"])
                        SetAttendanceColor(row.attendanceGrid)
                        row.reasonEditBox:SetEnabled(true)
                        -- print(dateString..row.reasonEditBox:GetText())
                        local changed = SetPlayerAttendance(n, d, L["Present"], GRA:DateToTime(dateString..row.reasonEditBox:GetText(), true))
                        if changed then
                            GRA:StylizeFrame(row.nameGrid, {1, .3, .3, .2})
                            GRA:StylizeFrame(row.attendanceGrid, {1, .3, .3, .2})
                            GRA:StylizeFrame(row.reasonEditBox, {1, .3, .3, .2})
                        else
                            GRA:StylizeFrame(row.nameGrid, {.7,.7,.7,.1})
                            GRA:StylizeFrame(row.attendanceGrid, {.7,.7,.7,.1})
                            GRA:StylizeFrame(row.reasonEditBox, {.7,.7,.7,.1})
                        end
                    end
                },
                {
                    ["text"] = L["Absent"],
                    ["color"] = "red",
                    ["onClick"] = function()
                        if row.attendanceGrid:GetText() ~= L["Absent"] then
                            row.reasonEditBox:SetText("")
                        end
                        row.attendanceGrid:SetText(L["Absent"])
                        SetAttendanceColor(row.attendanceGrid)
                        row.reasonEditBox:SetEnabled(true)
                        local changed = SetPlayerAttendance(n, d, L["Absent"], row.reasonEditBox:GetText())
                        if changed then
                            GRA:StylizeFrame(row.nameGrid, {1, .3, .3, .2})
                            GRA:StylizeFrame(row.attendanceGrid, {1, .3, .3, .2})
                            GRA:StylizeFrame(row.reasonEditBox, {1, .3, .3, .2})
                        else
                            GRA:StylizeFrame(row.nameGrid, {.7,.7,.7,.1})
                            GRA:StylizeFrame(row.attendanceGrid, {.7,.7,.7,.1})
                            GRA:StylizeFrame(row.reasonEditBox, {.7,.7,.7,.1})
                        end
                    end
                },
                {
                    ["text"] = L["Ignored"],
                    ["color"] = "yellow",
                    ["onClick"] = function()
                        if row.attendanceGrid:GetText() ~= L["Ignored"] then
                            row.reasonEditBox:SetText("")
                        end
                        row.attendanceGrid:SetText(L["Ignored"])
                        SetAttendanceColor(row.attendanceGrid)
                        row.reasonEditBox:SetEnabled(false)
                        local changed = SetPlayerAttendance(n, d, L["Ignored"])
                        if changed then
                            GRA:StylizeFrame(row.nameGrid, {1, .3, .3, .2})
                            GRA:StylizeFrame(row.attendanceGrid, {1, .3, .3, .2})
                            GRA:StylizeFrame(row.reasonEditBox, {1, .3, .3, .2})
                        else
                            GRA:StylizeFrame(row.nameGrid, {.7,.7,.7,.1})
                            GRA:StylizeFrame(row.attendanceGrid, {.7,.7,.7,.1})
                            GRA:StylizeFrame(row.reasonEditBox, {.7,.7,.7,.1})
                        end
                    end
                },
            }
		    local selector = GRA:CreatePopupSelector(row.attendanceGrid, 60, items)
            -- selector:SetPoint("TOPLEFT", row.attendanceGrid, "BOTTOMLEFT", 0, -1)
            selector:SetPoint("TOPLEFT")
	    end)

        row.confirmBtn = GRA:CreateButton(row.reasonEditBox, L["OK"], "blue", {30, 20}, "GRA_FONT_SMALL")
        row.confirmBtn:SetPoint("RIGHT")
        row.confirmBtn:Hide()
        row.confirmBtn:SetScript("OnClick", function()
            local changed
            if row.attendanceGrid:GetText() == L["Present"] then
                local h, m = string.split(":", row.reasonEditBox:GetText())
                local joinTime = string.format("%02d", h) .. ":" .. string.format("%02d", m)
                row.reasonEditBox:SetText(joinTime)
                -- join time
                changed = SetPlayerAttendance(n, d, row.attendanceGrid:GetText(), GRA:DateToTime(dateString..joinTime, true))
            else
                changed = SetPlayerAttendance(n, d, row.attendanceGrid:GetText(), row.reasonEditBox:GetText())
            end

            if changed then
                GRA:StylizeFrame(row.nameGrid, {1, .3, .3, .2})
                GRA:StylizeFrame(row.attendanceGrid, {1, .3, .3, .2})
                GRA:StylizeFrame(row.reasonEditBox, {1, .3, .3, .2})
            else
                GRA:StylizeFrame(row.nameGrid, {.7,.7,.7,.1})
                GRA:StylizeFrame(row.attendanceGrid, {.7,.7,.7,.1})
                GRA:StylizeFrame(row.reasonEditBox, {.7,.7,.7,.1})
            end

            row.reasonEditBox:ClearFocus()
            row.confirmBtn:Hide()
        end)

        if row.attendanceGrid:GetText() == L["Absent"] then
            row.reasonEditBox:SetText(t[2])
        elseif row.attendanceGrid:GetText() == L["Present"] then -- format seconds to time
            row.reasonEditBox:SetText(GRA:SecondsToTime(t[2]))
        else -- ignored
            row.reasonEditBox:SetEnabled(false)
        end

        row.reasonEditBox:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            row.confirmBtn:Show()
            if row.attendanceGrid:GetText() == L["Present"] then
                local h, m = string.split(":", row.reasonEditBox:GetText())
                h, m = tonumber(h), tonumber(m)
                if h and m and h >= 0 and h <= 23 and m >= 0 and m <= 59 then
                    row.confirmBtn:Show()
                    row.reasonEditBox:SetTextColor(1, 1, 1, 1)
                    saveBtn:SetEnabled(true)
                else
                    row.confirmBtn:Hide()
                    row.reasonEditBox:SetTextColor(1, .12, .12, 1)
                    saveBtn:SetEnabled(false)
                end
            end
        end)

        if last then
            row:SetPoint("TOP", last, "BOTTOM", 0, 1)
        else
            row:SetPoint("TOP")
        end
        last = row
    end
    attendanceEditor:Show()
end

attendanceEditor:SetScript("OnHide", function(self)
    self:Hide()
end)