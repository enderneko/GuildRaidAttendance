local addonName, E = ...
local GRA, gra = unpack(E)
local L = select(2, ...).L

local LGN = LibStub:GetLibrary("LibGuildNotes")
local f = CreateFrame("Frame")

-----------------------------------------
-- get dkp
-----------------------------------------
function GRA:GetDKP(name, note)
    local main = GRA:IsAlt(name)
    if not note then note = LGN:GetOfficerNote(main or name) or "" end
    local current, spent, total = string.split(",", note)
    current, spent, total = tonumber(current), tonumber(spent), tonumber(total)
    -- failed to retrieve or LGN not initialized
	if not current or not spent or not total then
        GRA:Debug(string.format("Retrieve %s's dkp failed, return 0.", main or name))
		current = 0
        spent = 0
        total = 0
	end
    return current, spent, total
end

-----------------------------------------
-- reset
-----------------------------------------
function GRA:ResetDKP()
	local players = GRA:GetPlayers()
	for _, player in pairs(players) do
		LGN:SetOfficerNote(player, "0,0,0")
	end
end

-----------------------------------------
-- decay
-----------------------------------------
function GRA:DecayDKP(p)
    local decay = p / 100
    local current, spent, total
    for name, _ in pairs(_G[GRA_R_Roster]) do
        current, spent, total = GRA:GetDKP(name)
        current = current - math.ceil(current * decay)
        LGN:SetOfficerNote(name, current .. "," .. spent .. "," .. total)
    end
end

-----------------------------------------
-- dkp undo
-----------------------------------------
function GRA:UndoDKP(dkpDate, index)
    local t = _G[GRA_R_RaidLogs][dkpDate]["details"][index]
    
    if t[1] == "DKP_A" then
        for _, n in pairs(t[4]) do
            local current, spent, total = GRA:GetDKP(n)
            LGN:SetOfficerNote(n, (current - t[2]) .. "," .. spent .. "," .. (total - t[2]))
            GRA:SendEntryMsg(L["DKP Undo"], n, t[2], t[3])
        end
    else -- DKP_C
        local main = GRA:IsAlt(t[4])
        local current, spent, total = GRA:GetDKP(main or t[4])
        LGN:SetOfficerNote(main or t[4], (current - t[2]) .. "," .. (spent + t[2]) .. "," .. total)
        GRA:SendEntryMsg(L["DKP Undo"], t[4], t[2], t[3])
    end

    table.remove(_G[GRA_R_RaidLogs][dkpDate]["details"], index)
    GRA:FireEvent("GRA_ENTRY_UNDO", dkpDate)
end

-----------------------------------------
-- dkp award/modify
-----------------------------------------
function GRA:AwardDKP(dkpDate, dkp, reason, players, note)
    -- set officer note
    for _, name in pairs(players) do
        local current, spent, total = GRA:GetDKP(name)
        LGN:SetOfficerNote(name, (current + dkp) .. "," .. spent .. "," .. (total + dkp))
        GRA:SendEntryMsg(L["DKP Award"], name, dkp, reason)
    end
    
    -- add to _G[GRA_R_RaidLogs]
    local dkpTable = {"DKP_A", dkp, reason, players, note}
    table.insert(_G[GRA_R_RaidLogs][dkpDate]["details"], dkpTable)

    GRA:FireEvent("GRA_ENTRY", dkpDate)
end

function GRA:ModifyDKP_A(dkpDate, dkp, reason, players, index)
    local t = _G[GRA_R_RaidLogs][dkpDate]["details"][index]
    local changes = {}

    -- modify exist
    for _, n in pairs(t[4]) do
        if GRA:TContains(players, n) then -- dkp changed
            changes[n] = dkp - t[2]
            GRA:SendEntryMsg(L["DKP Modify"], n, dkp, reason)
        else -- dkp undo
            changes[n] = -t[2]
            GRA:SendEntryMsg(L["DKP Undo"], n, t[2], reason)
        end
    end

    -- add new
    for _, n in pairs(players) do
        if not changes[n] then
            changes[n] = dkp
            GRA:SendEntryMsg(L["DKP Award"], n, dkp, reason)
        end
    end

    -- set officer note
    for n, dkpChange in pairs(changes) do
        local current, spent, total = GRA:GetDKP(n)
        LGN:SetOfficerNote(n, (dkpChange + current) .. "," .. spent .. "," .. (dkpChange + total))
    end

    _G[GRA_R_RaidLogs][dkpDate]["details"][index] = {"DKP_A", dkp, reason, players}
    GRA:FireEvent("GRA_ENTRY_MODIFY", dkpDate)
