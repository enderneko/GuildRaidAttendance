local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local raidLogsArchiveFrame
local raidDates

-- archive button status
local function CheckChanges()
    if raidLogsArchiveFrame.archiveToDropdown.selected == L["New Archive"] then
        local archiveTo = raidLogsArchiveFrame.archiveToEditBox:GetText()
        if archiveTo ~= ""  and archiveTo ~= L["New Archive"] and not _G[GRA_R_Archived][archiveTo] then
            raidLogsArchiveFrame.archiveBtn:SetEnabled(true)
        else
            raidLogsArchiveFrame.archiveBtn:SetEnabled(false)
        end
    else
        raidLogsArchiveFrame.archiveBtn:SetEnabled(true)
    end
end

local function CreateRaidLogsArchiveFrame(parent)
    raidLogsArchiveFrame = CreateFrame("Frame", "GRA_RaidLogsArchiveFrame", parent, "BackdropTemplate")
	GRA.StylizeFrame(raidLogsArchiveFrame)
	raidLogsArchiveFrame:EnableMouse(true)
	raidLogsArchiveFrame:SetFrameStrata("DIALOG")
    raidLogsArchiveFrame:SetSize(170,115)

    local closeBtn = GRA.CreateButton(raidLogsArchiveFrame, "×", "red", {16, 16}, "GRA_FONT_BUTTON")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() raidLogsArchiveFrame:Hide() end)

    -- archive to
	local archiveToSection = raidLogsArchiveFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	archiveToSection:SetText("|cff80FF00"..L["Archive To"].."|r")
	archiveToSection:SetPoint("TOPLEFT", 5, -20)
    GRA.CreateSeparator(raidLogsArchiveFrame, archiveToSection)

    -- dropdown
    local archiveToDropdown = GRA.CreateDropDownMenu(raidLogsArchiveFrame, 160)
    raidLogsArchiveFrame.archiveToDropdown = archiveToDropdown
    archiveToDropdown:SetPoint("TOPLEFT", 5, -40)

    -- editbox
    local archiveToEditBox = GRA.CreateEditBox(raidLogsArchiveFrame, raidLogsArchiveFrame:GetWidth()-10, 20, false, "GRA_FONT_SMALL")
    raidLogsArchiveFrame.archiveToEditBox = archiveToEditBox
	archiveToEditBox:SetPoint("TOPLEFT", archiveToDropdown, "BOTTOMLEFT", 0, -5)
    archiveToEditBox:SetPoint("RIGHT", archiveToDropdown)
    archiveToEditBox:SetScript("OnShow", function()
        raidLogsArchiveFrame:SetHeight(115)
    end)
    archiveToEditBox:SetScript("OnHide", function()
        raidLogsArchiveFrame:SetHeight(90)
    end)
    archiveToEditBox:SetScript("OnTextChanged", function()
        CheckChanges()
    end)

    -- archive button
    local archiveBtn = GRA.CreateButton(raidLogsArchiveFrame, L["Archive"], "green", {raidLogsArchiveFrame:GetWidth()-10, 20})
	raidLogsArchiveFrame.archiveBtn = archiveBtn
	archiveBtn:SetPoint("BOTTOM", 0, 5)
	archiveBtn:SetEnabled(false)
    archiveBtn:SetScript("OnClick", function()
        local archiveTo
        if raidLogsArchiveFrame.archiveToDropdown.selected == L["New Archive"] then
            archiveTo = archiveToEditBox:GetText()
            _G[GRA_R_Archived][archiveTo] = {}
        else
            archiveTo = raidLogsArchiveFrame.archiveToDropdown.selected
        end

        for _, d in pairs(raidDates) do
            -- copy
            _G[GRA_R_Archived][archiveTo][d] = GRA.Copy(GRA_Logs[d])
            -- delete
            GRA_Logs[d] = nil
        end
        raidLogsArchiveFrame:Hide()
        GRA.Fire("GRA_LOGS_ACV", raidDates, archiveTo)
    end)
end

function GRA.ShowRaidLogsArchiveFrame(parent, dates)
    if not raidLogsArchiveFrame then CreateRaidLogsArchiveFrame(parent) end

    raidLogsArchiveFrame:SetParent(parent)
    raidLogsArchiveFrame:ClearAllPoints()
    raidLogsArchiveFrame:SetPoint("BOTTOM", parent, "TOP", 0, 1)
    raidLogsArchiveFrame:Show()

    raidDates = dates

    local items = {
        {
            ["text"] = L["New Archive"],
            ["onClick"] = function()
                raidLogsArchiveFrame.archiveToEditBox:Show()
                CheckChanges()
            end,
        },
    }

    for archiveName, archiveTable in pairs(_G[GRA_R_Archived]) do
        tinsert(items, {
            ["text"] = archiveName,
            ["onClick"] = function()
                raidLogsArchiveFrame.archiveToEditBox:SetText("")
                raidLogsArchiveFrame.archiveToEditBox:Hide()
                CheckChanges()
            end,
        })
    end

    raidLogsArchiveFrame.archiveToDropdown:SetItems(items)
    raidLogsArchiveFrame.archiveToDropdown:SetSelected(L["New Archive"])
    raidLogsArchiveFrame.archiveToEditBox:Show()

    if GRA_RaidLogsEditFrame then GRA_RaidLogsEditFrame:Hide() end

	return raidLogsArchiveFrame
end