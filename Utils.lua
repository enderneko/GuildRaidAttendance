local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

-- #GRA:admin1,admin2
-- permission control
function GRA:IsAdmin()
	local info = GetGuildInfoText()
	if info == "" then
		-- GRA:Debug("|cff87CEEBGRA:IsAdmin: |rfailed")
		return -- nil
	end
	local lines = {strsplit("\n", info)}
	for _, line in pairs(lines) do
		if (string.find(line, "#GRA:")) then
			GRA:Debug("|cff87CEEBGRA:IsAdmin: |r" .. line)
			-- multi-admin
			gra.admins = {strsplit(",", string.sub(line, 6))}
			if GRA:TContains(gra.admins, UnitName("player")) then
			-- if string.sub(line, 6) == UnitName("player") then
				gra.isAdmin = true
				GRA:FireEvent("GRA_PERMISSION", true)
				-- force disable minimode
				if GRA_Variables["minimalMode"] then
					GRA:FireEvent("GRA_MINI", false)
					GRA_Variables["minimalMode"] = false
				end
				return true
			else
				gra.isAdmin = false
				GRA:FireEvent("GRA_PERMISSION", false)
				return false
			end
		end
	end
	gra.admins = {}
	gra.isAdmin = false
	GRA:FireEvent("GRA_PERMISSION", nil) -- nil , no admin
	return false
end

local trial, count = nil, 0
function GRA:CheckPermissions()
	-- permission control
	if GRA:IsAdmin() == nil then -- check failed
		if not trial then -- check 10 more times
			securecall("GuildRoster")
			trial = C_Timer.NewTicker(1.5, function()
				securecall("GuildRoster")
				count = count + 1
				GRA:Debug("|cff87CEEBGRA:CheckPermissions():|r " .. count)
				GRA:CheckPermissions() -- try again
			end, 10)
		end
	else
		if trial then
			trial:Cancel()
			count = 0
			trial = nil
			GRA:Debug("|cff87CEEBGRA:CheckPermissions()|r: cancelled with success")
		end
	end
end

------------------------------------------------
-- General
------------------------------------------------
function GRA:RGBtoHEX(r, g, b)
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function GRA:Round(n)
	if n < 0 then
		return math.ceil(n)
	elseif math.ceil(n) == n then -- is integer
		return n
	else
		return math.ceil(n)-1
	end
end

function GRA:Calc(ex)
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

function GRA:HexToRGB(color, a)
	local r = tonumber("0x" .. string.sub(color, 1, 2))/255
	local g = tonumber("0x" .. string.sub(color, 3, 4))/255
	local b = tonumber("0x" .. string.sub(color, 5, 6))/255

	if a then
		return r, g, b, a
	else
		return r, g, b
	end
end

function GRA:RGBToHex(r, g, b)
	r = string.format("%x", r * 255)
	g = string.format("%x", g * 255)
	b = string.format("%x", b * 255)
	return r .. g .. b
end


------------------------------------------------
-- Table
------------------------------------------------
function GRA:TContains(t, v)
	for _, value in pairs(t) do
		if value == v then return true end
	end
	return false
end

function GRA:TContainsKey(t, k)
	if t[k] ~= nil then
		return true
	end
	return false
end

