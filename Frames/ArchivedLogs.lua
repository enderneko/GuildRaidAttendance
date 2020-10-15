local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local dates, sortedDates, details = {}, {}, {}
local selected = 1
-----------------------------------------
-- archived logs frame
-----------------------------------------
local archivedLogsFrame = CreateFrame("Frame", "GRA_ArchivedLogsFrame", gra.mainFrame)
archivedLogsFrame:SetPoint("TOPLEFT", gra.mainFrame, 8, -30)
archivedLogsFrame:SetPoint("BOTTOMRIGHT", gra.mainFrame, -8, 29)
archivedLogsFrame:Hide()
gra.archivedLogsFrame = archivedLogsFrame

-----------------------------------------
-- title
-----------------------------------------
local titleFrame = CreateFrame("Frame", nil, archivedLogsFrame)
titleFrame:SetPoint("TOPLEFT")
titleFrame:SetPoint("BOTTOMRIGHT", archivedLogsFrame, "TOPRIGHT", 0, -16)

local titleText = titleFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
titleText:SetPoint("LEFT", 5, 0)
local function UpdateTitleText(d)
	titleText:SetText(gra.colors.chartreuse.s .. L["Raids: "] .. "|r" .. GRA:Getn(_G[GRA_R_RaidLogs])
		.. "    |cff80FF00" .. L["Current: "] .. "|r" .. date("%x", GRA:DateToSeconds(d))
		.. "    |cff80FF00" .. L["Raid Hours"] .. ":|r " .. GRA:GetRaidStartTime(d) .. " - " ..  GRA:GetRaidEndTime(d))
end

-----------------------------------------
-- button frame
-----------------------------------------
local buttonFrame = CreateFrame("Frame", nil, archivedLogsFrame)
buttonFrame:SetPoint("TOPLEFT", archivedLogsFrame, "BOTTOMLEFT", 0, 20)
buttonFrame:SetPoint("BOTTOMRIGHT")

local archivedDropDownMenu = GRA:CreateScrollDropDownMenu(buttonFrame, 200)
archivedDropDownMenu:SetPoint("BOTTOMLEFT")

-----------------------------------------
-- date list
-----------------------------------------
local listFrame = CreateFrame("Frame", nil, archivedLogsFrame, "BackdropTemplate")
GRA:StylizeFrame(listFrame, {.5, .5, .5, .1})
listFrame:SetPoint("TOPLEFT", 0, -16)
listFrame:SetPoint("BOTTOMRIGHT", archivedLogsFrame, "BOTTOMLEFT", 170, 24)
-- listFrame:SetPoint("TOPRIGHT", archivedLogsFrame, "TOPLEFT", 100, 0)
-- listFrame:SetHeight(300)
GRA:CreateScrollFrame(listFrame)
listFrame.scrollFrame:SetScrollStep(15)

-----------------------------------------
-- tabs
-----------------------------------------
local tabs, tabButtons = {}, {}
local currentTab
local function ShowTab(tabToShow, d)
	if not tabToShow then return end -- no logs, no date list, no button to click
	if not d then d = sortedDates[selected] end
	GRA:Debug("|cffFFC0CBShowTab:|r " .. tabToShow .. " " .. (d or "nil"))
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
tabButtons["details"]:SetEnabled(false)
tabButtons["details"]:SetScript("OnClick", function(self)
	ShowTab("details", sortedDates[selected])
end)

tabButtons["attendances"] = GRA:CreateButton(titleFrame, L["Attendances"], "green-hover", {70, 17})
tabButtons["attendances"]:SetPoint("RIGHT", tabButtons["details"], "LEFT", 1, 0)
tabButtons["attendances"]:SetEnabled(false)
tabButtons["attendances"]:SetScript("OnClick", function(self)
	ShowTab("attendances", sortedDates[selected])
end)

tabButtons["summary"] = GRA:CreateButton(titleFrame, L["Summary"], "red-hover", {70, 17})
tabButtons["summary"]:SetPoint("RIGHT", tabButtons["attendances"], "LEFT", 1, 0)
tabButtons["summary"]:SetScript("OnClick", function(self)
	ShowTab("summary", sortedDates[selected])
end)

