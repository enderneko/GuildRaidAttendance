local addonName, E =  ...
local GRA, gra = unpack(E)
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1, ...)
    if arg1 == addonName then
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
    end
end)