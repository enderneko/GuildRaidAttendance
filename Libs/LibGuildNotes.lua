--------------------------------------------
-- LibGuildNotes
-- fyhcslb 2017-12-12 03:52:26
-- simply guild note get/set
--------------------------------------------
local lib = LibStub:NewLibrary("LibGuildNotes", "1.0")
if not lib then return end

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
--@debug@
local debug = false
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

function lib:GetPublicNote(name)
	if cache[name] then
		return cache[name][1]
	end

	Print(name .. " is not in your guild.")
	return nil
end

function lib:GetOfficerNote(name)
	if cache[name] then
		return cache[name][2]
	end

	Print(name .. " is not in your guild.")
	return nil
end

local function SetNote(type, name, note, isRetry)
	if not cache[name] then
		Print(name .. " is not in your guild.")
		return
	end
	
	local index = cache[name][3]

	if GuildRosterFrame and GuildRosterFrame:IsVisible() then 
		SetGuildRosterShowOffline(true)
		GuildRosterShowOfflineButton:SetChecked(true)
	end

	-- check correctness, make sure it is THE ONE.
	local nameCurrentIndex = GetGuildRosterInfo(index)
	if nameCurrentIndex ~= name then
		-- Print("|cffFF3030-- LibGuildNotes --------------------|r", true)
		-- Print("    Set " .. name .. "'s note failed.", true)
		-- Print("    Name(should be):" .. name, true)
		-- Print("    Name(current index): " .. nameCurrentIndex, true)
		-- Print("|cffFF3030-------------------------------------|r", true)
		Print("Set " .. name .. "'s note failed, retry in 5 sec.")
		trial = C_Timer.NewTimer(5, function() securecall("GuildRoster") end)
		C_Timer.NewTimer(7, function() SetNote(type, name, note, true) end)
		return
	end

	
	if type == "public" then
		GuildRosterSetPublicNote(index, note)
	elseif type == "officer" then
		GuildRosterSetOfficerNote(index, note)
	end

	if isRetry then
		Print("Set " .. name .. "'s note successful.")
	end
end

function lib:SetPublicNote(name, note)
	if not CanEditPublicNote() then return end
	
	if not updating then
		SetNote("public", name, note)
	else
		-- retry after 2sec
		local ticker = C_Timer.NewTicker(2, function(ticker)
			if not updating then
				SetNote("public", name, note)
				ticker:Cancel()
			end
		end)
	end
end

function lib:SetOfficerNote(name, note)
	if not CanEditOfficerNote() then return end
	
	if not updating then
		SetNote("officer", name, note)
	else
		-- retry after 2sec
		local ticker = C_Timer.NewTicker(2, function(ticker)
			if not updating then
				SetNote("officer", name, note)
				ticker:Cancel()
			end
		end)
	end
end

function lib:IsInGuild(fullname)
	if cache[fullname] then
		return true
	else
		return false
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("GUILD_ROSTER_UPDATE")

function lib:ForceRefresh()
	-- if InCombatLockdown() then return end
	Print("Starting ForceRefresh")
	forceRefresh = true
	securecall("GuildRoster")
	trial = C_Timer.NewTicker(5, function() securecall("GuildRoster") end, 2)
end

function lib:Reinitialize()
	Print("Reinitializing...")
	initialized = false
	securecall("GuildRoster")
	trial = C_Timer.NewTicker(5, function() securecall("GuildRoster") end, 2)
end

f:SetScript("OnEvent", function(self, event)
	if event == "GUILD_ROSTER_UPDATE" then
		-- if InCombatLockdown() then return end

		-- make sure to get all guild members correctly
		if not GuildRosterFrame then
			SetGuildRosterShowOffline(true)
		elseif not GuildRosterFrame:IsVisible() then
			SetGuildRosterShowOffline(true)
		end
		
		local n = GetNumGuildMembers()
		if n ~= 0 then -- get guild roster successful
			if trial then
				trial:Cancel()
				trial = nil
			end

			updating = true

			-- SetGuildRosterShowOffline(true)
			for i = 1, n do
				-- fullName, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(index)
				local fullName, _, _, _, _, _, pnote, onote = GetGuildRosterInfo(i)
				if fullName ~= nil then
					if cache[fullName] and pnote ~= cache[fullName][1] then
						lib.callbacks:Fire("GUILD_PUBLIC_NOTE_CHANGED", fullName, pnote)
					end
					if cache[fullName] and onote ~= cache[fullName][2] then
						lib.callbacks:Fire("GUILD_OFFICER_NOTE_CHANGED", fullName, onote)
					end
					cache[fullName] = {pnote, onote, i}
				end
			end

			if not initialized then
				lib.callbacks:Fire("GUILD_NOTE_INITIALIZED")
				Print("|cff66CD00GUILD_NOTE_INITIALIZED|r " .. n .. " entries.")
				initialized = true
			end

			if forceRefresh then
				lib.callbacks:Fire("GUILD_NOTE_REFRESHED")
				Print("|cff66CD00GUILD_NOTE_REFRESHED|r " .. n .. " entries.")
				forceRefresh = false
			end

			updating = false
			-- lib.callbacks:Fire("GUILD_NOTE_UPDATED")
		else
			trial = C_Timer.NewTimer(5, function() securecall("GuildRoster") end)
			Print("Retry in 5 sec.")
		end
	end
end)

-- hooksecurefunc("GuildFrame_LoadUI", function()
-- 	GuildRosterFrame:HookScript("OnShow", function()
-- 		Print("show GuildRosterFrame")
-- 	end)
-- end)