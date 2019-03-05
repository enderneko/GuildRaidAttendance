local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local dateString, raidStartTime, raidEndTime
-- attendances: _G[GRA_R_RaidLogs] data
-- changes: changed data
-- rows: row buttons, used for highlighting and discarding changes
local attendances, changes, rows = {}, {}, {}

local attendanceEditor = CreateFrame("Frame", "GRA_AttendanceEditor", gra.mainFrame)
gra.attendanceEditor = attendanceEditor
attendanceEditor:Hide()

local tipText1 = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
tipText1:SetPoint("TOPLEFT", 5, -5)
tipText1:SetText("|cff70dd00" .. L["Double-click on the second column: "] .. gra.colors.grey.s .. L["Select attendance status."])
local tipText2 = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
tipText2:SetPoint("TOPLEFT", tipText1, "BOTTOMLEFT", 0, -3)
tipText2:SetText("|cff70dd00" .. L["Click on the last column: "] .. gra.colors.grey.s .. L["Set notes (not available for alts)."])

-- raid end time
local raidEndTimeEditBox = GRA:CreateEditBox(attendanceEditor, 70, 20, false, "GRA_FONT_SMALL")
raidEndTimeEditBox:SetJustifyH("CENTER")
raidEndTimeEditBox:SetPoint("TOPRIGHT", attendanceEditor, -5, -7)

local RETComfirmBtn = GRA:CreateButton(raidEndTimeEditBox, L["OK"], "blue", {20, 20}, "GRA_FONT_SMALL")
RETComfirmBtn:SetPoint("RIGHT", raidEndTimeEditBox)
RETComfirmBtn:Hide()
RETComfirmBtn:SetScript("OnClick", function()
	local h, m = string.split(":", raidEndTimeEditBox:GetText())
	raidEndTime = string.format("%02d", h) .. ":" .. string.format("%02d", m)

    if GRA:GetRaidStartTime(dateString) > raidEndTime then
        _G[GRA_R_RaidLogs][dateString]["endTime"] = GRA:DateToSeconds((dateString + 1) .. raidEndTime, true)
    else
        _G[GRA_R_RaidLogs][dateString]["endTime"] = GRA:DateToSeconds(dateString .. raidEndTime, true)
    end

    -- update attendance sheet column
    GRA:FireEvent("GRA_RH_UPDATE", dateString)

	raidEndTimeEditBox:SetText(raidEndTime)

	raidEndTimeEditBox:ClearFocus()
	RETComfirmBtn:Hide()
end)

raidEndTimeEditBox:SetScript("OnTextChanged", function(self, userInput)
	if not userInput then return end
	-- check time validity
	local h, m = string.split(":", raidEndTimeEditBox:GetText())
	h, m = tonumber(h), tonumber(m)
	if h and m and h >= 0 and h <= 23 and m >= 0 and m <= 59 then
		RETComfirmBtn:Show()
		GRA:StylizeFrame(raidEndTimeEditBox, {.1, .1, .1, .9})
	else
		RETComfirmBtn:Hide()
		GRA:StylizeFrame(raidEndTimeEditBox, {.1, .1, .1, .9}, {1, 0, 0, 1})
	end
end)

-- next OnShow, its data MUST be valid
raidEndTimeEditBox:SetScript("OnHide", function()
	RETComfirmBtn:Hide()
	GRA:StylizeFrame(raidEndTimeEditBox, {.1, .1, .1, .9})
end)

-- raid start time
local raidStartTimeEditBox = GRA:CreateEditBox(attendanceEditor, 70, 20, false, "GRA_FONT_SMALL")
raidStartTimeEditBox:SetJustifyH("CENTER")
raidStartTimeEditBox:SetPoint("RIGHT", raidEndTimeEditBox, "LEFT", -5, 0)

