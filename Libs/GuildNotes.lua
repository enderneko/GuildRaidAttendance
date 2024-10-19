---------------------------------------------------------------------
-- File: GuildNotes.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Modified: 2024-10-19 13:22 +08:00
---------------------------------------------------------------------

local lib = LibStub:NewLibrary("LibGuildNotes", 2)
if not lib then return end

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
--@debug@
local debug = true
--@end-debug@
local function Print(msg, f)
    if debug then
        if f then
            print(msg)
        else
            print("|cffFF3030LibGuildNotes:|r " .. msg)
        end
    end
end

local cache = {}
local updating = false
local initialized, forceRefresh = false, false
local trial

local GetGuildRosterInfo = GetGuildRosterInfo
local GuildRoster = C_GuildInfo.GuildRoster
local GuildRosterSetPublicNote = GuildRosterSetPublicNote
local GuildRosterSetOfficerNote = GuildRosterSetOfficerNote
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function lib.GetPublicNote(name)
    if cache[name] then
        return cache[name].pnote
    end

    Print(name .. " is not in your guild.")
    return nil
end

function lib.GetOfficerNote(name)
    if cache[name] then
        return cache[name].onote
    end

    Print(name .. " is not in your guild.")
    return nil
end

---------------------------------------------------------------------
-- set
---------------------------------------------------------------------
local function SetNote(noteType, name, note)
    if not cache[name] then
        Print(name .. " is not in your guild.")
        return
    end

    local index = cache[name].index

    -- check correctness, make sure it is THE ONE.
    local nameCurrentIndex = GetGuildRosterInfo(index)
    if nameCurrentIndex ~= name then
        -- Print("|cffFF3030-- LibGuildNotes --------------------|r", true)
        -- Print("    Set " .. name .. "'s note failed.", true)
        -- Print("    Name(should be):" .. name, true)
        -- Print("    Name(current index): " .. nameCurrentIndex, true)
        -- Print("|cffFF3030-------------------------------------|r", true)
        Print("Set " .. name .. "'s note failed, retry in 3 sec.")
        trial = C_Timer.NewTimer(1.5, function()
            securecall(GuildRoster)
        end)
        C_Timer.After(3, function()
            SetNote(noteType, name, note, true)
        end)
        return
    end

    if noteType == "public" then
        GuildRosterSetPublicNote(index, note)
        Print("Update " .. name .. "'s public note.")
    elseif noteType == "officer" then
        GuildRosterSetOfficerNote(index, note)
        Print("Update " .. name .. "'s officer note.")
    end
end

function lib.SetPublicNote(name, note)
    if not C_GuildInfo.CanEditPublicNote() then return end

    if not updating then
        SetNote("public", name, note)
    else
        -- retry after 1sec
        local ticker = C_Timer.NewTicker(1, function(ticker)
            if not updating then
                SetNote("public", name, note)
                ticker:Cancel()
            end
        end)
    end
end

function lib.SetOfficerNote(name, note)
    if not C_GuildInfo.CanEditOfficerNote() then return end

    if not updating then
        SetNote("officer", name, note)
    else
        -- retry after 1sec
        local ticker = C_Timer.NewTicker(1, function(ticker)
            if not updating then
                SetNote("officer", name, note)
                ticker:Cancel()
            end
        end)
    end
end

---------------------------------------------------------------------
-- misc
---------------------------------------------------------------------
function lib.IsInGuild(fullname)
    if cache[fullname] then
        return true
    else
        return false
    end
end

function lib.ForceRefresh()
    -- if InCombatLockdown() then return end
    Print("Starting ForceRefresh")
    forceRefresh = true
    securecall(GuildRoster)
    trial = C_Timer.NewTicker(3, function() securecall(GuildRoster) end)
end

function lib.Reinitialize()
    Print("Reinitializing...")
    initialized = false
    securecall(GuildRoster)
    trial = C_Timer.NewTicker(3, function() securecall(GuildRoster) end)
end

---------------------------------------------------------------------
-- event
---------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("GUILD_ROSTER_UPDATE")
f:SetScript("OnEvent", function(self, event)
    if event == "GUILD_ROSTER_UPDATE" then
        local n = GetNumGuildMembers()
        if n ~= 0 then -- get guild roster successful
            if trial then
                trial:Cancel()
                trial = nil
            end

            updating = true

            local fetched = 0
            for i = 1, n do
                -- fullName, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(index)
                local fullName, _, _, _, _, _, pnote, onote = GetGuildRosterInfo(i)
                if fullName then
                    if not cache[fullName] then
                        cache[fullName] = {}
                    end
                    if cache[fullName].pnote and pnote ~= cache[fullName].pnote then
                        lib.callbacks:Fire("GUILD_PUBLIC_NOTE_CHANGED", fullName, pnote)
                        Print(fullName .. "'s public note changed: " .. pnote)
                    end
                    if cache[fullName].pnote and onote ~= cache[fullName].onote then
                        lib.callbacks:Fire("GUILD_OFFICER_NOTE_CHANGED", fullName, onote)
                        Print(fullName .. "'s officer note changed: " .. onote)
                    end
                    cache[fullName].index = i
                    cache[fullName].pnote = pnote
                    cache[fullName].onote = onote
                    fetched = fetched + 1
                end
            end

            if not initialized then
                lib.callbacks:Fire("GUILD_NOTE_INITIALIZED")
                Print("|cff66CD00GUILD_NOTE_INITIALIZED|r " .. fetched .. "/" .. n .. " entries.")
                initialized = true
            end

            if forceRefresh then
                lib.callbacks:Fire("GUILD_NOTE_REFRESHED")
                Print("|cff66CD00GUILD_NOTE_REFRESHED|r " .. fetched .. "/" .. n .. " entries.")
                forceRefresh = false
            end

            updating = false
            -- lib.callbacks:Fire("GUILD_NOTE_UPDATED")
        else
            trial = C_Timer.NewTimer(5, function() securecall(GuildRoster) end)
            Print("Retry in 5 sec.")
        end
    end
end)