-----------------------------------------
-- summary
-----------------------------------------
local summaryTab = CreateFrame("Frame", "GRA_ArchivedLogsFrame_Summary", archivedLogsFrame, "BackdropTemplate")
tabs["summary"] = summaryTab
GRA:StylizeFrame(summaryTab, {.5, .5, .5, .1})
summaryTab:SetPoint("TOPLEFT", listFrame, "TOPRIGHT", 5, 0)
summaryTab:SetPoint("BOTTOMRIGHT", 0, 24)

local noteFrame = CreateFrame("Frame", nil, summaryTab, "BackdropTemplate")
GRA:StylizeFrame(noteFrame, {0, 0, 0, 0})
noteFrame:SetPoint("TOPLEFT")
noteFrame:SetPoint("RIGHT")
noteFrame:SetHeight(36)

noteFrame.text = noteFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
noteFrame.text:SetPoint("TOPLEFT", 5, -5)
noteFrame.text:SetPoint("TOPRIGHT", -5, -5)
noteFrame.text:SetSpacing(3)
noteFrame.text:SetWordWrap(true)
noteFrame.text:SetMaxLines(2)
noteFrame.text:SetJustifyH("LEFT")
noteFrame.text:SetJustifyV("TOP")

local function GetNote(note)
	note = string.gsub(note, "%[", gra.colors.firebrick.s)
	note = string.gsub(note, "%]", "|r")
	return note
end

local attendeesFrame = CreateFrame("Frame", nil, summaryTab, "BackdropTemplate")
GRA:StylizeFrame(attendeesFrame, {0, 0, 0, 0})
attendeesFrame:SetPoint("TOPLEFT", noteFrame, "BOTTOMLEFT", 0, 1)
attendeesFrame:SetPoint("RIGHT")
attendeesFrame:SetHeight(51)

attendeesFrame.text = attendeesFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
attendeesFrame.text:SetPoint("TOPLEFT", 5, -5)
attendeesFrame.text:SetPoint("TOPRIGHT", -5, -5)
attendeesFrame.text:SetSpacing(3)
attendeesFrame.text:SetWordWrap(true)
attendeesFrame.text:SetMaxLines(3)
attendeesFrame.text:SetJustifyH("LEFT")
attendeesFrame.text:SetJustifyV("TOP")

local absenteesFrame = CreateFrame("Frame", nil, summaryTab, "BackdropTemplate")
GRA:StylizeFrame(absenteesFrame, {0, 0, 0, 0})
absenteesFrame:SetPoint("TOPLEFT", attendeesFrame, "BOTTOMLEFT", 0, 1)
absenteesFrame:SetPoint("RIGHT")
absenteesFrame:SetHeight(51)

absenteesFrame.text = absenteesFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
absenteesFrame.text:SetPoint("TOPLEFT", 5, -5)
absenteesFrame.text:SetPoint("TOPRIGHT", -5, -5)
absenteesFrame.text:SetSpacing(3)
absenteesFrame.text:SetWordWrap(true)
absenteesFrame.text:SetMaxLines(3)
absenteesFrame.text:SetJustifyH("LEFT")
absenteesFrame.text:SetJustifyV("TOP")

local bossesFrame = CreateFrame("Frame", nil, summaryTab, "BackdropTemplate")
GRA:StylizeFrame(bossesFrame, {0, 0, 0, 0})
bossesFrame:SetPoint("TOPLEFT", absenteesFrame, "BOTTOMLEFT", 0, 1)
bossesFrame:SetPoint("BOTTOMRIGHT")
GRA:CreateScrollFrame(bossesFrame, -5, 6)
bossesFrame.scrollFrame:SetScrollStep(41)

local exportBtn = GRA:CreateButton(summaryTab, L["Export CSV"], "blue", {70, 20})
exportBtn:SetPoint("BOTTOMRIGHT", buttonFrame)
exportBtn:SetScript("OnClick", function()
	GRA:ShowExportFrame(sortedDates[selected])
end)

-----------------------------------------
-- attendances
-----------------------------------------
local attendancesTab = CreateFrame("Frame", "GRA_ArchivedLogsFrame_Attendance", archivedLogsFrame, "BackdropTemplate")
tabs["attendances"] = attendancesTab
GRA:StylizeFrame(attendancesTab, {.5, .5, .5, .1})
attendancesTab:SetPoint("TOPLEFT", listFrame, "TOPRIGHT", 5, 0)
attendancesTab:SetPoint("BOTTOMRIGHT", 0, 24)
attendancesTab:Hide()

