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
			if tContains(gra.admins, UnitName("player")) then
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
		if tContains(keys, k) ~= 1 then -- not contains
			newTbl[k] = tbl[k]
		end
	end
	return newTbl
end

function GRA:Sort(t, k1, order1, k2, order2)
	table.sort(t, function(a, b)
		if a[k1] ~= b[k1] then
			if order1 == "ascending" then
				return a[k1] < b[k1]
			else -- "descending"
				return a[k1] > b[k1]
			end
		else
			if order2 == "ascending" then
				return a[k2] < b[k2]
			else -- "descending"
				return a[k2] > b[k2]
			end
		end
	end)
	return t
end

function GRA:TableToString(tbl)
	-- if string then return it
	if type(tbl) == "string" then return tbl end
	if type(tbl) ~= "table" or #tbl == 0 then return "" end
	
	s = tbl[1]
	for i = 2, #tbl do
		s = s .. ", " .. tbl[i]
	end
	s = s .. "."
	return s
end

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
			-- sort and return
			GRA:Sort(roster, "rankIndex", "ascending", "name", "ascending")
			return roster
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

local classTable = {}
FillLocalizedClassList(classTable)
function GRA:GetLocalizedClassName(class)
	return classTable[class]
end

-- d: date string/number, "20170321" or 20170321
function GRA:DateToWeekday(d)
	local year = string.sub(d, 1, 4)
	local month = string.sub(d, 5, 6)
	local day = string.sub(d, 7, 8)

	local sec = time({["day"]=day, ["month"]=month, ["year"]=year})
	local t = date("*t", sec)
	local weekdayNames = {CalendarGetWeekdayNames()}
	if GRA_FORCE_ENGLISH then weekdayNames = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"} end
	
	return weekdayNames[t.wday], t.wday
end

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

-- 2017033112:30
function GRA:DateToTime(s, hasTime)
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

function GRA:GetRaidStartTime(d)
	if _G[GRA_R_RaidLogs][d]["startTime"] then
		return _G[GRA_R_RaidLogs][d]["startTime"]
	else
		return _G[GRA_R_Config]["raidInfo"]["startTime"]
	end
end

function GRA:IsLate(joinTime, startTime)
	if joinTime <= GRA:DateToTime(startTime, true) then
		return "PRESENT"
	else
		return "LATE"
	end
	-- local h1,m1 = strsplit(":", joinTime)
	-- local h2,m2 = strsplit(":", startTime)
	-- return tonumber(h1..m1) > tonumber(h2..m2)
end

-- update attendances when start time changed
function GRA:UpdateAttendance(d)
	if d then
		-- start time changed for this day
		for n, t in pairs(_G[GRA_R_RaidLogs][d]["attendees"]) do
			t[1] = GRA:IsLate(t[2], d .. (_G[GRA_R_RaidLogs][d]["startTime"] or _G[GRA_R_Config]["raidInfo"]["startTime"]))
		end
	else
		-- global start time changed, only check date without start time
		for dateString, logTable in pairs(_G[GRA_R_RaidLogs]) do
			if not logTable["startTime"] then
				GRA:UpdateAttendance(dateString)
			end
		end
	end
end

function GRA:DateOffset(d1, d2)
	local t1, t2 = GRA:DateToTime(d1), GRA:DateToTime(d2)
	local offset = abs(t1 - t2) / (3600 * 24)
	return offset
end