local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")
local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")

local ShowAR, CalcAR
-- local tooltip = GRA:CreateTooltip("GRA_AttendanceSheetTooltip")
-----------------------------------------
-- attendance frame
-----------------------------------------
local attendanceFrame = CreateFrame("Frame", "GRA_AttendanceFrame", gra.mainFrame)
attendanceFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, -30)
attendanceFrame:SetPoint("TOPRIGHT", gra.mainFrame, -8, -30)
attendanceFrame:SetHeight(331)
attendanceFrame:Hide()
gra.attendanceFrame = attendanceFrame

-- attendanceFrame.loaded = 0 -- debug
local loaded = {}

-----------------------------------------
-- sheet
-----------------------------------------
GRA:CreateScrollFrame(attendanceFrame, -25, 20, {0, 0, 0, 0})
attendanceFrame.scrollFrame:SetScrollStep(19)

-----------------------------------------
-- status frame
-----------------------------------------
local statusFrame = CreateFrame("Frame", nil, attendanceFrame)
statusFrame:SetPoint("TOPLEFT", attendanceFrame.scrollFrame, "BOTTOMLEFT")
statusFrame:SetPoint("BOTTOMRIGHT", attendanceFrame)
statusFrame:EnableMouse(true)
statusFrame:SetFrameLevel(7)

local membersText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
local minEPText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
minEPText:SetPoint("LEFT", membersText, "RIGHT", 10, 0)
local baseGPText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
baseGPText:SetPoint("LEFT", minEPText, "RIGHT", 10, 0)
local decayText = statusFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
-- decayText:SetPoint("LEFT", baseGPText, "RIGHT", 10, 0)

function attendanceFrame:UpdateEPGPStrings()
	baseGPText:SetText("|cff80FF00" .. L["Base GP"] .. ": |r" .. GRA_Config["raidInfo"]["EPGP"][1])
	minEPText:SetText("|cff80FF00" .. L["Min EP"] .. ": |r" .. GRA_Config["raidInfo"]["EPGP"][2])
	decayText:SetText("|cff80FF00" .. L["Decay"] .. ": |r" .. GRA_Config["raidInfo"]["EPGP"][3] .. "%")
end

-- roster received
GRA:RegisterEvent("GRA_R_DONE", "AttendanceFrame_RosterReceived", function()
	membersText:SetText("|cff80FF00" .. L["Members: "] .. "|r" .. GRA:Getn(GRA_Roster))
	attendanceFrame:UpdateEPGPStrings()
end)

-----------------------------------------
-- sort
-----------------------------------------
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

local SortSheetByName, SortSheetByClass, SortSheetByAR, SortSheetByAR30, SortSheetByAR60, SortSheetByAR90, SortSheetByPR, SortSheetByEP, SortSheetByGP

SortSheetByName = function()
	table.sort(loaded, function(a, b) return a.name < b.name end)
	SetRowPoints()
	GRA_Config["sortKey"] = "name"
end

SortSheetByClass = function()
	if GRA_Config["useEPGP"] then
		-- class pr ep gp name
		table.sort(loaded, function(a, b)
			if a.class ~= b.class then
				return GRA:GetIndex(gra.CLASS_ORDER, a.class) < GRA:GetIndex(gra.CLASS_ORDER, b.class)
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
	else
		-- class ar ar30 name
		table.sort(loaded, function(a, b)
			if a.class ~= b.class then
				return GRA:GetIndex(gra.CLASS_ORDER, a.class) < GRA:GetIndex(gra.CLASS_ORDER, b.class)
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
	GRA_Config["sortKey"] = "class"
end

SortSheetByAR = function()
	if GRA_Config["useEPGP"] then
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
	GRA_Config["sortKey"] = "ar"
end

SortSheetByAR30 = function()
	if GRA_Config["useEPGP"] then
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
	else
		-- ar30 ar name
		table.sort(loaded, function(a, b)
			if a.ar30 ~= b.ar30 then
				return a.ar30 > b.ar30
			elseif a.att30 ~= b.att30 then
				return a.att30 > b.att30
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Config["sortKey"] = "ar30"
end

SortSheetByAR60 = function()
	if GRA_Config["useEPGP"] then
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
	else
		-- ar60 ar name
		table.sort(loaded, function(a, b)
			if a.ar60 ~= b.ar60 then
				return a.ar60 > b.ar60
			elseif a.att60 ~= b.att60 then
				return a.att60 > b.att60
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Config["sortKey"] = "ar60"
end

SortSheetByAR90 = function()
	if GRA_Config["useEPGP"] then
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
	else
		-- ar90 ar name
		table.sort(loaded, function(a, b)
			if a.ar90 ~= b.ar90 then
				return a.ar90 > b.ar90
			elseif a.att90 ~= b.att90 then
				return a.att90 > b.att90
			elseif a.arLifetime ~= b.arLifetime then
				return a.arLifetime > b.arLifetime
			else
				return a.name < b.name
			end
		end)
	end
	SetRowPoints()
	GRA_Config["sortKey"] = "ar90"
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
	GRA_Config["sortKey"] = "pr"
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
	GRA_Config["sortKey"] = "ep"
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
	GRA_Config["sortKey"] = "gp"
end

local function SortSheet(key)
	if key == "pr" then
		SortSheetByPR()
	elseif key == "ep" then
		SortSheetByEP()
	elseif key == "gp" then
		SortSheetByGP()
	elseif key == "class" then
		SortSheetByClass()
	elseif key == "name" then
		SortSheetByName()
	elseif key == "ar" then
		SortSheetByAR()
	elseif key == "ar30" then
		SortSheetByAR30()
	elseif key == "ar60" then
		SortSheetByAR60()
	elseif key == "ar90" then
		SortSheetByAR90()
	end
end

-----------------------------------------
-- class filter
-----------------------------------------
-- local function FilterClass()
-- 	TODO: find a better way to filter class, not to create row again and again
-- end

local classFilterCBs = {}
classFilterCBs["ALL"] = GRA:CreateCheckButton(statusFrame, L["All"], nil, nil, "GRA_FONT_SMALL")
classFilterCBs["ALL"]:SetScript("OnClick", function(self)
	self:SetChecked(true) -- force check
	for i = 1, 12 do
		classFilterCBs[gra.CLASS_ORDER[i]]:SetChecked(true)
		GRA_Config["classFilter"][gra.CLASS_ORDER[i]] = true
	end
	-- reload sheet
	GRA:ShowAttendanceSheet()
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
	classFilterCBs[class] = GRA:CreateCheckButton(statusFrame, "", nil, function(checked)
		GRA_Config["classFilter"][class] = checked
		refreshCB_ALL()
		-- reload sheet
		GRA:ShowAttendanceSheet()
	end, nil, GRA:GetLocalizedClassName(class), L["Check to show this class."]) --, L["Check to show this class.\nFrequently clicking will cause high memory usage."])

	-- class color
	classFilterCBs[class]:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox-Normal-]] .. class)
	classFilterCBs[class]:SetHighlightTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox-Highlight-]] .. class, "ADD")
	classFilterCBs[class]:SetCheckedTexture([[Interface\AddOns\GuildRaidAttendance\Media\CheckBox-Checked-]] .. class)

	if lastCB then
		classFilterCBs[class]:SetPoint("LEFT", lastCB, "RIGHT", -19, 0)
	else
		classFilterCBs[class]:SetPoint("LEFT", -9, 0)
	end
	lastCB = classFilterCBs[class]