-----------------------------------------
-- details/loots
-----------------------------------------
local detailsTab = CreateFrame("Frame", "GRA_ArchivedLogsFrame_Details", archivedLogsFrame, "BackdropTemplate")
tabs["details"] = detailsTab
GRA:StylizeFrame(detailsTab, {.5, .5, .5, .1})
detailsTab:SetPoint("TOPLEFT", listFrame, "TOPRIGHT", 5, 0)
detailsTab:SetPoint("BOTTOMRIGHT", 0, 24)
detailsTab:Hide()
GRA:CreateScrollFrame(detailsTab, -13, 13)
detailsTab.scrollFrame:SetScrollStep(25)

-----------------------------------------
-- buttonFrame buttons
-----------------------------------------
local sendBtn = GRA:CreateButton(buttonFrame, L["Send"], "blue", {70, 20}, nil, false,
	L["Send archived logs to raid members"],
	L["GRA must be installed to receive data."])
sendBtn:SetPoint("LEFT", archivedDropDownMenu, "RIGHT", 5, 0)
sendBtn:Hide()
sendBtn:SetScript("OnClick", function()
	local confirm = GRA:CreateConfirmPopup(archivedLogsFrame, 180, L["Send archived logs data to raid/party members?"], function()

	end, true)
	confirm:SetPoint("CENTER")
end)
-- disabled while sending
sendBtn:SetScript("OnUpdate", function()
	sendBtn:SetEnabled(IsInGroup("LE_PARTY_CATEGORY_HOME") and not gra.sending)
end)

local deleteBtn = GRA:CreateButton(buttonFrame, L["Delete"], "blue", {70, 20}, nil, false,
L["Delete archived log"],
L["Delete archived raid logs."])
deleteBtn:SetPoint("LEFT", archivedDropDownMenu, "RIGHT", 5, 0)
deleteBtn:SetScript("OnClick", function()
	local text = L["Delete selected raid logs?"]

	local confirm = GRA:CreateConfirmPopup(archivedLogsFrame, 180, gra.colors.firebrick.s .. text, function()

	end, true)
	confirm:SetPoint("CENTER")
end)

local editBtn = GRA:CreateButton(buttonFrame, L["Edit"], "blue", {70, 20}, nil, false)
editBtn:Hide()

