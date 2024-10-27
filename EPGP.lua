---@class GRA
local GRA = select(2, ...)
local L = GRA.L
---@class Funcs
local F = GRA.funcs

local LGN = LibStub:GetLibrary("LibGuildNotes")
local f = CreateFrame("Frame")

---------------------------------------------------------------------
-- get ep and gp
---------------------------------------------------------------------
function F.GetEPGP(name, note)
    if not note then note = LGN:GetOfficerNote(name) or "" end
    local ep, gp = string.split(",", note)
    ep, gp = tonumber(ep), tonumber(gp)
    -- failed to retrieve or LGN not initialized
	if not ep or not gp then
        GRA.Debug(string.format("Retrieve %s's epgp failed, return 0.", name))
		ep = 0
		gp = 0
	end
    return ep, gp
end

-- 用于显示的PR
function F.GetPR(fullName)
    local main = F.IsAlt(fullName)
    if not GRA_Roster[main or fullName] then return 0 end

    local ep = GRA_Roster[main or fullName]["EP"] or 0
    local gp = GRA_Roster[main or fullName]["GP"] or 0
    local pr = (ep == 0) and 0 or (ep/(gp + GRA_Config["raidInfo"]["EPGP"][1]))

    if pr >= 1000 then
        pr = math.ceil(pr)
    elseif pr >= 100 then
        pr = tonumber(string.format("%.1f", pr))
    elseif pr >= 10 then
        pr = tonumber(string.format("%.2f", pr))
    elseif pr >= 1 then
        pr = tonumber(string.format("%.3f", pr))
    else
        pr = tonumber(string.format("%.4f", pr))
    end

    return pr
end

---------------------------------------------------------------------
-- reset
---------------------------------------------------------------------
function F.ResetEPGP()
	local players = F.GetPlayers()
	for _, player in pairs(players) do
		LGN:SetOfficerNote(player, "0,0")
	end
end

---------------------------------------------------------------------
-- decay
---------------------------------------------------------------------
function F.DecayEPGP(p)
    -- local decay = GRA_Config["raidInfo"]["EPGP"][3] / 100
    local decay = p / 100
    local baseGP = GRA_Config["raidInfo"]["EPGP"][1]
    local ep, gp
    for name, _ in pairs(GRA_Roster) do
        ep, gp = F.GetEPGP(name)
        ep = ep - math.ceil(ep * decay)
        gp = gp - math.ceil((baseGP + gp) * decay)
        LGN:SetOfficerNote(name, ep .. "," .. ((gp <= 0) and 0 or gp))
    end
end

---------------------------------------------------------------------
-- epgp undo
---------------------------------------------------------------------
function F.UndoEPGP(epgpDate, index)
    local t = GRA_Logs[epgpDate]["details"][index]

    if t[1] == "EP" then
        for _, n in pairs(t[4]) do
            local epOld, gp = F.GetEPGP(n)
            LGN:SetOfficerNote(n, (epOld - t[2]) .. "," .. gp)
            F.SendEntryMsg(L["EP Undo"], n, t[2], t[3])
        end
    else
        local main = F.IsAlt(t[4])
        local ep, gpOld = F.GetEPGP(main or t[4])
        LGN:SetOfficerNote(main or t[4], ep .. "," .. (gpOld - t[2]))
        F.SendEntryMsg(L["GP Undo"], t[4], t[2], t[3])
    end

    table.remove(GRA_Logs[epgpDate]["details"], index)
    GRA.Fire("GRA_ENTRY_UNDO", epgpDate)
end

---------------------------------------------------------------------
-- ep award/modify
---------------------------------------------------------------------
function F.AwardEP(epDate, ep, reason, players)
    -- set officer note
    for _, name in pairs(players) do
        local epOld, gp = F.GetEPGP(name)
        LGN:SetOfficerNote(name, ((ep + epOld > 0) and (ep + epOld) or 0) .. "," .. gp)
        F.SendEntryMsg(L["EP Award"], name, ep, reason)
    end

    -- add to GRA_Logs
    local epTable = {"EP", ep, reason, players}
    table.insert(GRA_Logs[epDate]["details"], epTable)

    GRA.Fire("GRA_ENTRY", epDate)
end

function F.ModifyEP(epDate, ep, reason, players, index)
    local t = GRA_Logs[epDate]["details"][index]
    local changes = {}

    -- modify exist
    for _, n in pairs(t[4]) do
        if F.TContains(players, n) then -- ep changed
            changes[n] = ep - t[2]
            F.SendEntryMsg(L["EP Modify"], n, ep, reason)
        else -- ep undo
            changes[n] = -t[2]
            F.SendEntryMsg(L["EP Undo"], n, t[2], reason)
        end
    end

    -- add new
    for _, n in pairs(players) do
        if not changes[n] then
            changes[n] = ep
            F.SendEntryMsg(L["EP Award"], n, ep, reason)
        end
    end

    -- set officer note
    for n, epChange in pairs(changes) do
        local epOld, gp = F.GetEPGP(n)
        LGN:SetOfficerNote(n, ((epChange + epOld > 0) and (epChange + epOld) or 0) .. "," .. gp)
    end

    GRA_Logs[epDate]["details"][index] = {"EP", ep, reason, players}
    GRA.Fire("GRA_ENTRY_MODIFY", epDate)
