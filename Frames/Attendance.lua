local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")
local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")

local ShowAR, CalcAR
-- local tooltip = GRA.CreateTooltip("GRA_AttendanceSheetTooltip")
---------------------------------------------------------------------
-- attendance frame
---------------------------------------------------------------------
local attendanceFrame = CreateFrame("Frame", "GRA_AttendanceFrame", gra.mainFrame)
attendanceFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, -30)
attendanceFrame:SetPoint("BOTTOMRIGHT", gra.mainFrame, -8, 27)
attendanceFrame:Hide()
gra.attendanceFrame = attendanceFrame

-- attendanceFrame.loaded = 0 -- debug
local loaded = {}
local function GetRow(name)
	for _, row in pairs(loaded) do
		if row.name == name then
			return row
		end
	end
end

---------------------------------------------------------------------
-- sheet
---------------------------------------------------------------------
GRA.CreateScrollFrame(attendanceFrame, -25, 20, {0, 0, 0, 0})
attendanceFrame.scrollFrame:SetScrollStep(19)

---------------------------------------------------------------------
-- status frame
---------------------------------------------------------------------
local statusFrame = CreateFrame("Frame", nil, attendanceFrame)
statusFrame:SetPoint("TOPLEFT", attendanceFrame.scrollFrame, "BOTTOMLEFT")
statusFrame:SetPoint("BOTTOMRIGHT", attendanceFrame)
statusFrame:EnableMouse(true)
statusFrame:SetFrameLevel(7)

local membersText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
membersText:SetPoint("LEFT", 2, 0)
local minEPText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
minEPText:SetPoint("LEFT", membersText, "RIGHT", 10, 0)
local baseGPText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
baseGPText:SetPoint("LEFT", minEPText, "RIGHT", 10, 0)
local decayText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
-- decayText:SetPoint("LEFT", baseGPText, "RIGHT", 10, 0)

local tankIcon = "|TInterface\\AddOns\\GuildRaidAttendance\\Media\\Roles\\TANK.blp:0|t"
local healerIcon = "|TInterface\\AddOns\\GuildRaidAttendance\\Media\\Roles\\HEALER.blp:0|t"
local dpsIcon = "|TInterface\\AddOns\\GuildRaidAttendance\\Media\\Roles\\DPS.blp:0|t"
local function UpdateMemberInfo()
	local tank, healer, dps = 0, 0, 0
	for n, t in pairs(GRA_Roster) do
		if t["role"] == "TANK" then
			tank = tank + 1
		elseif t["role"] == "HEALER" then
			healer = healer + 1
		else -- DPS
			dps = dps + 1
		end
	end
	membersText:SetText("|cff80FF00" .. L["Members: "] .. "|r" .. GRA.Getn(GRA_Roster) .. "   "
		.. tankIcon .. tank .. "  " .. healerIcon .. healer .. "  " .. dpsIcon .. dps)
end

function attendanceFrame:UpdateRaidInfoStrings() -- TODO: use event
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		baseGPText:SetText("|cff80FF00" .. L["Base GP"] .. ": |r" .. GRA_Config["raidInfo"]["EPGP"][1])
		minEPText:SetText("|cff80FF00" .. L["Min EP"] .. ": |r" .. GRA_Config["raidInfo"]["EPGP"][2])
		decayText:SetText("|cff80FF00" .. L["Decay"] .. ": |r" .. GRA_Config["raidInfo"]["EPGP"][3] .. "%")
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		baseGPText:SetText("")
		minEPText:SetText("")
		decayText:SetText("|cff80FF00" .. L["Decay"] .. ": |r" .. GRA_Config["raidInfo"]["DKP"] .. "%")
	end
end

-- roster received
GRA.RegisterCallback("GRA_R_DONE", "AttendanceFrame_RosterReceived", function()
	UpdateMemberInfo()
	attendanceFrame:UpdateRaidInfoStrings()
end)

---------------------------------------------------------------------
-- sort
---------------------------------------------------------------------
local function SetRowPoints()
	local last = nil
	for i = 1, #loaded do
		if last then
			loaded[i]:SetPoint("TOP", last, "BOTTOM", 0, 1)
		else
			loaded[i]:SetPoint("TOP")
		end
		last = loaded[i]
	end
	attendanceFrame.scrollFrame:ResetScroll()
end

local SortSheetByName, SortSheetByClass, SortSheetByATT, SortSheetByATT30, SortSheetByATT60, SortSheetByATT90, SortSheetByAR, SortSheetByAR30, SortSheetByAR60, SortSheetByAR90, SortSheetBySR, SortSheetBySO, SortSheetByPR, SortSheetByEP, SortSheetByGP, SortSheetByCurrentDKP, SortSheetBySpentDKP, SortSheetByTotalDKP

