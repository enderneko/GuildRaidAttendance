local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local memberAttendanceFrame = GRA:CreateMovableFrame(L["Attendance"], "GRA_MemberAttendanceFrame", 400, 381, "GRA_FONT_NORMAL", "HIGH")
gra.memberAttendanceFrame = memberAttendanceFrame
memberAttendanceFrame:SetToplevel(true)

GRA:CreateScrollFrame(memberAttendanceFrame)
memberAttendanceFrame.scrollFrame:SetScrollStep(19)

local function LoadMemberAttendance(name)
    local dates, bars = {}, {}
    for d, l in pairs(_G[GRA_R_RaidLogs]) do
        local att, jt, lt, ar, isSitOut, loots = GRA:GetMainAltAttendance(d, name)
        if att then -- not ignored
            table.insert(dates, d)
            local st = select(2, GRA:GetRaidStartTime(d))
            local et = select(2, GRA:GetRaidEndTime(d))
            -- frame, width, raidDate, attendance, attendanceRate, joinTime, leaveTime, startTime, endTime
            bars[d] = GRA:CreateAttendanceBar(memberAttendanceFrame.scrollFrame.content, memberAttendanceFrame.scrollFrame:GetWidth(), d, att, ar, jt, lt, st, et, isSitOut, l["attendances"][name] and l["attendances"][name][2])
            memberAttendanceFrame.scrollFrame:SetWidgetAutoWidth(bars[d])
        end
    end

    -- sort
    table.sort(dates)
    
    -- set point
    local last
    for i, d in ipairs(dates) do
        if i == 1 then
            bars[d]:SetPoint("TOP")
        else
            bars[d]:SetPoint("TOP", last, "BOTTOM", 0, 1)
        end
        last = bars[d]
    end
end

function GRA:ShowMemberAttendance(name)
    GRA:Print("|cffE066FFShowMemberAttendance:|r " .. name)
    memberAttendanceFrame.scrollFrame:Reset()
    -- set to main
    if GRA:IsAlt(name) then name = GRA:IsAlt(n) end
    LoadMemberAttendance(name)
    memberAttendanceFrame.header.text:SetText(L["Attendance"] .. ": " .. GRA:GetClassColoredName(name))
    memberAttendanceFrame:Show()
end

memberAttendanceFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(memberAttendanceFrame)
end)

memberAttendanceFrame:SetScript("OnHide", function()

end)