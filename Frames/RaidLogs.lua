local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local dates, sortedDates, details = {}, {}, {}
local selected = 1
-----------------------------------------
-- raid logs frame
-----------------------------------------
local raidLogsFrame = CreateFrame("Frame", "GRA_RaidLogsFrame", gra.mainFrame)
raidLogsFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, -30)
raidLogsFrame:SetPoint("TOPRIGHT", gra.mainFrame, -8, -30)
raidLogsFrame:SetHeight(341)
raidLogsFrame:Hide()
gra.raidLogsFrame = raidLogsFrame

-----------------------------------------
-- title
-----------------------------------------
local titleFrame = CreateFrame("Frame", nil, raidLogsFrame)
titleFrame:SetPoint("TOPLEFT")
titleFrame:SetPoint("BOTTOMRIGHT", raidLogsFrame, "TOPRIGHT", 0, -16)

local titleText = titleFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
titleText:SetPoint("LEFT", 5, 0)
local function UpdateTitleText(d)
	titleText:SetText("|cff80FF00" .. L["Raids: "] .. "|r" .. GRA:Getn(_G[GRA_R_RaidLogs])
		.. "    |cff80FF00" .. L["Current: "] .. "|r" .. date("%x", GRA:DateToSeconds(d))
		.. "    |cff80FF00" .. L["Raid Hours"] .. ":|r " .. GRA:GetRaidStartTime(d) .. " - " ..  GRA:GetRaidEndTime(d))
end

-----------------------------------------
-- status frame
-----------------------------------------
local statusFrame = CreateFrame("Frame", nil, raidLogsFrame)
statusFrame:SetPoint("TOPLEFT", raidLogsFrame, "BOTTOMLEFT", 0, 20)
statusFrame:SetPoint("BOTTOMRIGHT")

-----------------------------------------
-- date list
-----------------------------------------
local listFrame = CreateFrame("Frame", nil, raidLogsFrame)
GRA:StylizeFrame(listFrame, {.5, .5, .5, .1})
listFrame:SetPoint("TOPLEFT", 0, -16)
listFrame:SetPoint("BOTTOMRIGHT", raidLogsFrame, "BOTTOMLEFT", 70, 24)
-- listFrame:SetPoint("TOPRIGHT", raidLogsFrame, "TOPLEFT", 100, 0)
-- listFrame:SetHeight(300)
GRA:CreateScrollFrame(listFrame, 0, 0)
listFrame.scrollFrame:SetScrollStep(15)

-----------------------------------------
-- tabs
-----------------------------------------
local tabs, tabButtons = {}, {}
local currentTab
local function ShowTab(tabToShow, d)
	if not d then d = sortedDates[selected] end
	GRA:Debug("|cffFFC0CBShowTab:|r " .. tabToShow .. " " .. d)
	for n, tab in pairs(tabs) do
		local b = tabButtons[n]
		if n == tabToShow then
			b:SetBackdropColor(unpack(b.hoverColor))
			b:SetScript("OnEnter", nil)
			b:SetScript("OnLeave", nil)
			tab.func(d) -- load content
			tab:Show()
		else
			b:SetBackdropColor(unpack(b.color))
			b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(b.hoverColor)) end)
			b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(b.color)) end)
			tab:Hide()
		end
	end
	currentTab = tabToShow
end

tabButtons["details"] = GRA:CreateButton(titleFrame, L["Details"], "blue-hover", {70, 17})
tabButtons["details"]:SetPoint("BOTTOMRIGHT", 0, -1)
tabButtons["details"]:SetScript("OnClick", function(self)
	ShowTab("details", sortedDates[selected])
end)

tabButtons["attendances"] = GRA:CreateButton(titleFrame, L["Attendances"], "green-hover", {70, 17})
tabButtons["attendances"]:SetScript("OnClick", function(self)
	ShowTab("attendances", sortedDates[selected])
end)

tabButtons["summary"] = GRA:CreateButton(titleFrame, L["Summary"], "red-hover", {70, 17})
tabButtons["summary"]:SetPoint("RIGHT", tabButtons["details"], "LEFT", 1, 0)
tabButtons["summary"]:SetScript("OnClick", function(self)
	ShowTab("summary", sortedDates[selected])
end)

-----------------------------------------
-- summary
-----------------------------------------
local summaryTab = CreateFrame("Frame", "GRA_RaidLogsFrame_Summary", raidLogsFrame)
tabs["summary"] = summaryTab
GRA:StylizeFrame(summaryTab, {.5, .5, .5, .1})
summaryTab:SetPoint("TOPLEFT", listFrame, "TOPRIGHT", 5, 0)
summaryTab:SetPoint("BOTTOMRIGHT", 0, 24)