SortSheetByName = function()
	table.sort(loaded, function(a, b) return a.name < b.name end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "name"
end

SortSheetByClass = function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- class pr ep gp name
		table.sort(loaded, function(a, b)
			if a.class ~= b.class then
				return GRA.GetIndex(gra.CLASS_ORDER, a.class) < GRA.GetIndex(gra.CLASS_ORDER, b.class)
			elseif a.pr ~= b.pr then
				return a.pr > b.pr
			elseif a.ep ~= b.ep then
				return a.ep > b.ep
			elseif a.gp ~= b.gp then
				return a.gp < b.gp
			else
				return a.name < b.name
			end
		end)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		-- class current total spent name
		table.sort(loaded, function(a, b)
			if a.class ~= b.class then
				return GRA.GetIndex(gra.CLASS_ORDER, a.class) < GRA.GetIndex(gra.CLASS_ORDER, b.class)
			elseif a.current ~= b.current then
				return a.current > b.current
			elseif a.total ~= b.total then
				return a.total > b.total
			elseif a.spent ~= b.spent then
				return a.spent < b.spent
			else
				return a.name < b.name
			end
		end)
	else
		-- class ar ar30 name
		table.sort(loaded, function(a, b)
			if a.class ~= b.class then
				return GRA.GetIndex(gra.CLASS_ORDER, a.class) < GRA.GetIndex(gra.CLASS_ORDER, b.class)
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Variables["sortKey"] = "class"
end

SortSheetByATT = function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- att late ar pr ep gp name
		table.sort(loaded, function(a, b)
			if a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			-- elseif a.partialLifeTime ~= b.partialLifeTime then
			-- 	return a.partialLifeTime < b.partialLifeTime
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.pr ~= b.pr then
				return a.pr > b.pr
			elseif a.ep ~= b.ep then
				return a.ep > b.ep
			elseif a.gp ~= b.gp then
				return a.gp < b.gp
			else
				return a.name < b.name
			end
		end)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		-- att ar current total spent name
		table.sort(loaded, function(a, b)
			if a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.current ~= b.current then
				return a.current > b.current
			elseif a.total ~= b.total then
				return a.total > b.total
			elseif a.spent ~= b.spent then
				return a.spent < b.spent
			else
				return a.name < b.name
			end
		end)
	else
		-- att ar ar30 name
		table.sort(loaded, function(a, b)
			if a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Variables["sortKey"] = "att"
end

SortSheetByAR = function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- ar pr ep gp name
		table.sort(loaded, function(a, b)
			if a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			elseif a.pr ~= b.pr then
				return a.pr > b.pr
			elseif a.ep ~= b.ep then
				return a.ep > b.ep
			elseif a.gp ~= b.gp then
				return a.gp < b.gp
			else
				return a.name < b.name
			end
		end)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		-- ar current total spent name
		table.sort(loaded, function(a, b)
			if a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			elseif a.current ~= b.current then
				return a.current > b.current
			elseif a.total ~= b.total then
				return a.total > b.total
			elseif a.spent ~= b.spent then
				return a.spent < b.spent
			else
				return a.name < b.name
			end
		end)
	else
		-- ar ar30 name
		table.sort(loaded, function(a, b)
			if a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			elseif a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Variables["sortKey"] = "ar"
end

SortSheetByATT30 = function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- att late ar pr ep gp name
		table.sort(loaded, function(a, b)
			if a.att30 ~= b.att30 then
				return a.att30 > b.att30
			elseif a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			elseif a.pr ~= b.pr then
				return a.pr > b.pr
			elseif a.ep ~= b.ep then
				return a.ep > b.ep
			elseif a.gp ~= b.gp then
				return a.gp < b.gp
			else
				return a.name < b.name
			end
		end)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		-- att ar current total spent name
		table.sort(loaded, function(a, b)
			if a.att30 ~= b.att30 then
				return a.att30 > b.att30
			elseif a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			elseif a.current ~= b.current then
				return a.current > b.current
			elseif a.total ~= b.total then
				return a.total > b.total
			elseif a.spent ~= b.spent then
				return a.spent < b.spent
			else
				return a.name < b.name
			end
		end)
	else
		-- att30 ar30 att ar name
		table.sort(loaded, function(a, b)
			if a.att30 ~= b.att30 then
				return a.att30 > b.att30
			elseif a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			elseif a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Variables["sortKey"] = "att30"
end

SortSheetByATT60 = function()
	-- att60 ar60 att ar name
	table.sort(loaded, function(a, b)
		if a.att60 ~= b.att60 then
			return a.att60 > b.att60
		elseif a.ar60 ~= b.ar60 then
			return a.ar60 > b.ar60
		elseif a.attLifetime ~= b.attLifetime then
			return a.attLifetime > b.attLifetime
		elseif a.arLifetime ~= b.arLifetime then
			return a.arLifetime > b.arLifetime
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "att60"
end

SortSheetByATT90 = function()
	-- att90 ar90 att ar name
	table.sort(loaded, function(a, b)
		if a.att90 ~= b.att90 then
			return a.att90 > b.att90
		elseif a.ar90 ~= b.ar90 then
			return a.ar90 > b.ar90
		elseif a.attLifetime ~= b.attLifetime then
			return a.attLifetime > b.attLifetime
		elseif a.arLifetime ~= b.arLifetime then
			return a.arLifetime > b.arLifetime
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "att90"
end

SortSheetByAR30 = function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- ar30 pr ep gp name
		table.sort(loaded, function(a, b)
			if a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			elseif a.att30 ~= b.att30 then
				return a.att30 > b.att30
			elseif a.pr ~= b.pr then
				return a.pr > b.pr
			elseif a.ep ~= b.ep then
				return a.ep > b.ep
			elseif a.gp ~= b.gp then
				return a.gp < b.gp
			else
				return a.name < b.name
			end
		end)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		-- ar30 current total spent name
		table.sort(loaded, function(a, b)
			if a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			elseif a.att30 ~= b.att30 then
				return a.att30 > b.att30
			elseif a.current ~= b.current then
				return a.current > b.current
			elseif a.total ~= b.total then
				return a.total > b.total
			elseif a.spent ~= b.spent then
				return a.spent < b.spent
			else
				return a.name < b.name
			end
		end)
	else
		-- ar30 att30 ar att name
		table.sort(loaded, function(a, b)
			if a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			elseif a.att30 ~= b.att30 then
				return a.att30 > b.att30
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Variables["sortKey"] = "ar30"
end

SortSheetByAR60 = function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- ar60 pr ep gp name
		table.sort(loaded, function(a, b)
			if a.ar60 ~= b.ar60 then
				return a.ar60 > b.ar60
			elseif a.att60 ~= b.att60 then
				return a.att60 > b.att60
			elseif a.pr ~= b.pr then
				return a.pr > b.pr
			elseif a.ep ~= b.ep then
				return a.ep > b.ep
			elseif a.gp ~= b.gp then
				return a.gp < b.gp
			else
				return a.name < b.name
			end
		end)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		-- ar60 current total spent name
		table.sort(loaded, function(a, b)
			if a.ar60 ~= b.ar60 then
				return a.ar60 > b.ar60
			elseif a.att60 ~= b.att60 then
				return a.att60 > b.att60
			elseif a.current ~= b.current then
				return a.current > b.current
			elseif a.total ~= b.total then
				return a.total > b.total
			elseif a.spent ~= b.spent then
				return a.spent < b.spent
			else
				return a.name < b.name
			end
		end)
	else
		-- ar60 att60 ar att name
		table.sort(loaded, function(a, b)
			if a.ar60 ~= b.ar60 then
				return a.ar60 > b.ar60
			elseif a.att60 ~= b.att60 then
				return a.att60 > b.att60
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Variables["sortKey"] = "ar60"
end

SortSheetByAR90 = function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- ar90 pr ep gp name
		table.sort(loaded, function(a, b)
			if a.ar90 ~= b.ar90 then
				return a.ar90 > b.ar90
			elseif a.att90 ~= b.att90 then
				return a.att90 > b.att90
			elseif a.pr ~= b.pr then
				return a.pr > b.pr
			elseif a.ep ~= b.ep then
				return a.ep > b.ep
			elseif a.gp ~= b.gp then
				return a.gp < b.gp
			else
				return a.name < b.name
			end
		end)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		-- ar90 current total spent name
		table.sort(loaded, function(a, b)
			if a.ar90 ~= b.ar90 then
				return a.ar90 > b.ar90
			elseif a.att90 ~= b.att90 then
				return a.att90 > b.att90
			elseif a.current ~= b.current then
				return a.current > b.current
			elseif a.total ~= b.total then
				return a.total > b.total
			elseif a.spent ~= b.spent then
				return a.spent < b.spent
			else
				return a.name < b.name
			end
		end)
	else
		-- ar90 att90 ar att name
		table.sort(loaded, function(a, b)
			if a.ar90 ~= b.ar90 then
				return a.ar90 > b.ar90
			elseif a.att90 ~= b.att90 then
				return a.att90 > b.att90
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			elseif a.attLifetime ~= b.attLifetime then
				return a.attLifetime > b.attLifetime
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Variables["sortKey"] = "ar90"
end

SortSheetBySR = function()
	-- sr so name
	table.sort(loaded, function(a, b)
		if a.sitOutRate ~= b.sitOutRate then
			return a.sitOutRate > b.sitOutRate
		elseif a.sitOut ~= b.sitOut then
			return a.sitOut > b.sitOut
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "sr"
end

SortSheetBySO = function()
	-- so sr name
	table.sort(loaded, function(a, b)
		if a.sitOut ~= b.sitOut then
			return a.sitOut > b.sitOut
		elseif a.sitOutRate ~= b.sitOutRate then
			return a.sitOutRate > b.sitOutRate
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "so"
end

SortSheetByPR = function()
	-- pr ar ep gp name
	table.sort(loaded, function(a, b)
		if a.pr ~= b.pr then
			return a.pr > b.pr
		elseif a.arLifetime ~= b.arLifetime then
			return a.arLifetime > b.arLifetime
		elseif a.ep ~= b.ep then
			return a.ep > b.ep
		elseif a.gp ~= b.gp then
			return a.gp < b.gp
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "pr"
end

SortSheetByEP = function()
	-- ep pr gp name
	table.sort(loaded, function(a, b)
		if a.ep ~= b.ep then
			return a.ep > b.ep
		elseif a.pr ~= b.pr then
			return a.pr > b.pr
		elseif a.gp ~= b.gp then
			return a.gp < b.gp
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "ep"
end

SortSheetByGP = function()
	-- gp pr ep name
	table.sort(loaded, function(a, b)
		if a.gp ~= b.gp then
			return a.gp > b.gp
		elseif a.pr ~= b.pr then
			return a.pr > b.pr
		elseif a.ep ~= b.ep then
			return a.ep > b.ep
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "gp"
end

SortSheetByCurrentDKP = function()
	-- current ar total spent name
	table.sort(loaded, function(a, b)
		if a.current ~= b.current then
			return a.current > b.current
		elseif a.arLifetime ~= b.arLifetime then
			return a.arLifetime > b.arLifetime
		elseif a.total ~= b.total then
			return a.total > b.total
		elseif a.spent ~= b.spent then
			return a.spent < b.spent
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "current"
end

SortSheetBySpentDKP = function()
	-- spent current total name
	table.sort(loaded, function(a, b)
		if a.spent ~= b.spent then
			return a.spent > b.spent
		elseif a.current ~= b.current then
			return a.current > b.current
		elseif a.total ~= b.total then
			return a.total > b.total
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "spent"
end

SortSheetByTotalDKP = function()
	-- total current spent name
	table.sort(loaded, function(a, b)
		if a.total ~= b.total then
			return a.total > b.total
		elseif a.current ~= b.current then
			return a.current > b.current
		elseif a.spent ~= b.spent then
			return a.spent < b.spent
		else
			return a.name < b.name
		end
	end)
	SetRowPoints()
	GRA_Variables["sortKey"] = "total"
end

local function SortSheet(key)
	if key == "pr" then
		SortSheetByPR()
	elseif key == "ep" then
		SortSheetByEP()
	elseif key == "gp" then
		SortSheetByGP()
	elseif key == "current" then
		SortSheetByCurrentDKP()
	elseif key == "spent" then
		SortSheetBySpentDKP()
	elseif key == "total" then
		SortSheetByTotalDKP()
	elseif key == "class" then
		SortSheetByClass()
	elseif key == "name" then
		SortSheetByName()
	elseif key == "att" then
		SortSheetByATT()
	elseif key == "att30" then
		SortSheetByATT30()
	elseif key == "att60" then
		SortSheetByATT60()
	elseif key == "att90" then
		SortSheetByATT90()
	elseif key == "ar" then
		SortSheetByAR()
	elseif key == "ar30" then
		SortSheetByAR30()
	elseif key == "ar60" then
		SortSheetByAR60()
	elseif key == "ar90" then
		SortSheetByAR90()
	elseif key == "sr" then
		SortSheetBySR()
	elseif key == "so" then
		SortSheetBySO()
	end
end

---------------------------------------------------------------------
-- class filter
---------------------------------------------------------------------
--[=[
local classFilterCBs = {}
classFilterCBs["ALL"] = GRA.CreateCheckButton(statusFrame, L["All"], nil, nil, "GRA_FONT_SMALL")
classFilterCBs["ALL"]:SetScript("OnClick", function(self)
	self:SetChecked(true) -- force check
	for i = 1, 12 do
		classFilterCBs[gra.CLASS_ORDER[i]]:SetChecked(true)
		GRA_Variables["classFilter"][gra.CLASS_ORDER[i]] = true
	end
	-- reload sheet
	GRA.ShowAttendanceSheet()
end)

-- refresh "all classes" CB's state
local function refreshCB_ALL()
	for _, class in pairs(gra.CLASS_ORDER) do
		if not classFilterCBs[class]:GetChecked() then -- unselected class exists
			classFilterCBs["ALL"]:SetChecked(false)
			return
		end
	end
	-- all classes selected
	classFilterCBs["ALL"]:SetChecked(true)
end

local lastCB = nil
for i = 1, 12 do
	local class = gra.CLASS_ORDER[i]
	-- create 12 CBs
	classFilterCBs[class] = GRA.CreateCheckButton(statusFrame, "", nil, function(checked)
		GRA_Variables["classFilter"][class] = checked
		refreshCB_ALL()
		-- reload sheet
		GRA.ShowAttendanceSheet()
	end, nil, GRA.GetLocalizedClassName(class), L["Check to show this class."]) --, L["Check to show this class.\nFrequently clicking will cause high memory usage."])

	-- class color
	classFilterCBs[class]:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox\CheckBox-Normal-]] .. class .. "-16x16")
	classFilterCBs[class]:SetHighlightTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox\CheckBox-Highlight-]] .. class .. "-16x16", "ADD")
	classFilterCBs[class]:SetCheckedTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox\CheckBox-Checked-]] .. class .. "-16x16")

	if lastCB then
		classFilterCBs[class]:SetPoint("LEFT", lastCB, "RIGHT", -3, 0)
	else
		classFilterCBs[class]:SetPoint("LEFT", -1, 0)
	end
	lastCB = classFilterCBs[class]
end

classFilterCBs["ALL"]:SetPoint("LEFT", lastCB, "RIGHT", 10, 0)
]=]

---------------------------------------------------------------------
-- refresh button & date picker
---------------------------------------------------------------------
-- force refresh
local refreshCD = 10
local refreshBtn = GRA.CreateButton(statusFrame, L["Refresh"], nil, {55, 20}, "GRA_FONT_SMALL")
-- refreshBtn:SetPoint("BOTTOMRIGHT", 0, 1)
refreshBtn:SetFrameLevel(8)
refreshBtn:SetScript("OnClick", function()
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		GRA.RefreshEPGP()
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		GRA.RefreshDKP()
	end
	GRA.ShowAttendanceSheet()
	-- re-calc attendance rate
	CalcAR()

	refreshCD = 10
	refreshBtn:SetEnabled(false)
	refreshBtn:SetText(refreshCD)
	local refreshTimer = C_Timer.NewTicker(1, function()
		refreshCD = refreshCD - 1
		refreshBtn:SetText(refreshCD)
		if refreshCD == 0 then
			refreshBtn:SetText(L["Refresh"])
			refreshBtn:SetEnabled(true)
		end
	end, 10)
end)

refreshBtn:RegisterEvent("PLAYER_REGEN_DISABLED")
refreshBtn:RegisterEvent("PLAYER_REGEN_ENABLED")
refreshBtn:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		refreshBtn:SetEnabled(false)
	else
		refreshBtn:SetEnabled(true)
	end
end)

-- date picker
local datePicker = GRA.CreateDatePicker(statusFrame, 70, 20, function(d)
	GRA_Config["startDate"] = d
	GRA.ShowAttendanceSheet()
end)
datePicker:SetPoint("RIGHT", refreshBtn, "LEFT", 1, 0)
datePicker:SetFrameLevel(8)

---------------------------------------------------------------------
-- sheet legend
---------------------------------------------------------------------
local legendFrame = CreateFrame("Frame", nil, gra.mainFrame.header)
legendFrame:SetSize(29, 8)
legendFrame:SetPoint("BOTTOMRIGHT", gra.mainFrame.header.closeBtn, "BOTTOMLEFT", -1, 0)
legendFrame.tex = legendFrame:CreateTexture()
legendFrame.tex:SetTexture([[Interface\AddOns\GuildRaidAttendance\Media\legend.tga]])
legendFrame.tex:SetPoint("BOTTOMLEFT")

legendFrame:SetScript("OnEnter", function(self)
	GRA_Tooltip:SetOwner(self, "ANCHOR_LEFT", -1, -8)
	GRA_Tooltip:AddLine(L["Legend"])
	GRA_Tooltip:AddDoubleLine("|cff00FF00" .. L["Green"] .. "|r - |cffFFFFFF" .. L["Present"])
	GRA_Tooltip:AddLine("|cffFFFF00" .. L["Yellow"] .. "|r - |cffFFFFFF" .. L["Late Arrival / Early Leave"])
	GRA_Tooltip:AddLine("|cffFF0000" .. L["Red"] .. "|r - |cffFFFFFF" .. L["Absent"])
	GRA_Tooltip:AddLine("|cffFF00FF" .. L["Magenta"] .. "|r - |cffFFFFFF" .. L["On Leave"])
	GRA_Tooltip:Show()
end)

legendFrame:SetScript("OnLeave", function(self)
	GRA_Tooltip:Hide()
end)

---------------------------------------------------------------------
-- sheet header frame
---------------------------------------------------------------------
local newWidth
local headerFrame = CreateFrame("Frame", nil, attendanceFrame)
headerFrame:SetPoint("TOPLEFT", attendanceFrame)
headerFrame:SetPoint("BOTTOMRIGHT", attendanceFrame.scrollFrame, "TOPRIGHT")
headerFrame:EnableMouse(true)
headerFrame:SetFrameLevel(7)

local nameText = GRA.CreateGrid(headerFrame, 95, L["Name"], nil, false, L["Sort: "], "|cffFFD100" .. L["Left-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by name."] .. "\n|cffFFD100" .. L["Right-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by class."])
nameText:GetFontString():ClearAllPoints()
nameText:GetFontString():SetWidth(90)
nameText:GetFontString():SetPoint("BOTTOMLEFT", 20, 1)
nameText:GetFontString():SetJustifyH("LEFT")
nameText:SetPoint("BOTTOMLEFT", headerFrame)
nameText:RegisterForClicks("LeftButtonUp", "RightButtonUp")
nameText:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		SortSheetByName()
		GRA.Print(L["Sort attendance sheet by name."])
	elseif button == "RightButton" then
		SortSheetByClass()
		GRA.Print(L["Sort attendance sheet by class."])
	end
end)

-- epgp
local epText = GRA.CreateGrid(headerFrame, 50, "EP", nil, false, L["Sort: "], L["Sort attendance sheet by EP."])
epText:GetFontString():ClearAllPoints()
epText:GetFontString():SetPoint("BOTTOM", 0, 1)
epText:SetScript("OnClick", function()
	SortSheetByEP()
	GRA.Print(L["Sort attendance sheet by EP."])
end)

local gpText = GRA.CreateGrid(headerFrame, 50, "GP", nil, false, L["Sort: "], L["Sort attendance sheet by GP."])
gpText:GetFontString():ClearAllPoints()
gpText:GetFontString():SetPoint("BOTTOM", 0, 1)
gpText:SetScript("OnClick", function()
	SortSheetByGP()
	GRA.Print(L["Sort attendance sheet by GP."])
end)

local prText = GRA.CreateGrid(headerFrame, 50, "PR", nil, false, L["Sort: "], L["Sort attendance sheet by PR."])
prText:GetFontString():ClearAllPoints()
prText:GetFontString():SetPoint("BOTTOM", 0, 1)
prText:SetScript("OnClick", function()
	SortSheetByPR()
	GRA.Print(L["Sort attendance sheet by PR."])
end)

-- dkp
local currentText = GRA.CreateGrid(headerFrame, 50, L["Current"], nil, false, L["Sort: "], L["Sort attendance sheet by DKP (current)."])
currentText:GetFontString():ClearAllPoints()
currentText:GetFontString():SetPoint("BOTTOM", 0, 1)
currentText:SetScript("OnClick", function()
	SortSheetByCurrentDKP()
	GRA.Print(L["Sort attendance sheet by DKP (current)."])
end)

local spentText = GRA.CreateGrid(headerFrame, 50, L["Spent"], nil, false, L["Sort: "], L["Sort attendance sheet by DKP (spent)."])
spentText:GetFontString():ClearAllPoints()
spentText:GetFontString():SetPoint("BOTTOM", 0, 1)
spentText:SetScript("OnClick", function()
	SortSheetBySpentDKP()
	GRA.Print(L["Sort attendance sheet by DKP (spent)."])
end)

local totalText = GRA.CreateGrid(headerFrame, 50, L["Total"], nil, false, L["Sort: "], L["Sort attendance sheet by DKP (total)."])
totalText:GetFontString():ClearAllPoints()
totalText:GetFontString():SetPoint("BOTTOM", 0, 1)
totalText:SetScript("OnClick", function()
	SortSheetByTotalDKP()
	GRA.Print(L["Sort attendance sheet by DKP (total)."])
end)

-- attendance rate
local ar30Text = GRA.CreateGrid(headerFrame, 50, "AR 30", nil, false, L["Sort: "], "|cffFFD100" .. L["Left-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance rate (30 days)."] .. "\n|cffFFD100" .. L["Right-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance (30 days)."])
ar30Text:GetFontString():ClearAllPoints()
ar30Text:GetFontString():SetPoint("BOTTOM", 0, 1)
ar30Text:RegisterForClicks("LeftButtonUp", "RightButtonUp")
ar30Text:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		SortSheetByAR30()
		GRA.Print(L["Sort attendance sheet by attendance rate (30 days)."])
	elseif button == "RightButton" then
		SortSheetByATT30()
		GRA.Print(L["Sort attendance sheet by attendance (30 days)."])
	end
end)

local ar60Text = GRA.CreateGrid(headerFrame, 50, "AR 60", nil, false, L["Sort: "], "|cffFFD100" .. L["Left-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance rate (60 days)."] .. "\n|cffFFD100" .. L["Right-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance (60 days)."])
ar60Text:GetFontString():ClearAllPoints()
ar60Text:GetFontString():SetPoint("BOTTOM", 0, 1)
ar60Text:SetScript("OnClick", function()
	if button == "LeftButton" then
		SortSheetByAR60()
		GRA.Print(L["Sort attendance sheet by attendance rate (60 days)."])
	elseif button == "RightButton" then
		SortSheetByATT60()
		GRA.Print(L["Sort attendance sheet by attendance (60 days)."])
	end
end)

local ar90Text = GRA.CreateGrid(headerFrame, 50, "AR 90", nil, false, L["Sort: "], "|cffFFD100" .. L["Left-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance rate (90 days)."] .. "\n|cffFFD100" .. L["Right-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance (90 days)."])
ar90Text:GetFontString():ClearAllPoints()
ar90Text:GetFontString():SetPoint("BOTTOM", 0, 1)
ar90Text:SetScript("OnClick", function()
	if button == "LeftButton" then
		SortSheetByAR90()
		GRA.Print(L["Sort attendance sheet by attendance rate (90 days)."])
	elseif button == "RightButton" then
		SortSheetByATT90()
		GRA.Print(L["Sort attendance sheet by attendance (90 days)."])
	end
end)

local arLifetimeText = GRA.CreateGrid(headerFrame, 50, "AR", nil, false, L["Sort: "], "|cffFFD100" .. L["Left-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance rate (lifetime)."] .. "\n|cffFFD100" .. L["Right-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by attendance (lifetime)."])
arLifetimeText:GetFontString():ClearAllPoints()
arLifetimeText:GetFontString():SetPoint("BOTTOM", 0, 1)
arLifetimeText:RegisterForClicks("LeftButtonUp", "RightButtonUp")
arLifetimeText:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		SortSheetByAR()
		GRA.Print(L["Sort attendance sheet by attendance rate (lifetime)."])
	elseif button == "RightButton" then
		SortSheetByATT()
		GRA.Print(L["Sort attendance sheet by attendance (lifetime)."])
	end
end)

local sitOutText = GRA.CreateGrid(headerFrame, 50, "SR", nil, false, L["Sort: "], "|cffFFD100" .. L["Left-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by sit-out rate (lifetime)."] .. "\n|cffFFD100" .. L["Right-Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by sit-out (lifetime)."])
sitOutText:GetFontString():ClearAllPoints()
sitOutText:GetFontString():SetPoint("BOTTOM", 0, 1)
sitOutText:RegisterForClicks("LeftButtonUp", "RightButtonUp")
sitOutText:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		SortSheetBySR()
		GRA.Print(L["Sort attendance sheet by sit-out rate (lifetime)."])
	elseif button == "RightButton" then
		SortSheetBySO()
		GRA.Print(L["Sort attendance sheet by sit-out (lifetime)."])
	end
end)

-- dates
local dateGrids = {}
local function CreateDateHeader()
	local days = GRA_Config["raidInfo"]["days"]
	local daysPerWeek = #days
	local weeks = 0

	-- show x weeks in sheet
	if daysPerWeek == 1 then weeks = 16 -- 1 day every week --> 1d*16w = 16
	elseif daysPerWeek == 2 then weeks = 8 -- 2 days every week --> 2d*8w = 16
	elseif daysPerWeek == 3 then weeks = 5 -- 3 days every week --> 3d*5w = 15
	elseif daysPerWeek == 4 then weeks = 4 -- 4 days every week --> 4d*4w = 16
	elseif daysPerWeek == 5 then weeks = 3 -- 5 days every week --> 5d*3w = 15
	elseif daysPerWeek == 6 then weeks = 3 -- 6 days every week --> 6d*3w = 18
	elseif daysPerWeek == 7 then weeks = 3 -- 7 days every week --> 7d*3w = 21
	end

	local firstRaidDay, temp = nil, gra.RAID_LOCKOUTS_RESET
	-- calc first raid day after RAID_LOCKOUTS_RESET day
	for i = 1, 7 do
		if GRA.TContains(days, temp) then
			firstRaidDay = temp
			break
		end
		temp = (temp == 7) and 1 or (temp + 1)
	end

	local startDate = GRA_Config["startDate"]
	for i = 1, weeks do
		for j = 1, 7 do -- 7 days
			local wday = select(2, GRA.DateToWeekday(startDate))
			if GRA.TContains(days, wday) then -- is a raid day
				-- color first day for every raid lockouts period
				-- one day per week = white
				if daysPerWeek ~= 1 and (wday == gra.RAID_LOCKOUTS_RESET or wday == firstRaidDay) then
					color = gra.colors.firebrick.s
				else
					color = "|cffFFFFFF"
				end
				dateGrids[#dateGrids+1] = GRA.CreateGrid(headerFrame, gra.size.grid_dates, color..GRA.FormatDateHeader(startDate), nil)
				dateGrids[#dateGrids]:GetFontString():ClearAllPoints()
				dateGrids[#dateGrids]:GetFontString():SetPoint("BOTTOM", 0, 1)
				-- store date(string "20170330"), use it for GRA_Roster["playerName"]["details"]["date"]
				dateGrids[#dateGrids]["date"] = startDate
				if #dateGrids == 1 then -- first
					-- dateGrids[#dateGrids]:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
				else
					dateGrids[#dateGrids]:SetPoint("LEFT", dateGrids[#dateGrids-1], "RIGHT", -1, 0)
				end
				color = "|cffFFFFFF"
			end
			startDate = GRA.NextDate(startDate)
		end
	end
end

function GRA.SetColumns()
	if GRA.Getn(GRA_Roster) == 0 then return end

	-- set point left, align left
	LPP:PixelPerfectPoint(gra.mainFrame)
	-- re-set mainFrame width
	-- local width = GRA.Round(dateGrids[#dateGrids]:GetRight() - nameText:GetLeft() + 16)
	-- local width2 = 75+(45*3)-3+16+(#dateGrids*30)-#dateGrids
	-- print(width2)
	-- newWidth = 16 + 75 + (#dateGrids * 30) - #dateGrids
	newWidth = 16 + gra.size.grid_name + (#dateGrids * gra.size.grid_dates) - #dateGrids
	if #loaded > 15 then -- space for scroll bar
		newWidth = newWidth + 7
	end

	local lastColumn = nameText

	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		epText:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		epText:Show()
		gpText:SetPoint("LEFT", epText, "RIGHT", -1, 0)
		gpText:Show()
		prText:SetPoint("LEFT", gpText, "RIGHT", -1, 0)
		prText:Show()
		newWidth = newWidth + gra.size.grid_others * 3 - 3
		lastColumn = prText

		-- hide dkp columns
		currentText:Hide()
		spentText:Hide()
		totalText:Hide()

		minEPText:Show()
		baseGPText:Show()
		decayText:Show()
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		currentText:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		currentText:Show()
		spentText:SetPoint("LEFT", currentText, "RIGHT", -1, 0)
		spentText:Show()
		totalText:SetPoint("LEFT", spentText, "RIGHT", -1, 0)
		totalText:Show()
		newWidth = newWidth + gra.size.grid_others * 3 - 3
		lastColumn = totalText

		-- hide epgp columns
		epText:Hide()
		gpText:Hide()
		prText:Hide()

		minEPText:Hide()
		baseGPText:Hide()
		decayText:Show()
	else
		epText:Hide()
		gpText:Hide()
		prText:Hide()
		currentText:Hide()
		spentText:Hide()
		totalText:Hide()

		-- hide MinEP BaseGP Decay
		minEPText:Hide()
		baseGPText:Hide()
		decayText:Hide()
	end

	if GRA_Variables["columns"]["AR_30"] then
		ar30Text:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		ar30Text:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = ar30Text
	else
		ar30Text:Hide()
	end

	if GRA_Variables["columns"]["AR_60"] then
		ar60Text:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		ar60Text:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = ar60Text
	else
		ar60Text:Hide()
	end

	if GRA_Variables["columns"]["AR_90"] then
		ar90Text:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		ar90Text:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = ar90Text
	else
		ar90Text:Hide()
	end

	if GRA_Variables["columns"]["AR_Lifetime"] then
		arLifetimeText:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		arLifetimeText:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = arLifetimeText
	else
		arLifetimeText:Hide()
	end

	if GRA_Variables["columns"]["Sit_Out"] then
		sitOutText:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		sitOutText:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = sitOutText
	else
		sitOutText:Hide()
	end

	-- row SetColumns
	for _, row in pairs(loaded) do
		row:SetColumns()
	end

	if dateGrids[1] then
		dateGrids[1]:SetPoint("BOTTOMLEFT", lastColumn, "BOTTOMRIGHT", -1, 0)
	end
	-- set width
	if attendanceFrame:IsVisible() then gra.mainFrame:SetWidth(newWidth) end
end

---------------------------------------------------------------------
-- sheet data function
---------------------------------------------------------------------
-- for EPGPOptions only
function GRA.RecalcPR()
	local baseGP = tonumber(GRA_Config["raidInfo"]["EPGP"][1])
	local minEP = GRA_Config["raidInfo"]["EPGP"][2]
	for _, row in pairs(loaded) do
		local ep = GRA_Roster[row.name]["EP"]
		local gp = GRA_Roster[row.name]["GP"]
		GRA.UpdatePlayerData_EPGP(row.name, ep, gp, true)
	end
	-- sort after recalc
	SortSheet(GRA_Variables["sortKey"])
end

function GRA.UpdatePlayerData_EPGP(name, ep, gp, noSort)
	if GRA_Roster[name]["altOf"] then return end

	local baseGP = GRA_Config["raidInfo"]["EPGP"][1]
	local minEP = GRA_Config["raidInfo"]["EPGP"][2]

	local row = GetRow(name)
	row.epGrid:SetText(ep)
	-- ep < minEP
	local color
	if ep < minEP then
		color = "|cffA0A0A0"
	else
		color = "|cffFFFFFF"
	end

	row.epGrid:SetText(color .. ep)
	row.gpGrid:SetText(color .. (gp + baseGP))

	local pr = (ep == 0) and 0 or (ep/(gp + baseGP))
	row.ep = ep
	row.gp = gp
	row.pr = pr

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
	row.prGrid:SetText(color .. pr)

	if not noSort then
		-- auto sort after data updated
		SortSheet(GRA_Variables["sortKey"])
	end
end

function GRA.UpdatePlayerData_DKP(name, current, spent, total)
	if GRA_Roster[name]["altOf"] then return end

	local row = GetRow(name)
	row.current = current
	row.spent = spent
	row.total = total
	row.currentGrid:SetText(current)
	row.spentGrid:SetText(spent)
	row.totalGrid:SetText(total)

	-- auto sort after data updated
	SortSheet(GRA_Variables["sortKey"])
end

---------------------------------------------------------------------
-- attendance rate function
---------------------------------------------------------------------
ShowAR = function()
	-- GRA.Debug("|cff1E90FFShow attendance rate")
	for _, row in pairs(loaded) do
		local att30 = GRA_Roster[row.name]["att30"] or {0, 0, 0, 0, 0}
		local att60 = GRA_Roster[row.name]["att60"] or {0, 0, 0, 0, 0}
		local att90 = GRA_Roster[row.name]["att90"] or {0, 0, 0, 0, 0}
		local attLifetime = GRA_Roster[row.name]["attLifetime"] or {0, 0, 0, 0, 0, 0}

		-- attendance count
		row.att30 = att30[1]
		row.att60 = att60[1]
		row.att90 = att90[1]
		row.attLifetime = attLifetime[1]
		row.sitOut = attLifetime[6]

		-- attendance rate
		row.ar30 = tonumber(format("%.1f", att30[5]))
		row.ar60 = tonumber(format("%.1f", att60[5]))
		row.ar90 = tonumber(format("%.1f", att90[5]))
		row.arLifetime = tonumber(format("%.1f", attLifetime[5]))
		row.sitOutRate = attLifetime[6] == 0 and 0 or tonumber(format("%.1f", attLifetime[6] / attLifetime[1] * 100))

		row.ar30Grid:SetText(row.ar30 .. "%")
		row.ar60Grid:SetText(row.ar60 .. "%")
		row.ar90Grid:SetText(row.ar90 .. "%")
		row.arLifetimeGrid:SetText(row.arLifetime .. "%")
		row.sitOutGrid:SetText(row.sitOutRate .. "%" )

		-- tooltip
		row.ar30Grid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA.GetClassColoredName(row.name))
			if att30[3] and att30[3] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att30[1] .. " |cffffff00(" .. att30[3] .. ")")
			else
				GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att30[1])
			end
			if att30[4] and att30[4] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att30[2] .. " |cffff00ff(" .. att30[4] .. ")")
			else
				GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att30[2])
			end
			GRA_Tooltip:Show()
		end)
		row.ar30Grid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

		row.ar60Grid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA.GetClassColoredName(row.name))
			if att60[3] and att60[3] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att60[1] .. " |cffffff00(" .. att60[3] .. ")")
			else
				GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att60[1])
			end
			if att60[4] and att60[4] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att60[2] .. " |cffff00ff(" .. att60[4] .. ")")
			else
				GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att60[2])
			end
			GRA_Tooltip:Show()
		end)
		row.ar60Grid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

		row.ar90Grid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA.GetClassColoredName(row.name))
			if att90[3] and att90[3] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att90[1] .. " |cffffff00(" .. att90[3] .. ")")
			else
			GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att90[1])
			end
			if att90[4] and att90[4] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att90[2] .. " |cffff00ff(" .. att90[4] .. ")")
			else
			GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att90[2])
			end
			GRA_Tooltip:Show()
		end)
		row.ar90Grid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

		row.arLifetimeGrid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA.GetClassColoredName(row.name))
			if attLifetime[3] and attLifetime[3] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. attLifetime[1] .. " |cffffff00(" .. attLifetime[3] .. ")")
			else
			GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. attLifetime[1])
			end
			if attLifetime[4] and attLifetime[4] ~= 0 then
				GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. attLifetime[2] .. " |cffff00ff(" .. attLifetime[4] .. ")")
			else
				GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. attLifetime[2])
			end
			GRA_Tooltip:Show()
		end)
		row.arLifetimeGrid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

		row.sitOutGrid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA.GetClassColoredName(row.name))
			GRA_Tooltip:AddDoubleLine(L["Sit Out"] .. ": ", "|cff00e6ff" .. attLifetime[6])
			GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. attLifetime[1])
			GRA_Tooltip:Show()
		end)
		row.sitOutGrid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)
	end

	SortSheet(GRA_Variables["sortKey"])