end

-----------------------------------------
-- dkp credit/modify
-----------------------------------------
function GRA:CreditDKP(dkpDate, dkp, reason, looter, note)
    local main = GRA:IsAlt(looter)
    dkp = -dkp
    -- set officer note
    local current, spent, total = GRA:GetDKP(main or looter)
    LGN:SetOfficerNote(main or looter, (current + dkp) .. "," .. (spent - dkp) .. "," .. total)
    GRA:SendEntryMsg(L["DKP Credit"], looter, dkp, reason)

    -- add to _G[GRA_R_RaidLogs]
    local dkpTable = {"DKP_C", dkp, reason, looter, note}
    table.insert(_G[GRA_R_RaidLogs][dkpDate]["details"], dkpTable)

    GRA:FireEvent("GRA_ENTRY", dkpDate)
end

function GRA:ModifyDKP_C(dkpDate, dkp, reason, looter, note, index)
    dkp = -dkp
    local t = _G[GRA_R_RaidLogs][dkpDate]["details"][index]
    local main = GRA:IsAlt(looter)
    local previousMain = GRA:IsAlt(t[4])
    
    -- same looter, main -> alt, alt -> main, alt -> alt
    if t[4] == looter or t[4] == main or previousMain == looter or (main and previousMain and main == previousMain) then
        local current, spent, total = GRA:GetDKP(main or looter)
        local change = dkp - t[2]
        LGN:SetOfficerNote(main or looter, (current + change) .. "," .. (spent - change) .. "," .. total)
        GRA:SendEntryMsg(L["DKP Modify"], looter, dkp, reason)
    else -- change looter
        -- undo previous looter
        local current, spent, total = GRA:GetDKP(previousMain or t[4])
        LGN:SetOfficerNote(previousMain or t[4], (current - t[2]) .. "," .. (spent + t[2]) .. "," .. total)
        GRA:SendEntryMsg(L["DKP Undo"], t[4], t[2], t[3])
        -- change to new looter
        current, spent, total = GRA:GetDKP(main or looter)
        LGN:SetOfficerNote(main or looter, (current + dkp) .. "," .. (spent - dkp) .. "," .. total)
        GRA:SendEntryMsg(L["DKP Credit"], looter, dkp, reason)
    end

    _G[GRA_R_RaidLogs][dkpDate]["details"][index] = {"DKP_C", dkp, reason, looter, note}
    GRA:FireEvent("GRA_ENTRY_MODIFY", dkpDate)
end

-----------------------------------------
-- penalize
-----------------------------------------
function GRA:PenalizeDKP(pDate, value, reason, players)
    value = -value
    -- set officer note
    for _, name in pairs(players) do
        local current, spent, total = GRA:GetDKP(name)
        LGN:SetOfficerNote(name, (current + value) .. "," .. spent .. "," .. total)
        GRA:SendEntryMsg(L["DKP Penalize"], name, value, reason)
    end
    
    -- add to _G[GRA_R_RaidLogs]
    local pTable = {"DKP_P", value, reason, players}
    table.insert(_G[GRA_R_RaidLogs][pDate]["details"], pTable)
    GRA:FireEvent("GRA_ENTRY", pDate)
end

function GRA:ModifyPenalizeDKP(pDate, value, reason, players, index)
    value = -value
    local changes = {}
    -- undo all
    local t = _G[GRA_R_RaidLogs][pDate]["details"][index]
    for _, n in pairs(t[4]) do
        changes[n] = -t[2]
        GRA:SendEntryMsg(L["DKP Penalize Undo"], n, t[2], t[3])
    end

    -- penalize!
    for _, n in pairs(players) do
        changes[n] = (changes[n] or 0) + value
        GRA:SendEntryMsg(L["DKP Penalize"], n, value, reason)
    end

    -- set note!
    -- texplore(changes)
    for n, change in pairs(changes) do
        local current, spent, total = GRA:GetDKP(n)
        LGN:SetOfficerNote(n, (current + change) .. "," .. spent .. "," .. total)
    end
        
    _G[GRA_R_RaidLogs][pDate]["details"][index] = {"DKP_P", value, reason, players}
    GRA:FireEvent("GRA_ENTRY_MODIFY", pDate)
