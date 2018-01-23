local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local dateString, dateButton, raidStartTime
-- attendances: _G[GRA_R_RaidLogs] data
-- changes: changed data
-- rows: row buttons, used for highlighting and discarding changes
local attendances, changes, rows = {}, {}, {}

local attendanceEditor = GRA:CreateFrame(L["Attendance Editor"], "GRA_AttendanceEditor", gra.mainFrame, 326, gra.mainFrame:GetHeight())
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
    GRA_Tooltip:AddLine(L["Click on the last column: "] .. "|cffffffff" .. L["Set notes (not available for alts)."])
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
	raidStartTime = string.format("%02d", h) .. ":" .. string.format("%02d", m)

	_G[GRA_R_RaidLogs][dateString]["startTime"] = raidStartTime
    -- update attendance sheet column
    GRA:FireEvent("GRA_ST_UPDATE", dateString)

	raidStartTimeEditBox:SetText(raidStartTime)

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

-- sort & set point
local function SortAttendanceEditor()
    local sorted ={}
    for n, row in pairs(rows) do
        local att
        if row.attendance == "PRESENT" then
            att = 1
        elseif row.attendance == "ONLEAVE" then
            att = 2
        elseif row.attendance == "ABSENT" then
            att = 3
        else -- IGNORED
            att = 4
        end
        table.insert(sorted, {n, att, row.joinTime})
    end
    table.sort(sorted, function(a, b)
        if a[2] ~= b[2] then
            return a[2] < b[2]
        elseif a[3] ~= b[3] then
            return a[3] < b[3]
        else
            return a[1] < b[1]
        end 
    end)

    local last
    for _, t in pairs(sorted) do
        if last then
            rows[t[1]]:SetPoint("TOP", last, "BOTTOM", 0, 1)
        else
            rows[t[1]]:SetPoint("TOP")
        end
        last = rows[t[1]]
    end
    wipe(sorted)
end

local SaveChanges
local saveBtn = GRA:CreateButton(attendanceEditor, L["Save All Changes"], "green", {156, 20})
saveBtn:SetPoint("BOTTOMLEFT", 5, 5)
saveBtn:SetScript("OnClick", function()
    SaveChanges()
    SortAttendanceEditor()
end)

local DiscardChanges
local discardBtn = GRA:CreateButton(attendanceEditor, L["Discard All Changes"], "red", {156, 20})
discardBtn:SetPoint("BOTTOMRIGHT", -5, 5)
discardBtn:SetScript("OnClick", function()
    DiscardChanges()
end)

local function CheckAttendances(d)
    attendances = {}
    for n, _ in pairs(_G[GRA_R_Roster]) do
        if _G[GRA_R_RaidLogs][d]["attendances"][n] then -- present/absent/late/onleave
            if _G[GRA_R_RaidLogs][d]["attendances"][n][3] then -- present/late
                attendances[n] = {"PRESENT", _G[GRA_R_RaidLogs][d]["attendances"][n][2], _G[GRA_R_RaidLogs][d]["attendances"][n][3]}
            else -- absent/onleave
                attendances[n] = {_G[GRA_R_RaidLogs][d]["attendances"][n][1], _G[GRA_R_RaidLogs][d]["attendances"][n][2]}
            end
        else -- ignored
            attendances[n] = {"IGNORED"}
        end
    end
end

-- set player attendance: on changed, save to changes(table)
local function CheckPlayerAttendance(row)
    local changed = false
    local name = row.name
    -- attendance/note/joinTime changed
    if row.attendance ~= attendances[name][1] or row.note ~= attendances[name][2] or row.joinTime ~= attendances[name][3] then 
        if not changes[name] then changes[name] = {} end
        changes[name][1] = row.attendance
        changes[name][2] = row.note
        changes[name][3] = row.joinTime
        changed = true
    else
        changes = GRA:RemoveElementsByKeys(changes, {name})
        changed = false
    end

    row:SetChanged(changed)
    -- texplore(changes)
end

SaveChanges = function()
    if GRA:Getn(changes) == 0 then return end
    for n, t in pairs(changes) do
        if t[1] == "IGNORED" then -- delete
            _G[GRA_R_RaidLogs][dateString]["attendances"] = GRA:RemoveElementsByKeys(_G[GRA_R_RaidLogs][dateString]["attendances"], {n})
        elseif t[1] == "PRESENT" then -- PRESENT
            _G[GRA_R_RaidLogs][dateString]["attendances"][n] = {GRA:IsLate(t[3], dateString..raidStartTime), t[2], t[3]}
        else -- ABSENT, ONLEAVE
            if t[2] then
                _G[GRA_R_RaidLogs][dateString]["attendances"][n] = {t[1], t[2]}
            else
                _G[GRA_R_RaidLogs][dateString]["attendances"][n] = {t[1]}
            end
        end

        rows[n].joinTimeEditBox:ClearFocus()
        rows[n].noteEditBox:ClearFocus()
        rows[n]:SetChanged(false)
    end

    wipe(changes)
    -- refresh date detail
    dateButton:Click()
    GRA:Print(L["Saved all attendance changes on %s."]:format(date("%x", GRA:DateToTime(dateString))))
    -- re-check attendances
    CheckAttendances(dateString)
    -- update attendance sheet & raid logs
    GRA:FireEvent("GRA_RAIDLOGS", dateString)