end

local calcARProgressFrame
local function ShowCalcARProgressFrame()
	if not calcARProgressFrame then
		calcARProgressFrame = CreateFrame("Frame", nil, attendanceFrame.scrollFrame, "BackdropTemplate")
		GRA.StylizeFrame(calcARProgressFrame, {.1, .1, .1, .95}, {0, 0, 0, 0})
		calcARProgressFrame:SetSize(156, 18)
		calcARProgressFrame:SetPoint("BOTTOMLEFT", attendanceFrame.scrollFrame, 1, 1)
		calcARProgressFrame:Hide()

		-- fade-in effect
		calcARProgressFrame.fadeIn = calcARProgressFrame:CreateAnimationGroup()
		local fadeInAlpha = calcARProgressFrame.fadeIn:CreateAnimation("Alpha")
		fadeInAlpha:SetFromAlpha(0)
		fadeInAlpha:SetToAlpha(1)
		fadeInAlpha:SetDuration(.3)

		-- fade-out effect
		calcARProgressFrame.fadeOut = calcARProgressFrame:CreateAnimationGroup()
		local fadeOutAlpha = calcARProgressFrame.fadeOut:CreateAnimation("Alpha")
		fadeOutAlpha:SetFromAlpha(1)
		fadeOutAlpha:SetToAlpha(0)
		fadeOutAlpha:SetDuration(.3)
		fadeOutAlpha:SetStartDelay(3)

		calcARProgressFrame.fadeIn:SetScript("OnPlay", function()
			calcARProgressFrame.fadeOut:Stop() -- if hiding
			calcARProgressFrame:Show()
		end)

		calcARProgressFrame.fadeOut:SetScript("OnFinished", function()
			calcARProgressFrame:Hide()
		end)

		calcARProgressFrame.bar = GRA.CreateProgressBar(calcARProgressFrame, 155, 2, 0, function()
			calcARProgressFrame.fadeOut:Play()
		end)
		calcARProgressFrame.bar:SetPoint("BOTTOMLEFT")

		calcARProgressFrame.text = calcARProgressFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
		calcARProgressFrame.text:SetJustifyH("RIGHT")
		calcARProgressFrame.text:SetJustifyV("MIDDLE")
		calcARProgressFrame.text:SetPoint("BOTTOMLEFT", calcARProgressFrame.bar, "TOPLEFT", 2, 2)
		calcARProgressFrame.text:SetText(L["Updating attendance rate..."])

		function calcARProgressFrame:SetValue(value)
			calcARProgressFrame.bar:SetValue(value)
		end
	end

	calcARProgressFrame.bar:Reset()
	calcARProgressFrame.fadeIn:Play()