function GRA:Getn(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end

function GRA:GetIndex(t, e)
	for i = 1, #t do
		if e == t[i] then
			return i
		end
	end
	return nil
end

function GRA:Copy(t)
	local newTbl = {}
	for k, v in pairs(t) do
        if type(v) == "table" then  
            newTbl[k] = GRA:Copy(v)
        else  
            newTbl[k] = v  
        end  
	end
	return newTbl
end

-- function GRA:Copy(from, to)
-- 	for k, v in pairs(from) do
--         if type(v) == "table" then  
--             to[k] = {}
--             GRA:Copy(v, to[k])
--         else  
--             to[k] = v
--         end  
-- 	end
-- end

function GRA:Remove(t, v)
	for i = 1, #t do
		if t[i] == v then
			table.remove(t, i)
			return
		end
	end
end

function GRA:RemoveElementsByKeys(tbl, keys) -- keys is a table
	local newTbl = {}
	for k, v in pairs(tbl) do
		if not GRA:TContains(keys, k) then
			newTbl[k] = tbl[k]
		end
	end
	return newTbl
end

function GRA:Sort(t, k1, order1, k2, order2, k3, order3)
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

function GRA:TableToString(tbl, sep, noEndDot)
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

------------------------------------------------
-- GRA Data
------------------------------------------------
function GRA:GetPlayers()
	local players = {}
	for pName, pTable in pairs(_G[GRA_R_Roster]) do
		table.insert(players, pName)
	end
	return players
end

function GRA:GetGuildRoster(rank)
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
			-- GRA:Sort(roster, "rankIndex", "ascending", "name", "ascending")
			-- return roster
		end
	end
	return roster
end

function GRA:GetGuildOnlineRoster()
	local roster = {}
	for i = 1, GetNumGuildMembers() do
		local fullName, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
		if isOnline then
			roster[fullName] = true
		end
	end
	return roster
end

function GRA:GetShortName(fullName)
	local shortName = strsplit("-", fullName)
	return shortName
end

function GRA:GetClassColoredName(fullName, class)
	if not fullName then return "" end
	local name = GRA:GetShortName(fullName)

	if not class then
		if not _G[GRA_R_Roster][fullName] then -- grey (deleted players)
			return "|cff909090" .. name .. "|r"
		end
		class = _G[GRA_R_Roster][fullName]["class"]
	end
	
	if not RAID_CLASS_COLORS[class] then -- wrong class
		return "|cff909090" .. name .. "|r"
	else
		return "|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. "|r"
	end
end

function GRA:GetRealmName()
	return string.gsub(GetRealmName(), " ", "")
end

function GRA:GetPlayersInRaid()
	if IsInRaid() then
		local raidInfo = {}
		for i = 1, 40 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
			if name then
				if not raidInfo[subgroup] then raidInfo[subgroup] = {} end
				if not string.find(name, "-") then name = name .. "-" .. GRA:GetRealmName() end
				table.insert(raidInfo[subgroup], name)
			 end
		end
		return raidInfo
	end
end

function GRA:GetDifficultyInfo(difficultyID)
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

local classTable = {}
FillLocalizedClassList(classTable)
function GRA:GetLocalizedClassName(class)
	return classTable[class]
end

gra.mainAlt = {}
function GRA:UpdateMainAlt()
	wipe(gra.mainAlt)
	for n, t in pairs(_G[GRA_R_Roster]) do
		if t["altOf"] then
			if not gra.mainAlt[t["altOf"]] then gra.mainAlt[t["altOf"]] = {} end
			table.insert(gra.mainAlt[t["altOf"]], n)
		end
	end
end

function GRA:IsAlt(n)
	if _G[GRA_R_Roster][n] and _G[GRA_R_Roster][n]["altOf"] then
		return _G[GRA_R_Roster][n]["altOf"]
	end
end

function GRA:GetAttendeesAndAbsentees(d, filterMainAlt)
	local attendees, absentees = {}, {}
	for n, t in pairs(_G[GRA_R_RaidLogs][d]["attendances"]) do
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
			if _G[GRA_R_Roster][n] and _G[GRA_R_Roster][n]["altOf"] then
				if GRA:GetIndex(attendees, _G[GRA_R_Roster][n]["altOf"]) then
					-- main already exists in attendees, remove it
					table.remove(attendees, i)
				else
					-- convert to main!
					attendees[i] = _G[GRA_R_Roster][n]["altOf"]
				end
			end
		end

		for i = #absentees, 1, -1 do
			local n = absentees[i]
			if _G[GRA_R_Roster][n] and _G[GRA_R_Roster][n]["altOf"] then -- is alt
				if GRA:TContains(absentees, _G[GRA_R_Roster][n]["altOf"]) then
					-- main already exists in absentees, remove it
					table.remove(absentees, i)
				else
					if GRA:TContains(attendees, _G[GRA_R_Roster][n]["altOf"]) then
						-- main exists in attendees, remove it from absentees
						table.remove(absentees, i)
					else
						-- convert to main!
						absentees[i] = _G[GRA_R_Roster][n]["altOf"]
					end
				end
			else -- is main
				if GRA:TContains(attendees, n) then
					-- main exists in attendees, remove it from absentees
					table.remove(absentees, i)
				end
			end
		end
	end

	return attendees, absentees
end

------------------------------------------------
-- Date & Time
------------------------------------------------
local monthNames = CALENDAR_FULLDATE_MONTH_NAMES
function GRA:GetMonthNames(isShort)
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
function GRA:GetWeekdayNames(isShort, forceEnglish)
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
function GRA:DateToWeekday(d, forceEnglish)
	local year = string.sub(d, 1, 4)
	local month = string.sub(d, 5, 6)
	local day = string.sub(d, 7, 8)

	local sec = time({["day"]=day, ["month"]=month, ["year"]=year})
	local t = date("*t", sec)
	local wdNames = GRA:GetWeekdayNames(true, forceEnglish or GRA_FORCE_ENGLISH)
	
	return wdNames[t.wday], t.wday
end

-- http://lua-users.org/wiki/DayOfWeekAndDaysInMonthExample
local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

local function isLeapYear(year)
	return year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0)
