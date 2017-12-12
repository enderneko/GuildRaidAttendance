local addonName, E = ...
local GRA, gra = unpack(E)
local L = select(2, ...).L

local LGN = LibStub:GetLibrary("LibGuildNotes")
local f = CreateFrame("Frame")

-----------------------------------------
-- get ep and gp
-----------------------------------------
function GRA:GetEPGP(name, note)
    if not note then note = LGN:GetOfficerNote(name) end
    if not note then note = "" end
    local ep, gp = string.split(",", note)
    ep, gp = tonumber(ep), tonumber(gp)
    -- failed to retrieve or LGN not initialized
	if not ep or not gp then
        GRA:Debug(string.format("Retrieve %s's epgp failed, return 0.", name))
		ep = 0
		gp = 0
	end
    return ep, gp
end

-- 用于显示的PR
function GRA:GetPR(fullName)
    if not _G[GRA_R_Roster][fullName] then return 0 end

    local ep = _G[GRA_R_Roster][fullName]["EP"] or 0
    local gp = _G[GRA_R_Roster][fullName]["GP"] or 0
    local pr = (ep == 0) and 0 or (ep/(gp + _G[GRA_R_Config]["raidInfo"]["EPGP"][1]))

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

-----------------------------------------
-- decay
-----------------------------------------
function GRA:Decay(p)
    -- local decay = _G[GRA_R_Config]["raidInfo"]["EPGP"][3] / 100
    local decay = p / 100
    local baseGP = _G[GRA_R_Config]["raidInfo"]["EPGP"][1]
    local ep, gp
    for name, _ in pairs(_G[GRA_R_Roster]) do
        ep, gp = GRA:GetEPGP(name)
        ep = ep - math.ceil(ep * decay)
        gp = gp - math.ceil((baseGP + gp) * decay)
        LGN:SetOfficerNote(name, ep .. "," .. ((gp <= 0) and 0 or gp))
    end
end

-----------------------------------------
-- epgp undo
-----------------------------------------
function GRA:UndoEPGP(epgpDate, index)
    local t = _G[GRA_R_RaidLogs][epgpDate]["details"][index]
    
    if t[1] == "EP" then
        for _, n in pairs(t[4]) do
            local epOld, gp = GRA:GetEPGP(n)
            LGN:SetOfficerNote(n, (epOld - t[2]) .. "," .. gp)
            GRA:SendEPGPMsg(L["EP Undo"], n, t[2], t[3])
        end
    else
        local ep, gpOld = GRA:GetEPGP(t[4])
        LGN:SetOfficerNote(t[4], ep .. "," .. (gpOld - t[2]))
        GRA:SendEPGPMsg(L["GP Undo"], t[4], t[2], t[3])
    end

    table.remove(_G[GRA_R_RaidLogs][epgpDate]["details"], index)
    GRA:FireEvent("GRA_EPGP_UNDO", epgpDate)
end

-----------------------------------------
-- ep award/modify
-----------------------------------------
function GRA:AwardEP(epDate, ep, reason, players)
    -- set officer note
    for _, name in pairs(players) do
        local epOld, gp = GRA:GetEPGP(name)
        LGN:SetOfficerNote(name, ((ep + epOld > 0) and (ep + epOld) or 0) .. "," .. gp)
        GRA:SendEPGPMsg(L["EP Award"], name, ep, reason)
    end
    
    -- add to _G[GRA_R_RaidLogs]
    local epTable = {"EP", ep, reason, players}
    table.insert(_G[GRA_R_RaidLogs][epDate]["details"], epTable)

    GRA:FireEvent("GRA_EPGP", epDate)
end

function GRA:ModifyEP(epDate, ep, reason, players, index)
    local t = _G[GRA_R_RaidLogs][epDate]["details"][index]
    local changes = {}

    -- modify exist
    for _, n in pairs(t[4]) do
        if tContains(players, n) then -- ep changed
            changes[n] = ep - t[2]
            GRA:SendEPGPMsg(L["EP Modify"], n, ep, reason)
        else -- ep undo
            changes[n] = -t[2]
            GRA:SendEPGPMsg(L["EP Undo"], n, t[2], reason)
        end
    end

    -- add new
    for _, n in pairs(players) do
        if not changes[n] then
            changes[n] = ep
            GRA:SendEPGPMsg(L["EP Award"], n, ep, reason)
        end
    end

    -- set officer note
    for n, epChange in pairs(changes) do
        local epOld, gp = GRA:GetEPGP(n)
        LGN:SetOfficerNote(n, ((epChange + epOld > 0) and (epChange + epOld) or 0) .. "," .. gp)
    end

    _G[GRA_R_RaidLogs][epDate]["details"][index] = {"EP", ep, reason, players}
    GRA:FireEvent("GRA_EPGP_MODIFY", epDate)
