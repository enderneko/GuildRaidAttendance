local addonName, E =  ...
local GRA, gra = unpack(E)
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1, ...)
	if arg1 == addonName then
		--[[
		if type(_G[GRA_R_Config]["raidInfo"]["DKP"]) ~= "number" then
			_G[GRA_R_Config]["raidInfo"]["DKP"] = 0
        end
        
		if type(_G[GRA_R_Config]["raidInfo"]["startTime"]) ~= "string" then
			_G[GRA_R_Config]["raidInfo"]["startTime"] = _G[GRA_R_Config]["raidInfo"]["deadline"]
			_G[GRA_R_Config]["raidInfo"] = GRA:RemoveElementsByKeys(_G[GRA_R_Config]["raidInfo"], {"deadline"})
        end
        
		if _G[GRA_R_Config]["raidInfo"]["lastDecayed"] then
			_G[GRA_R_Config]["raidInfo"] = GRA:RemoveElementsByKeys(_G[GRA_R_Config]["raidInfo"], {"lastDecayed"})
        end
        
		if _G[GRA_R_Config]["useEPGP"] then
			_G[GRA_R_Config]["raidInfo"]["system"] = "EPGP"
			_G[GRA_R_Config] = GRA:RemoveElementsByKeys(_G[GRA_R_Config], {"useEPGP"})
        end
        
		-- r77-beta
		if _G[GRA_R_Config]["system"] then
			_G[GRA_R_Config]["raidInfo"]["system"] = _G[GRA_R_Config]["system"]
			_G[GRA_R_Config] = GRA:RemoveElementsByKeys(_G[GRA_R_Config], {"system"})
        end
        
        -- r78-release removed class filter
        if GRA_Variables["classFilter"] then
            GRA_Variables = GRA:RemoveElementsByKeys(GRA_Variables, {"classFilter"})
		end
		
		-- r78-release new GRA_RaidLogs structure
		for d, t in pairs(_G[GRA_R_RaidLogs]) do
			if t["attendees"] and t["absentees"] then
				t["attendances"] = {}
				-- process attendees
				for n, tbl in pairs(t["attendees"]) do
					t["attendances"][n] = {tbl[1], nil, tbl[2]}
				end
				-- process absentees
				for n, note in pairs(t["absentees"]) do
					if note == "" then
						t["attendances"][n] = {"ABSENT"}
					else
						t["attendances"][n] = {"ONLEAVE", note}
					end
				end

				-- delete
				_G[GRA_R_RaidLogs][d] = GRA:RemoveElementsByKeys(t, {"attendees", "absentees"})
			end
		end

		-- r79-release startTime string -> number
		for d, t in pairs(_G[GRA_R_RaidLogs]) do
			if type(t["startTime"]) == "string" then
				t["startTime"] = GRA:DateToTime(d .. t["startTime"], true)
			end
			-- change LATE -> PARTLY
			for n, att in pairs(t["attendances"]) do
				if att[1] == "LATE" then
					att[1] = "PARTLY"
				end
			end
		end

		-- r79 add endTime
		if type(_G[GRA_R_Config]["raidInfo"]["endTime"]) ~= "string" then
			_G[GRA_R_Config]["raidInfo"]["endTime"] = "23:00"
		end
		]]
    end
end)