end

classFilterCBs["ALL"]:SetPoint("LEFT", lastCB, "RIGHT", -10, 0)

-----------------------------------------
-- refresh button & date picker
-----------------------------------------
-- force refresh
local refreshCD = 10
local refreshBtn = GRA:CreateButton(statusFrame, L["Refresh"], nil, {55, 20}, "GRA_FONT_SMALL")
-- refreshBtn:SetPoint("BOTTOMRIGHT", 0, 1)
refreshBtn:SetFrameLevel(8)
refreshBtn:SetScript("OnClick", function()
	if GRA_Config["useEPGP"] then
		GRA:RefreshEPGP()
	end
	GRA:ShowAttendanceSheet()
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
local datePicker = GRA:CreateDatePicker(statusFrame, 70, 20, function(d)
	GRA_Config["startDate"] = d
	GRA:ShowAttendanceSheet()
end)
datePicker:SetPoint("RIGHT", refreshBtn, "LEFT", 1, 0)
datePicker:SetFrameLevel(8)

-----------------------------------------
-- sheet legend
-----------------------------------------
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
	GRA_Tooltip:AddLine("|cffFFFF00" .. L["Yellow"] .. "|r - |cffFFFFFF" .. L["Late"])
	GRA_Tooltip:AddLine("|cffFF0000" .. L["Red"] .. "|r - |cffFFFFFF" .. L["Absent"])
	GRA_Tooltip:AddLine("|cffFF00FF" .. L["Magenta"] .. "|r - |cffFFFFFF" .. L["On Leave"])
	GRA_Tooltip:Show()
end)

legendFrame:SetScript("OnLeave", function(self)
	GRA_Tooltip:Hide()
end)

-----------------------------------------
-- sheet header frame
-----------------------------------------
local newWidth
local headerFrame = CreateFrame("Frame", nil, attendanceFrame)
headerFrame:SetPoint("TOPLEFT", attendanceFrame)
headerFrame:SetPoint("BOTTOMRIGHT", attendanceFrame.scrollFrame, "TOPRIGHT")
headerFrame:EnableMouse(true)
headerFrame:SetFrameLevel(7)

local nameText = GRA:CreateGrid(headerFrame, 75, L["Name"], GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], "|cffFFD100" .. L["Left Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by name."] .. "\n|cffFFD100" .. L["Right Click: "] .. "|cffFFFFFF" .. L["Sort attendance sheet by class."])
nameText:GetFontString():ClearAllPoints()
nameText:GetFontString():SetWidth(70)
nameText:GetFontString():SetPoint("BOTTOMLEFT", 5, 1)
nameText:GetFontString():SetJustifyH("LEFT")
nameText:SetPoint("BOTTOMLEFT", headerFrame)
nameText:RegisterForClicks("LeftButtonUp", "RightButtonUp")
nameText:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		SortSheetByName()
		GRA:Print(L["Sort attendance sheet by name."])
	elseif button == "RightButton" then
		SortSheetByClass()
		GRA:Print(L["Sort attendance sheet by class."])
	end