end

---------------------------------------------------------------------
-- gp credit/modify
---------------------------------------------------------------------
function F.CreditGP(gpDate, gp, reason, looter, note)
    local main = F.IsAlt(looter)
    -- set officer note
    local ep, gpOld = F.GetEPGP(main or looter)
    LGN:SetOfficerNote(main or looter, ep .. "," .. (gp + gpOld))
    F.SendEntryMsg(L["GP Credit"], looter, gp, reason)

    -- add to GRA_Logs
    local gpTable = {"GP", gp, reason, looter, note}
    table.insert(GRA_Logs[gpDate]["details"], gpTable)

    GRA.Fire("GRA_ENTRY", gpDate)
end

function F.ModifyGP(gpDate, gp, reason, looter, note, index)
    local main = F.IsAlt(looter)
    local t = GRA_Logs[gpDate]["details"][index]
    local previousMain = F.IsAlt(t[4])

    -- same looter, main -> alt, alt -> main, alt -> alt
    if t[4] == looter or t[4] == main or previousMain == looter or (main and previousMain and main == previousMain) then
        local ep, gpOld = F.GetEPGP(main or looter)
        LGN:SetOfficerNote(main or looter, ep .. "," .. (gpOld + (gp - t[2])))
        F.SendEntryMsg(L["GP Modify"], looter, gp, reason)
    else -- change looter
        -- undo previous looter
        local ep, gpOld = F.GetEPGP(previousMain or t[4])
        LGN:SetOfficerNote(previousMain or t[4], ep .. "," .. (gpOld - t[2]))
        F.SendEntryMsg(L["GP Undo"], t[4], t[2], t[3])
        -- change to new looter
        ep, gpOld = F.GetEPGP(main or looter)
        LGN:SetOfficerNote(main or looter, ep .. "," .. (gpOld + gp))
        F.SendEntryMsg(L["GP Credit"], looter, gp, reason)
    end

    GRA_Logs[gpDate]["details"][index] = {"GP", gp, reason, looter, note}
    GRA.Fire("GRA_ENTRY_MODIFY", gpDate)
end

---------------------------------------------------------------------
-- penalize
---------------------------------------------------------------------
function F.PenalizeEPGP(pDate, pType, value, reason, players)
    if pType == "PEP" then
        value = -value
        -- set officer note
        for _, name in pairs(players) do
            local epOld, gp = F.GetEPGP(name)
            LGN:SetOfficerNote(name, ((value + epOld > 0) and (value + epOld) or 0) .. "," .. gp)
            F.SendEntryMsg(L["EP Penalize"], name, value, reason)
        end
    else -- PGP
        for _, name in pairs(players) do
            local ep, gpOld = F.GetEPGP(name)
            LGN:SetOfficerNote(name, ep .. "," .. (gpOld + value))
            F.SendEntryMsg(L["GP Penalize"], name, value, reason)
        end
    end

    -- add to GRA_Logs
    local pTable = {pType, value, reason, players}
    table.insert(GRA_Logs[pDate]["details"], pTable)
    GRA.Fire("GRA_ENTRY", pDate)
end

function F.ModifyPenalizeEPGP(pDate, pType, value, reason, players, index)
    local changes = {}
    -- undo all
    local t = GRA_Logs[pDate]["details"][index]
    if t[1] == "PEP" then
        for _, n in pairs(t[4]) do
            changes[n] = {}
            changes[n]["EP"] = -t[2]
            F.SendEntryMsg(L["EP Penalize Undo"], n, t[2], t[3])
        end
    else
        for _, n in pairs(t[4]) do
            changes[n] = {}
            changes[n]["GP"] = -t[2]
            F.SendEntryMsg(L["GP Penalize Undo"], n, t[2], t[3])
        end
    end

    -- penalize!
    if pType == "PEP" then
        value = -value
        for _, n in pairs(players) do
            if not changes[n] then changes[n] = {} end
            changes[n]["EP"] = (changes[n]["EP"] or 0) + value
            F.SendEntryMsg(L["EP Penalize"], n, value, reason)
        end
    else -- PGP
        for _, n in pairs(players) do
            if not changes[n] then changes[n] = {} end
            changes[n]["GP"] = (changes[n]["GP"] or 0) + value
            F.SendEntryMsg(L["GP Penalize"], n, value, reason)
        end
    end

    -- set note!
    -- texplore(changes)
    for n, change in pairs(changes) do
        local epOld, gpOld = F.GetEPGP(n)
        local epNew = (change["EP"] or 0) + epOld
        local gpNew = (change["GP"] or 0) + gpOld
        LGN:SetOfficerNote(n, ((epNew > 0) and epNew or 0) .. "," .. gpNew)
    end

    GRA_Logs[pDate]["details"][index] = {pType, value, reason, players}
    GRA.Fire("GRA_ENTRY_MODIFY", pDate)