end

-- return numDays, firstWeekday
function GRA:GetAbsMonthInfo(month, year)
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
function GRA:FormatDateHeader(d)
	-- weekdayNames = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
	local year = string.sub(d, 1, 4)
	local month = string.sub(d, 5, 6)
	local day = string.sub(d, 7, 8)

	local sec = time({["day"]=day, ["month"]=month, ["year"]=year})
	return L[date("%a", sec)] .. "\n" .. tonumber(day)
	-- local weekday = GRA:DateToWeekday(d)
	-- return weekday .. "\n" .. tonumber(day)
end

-- get current time, "20170305", "23:33"
function GRA:Date()
	local sec = time()
	-- local t = date("*t", sec)
	-- local year, month, day =  date("%Y", sec), date("%m", sec), date("%d", sec)
	-- local hour, minute = date("%H", sec), date("%M", sec)
	-- return year..month..day, hour..":"..minute
	return date("%Y%m%d", sec), date("%H:%M", sec)
end

-- get lockout reset day of this "week", init _G[GRA_R_Config]["startDate"]
function GRA:GetLockoutsResetDate()
	local t = GRA:Date()
	local wday = select(2, GRA:DateToWeekday(t))
	local offset = 0
	-- backward search
	if wday > gra.RAID_LOCKOUTS_RESET  then -- forward
		offset = gra.RAID_LOCKOUTS_RESET - wday
	elseif wday < gra.RAID_LOCKOUTS_RESET then -- backward
		offset = gra.RAID_LOCKOUTS_RESET - wday - 7
	end
	return GRA:NextDate(t, offset)
end

-- next valid date string, offset = 1 by default, "20170331"->"20170401"
function GRA:NextDate(d, offset)
	if not offset then offset = 1 end
	local year = string.sub(d, 1, 4)
	local month = string.sub(d, 5, 6)
	local day = string.sub(d, 7, 8) + offset
	local sec = time({["year"]=year, ["month"]=month, ["day"]=day})
	return date("%Y%m%d", sec)
end

function GRA:DateOffset(d1, d2)
	local t1, t2 = GRA:DateToSeconds(d1), GRA:DateToSeconds(d2)
	local offset = abs(t1 - t2) / (3600 * 24)
	return offset
end

-- 2017033112:30
function GRA:DateToSeconds(s, hasTime)
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

function GRA:SecondsToTime(s)
	s = tonumber(s)
	return date("%H:%M", s)
end

-- time, seconds
function GRA:GetRaidStartTime(d)
	if d then
		if _G[GRA_R_RaidLogs][d]["startTime"] then -- has startTime
			return GRA:SecondsToTime(_G[GRA_R_RaidLogs][d]["startTime"]), _G[GRA_R_RaidLogs][d]["startTime"]
		else
			return _G[GRA_R_Config]["raidInfo"]["startTime"], GRA:DateToSeconds(d .. _G[GRA_R_Config]["raidInfo"]["startTime"], true)
		end
	else
		return _G[GRA_R_Config]["raidInfo"]["startTime"]
	end