end)

local epText = GRA:CreateGrid(headerFrame, 45, "EP", GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], L["Sort attendance sheet by EP."])
epText:GetFontString():ClearAllPoints()
epText:GetFontString():SetPoint("BOTTOM", 0, 1)
epText:SetScript("OnClick", function()
	SortSheetByEP()
	GRA:Print(L["Sort attendance sheet by EP."])
end)

local gpText = GRA:CreateGrid(headerFrame, 45, "GP", GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], L["Sort attendance sheet by GP."])
gpText:GetFontString():ClearAllPoints()
gpText:GetFontString():SetPoint("BOTTOM", 0, 1)
gpText:SetScript("OnClick", function()
	SortSheetByGP()
	GRA:Print(L["Sort attendance sheet by GP."])
end)

local prText = GRA:CreateGrid(headerFrame, 45, "PR", GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], L["Sort attendance sheet by PR."])
prText:GetFontString():ClearAllPoints()
prText:GetFontString():SetPoint("BOTTOM", 0, 1)
prText:SetScript("OnClick", function()
	SortSheetByPR()
	GRA:Print(L["Sort attendance sheet by PR."])
end)

local ar30Text = GRA:CreateGrid(headerFrame, 45, "AR 30", GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], L["Sort attendance sheet by attendance rate (30 days)."])
ar30Text:GetFontString():ClearAllPoints()
ar30Text:GetFontString():SetPoint("BOTTOM", 0, 1)
ar30Text:SetScript("OnClick", function()
	SortSheetByAR30()
	GRA:Print(L["Sort attendance sheet by attendance rate (30 days)."])
end)

local ar60Text = GRA:CreateGrid(headerFrame, 45, "AR 60", GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], L["Sort attendance sheet by attendance rate (60 days)."])
ar60Text:GetFontString():ClearAllPoints()
ar60Text:GetFontString():SetPoint("BOTTOM", 0, 1)
ar60Text:SetScript("OnClick", function()
	SortSheetByAR60()
	GRA:Print(L["Sort attendance sheet by attendance rate (60 days)."])
end)

local ar90Text = GRA:CreateGrid(headerFrame, 45, "AR 90", GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], L["Sort attendance sheet by attendance rate (90 days)."])
ar90Text:GetFontString():ClearAllPoints()
ar90Text:GetFontString():SetPoint("BOTTOM", 0, 1)
ar90Text:SetScript("OnClick", function()
	SortSheetByAR90()
	GRA:Print(L["Sort attendance sheet by attendance rate (90 days)."])
end)

