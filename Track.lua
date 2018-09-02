local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- eventFrame:RegisterEvent("PLAYER_LOGOUT")

local raidDate = nil
local encounterInfo = {}

-- local function UpdateLeaveTime()
local function RaidRosterUpdate()
	-- 意外删除了刚刚创建的记录，再次询问
	if not _G[GRA_R_RaidLogs][raidDate] then GRA:StartTracking() return end

	local updateNeeded = false
	-- joinTime
	local n = GetNumGroupMembers("LE_PARTY_CATEGORY_HOME")
	for i = 1, n do
		-- name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index)
		local playerName, _, _, _, _, classFileName = GetRaidRosterInfo(i)
		if playerName then
			if not string.find(playerName, "-") then playerName = playerName .. "-" .. GetRealmName() end
			
			if _G[GRA_R_Roster][playerName] and _G[GRA_R_RaidLogs][raidDate]["attendances"][playerName] then
				-- only log players in roster, and record joinTime
				if not _G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][3] then
					-- check attendance (PRESENT or PARTLY)
					local joinTime = time()
					local att = GRA:CheckAttendanceStatus(joinTime, select(2, GRA:GetRaidStartTime(raidDate)))
					-- keep it logged
					_G[GRA_R_RaidLogs][raidDate]["attendances"][playerName] = {att, nil, joinTime}
					updateNeeded = true
				end

				-- re-join group, delete leaveTime if exists
				if _G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][4] then
					table.remove(_G[GRA_R_RaidLogs][raidDate]["attendances"][playerName], 4)
					-- update att
					_G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][1] = GRA:CheckAttendanceStatus(_G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][3], select(2, GRA:GetRaidStartTime(raidDate)))
					updateNeeded = true
				end
			end
		end
	end

	-- leaveTime
	for playerName, t in pairs(_G[GRA_R_RaidLogs][raidDate]["attendances"]) do
		if not _G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][4]
			and _G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][3]
			and not (UnitInParty(GRA:GetShortName(playerName)) or UnitInRaid(GRA:GetShortName(playerName))) then
			-- 记录离团时间，并更新出勤
			_G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][4] = time()
			_G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][1] = GRA:CheckAttendanceStatus(_G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][3], select(2, GRA:GetRaidStartTime(raidDate)), _G[GRA_R_RaidLogs][raidDate]["attendances"][playerName][4], select(2, GRA:GetRaidEndTime(raidDate)))
			updateNeeded = true
		end
	end

	if updateNeeded then
		-- refresh sheet and logs
		GRA:FireEvent("GRA_RAIDLOGS", raidDate)
	end
end

---------------------------------------------------
-- start/stop tracking
---------------------------------------------------
function GRA:StartTracking(instanceName, difficultyName)
	local cb
	raidDate = GRA:Date()

	local text = L["Keep track of boss kills and attendances during this raid session?"]
	if instanceName and difficultyName then
		text = text.."\n|cff909090"..L["Raid: "]..instanceName.." "..difficultyName
	end

	GRA:CreateStaticPopup(L["Track This Raid"], text, function()
		if GRA:Getn(_G[GRA_R_Roster]) == 0 then -- no member
			GRA:Print(L["In order to start tracking, you have to import members in Config."])
			return
		end
		if not cb or not cb:GetChecked() then -- new raid (no raid log before)
			GRA:Print(L["Raid tracking has started."])
			_G[GRA_R_Config]["lastRaidDate"] = raidDate
		else
			-- resume last raid
			raidDate = _G[GRA_R_Config]["lastRaidDate"]
			GRA:Print(L["Resumed last raid (%s)."]:format(date("%x", GRA:DateToTime(raidDate))))
		end
		
		-- init date
		if not _G[GRA_R_RaidLogs][raidDate] then
			_G[GRA_R_RaidLogs][raidDate] = {["attendances"]={}, ["details"]={}, ["bosses"] = {}}
			-- init all members with "ABSENT" 
			for n, t in pairs(_G[GRA_R_Roster]) do
				_G[GRA_R_RaidLogs][raidDate]["attendances"][n] = {"ABSENT"}
			end
			-- init desc
			if instanceName and difficultyName then
				_G[GRA_R_RaidLogs][raidDate]["desc"] = instanceName.." "..difficultyName
			end
		end

		RaidRosterUpdate() -- scan raid for attendance
		eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		eventFrame:RegisterEvent("ENCOUNTER_START")
		eventFrame:RegisterEvent("ENCOUNTER_END")
		GRA:FireEvent("GRA_TRACK", raidDate)
		GRA:FireEvent("GRA_RAIDLOGS", raidDate)
		gra.isTracking = true
		gra.trackingDate = raidDate

		if cb then cb:Hide() end
	end, function()
		if cb then cb:Hide() end
		eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		eventFrame:UnregisterEvent("ENCOUNTER_START")
		eventFrame:UnregisterEvent("ENCOUNTER_END")
		GRA:FireEvent("GRA_TRACK")
		gra.isTracking = false
		gra.trackingDate = nil
	end)
	
	if _G[GRA_R_Config]["lastRaidDate"] and _G[GRA_R_Config]["lastRaidDate"] ~= raidDate then
		cb = GRA:CreateCheckButton(gra.staticPopup, L["Resume last raid"], nil, function()
		end, "GRA_FONT_SMALL")
		cb:SetPoint("BOTTOMLEFT", 2, 2)
	end