local attendeesFrame = CreateFrame("Frame", nil, summaryTab)
GRA:StylizeFrame(attendeesFrame, {0, 0, 0, 0})
attendeesFrame:SetPoint("TOPLEFT")
attendeesFrame:SetPoint("RIGHT")
attendeesFrame:SetHeight(46)

local attendeesText = attendeesFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
attendeesText:SetPoint("TOPLEFT", 5, -5)
attendeesText:SetPoint("TOPRIGHT", -5, -5)
attendeesText:SetSpacing(2)
attendeesText:SetWordWrap(true)
attendeesText:SetMaxLines(3)
attendeesText:SetJustifyH("LEFT")
attendeesText:SetJustifyV("TOP")

local absenteesFrame = CreateFrame("Frame", nil, summaryTab)
GRA:StylizeFrame(absenteesFrame, {0, 0, 0, 0})
absenteesFrame:SetPoint("TOPLEFT", attendeesFrame, "BOTTOMLEFT", 0, 1)
absenteesFrame:SetPoint("RIGHT")
absenteesFrame:SetHeight(46)

local absenteesText = absenteesFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
absenteesText:SetPoint("TOPLEFT", 5, -5)
absenteesText:SetPoint("TOPRIGHT", -5, -5)
absenteesText:SetSpacing(2)
absenteesText:SetWordWrap(true)
absenteesText:SetMaxLines(3)
absenteesText:SetJustifyH("LEFT")
absenteesText:SetJustifyV("TOP")

local bossesFrame = CreateFrame("Frame", nil, summaryTab)
GRA:StylizeFrame(bossesFrame, {0, 0, 0, 0})
bossesFrame:SetPoint("TOPLEFT", absenteesFrame, "BOTTOMLEFT", 0, 1)
bossesFrame:SetPoint("BOTTOMRIGHT")
GRA:CreateScrollFrame(bossesFrame, -5, 6)
bossesFrame.scrollFrame:SetScrollStep(41)

local addBossBtn = GRA:CreateButton(summaryTab, L["Add Boss"], "blue", {100, 20})
addBossBtn:SetPoint("BOTTOMRIGHT", statusFrame)
addBossBtn:Hide()
addBossBtn:SetEnabled(false)

local exportBtn = GRA:CreateButton(summaryTab, L["Export to CSV"], "blue", {100, 20})
exportBtn:SetPoint("RIGHT", addBossBtn, "LEFT", -5, 0)
exportBtn:Hide()
exportBtn:SetEnabled(false)

-----------------------------------------
-- attendances
-----------------------------------------
local attendancesTab = CreateFrame("Frame", "GRA_RaidLogsFrame_Attendance", raidLogsFrame)
tabs["attendances"] = attendancesTab
GRA:StylizeFrame(attendancesTab, {.5, .5, .5, .1})
attendancesTab:SetPoint("TOPLEFT", listFrame, "TOPRIGHT", 5, 0)
attendancesTab:SetPoint("BOTTOMRIGHT", 0, 24)
attendancesTab:Hide()
-- attendance editor
gra.attendanceEditor:SetParent(attendancesTab)
gra.attendanceEditor:SetAllPoints(attendancesTab)
gra.attendanceEditor.discardBtn:SetPoint("BOTTOMRIGHT", statusFrame)
gra.attendanceEditor.saveBtn:SetPoint("RIGHT", gra.attendanceEditor.discardBtn, "LEFT", -5, 0)

-----------------------------------------
-- details/loots
-----------------------------------------
local detailsTab = CreateFrame("Frame", "GRA_RaidLogsFrame_Details", raidLogsFrame)
tabs["details"] = detailsTab
GRA:StylizeFrame(detailsTab, {.5, .5, .5, .1})
detailsTab:SetPoint("TOPLEFT", listFrame, "TOPRIGHT", 5, 0)
detailsTab:SetPoint("BOTTOMRIGHT", 0, 24)
detailsTab:Hide()
GRA:CreateScrollFrame(detailsTab, -3, 3)
detailsTab.scrollFrame:SetScrollStep(25)

-- non EPGP/DKP
local recordLootBtn = GRA:CreateButton(detailsTab, L["Record Loot"], "blue", {100, 20})
recordLootBtn:SetPoint("BOTTOMRIGHT", statusFrame)
recordLootBtn:Hide()
recordLootBtn:SetScript("OnClick", function()
	if gra.recordLootFrame:IsShown() then
		gra.recordLootFrame:Hide()
	else
		local d = sortedDates[selected]
		if not d then return end
		GRA:ShowRecordLootFrame(d, nil, nil, nil)
	end
end)