local arLifetimeText = GRA:CreateGrid(headerFrame, 45, "AR", GRA:Debug() and {1,0,0,.2}, false, L["Sort: "], L["Sort attendance sheet by attendance rate (lifetime)."])
arLifetimeText:GetFontString():ClearAllPoints()
arLifetimeText:GetFontString():SetPoint("BOTTOM", 0, 1)
arLifetimeText:SetScript("OnClick", function()
	SortSheetByAR()
	GRA:Print(L["Sort attendance sheet by attendance rate (lifetime)."])
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
		if tContains(days, temp) then
			firstRaidDay = temp
			break
		end
		temp = (temp == 7) and 1 or (temp + 1)
	end

	local startDate = GRA_Config["startDate"]
	for i = 1, weeks do
		for j = 1, 7 do -- 7 days
			local wday = select(2, GRA:DateToWeekday(startDate))
			if tContains(days, wday) then -- is a raid day
				-- color first day for every raid lockouts period
				-- one day per week = white
				if daysPerWeek ~= 1 and (wday == gra.RAID_LOCKOUTS_RESET or wday == firstRaidDay) then
					color = gra.colors.firebrick.s
				else
					color = "|cffFFFFFF"
				end
				dateGrids[#dateGrids+1] = GRA:CreateGrid(headerFrame, gra.size.grid_dates, color..GRA:FormatDateHeader(startDate), GRA:Debug() and {1,0,0,.2})
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
			startDate = GRA:NextDate(startDate)
		end
	end
end

function GRA:SetColumns()
	-- set point left, align left
	LPP:PixelPerfectPoint(gra.mainFrame)
	-- re-set mainFrame width
	-- local width = GRA:Round(dateGrids[#dateGrids]:GetRight() - nameText:GetLeft() + 16)
	-- local width2 = 75+(45*3)-3+16+(#dateGrids*30)-#dateGrids
	-- print(width2)
	-- newWidth = 16 + 75 + (#dateGrids * 30) - #dateGrids
	newWidth = 16 + gra.size.grid_name + (#dateGrids * gra.size.grid_dates) - #dateGrids
	if #loaded > 15 then -- space for scroll bar
		newWidth = newWidth + 7
	end

	local lastColumn = nameText

	if GRA_Config["useEPGP"] then
		epText:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		epText:Show()
		gpText:SetPoint("LEFT", epText, "RIGHT", -1, 0)
		gpText:Show()
		prText:SetPoint("LEFT", gpText, "RIGHT", -1, 0)
		prText:Show()
		newWidth = newWidth + gra.size.grid_others * 3 - 3
		lastColumn = prText

		minEPText:Show()
		baseGPText:Show()
		decayText:Show()
	else
		epText:Hide()
		gpText:Hide()
		prText:Hide()

		-- hide MinEP BaseGP Decay
		minEPText:Hide()
		baseGPText:Hide()
		decayText:Hide()
	end

	if GRA_Config["columns"]["AR_30"] then
		ar30Text:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		ar30Text:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = ar30Text
	else
		ar30Text:Hide()
	end

	if GRA_Config["columns"]["AR_60"] then
		ar60Text:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		ar60Text:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = ar60Text
	else
		ar60Text:Hide()
	end

	if GRA_Config["columns"]["AR_90"] then
		ar90Text:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		ar90Text:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = ar90Text
	else
		ar90Text:Hide()
	end

	if GRA_Config["columns"]["AR_Lifetime"] then
		arLifetimeText:SetPoint("LEFT", lastColumn, "RIGHT", -1, 0)
		arLifetimeText:Show()
		newWidth = newWidth + gra.size.grid_others - 1
		lastColumn = arLifetimeText
	else
		arLifetimeText:Hide()
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

-----------------------------------------
-- sheet data function
-----------------------------------------
-- for EPGPOptions only
function GRA:RecalcPR()
	local baseGP = tonumber(GRA_Config["raidInfo"]["EPGP"][1])
	local minEP = GRA_Config["raidInfo"]["EPGP"][2]
	for _, row in pairs(loaded) do
		local ep = GRA_Roster[row.name]["EP"]
		local gp = GRA_Roster[row.name]["GP"]
		GRA:UpdatePlayerData(row.name, ep, gp, true)
	end
	-- sort after recalc
	SortSheet(GRA_Config["sortKey"])
end

function GRA:UpdatePlayerData(name, ep, gp, noSort)
	local baseGP = GRA_Config["raidInfo"]["EPGP"][1]
	local minEP = GRA_Config["raidInfo"]["EPGP"][2]
	for _, row in pairs(loaded) do
		if row.name == name then
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
			break
		end
	end

	if not noSort then
		-- auto sort after data updated
		SortSheet(GRA_Config["sortKey"])
	end
end

-----------------------------------------
-- attendance rate function
-----------------------------------------
ShowAR = function()
	-- GRA:Debug("|cff1E90FFShow attendance rate")
	for _, row in pairs(loaded) do
		local att30 = GRA_Roster[row.name]["att30"] or {0, 0}
		local att60 = GRA_Roster[row.name]["att60"] or {0, 0}
		local att90 = GRA_Roster[row.name]["att90"] or {0, 0}
		local attLifetime = GRA_Roster[row.name]["attLifetime"] or {0, 0, 0, 0}
		
		-- attendance count
		row.att30 = att30[1]
		row.att60 = att60[1]
		row.att90 = att90[1]
		row.attLifetime = attLifetime[1]
		
		-- attendance rate
		row.ar30 = tonumber(format("%.1f", att30[1]/(att30[1]+att30[2])*100)) or 0
		row.ar60 = tonumber(format("%.1f", att60[1]/(att60[1]+att60[2])*100)) or 0
		row.ar90 = tonumber(format("%.1f", att90[1]/(att90[1]+att90[2])*100)) or 0
		row.arLifetime = tonumber(format("%.1f", attLifetime[1]/(attLifetime[1]+attLifetime[2])*100)) or 0

		row.ar30Grid:SetText(row.ar30 .. "%")
		row.ar60Grid:SetText(row.ar60 .. "%")
		row.ar90Grid:SetText(row.ar90 .. "%")
		row.arLifetimeGrid:SetText(row.arLifetime .. "%")
		
		-- tooltip
		row.ar30Grid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA:GetClassColoredName(row.name))
			GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att30[1])
			GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att30[2])
			-- GRA_Tooltip:AddDoubleLine(L["Late"] .. ": ", "|cffffffff" .. "nil")
			-- GRA_Tooltip:AddDoubleLine(L["On Leave"] .. ": ", "|cffffffff" .. "nil")
			GRA_Tooltip:Show()
		end)
		row.ar30Grid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

		row.ar60Grid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA:GetClassColoredName(row.name))
			GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att60[1])
			GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att60[2])
			-- GRA_Tooltip:AddDoubleLine(L["Late"] .. ": ", "|cffffffff" .. "nil")
			-- GRA_Tooltip:AddDoubleLine(L["On Leave"] .. ": ", "|cffffffff" .. "nil")
			GRA_Tooltip:Show()
		end)
		row.ar60Grid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

		row.ar90Grid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA:GetClassColoredName(row.name))
			GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. att90[1])
			GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. att90[2])
			-- GRA_Tooltip:AddDoubleLine(L["Late"] .. ": ", "|cffffffff" .. "nil")
			-- GRA_Tooltip:AddDoubleLine(L["On Leave"] .. ": ", "|cffffffff" .. "nil")
			GRA_Tooltip:Show()
		end)
		row.ar90Grid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)

		row.arLifetimeGrid:HookScript("OnEnter", function(self)
			GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
			GRA_Tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 0)
			GRA_Tooltip:AddLine(GRA:GetClassColoredName(row.name))
			GRA_Tooltip:AddDoubleLine(L["Present"] .. ": ", "|cff00ff00" .. attLifetime[1])
			GRA_Tooltip:AddDoubleLine(L["Absent"] .. ": ", "|cffff0000" .. attLifetime[2])
			GRA_Tooltip:AddDoubleLine(L["Late"] .. ": ", "|cffffff00" .. attLifetime[3])
			GRA_Tooltip:AddDoubleLine(L["On Leave"] .. ": ", "|cffff00ff" .. attLifetime[4])
			GRA_Tooltip:Show()
		end)
		row.arLifetimeGrid:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)
	end
