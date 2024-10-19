---@class GRA
local GRA = select(2, ...)
local L = GRA.L
---@class Funcs
local F = GRA.funcs

-- #GRA.admin1,admin2
-- permission control
function F.IsAdmin()
    local info = GetGuildInfoText()
    if info == "" then
        -- GRA.Debug("|cff87CEEBF.IsAdmin: |rfailed")
        return nil
    end
    local lines = {strsplit("\n", info)}
    for _, line in pairs(lines) do
        if (string.find(line, "^#GRA:")) then
            GRA.Debug("|cff87CEEBF.IsAdmin: |r" .. line)
            -- multi-admin
            GRA.vars.admins = F.ConvertTable({strsplit(",", string.sub(line, 6))}, true)
            if GRA.vars.admins[UnitName("player")] then
                -- if string.sub(line, 6) == UnitName("player") then
                GRA.vars.isAdmin = true
                GRA.Fire("GRA_PERMISSION", true)
                return true
            else
                GRA.vars.isAdmin = false
                GRA.Fire("GRA_PERMISSION", false)
                return false
            end
        end
    end
    GRA.vars.admins = {}
    GRA.vars.isAdmin = false
    GRA.Fire("GRA_PERMISSION", nil) -- nil , no admin
    return false
end

local trial, count = nil, 0
--? update with CLUB_UPDATED
function F.CheckPermissions()
    -- permission control
    if F.IsAdmin() == nil then -- check failed
        securecall(C_GuildInfo.GuildRoster)
        if not trial then -- check 5 more times
            trial = C_Timer.NewTicker(2, function()
                count = count + 1
                GRA.Debug("|cff87CEEBF.CheckPermissions():|r " .. count)
                F.CheckPermissions() -- try again
            end, 5)
        end
    else
        if trial then
            trial:Cancel()
            count = 0
            trial = nil
            GRA.Debug("|cff87CEEBF.CheckPermissions()|r: cancelled with success")
        end
    end
end

---------------------------------------------------------------------
-- General
---------------------------------------------------------------------
function F.RGBtoHEX(r, g, b)
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function F.Round(n)
    if n < 0 then
        return math.ceil(n)
    elseif math.ceil(n) == n then -- is integer
        return n
    else
        return math.ceil(n)-1
    end
end

function F.Calc(ex)
    --[[
        Calc
        Simple inline calculator

        Version: v1.2.0.8
        Date:    2016-08-01T20:09:59Z
        Author:  lenwe-saralonde
    ]]
    local func, errorMessage = loadstring('return ' .. ex, ex);

    if (not func) then
        return false, errorMessage
    end

    local status, result = pcall(func);

    return status, result
end

function F.HexToRGB(color, a)
    local r = tonumber("0x" .. string.sub(color, 1, 2))/255
    local g = tonumber("0x" .. string.sub(color, 3, 4))/255
    local b = tonumber("0x" .. string.sub(color, 5, 6))/255

    if a then
        return r, g, b, a
    else
        return r, g, b
    end
end

function F.RGBToHex(r, g, b)
    r = string.format("%x", r * 255)
    g = string.format("%x", g * 255)
    b = string.format("%x", b * 255)
    return r .. g .. b
end


---------------------------------------------------------------------
-- Table
---------------------------------------------------------------------
function F.TContains(t, v)
    for _, value in pairs(t) do
        if value == v then return true end
    end
    return false
end

function F.TContainsKey(t, k)
    if t[k] ~= nil then
        return true
    end
    return false
end

