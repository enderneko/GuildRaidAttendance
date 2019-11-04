local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

function GRA:CreateAttendanceEditor(parent)
    -- create editor
    local attendanceEditor = CreateFrame("Frame", parent:GetName() .. "_AttendanceEditor", parent)
    parent.attendanceEditor = attendanceEditor
    attendanceEditor:Hide()
    
    -- init
    -- attendances: _G[GRA_R_RaidLogs] data
    -- changes: changed data
    -- rows: row buttons, used for highlighting and discarding changes
    attendanceEditor.attendances, attendanceEditor.changes, attendanceEditor.rows = {}, {}, {}
    -- attendanceEditor.dateString
    
    local tipText1 = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
    tipText1:SetPoint("TOPLEFT", 5, -8)
    tipText1:SetText("|cff70dd00" .. L["Double-click on the second column: "] .. gra.colors.grey.s .. L["Select attendance status."])
    local tipText2 = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
    tipText2:SetPoint("TOPLEFT", tipText1, "BOTTOMLEFT", 0, -3)
    tipText2:SetText("|cff70dd00" .. L["Click on the last column: "] .. gra.colors.grey.s .. L["Set notes (not available for alts)."])

    -- raid end time
    local raidStartTimeEditBox, raidEndTimeEditBox, rstConfirmBtn, retConfirmBtn = GRA:CreateRaidHoursEditBox(attendanceEditor,
    function(startTime)
        _G[GRA_R_RaidLogs][attendanceEditor.dateString]["startTime"] = GRA:DateToSeconds(attendanceEditor.dateString .. startTime, true)
        -- update attendance sheet column
        GRA:FireEvent("GRA_RH_UPDATE", attendanceEditor.dateString)
    end, function(endTime)
        if GRA:GetRaidStartTime(attendanceEditor.dateString) > endTime then
            _G[GRA_R_RaidLogs][attendanceEditor.dateString]["endTime"] = GRA:DateToSeconds((attendanceEditor.dateString + 1) .. endTime, true)
        else
            _G[GRA_R_RaidLogs][attendanceEditor.dateString]["endTime"] = GRA:DateToSeconds(attendanceEditor.dateString .. endTime, true)
        end
    
        -- update attendance sheet column
        GRA:FireEvent("GRA_RH_UPDATE", attendanceEditor.dateString)
    end)

    attendanceEditor.raidStartTimeEditBox = raidStartTimeEditBox
    attendanceEditor.raidEndTimeEditBox = raidEndTimeEditBox
    
    raidEndTimeEditBox:SetWidth(70)
    raidEndTimeEditBox:SetPoint("TOPRIGHT", attendanceEditor, -5, -11)
    retConfirmBtn:ClearAllPoints()
    retConfirmBtn:SetPoint("RIGHT")
    
    -- raid start time
    raidStartTimeEditBox:SetWidth(70)
    raidStartTimeEditBox:SetPoint("RIGHT", raidEndTimeEditBox, "LEFT", -5, 0)
    rstConfirmBtn:ClearAllPoints()
    rstConfirmBtn:SetPoint("RIGHT")
    
    local raidHours = attendanceEditor:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
    raidHours:SetPoint("RIGHT", raidStartTimeEditBox, "LEFT", -3, 0)
    raidHours:SetText(gra.colors.chartreuse.s .. L["Raid Hours"] .. ": ")
    
    local scroll = GRA:CreateScrollFrame(attendanceEditor, -41)
    GRA:StylizeFrame(scroll, {0, 0, 0, 0})
    scroll:SetScrollStep(19)

    attendanceEditor.saveBtn = GRA:CreateButton(attendanceEditor, L["Save All Changes"], "green", {115, 20})
    attendanceEditor.saveBtn:SetScript("OnClick", function()
        attendanceEditor:SaveChanges()
        attendanceEditor:Sort()
    end)

    attendanceEditor.discardBtn = GRA:CreateButton(attendanceEditor, L["Discard All Changes"], "red", {115, 20})
    attendanceEditor.discardBtn:SetScript("OnClick", function()
        attendanceEditor:DiscardChanges()
    end)

    -- functions
    function attendanceEditor:CheckAttendances()
        wipe(attendanceEditor.attendances)
        local d = attendanceEditor.dateString

        for n, _ in pairs(_G[GRA_R_Roster]) do
            if _G[GRA_R_RaidLogs][d]["attendances"][n] then -- present/absent/partial/onleave
                if _G[GRA_R_RaidLogs][d]["attendances"][n][3] then -- present/partial -> present
                    local isSitOut
                    if _G[GRA_R_RaidLogs][d]["attendances"][n][5] then isSitOut = true else isSitOut = false end
                    attendanceEditor.attendances[n] = {"PRESENT", _G[GRA_R_RaidLogs][d]["attendances"][n][2], _G[GRA_R_RaidLogs][d]["attendances"][n][3], _G[GRA_R_RaidLogs][d]["attendances"][n][4] or select(2, GRA:GetRaidEndTime(d)), isSitOut}
                else -- absent/onleave
                    attendanceEditor.attendances[n] = {_G[GRA_R_RaidLogs][d]["attendances"][n][1], _G[GRA_R_RaidLogs][d]["attendances"][n][2]}
                end
            else -- ignored
                attendanceEditor.attendances[n] = {"IGNORED"}
            end
        end
    end

    -- check and save to changes(table)
    function attendanceEditor:CheckChanges(row)
        local changed = false
        local name = row.name
        -- attendance/note/joinTime changed
        if row.attendance ~= attendanceEditor.attendances[name][1] or row.note ~= attendanceEditor.attendances[name][2] or row.joinTime ~= attendanceEditor.attendances[name][3] or row.leaveTime ~= attendanceEditor.attendances[name][4] or row.isSitOut ~= attendanceEditor.attendances[name][5] then 
            if not attendanceEditor.changes[name] then attendanceEditor.changes[name] = {} end
            attendanceEditor.changes[name][1] = row.attendance
            attendanceEditor.changes[name][2] = row.note
            attendanceEditor.changes[name][3] = row.joinTime
            attendanceEditor.changes[name][4] = row.leaveTime
            attendanceEditor.changes[name][5] = row.isSitOut
            changed = true
        else
            attendanceEditor.changes = GRA:RemoveElementsByKeys(attendanceEditor.changes, {name})
            changed = false
        end

        row:SetChanged(changed)
        -- texplore(attendanceEditor.changes)
    end

    -- sort & set point
    function attendanceEditor:Sort()
        local sorted ={}
        for n, row in pairs(attendanceEditor.rows) do
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
                attendanceEditor.rows[t[1]]:SetPoint("TOP", last, "BOTTOM", 0, 1)
            else
                attendanceEditor.rows[t[1]]:SetPoint("TOP")
            end
            last = attendanceEditor.rows[t[1]]
        end
        wipe(sorted)
    end

    function attendanceEditor:SaveChanges()
        if GRA:Getn(attendanceEditor.changes) == 0 then return end
        local d = attendanceEditor.dateString

        for n, t in pairs(attendanceEditor.changes) do
            if t[1] == "IGNORED" then -- delete
                _G[GRA_R_RaidLogs][d]["attendances"] = GRA:RemoveElementsByKeys(_G[GRA_R_RaidLogs][d]["attendances"], {n})
            elseif t[1] == "PRESENT" then -- PRESENT
                if t[5] then
                    _G[GRA_R_RaidLogs][d]["attendances"][n] = {GRA:CheckAttendanceStatus(t[3], select(2, GRA:GetRaidStartTime(d)), t[4], select(2, GRA:GetRaidEndTime(d))), t[2], t[3], t[4], true}
                else
                    _G[GRA_R_RaidLogs][d]["attendances"][n] = {GRA:CheckAttendanceStatus(t[3], select(2, GRA:GetRaidStartTime(d)), t[4], select(2, GRA:GetRaidEndTime(d))), t[2], t[3], t[4]}
                end
            else -- ABSENT, ONLEAVE
                if t[2] then
                    _G[GRA_R_RaidLogs][d]["attendances"][n] = {t[1], t[2]}
                else
                    _G[GRA_R_RaidLogs][d]["attendances"][n] = {t[1]}
                end
            end
    
            attendanceEditor.rows[n].joinTimeEditBox:ClearFocus()
            attendanceEditor.rows[n].leaveTimeEditBox:ClearFocus()
            attendanceEditor.rows[n].noteEditBox:ClearFocus()
            attendanceEditor.rows[n]:SetChanged(false)
        end
    
        wipe(attendanceEditor.changes)
        GRA:Print(L["Saved all attendance changes on %s."]:format(date("%x", GRA:DateToSeconds(d))))
        -- re-check attendances
        attendanceEditor:CheckAttendances()
        -- update attendance sheet & raid logs
        GRA:FireEvent("GRA_RAIDLOGS", d)
    end
    
    function attendanceEditor:DiscardChanges()
        if GRA:Getn(attendanceEditor.changes) == 0 then return end
        for n, _ in pairs(attendanceEditor.changes) do
            attendanceEditor.rows[n]:SetRowInfo(attendanceEditor.attendances[n][1], attendanceEditor.attendances[n][2], attendanceEditor.attendances[n][3], attendanceEditor.attendances[n][4], attendanceEditor.attendances[n][5])
            attendanceEditor.rows[n].joinTimeEditBox:ClearFocus()
            attendanceEditor.rows[n].leaveTimeEditBox:ClearFocus()
            attendanceEditor.rows[n].noteEditBox:ClearFocus()
            attendanceEditor.rows[n]:SetChanged(false)
        end
    
        wipe(attendanceEditor.changes)
        GRA:Print(L["Discarded all attendance changes on %s."]:format(date("%x", GRA:DateToSeconds(attendanceEditor.dateString))))
    end

    return attendanceEditor