end

local calcARProgressFrame
local function ShowCalcARProgressFrame(maxValue)
	if not calcARProgressFrame then
		calcARProgressFrame = CreateFrame("Frame", nil, attendanceFrame.scrollFrame)
		GRA:StylizeFrame(calcARProgressFrame, {.1, .1, .1, .95}, {0, 0, 0, 0})
		calcARProgressFrame:SetSize(156, 18)
		calcARProgressFrame:SetPoint("BOTTOMLEFT", attendanceFrame.scrollFrame, 1, 1)
		calcARProgressFrame:Hide()

		local bar = CreateFrame("StatusBar", nil, calcARProgressFrame)
		calcARProgressFrame.bar = bar
		LSSB:SmoothBar(bar) -- smooth progress bar
		bar.tex = bar:CreateTexture()
		bar.tex:SetColorTexture(.5, 1, 0, .8)
		bar:SetStatusBarTexture(bar.tex)
		bar:GetStatusBarTexture():SetHorizTile(false)
		bar:SetHeight(2)
		bar:SetWidth(155)
		bar:SetPoint("BOTTOMLEFT")
		-- bar:SetPoint("BOTTOMRIGHT", frame, -5, 5)
		bar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = -1})
		bar:SetBackdropColor(.07, .07, .07, .9)
		bar:SetBackdropBorderColor(0, 0, 0, 1)

		bar.text = bar:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
		bar.text:SetJustifyH("RIGHT")
		bar.text:SetJustifyV("MIDDLE")
		bar.text:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 2, 2)
		bar.text:SetText(L["Updating attendance rate..."])

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

		calcARProgressFrame.fadeIn:SetScript("OnPlay", function()
			calcARProgressFrame.fadeOut:Stop() -- if hiding
			calcARProgressFrame:Show()
		end)

		calcARProgressFrame.fadeOut:SetScript("OnFinished", function()
			calcARProgressFrame:Hide()
		end)

		calcARProgressFrame:SetScript("OnHide", function()
			-- LSSB:ResetBar(bar) -- disable smooth
			-- bar:SetValue(0)
			-- LSSB:SmoothBar(bar) -- re-enable smooth
		end)

		function calcARProgressFrame:SetValue(value)
			bar:SetValue(value)
		end
	end

	calcARProgressFrame.bar:SetMinMaxValues(0, maxValue)
	LSSB:ResetBar(calcARProgressFrame.bar) -- disable smooth
	calcARProgressFrame.bar:SetValue(0)
	LSSB:SmoothBar(calcARProgressFrame.bar) -- re-enable smooth
	calcARProgressFrame.bar:SetScript("OnValueChanged", function(self, value)
		-- print(value)
		if value == maxValue then
			calcARProgressFrame.timer = C_Timer.After(3, function()
				calcARProgressFrame.fadeOut:Play()
			end)
		end
	end)

	if calcARProgressFrame.timer then
		calcARProgressFrame.timer:Cancel()
	end
	calcARProgressFrame.fadeIn:Play()
end