end

-- admin only, calculate AR
local updateRequired
CalcAR = function()
	if GRA.Getn(GRA_Logs) == 0 then return end

	if gra.isAdmin == nil then -- wait for GRA_PERMISSION
		GRA.RegisterCallback("GRA_PERMISSION", "CalcAR_CheckPermission", function()
			CalcAR()
		end)
		return
	elseif gra.isAdmin == false then -- not admin
		return
	end

	ShowCalcARProgressFrame()
	GRA.CalcAtendanceRateAndLoots(nil, nil, calcARProgressFrame.bar, true)
	updateRequired = nil

	ShowAR()
end

---------------------------------------------------------------------
-- sheet grid function
---------------------------------------------------------------------
local gps, eps = {}, {} -- details
local todaysGP, todaysEP = {}, {} -- points
local function CountByDate_EPGP(d)
	if GRA_Logs[d] then
		gps[d] = {}
		eps[d] = {}
		todaysGP[d] = {}
		todaysEP[d] = {}

		local details = GRA_Logs[d]["details"]
		-- scan each gp/ep
		for _, detail in pairs(details) do
			if detail[1] == "GP" then
				local name = detail[4]
				-- for _, name in pairs(detail[4]) do
					if not gps[d][name] then gps[d][name] = {} end
					gps[d][name]["loots"] = (gps[d][name]["loots"] or 0) + 1 -- store loot num
					table.insert(gps[d][name], "|cffffffff" .. detail[3] .. "|cffffffff: " .. detail[2] .. " GP")

					if not todaysGP[d][name] then todaysGP[d][name] = 0 end
					todaysGP[d][name] = todaysGP[d][name] + detail[2]
				-- end
			elseif detail[1] == "EP" or detail[1] == "PEP" then
				for _, name in pairs(detail[4]) do
					if not eps[d][name] then eps[d][name] = {} end
					table.insert(eps[d][name], "|cffffffff" .. detail[3] .. ": " .. detail[2] .. " EP")

					if not todaysEP[d][name] then todaysEP[d][name] = 0 end
					todaysEP[d][name] = todaysEP[d][name] + detail[2]
				end
			elseif detail[1] == "PGP" then
				for _, name in pairs(detail[4]) do
					if not gps[d][name] then gps[d][name] = {} end
					table.insert(gps[d][name], "|cffffffff" .. detail[3] .. ": " .. detail[2] .. " GP")

					if not todaysGP[d][name] then todaysGP[d][name] = 0 end
					todaysGP[d][name] = todaysGP[d][name] + detail[2]
				end
			end
		end
	end