end

function GRA:ShowAttendanceEditor(parent, d, readOnly) -- TODO: readOnly
    if not parent.attendanceEditor then GRA:CreateAttendanceEditor(parent) end
    parent.attendanceEditor.dateString = d

    local raidStartTime, raidStartSeconds = GRA:GetRaidStartTime(d)
    local raidEndTime, raidEndSeconds = GRA:GetRaidEndTime(d)
    parent.attendanceEditor.raidStartTimeEditBox:SetText(raidStartTime)
    parent.attendanceEditor.raidEndTimeEditBox:SetText(raidEndTime)

    parent.attendanceEditor.scrollFrame:Reset()
    wipe(parent.attendanceEditor.rows)

    -- check attendances from _G[GRA_R_RaidLogs][d]
    parent.attendanceEditor:CheckAttendances()
    for n, t in pairs(parent.attendanceEditor.attendances) do
        local row = GRA:CreateRow_AttendanceEditor(parent.attendanceEditor.scrollFrame.content, parent.attendanceEditor:GetWidth(), n, t[1], t[2], t[3], t[4], t[5])
        parent.attendanceEditor.scrollFrame:SetWidgetAutoWidth(row)
        parent.attendanceEditor.rows[n] = row
        row.name = n

        -- set attendance
        row.attendanceGrid:SetScript("OnDoubleClick", function()
            local items = {
                {
                    ["text"] = L["Present"],
                    ["color"] = "green",
                    ["onClick"] = function()
                        row:SetRowInfo("PRESENT", row.note, row.joinTime or raidStartSeconds, row.leaveTime or raidEndSeconds, false)
                        parent.attendanceEditor:CheckChanges(row)
                    end
                },
                {
                    ["text"] = L["Sit Out"],
                    ["color"] = "blue",
                    ["onClick"] = function()
                        row:SetRowInfo("PRESENT", row.note, row.joinTime or raidStartSeconds, row.leaveTime or raidEndSeconds, true)
                        parent.attendanceEditor:CheckChanges(row)
                    end
                },
                {
                    ["text"] = L["Absent"],
                    ["color"] = "red",
                    ["onClick"] = function()
                        row:SetRowInfo("ABSENT", row.note)
                        parent.attendanceEditor:CheckChanges(row)
                    end
                },
                {
                    ["text"] = L["On Leave"],
                    ["color"] = "magenta",
                    ["onClick"] = function()
                        row:SetRowInfo("ONLEAVE", row.note)
                        parent.attendanceEditor:CheckChanges(row)
                    end
                },
                {
                    ["text"] = L["Ignored"],
                    ["color"] = "yellow",
                    ["onClick"] = function()
                        row:SetRowInfo("IGNORED")
                        parent.attendanceEditor:CheckChanges(row)
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
                    row.joinTime = GRA:DateToSeconds(parent.attendanceEditor.dateString..joinTime, true)
                    parent.attendanceEditor.saveBtn:SetEnabled(true)
                else
                    self:SetTextColor(1, .12, .12, 1)
                    row.joinTime = nil
                    parent.attendanceEditor.saveBtn:SetEnabled(false)
                end
                parent.attendanceEditor:CheckChanges(row)
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
                        row.leaveTime = GRA:DateToSeconds((parent.attendanceEditor.dateString+1)..leaveTime, true)
                    else
                        row.leaveTime = GRA:DateToSeconds(parent.attendanceEditor.dateString..leaveTime, true)
                    end
                    parent.attendanceEditor.saveBtn:SetEnabled(true)
                else
                    self:SetTextColor(1, .12, .12, 1)
                    row.leaveTime = nil
                    parent.attendanceEditor.saveBtn:SetEnabled(false)
                end
                parent.attendanceEditor:CheckChanges(row)
            end
        end)

        row.noteEditBox:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            row.note = self:GetText()
            if row.note == "" then row.note = nil end
            parent.attendanceEditor:CheckChanges(row)
        end)
    end

    parent.attendanceEditor:Sort()
    parent.attendanceEditor:Show()
end