-----------------------------------------
-- tab content functions
-----------------------------------------
local function SortByClass(a, b)
	local classA = _G[GRA_R_Roster][a] and GRA:GetIndex(gra.CLASS_ORDER, _G[GRA_R_Roster][a]["class"]) or 99
	local classB = _G[GRA_R_Roster][b] and GRA:GetIndex(gra.CLASS_ORDER, _G[GRA_R_Roster][b]["class"]) or 99
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

	if t["note"] and t["note"] ~= "" then
		noteFrame.text:SetText(gra.colors.chartreuse.s .. L["Note"] .. ": |r" .. GetNote(t["note"]))
	else
		noteFrame.text:SetText(gra.colors.chartreuse.s .. L["Note"] .. ": |r" .. gra.colors.grey.s .. L["Right-click to edit. Characters in [square brackets] will be shown in red color."])
	end
	attendeesFrame.text:SetText(gra.colors.chartreuse.s .. L["Attendees"] .. "(" .. GRA:Getn(attendees) .. "): " .. attendeesString)
	absenteesFrame.text:SetText(gra.colors.chartreuse.s .. L["Absentees"] .. "(" .. GRA:Getn(absentees) .. "): " .. absenteesString)

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
				if detail[1] == "LOOT" then
					if string.find(detail[2], "|Hitem") then
						GRA_Tooltip:SetOwner(b, "ANCHOR_NONE")
						GRA_Tooltip:SetPoint("RIGHT", b, "LEFT", -2, 0)
						GRA_Tooltip:SetHyperlink(detail[2])
					else
						GRA_Tooltip:Hide()
					end
				elseif detail[1] == "GP" or detail[1] == "DKP_C" then
					if string.find(detail[3], "|Hitem") then
						GRA_Tooltip:SetOwner(b, "ANCHOR_NONE")
						GRA_Tooltip:SetPoint("RIGHT", b, "LEFT", -2, 0)
						GRA_Tooltip:SetHyperlink(detail[3])
					else
						GRA_Tooltip:Hide()
					end
				else -- EP or DKP_A or Penalize
					if b.playerText:IsTruncated() then
						GRA_Tooltip:SetOwner(b, "ANCHOR_NONE")
						GRA_Tooltip:SetPoint("RIGHT", b, "LEFT", -2, 0)
						if detail[1] == "EP" then
							GRA_Tooltip:AddLine(L["EP Award"] .. " (" .. #detail[4] .. ")")
						elseif detail[1] == "DKP_A" then
							GRA_Tooltip:AddLine(L["DKP Award"] .. " (" .. #detail[4] .. ")")
						else
							GRA_Tooltip:AddLine(L["Penalize"] .. " (" .. #detail[4] .. ")")
						end
						for i = 1, #detail[4], 2 do
							GRA_Tooltip:AddDoubleLine(GRA:GetClassColoredName(detail[4][i]), GRA:GetClassColoredName(detail[4][i+1]))
						end
						GRA_Tooltip:Show()
					end
				end
			end)

			b:HookScript("OnLeave", function()
				GRA_Tooltip:Hide()
			end)

			if gra.isAdmin then
				b.deleteBtn:Show()
				if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
					if detail[1] == "GP" then
						b.noteFrame.text:SetPoint("RIGHT", -25, 0)
					else
						b.playerText:SetPoint("RIGHT", -25, 0)
					end

					-- delete detail entry
					b.deleteBtn:SetScript("OnClick", function()
						local confirm = GRA:CreateConfirmPopup(detailsTab, 200, gra.colors.firebrick.s .. L["Delete this entry and undo changes to %s?"]:format("EP/GP") .. "|r\n" 
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
				-- 		b.noteFrame.text:SetPoint("RIGHT", -25, 0)
				-- 	else
				-- 		b.playerText:SetPoint("RIGHT", -25, 0)
				-- 	end

				-- 	-- delete detail entry
				-- 	b.deleteBtn:SetScript("OnClick", function()
				-- 		local confirm = GRA:CreateConfirmPopup(detailsFrame, 200, gra.colors.firebrick.s .. L["Delete this entry and undo changes to %s?"]:format("DKP") .. "|r\n" 
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
					b.noteFrame.text:SetPoint("RIGHT", -25, 0)
					-- delete detail entry
					b.deleteBtn:SetScript("OnClick", function()
						local confirm = GRA:CreateConfirmPopup(detailsTab, 200, gra.colors.firebrick.s .. L["Delete this entry?"] .. "|r\n" 
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
			local note = _G[GRA_R_RaidLogs][d]["note"] and (" " .. GetNote(_G[GRA_R_RaidLogs][d]["note"])) or ""
			dates[d] = GRA:CreateListButton(listFrame.scrollFrame.content, date("%x", GRA:DateToSeconds(d)) .. note, "transparent-light", {listFrame.scrollFrame.content:GetWidth(), gra.size.height-4})
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
		GRA:CreateMask(archivedLogsFrame, L["No raid log"], {-1, 1, 1, -1})
		titleText:SetText("")
		noteFrame.text:SetText("")
		attendeesFrame.text:SetText("")
		absenteesFrame.text:SetText("")

		bossesFrame.scrollFrame:Reset()
		gra.attendanceEditor.scrollFrame:Reset()
		detailsTab.scrollFrame:Reset()

	else
		if archivedLogsFrame.mask then archivedLogsFrame.mask:Hide() end
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
			if dates[dateToShow].index > 23 then
				listFrame.scrollFrame:SetVerticalScroll((gra.size.height-5) * (dates[dateToShow].index - 23))
			else
				listFrame.scrollFrame:SetVerticalScroll(0)
			end
		end)
	end
end

local init, updateRequired = false, nil
archivedLogsFrame:SetScript("OnShow", function()
	LPP:PixelPerfectPoint(gra.mainFrame)
	gra.mainFrame:SetWidth(gra.size.archivedLogsFrame[1])

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
-- permission
-----------------------------------------
GRA:RegisterEvent("GRA_PERMISSION", "ArchivedLogsFrame_CheckPermissions", function(isAdmin)
	if isAdmin then
		sendBtn:Show()
		deleteBtn:SetPoint("LEFT", sendBtn, "RIGHT", 5, 0)
		editBtn:SetPoint("LEFT", deleteBtn, "RIGHT", 5, 0)
		exportBtn:Show()

		-- current tab = details
		if GRA:Getn(dates) ~= 0 and currentTab == "details" then
			ShowTab("details", sortedDates[selected])
		end
	end
end)