local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local raidLogEditFrame, raidNote, raidStartTime, raidEndTime, raidDates
local noteChanged, raidHoursChanged

-- apply button status
local function CheckChanges()
	if noteChanged or raidHoursChanged then
		raidLogEditFrame.applyBtn:SetEnabled(true)
	else
		raidLogEditFrame.applyBtn:SetEnabled(false)
	end
end

-- note
local function SetOrClearNotes(bName)
	if bName == L["Set"] then
		GRA:ChangeSizeWithAnimation(raidLogEditFrame, nil, 225, function()
			if not raidLogEditFrame.noteEditBox:IsShown() then -- ignore when already shown
				raidLogEditFrame.noteEditBox:Show()
				noteChanged = false
				CheckChanges()
			end
		end, nil, true)
	elseif bName == L["Clear"] then
		GRA:ChangeSizeWithAnimation(raidLogEditFrame, nil, 140, function()
			raidLogEditFrame.noteEditBox:ClearFocus()
			raidLogEditFrame.noteEditBox:SetText("")
			noteChanged = true
			CheckChanges()
		end, function()
			raidLogEditFrame.noteEditBox:Hide()
		end, true)
	end
end

local function CreateRaidLogEditFrame(parent)
	raidLogEditFrame = CreateFrame("Frame", "GRA_RaidLogEditFrame", parent, "BackdropTemplate")
	GRA:StylizeFrame(raidLogEditFrame)
	raidLogEditFrame:EnableMouse(true)
	raidLogEditFrame:SetFrameStrata("DIALOG")
	raidLogEditFrame:SetSize(220,140)

	-- text
	local text = raidLogEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	text:SetPoint("TOPLEFT", 5, -7)
	text:SetText(gra.colors.grey.s .. L["Blank fields will be ignored."])

	-- note section
	local noteSection = raidLogEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	noteSection:SetText("|cff80FF00"..L["Note"].."|r")
	noteSection:SetPoint("TOPLEFT", 5, -20)
	GRA:CreateSeparator(raidLogEditFrame, noteSection)

	-- note group buttons
	local setButton = GRA:CreateButton(raidLogEditFrame, L["Set"], "green-hover", {50, 20})
	setButton:SetPoint("TOPLEFT", 5, -40)
	local clearButton = GRA:CreateButton(raidLogEditFrame, L["Clear"], "red-hover", {50, 20})
	clearButton:SetPoint("LEFT", setButton, "RIGHT", -1, 0)

	local noteButtons = GRA:CreateButtonGroup(SetOrClearNotes, setButton, clearButton)

	-- note
	raidLogEditFrame.noteEditBox = GRA:CreateEditBox(raidLogEditFrame, raidLogEditFrame:GetWidth()-10, 80, false, "GRA_FONT_SMALL")
	raidLogEditFrame.noteEditBox:SetPoint("TOPLEFT", setButton, "BOTTOMLEFT", 0, 1)
	raidLogEditFrame.noteEditBox:SetPoint("BOTTOMRIGHT", raidLogEditFrame, -5, 80)
	raidLogEditFrame.noteEditBox:SetMultiLine(true)
	raidLogEditFrame.noteEditBox:SetMaxLetters(200)
	raidLogEditFrame.noteEditBox:SetTextInsets(5, 5, 5, 5)
	raidLogEditFrame.noteEditBox:Hide()
	raidLogEditFrame.noteEditBox:SetScript("OnTextChanged", function(self, userInput)
		if not userInput then return end
		if strtrim(raidLogEditFrame.noteEditBox:GetText()) ~= "" then
			raidNote = strtrim(raidLogEditFrame.noteEditBox:GetText())
			noteChanged = true
		else
			raidNote = nil
			noteChanged = false
		end
		CheckChanges()
	end)

	-- raid hours section
	local rhSection = raidLogEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	rhSection:SetText("|cff80FF00"..L["Raid Hours"].."|r")
	rhSection:SetPoint("BOTTOMLEFT", 5, 60)
	GRA:CreateSeparator(raidLogEditFrame, rhSection)

	-- raid hours editbox
	raidLogEditFrame.rstEditBox, raidLogEditFrame.retEditBox, raidLogEditFrame.rstConfirmBtn, raidLogEditFrame.retConfirmBtn = GRA:CreateRaidHoursEditBox(raidLogEditFrame,
	function(startTime)
		raidStartTime = startTime
		raidHoursChanged = true
		CheckChanges()
	end, function(endTime)
		raidEndTime = endTime
		raidHoursChanged = true
		CheckChanges()
	end)

	raidLogEditFrame.rstEditBox:SetPoint("BOTTOMLEFT", 35, 30)
	raidLogEditFrame.retEditBox:SetPoint("BOTTOMRIGHT", raidLogEditFrame, -25, 30)
	
	local startText = raidLogEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	startText:SetText(gra.colors.chartreuse.s .. L["Start"])
	startText:SetPoint("RIGHT", raidLogEditFrame.rstEditBox, "LEFT", -5, 0)
	
	local endText = raidLogEditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	endText:SetText(gra.colors.chartreuse.s .. L["End"])
	endText:SetPoint("RIGHT", raidLogEditFrame.retEditBox, "LEFT", -5, 0)
	
	-- button
	local closeBtn = GRA:CreateButton(raidLogEditFrame, "×", "red", {16, 16}, "GRA_FONT_BUTTON")
	closeBtn:SetPoint("TOPRIGHT", -5, -5)
	closeBtn:SetScript("OnClick", function() raidLogEditFrame:Hide() end)

	local applyBtn = GRA:CreateButton(raidLogEditFrame, L["Apply"], "green", {raidLogEditFrame:GetWidth()-10, 20})
	raidLogEditFrame.applyBtn = applyBtn
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
		raidLogEditFrame:Hide()
	end)

	-- OnHide
	raidLogEditFrame:SetScript("OnHide", function(self)
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
		raidLogEditFrame:SetSize(220,140)
		-- hide editbox
		self.noteEditBox:Hide()
	end)
end

function GRA:ShowRaidLogEditFrame(parent, dates)
	if not raidLogEditFrame then CreateRaidLogEditFrame(parent) end

    raidLogEditFrame:SetParent(parent)
    raidLogEditFrame:ClearAllPoints()
    raidLogEditFrame:SetPoint("BOTTOM", parent, "TOP", 0, 1)
	raidLogEditFrame:Show()

	raidDates = dates

	return raidLogEditFrame
end