end

function GRA:UndoPenalizeDKP(pDate, index)
    local t = _G[GRA_R_RaidLogs][pDate]["details"][index]
    
    for _, n in pairs(t[4]) do
        local current, spent, total = GRA:GetDKP(n)
        LGN:SetOfficerNote(n, (current - t[2]) .. "," .. spent .. "," .. total)
        GRA:SendEntryMsg(L["DKP Penalize Undo"], n, t[2], t[3])
    end

    table.remove(_G[GRA_R_RaidLogs][pDate]["details"], index)
    GRA:FireEvent("GRA_ENTRY_UNDO", pDate)
end


-----------------------------------------
-- update & init dkp
-----------------------------------------
-- update roster EP and GP when officer note changed
local function UpdateRosterDKP(event, name, note)
    if not _G[GRA_R_Roster][name] then return end

    local current, spent, total = GRA:GetDKP(name, note)
    _G[GRA_R_Roster][name]["DKP_Current"] = current
    _G[GRA_R_Roster][name]["DKP_Spent"] = spent
    _G[GRA_R_Roster][name]["DKP_Total"] = total

    -- update attendance sheet
    GRA:UpdatePlayerData_DKP(name, current, spent, total)

    if event then -- not from InitRosterDKP()
        -- GRA:Debug("|cff66CD00GUILD_OFFICER_NOTE_CHANGED:|r " .. name .. " " .. note)
    end
end

-- update roster EP and GP when log in
local function InitRosterDKP()
    GRA:Debug("|cff1E90FFInitRosterDKP...")
    for name, _ in pairs(_G[GRA_R_Roster]) do
        UpdateRosterDKP(nil, name, LGN:GetOfficerNote(name))
    end
end

-- update sheet & _G[GRA_R_Roster], check whether update them automatically
function GRA:UpdateRosterDKP()
    if GRA:Getn(_G[GRA_R_Roster]) ~= 0 then -- has member
        InitRosterDKP()
        -- update roster EP and GP when officer note changed
        LGN.RegisterCallback(f, "GUILD_OFFICER_NOTE_CHANGED", UpdateRosterDKP)
        GRA:Debug("|cff1E90FFRegisterCallback |cff66CD00GUILD_OFFICER_NOTE_CHANGED")
    else -- no member
        LGN.UnregisterCallback(f, "GUILD_OFFICER_NOTE_CHANGED")
        GRA:Debug("|cffFF3030UnregisterCallback |cff66CD00GUILD_OFFICER_NOTE_CHANGED|r no member")
    end
end

-- f:RegisterEvent("ADDON_LOADED")
-- f:SetScript("OnEvent", function(self, event, arg)
--     if arg == addonName then
--         if _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
--             LGN.RegisterCallback(f, "GUILD_NOTE_INITIALIZED", GRA.UpdateRosterDKP)
--             GRA:Debug("ADDON_LOADED DKP enabled.")
--         else
--             GRA:Debug("ADDON_LOADED DKP disabled.")
--         end
--     end
-- end)

function GRA:SetDKPEnabled(enabled)
    if enabled then
        GRA:Print(L["DKP enabled."])
        LGN.RegisterCallback(f, "GUILD_NOTE_INITIALIZED", GRA.UpdateRosterDKP)
        -- disable epgp
        GRA:UnregisterAllCallbacks_EPGP()
        -- init
        LGN:Reinitialize()
        GRA:FireEvent("GRA_SYSTEM", "DKP")
    else
        GRA:Print(L["DKP disabled."])
        GRA:FireEvent("GRA_SYSTEM", "")
    end
end

-- used by EPGP
function GRA:UnregisterAllCallbacks_DKP()
    LGN.UnregisterAllCallbacks(f)
end

function GRA:RefreshDKP()
    LGN.RegisterCallback(f, "GUILD_NOTE_REFRESHED", InitRosterDKP)
    LGN:ForceRefresh()
end

-- f:SetScript("OnEvent", function(self, event, ...)
-- 	self[event](self, ...)
-- end)