end

local function CountByDate_DKP(d)
	if GRA_Logs[d] then
		gps[d] = {}
		eps[d] = {}
		todaysGP[d] = {}
		todaysEP[d] = {}

		local details = GRA_Logs[d]["details"]
		-- scan each dkp
		for _, detail in pairs(details) do
			if detail[1] == "DKP_C" then
				local name = detail[4]
				if not gps[d][name] then gps[d][name] = {} end
				gps[d][name]["loots"] = (gps[d][name]["loots"] or 0) + 1 -- store loot num
				table.insert(gps[d][name], "|cffffffff" .. detail[3] .. "|cffffffff: " .. detail[2] .. " DKP")

				todaysGP[d][name] = (todaysGP[d][name] or 0) + detail[2]
			elseif detail[1] == "DKP_A" then
				for _, name in pairs(detail[4]) do
					if not eps[d][name] then eps[d][name] = {} end
					table.insert(eps[d][name], "|cffffffff" .. detail[3] .. ": " .. detail[2] .. " DKP")

					todaysEP[d][name] = (todaysEP[d][name] or 0) + detail[2]
				end
			elseif detail[1] == "DKP_P" then
				for _, name in pairs(detail[4]) do
					if not gps[d][name] then gps[d][name] = {} end
					table.insert(gps[d][name], "|cffffffff" .. detail[3] .. ": " .. detail[2] .. " DKP")

					todaysGP[d][name] = (todaysGP[d][name] or 0) + detail[2]
				end
			end
		end
	end