end

-----------------------------------------
-- gp credit/modify
-----------------------------------------
function GRA:CreditGP(gpDate, gp, reason, looter)
    -- set officer note
    local ep, gpOld = GRA:GetEPGP(looter)
    LGN:SetOfficerNote(looter, ep .. "," .. (gp + gpOld))
    GRA:SendEPGPMsg(L["GP Credit"], looter, gp, reason)

    -- add to _G[GRA_R_RaidLogs]
    local gpTable = {"GP", gp, reason, looter}
    table.insert(_G[GRA_R_RaidLogs][gpDate]["details"], gpTable)

    GRA:FireEvent("GRA_EPGP", gpDate)
end

function GRA:ModifyGP(gpDate, gp, reason, looter, index)
    local t = _G[GRA_R_RaidLogs][gpDate]["details"][index]
    
    if t[4] == looter then -- same looter, modify gp only
        local ep, gpOld = GRA:GetEPGP(looter)
        LGN:SetOfficerNote(looter, ep .. "," .. (gpOld + (gp - t[2])))
        GRA:SendEPGPMsg(L["GP Modify"], looter, gp, reason)
    else -- change looter
        -- undo previous looter
        local ep, gpOld = GRA:GetEPGP(t[4])
        LGN:SetOfficerNote(t[4], ep .. "," .. (gpOld - t[2]))
        GRA:SendEPGPMsg(L["GP Undo"], t[4], t[2], t[3])
        -- change to new looter
        ep, gpOld = GRA:GetEPGP(looter)
        LGN:SetOfficerNote(looter, ep .. "," .. (gpOld + gp))
        GRA:SendEPGPMsg(L["GP Credit"], looter, gp, reason)
    end

    _G[GRA_R_RaidLogs][gpDate]["details"][index] = {"GP", gp, reason, looter}
    GRA:FireEvent("GRA_EPGP_MODIFY", gpDate)
end

-----------------------------------------
-- penalize
-----------------------------------------
function GRA:Penalize(pDate, pType, value, reason, players)
    if pType == "PEP" then
        value = -value
        -- set officer note
        for _, name in pairs(players) do
            local epOld, gp = GRA:GetEPGP(name)
            LGN:SetOfficerNote(name, ((value + epOld > 0) and (value + epOld) or 0) .. "," .. gp)
            GRA:SendEPGPMsg(L["EP Penalize"], name, value, reason)
        end
    else -- PGP
        for _, name in pairs(players) do
            local ep, gpOld = GRA:GetEPGP(name)
            LGN:SetOfficerNote(name, ep .. "," .. (gpOld + value))
            GRA:SendEPGPMsg(L["GP Penalize"], name, value, reason)
        end
    end
    
    -- add to _G[GRA_R_RaidLogs]
    local pTable = {pType, value, reason, players}
    table.insert(_G[GRA_R_RaidLogs][pDate]["details"], pTable)
    GRA:FireEvent("GRA_EPGP", pDate)
end

function GRA:ModifyPenalize(pDate, pType, value, reason, players, index)
    local changes = {}
    -- undo all
    local t = _G[GRA_R_RaidLogs][pDate]["details"][index]
    if t[1] == "PEP" then
        for _, n in pairs(t[4]) do
            changes[n] = {}
            changes[n]["EP"] = -t[2]
            GRA:SendEPGPMsg(L["EP Penalize Undo"], n, t[2], t[3])
        end
    else
        for _, n in pairs(t[4]) do
            changes[n] = {}
            changes[n]["GP"] = -t[2]
            GRA:SendEPGPMsg(L["GP Penalize Undo"], n, t[2], t[3])
        end
    end

    -- penalize!
    if pType == "PEP" then
        value = -value
        for _, n in pairs(players) do
            if not changes[n] then changes[n] = {} end
            changes[n]["EP"] = (changes[n]["EP"] or 0) + value
            GRA:SendEPGPMsg(L["EP Penalize"], n, value, reason)
        end
    else -- PGP
        for _, n in pairs(players) do
            if not changes[n] then changes[n] = {} end
            changes[n]["GP"] = (changes[n]["GP"] or 0) + value
            GRA:SendEPGPMsg(L["GP Penalize"], n, value, reason)
        end
    end

    -- set note!
    -- texplore(changes)
    for n, change in pairs(changes) do
        local epOld, gpOld = GRA:GetEPGP(n)
        local epNew = (change["EP"] or 0) + epOld
        local gpNew = (change["GP"] or 0) + gpOld
        LGN:SetOfficerNote(n, ((epNew > 0) and epNew or 0) .. "," .. gpNew)
    end
        
    _G[GRA_R_RaidLogs][pDate]["details"][index] = {pType, value, reason, players}
    GRA:FireEvent("GRA_EPGP_MODIFY", pDate)