-- admin only, calculate AR
CalcAR = function()
	if gra.isAdmin == nil then -- wait for GRA_PERMISSION
		GRA:RegisterEvent("GRA_PERMISSION", "CalcAR_CheckPermission", function()
			CalcAR()
		end)
		return
	elseif gra.isAdmin == false then -- not admin
		return
	end
	
	if GRA:Getn(GRA_RaidLogs) ~= 0 then
		ShowCalcARProgressFrame(GRA:Getn(GRA_RaidLogs))
		GRA:Debug("|cff1E90FFCalculating attendance rate...")
	else
		GRA:Debug("|cff1E90FFClear attendance rate...")
	end

	local today = GRA:Date()
	local playerAtts = {}
	for n, _ in pairs(GRA_Roster) do
		playerAtts[n] = {
			-- {present, absent, late, onLeave}
			["30"] = {0, 0},
			["60"] = {0, 0},
			["90"] = {0, 0},
			["lifetime"] = {0, 0, 0, 0},
		}
	end

	local n = 1
	-- calc
	for d, l in pairs(GRA_RaidLogs) do
		-- count PRESENT
		for name, t in pairs(l["attendees"]) do
			if playerAtts[name] then -- exists in roster
				playerAtts[name]["lifetime"][1] = playerAtts[name]["lifetime"][1] + 1
				if t[1] == "LATE" then
					playerAtts[name]["lifetime"][3] = playerAtts[name]["lifetime"][3] + 1
				end
				
				if GRA:DateOffset(d, today) < 90 then
					playerAtts[name]["90"][1] = playerAtts[name]["90"][1] + 1
				end
				if GRA:DateOffset(d, today) < 60 then
					playerAtts[name]["60"][1] = playerAtts[name]["60"][1] + 1
				end
				if GRA:DateOffset(d, today) < 30 then
					playerAtts[name]["30"][1] = playerAtts[name]["30"][1] + 1
				end
			end
		end
		-- count ABSENT
		for name, reason in pairs(l["absentees"]) do
			if playerAtts[name] then -- exists in roster
				playerAtts[name]["lifetime"][2] = playerAtts[name]["lifetime"][2] + 1
				if reason ~= "" then
					playerAtts[name]["lifetime"][4] = playerAtts[name]["lifetime"][4] + 1
				end
				
				if GRA:DateOffset(d, today) < 90 then
					playerAtts[name]["90"][2] = playerAtts[name]["90"][2] + 1
				end
				if GRA:DateOffset(d, today) < 60 then
					playerAtts[name]["60"][2] = playerAtts[name]["60"][2] + 1
				end
				if GRA:DateOffset(d, today) < 30 then
					playerAtts[name]["30"][2] = playerAtts[name]["30"][2] + 1
				end
			end
		end
		calcARProgressFrame:SetValue(n)
		n = n + 1
	end

	-- save
	for name, t in pairs(GRA_Roster) do
		local present30, absent30 = playerAtts[name]["30"][1], playerAtts[name]["30"][2]
		local present60, absent60 = playerAtts[name]["60"][1], playerAtts[name]["60"][2]
		local present90, absent90 = playerAtts[name]["90"][1], playerAtts[name]["90"][2]
		local presentL, absentL = playerAtts[name]["lifetime"][1], playerAtts[name]["lifetime"][2]

		t["att30"] = {playerAtts[name]["30"][1], playerAtts[name]["30"][2]}
		t["att60"] = {playerAtts[name]["60"][1], playerAtts[name]["60"][2]}
		t["att90"] = {playerAtts[name]["90"][1], playerAtts[name]["90"][2]}
		t["attLifetime"] = {playerAtts[name]["lifetime"][1], playerAtts[name]["lifetime"][2], playerAtts[name]["lifetime"][3], playerAtts[name]["lifetime"][4]}
	end

	ShowAR()

	-- re-sort by attendance rate
	-- if string.find(GRA_Config["sortKey"], "ar") then
		SortSheet(GRA_Config["sortKey"])
	-- end
end

-----------------------------------------
-- sheet grid function
-----------------------------------------
local gps, eps = {}, {} -- details
local todaysGP, todaysEP = {}, {} -- points
local function CountByDate(d)
	if GRA_RaidLogs[d] then
		gps[d] = {}
		eps[d] = {}
		todaysGP[d] = {}
		todaysEP[d] = {}

		local details = GRA_RaidLogs[d]["details"]
		-- scan each gp/ep
		for _, detail in pairs(details) do
			if detail[1] == "GP" then
				local name = detail[4]
				-- if type(detail[4]) ~= "table" then detail[4] = {detail[4]} end -- convert old format
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
			else -- PGP
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

local function CountByDate_NonEPGP(d)
	if GRA_RaidLogs[d] then
		gps[d] = {}
		eps[d] = {}
		todaysGP[d] = {}
		todaysEP[d] = {}

		local details = GRA_RaidLogs[d]["details"]
		-- scan each gp
		for _, detail in pairs(details) do
			if detail[1] == "GP" then
				local name = detail[4]
				if not gps[d][name] then gps[d][name] = {["loots"] = 0} end
				gps[d][name]["loots"] = gps[d][name]["loots"] + 1 -- store loot num
				table.insert(gps[d][name], "|cffffffff" .. detail[3] .. " |cffffffff" .. (detail[5] or ""))
			end
		end
	end
end

local function CountAll()
	gps, eps = {}, {}
	-- count each day in sheet
	for k, dateGrid in pairs(dateGrids) do
		local d = dateGrid.date
		if GRA_Config["useEPGP"] then
			CountByDate(d)
		else
			CountByDate_NonEPGP(d)
		end
	end
	-- texplore(gps)
end

