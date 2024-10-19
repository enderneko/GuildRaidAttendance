local addonName, E =  ...
local GRA, gra = unpack(E)
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1, ...)
	if arg1 == addonName then
		--[[
		if type(GRA_Config["raidInfo"]["DKP"]) ~= "number" then
			GRA_Config["raidInfo"]["DKP"] = 0
        end

		if type(GRA_Config["raidInfo"]["startTime"]) ~= "string" then
			GRA_Config["raidInfo"]["startTime"] = GRA_Config["raidInfo"]["deadline"]
			GRA_Config["raidInfo"] = GRA.RemoveElementsByKeys(GRA_Config["raidInfo"], {"deadline"})
        end

		if GRA_Config["raidInfo"]["lastDecayed"] then
			GRA_Config["raidInfo"] = GRA.RemoveElementsByKeys(GRA_Config["raidInfo"], {"lastDecayed"})
        end

		if GRA_Config["useEPGP"] then
			GRA_Config["raidInfo"]["system"] = "EPGP"
			GRA_Config = GRA.RemoveElementsByKeys(GRA_Config, {"useEPGP"})
        end

		-- r77-beta
		if GRA_Config["system"] then
			GRA_Config["raidInfo"]["system"] = GRA_Config["system"]
			GRA_Config = GRA.RemoveElementsByKeys(GRA_Config, {"system"})
        end

        -- r78-release removed class filter
        if GRA_Variables["classFilter"] then
            GRA_Variables = GRA.RemoveElementsByKeys(GRA_Variables, {"classFilter"})
		end

		-- r78-release new GRA_RaidLogs structure
		for d, t in pairs(GRA_Logs) do
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
				GRA_Logs[d] = GRA.RemoveElementsByKeys(t, {"attendees", "absentees"})
			end
		end

		-- r79-release startTime string -> number
		for d, t in pairs(GRA_Logs) do
			if type(t["startTime"]) == "string" then
				t["startTime"] = GRA.DateToSeconds(d .. t["startTime"], true)
			end
			-- change LATE -> PARTIAL
			for n, att in pairs(t["attendances"]) do
				if att[1] == "LATE" then
					att[1] = "PARTIAL"
				end
			end
		end

		-- r79 add endTime
		if type(GRA_Config["raidInfo"]["endTime"]) ~= "string" then
			GRA_Config["raidInfo"]["endTime"] = "23:00"
		end

		-- r84-release
		for n, t in pairs(GRA_Roster) do
			if t["attLifetime"] and #t["attLifetime"] == 5 then
				table.insert(t["attLifetime"], 0)
			end
		end

		if type(GRA_Variables["columns"]["Sit_Out"]) ~= "boolean" then
			GRA_Variables["columns"]["Sit_Out"] = false
		end

		-- r86-release
		if not(GRA_Config["revise"]) or GRA_Config["revise"] < "r86-release" then
			for _, t in pairs(GRA_Logs) do
				for _, att in pairs(t["attendances"]) do
					if att[1] == "PARTLY" then
						att[1] = "PARTIAL"
					end
				end
			end
			GRA_Config["revise"] = "r86-release"
		end

		-- r87-release
		if not(GRA_Config["revise"]) or GRA_Config["revise"] < "r87-release" then
			for _, t in pairs(GRA_Logs) do
				-- fix typo in r86-release
				for _, att in pairs(t["attendances"]) do
					if att[1] == "PARTLY" then
						att[1] = "PARTIAL"
					end
				end

				-- add duration and wipes
				for _, bt in ipairs(t["bosses"]) do
					if #bt == 5 then
						-- duration
						if bt[3] then
							table.insert(bt, 3, bt[4]-bt[3])
						else
							table.insert(bt, 3, nil)
						end
						-- wipes
						table.insert(bt, 6, 0)
					end
				end
			end
			GRA_Config["revise"] = "r87-release"
		end

		-- r88-release
		if not(GRA_Config["revise"]) or GRA_Config["revise"] < "r88-release" then
			for _, t in pairs(GRA_Logs) do
				-- fix attendances structure
				for _, att in pairs(t["attendances"]) do
					if att[4] == true or att[4] == false then
						att[5] = att[4]
						att[4] = nil
					end
				end
			end
			GRA_Config["revise"] = "r88-release"
		end

		-- r89-release
		if not(GRA_Config["revise"]) or GRA_Config["revise"] < "r89-release" then
			GRA_A_Variables["aboutViewed"] = nil
			GRA_Config["revise"] = "r89-release"
		end

		-- r91-release add startTime & endTime for all logs
		if not(GRA_Config["revise"]) or GRA_Config["revise"] < "r91-release" then
			for d, t in pairs(GRA_Logs) do
				if not t["startTime"] then t["startTime"] =  select(2, GRA.GetRaidStartTime(d)) end
				if not t["endTime"] then t["endTime"] =  select(2, GRA.GetRaidEndTime(d)) end
				if t["desc"] then
					t["note"] = t["desc"]
					t["desc"] = nil
				end
			end
			GRA_Config["revise"] = "r91-release"
		end
		]]
    end
end)