end

DiscardChanges = function()
    if GRA:Getn(changes) == 0 then return end
    for n, _ in pairs(changes) do
        rows[n]:SetRowInfo(attendances[n][1], attendances[n][2], attendances[n][3])
        rows[n].joinTimeEditBox:ClearFocus()
        rows[n].noteEditBox:ClearFocus()
        rows[n]:SetChanged(false)
    end

    wipe(changes)
    GRA:Print(L["Discarded all member changes on %s."]:format(date("%x", GRA:DateToTime(dateString))))
end

function GRA:ShowAttendanceEditor(d, b)
    dateButton = b
    dateString = d
    raidDateText:SetText("|cff80FF00" .. L["Raid Date: "] .. "|r" .. date("%x", GRA:DateToTime(d)))
    raidStartTime = GRA:GetRaidStartTime(d)
    raidStartTimeEditBox:SetText(raidStartTime)

    scroll:Reset()
    rows = {}

    -- check attendances from _G[GRA_R_RaidLogs][d]
    CheckAttendances(d)
    for n, t in pairs(attendances) do
        local row = GRA:CreateRow_AttendanceEditor(scroll.content, attendanceEditor:GetWidth(), n, t[1], t[2], t[3])
        scroll:SetWidgetAutoWidth(row)
        rows[n] = row
        row.name = n

        -- set attendance
        row.attendanceGrid:SetScript("OnDoubleClick", function()
            local items = {
                {
                    ["text"] = L["Present"],
                    ["color"] = "green",
                    ["onClick"] = function()
                        local joinTime = GRA:DateToTime(dateString..raidStartTime, true)
                        row:SetRowInfo("PRESENT", row.note, row.joinTime or joinTime)
                        CheckPlayerAttendance(row)
                    end
                },
                {
                    ["text"] = L["Absent"],
                    ["color"] = "red",
                    ["onClick"] = function()
                        row:SetRowInfo("ABSENT", row.note)
                        CheckPlayerAttendance(row)
                    end
                },
                {
                    ["text"] = L["On Leave"],
                    ["color"] = "magenta",
                    ["onClick"] = function()
                        row:SetRowInfo("ONLEAVE", row.note)
                        CheckPlayerAttendance(row)
                    end
                },
                {
                    ["text"] = L["Ignored"],
                    ["color"] = "yellow",
                    ["onClick"] = function()
                        row:SetRowInfo("IGNORED")
                        row.noteEditBox:SetEnabled(false)
                        CheckPlayerAttendance(row)
                    end
                },
            }
		    local selector = GRA:CreatePopupSelector(row.attendanceGrid, 60, items)
            -- selector:SetPoint("TOPLEFT", row.attendanceGrid, "BOTTOMLEFT", 0, -1)
            selector:SetPoint("TOPLEFT")
        end)
        
        -- load text
        row:SetRowInfo(row.attendance, row.note, row.joinTime)

        -- joinTime
        row.joinTimeEditBox:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            if row.attendance == "PRESENT" then
                local h, m = string.split(":", self:GetText())
                h, m = tonumber(h), tonumber(m)
                if h and m and h >= 0 and h <= 23 and m >= 0 and m <= 59 then
                    self:SetTextColor(1, 1, 1, 1)
                    local joinTime = string.format("%02d", h) .. ":" .. string.format("%02d", m)
                    -- convert to seconds, update joinTime
                    row.joinTime = GRA:DateToTime(dateString..joinTime, true)
                    CheckPlayerAttendance(row)
                    saveBtn:SetEnabled(true)
                else
                    row:SetChanged(true)
                    self:SetTextColor(1, .12, .12, 1)
                    saveBtn:SetEnabled(false)
                end
            end
        end)

        row.noteEditBox:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            row.note = self:GetText()
            CheckPlayerAttendance(row)
        end)
    end

    SortAttendanceEditor()
    attendanceEditor:Show()
end

attendanceEditor:SetScript("OnHide", function(self)
    self:Hide()
end)