end

function GRA:GetRaidEndTime(d)
	if d then
		if _G[GRA_R_RaidLogs][d]["endTime"] then -- has endTime
			return GRA:SecondsToTime(_G[GRA_R_RaidLogs][d]["endTime"]), _G[GRA_R_RaidLogs][d]["endTime"]
		else
			if _G[GRA_R_Config]["raidInfo"]["startTime"] > _G[GRA_R_Config]["raidInfo"]["endTime"] then -- 21:00-00:00(the next day)
				d = d + 1
			end
			return _G[GRA_R_Config]["raidInfo"]["endTime"], GRA:DateToSeconds(d .. _G[GRA_R_Config]["raidInfo"]["endTime"], true)
		end
	else
		return _G[GRA_R_Config]["raidInfo"]["endTime"]
	end
end

------------------------------------------------
-- Attendance
------------------------------------------------
function GRA:CheckAttendanceStatus(joinTime, startTime, leaveTime, endTime)
	if joinTime and startTime and (joinTime > startTime) then
		return "PARTIAL" -- no need to check leaveTime
	end

	if leaveTime and endTime and (leaveTime < endTime) then
		return "PARTIAL"
	end

	return "PRESENT"
end

-- update attendance status when raid hours changed
function GRA:UpdateAttendanceStatus(d)
	if d then
		-- start/end time changed for this day
		local startTime = select(2, GRA:GetRaidStartTime(d))
		local endTime =  select(2, GRA:GetRaidEndTime(d))
		if startTime > endTime then GRA:Print(gra.colors.firebrick.s .. L["Invalid raid hours on "] .. date("%x", GRA:DateToSeconds(d)) .. ".") end
		
		for n, t in pairs(_G[GRA_R_RaidLogs][d]["attendances"]) do
			if t[3] then -- PRESENT or PARTIAL
				t[1] = GRA:CheckAttendanceStatus(t[3], startTime, t[4], endTime)
			end
		end
	end
end

-- 出勤率使用出勤分钟数计算
local function GetAttendanceRate(d, joinTime, leaveTime)
	if not joinTime then
		return 0
	else
		local startTime = select(2, GRA:GetRaidStartTime(d))
		local endTime = select(2, GRA:GetRaidEndTime(d))

		-- validate raid hours
		if startTime == endTime then
			GRA:Print(gra.colors.firebrick.s .. L["Invalid Raid Hours on "] .. d)
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
	for _, t in pairs(_G[GRA_R_RaidLogs][d]["details"]) do
		-- TODO: add support for EPGP and DKP
		if t[1] == "LOOT" and t[3] == name then
			loots = loots + 1
		end
	end
	return loots
end

-- get main-alt attendance
function GRA:GetMainAltAttendance(d, mainName)
	local att, joinTime, leaveTime, isSitOut
	local loots = 0

	-- check main
	if _G[GRA_R_RaidLogs][d]["attendances"][mainName] then
		att = _G[GRA_R_RaidLogs][d]["attendances"][mainName][1]

		if _G[GRA_R_RaidLogs][d]["attendances"][mainName][3] then -- 大号有出勤
			joinTime = _G[GRA_R_RaidLogs][d]["attendances"][mainName][3]
			leaveTime = _G[GRA_R_RaidLogs][d]["attendances"][mainName][4] or select(2, GRA:GetRaidEndTime(d))
			-- main sit out
			if _G[GRA_R_RaidLogs][d]["attendances"][mainName][5] then isSitOut = true end
			-- main loots
			loots = loots + GetLoots(d, mainName)
		end
	end

	-- check alt
	if gra.mainAlt[mainName] then
		for _, altName in pairs(gra.mainAlt[mainName]) do
			if _G[GRA_R_RaidLogs][d]["attendances"][altName] then -- alt is in log
				if _G[GRA_R_RaidLogs][d]["attendances"][altName][3] then -- PRESENT or PARTIAL
					-- 大号没有出勤 or 小号先于大号进组
					if not joinTime or joinTime > _G[GRA_R_RaidLogs][d]["attendances"][altName][3] then
						-- att = _G[GRA_R_RaidLogs][d]["attendances"][altName][1]
						joinTime = _G[GRA_R_RaidLogs][d]["attendances"][altName][3]
					end
					-- 小号有退组时间，且小号后于大号退组
					if _G[GRA_R_RaidLogs][d]["attendances"][altName][4] and (not leaveTime or leaveTime < _G[GRA_R_RaidLogs][d]["attendances"][altName][4]) then
						leaveTime = _G[GRA_R_RaidLogs][d]["attendances"][altName][4]
					end
					-- check attendance status again
					if not leaveTime then leaveTime = select(2, GRA:GetRaidEndTime(d)) end -- main has no attendance
					att = GRA:CheckAttendanceStatus(joinTime, select(2, GRA:GetRaidStartTime(d)), leaveTime, select(2, GRA:GetRaidEndTime(d)))
					-- alt sit out
					if _G[GRA_R_RaidLogs][d]["attendances"][altName][5] then isSitOut = true end
					-- alt loots
					loots = loots + GetLoots(d, altName)
				else -- ABSENT or ONLEAVE
					if att == nil then
						att = _G[GRA_R_RaidLogs][d]["attendances"][altName][1]
					end
				end
			end
		end
	end

	-- print(d .. " name:" .. mainName .. " att:" .. att .. " join:" .. (joinTime or "") .. " leave:" .. (leaveTime or ""))
	return att, joinTime, leaveTime, GetAttendanceRate(d, joinTime, leaveTime), isSitOut, loots
