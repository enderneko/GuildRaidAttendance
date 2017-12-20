local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- eventFrame:RegisterEvent("PLAYER_LOGOUT")

local raidDate = nil
local function RaidRosterUpdate()
	-- 处于意外删除了刚刚创建的记录，再次询问
	if not _G[GRA_R_RaidLogs][raidDate] then GRA:StartTracking() end
	local n = GetNumGroupMembers("LE_PARTY_CATEGORY_HOME")
	for i = 1, n do
		-- name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index)
		local playerName, _, _, _, _, classFileName = GetRaidRosterInfo(i)
		if playerName then
			if not string.find(playerName, "-") then playerName = playerName .. "-" .. GetRealmName() end
			
			-- only log players in raid team, and "ONCE"
			if _G[GRA_R_Roster][playerName] and not _G[GRA_R_RaidLogs][raidDate]["attendees"][playerName] then
				-- check attendance (PRESENT or LATE)
				local joinTime = time()
				local att = GRA:IsLate(joinTime, raidDate.._G[GRA_R_Config]["raidInfo"]["startTime"])
				-- keep it logged
				_G[GRA_R_RaidLogs][raidDate]["attendees"][playerName] = {att, joinTime}
				-- remove from absentees
				_G[GRA_R_RaidLogs][raidDate]["absentees"] = GRA:RemoveElementsByKeys(_G[GRA_R_RaidLogs][raidDate]["absentees"], {playerName})
				-- refresh sheet and logs
				GRA:FireEvent("GRA_RAIDLOGS", raidDate)
			end
		end
	end
end

---------------------------------------------------
-- start/stop tracking
---------------------------------------------------
function GRA:StartTracking(instanceName, difficultyName)
	local cb
	raidDate = GRA:Date()

	local text = L["Keep track of loots and attendances during this raid session?"]
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
			_G[GRA_R_RaidLogs][raidDate] = {["attendees"]={}, ["absentees"]={}, ["details"]={}}
			-- fill absent with all members
			for n, t in pairs(_G[GRA_R_Roster]) do
				_G[GRA_R_RaidLogs][raidDate]["absentees"][n] = ""
			end
		end

		RaidRosterUpdate()
		eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		GRA:FireEvent("GRA_TRACK", raidDate)
		gra.isTracking = true

		if cb then cb:Hide() end
	end, function()
		if cb then cb:Hide() end
		eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		GRA:FireEvent("GRA_TRACK")
		gra.isTracking = false
	end)
	
	if _G[GRA_R_Config]["lastRaidDate"] and _G[GRA_R_Config]["lastRaidDate"] ~= raidDate then
		cb = GRA:CreateCheckButton(gra.staticPopup, L["Resume last raid"], nil, function()
		end, "GRA_FONT_SMALL")
		cb:SetPoint("BOTTOMLEFT", 2, 2)
	end
end

-- manually stop tracking
function GRA:StopTracking()
	local text = L["Stop tracking loots and attendances?"]
	GRA:CreateStaticPopup(L["Stop Tracking"], text, function()
		GRA:Print(L["Raid tracking has stopped."])
		eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		GRA:FireEvent("GRA_TRACK")
		gra.isTracking = false
	end)
end

---------------------------------------------------
-- check permission and ask whether to track
---------------------------------------------------
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
		GRA:Print(L["Raid tracking has stopped."])
		GRA:FireEvent("GRA_TRACK")
		gra.isTracking = false
	end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)