local RSTComfirmBtn = GRA:CreateButton(raidStartTimeEditBox, L["OK"], "blue", {20, 20}, "GRA_FONT_SMALL")
RSTComfirmBtn:SetPoint("RIGHT", raidStartTimeEditBox)
RSTComfirmBtn:Hide()
RSTComfirmBtn:SetScript("OnClick", function()
	local h, m = string.split(":", raidStartTimeEditBox:GetText())
	raidStartTime = string.format("%02d", h) .. ":" .. string.format("%02d", m)

	_G[GRA_R_RaidLogs][dateString]["startTime"] = GRA:DateToSeconds(dateString .. raidStartTime, true)
    -- update attendance sheet column
    GRA:FireEvent("GRA_RH_UPDATE", dateString)

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


local raidHours = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
raidHours:SetPoint("RIGHT", raidStartTimeEditBox, "LEFT", -3, 0)
raidHours:SetText(gra.colors.chartreuse.s .. L["Raid Hours"] .. ": ")

local scroll = GRA:CreateScrollFrame(attendanceEditor, -34, 0)
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
        table.insert(sorted, {n, att, row.isSitOut and 1 or 0, row.joinTime, row.leaveTime, _G[GRA_R_Roster][n]["class"]})
    end
    table.sort(sorted, function(a, b)
        if a[2] ~= b[2] then
            return a[2] < b[2]
        elseif a[3] ~= b[3] then
            return a[3] < b[3]
        elseif a[4] ~= b[4] then
            return a[4] < b[4]
        elseif a[4] ~= b[4] then
            return a[5] > b[5]
        elseif a[6] ~= b[6] then
            return GRA:GetIndex(gra.CLASS_ORDER, a[6]) < GRA:GetIndex(gra.CLASS_ORDER, b[6])
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
local saveBtn = GRA:CreateButton(attendanceEditor, L["Save All Changes"], "green", {115, 20})
attendanceEditor.saveBtn = saveBtn
saveBtn:SetScript("OnClick", function()
    SaveChanges()
    SortAttendanceEditor()
end)

local DiscardChanges
local discardBtn = GRA:CreateButton(attendanceEditor, L["Discard All Changes"], "red", {115, 20})
attendanceEditor.discardBtn = discardBtn
discardBtn:SetScript("OnClick", function()
    DiscardChanges()
end)

local function CheckAttendances(d)
    attendances = {}
    for n, _ in pairs(_G[GRA_R_Roster]) do
        if _G[GRA_R_RaidLogs][d]["attendances"][n] then -- present/absent/partial/onleave
            if _G[GRA_R_RaidLogs][d]["attendances"][n][3] then -- present/partial -> present
                local isSitOut
                if _G[GRA_R_RaidLogs][d]["attendances"][n][5] then isSitOut = true else isSitOut = false end
                attendances[n] = {"PRESENT", _G[GRA_R_RaidLogs][d]["attendances"][n][2], _G[GRA_R_RaidLogs][d]["attendances"][n][3], _G[GRA_R_RaidLogs][d]["attendances"][n][4] or select(2, GRA:GetRaidEndTime(d)), isSitOut}
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
    if row.attendance ~= attendances[name][1] or row.note ~= attendances[name][2] or row.joinTime ~= attendances[name][3] or row.leaveTime ~= attendances[name][4] or row.isSitOut ~= attendances[name][5] then 
        if not changes[name] then changes[name] = {} end
        changes[name][1] = row.attendance
        changes[name][2] = row.note
        changes[name][3] = row.joinTime
        changes[name][4] = row.leaveTime
        changes[name][5] = row.isSitOut
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
            if t[5] then
                _G[GRA_R_RaidLogs][dateString]["attendances"][n] = {GRA:CheckAttendanceStatus(t[3], select(2, GRA:GetRaidStartTime(dateString)), t[4], select(2, GRA:GetRaidEndTime(dateString))), t[2], t[3], t[4], true}
            else
                _G[GRA_R_RaidLogs][dateString]["attendances"][n] = {GRA:CheckAttendanceStatus(t[3], select(2, GRA:GetRaidStartTime(dateString)), t[4], select(2, GRA:GetRaidEndTime(dateString))), t[2], t[3], t[4]}
            end
        else -- ABSENT, ONLEAVE
            if t[2] then
                _G[GRA_R_RaidLogs][dateString]["attendances"][n] = {t[1], t[2]}
            else
                _G[GRA_R_RaidLogs][dateString]["attendances"][n] = {t[1]}
            end
        end

        rows[n].joinTimeEditBox:ClearFocus()
        rows[n].leaveTimeEditBox:ClearFocus()
        rows[n].noteEditBox:ClearFocus()
        rows[n]:SetChanged(false)
    end

    wipe(changes)
    GRA:Print(L["Saved all attendance changes on %s."]:format(date("%x", GRA:DateToSeconds(dateString))))
    -- re-check attendances
    CheckAttendances(dateString)
    -- update attendance sheet & raid logs
    GRA:FireEvent("GRA_RAIDLOGS", dateString)
end

DiscardChanges = function()
    if GRA:Getn(changes) == 0 then return end
    for n, _ in pairs(changes) do
        rows[n]:SetRowInfo(attendances[n][1], attendances[n][2], attendances[n][3], attendances[n][4], attendances[n][5])
        rows[n].joinTimeEditBox:ClearFocus()
        rows[n].leaveTimeEditBox:ClearFocus()
        rows[n].noteEditBox:ClearFocus()
        rows[n]:SetChanged(false)
    end

    wipe(changes)
    GRA:Print(L["Discarded all attendance changes on %s."]:format(date("%x", GRA:DateToSeconds(dateString))))
end

function GRA:ShowAttendanceEditor(d)
    dateString = d
    raidStartTime, raidStartSeconds = GRA:GetRaidStartTime(d)
    raidEndTime, raidEndSeconds = GRA:GetRaidEndTime(d)
    raidStartTimeEditBox:SetText(raidStartTime)
    raidEndTimeEditBox:SetText(raidEndTime)

    scroll:Reset()
    rows = {}

    -- check attendances from _G[GRA_R_RaidLogs][d]
    CheckAttendances(d)
    for n, t in pairs(attendances) do
        local row = GRA:CreateRow_AttendanceEditor(scroll.content, attendanceEditor:GetWidth(), n, t[1], t[2], t[3], t[4], t[5])
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
                        row:SetRowInfo("PRESENT", row.note, row.joinTime or raidStartSeconds, row.leaveTime or raidEndSeconds, false)
                        CheckPlayerAttendance(row)
                    end
                },
                {
                    ["text"] = L["Sit Out"],
                    ["color"] = "blue",
                    ["onClick"] = function()
                        row:SetRowInfo("PRESENT", row.note, row.joinTime or raidStartSeconds, row.leaveTime or raidEndSeconds, true)
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
                        CheckPlayerAttendance(row)
                    end
                },
            }
		    local selector = GRA:CreatePopupSelector(row.attendanceGrid, 60, items)
            selector:SetPoint("TOPLEFT")
        end)
        
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
                    row.joinTime = GRA:DateToSeconds(dateString..joinTime, true)
                    saveBtn:SetEnabled(true)
                else
                    self:SetTextColor(1, .12, .12, 1)
                    row.joinTime = nil
                    saveBtn:SetEnabled(false)
                end
                CheckPlayerAttendance(row)
            end
        end)

        -- leaveTime
        row.leaveTimeEditBox:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            if row.attendance == "PRESENT" then
                local h, m = string.split(":", self:GetText())
                h, m = tonumber(h), tonumber(m)
                if h and m and h >= 0 and h <= 23 and m >= 0 and m <= 59 then
                    self:SetTextColor(1, 1, 1, 1)
                    local leaveTime = string.format("%02d", h) .. ":" .. string.format("%02d", m)
                    local joinTime = GRA:SecondsToTime(row.joinTime)
                    -- convert to seconds, update leaveTime
                    if joinTime > leaveTime then
                        row.leaveTime = GRA:DateToSeconds((dateString+1)..leaveTime, true)
                    else
                        row.leaveTime = GRA:DateToSeconds(dateString..leaveTime, true)
                    end
                    saveBtn:SetEnabled(true)
                else
                    self:SetTextColor(1, .12, .12, 1)
                    row.leaveTime = nil
                    saveBtn:SetEnabled(false)
                end
                CheckPlayerAttendance(row)
            end
        end)

        row.noteEditBox:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            row.note = self:GetText()
            if row.note == "" then row.note = nil end
            CheckPlayerAttendance(row)
        end)
    end

    SortAttendanceEditor()
    attendanceEditor:Show()
end

GRA:RegisterEvent("GRA_RH_UPDATE", "AttendanceEditor_RaidHoursUpdate", function(d)
    if not attendanceEditor:IsShown() then return end
    -- Global RH changed, refresh editor
    GRA:ShowAttendanceEditor(dateString)
end)