-- EPGP/DKP penalize
local penalizeBtn = GRA:CreateButton(detailsTab, L["Penalize"], "Penalize", {70, 20})
penalizeBtn:SetPoint("BOTTOMRIGHT", statusFrame)
penalizeBtn:SetScript("OnClick", function()
	if gra.penalizeFrame:IsShown() then
		gra.penalizeFrame:Hide()
	else
		local d = sortedDates[selected]
		if not d then return end
		GRA:ShowPenalizeFrame(d, nil, nil, nil, nil)
	end
end)
penalizeBtn:Hide()

local creditBtn = GRA:CreateButton(detailsTab, "XX Credit", "Credit", {70, 20})
creditBtn:SetPoint("RIGHT", penalizeBtn, "LEFT", 1, 0)
creditBtn:SetScript("OnClick", function()
	if gra.creditFrame:IsShown() then
		gra.creditFrame:Hide()
	else
		local d = sortedDates[selected]
		if not d then return end
		GRA:ShowCreditFrame(d, nil, nil, nil, nil)
	end
end)
creditBtn:Hide()

local awardBtn = GRA:CreateButton(detailsTab, "XX Award", "Award", {70, 20})
awardBtn:SetPoint("RIGHT", creditBtn, "LEFT", 1, 0)
awardBtn:SetScript("OnClick", function()
	if gra.awardFrame:IsShown() then
		gra.awardFrame:Hide()
	else
		local d = sortedDates[selected]
		if not d then return end
		GRA:ShowAwardFrame(d, nil, nil, nil)
	end
end)
awardBtn:Hide()

-----------------------------------------
-- status frame buttons
-----------------------------------------
local sendToRaidBtn = GRA:CreateButton(statusFrame, L["Send To Raid"], "blue", {100, 20}, nil, false,
	L["Send selected logs to raid members"],
	L["GRA must be installed to receive data."],
	L["Attendance rate data will be sent ATST."],
	L["Select multiple logs with the Ctrl and Shift keys."])
sendToRaidBtn:SetPoint("BOTTOMLEFT")
sendToRaidBtn:Hide()
sendToRaidBtn:SetScript("OnClick", function()
	local confirm = GRA:CreateConfirmBox(raidLogsFrame, 180, L["Send selected raid logs data to raid/party members?"], function()
		local selectedDates = {}
		for d, b in pairs(dates) do
			if b.isSelected then
				table.insert(selectedDates, d)
			end
		end
		GRA:SendLogsToRaid(selectedDates)
	end, true)
	confirm:SetPoint("CENTER")
end)
-- disabled while sending
sendToRaidBtn:SetScript("OnUpdate", function()
	sendToRaidBtn:SetEnabled(IsInGroup("LE_PARTY_CATEGORY_HOME") and not gra.sending)
end)

local newRaidLogBtn = GRA:CreateButton(statusFrame, L["New Raid Log"], "blue", {100, 20}, nil, false,
	L["Create a new raid log"], L["After creating it, you can manually edit attendance."])
newRaidLogBtn:SetPoint("LEFT", sendToRaidBtn, "RIGHT", 5, 0)
newRaidLogBtn:Hide()
newRaidLogBtn:SetScript("OnClick", function()
	GRA:NewRaidLog(newRaidLogBtn)
end)

local deleteRaidLogBtn = GRA:CreateButton(statusFrame, L["Delete Raid Log"], "blue", {100, 20}, nil, false,
	L["Delete Raid Log"],
	L["Delete selected raid logs."],
	L["Select multiple logs with the Ctrl and Shift keys."])
deleteRaidLogBtn:SetScript("OnClick", function()
	local text = L["Delete selected raid logs?"]
	if gra.isAdmin then
		text = text .. "\n|cffFFFFFF" .. L["This will affect attendance rate!"]
	end
	local confirm = GRA:CreateConfirmBox(raidLogsFrame, 180, gra.colors.firebrick.s .. text, function()
		local selectedDates = {}
		for d, b in pairs(dates) do
			if b.isSelected then
				table.insert(selectedDates, d)
			end
		end
		_G[GRA_R_RaidLogs] = GRA:RemoveElementsByKeys(_G[GRA_R_RaidLogs], selectedDates)
		GRA:Print(L["Deleted raid logs: "] .. GRA:TableToString(selectedDates))
		GRA:FireEvent("GRA_LOGS_DEL", selectedDates)
	end, true)
	confirm:SetPoint("CENTER")
end)

-----------------------------------------
-- tab content functions
-----------------------------------------
local function SortByClass(a, b)
	local classA = _G[GRA_R_Roster][a] and GRA:GetIndex(gra.CLASS_ORDER, _G[GRA_R_Roster][a]["class"]) or "99"
	local classB = _G[GRA_R_Roster][b] and GRA:GetIndex(gra.CLASS_ORDER, _G[GRA_R_Roster][b]["class"]) or "99"
	if classA ~= classB then
		return 	classA < classB
	else
		return a < b
	end