function F.Getn(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function F.GetIndex(t, e)
    for i = 1, #t do
        if e == t[i] then
            return i
        end
    end
    return nil
end

function F.Copy(t)
    local newTbl = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            newTbl[k] = F.Copy(v)
        else
            newTbl[k] = v
        end
    end
    return newTbl
end

function F.ConvertTable(t, value)
    local temp = {}
    for k, v in ipairs(t) do
        temp[v] = value or k
    end
    return temp
end

-- function F.Copy(from, to)
-- 	for k, v in pairs(from) do
--         if type(v) == "table" then
--             to[k] = {}
--             F.Copy(v, to[k])
--         else
--             to[k] = v
--         end
-- 	end
-- end

function F.Remove(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then
            table.remove(t, i)
        end
    end
end

function F.RemoveElementsByKeys(tbl, ...)
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        tbl[k] = nil
    end
end

function F.IsEmpty(t)
    if not t or type(t) ~= "table" then
        return true
    end

    if next(t) then
        return false
    end
    return true
end

function F.Sort(t, k1, order1, k2, order2, k3, order3)
    table.sort(t, function(a, b)
        if a[k1] ~= b[k1] then
            if order1 == "ascending" then
                return a[k1] < b[k1]
            else -- "descending"
                return a[k1] > b[k1]
            end
        elseif k2 and order2 and a[k2] ~= b[k2] then
            if order2 == "ascending" then
                return a[k2] < b[k2]
            else -- "descending"
                return a[k2] > b[k2]
            end
        elseif k3 and order3 and a[k3] ~= b[k3] then
            if order3 == "ascending" then
                return a[k3] < b[k3]
            else -- "descending"
                return a[k3] > b[k3]
            end
        end
    end)
    return t
end

function F.TableToString(tbl, sep, noEndDot)
    -- if string then return it
    if type(tbl) == "string" then return tbl end
    if type(tbl) ~= "table" or #tbl == 0 then return "" end

    if not sep then sep = ", " end

    s = tbl[1]
    for i = 2, #tbl do
        s = s .. sep .. tbl[i]
    end
    if not noEndDot then s = s .. "." end
    return s
end

---------------------------------------------------------------------
-- GRA Data
---------------------------------------------------------------------
function F.GetPlayers()
    local players = {}
    for pName, pTable in pairs(GRA_Roster) do
        table.insert(players, pName)
    end
    return players
end

function F.GetGuildRoster(rank)
    local roster = {}
    SetGuildRosterShowOffline(true)
    -- two-key sort CANNOT revers sort!!!
    --SortGuildRoster("name")
    SortGuildRoster("rank")

    -- check sort
    local fullName, _, rankIndex, _, _, _, _, _, _, _, class = GetGuildRosterInfo(1)
    if rankIndex ~= 0 then
        SortGuildRoster("rank")
    end

    local n = GetNumGuildMembers()
    for i = 1, n do
        local fullName, _, rankIndex, _, _, _, _, _, _, _, class = GetGuildRosterInfo(i)
        if rankIndex <= rank - 1 then
            table.insert(roster, {["name"] = fullName, ["class"] = class, ["rankIndex"] = rankIndex})
        else
            break
            -- sort and return
            -- F.Sort(roster, "rankIndex", "ascending", "name", "ascending")
            -- return roster
        end
    end
    return roster
end

function F.GetGuildOnlineRoster()
    local roster = {}
    for i = 1, GetNumGuildMembers() do
        local fullName, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
        if isOnline then
            roster[fullName] = true
        end
    end
    return roster
end

function F.GetShortName(fullName)
    local shortName = strsplit("-", fullName)
    return shortName
end

function F.GetClassColoredName(fullName, class)
    if not fullName then return "" end
    local name = F.GetShortName(fullName)

    if not class then
        if not GRA_Roster[fullName] then -- grey (deleted players)
            return "|cff909090" .. name .. "|r"
        end
        class = GRA_Roster[fullName]["class"]
    end

    if not RAID_CLASS_COLORS[class] then -- wrong class
        return "|cff909090" .. name .. "|r"
    else
        return "|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. "|r"
    end
end

function F.GetRealmName()
    return string.gsub(GetRealmName(), " ", "")
end

function F.GetPlayersInRaid()
    if IsInRaid() then
        local raidInfo = {}
        for i = 1, 40 do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
            if name then
                if not raidInfo[subgroup] then raidInfo[subgroup] = {} end
                if not string.find(name, "-") then name = name .. "-" .. F.GetRealmName() end
                table.insert(raidInfo[subgroup], name)
             end
        end
        return raidInfo
    end
end

function F.GetDifficultyInfo(difficultyID)
    if difficultyID == 14  or difficultyID == 3 or difficultyID == 4 then
        return "N"
    elseif difficultyID == 15 or difficultyID == 5 or difficultyID == 6 then
        return "H"
    elseif difficultyID == 16 then
        return "M"
    elseif difficultyID == 17 or difficultyID == 7 then
        return "LFR"
    else
        return "?"
    end
end

local localizedClass = LocalizedClassList()
function F.GetLocalizedClassName(class)
    return localizedClass[class]
end

GRA.vars.mainAlt = {}
function F.UpdateMainAlt()
    wipe(GRA.vars.mainAlt)
    for n, t in pairs(GRA_Roster) do
        if t["altOf"] then
            if not GRA.vars.mainAlt[t["altOf"]] then GRA.vars.mainAlt[t["altOf"]] = {} end
            table.insert(GRA.vars.mainAlt[t["altOf"]], n)
        end
    end
end

function F.IsAlt(n)
    if GRA_Roster[n] and GRA_Roster[n]["altOf"] then
        return GRA_Roster[n]["altOf"]
    end
end

function F.GetAttendeesAndAbsentees(logTable, filterMainAlt)
    local attendees, absentees = {}, {}
    for n, t in pairs(logTable["attendances"]) do
        if t[3] then
            table.insert(attendees, n)
        else -- ABSENT or ONLEAVE
            table.insert(absentees, n)
        end
    end

    if filterMainAlt then
        -- process main-alt
        for i = #attendees, 1, -1 do
            local n = attendees[i]
            if GRA_Roster[n] and GRA_Roster[n]["altOf"] then
                if F.GetIndex(attendees, GRA_Roster[n]["altOf"]) then
                    -- main already exists in attendees, remove it
                    table.remove(attendees, i)
                else
                    -- convert to main!
                    attendees[i] = GRA_Roster[n]["altOf"]
                end
            end
        end

        for i = #absentees, 1, -1 do
            local n = absentees[i]
            if GRA_Roster[n] and GRA_Roster[n]["altOf"] then -- is alt
                if F.TContains(absentees, GRA_Roster[n]["altOf"]) then
                    -- main already exists in absentees, remove it
                    table.remove(absentees, i)
                else
                    if F.TContains(attendees, GRA_Roster[n]["altOf"]) then
                        -- main exists in attendees, remove it from absentees
                        table.remove(absentees, i)
                    else
                        -- convert to main!
                        absentees[i] = GRA_Roster[n]["altOf"]
                    end
                end
            else -- is main
                if F.TContains(attendees, n) then
                    -- main exists in attendees, remove it from absentees
                    table.remove(absentees, i)
                end
            end
        end
    end

    return attendees, absentees
end

---------------------------------------------------------------------
-- Date & Time
---------------------------------------------------------------------
local monthNames = CALENDAR_FULLDATE_MONTH_NAMES
function F.GetMonthNames(isShort)
    if GRA_FORCE_ENGLISH then
        monthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    end
    if isShort and (GRA_FORCE_ENGLISH or not(GetLocale() == "zhCN" or GetLocale() == "zhTW")) then
        for i,n in pairs(monthNames) do
            monthNames[i] = string.sub(n, 1, 3)
        end
    end
    return monthNames
end

local weekdayNames = CALENDAR_WEEKDAY_NAMES
function F.GetWeekdayNames(isShort, forceEnglish)
    if forceEnglish then
        weekdayNames = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
    end
    if isShort and (forceEnglish or not(GetLocale() == "zhCN" or GetLocale() == "zhTW")) then
        for i,n in pairs(weekdayNames) do
            weekdayNames[i] = string.sub(n, 1, 3)
        end
    end
    return weekdayNames
end

-- d: date string/number, "20170321" or 20170321
function F.DateToWeekday(d, forceEnglish)
    local year = string.sub(d, 1, 4)
    local month = string.sub(d, 5, 6)
    local day = string.sub(d, 7, 8)

    local sec = time({["day"]=day, ["month"]=month, ["year"]=year})
    local t = date("*t", sec)
    local wdNames = F.GetWeekdayNames(true, forceEnglish or GRA_FORCE_ENGLISH)

    return wdNames[t.wday], t.wday
end

-- http://lua-users.org/wiki/DayOfWeekAndDaysInMonthExample
local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

local function isLeapYear(year)
    return year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0)
end

-- return numDays, firstWeekday
function F.GetAbsMonthInfo(month, year)
    local numDays, firstWeekday
    if month == 2 and isLeapYear(year) then
        numDays = 29
    else
        numDays = days_in_month[month]
    end
    firstWeekday = date("%w", time({["day"]=1, ["month"]=month, ["year"]=year})) + 1
    return numDays, firstWeekday
end

-- date header for GRA Attendance Sheet
function F.FormatDateHeader(d)
    -- weekdayNames = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    local year = string.sub(d, 1, 4)
    local month = string.sub(d, 5, 6)
    local day = string.sub(d, 7, 8)

    local sec = time({["day"]=day, ["month"]=month, ["year"]=year})
    return L[date("%a", sec)] .. "\n" .. tonumber(day)
    -- local weekday = F.DateToWeekday(d)
    -- return weekday .. "\n" .. tonumber(day)
end

-- get current time, "20170305", "23:33"
function F.Date()
    local sec = time()
    -- local t = date("*t", sec)
    -- local year, month, day =  date("%Y", sec), date("%m", sec), date("%d", sec)
    -- local hour, minute = date("%H", sec), date("%M", sec)
    -- return year..month..day, hour..":"..minute
    return date("%Y%m%d", sec), date("%H:%M", sec)
end

-- get lockout reset day of this "week", init GRA_Config["startDate"]
function F.GetLockoutsResetDate()
    local t = F.Date()
    local wday = select(2, F.DateToWeekday(t))
    local offset = 0
    -- backward search
    if wday > GRA.vars.RAID_LOCKOUTS_RESET  then -- forward
        offset = GRA.vars.RAID_LOCKOUTS_RESET - wday
    elseif wday < GRA.vars.RAID_LOCKOUTS_RESET then -- backward
        offset = GRA.vars.RAID_LOCKOUTS_RESET - wday - 7
    end
    return F.NextDate(t, offset)
end

-- next valid date string, offset = 1 by default, "20170331"->"20170401"
function F.NextDate(d, offset)
    if not offset then offset = 1 end
    local year = string.sub(d, 1, 4)
    local month = string.sub(d, 5, 6)
    local day = string.sub(d, 7, 8) + offset
    local sec = time({["year"]=year, ["month"]=month, ["day"]=day})
    return date("%Y%m%d", sec)
end

function F.DateOffset(d1, d2)
    local t1, t2 = F.DateToSeconds(d1), F.DateToSeconds(d2)
    local offset = abs(t1 - t2) / (3600 * 24)
    return offset
end

-- 2017033112:30
function F.DateToSeconds(s, hasTime)
    local y = tonumber(string.sub(s, 1, 4))
    local M = tonumber(string.sub(s, 5, 6))
    local d = tonumber(string.sub(s, 7, 8))
    local h, m = 0, 0
    if hasTime then
        h = tonumber(string.sub(s, 9, 10))
        m = tonumber(string.sub(s, 12, 13))
    end
    local tbl = {year=y, month=M, day=d, hour=h, min=m}
    return time(tbl), tbl
end

function F.SecondsToTime(s)
    s = tonumber(s)
    return date("%H:%M", s)
end

-- time, seconds
function F.GetRaidStartTime(d)
    if d then
        if GRA_Logs[d]["startTime"] then -- has startTime
            return F.SecondsToTime(GRA_Logs[d]["startTime"]), GRA_Logs[d]["startTime"]
        else
            return GRA_Config["raidInfo"]["startTime"], F.DateToSeconds(d .. GRA_Config["raidInfo"]["startTime"], true)
        end
    else
        return GRA_Config["raidInfo"]["startTime"]
    end
end

function F.GetRaidEndTime(d)
    if d then
        if GRA_Logs[d]["endTime"] then -- has endTime
            return F.SecondsToTime(GRA_Logs[d]["endTime"]), GRA_Logs[d]["endTime"]
        else
            if GRA_Config["raidInfo"]["startTime"] > GRA_Config["raidInfo"]["endTime"] then -- 21:00-00:00(the next day)
                d = d + 1
            end
            return GRA_Config["raidInfo"]["endTime"], F.DateToSeconds(d .. GRA_Config["raidInfo"]["endTime"], true)
        end
    else
        return GRA_Config["raidInfo"]["endTime"]
    end
end

---------------------------------------------------------------------
-- Attendance
---------------------------------------------------------------------
function F.CheckAttendanceStatus(joinTime, startTime, leaveTime, endTime)
    if joinTime and startTime and (joinTime > startTime) then
        return "PARTIAL" -- no need to check leaveTime
    end

    if leaveTime and endTime and (leaveTime < endTime) then
        return "PARTIAL"
    end

    return "PRESENT"
end

-- update attendance status when raid hours changed
function F.UpdateAttendanceStatus(d)
    if d then
        -- start/end time changed for this day
        local startTime = select(2, F.GetRaidStartTime(d))
        local endTime =  select(2, F.GetRaidEndTime(d))
        if startTime > endTime then GRA.Print(GRA.vars.colors.firebrick.s .. L["Invalid raid hours on "] .. date("%x", F.DateToSeconds(d)) .. ".") end

        for n, t in pairs(GRA_Logs[d]["attendances"]) do
            if t[3] then -- PRESENT or PARTIAL
                t[1] = F.CheckAttendanceStatus(t[3], startTime, t[4], endTime)
            end
        end
    end
end

-- 出勤率使用出勤分钟数计算
local function GetAttendanceRate(d, joinTime, leaveTime)
    if not joinTime then
        return 0
    else
        local startTime = select(2, F.GetRaidStartTime(d))
        local endTime = select(2, F.GetRaidEndTime(d))

        -- validate raid hours
        if startTime == endTime then
            GRA.Print(GRA.vars.colors.firebrick.s .. L["Invalid Raid Hours on "] .. d)
            return 0
        end

        if leaveTime and leaveTime < startTime then return 0 end -- leave before start

        joinTime = math.max(startTime, joinTime)
        leaveTime = leaveTime and math.min(endTime, leaveTime) or endTime

        if joinTime == startTime and leaveTime == endTime then
            return 1
        else
            return math.ceil((leaveTime - joinTime) / 60) / math.ceil((endTime - startTime) / 60)
        end
    end
end

-- count player loots
local function GetLoots(d, name)
    local loots = 0
    for _, t in pairs(GRA_Logs[d]["details"]) do
        -- TODO: add support for EPGP and DKP
        if t[1] == "LOOT" and t[3] == name then
            loots = loots + 1
        end
    end
    return loots
end

-- get main-alt attendance
function F.GetMainAltAttendance(d, mainName)
    local att, joinTime, leaveTime, isSitOut
    local loots = 0

    -- check main
    if GRA_Logs[d]["attendances"][mainName] then
        att = GRA_Logs[d]["attendances"][mainName][1]

        if GRA_Logs[d]["attendances"][mainName][3] then -- 大号有出勤
            joinTime = GRA_Logs[d]["attendances"][mainName][3]
            leaveTime = GRA_Logs[d]["attendances"][mainName][4] or select(2, F.GetRaidEndTime(d))
            -- main sit out
            if GRA_Logs[d]["attendances"][mainName][5] then isSitOut = true end
            -- main loots
            loots = loots + GetLoots(d, mainName)
        end
    end

    -- check alt
    if GRA.vars.mainAlt[mainName] then
        for _, altName in pairs(GRA.vars.mainAlt[mainName]) do
            if GRA_Logs[d]["attendances"][altName] then -- alt is in log
                if GRA_Logs[d]["attendances"][altName][3] then -- PRESENT or PARTIAL
                    -- 大号没有出勤 or 小号先于大号进组
                    if not joinTime or joinTime > GRA_Logs[d]["attendances"][altName][3] then
                        -- att = GRA_Logs[d]["attendances"][altName][1]
                        joinTime = GRA_Logs[d]["attendances"][altName][3]
                    end
                    -- 小号有退组时间，且小号后于大号退组
                    if GRA_Logs[d]["attendances"][altName][4] and (not leaveTime or leaveTime < GRA_Logs[d]["attendances"][altName][4]) then
                        leaveTime = GRA_Logs[d]["attendances"][altName][4]
                    end
                    -- check attendance status again
                    if not leaveTime then leaveTime = select(2, F.GetRaidEndTime(d)) end -- main has no attendance
                    att = F.CheckAttendanceStatus(joinTime, select(2, F.GetRaidStartTime(d)), leaveTime, select(2, F.GetRaidEndTime(d)))
                    -- alt sit out
                    if GRA_Logs[d]["attendances"][altName][5] then isSitOut = true end
                    -- alt loots
                    loots = loots + GetLoots(d, altName)
                else -- ABSENT or ONLEAVE
                    if att == nil then
                        att = GRA_Logs[d]["attendances"][altName][1]
                    end
                end
            end
        end
    end

    -- print(d .. " name:" .. mainName .. " att:" .. att .. " join:" .. (joinTime or "") .. " leave:" .. (leaveTime or ""))
    return att, joinTime, leaveTime, GetAttendanceRate(d, joinTime, leaveTime), isSitOut, loots
end

-- calc AR and Loots
function F.CalcAtendanceRateAndLoots(from, to, progressBar, saveToSV)
    local today = F.Date()
    local logsNumber, logsNumber30, logsNumber60, logsNumber90 = 0, 0, 0, 0

    for d, _ in pairs(GRA_Logs) do
        if from and to then
            if d >= from and d <= to then
                logsNumber = logsNumber + 1
            end
        else
            local dateOffset = F.DateOffset(d, today)
            if dateOffset < 30 then logsNumber30 = logsNumber30 + 1 end
            if dateOffset < 60 then logsNumber60 = logsNumber60 + 1 end
            if dateOffset < 90 then logsNumber90 = logsNumber90 + 1 end
            logsNumber = logsNumber + 1
        end
    end

    if logsNumber ~= 0 then
        if progressBar then progressBar:SetMaxValue(logsNumber) end
        GRA.Debug("|cff1E90FFCalculating attendance rate:|r " .. logsNumber)
    else
        if progressBar then
            -- fake value, in order to make "OnValueChanged -> value == maxValue" happen
            progressBar:SetMaxValue(1)
            progressBar:SetValue(1)
        end
    end

    local playerAtts, playerLoots, dates = {}, {}, {}
    for n, t in pairs(GRA_Roster) do
        if not t["altOf"] then -- ignore alts
            playerAtts[n] = {
                -- {present, absent, late/leaveEarly, onLeave, ar, sitOut}
                ["30"] = {0, 0, 0, 0, 0},
                ["60"] = {0, 0, 0, 0, 0},
                ["90"] = {0, 0, 0, 0, 0},
                ["lifetime"] = {0, 0, 0, 0, 0, 0},
                ["dailyAttendance"] = {}, -- joinTime / leaveTime
            }
            playerLoots[n] = 0
        end
    end

    local n = 1
    -- calc
    if from and to then
        for d, l in pairs(GRA_Logs) do
            if d >= from and d <= to then
                -- store dates for Export.lua
                table.insert(dates, d)
                for name, t in pairs(l["attendances"]) do
                    local main = F.IsAlt(name)
                    -- main is added to roster after alt, (main is IGNORED)
                    if main and not l["attendances"][main] then
                        name = main
                    end
                    if playerAtts[name] then -- exists in roster
                        local att, joinTime, leaveTime, ar, isSitOut, loots = F.GetMainAltAttendance(d, name) -- add alt attendance to main
                        if att == "PRESENT" or att == "PARTIAL" then
                            playerAtts[name]["lifetime"][1] = playerAtts[name]["lifetime"][1] + 1
                            playerAtts[name]["lifetime"][5] = playerAtts[name]["lifetime"][5] + ar
                            if att == "PARTIAL" then
                                playerAtts[name]["lifetime"][3] = playerAtts[name]["lifetime"][3] + 1
                            end
                            if isSitOut then
                                playerAtts[name]["lifetime"][6] = playerAtts[name]["lifetime"][6] + 1
                            end
                            playerLoots[name] = playerLoots[name] + loots
                            -- joinTime & leaveTime
                            playerAtts[name]["dailyAttendance"][d] = {joinTime, leaveTime}
                        else -- ABSENT or ONLEAVE
                            playerAtts[name]["lifetime"][2] = playerAtts[name]["lifetime"][2] + 1
                            if att == "ONLEAVE" then
                                playerAtts[name]["lifetime"][4] = playerAtts[name]["lifetime"][4] + 1
                            end
                        end
                    end
                end

                if progressBar then
                    progressBar:SetValue(n)
                    n = n + 1
                end
            end
        end

    else
        for d, l in pairs(GRA_Logs) do
            local dateOffset = F.DateOffset(d, today)
            for name, t in pairs(l["attendances"]) do
                local main = F.IsAlt(name)
                -- main is added to roster after alt, (main is IGNORED)
                if main and not l["attendances"][main] then
                    name = main
                end
                if playerAtts[name] then -- exists in roster
                    local att, _, _, ar, isSitOut, loots = F.GetMainAltAttendance(d, name) -- add alt attendance to main
                    if att == "PRESENT" or att == "PARTIAL" then
                        playerAtts[name]["lifetime"][1] = playerAtts[name]["lifetime"][1] + 1
                        playerAtts[name]["lifetime"][5] = playerAtts[name]["lifetime"][5] + ar
                        if att == "PARTIAL" then
                            playerAtts[name]["lifetime"][3] = playerAtts[name]["lifetime"][3] + 1
                        end
                        if isSitOut then
                            playerAtts[name]["lifetime"][6] = playerAtts[name]["lifetime"][6] + 1
                        end

                        if dateOffset < 90 then
                            playerAtts[name]["90"][1] = playerAtts[name]["90"][1] + 1
                            playerAtts[name]["90"][5] = playerAtts[name]["90"][5] + ar
                            if att == "PARTIAL" then
                                playerAtts[name]["90"][3] = playerAtts[name]["90"][3] + 1
                            end
                        end
                        if dateOffset < 60 then
                            playerAtts[name]["60"][1] = playerAtts[name]["60"][1] + 1
                            playerAtts[name]["60"][5] = playerAtts[name]["60"][5] + ar
                            if att == "PARTIAL" then
                                playerAtts[name]["60"][3] = playerAtts[name]["60"][3] + 1
                            end
                        end
                        if dateOffset < 30 then
                            playerAtts[name]["30"][1] = playerAtts[name]["30"][1] + 1
                            playerAtts[name]["30"][5] = playerAtts[name]["30"][5] + ar
                            if att == "PARTIAL" then
                                playerAtts[name]["30"][3] = playerAtts[name]["30"][3] + 1
                            end
                        end
                        playerLoots[name] = playerLoots[name] + loots
                    else -- ABSENT or ONLEAVE
                        playerAtts[name]["lifetime"][2] = playerAtts[name]["lifetime"][2] + 1
                        if att == "ONLEAVE" then
                            playerAtts[name]["lifetime"][4] = playerAtts[name]["lifetime"][4] + 1
                        end

                        if dateOffset < 90 then
                            playerAtts[name]["90"][2] = playerAtts[name]["90"][2] + 1
                            if att == "ONLEAVE" then
                                playerAtts[name]["90"][4] = playerAtts[name]["90"][4] + 1
                            end
                        end
                        if dateOffset < 60 then
                            playerAtts[name]["60"][2] = playerAtts[name]["60"][2] + 1
                            if att == "ONLEAVE" then
                                playerAtts[name]["60"][4] = playerAtts[name]["60"][4] + 1
                            end
                        end
                        if dateOffset < 30 then
                            playerAtts[name]["30"][2] = playerAtts[name]["30"][2] + 1
                            if att == "ONLEAVE" then
                                playerAtts[name]["30"][4] = playerAtts[name]["30"][4] + 1
                            end
                        end
                    end
                end
            end

            if progressBar then
                progressBar:SetValue(n)
                n = n + 1
            end
        end
    end

    for name, t in pairs(GRA_Roster) do
        if playerAtts[name] then
            -- calc ar
            if GRA_Config["arCalculationMethod"] == "A" then -- method A: AR = PRESENT / (PRESENT + ABSENT)
                playerAtts[name]["30"][5] = (playerAtts[name]["30"][5] == 0) and 0 or (playerAtts[name]["30"][5] / (playerAtts[name]["30"][1] + playerAtts[name]["30"][2]) * 100)
                playerAtts[name]["60"][5] = (playerAtts[name]["60"][5] == 0) and 0 or (playerAtts[name]["60"][5] / (playerAtts[name]["60"][1] + playerAtts[name]["60"][2]) * 100)
                playerAtts[name]["90"][5] = (playerAtts[name]["90"][5] == 0) and 0 or (playerAtts[name]["90"][5] / (playerAtts[name]["90"][1] + playerAtts[name]["90"][2]) * 100)
                playerAtts[name]["lifetime"][5] = (playerAtts[name]["lifetime"][5] == 0) and 0 or (playerAtts[name]["lifetime"][5] / (playerAtts[name]["lifetime"][1] + playerAtts[name]["lifetime"][2]) * 100)
            else -- method B: AR = PRESENT / ALL RAID DAYS
                playerAtts[name]["30"][5] = (playerAtts[name]["30"][5] == 0) and 0 or (playerAtts[name]["30"][5] / logsNumber30 * 100)
                playerAtts[name]["60"][5] = (playerAtts[name]["60"][5] == 0) and 0 or (playerAtts[name]["60"][5] / logsNumber60 * 100)
                playerAtts[name]["90"][5] = (playerAtts[name]["90"][5] == 0) and 0 or (playerAtts[name]["90"][5] / logsNumber90 * 100)
                playerAtts[name]["lifetime"][5] = (playerAtts[name]["lifetime"][5] == 0) and 0 or (playerAtts[name]["lifetime"][5] / logsNumber * 100)
            end

            -- save
            if saveToSV then
                t["att30"] = playerAtts[name]["30"]
                t["att60"] = playerAtts[name]["60"]
                t["att90"] = playerAtts[name]["90"]
                t["attLifetime"] = playerAtts[name]["lifetime"]
                t["loots"] = playerLoots[name]
            end
        end
    end

    table.sort(dates)
    return playerAtts, playerLoots, dates
end