end

-- manually stop tracking
function GRA:StopTracking(force)
	if not force then
		local text = L["Stop tracking boss kills and attendances?"]
		GRA:CreateStaticPopup(L["Stop Tracking"], text, function()
			GRA:Print(L["Raid tracking has stopped."])
			eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
			eventFrame:UnregisterEvent("ENCOUNTER_START")
			eventFrame:UnregisterEvent("ENCOUNTER_END")
			GRA:FireEvent("GRA_TRACK")
			gra.isTracking = false
			gra.trackingDate = nil
			wipe(encounterInfo)
		end)
	else
		GRA:Print(L["Raid tracking has stopped."])
		eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		eventFrame:UnregisterEvent("ENCOUNTER_START")
		eventFrame:UnregisterEvent("ENCOUNTER_END")
		GRA:FireEvent("GRA_TRACK")
		gra.isTracking = false
		gra.trackingDate = nil
		wipe(encounterInfo)
	end
end

---------------------------------------------------
-- events
---------------------------------------------------
-- check permission and ask whether to track
function eventFrame:PLAYER_ENTERING_WORLD()
	if IsInGuild() and gra.isAdmin == nil then -- check permission
		GRA:CheckPermissions()
		GRA:RegisterEvent("GRA_PERMISSION", "Events_CheckPermissions", function(isAdmin)
			-- GRA:UnregisterEvent("GRA_PERMISSION", "Events_CheckPermissions")
			if isAdmin then
				eventFrame:PLAYER_ENTERING_WORLD()
			end
		end)
	elseif gra.isAdmin then -- track?
		local name, instanceType, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
		if not gra.isTracking and instanceType == "raid" and difficulty ~= 17 and IsInRaid() then -- and UnitIsGroupLeader("player")
			GRA:StartTracking(name, difficultyName)
		end
	end
end

function eventFrame:GROUP_ROSTER_UPDATE()
	if IsInRaid() or IsInGroup("LE_PARTY_CATEGORY_HOME") then
		RaidRosterUpdate() -- keep track of join_time
	else -- left group
		eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		eventFrame:UnregisterEvent("ENCOUNTER_START")
		eventFrame:UnregisterEvent("ENCOUNTER_END")
		GRA:Print(L["Raid tracking has stopped."])
		GRA:FireEvent("GRA_TRACK")
		gra.isTracking = false
		gra.trackingDate = nil
		wipe(encounterInfo)
	end
end

function eventFrame:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
	-- local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(difficultyID)
	encounterInfo[encounterID] = {encounterName, difficultyID, time()}
end

function eventFrame:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
	if success then
		if not encounterInfo[encounterID] or #encounterInfo[encounterID] == 0 then -- disconnected or wiped
			encounterInfo[encounterID] = {encounterName, difficultyID, nil, time(), GRA:GetPlayersInRaid()}
		else
			encounterInfo[encounterID][4] = time() -- end time
			encounterInfo[encounterID][5] = GRA:GetPlayersInRaid()
		end
		
		local popup = GRA:CreatePopupWithButton(gra.colors.chartreuse.s .. L["Save encounter info?"] .. "|r\n" .. encounterInfo[encounterID][1], function()
			-- 点击发生在退队后，encounterInfo已被清空
			if encounterInfo[encounterID] then
				table.insert(_G[GRA_R_RaidLogs][raidDate]["bosses"], GRA:Copy(encounterInfo[encounterID]))
				GRA:FireEvent("GRA_BOSS", raidDate)
				wipe(encounterInfo[encounterID])
			end
		end, function()
			if encounterInfo[encounterID] then
				wipe(encounterInfo[encounterID])
			end
		end)
	end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)