end

-- ShowRaidSummary
summaryTab.func = function(d)
	local t = _G[GRA_R_RaidLogs][d]
	local attendeesString, absenteesString = "", ""

	-- fill table
	local attendees, absentees = GRA:GetAttendeesAndAbsentees(d, true)
	-- sort by class
	table.sort(attendees, function(a, b) return SortByClass(a, b) end)
	table.sort(absentees, function(a, b) return SortByClass(a, b) end)

	for _, n in pairs(attendees) do
		attendeesString = attendeesString .. GRA:GetClassColoredName(n) .. " "
	end
	for _, n in pairs(absentees) do
		absenteesString = absenteesString .. GRA:GetClassColoredName(n) .. " "
	end
	attendeesText:SetText("|cff80FF00" .. L["Attendees"] .. "(" .. GRA:Getn(attendees) .. "): " .. attendeesString)
	absenteesText:SetText("|cff80FF00" .. L["Absentees"] .. "(" .. GRA:Getn(absentees) .. "): " .. absenteesString)

	wipe(attendees)
	wipe(absentees)

	-- bosses
	bossesFrame.scrollFrame:Reset()
	local last
	for _, boss in pairs(t["bosses"]) do
		local b = GRA:CreateBossButton(bossesFrame.scrollFrame.content, boss)
		b:SetPoint("LEFT", 5, 0)
		b:SetPoint("RIGHT", -5, 0)

		if last then
			b:SetPoint("TOP", last, "BOTTOM", 0, -5)
		else
			b:SetPoint("TOP")
		end
		last = b

		if gra.isAdmin then
			b:SetScript("OnClick", function()
				GRA:Print("Editing boss details is WIP.")
			end)
		end
	end

	if bossesFrame.scrollRequired then
		bossesFrame.scrollFrame:SetVerticalScroll(bossesFrame.scrollFrame:GetVerticalScrollRange())
		bossesFrame.scrollRequired = false
	end
end

-- ShowRaidAttendances
attendancesTab.func = function(d)
	GRA:ShowAttendanceEditor(d)
end