end

-- calc AR and Loots
function GRA:CalcAtendanceRateAndLoots(from, to, progressBar, saveToSV)
	local today = GRA:Date()
	local logsNumber, logsNumber30, logsNumber60, logsNumber90 = 0, 0, 0, 0

	for d, _ in pairs(_G[GRA_R_RaidLogs]) do
		if from and to then
			if d >= from and d <= to then
				logsNumber = logsNumber + 1
			end
		else
			local dateOffset = GRA:DateOffset(d, today)
			if dateOffset < 30 then logsNumber30 = logsNumber30 + 1 end
			if dateOffset < 60 then logsNumber60 = logsNumber60 + 1 end
			if dateOffset < 90 then logsNumber90 = logsNumber90 + 1 end
			logsNumber = logsNumber + 1
		end
	end

	if logsNumber ~= 0 then
		if progressBar then progressBar:SetMaxValue(logsNumber) end
		GRA:Debug("|cff1E90FFCalculating attendance rate:|r " .. logsNumber)
	else
		if progressBar then
			-- fake value, in order to make "OnValueChanged -> value == maxValue" happen
			progressBar:SetMaxValue(1)
			progressBar:SetValue(1)
		end
	end

	local playerAtts, playerLoots, dates = {}, {}, {}
	for n, t in pairs(_G[GRA_R_Roster]) do
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
		for d, l in pairs(_G[GRA_R_RaidLogs]) do
			if d >= from and d <= to then
				-- store dates for Export.lua
				table.insert(dates, d)
				for name, t in pairs(l["attendances"]) do
					local main = GRA:IsAlt(name)
					-- main is added to roster after alt, (main is IGNORED)
					if main and not l["attendances"][main] then
						name = main
					end
					if playerAtts[name] then -- exists in roster
						local att, joinTime, leaveTime, ar, isSitOut, loots = GRA:GetMainAltAttendance(d, name) -- add alt attendance to main
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
		for d, l in pairs(_G[GRA_R_RaidLogs]) do
			local dateOffset = GRA:DateOffset(d, today)
			for name, t in pairs(l["attendances"]) do
				local main = GRA:IsAlt(name)
				-- main is added to roster after alt, (main is IGNORED)
				if main and not l["attendances"][main] then
					name = main
				end
				if playerAtts[name] then -- exists in roster
					local att, _, _, ar, isSitOut, loots = GRA:GetMainAltAttendance(d, name) -- add alt attendance to main
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
	
	for name, t in pairs(_G[GRA_R_Roster]) do
		if playerAtts[name] then
			-- calc ar
			if _G[GRA_R_Config]["arCalculationMethod"] == "A" then -- method A: AR = PRESENT / (PRESENT + ABSENT)
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