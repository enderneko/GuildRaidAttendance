---@class GRA
local GRA = select(2, ...)
local L = GRA.L
---@class Funcs
local F = GRA.funcs

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- eventFrame:RegisterEvent("PLAYER_LOGOUT")

local raidDate = nil
local encounterInfo = {}

local function RaidRosterUpdate()
    -- 意外删除了刚刚创建的记录，再次询问
    if not GRA_Logs[raidDate] then F.StartTracking() return end

    local updateNeeded = false
    -- joinTime
    local n = GetNumGroupMembers("LE_PARTY_CATEGORY_HOME")
    for i = 1, n do
        -- name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index)
        local playerName, _, _, _, _, classFileName = GetRaidRosterInfo(i)
        if playerName then
            if not string.find(playerName, "-") then playerName = playerName .. "-" .. F.GetRealmName() end

            if GRA_Roster[playerName] and GRA_Logs[raidDate]["attendances"][playerName] then
                -- only log players in roster, and record joinTime
                if not GRA_Logs[raidDate]["attendances"][playerName][3] then
                    -- check attendance (PRESENT or PARTIAL)
                    local joinTime = time()
                    local att = F.CheckAttendanceStatus(joinTime, select(2, F.GetRaidStartTime(raidDate)))
                    -- keep it logged
                    GRA_Logs[raidDate]["attendances"][playerName] = {att, nil, joinTime}
                    updateNeeded = true
                end

                -- re-join group, delete leaveTime if exists
                if GRA_Logs[raidDate]["attendances"][playerName][4] then
                    GRA_Logs[raidDate]["attendances"][playerName][4] = nil
                    -- update att
                    GRA_Logs[raidDate]["attendances"][playerName][1] = F.CheckAttendanceStatus(GRA_Logs[raidDate]["attendances"][playerName][3], select(2, F.GetRaidStartTime(raidDate)))
                    updateNeeded = true
                end
            end
        end
    end

    -- leaveTime
    for playerName, t in pairs(GRA_Logs[raidDate]["attendances"]) do
        if not GRA_Logs[raidDate]["attendances"][playerName][4]
            and GRA_Logs[raidDate]["attendances"][playerName][3]
            and not (UnitInParty(F.GetShortName(playerName)) or UnitInRaid(F.GetShortName(playerName))) then
            -- 记录离团时间，并更新出勤
            GRA_Logs[raidDate]["attendances"][playerName][4] = time()
            GRA_Logs[raidDate]["attendances"][playerName][1] = F.CheckAttendanceStatus(GRA_Logs[raidDate]["attendances"][playerName][3], select(2, F.GetRaidStartTime(raidDate)), GRA_Logs[raidDate]["attendances"][playerName][4], select(2, F.GetRaidEndTime(raidDate)))
            updateNeeded = true
        end
    end

    if updateNeeded then
        -- refresh sheet and logs
        GRA.Fire("GRA_RAIDLOGS", raidDate)
    end
end

---------------------------------------------------------------------
-- start/stop tracking
---------------------------------------------------------------------
function F.StartTracking(instanceName, difficultyName)
    local cb
    raidDate = F.Date()

    local text = L["Keep track of boss kills and attendances during this raid session?"]
    if instanceName and difficultyName then
        text = text.."\n|cff909090"..L["Raid: "]..instanceName.." "..difficultyName
    end

    F.CreateStaticPopup(L["Track This Raid"], text, function()
        if F.Getn(GRA_Roster) == 0 then -- no member
            GRA.Print(L["In order to start tracking, you have to import members in Config."])
            return
        end
        if not cb or not cb:GetChecked() then -- new raid (no raid log before)
            GRA.Print(L["Raid tracking has started."])
            GRA_Config["lastRaidDate"] = raidDate
        else
            -- resume last raid
            raidDate = GRA_Config["lastRaidDate"]
            GRA.Print(L["Resumed last raid (%s)."]:format(date("%x", F.DateToSeconds(raidDate))))
        end

        -- init date
        if not GRA_Logs[raidDate] then
            GRA_Logs[raidDate] = {["attendances"]={}, ["details"]={}, ["bosses"]={}}
            -- init all members with "ABSENT"
            for n, t in pairs(GRA_Roster) do
                GRA_Logs[raidDate]["attendances"][n] = {"ABSENT"}
            end
            -- init note
            if instanceName and difficultyName then
                GRA_Logs[raidDate]["note"] = instanceName.." "..difficultyName
            end
            -- init raid hours
            GRA_Logs[raidDate]["startTime"] = select(2, F.GetRaidStartTime(raidDate))
            GRA_Logs[raidDate]["endTime"] = select(2, F.GetRaidEndTime(raidDate))
        end

        RaidRosterUpdate() -- scan raid for attendance
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        eventFrame:RegisterEvent("ENCOUNTER_START")
        eventFrame:RegisterEvent("ENCOUNTER_END")
        GRA.Fire("GRA_TRACK", raidDate)
        GRA.Fire("GRA_RAIDLOGS", raidDate)
        GRA.vars.isTracking = true
        GRA.vars.trackingDate = raidDate

        if cb then cb:Hide() end
    end, function()
        if cb then cb:Hide() end
        eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        eventFrame:UnregisterEvent("ENCOUNTER_START")
        eventFrame:UnregisterEvent("ENCOUNTER_END")
        GRA.Fire("GRA_TRACK")
        GRA.vars.isTracking = nil
        GRA.vars.trackingDate = nil
    end)

    if GRA_Config["lastRaidDate"] and GRA_Config["lastRaidDate"] ~= raidDate then
        cb = F.CreateCheckButton(GRA.vars.staticPopup, L["Resume last raid"], nil, function()
        end, "GRA_FONT_SMALL")
        cb:SetPoint("BOTTOMLEFT", 2, 2)
    end