end

local function CountByDate(d)
	if GRA_Logs[d] then
		gps[d] = {}
		eps[d] = {}
		todaysGP[d] = {}
		todaysEP[d] = {}

		local details = GRA_Logs[d]["details"]
		-- scan each loot
		for _, detail in pairs(details) do
			if detail[1] == "LOOT" then
				local name = detail[3]
				if not gps[d][name] then gps[d][name] = {["loots"] = 0} end
				gps[d][name]["loots"] = gps[d][name]["loots"] + 1 -- store loot num
				table.insert(gps[d][name], "|cffffffff" .. detail[2] .. " |cffffffff" .. (detail[4] or ""))
			end
		end
	end
end

local function CountAll()
	gps, eps = {}, {}
	-- count each day in sheet
	for k, dateGrid in pairs(dateGrids) do
		local d = dateGrid.date
		if GRA_Config["raidInfo"]["system"] == "EPGP" then
			CountByDate_EPGP(d)
		elseif GRA_Config["raidInfo"]["system"] == "DKP" then
			CountByDate_DKP(d)
		else
			CountByDate(d)
		end
	end
	-- texplore(gps)
end

local function UpdateGrid(g, d, name, altGs)
	-- set gp detail
	if gps[d][name] then
		g:SetText(gps[d][name]["loots"])
	else
		g:SetText("")
	end

	local att, joinTime, leaveTime, _, isSitOut = GRA.GetMainAltAttendance(d, name)
	if altGs then
		-- 设置大号出勤状态
		if GRA_Logs[d]["attendances"][name] then -- main is not IGNORED
			if not GRA_Logs[d]["attendances"][name][3] then -- 大号没出勤
				if att ~= "ABSENT" and att ~= "ONLEAVE" then -- 小号有出勤
					g:SetAttendance("IGNORED")
				else
					g:SetAttendance(att)
				end
			else  -- 大号有出勤
				g:SetAttendance(att)
				-- sit out mark
				g:ShowSitOutMark(isSitOut)
			end
		else
			g:SetAttendance("IGNORED")
		end

		-- update altGs
		for altName, altG in pairs(altGs) do
			if gps[d][altName] then
				altG:SetText(gps[d][altName]["loots"])
			else
				altG:SetText("")
			end

			if GRA_Logs[d]["attendances"][altName] then
				if GRA_Logs[d]["attendances"][altName][3] then -- alt has attendance
					altG:SetAttendance(att)
					-- sit out mark
					altG:ShowSitOutMark(isSitOut)
				elseif not GRA_Logs[d]["attendances"][name] then -- alt is ABSENT/ONLEAVE and main is IGNORED
					altG:SetAttendance(att)
				end
				if GRA_Logs[d]["attendances"][altName][2] then
					altG:ShowNoteMark(true)
				end
			else
				altG:SetAttendance("IGNORED")
			end

			-- prepare tooltip, add alts to main
			if todaysEP[d][altName] then -- 小号有EP
				todaysEP[d][name] = todaysEP[d][altName] + (todaysEP[d][name] or 0)
			end
			if eps[d][altName] then -- 小号有EP
				if not eps[d][name] then eps[d][name] = {} end -- 如果大号没有则创建table
				for k, altEP in pairs(eps[d][altName]) do
					table.insert(eps[d][name], altEP .. " (" .. GRA.GetClassColoredName(altName) .. "|cffffffff)")
				end
			end

			if todaysGP[d][altName] then -- 小号有GP
				todaysGP[d][name] = todaysGP[d][altName] + (todaysGP[d][name] or 0)
			end
			if gps[d][altName] then -- 小号有拾取
				if not gps[d][name] then gps[d][name] = {} end -- 如果大号没有则创建table
				for k, altGP in pairs(gps[d][altName]) do
					if k ~= "loots" then
						table.insert(gps[d][name], altGP .. " (" .. GRA.GetClassColoredName(altName) .. "|cffffffff)")
					end
				end
			end
		end
	else
		g:SetAttendance(att)
		-- sit out mark
		g:ShowSitOutMark(isSitOut)
	end

	-- mark
	if GRA_Logs[d]["attendances"][name] and GRA_Logs[d]["attendances"][name][2] then
		g:ShowNoteMark(true)
	end

	-- tooltip
	g:HookScript("OnEnter", function()
		GRA_Tooltip:SetOwner(g, "ANCHOR_NONE")
		GRA_Tooltip:SetPoint("BOTTOMRIGHT", g, "BOTTOMLEFT", 1, 0)
		GRA_Tooltip:SetPoint("RIGHT", g, "LEFT", 1, 0)
		GRA_Tooltip:SetPoint("BOTTOM", g:GetParent(), 0, 0)
		GRA_Tooltip:AddLine(GRA.GetClassColoredName(name))

		-- join time
		if att == "PRESENT" or att == "PARTIAL" then
			GRA_Tooltip:AddLine(GRA.SecondsToTime(joinTime) .. " - " .. (GRA.SecondsToTime(leaveTime)))
			GRA_Tooltip:Show()
		end

		-- note
		if GRA_Logs[d]["attendances"][name] and GRA_Logs[d]["attendances"][name][2] then
			GRA_Tooltip:AddLine("|cffFFFFFF" .. GRA_Logs[d]["attendances"][name][2])
			GRA_Tooltip:Show()
		end
		if altGs then -- FIXME: alts should have no notes
			for altName, _ in pairs(altGs) do
				if GRA_Logs[d]["attendances"][altName] and GRA_Logs[d]["attendances"][altName][2] then
					GRA_Tooltip:AddLine("|cffFFFFFF" .. GRA_Logs[d]["attendances"][altName][2])
				end
			end
			GRA_Tooltip:Show()
		end

		if eps[d][name] then
			GRA_Tooltip:AddLine(" ")

			if GRA_Config["raidInfo"]["system"] == "EPGP" then
				GRA_Tooltip:AddLine(L["Today's EP: "] .. todaysEP[d][name])
			elseif GRA_Config["raidInfo"]["system"] == "DKP" then
				GRA_Tooltip:AddLine(L["Today's DKP (awarded): "] .. todaysEP[d][name])
			end

			for _, v in pairs(eps[d][name]) do
				GRA_Tooltip:AddLine(v)
			end
			GRA_Tooltip:Show()
		end

		if gps[d][name] then
			GRA_Tooltip:AddLine(" ")

			if GRA_Config["raidInfo"]["system"] == "EPGP" then
				GRA_Tooltip:AddLine(L["Today's GP: "] .. todaysGP[d][name])
			elseif GRA_Config["raidInfo"]["system"] == "DKP" then
				GRA_Tooltip:AddLine(L["Today's DKP (spent/penalized): "] .. todaysGP[d][name])
			end

			for k, v in pairs(gps[d][name]) do
				if k ~= "loots" then GRA_Tooltip:AddLine(v) end
			end
			GRA_Tooltip:Show()
		end
	end)

	g:HookScript("OnLeave", function()
		GRA_Tooltip:Hide()
	end)
