local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local raidLogsEditFrame, raidNote, raidStartTime, raidEndTime, raidDates
local noteChanged, raidHoursChanged

-- apply button status
local function CheckChanges()
	if noteChanged or raidHoursChanged then
		raidLogsEditFrame.applyBtn:SetEnabled(true)
	else
		raidLogsEditFrame.applyBtn:SetEnabled(false)
	end
end

-- note
local function SetOrClearNotes(bName)
	if bName == L["Set"] then
		GRA:ChangeSizeWithAnimation(raidLogsEditFrame, nil, 225, function()
			if not raidLogsEditFrame.noteEditBox:IsShown() then -- ignore when already shown
				raidLogsEditFrame.noteEditBox:Show()
				noteChanged = false
				CheckChanges()
			end
		end, nil, true)
	elseif bName == L["Clear"] then
		GRA:ChangeSizeWithAnimation(raidLogsEditFrame, nil, 140, function()
			raidLogsEditFrame.noteEditBox:ClearFocus()
			raidLogsEditFrame.noteEditBox:SetText("")
			noteChanged = true
			CheckChanges()
		end, function()
			raidLogsEditFrame.noteEditBox:Hide()
		end, true)
	end
end

local function CreateRaidLogsEditFrame(parent)
	raidLogsEditFrame = CreateFrame("Frame", "GRA_RaidLogsEditFrame", parent, "BackdropTemplate")
	GRA:StylizeFrame(raidLogsEditFrame)
	raidLogsEditFrame:EnableMouse(true)
	raidLogsEditFrame:SetFrameStrata("DIALOG")
	raidLogsEditFrame:SetSize(220,140)

	-- text
	local text = raidLogsEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	text:SetPoint("TOPLEFT", 5, -7)
	text:SetText(gra.colors.grey.s .. L["Blank fields will be ignored."])

	-- note section
	local noteSection = raidLogsEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	noteSection:SetText("|cff80FF00"..L["Note"].."|r")
	noteSection:SetPoint("TOPLEFT", 5, -20)
	GRA:CreateSeparator(raidLogsEditFrame, noteSection)

	-- note group buttons
	local setButton = GRA:CreateButton(raidLogsEditFrame, L["Set"], "green-hover", {50, 20})
	setButton:SetPoint("TOPLEFT", 5, -40)
	local clearButton = GRA:CreateButton(raidLogsEditFrame, L["Clear"], "red-hover", {50, 20})
	clearButton:SetPoint("LEFT", setButton, "RIGHT", -1, 0)

	local noteButtons = GRA:CreateButtonGroup(SetOrClearNotes, setButton, clearButton)

	-- note
	raidLogsEditFrame.noteEditBox = GRA:CreateEditBox(raidLogsEditFrame, raidLogsEditFrame:GetWidth()-10, 80, false, "GRA_FONT_SMALL")
	raidLogsEditFrame.noteEditBox:SetPoint("TOPLEFT", setButton, "BOTTOMLEFT", 0, 1)
	raidLogsEditFrame.noteEditBox:SetPoint("BOTTOMRIGHT", raidLogsEditFrame, -5, 80)
	raidLogsEditFrame.noteEditBox:SetMultiLine(true)
	raidLogsEditFrame.noteEditBox:SetMaxLetters(200)
	raidLogsEditFrame.noteEditBox:SetTextInsets(5, 5, 5, 5)
	raidLogsEditFrame.noteEditBox:Hide()
	raidLogsEditFrame.noteEditBox:SetScript("OnTextChanged", function(self, userInput)
		if not userInput then return end
		if strtrim(raidLogsEditFrame.noteEditBox:GetText()) ~= "" then
			raidNote = strtrim(raidLogsEditFrame.noteEditBox:GetText())
			noteChanged = true
		else
			raidNote = nil
			noteChanged = false
		end
		CheckChanges()
	end)

	-- raid hours section
	local rhSection = raidLogsEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	rhSection:SetText("|cff80FF00"..L["Raid Hours"].."|r")
	rhSection:SetPoint("BOTTOMLEFT", 5, 60)
	GRA:CreateSeparator(raidLogsEditFrame, rhSection)

	-- raid hours editbox
	raidLogsEditFrame.rstEditBox, raidLogsEditFrame.retEditBox, raidLogsEditFrame.rstConfirmBtn, raidLogsEditFrame.retConfirmBtn = GRA:CreateRaidHoursEditBox(raidLogsEditFrame,
	function(startTime)
		raidStartTime = startTime
		raidHoursChanged = true
		CheckChanges()
	end, function(endTime)
		raidEndTime = endTime
		raidHoursChanged = true
		CheckChanges()
	end)

	raidLogsEditFrame.rstEditBox:SetPoint("BOTTOMLEFT", 35, 30)
	raidLogsEditFrame.retEditBox:SetPoint("BOTTOMRIGHT", raidLogsEditFrame, -25, 30)
	
	local startText = raidLogsEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	startText:SetText(gra.colors.chartreuse.s .. L["Start"])
	startText:SetPoint("RIGHT", raidLogsEditFrame.rstEditBox, "LEFT", -5, 0)
	
	local endText = raidLogsEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	endText:SetText(gra.colors.chartreuse.s .. L["End"])
	endText:SetPoint("RIGHT", raidLogsEditFrame.retEditBox, "LEFT", -5, 0)
	
	-- button
	local closeBtn = GRA:CreateButton(raidLogsEditFrame, "×", "red", {16, 16}, "GRA_FONT_BUTTON")
	closeBtn:SetPoint("TOPRIGHT", -5, -5)
	closeBtn:SetScript("OnClick", function() raidLogsEditFrame:Hide() end)

	local applyBtn = GRA:CreateButton(raidLogsEditFrame, L["Apply"], "green", {raidLogsEditFrame:GetWidth()-10, 20})
	raidLogsEditFrame.applyBtn = applyBtn
	applyBtn:SetPoint("BOTTOM", 0, 5)
	applyBtn:SetEnabled(false)
	applyBtn:SetScript("OnClick", function()
		for _, d in pairs(raidDates) do
			if raidStartTime or raidEndTime then
				-- update startTime
				if raidStartTime then
					_G[GRA_R_RaidLogs][d]["startTime"] = GRA:DateToSeconds(d .. raidStartTime, true)
					print(d .. raidStartTime)
				end
				-- update endTime
				if raidEndTime then
					if GRA:GetRaidStartTime(d) > raidEndTime then
						_G[GRA_R_RaidLogs][d]["endTime"] = GRA:DateToSeconds((d + 1) .. raidEndTime, true)
						print((d + 1) .. raidEndTime)
					else
						_G[GRA_R_RaidLogs][d]["endTime"] = GRA:DateToSeconds(d .. raidEndTime, true)
						print(d .. raidEndTime)
					end
				end
				-- notify raid hours changes
				GRA:FireEvent("GRA_RH_UPDATE", d)
			end

			-- notify raid note changes
			if raidNote then
				_G[GRA_R_RaidLogs][d]["note"] = raidNote
				GRA:FireEvent("GRA_RN_UPDATE", d)
			elseif noteChanged then -- clear
				_G[GRA_R_RaidLogs][d]["note"] = nil
				GRA:FireEvent("GRA_RN_UPDATE", d)
			end
		end
		GRA:Print(L["Raid logs updated: "] .. GRA:TableToString(raidDates))
		raidLogsEditFrame:Hide()
	end)

	-- OnHide
	raidLogsEditFrame:SetScript("OnHide", function(self)
		self:Hide()
		self.noteEditBox:SetText("")
		self.rstEditBox:SetText("")
		self.retEditBox:SetText("")
		self.applyBtn:SetEnabled(false)
		raidNote = nil
		raidStartTime = nil
		raidEndTime = nil
		noteChanged = false
		raidHoursChanged = false

		-- clear highlight
		noteButtons.HighlightButton()
		-- reset size
		raidLogsEditFrame:SetSize(220,140)
		-- hide editbox
		self.noteEditBox:Hide()
	end)
end

function GRA:ShowRaidLogsEditFrame(parent, dates)
	if not raidLogsEditFrame then CreateRaidLogsEditFrame(parent) end

    raidLogsEditFrame:SetParent(parent)
    raidLogsEditFrame:ClearAllPoints()
	raidLogsEditFrame:SetPoint("BOTTOM", parent, "TOP", 0, 1)
	raidLogsEditFrame:Show()

	raidDates = dates

	if GRA_RaidLogsArchiveFrame then GRA_RaidLogsArchiveFrame:Hide() end

	return raidLogsEditFrame
end