end

-- manually stop tracking
function F.StopTracking(force)
    if not force then
        local text = L["Stop tracking boss kills and attendances?"]
        F.CreateStaticPopup(L["Stop Tracking"], text, function()
            GRA.Print(L["Raid tracking has stopped."])
            eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
            eventFrame:UnregisterEvent("ENCOUNTER_START")
            eventFrame:UnregisterEvent("ENCOUNTER_END")
            GRA.Fire("GRA_TRACK")
            GRA.vars.isTracking = false
            GRA.vars.trackingDate = nil
            wipe(encounterInfo)
        end)
    else
        GRA.Print(L["Raid tracking has stopped."])
        eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        eventFrame:UnregisterEvent("ENCOUNTER_START")
        eventFrame:UnregisterEvent("ENCOUNTER_END")
        GRA.Fire("GRA_TRACK")
        GRA.vars.isTracking = nil
        GRA.vars.trackingDate = nil
        wipe(encounterInfo)
    end
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
GRA.RegisterCallback("GRA_PERMISSION", "Track_CheckPermissions", function(isAdmin)
    if isAdmin then
        eventFrame:PLAYER_ENTERING_WORLD()
    end
end)

-- check permission and ask whether to track
function eventFrame:PLAYER_ENTERING_WORLD()
    if IsInGuild() and GRA.vars.isAdmin == nil then -- check permission
        F.CheckPermissions()
    elseif GRA.vars.isAdmin then -- track?
        local name, instanceType, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
        if not GRA.vars.isTracking and instanceType == "raid" and difficulty ~= 17 and IsInRaid() then -- and UnitIsGroupLeader("player")
            F.StartTracking(name, difficultyName)
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
        GRA.Print(L["Raid tracking has stopped."])
        GRA.Fire("GRA_TRACK")
        GRA.vars.isTracking = nil
        GRA.vars.trackingDate = nil
        wipe(encounterInfo)
    end
end

function eventFrame:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
    -- local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(difficultyID)
    encounterID = encounterID..difficultyID
    local startTime = time()
    if not encounterInfo[encounterID] then -- first pull
        encounterInfo[encounterID] = {encounterName, difficultyID, startTime, startTime, nil, 0}
    else -- pull after wipe
        encounterInfo[encounterID][3] = startTime
    end
end

function eventFrame:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
    encounterID = encounterID .. difficultyID

    -- search in SV
    local index = 0
    for i, bt in ipairs(GRA_Logs[raidDate]["bosses"]) do
        if bt[1] == encounterName and bt[2] == difficultyID then
            index = i
            break
        end
    end

    local endTime = time()
    if not encounterInfo[encounterID] then -- disconnected
        if index == 0 then -- not in SV, create new
            encounterInfo[encounterID] = {encounterName, difficultyID, nil, nil, endTime, 0}
        else -- load from SV
            encounterInfo[encounterID] = GRA_Logs[raidDate]["bosses"][index]
        end
    else
        if index ~= 0 then
            -- MUST restore start time and wipe count (可能在重载之后开始战斗)
            encounterInfo[encounterID][4] = GRA_Logs[raidDate]["bosses"][index][4]
            encounterInfo[encounterID][6] = GRA_Logs[raidDate]["bosses"][index][6]
        end
        encounterInfo[encounterID][3] = endTime - encounterInfo[encounterID][3] -- duration
    end

    -- update end time and members, always available!
    encounterInfo[encounterID][5] = endTime
    encounterInfo[encounterID][7] = F.GetPlayersInRaid()

    -- wipe
    if success == 0 then
        if encounterInfo[encounterID][3] then
            if encounterInfo[encounterID][3] >= 30 then -- has duration of this pull and fight duration >= 30
                encounterInfo[encounterID][6] = encounterInfo[encounterID][6] + 1
            end
        else -- no start time, consider as wipe
            encounterInfo[encounterID][6] = encounterInfo[encounterID][6] + 1
        end
        encounterInfo[encounterID][3] = nil
    end

    -- save, no matter kill or not
    if index == 0 then
        table.insert(GRA_Logs[raidDate]["bosses"], F.Copy(encounterInfo[encounterID]))
    else
        GRA_Logs[raidDate]["bosses"][index] = {unpack(encounterInfo[encounterID])}
    end
    GRA.Fire("GRA_BOSS", raidDate)

    if success == 1 then
        wipe(encounterInfo[encounterID])
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