local function UpdateGrid(g, d, name)
	-- set gp detail
	local gp = gps[d][name]
	-- if gp then g:SetText(#gp) end
	if gp then g:SetText(gp["loots"]) end

	-- set ep detail
	local ep = eps[d][name]

	-- set attendance (color grid)
	if GRA_RaidLogs[d]["attendees"][name] then
		g:SetAttendance(GRA_RaidLogs[d]["attendees"][name][1])
	else 
		g:SetAttendance(GRA_RaidLogs[d]["absentees"][name])
	end

	g:SetScript("OnEnter", function()
		g.onEnter()

		GRA_Tooltip:SetOwner(g, "ANCHOR_NONE")
		GRA_Tooltip:SetPoint("BOTTOMRIGHT", g, "BOTTOMLEFT", 1, 0)
		GRA_Tooltip:AddLine(GRA:GetClassColoredName(name))

		local blankLine = false
		-- join time
		if GRA_RaidLogs[d]["attendees"][name] then
			GRA_Tooltip:AddLine(L["Join Time: "] .. GRA:SecondsToTime(GRA_RaidLogs[d]["attendees"][name][2]))
			GRA_Tooltip:Show()
			blankLine = true
		end


		-- on leave
		if GRA_RaidLogs[d]["absentees"][name] and GRA_RaidLogs[d]["absentees"][name] ~= "" then
			GRA_Tooltip:AddLine(GRA_RaidLogs[d]["absentees"][name])
			GRA_Tooltip:Show()
			blankLine = true
		end

		if todaysEP[d][name] then
			if blankLine then GRA_Tooltip:AddLine(" ") blankLine = false end
			GRA_Tooltip:AddLine(L["Today's EP: "] .. todaysEP[d][name])
		end

		if ep then
			for _, v in pairs(ep) do
				GRA_Tooltip:AddLine(v)
			end
			GRA_Tooltip:Show()
			blankLine = true
		end

		if todaysGP[d][name] then
			if blankLine then GRA_Tooltip:AddLine(" ") blankLine = false end
			GRA_Tooltip:AddLine(L["Today's GP: "] .. todaysGP[d][name])
		end

		if gp then
			for k, v in pairs(gp) do
				if k ~= "loots" then GRA_Tooltip:AddLine(v) end
			end
			GRA_Tooltip:Show()
		end
	end)

	g:SetScript("OnLeave", function()
		g.onLeave()
		GRA_Tooltip:Hide()
	end)
end

local function LoadRowDetail(row)
	for k, g in pairs(row.dateGrids) do
		local d = dateGrids[k].date
		
		if GRA_RaidLogs[d] then
			UpdateGrid(g, d, row.name)
		end
	end
end

-- update grids after awarding ep or crediting ep or changing attendance
local function RefreshDetailsByDate(d)
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

	-- if no logs exist, deleted
	if not GRA_RaidLogs[d] then
		-- empty grids and remove tooltips
		for _, row in pairs(loaded) do
			local g = row.dateGrids[index]
			g:SetAttendance(nil)
			g:SetText("")
			g:SetScript("OnEnter", g.onEnter)
			g:SetScript("OnLeave", g.onLeave)
		end
		return
	end

	-- count on this day
	if GRA_Config["useEPGP"] then
		CountByDate(d)
	else
		CountByDate_NonEPGP(d)
	end

	for _, row in pairs(loaded) do
		local g = row.dateGrids[index]
		UpdateGrid(g, d, row.name)
	end
end

function GRA:RefreshSheetByDates(dates)
	for _, d in pairs(dates) do
		RefreshDetailsByDate(d)
	end
end

GRA:RegisterEvent("GRA_EPGP", "AttendanceSheet_DetailsRefresh", RefreshDetailsByDate)
GRA:RegisterEvent("GRA_EPGP_MODIFY", "AttendanceSheet_DetailsRefresh", RefreshDetailsByDate)
GRA:RegisterEvent("GRA_EPGP_UNDO", "AttendanceSheet_DetailsRefresh", RefreshDetailsByDate)

-- raid logs (attendance) changed
local refreshTimer
GRA:RegisterEvent("GRA_RAIDLOGS", "AttendanceSheet_DetailsRefresh", function(d)
	-- update ONCE EVERY 1S!!!
	if refreshTimer then
		refreshTimer:Cancel()
		refreshTimer = nil
	end

	refreshTimer = C_Timer.NewTimer(1, function()
		RefreshDetailsByDate(d)
		CalcAR()
		refreshTimer = nil

		-- attendance rate may changed, re-sort
		SortSheet(GRA_Config["sortKey"])
	end)
end)

-- raid logs deleted
GRA:RegisterEvent("GRA_LOGS_DEL", "AttendanceSheet_DetailsRefresh", function(dates)
	GRA:RefreshSheetByDates(dates)
	CalcAR()
	SortSheet(GRA_Config["sortKey"])
end)

-- raid start time update
GRA:RegisterEvent("GRA_ST_UPDATE", "AttendanceSheet_StartTimeUpdate", function(d)
	GRA:Debug("|cff66CD00GRA_ST_UPDATE:|r " .. (d or "GLOBAL"))
	GRA:UpdateAttendance(d)
	if d then
		RefreshDetailsByDate(d)
	else -- update all
		GRA:ShowAttendanceSheet()
	end
end)

-- system changed
GRA:RegisterEvent("GRA_SYSTEM", "AttendanceSheet_SystemChanged", function(system)
	if GRA:Getn(GRA_Roster) == 0 then return end
	-- show columns
	GRA:SetColumns()
	-- refresh tooltip
	gps, eps = {}, {}
	for _, dateGrid in pairs(dateGrids) do
		RefreshDetailsByDate(dateGrid.date)
	end
end)

-- refresh on raid logs received
GRA:RegisterEvent("GRA_LOGS_DONE", "AttendanceFrame_LogsReceived", function(count, dates)
	GRA:RefreshSheetByDates(dates)
	-- refresh attendance rate
	ShowAR()
end)

-----------------------------------------
-- load sheet (create row)
-----------------------------------------
local function LoadSheet()
	CountAll()
	for pName, pTable in pairs(GRA_Roster) do
		-- filter class
		if GRA_Config["classFilter"][pTable["class"]] then
			local shortName = GRA:GetShortName(pName)
			local color = RAID_CLASS_COLORS[pTable["class"]].colorStr
			local row = GRA:CreateRow(attendanceFrame.scrollFrame.content, attendanceFrame.scrollFrame:GetWidth(), "|c" .. color .. shortName .. "|r",
				function() print("Show details (WIP): " .. pName) end)
			row["name"] = pName -- sort key
			row["class"] = pTable["class"] -- sort key
			
			-- prepare for sorting (or it may be nil)
			row.ep = pTable["EP"] or 0
			row.gp = pTable["GP"] or 0
			row.pr = row.ep / (row.gp + GRA_Config["raidInfo"]["EPGP"][1])
			
			-- disabled in minimal mode
			if not GRA_Config["minimalMode"] then
				row:CreateGrid(#dateGrids)
				LoadRowDetail(row)
			end
			
			table.insert(loaded, row)
			attendanceFrame.scrollFrame:SetWidgetAutoWidth(row)
			-- attendanceFrame.loaded = attendanceFrame.loaded + 1
		end
	end
end

local function HideAll()
	loaded = {} -- clear

	statusFrame:Hide()
	headerFrame:Hide()
	for i = 1, #dateGrids do
		dateGrids[i]:ClearAllPoints()
		dateGrids[i]:Hide()
	end
	dateGrids = {} -- clear

	-- attendanceFrame.loaded = 0
	attendanceFrame.scrollFrame:Reset()
end

function GRA:ShowAttendanceSheet()
	HideAll()

	if GRA:Getn(GRA_Roster) ~= 0 then
		GRA:Debug("|cff1E90FFLoading attendance sheet|r")
		
		if not GRA_Config["minimalMode"] then CreateDateHeader() end
		LoadSheet()
		-- after sheet row loaded set columns and WIDTH!!!
		GRA:SetColumns()
		-- load attendance rate
		ShowAR()

		headerFrame:Show()
		statusFrame:Show()

		-- sort
		SortSheet(GRA_Config["sortKey"])

		membersText:SetText("|cff80FF00" .. L["Members: "] .. "|r" .. GRA:Getn(GRA_Roster))
		attendanceFrame:UpdateEPGPStrings()

		if attendanceFrame.scrollFrame.mask then attendanceFrame.scrollFrame.mask:Hide() end
	else
		-- print("No member!")
		GRA:CreateMask(attendanceFrame.scrollFrame, L["No member"], {1, -1, -1, 1})
	end

	-- schedule changed (mainFrame's width changed) may cause frame not pixel perfect, fix it!
	LPP:PixelPerfectPoint(gra.mainFrame)

	if GRA_Config["useEPGP"] then
		-- register/unregister GUILD_OFFICER_NOTE_CHANGED
		GRA:UpdateRosterEPGP()
	end
end

local function EnableMiniMode(f)
	if f then
		legendFrame:Hide()
		datePicker:Hide()
		refreshBtn:ClearAllPoints()
		refreshBtn:SetPoint("BOTTOMRIGHT", gra.mainFrame, -62, 5)
		
		membersText:ClearAllPoints()
		membersText:SetPoint("TOPLEFT", 0, -20)
		decayText:ClearAllPoints()
		decayText:SetPoint("TOPLEFT", 0, -38)
	else
		-- reset frame width
		gra.mainFrame:SetWidth(gra.size.mainFrame[1])

		legendFrame:Show()
		datePicker:Show()
		refreshBtn:ClearAllPoints()
		refreshBtn:SetPoint("BOTTOMRIGHT", 0, 1)
		
		membersText:ClearAllPoints()
		membersText:SetPoint("LEFT", 245, 0)
		decayText:ClearAllPoints()
		decayText:SetPoint("LEFT", baseGPText, "RIGHT", 10, 0)
		-- decayText:ClearAllPoints()
		-- decayText:SetPoint("LEFT", baseGPText, "RIGHT", 10, 0)
	end
end

GRA:RegisterEvent("GRA_MINI", "AttendanceFrame_MiniMode", function(enabled)
	EnableMiniMode(enabled)
	GRA:ShowAttendanceSheet()
end)

-----------------------------------------
-- script
-----------------------------------------
attendanceFrame:SetScript("OnShow", function()
	EnableMiniMode(GRA_Config["minimalMode"])
	LPP:PixelPerfectPoint(gra.mainFrame)
	if newWidth then gra.mainFrame:SetWidth(newWidth) end

	-- class filter
	for class,checked in pairs(GRA_Config["classFilter"]) do
		classFilterCBs[class]:SetChecked(checked)
		-- print(class .. (checked and "√" or "×"))
	end
	refreshCB_ALL()

	datePicker:SetDate(GRA_Config["startDate"])
	
	-- TODO: don't sort every time
	if #loaded ~= 0 then -- already loaded
		-- sort on show!
		SortSheet(GRA_Config["sortKey"])
		return
	end

	GRA:ShowAttendanceSheet()
	-- admin calc attendance rate
	CalcAR()
end)

attendanceFrame:SetScript("OnHide", function()
	legendFrame:Hide()
end)

if GRA:Debug() then
	-- GRA:StylizeFrame(attendanceFrame, {.5, 0, 0, 0})
	GRA:StylizeFrame(headerFrame, {0, .7, 0, .1}, {0, 0, 0, 0})
	-- GRA:StylizeFrame(statusFrame, {1, 0, 0, .1}, {0, 0, 0, 0})
end

-----------------------------------------
-- resize
-----------------------------------------
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