-- Show Details/Loots
detailsTab.func = function(d)
	detailsTab.scrollFrame:Reset()
	
	details = {}
	local t = _G[GRA_R_RaidLogs][d]

	local last
	for k, detail in pairs(t["details"]) do
		local b
		
		if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
			b = GRA:CreateDetailButton_EPGP(detailsTab.scrollFrame.content, detail)
		-- elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
		-- 	b = GRA:CreateDetailButton_DKP(detailsTab.scrollFrame.content, detail)
		else -- loot council
			b = GRA:CreateLootButton(detailsTab.scrollFrame.content, detail)
		end
		
		if b then
			b:SetPoint("LEFT", 5, 0)
			b:SetPoint("RIGHT", -5, 0)
			if last then
				b:SetPoint("TOP", last, "BOTTOM", 0, -5)
			else
				b:SetPoint("TOP")
			end
			last = b
			table.insert(details, b)

			-- GRA_Tooltip
			b:HookScript("OnEnter", function()
				-- if detail[1] == "LOOT" then
					if string.find(detail[2], "|Hitem") then
						GRA_Tooltip:SetOwner(b, "ANCHOR_NONE")
						GRA_Tooltip:SetPoint("RIGHT", b, "LEFT", -2, 0)
						GRA_Tooltip:SetHyperlink(detail[2])
					else
						GRA_Tooltip:Hide()
					end
				-- elseif detail[1] == "GP" or detail[1] == "DKP_C" then
				-- 	if string.find(detail[3], "|Hitem") then
				-- 		GRA_Tooltip:SetOwner(b, "ANCHOR_NONE")
				-- 		GRA_Tooltip:SetPoint("RIGHT", b, "LEFT", -2, 0)
				-- 		GRA_Tooltip:SetHyperlink(detail[3])
				-- 	else
				-- 		GRA_Tooltip:Hide()
				-- 	end
				-- else -- EP or DKP_A or Penalize
				-- 	if b.playerText:IsTruncated() then
				-- 		GRA_Tooltip:SetOwner(b, "ANCHOR_NONE")
				-- 		GRA_Tooltip:SetPoint("RIGHT", b, "LEFT", -2, 0)
				-- 		if detail[1] == "EP" then
				-- 			GRA_Tooltip:AddLine(L["EP Award"] .. " (" .. #detail[4] .. ")")
				-- 		elseif detail[1] == "DKP_A" then
				-- 			GRA_Tooltip:AddLine(L["DKP Award"] .. " (" .. #detail[4] .. ")")
				-- 		else
				-- 			GRA_Tooltip:AddLine(L["Penalize"] .. " (" .. #detail[4] .. ")")
				-- 		end
				-- 		for i = 1, #detail[4], 2 do
				-- 			GRA_Tooltip:AddDoubleLine(GRA:GetClassColoredName(detail[4][i]), GRA:GetClassColoredName(detail[4][i+1]))
				-- 		end
				-- 		GRA_Tooltip:Show()
				-- 	end
				-- end
			end)

			b:HookScript("OnLeave", function()
				GRA_Tooltip:Hide()
			end)

			if gra.isAdmin then
				b.deleteBtn:Show()
				if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
					if detail[1] == "GP" then
						b.noteText:SetPoint("RIGHT", -25, 0)
					else
						b.playerText:SetPoint("RIGHT", -25, 0)
					end

					-- delete detail entry
					b.deleteBtn:SetScript("OnClick", function()
						local confirm = GRA:CreateConfirmBox(detailsTab, 200, gra.colors.firebrick.s .. L["Delete this entry and undo changes to %s?"]:format("EP/GP") .. "|r\n" 
						.. detail[3] .. ": " .. detail[2] .. " " .. (string.find(detail[1], "EP") and "EP" or "GP")
						, function()
							if string.find(detail[1], "P") == 1 then
								GRA:UndoPenalizeEPGP(d, k)
							else
								GRA:UndoEPGP(d, k)
							end
							ShowTab("details", d)
							detailsTab.scrollFrame:ResetScroll()
						end, true)
						confirm:SetPoint("CENTER")
					end)

					-- modify detail entry
					b:SetScript("OnClick", function()
						if detail[1] == "EP" then
							GRA:ShowAwardFrame(d, detail[3], detail[2], detail[4], k)
						elseif detail[1] == "GP" then
							GRA:ShowCreditFrame(d, detail[3], detail[2], detail[4], detail[5], k)
						else -- PGP/PEP
							GRA:ShowPenalizeFrame(d, detail[1], detail[3], detail[2], detail[4], k)
						end
					end)

				-- elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
				-- 	if detail[1] == "DKP_C" then
				-- 		b.noteText:SetPoint("RIGHT", -25, 0)
				-- 	else
				-- 		b.playerText:SetPoint("RIGHT", -25, 0)
				-- 	end

				-- 	-- delete detail entry
				-- 	b.deleteBtn:SetScript("OnClick", function()
				-- 		local confirm = GRA:CreateConfirmBox(detailsFrame, 200, gra.colors.firebrick.s .. L["Delete this entry and undo changes to %s?"]:format("DKP") .. "|r\n" 
				-- 		.. detail[3] .. ": " .. detail[2] .. " DKP"
				-- 		, function()
				-- 			if detail[1] == "DKP_P" then
				-- 				GRA:UndoPenalizeDKP(d, k)
				-- 			else
				-- 				GRA:UndoDKP(d, k)
				-- 			end
				-- 			ShowTab("details", d)
				--			detailsTab.scrollFrame:ResetScroll()
				-- 		end, true)
				-- 		confirm:SetPoint("CENTER")
				-- 	end)

				-- 	-- modify detail entry
				-- 	b:SetScript("OnClick", function()
				-- 		if detail[1] == "DKP_A" then
				-- 			GRA:ShowAwardFrame(d, detail[3], detail[2], detail[4], k)
				-- 		elseif detail[1] == "DKP_C" then
				-- 			GRA:ShowCreditFrame(d, detail[3], -detail[2], detail[4], detail[5], k)
				-- 		else -- DKP_P
				-- 			GRA:ShowPenalizeFrame(d, detail[1], detail[3], detail[2], detail[4], k)
				-- 		end
				-- 	end)

				else -- loot council
					b.noteText:SetPoint("RIGHT", -25, 0)
					-- delete detail entry
					b.deleteBtn:SetScript("OnClick", function()
						local confirm = GRA:CreateConfirmBox(detailsTab, 200, gra.colors.firebrick.s .. L["Delete this entry?"] .. "|r\n" 
						.. detail[2] .. " " .. GRA:GetClassColoredName(detail[3])
						, function()
							-- delete from logs
							table.remove(_G[GRA_R_RaidLogs][d]["details"], k)
							-- fake GRA_ENTRY_UNDO event, refresh sheet by date
							GRA:FireEvent("GRA_ENTRY_UNDO", d)
							ShowTab("details", d)
							detailsTab.scrollFrame:ResetScroll()
						end, true)
						confirm:SetPoint("CENTER")
					end)

					-- modify detail entry
					b:SetScript("OnClick", function()
						GRA:ShowRecordLootFrame(d, detail[2], detail[4], detail[3], k)
					end)
				end
			end
		end
	end

	if detailsTab.scrollRequired then
		detailsTab.scrollFrame:SetVerticalScroll(detailsTab.scrollFrame:GetVerticalScrollRange())
		detailsTab.scrollRequired = false
	end
end

-----------------------------------------
-- load date list
-----------------------------------------
local function LoadDateList()
	GRA:Debug("|cffFFC0CBLoading date list...|r ")

	for d, t in pairs(_G[GRA_R_RaidLogs]) do
		table.insert(sortedDates, d)
	end
	table.sort(sortedDates, function(a, b) return a < b end)

	for i = 1, #sortedDates do
		local d = sortedDates[i]
		if not dates[d] then
			dates[d] = GRA:CreateListButton(listFrame.scrollFrame.content, date("%x", GRA:DateToSeconds(d)), "transparent-light", {listFrame.scrollFrame.content:GetWidth(), gra.size.height-4})
			listFrame.scrollFrame:SetWidgetAutoWidth(dates[d])

			-- highlight selected, dehighlight others
			dates[d]:HookScript("OnClick", function(self)
				if IsShiftKeyDown() then
					if selected then
						-- print("selected: " .. selected .. " current:" .. self.index)
						for i = 1, #sortedDates do
							if selected < self.index then -- ... selected ... clicked ...
								if  i < selected or i > self.index then
									dates[sortedDates[i]]:Deselect()
								else
									dates[sortedDates[i]]:Select()
								end
							elseif selected > self.index then -- ... clicked ... selected ...
								if  i > selected or i < self.index then
									dates[sortedDates[i]]:Deselect()
								else
									dates[sortedDates[i]]:Select()
								end
							else -- ... clicked(selected) ...
								if  i ~= self.index then
									dates[sortedDates[i]]:Deselect()
								end
							end
						end
					end
				elseif IsControlKeyDown() then
					if dates[sortedDates[self.index]].isSelected then
						dates[sortedDates[self.index]]:Deselect()
					else
						dates[sortedDates[self.index]]:Select()
					end
				else
					selected = self.index
					for i = 1, #sortedDates do
						if dates[sortedDates[i]].index ~= selected then
							dates[sortedDates[i]]:Deselect()
						end
					end
					
					ShowTab("summary", d)
					UpdateTitleText(d)					
				end
			end)
		end
		-- update index, used for multi-selection
		dates[d].index = i
	end

	-- set point
	local last = nil
	for _, d in pairs(sortedDates) do
		dates[d]:ClearAllPoints()
		if last then
			dates[d]:SetPoint("TOP", last, "BOTTOM", 0, 1)
		else
			dates[d]:SetPoint("TOPLEFT")
		end
		dates[d]:Show()
		last = dates[d]
	end
end

local function PrepareRaidLogs()
	wipe(sortedDates)
	if GRA:Getn(_G[GRA_R_RaidLogs]) == 0 then
		GRA:CreateMask(raidLogsFrame, L["No raid log"], {-1, 1, 1, -1})
		titleText:SetText("")
		attendeesText:SetText("")
		absenteesText:SetText("")

		bossesFrame.scrollFrame:Reset()
		gra.attendanceEditor.scrollFrame:Reset()
		detailsTab.scrollFrame:Reset()

		newRaidLogBtn:SetFrameLevel(127)
	else
		if raidLogsFrame.mask then raidLogsFrame.mask:Hide() end
		newRaidLogBtn:SetFrameLevel(4)
		LoadDateList()
		-- if not sortedDates[selected] then selected = #sortedDates end
	end

	-- update detailsTab title
	tabButtons["details"]:SetText(_G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" and L["Details"] or L["Loots"])
end

-- update list and scroll
local function UpdateList(dateToShow)
	listFrame.scrollFrame:ResetScroll()
	PrepareRaidLogs()
	-- show last log by default
	if not dateToShow then dateToShow = sortedDates[#sortedDates] end
	GRA:Debug("|cffFFC0CBShowing log: |r" .. (dateToShow or "nil"))
	if dates[dateToShow] then
		dates[dateToShow]:Click() -- highlight this date button and load its content
		-- scroll list
		C_Timer.After(.1, function()
			-- if not dates[dateToShow]:IsVisible() then
				if dates[dateToShow].index > 20 then
					listFrame.scrollFrame:SetVerticalScroll((gra.size.height-5) * (dates[dateToShow].index - 20))
				else
					listFrame.scrollFrame:SetVerticalScroll(0)
				end
			-- end
		end)
	end
end

local init, updateRequired = false, nil
raidLogsFrame:SetScript("OnShow", function()
	LPP:PixelPerfectPoint(gra.mainFrame)
	gra.mainFrame:SetWidth(gra.size.mainFrame[1])

	if updateRequired then
		init = true
		if sortedDates[selected] == updateRequired then -- 需要刷新的日期与当前显示的日期相同，仅更新当前tab
			ShowTab(currentTab, updateRequired)
		else -- 否则重新加载list并显示
			UpdateList(updateRequired)
		end
		updateRequired = nil
	end

	if not init then
		init = true
		UpdateList()
	end
end)

-----------------------------------------
-- events
-----------------------------------------
GRA:RegisterEvent("GRA_ROSTER", "RaidLogsFrame_RosterUpdate", function()
	if raidLogsFrame:IsVisible() then
		ShowTab(currentTab)
	else
		updateRequired = sortedDates[selected]
	end
end)

GRA:RegisterEvent("GRA_LOGS_DONE", "RaidLogsFrame_LogsReceived", function(count, dateStrings)
	GRA:Print(L["%d raid logs have been received: %s"]:format(count, GRA:TableToString(dateStrings)))
	-- show last of received dates
	if raidLogsFrame:IsVisible() then
		UpdateList(dateStrings[#dateStrings])
	else
		updateRequired = dateStrings[#dateStrings]
	end
end)

-- show updated log -- FIXME: may cause unpredictable error
GRA:RegisterEvent("GRA_RAIDLOGS", "RaidLogsFrame_RaidLogsUpdated", function(d)
	if raidLogsFrame:IsVisible() then
		if not dates[d] then -- 需要刷新的日期未创建
			UpdateList(d)
		elseif sortedDates[selected] == d then -- 已创建 并 需要刷新的日期与当前显示的日期相同
			ShowTab(currentTab, d)
		else -- 已创建 并 当前显示其他日期log
			updateRequired = d
		end
	else
		updateRequired = d
	end
end)

GRA:RegisterEvent("GRA_LOGS_DEL", "RaidLogsFrame_RaidLogsDeleted", function(deletedDates)
	-- hide
	for _, d in pairs(deletedDates) do
		dates[d]:SetParent(nil)
		dates[d]:ClearAllPoints()
		dates[d]:Hide()
	end
	-- delete
	dates = GRA:RemoveElementsByKeys(dates, deletedDates)
	-- reset scroll
	listFrame.scrollFrame:ResetScroll()
	listFrame.scrollFrame:ResetHeight()
	-- show last
	UpdateList()

	if GRA:TContains(deletedDates, gra.trackingDate) then
		GRA:StopTracking(true)
	end
end)

GRA:RegisterEvent("GRA_RH_UPDATE", "RaidLogsFrame_RaidHoursUpdate", function(d)
	if not init then return end

	UpdateTitleText(sortedDates[selected])
end)

-- details
local function Details_Refresh(d)
	if sortedDates[selected] == d and currentTab == "details" then
		if raidLogsFrame:IsVisible() then
			ShowTab("details", d)
		else
			updateRequired = d
		end
	end
end

local function Details_RefreshAndScroll(d)
	detailsTab.scrollRequired = true
	Details_Refresh(tonumber(d) and d or sortedDates[selected]) -- d==EPGP/DKP/"" when GRA_SYSTEM fires
end

GRA:RegisterEvent("GRA_ENTRY", "RaidLogsFrame_DetailsRefresh", Details_RefreshAndScroll)
GRA:RegisterEvent("GRA_ENTRY_MODIFY", "RaidLogsFrame_DetailsRefresh", Details_Refresh)
GRA:RegisterEvent("GRA_SYSTEM", "RaidLogsFrame_DetailsRefresh", Details_RefreshAndScroll)

-- bosses
local function Bosses_Refresh(d)
	if sortedDates[selected] == d and currentTab == "summary" then
		if raidLogsFrame:IsVisible() then
			ShowTab("summary", d)
		else
			updateRequired = d
		end
	end
end

local function Bosses_RefreshAndScroll(d)
	bossesFrame.scrollRequired = true
	Bosses_Refresh(d)
end

GRA:RegisterEvent("GRA_BOSS", "RaidLogsFrame_BossesRefresh", Bosses_RefreshAndScroll)
GRA:RegisterEvent("GRA_BOSS_MODIFY", "RaidLogsFrame_BossesRefresh", Bosses_Refresh) -- TODO:

-----------------------------------------
-- permission
-----------------------------------------
GRA:RegisterEvent("GRA_PERMISSION", "RaidLogsFrame_CheckPermissions", function(isAdmin)
	if isAdmin then
		sendToRaidBtn:Show()
		newRaidLogBtn:Show()
		deleteRaidLogBtn:SetPoint("LEFT", newRaidLogBtn, "RIGHT", 5, 0)
		exportBtn:Show()
		addBossBtn:Show()
		tabButtons["attendances"]:SetPoint("RIGHT", tabButtons["details"], "LEFT", 1, 0)
		tabButtons["summary"]:SetPoint("RIGHT", tabButtons["attendances"], "LEFT", 1, 0)

		if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
			creditBtn:SetText(L["GP Credit"])
			creditBtn:Show()
			awardBtn:SetText(L["EP Award"])
			awardBtn:Show()
			penalizeBtn:Show()
		elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
			creditBtn:SetText(L["DKP Credit"])
			creditBtn:Show()
			awardBtn:SetText(L["DKP Award"])
			awardBtn:Show()
			penalizeBtn:Show()
		else
			recordLootBtn:Show()
		end

		-- current tab = details -- FIXME: bug???
		if GRA:Getn(dates) ~= 0 and currentTab == "details" then
			ShowTab("details", sortedDates[selected])
		end
	else
		deleteRaidLogBtn:SetPoint("BOTTOMLEFT")
	end
end)

GRA:RegisterEvent("GRA_SYSTEM", "RaidLogsFrame_SystemChanged", function(system)
	-- admin only
	if not gra.isAdmin then return end
	if system == "EPGP" then
		creditBtn:SetText(L["GP Credit"])
		creditBtn:Show()
		awardBtn:SetText(L["EP Award"])
		awardBtn:Show()
		penalizeBtn:Show()
		recordLootBtn:Hide()
		tabButtons["details"]:SetText(L["Details"])
	elseif system == "DKP" then
		creditBtn:SetText(L["DKP Credit"])
		creditBtn:Show()
		awardBtn:SetText(L["DKP Award"])
		awardBtn:Show()
		penalizeBtn:Show()
		recordLootBtn:Hide()
		tabButtons["details"]:SetText(L["Details"])
	else
		recordLootBtn:Show()
		creditBtn:Hide()
		awardBtn:Hide()
		penalizeBtn:Hide()
		tabButtons["details"]:SetText(L["Loots"])
	end
end)

if GRA:Debug() then
	-- GRA:StylizeFrame(raidLogsFrame, {0, 0, 0, 0}, {0, 0, 0, 1})
	-- GRA:StylizeFrame(titleFrame, {0, .5, 0, .1}, {0, 0, 0, 1})
	-- GRA:StylizeFrame(statusFrame, {0, .5, 0, .1}, {0, 0, 0, 1})
end

-----------------------------------------
-- resize
-----------------------------------------
function raidLogsFrame:Resize()
	raidLogsFrame:ClearAllPoints()
	raidLogsFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, gra.size.raidLogsFrame[1])
	raidLogsFrame:SetPoint("TOPRIGHT", gra.mainFrame, -8, gra.size.raidLogsFrame[1])
	raidLogsFrame:SetHeight(gra.size.raidLogsFrame[2])
	titleFrame:SetPoint("BOTTOMRIGHT", raidLogsFrame, "TOPRIGHT", 0, 3-gra.size.height)
	-- buttons
	sendToRaidBtn:SetSize(unpack(gra.size.button_main))
	newRaidLogBtn:SetSize(unpack(gra.size.button_main))
	deleteRaidLogBtn:SetSize(unpack(gra.size.button_main))
	awardBtn:SetSize(unpack(gra.size.button_raidLogs))
	creditBtn:SetSize(unpack(gra.size.button_raidLogs))
	penalizeBtn:SetSize(unpack(gra.size.button_raidLogs))
	recordLootBtn:SetSize(unpack(gra.size.button_raidLogs))
	-- list
	listFrame:SetPoint("TOPLEFT", 0, gra.size.raidLogsFrame_list[1])
	listFrame:SetPoint("BOTTOMRIGHT", raidLogsFrame, "BOTTOMLEFT", gra.size.raidLogsFrame_list[3], gra.size.raidLogsFrame_list[2])
	listFrame.scrollFrame:SetScrollStep(gra.size.height-5)
	-- summary
	attendeesFrame:SetHeight(gra.size.height+32)
	absenteesFrame:SetHeight(gra.size.height+31)
	attendeesText:SetSpacing(gra.size.fontSize-9)
	absenteesText:SetSpacing(gra.size.fontSize-9)
	-- details
	-- detailsFrame:SetPoint("BOTTOMRIGHT", 0, gra.size.raidLogsFrame_list[2])
	-- detailsFrame.scrollFrame:SetScrollStep(gra.size.height+5)
end