end

local function LoadRowDetails(row)
	for k, g in pairs(row.dateGrids) do
		local d = dateGrids[k].date

		if GRA_Logs[d] then
			if row.alts then
				local altGs = {}
				for altName, altTable in pairs(row.alts) do
					altGs[altName] = altTable.dateGrids[k]
				end
				UpdateGrid(g, d, row.name, altGs)
			else
				UpdateGrid(g, d, row.name)
			end
		end
	end
end

-- update grids after awarding ep or crediting ep or changing attendance
local function RefreshSheetByDate(d)
	local index
	-- get index
	for k, g in pairs(dateGrids) do
		if g.date == d then
			index = k
			break
		end
	end

	-- date not shown
	if not index then return end

	-- empty grids and remove tooltips
	for _, row in pairs(loaded) do
		local g = row.dateGrids[index]
		g:SetAttendance(nil)
		g:SetText("")
		g:ShowNoteMark(false)
		g:ShowSitOutMark(false)

		if row.alts then
			for _, alts in pairs(row.alts) do
				alts.dateGrids[index]:SetAttendance(nil)
				alts.dateGrids[index]:SetText("")
				alts.dateGrids[index]:ShowNoteMark(false)
				alts.dateGrids[index]:ShowSitOutMark(false)
			end

			g:SetScript("OnEnter", function()
				g:Highlight()
				for _, alts in pairs(row.alts) do
					alts.dateGrids[index]:Highlight()
				end
			end)
			g:SetScript("OnLeave", function()
				g:Unhighlight()
				for _, alts in pairs(row.alts) do
					alts.dateGrids[index]:Unhighlight()
				end
			end)
		else
			g:SetScript("OnEnter", g.Highlight)
			g:SetScript("OnLeave", g.Unhighlight)
		end
	end

	-- if no logs exist, deleted
	if not GRA_Logs[d] then return end

	-- count on this day
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		CountByDate_EPGP(d)
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		CountByDate_DKP(d)
	else
		CountByDate(d)
	end

	for _, row in pairs(loaded) do
		if row.alts then
			local altGs = {}
			for altName, altTable in pairs(row.alts) do
				altGs[altName] = altTable.dateGrids[index]
			end
			UpdateGrid(row.dateGrids[index], d, row.name, altGs)
		else
			UpdateGrid(row.dateGrids[index], d, row.name)
		end
	end
end

local function RefreshSheetByDates(dates)
	for _, d in pairs(dates) do
		RefreshSheetByDate(d)
	end
end

GRA.RegisterCallback("GRA_ENTRY", "AttendanceSheet_DetailsRefresh", RefreshSheetByDate)
GRA.RegisterCallback("GRA_ENTRY_MODIFY", "AttendanceSheet_DetailsRefresh", RefreshSheetByDate)
GRA.RegisterCallback("GRA_ENTRY_UNDO", "AttendanceSheet_DetailsRefresh", RefreshSheetByDate)

-- raid logs (attendance) changed
local refreshTimer
GRA.RegisterCallback("GRA_RAIDLOGS", "AttendanceSheet_DetailsRefresh", function(d)
	if attendanceFrame:IsVisible() then
		-- update ONCE EVERY 1S!!!
		if refreshTimer then
			refreshTimer:Cancel()
			refreshTimer = nil
		end

		refreshTimer = C_Timer.NewTimer(1, function()
			RefreshSheetByDate(d)
			CalcAR()
			refreshTimer = nil
		end)
	else
		-- if updateRequired ~= nil and sheet not updated yet.
		if type(updateRequired) == "table" then
			if not GRA.TContains(updateRequired, d) then
				table.insert(updateRequired, d)
			end
		elseif type(updateRequired) == "string" then
			if updateRequired ~= d then
				updateRequired = {updateRequired, d}
			end
		else
			updateRequired = d
		end
	end
end)

local function AttendanceSheet_DetailsRefreshByDates(dates)
	if attendanceFrame:IsVisible() then
		RefreshSheetByDates(dates)
		CalcAR()
	else
		-- if updateRequired ~= nil and sheet not updated yet.
		if type(updateRequired) == "table" then
			local temp = {}
			-- there're no duplicate keys in a table
			for _, v in pairs(dates) do
				temp[v] = true
			end
			for _, v in pairs(updateRequired) do
				temp[v] = true
			end
			-- save to updateRequired
			wipe(updateRequired)
			for k, _ in pairs(temp) do
				table.insert(updateRequired, k)
			end

		elseif type(updateRequired) == "string" then
			if not GRA.TContains(dates, d) then
				table.insert(dates, d)
			end
			updateRequired = dates
		else
			updateRequired = dates
		end
	end
end

-- raid logs deleted
GRA.RegisterCallback("GRA_LOGS_DEL", "AttendanceSheet_DetailsRefresh", AttendanceSheet_DetailsRefreshByDates)

-- raid logs archived
GRA.RegisterCallback("GRA_LOGS_ACV", "AttendanceSheet_DetailsRefresh", AttendanceSheet_DetailsRefreshByDates)

-- raid start time update (RaidLogsEditFrame/AttendanceEditor)
GRA.RegisterCallback("GRA_RH_UPDATE", "AttendanceSheet_RaidHoursUpdate", function(d)
	GRA.Debug("|cff66CD00GRA_RH_UPDATE:|r " .. d)
	GRA.UpdateAttendanceStatus(d)
	RefreshSheetByDate(d)
	updateRequired = true -- CalcAR
end)