end

function F.UndoPenalizeEPGP(pDate, index)
    local t = GRA_Logs[pDate]["details"][index]

    if t[1] == "PEP" then
        for _, n in pairs(t[4]) do
            local epOld, gp = F.GetEPGP(n)
            LGN:SetOfficerNote(n, (epOld - t[2]) .. "," .. gp)
            F.SendEntryMsg(L["EP Penalize Undo"], n, t[2], t[3])
        end
    else
        for _, n in pairs(t[4]) do
            local ep, gpOld = F.GetEPGP(n)
            LGN:SetOfficerNote(n, ep .. "," .. (gpOld - t[2]))
            F.SendEntryMsg(L["GP Penalize Undo"], n, t[2], t[3])
        end
    end

    table.remove(GRA_Logs[pDate]["details"], index)
    GRA.Fire("GRA_ENTRY_UNDO", pDate)
end


---------------------------------------------------------------------
-- update & init epgp
---------------------------------------------------------------------
-- update roster EP and GP when officer note changed
local function UpdateRosterEPGP(event, name, note)
    if not GRA_Roster[name] then return end

    local ep, gp = F.GetEPGP(name, note)
    GRA_Roster[name]["EP"] = ep
    GRA_Roster[name]["GP"] = gp

    -- update attendance sheet
    F.UpdatePlayerData_EPGP(name, ep, gp)

    if event then -- not from InitRosterEPGP()
        -- GRA.Debug("|cff66CD00GUILD_OFFICER_NOTE_CHANGED:|r " .. name .. " " .. note)
    end
end

-- update roster EP and GP when log in
local function InitRosterEPGP()
    GRA.Debug("|cff1E90FFInitRosterEPGP...")
    for name, _ in pairs(GRA_Roster) do
        UpdateRosterEPGP(nil, name, LGN:GetOfficerNote(name))
    end
end

-- update sheet & GRA_Roster, check whether update them automatically
function F.UpdateRosterEPGP()
    if F.Getn(GRA_Roster) ~= 0 then -- has member
        InitRosterEPGP()
        -- update roster EP and GP when officer note changed
        LGN.RegisterCallback(f, "GUILD_OFFICER_NOTE_CHANGED", UpdateRosterEPGP)
        GRA.Debug("|cff1E90FFRegisterCallback |cff66CD00GUILD_OFFICER_NOTE_CHANGED")
    else -- no member
        LGN.UnregisterCallback(f, "GUILD_OFFICER_NOTE_CHANGED")
        GRA.Debug("|cffFF3030UnregisterCallback |cff66CD00GUILD_OFFICER_NOTE_CHANGED|r no member")
    end
end

-- f:RegisterEvent("ADDON_LOADED")
-- f:SetScript("OnEvent", function(self, event, arg)
--     if arg == addonName then
--         if GRA_Config["raidInfo"]["system"] == "EPGP" then
--             LGN.RegisterCallback(f, "GUILD_NOTE_INITIALIZED", F.UpdateRosterEPGP)
--             GRA.Debug("ADDON_LOADED EPGP enabled.")
--         else
--             GRA.Debug("ADDON_LOADED EPGP disabled.")
--         end
--     end
-- end)

function F.SetEPGPEnabled(enabled)
    if enabled then
        GRA.Print(L["EPGP enabled."])
        LGN.RegisterCallback(f, "GUILD_NOTE_INITIALIZED", GRA.UpdateRosterEPGP)
        -- disable dkp
        F.UnregisterAllCallbacks_DKP()
        -- init
        LGN:Reinitialize()
        GRA.Fire("GRA_SYSTEM", "EPGP")
    else
        GRA.Print(L["EPGP disabled."])
        GRA.Fire("GRA_SYSTEM", "")
    end
end

-- used by DKP
function F.UnregisterAllCallbacks_EPGP()
    LGN.UnregisterAllCallbacks(f)
end

function F.RefreshEPGP()
    LGN.RegisterCallback(f, "GUILD_NOTE_REFRESHED", InitRosterEPGP)
    LGN:ForceRefresh()
end

-- f:SetScript("OnEvent", function(self, event, ...)
-- 	self[event](self, ...)
-- end)