end

function GRA:UndoPenalize(pDate, index)
    local t = _G[GRA_R_RaidLogs][pDate]["details"][index]
    
    if t[1] == "PEP" then
        for _, n in pairs(t[4]) do
            local epOld, gp = GRA:GetEPGP(n)
            LGN:SetOfficerNote(n, (epOld - t[2]) .. "," .. gp)
            GRA:SendEPGPMsg(L["EP Penalize Undo"], n, t[2], t[3])
        end
    else
        for _, n in pairs(t[4]) do
            local ep, gpOld = GRA:GetEPGP(n)
            LGN:SetOfficerNote(n, ep .. "," .. (gpOld - t[2]))
            GRA:SendEPGPMsg(L["GP Penalize Undo"], n, t[2], t[3])
        end
    end

    table.remove(_G[GRA_R_RaidLogs][pDate]["details"], index)
    GRA:FireEvent("GRA_EPGP_UNDO", pDate)
end


-----------------------------------------
-- update & init epgp
-----------------------------------------
-- update roster EP and GP when officer note changed
local function UpdateRosterEPGP(event, name, note)
    if not _G[GRA_R_Roster][name] then return end

    local ep, gp = GRA:GetEPGP(name, note)
    _G[GRA_R_Roster][name]["EP"] = ep
    _G[GRA_R_Roster][name]["GP"] = gp

    -- update attendance sheet
    GRA:UpdatePlayerData(name, ep, gp)

    if event then -- not from InitRosterEPGP()
        -- GRA:Debug("|cff66CD00GUILD_OFFICER_NOTE_CHANGED:|r " .. name .. " " .. note)
    end
end

-- update roster EP and GP when log in
local function InitRosterEPGP()
    for name, _ in pairs(_G[GRA_R_Roster]) do
        UpdateRosterEPGP(nil, name, LGN:GetOfficerNote(name))
    end
end

-- update sheet & _G[GRA_R_Roster], check whether update them automatically
function GRA:UpdateRosterEPGP()
    if GRA:Getn(_G[GRA_R_Roster]) ~= 0 then -- has member
        InitRosterEPGP()
        -- update roster EP and GP when officer note changed
        LGN.RegisterCallback(f, "GUILD_OFFICER_NOTE_CHANGED", UpdateRosterEPGP)
        GRA:Debug("|cff1E90FFRegisterCallback |cff66CD00GUILD_OFFICER_NOTE_CHANGED")
    else -- no member
        LGN.UnregisterCallback(f, "GUILD_OFFICER_NOTE_CHANGED")
        GRA:Debug("|cffFF3030UnregisterCallback |cff66CD00GUILD_OFFICER_NOTE_CHANGED|r no member")
    end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg)
    if arg == addonName then
        if _G[GRA_R_Config]["system"] == "EPGP" then
            LGN.RegisterCallback(f, "GUILD_NOTE_INITIALIZED", GRA.UpdateRosterEPGP)
            GRA:Debug("ADDON_LOADED EPGP enabled.")
        else
            GRA:Debug("ADDON_LOADED EPGP enabled.")
        end
    end
end)

function GRA:SetEPGPEnabled(enabled)
    if enabled then
        GRA:Print(L["EPGP enabled."])
        LGN.RegisterCallback(f, "GUILD_NOTE_INITIALIZED", GRA.UpdateRosterEPGP)
        -- init
        LGN:Reinitialize()
        GRA:FireEvent("GRA_SYSTEM", "EPGP")
    else
        GRA:Print(L["EPGP disabled."])
        GRA:FireEvent("GRA_SYSTEM", "NONE")
    end
end

function GRA:RefreshEPGP()
    LGN.RegisterCallback(f, "GUILD_NOTE_REFRESHED", InitRosterEPGP)
    LGN:ForceRefresh()
end

-- f:SetScript("OnEvent", function(self, event, ...)
-- 	self[event](self, ...)
-- end)