-- system changed
GRA.RegisterCallback("GRA_SYSTEM", "AttendanceSheet_SystemChanged", function(system)
	if GRA.Getn(GRA_Roster) == 0 then return end
	attendanceFrame:UpdateRaidInfoStrings()
	-- show columns
	GRA.SetColumns()
	-- refresh tooltip
	gps, eps = {}, {}
	todaysGP, todaysEP = {}, {}
	for _, dateGrid in pairs(dateGrids) do
		RefreshSheetByDate(dateGrid.date)
	end
end)

-- refresh on raid logs received
GRA.RegisterCallback("GRA_LOGS_DONE", "AttendanceFrame_LogsReceived", function(count, dates)
	RefreshSheetByDates(dates)
	-- refresh attendance rate
	ShowAR()
end)

GRA.RegisterCallback("GRA_MAINALT", "AttendanceFrame_MainAltChanged", function()
	CalcAR()
end)

-- attendance rate calculation method changed
GRA.RegisterCallback("GRA_ARCM", "AttendanceFrame_ARCMChanged", function()
	if attendanceFrame:IsVisible() then
		CalcAR()
	else
		if updateRequired == nil then updateRequired = true end
	end
end)

---------------------------------------------------------------------
-- load sheet (create row)
---------------------------------------------------------------------
local function LoadSheet()
	CountAll()
	GRA.UpdateMainAlt()
	-- process mains and alts
	for pName, pTable in pairs(GRA_Roster) do
		if not pTable["altOf"] then
			local row = GRA.CreateRow(attendanceFrame.scrollFrame.content, attendanceFrame.scrollFrame:GetWidth(), pName,
				function() GRA.ShowMemberAttendance(pName) end)
			row.name = pName -- sort key
			row.class = pTable["class"] -- sort key

			-- prepare for sorting (or it may be nil)
			row.ep = pTable["EP"] or 0
			row.gp = pTable["GP"] or 0
			row.pr = row.ep / (row.gp + GRA_Config["raidInfo"]["EPGP"][1])
			-- dkp
			row.current = pTable["DKP_Current"] or 0
			row.spent = pTable["DKP_Spent"] or 0
			row.total = pTable["DKP_Total"] or 0

			-- disabled in minimal mode
			if not GRA_Variables["minimalMode"] then
				row:CreateGrid(#dateGrids)
			end

			-- load alts
			if gra.mainAlt[pName] then
				for _, altName in pairs(gra.mainAlt[pName]) do
					row:AddAlt(altName)
				end
			end

			-- disabled in minimal mode
			if not GRA_Variables["minimalMode"] then
				LoadRowDetails(row)
			end

			table.insert(loaded, row)
			attendanceFrame.scrollFrame:SetWidgetAutoWidth(row)
			-- attendanceFrame.loaded = attendanceFrame.loaded + 1
		end
	end
end

local function HideAll()
	wipe(loaded)

	statusFrame:Hide()
	headerFrame:Hide()
	for i = 1, #dateGrids do
		dateGrids[i]:ClearAllPoints()
		dateGrids[i]:Hide()
	end
	wipe(dateGrids)

	-- attendanceFrame.loaded = 0
	attendanceFrame.scrollFrame:Reset()
end

function GRA.ShowAttendanceSheet()
	HideAll()

	if GRA.Getn(GRA_Roster) ~= 0 then
		GRA.Debug("|cff1E90FFShowAttendanceSheet|r")

		if not GRA_Variables["minimalMode"] then CreateDateHeader() end
		LoadSheet()
		-- after sheet row loaded set columns and WIDTH!!!
		GRA.SetColumns()
		-- load attendance rate and sort
		ShowAR()

		headerFrame:Show()
		statusFrame:Show()

		UpdateMemberInfo()
		attendanceFrame:UpdateRaidInfoStrings()

		if attendanceFrame.scrollFrame.mask then attendanceFrame.scrollFrame.mask:Hide() end
	else
		-- print("No member!")
		GRA.CreateMask(attendanceFrame.scrollFrame, L["No member"], {1, -1, -1, 1})
	end

	-- schedule changed (mainFrame's width changed) may cause frame not pixel perfect, fix it!
	LPP:PixelPerfectPoint(gra.mainFrame)

	-- update!
	if GRA_Config["raidInfo"]["system"] == "EPGP" then
		-- register/unregister GUILD_OFFICER_NOTE_CHANGED
		GRA.UpdateRosterEPGP()
	elseif GRA_Config["raidInfo"]["system"] == "DKP" then
		GRA.UpdateRosterDKP()
	end
end

local function EnableMiniMode(f)
	if f then
		legendFrame:Hide()
		datePicker:Hide()
		refreshBtn:ClearAllPoints()
		refreshBtn:SetPoint("BOTTOMRIGHT", gra.mainFrame, -62, 5)

		-- membersText:ClearAllPoints()
		-- membersText:SetPoint("TOPLEFT", 0, -20)
		decayText:ClearAllPoints()
		decayText:SetPoint("TOPLEFT", 2, -20)
	else
		-- reset frame width
		gra.mainFrame:SetWidth(gra.size.mainFrame[1])

		legendFrame:Show()
		datePicker:Show()
		refreshBtn:ClearAllPoints()
		refreshBtn:SetPoint("BOTTOMRIGHT", 0, 1)

		-- membersText:ClearAllPoints()
		-- membersText:SetPoint("LEFT", 245, 0)
		decayText:ClearAllPoints()
		decayText:SetPoint("LEFT", baseGPText, "RIGHT", 10, 0)
	end
end

GRA.RegisterCallback("GRA_MINI", "AttendanceFrame_MiniMode", function(enabled)
	EnableMiniMode(enabled)
	GRA.ShowAttendanceSheet()
end)

GRA.RegisterCallback("GRA_ROSTER", "AttendanceFrame_RosterUpdate", function()
	GRA.ShowAttendanceSheet()
end)

---------------------------------------------------------------------
-- script
---------------------------------------------------------------------
attendanceFrame:SetScript("OnShow", function()
	EnableMiniMode(GRA_Variables["minimalMode"])
	LPP:PixelPerfectPoint(gra.mainFrame)
	if newWidth then gra.mainFrame:SetWidth(newWidth) end

	--[=[ class filter
	for class,checked in pairs(GRA_Variables["classFilter"]) do
		classFilterCBs[class]:SetChecked(checked)
		-- print(class .. (checked and "√" or "×"))
	end
	refreshCB_ALL()
	]=]

	datePicker:SetDate(GRA_Config["startDate"])

	if updateRequired then
		if type(updateRequired) == "table" then
			RefreshSheetByDates(updateRequired)
		elseif type(updateRequired) == "string" then
			RefreshSheetByDate(updateRequired)
		end
		CalcAR()
	end

	if #loaded ~= 0 then -- already loaded
		return
	end

	GRA.ShowAttendanceSheet()
	-- admin calc attendance rate
	CalcAR()
end)

attendanceFrame:SetScript("OnHide", function()
	legendFrame:Hide()
end)

if GRA.Debug() then
	-- GRA.StylizeFrame(attendanceFrame, {.5, 0, 0, 0})
	-- GRA.StylizeFrame(headerFrame, {0, .7, 0, .1}, {0, 0, 0, 0})
	-- GRA.StylizeFrame(statusFrame, {1, 0, 0, .1}, {0, 0, 0, 0})
end

---------------------------------------------------------------------
-- resize
---------------------------------------------------------------------
function attendanceFrame:Resize()
	attendanceFrame:ClearAllPoints()
	attendanceFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, gra.size.attendanceFrame[1])
	attendanceFrame:SetPoint("TOPRIGHT", gra.mainFrame, -8, gra.size.attendanceFrame[1])
	attendanceFrame:SetHeight(gra.size.attendanceFrame[2])
	-- header
	nameText:SetSize(gra.size.grid_name, gra.size.height)
	epText:SetSize(gra.size.grid_others, gra.size.height)
	gpText:SetSize(gra.size.grid_others, gra.size.height)
	prText:SetSize(gra.size.grid_others, gra.size.height)
	ar30Text:SetSize(gra.size.grid_others, gra.size.height)
	ar60Text:SetSize(gra.size.grid_others, gra.size.height)
	ar90Text:SetSize(gra.size.grid_others, gra.size.height)
	arLifetimeText:SetSize(gra.size.grid_others, gra.size.height)
	-- scroll
	attendanceFrame.scrollFrame:SetScrollStep(gra.size.height-1)
	attendanceFrame.scrollFrame:Resize(-gra.size.height-5, gra.size.height)
	-- button
	refreshBtn:SetSize(unpack(gra.size.button_refresh))
	datePicker:SetSize(unpack(gra.size.button_datePicker))
	datePicker:Resize(gra.size.button_datePicker_outter[1], gra.size.button_datePicker_outter[2], gra.size.button_datePicker_inner[1], gra.size.button_datePicker_inner[2])
end