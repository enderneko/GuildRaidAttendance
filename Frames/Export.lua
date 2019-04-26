local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local HEIGHT_NORMAL, HEIGHT_EXPAND = 150, 400
local date1, date2 = nil, nil
local isCalculating = false
local Shrink, Reset

local exportFrame = GRA:CreateMovableFrame(L["Export"] .. " (Beta)", "GRA_ExportFrame", 400, HEIGHT_NORMAL, nil, "DIALOG")
exportFrame:SetToplevel(true)
gra.exportFrame = exportFrame

local text = exportFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
text:SetText(gra.colors.chartreuse.s .. "Submit a ticket on GitHub, if this doesn't meet your needs.")
text:SetPoint("TOPLEFT", 5, -5)

-----------------------------------------
-- period
-----------------------------------------
local periodText = exportFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
periodText:SetText(gra.colors.chartreuse.s .. L["Period"] .. ": ")
periodText:SetPoint("TOPLEFT", 5, -25)

local fromDropDown = GRA:CreateScrollDropDownMenu(exportFrame, 80)
fromDropDown:SetPoint("TOPLEFT", 50, -21)

local periodToText = exportFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
periodToText:SetText(gra.colors.chartreuse.s .. L["to"])
periodToText:SetPoint("LEFT", fromDropDown, "RIGHT", 5, 0)
periodToText:Hide()

local toDropDown = GRA:CreateScrollDropDownMenu(exportFrame, 80)
toDropDown:SetPoint("LEFT", fromDropDown, "RIGHT", 20, 0)
toDropDown:Hide()

-----------------------------------------
-- columns
-----------------------------------------
local columns, dateColumns = {}, {}
local cbs = {}

local columnsText = exportFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
columnsText:SetText(gra.colors.chartreuse.s .. L["Colunms"] .. ": ")
columnsText:SetPoint("TOPLEFT", 5, -50)

-- create cbs
local function CreateCheckButtons()
    columns = {"AR", "AR30", "AR60", "AR90", "SR", "Present", "Late/LeaveEarly", "Absent", "OnLeave", "SitOut", "Loots", "DailyAttendance"}
    for _, c in ipairs(columns) do
        cbs[c] = GRA:CreateCheckButton(exportFrame, c, nil, function(checked)
            if checked then
                table.insert(columns, c)
            else
                GRA:Remove(columns, c)
            end
            -- shrink
            Shrink()
        end, "GRA_FONT_SMALL")
    end
end

-----------------------------------------
-- copy box
-----------------------------------------
local resultFrame = CreateFrame("EditBox", nil, exportFrame)
resultFrame:SetPoint("TOPLEFT", 5, - HEIGHT_NORMAL + 25)
resultFrame:SetPoint("BOTTOMRIGHT", -5, 5)
GRA:StylizeFrame(resultFrame)
GRA:CreateScrollEditBox(resultFrame)
resultFrame:Hide()

resultFrame:SetScript("OnHide", function()
    resultFrame:Hide()
    resultFrame.scrollFrame:ResetScroll()
    resultFrame.editBox:SetText("")
end)

-----------------------------------------
-- function
-----------------------------------------
Shrink = function()
    fromDropDown:Close()
    toDropDown:Close()
    -- reset height
    if floor(exportFrame:GetHeight() + .5) ~= HEIGHT_NORMAL then
        resultFrame:Hide()
        GRA:ChangeSizeWithAnimation(exportFrame, nil, HEIGHT_NORMAL, function() exportFrame.generateBtn:SetEnabled(false) end, function() exportFrame.generateBtn:SetEnabled(true) end)
        exportFrame.generateBtn:Show()
    end
end

Reset = function()
    -- reset dropdown, dropdown items and selected will be reset when SetItems called
    toDropDown:Hide()
    periodToText:Hide()
    fromDropDown:Close()
    -- reset cbs
    for _, cb in pairs(cbs) do
        cb:SetChecked(false)
        cb:Hide()
        cb:ClearAllPoints()
    end
end

local function SetWidgetsEnabled(enabled)
    for _, cb in pairs(cbs) do
        cb:SetEnabled(enabled)
    end
    
    fromDropDown:SetEnabled(enabled)
    fromDropDown:Close()
    -- toDropDown:SetEnabled(enabled) -- TODO:
    toDropDown:Close()
end

local function ShowOverallLayout()
    Shrink()
    Reset()

    columns = {"AR", "SR", "Present", "Late/LeaveEarly", "Absent", "OnLeave", "SitOut"}
    for _, c in ipairs(columns) do
        cbs[c]:SetChecked(true)
    end
    
    cbs["AR"]:Show()    cbs["AR"]:SetPoint("LEFT", columnsText, 65, 0)
    cbs["AR30"]:Show()  cbs["AR30"]:SetPoint("LEFT", cbs["AR"], 65, 0)
    cbs["AR60"]:Show()  cbs["AR60"]:SetPoint("LEFT", cbs["AR30"], 65, 0)
    cbs["AR90"]:Show()  cbs["AR90"]:SetPoint("LEFT", cbs["AR60"], 65, 0)
    cbs["SR"]:Show()    cbs["SR"]:SetPoint("LEFT", cbs["AR90"], 65, 0)

    cbs["Present"]:Show()   cbs["Present"]:SetPoint("TOP", cbs["AR"], 0, -20)
    cbs["Absent"]:Show()    cbs["Absent"]:SetPoint("LEFT", cbs["Present"], 65, 0)
    cbs["OnLeave"]:Show()   cbs["OnLeave"]:SetPoint("LEFT", cbs["Absent"], 65, 0)
    cbs["SitOut"]:Show()    cbs["SitOut"]:SetPoint("LEFT", cbs["OnLeave"], 65, 0)
    
    cbs["Loots"]:Show()             cbs["Loots"]:SetPoint("TOP", cbs["Present"], 0, -20)
    cbs["Late/LeaveEarly"]:Show()   cbs["Late/LeaveEarly"]:SetPoint("LEFT", cbs["Loots"], 65, 0)
end

local function ShowSingleDayLayout()
    Shrink()
    Reset()

    toDropDown:Show()
    toDropDown:SetSelected("(WIP)")
    toDropDown:SetEnabled(false)
    periodToText:Show()
    fromDropDown:Close()
    toDropDown:Close()

    columns = {"AR", "SR", "DailyAttendance"}
    for _, c in ipairs(columns) do
        cbs[c]:SetChecked(true)
    end
    
    cbs["AR"]:Show()                cbs["AR"]:SetPoint("LEFT", columnsText, 65, 0)
    cbs["SR"]:Show()                cbs["SR"]:SetPoint("LEFT", cbs["AR"], 65, 0)
    cbs["Loots"]:Show()             cbs["Loots"]:SetPoint("LEFT", cbs["SR"], 65, 0)
    cbs["DailyAttendance"]:Show()   cbs["DailyAttendance"]:SetPoint("LEFT", cbs["Loots"], 65, 0)
end

local function ShowMultiDaysLayout()
    Shrink()
    Reset()
    toDropDown:Show()
    periodToText:Show()
end

local function LoadDropDown()
    local fromItems = {
        {
            ["text"] = L["Overall"],
            ["onClick"] = function()
                date1, date2 = nil, nil
                ShowOverallLayout()
            end,
        },
    }
    local toItems = {}

    -- dates
    local dates = {}
    for d, _ in pairs(_G[GRA_R_RaidLogs]) do
        table.insert(dates, d)
    end
    table.sort(dates)

    for _, d in ipairs(dates) do
        table.insert(fromItems, {
            ["text"] = date("%x", GRA:DateToSeconds(d)),
            ["onClick"] = function()
                date1 = d
                ShowSingleDayLayout() -- TODO: check toDropDown
            end,
        })
        -- TODO:
        -- table.insert(toItems, {
        --     ["text"] = date("%x", GRA:DateToSeconds(d)),
        --     ["onClick"] = function()

        --     end,
        -- })
    end

    -- from
    fromDropDown:SetItems(fromItems)
    wipe(fromItems)
    -- to
    -- toDropDown:SetItems(toItems)
    -- wipe(toItems)
end

local COLUMN_ORDER = {"AR", "AR30", "AR60", "AR90", "SR", "Present", "Late/LeaveEarly", "Absent", "OnLeave", "SitOut", "Loots", "DailyAttendance"}
local function SortColumn()
    table.sort(columns, function(a, b)
		return GRA:GetIndex(COLUMN_ORDER, a) < GRA:GetIndex(COLUMN_ORDER, b)
	end)
end

local result = {}
local function PrepareResult()
    isCalculating = true
    wipe(result)
    -- disable
    SetWidgetsEnabled(false)
    
    exportFrame.generateBtn:Hide()
    exportFrame.progressBar:Show()

    if date1 and date2 then -- multi days
        GRA:Debug("|cff00FF7FShowExportFrame_PrepareResult:|r " .. date1 .. " to " .. date2)

    elseif date1 then -- single day
        GRA:Debug("|cff00FF7FShowExportFrame_PrepareResult:|r " .. date1)
        local playerAtts, playerLoots, dates = GRA:CalcAtendanceRateAndLoots(date1, date1, exportFrame.progressBar)
        dateColumns = dates

        for name, t in pairs(_G[GRA_R_Roster]) do
            if not t["altOf"] then
                result[name] = {
                    ["AR"] = tonumber(format("%.1f", t["attLifetime"][5])) .. "%",
                    ["SR"] = t["attLifetime"][6] == 0 and "0%" or (tonumber(format("%.1f", t["attLifetime"][6] / t["attLifetime"][1] * 100)) .. "%"),
                    ["Loots"] = t["loots"],
                    ["DailyAttendance"] = playerAtts[name]["dailyAttendance"],
                }
            end
        end

    else -- overall
        GRA:Debug("|cff00FF7FShowExportFrame_PrepareResult:|r Overall")
        GRA:CalcAtendanceRateAndLoots(nil, nil, exportFrame.progressBar, true)
        for name, t in pairs(_G[GRA_R_Roster]) do
            if not t["altOf"] then
                result[name] = {
                    ["AR"] = tonumber(format("%.1f", t["attLifetime"][5])) .. "%",
                    ["AR30"] = tonumber(format("%.1f", t["att30"][5])) .. "%",
                    ["AR60"] = tonumber(format("%.1f", t["att60"][5])) .. "%",
                    ["AR90"] = tonumber(format("%.1f", t["att90"][5])) .. "%",
                    ["SR"] = t["attLifetime"][6] == 0 and "0%" or (tonumber(format("%.1f", t["attLifetime"][6] / t["attLifetime"][1] * 100)) .. "%"),
                    ["Present"] = t["attLifetime"][1],
                    ["Absent"] = t["attLifetime"][2],
                    ["Late/LeaveEarly"] = t["attLifetime"][3],
                    ["OnLeave"] = t["attLifetime"][4],
                    ["SitOut"] = t["attLifetime"][6],
                    ["Loots"] = t["loots"],
                }
            end
        end
    end
end

local function ShowResult()
    SortColumn()
    -- localized header
    for i, c in ipairs(columns) do
        if i == 1 then
            resultFrame.editBox:Insert(L["Name"] .. "," .. L[c])
        else
            if c ~= "DailyAttendance" then
                resultFrame.editBox:Insert("," .. L[c])
            end
        end
    end
    -- date columns
    if cbs["DailyAttendance"]:GetChecked() then
        for i, d in ipairs(dateColumns) do
            resultFrame.editBox:Insert("," .. date("%x", GRA:DateToSeconds(d)))
        end
    end

    for name, t in pairs(_G[GRA_R_Roster]) do
        if not t["altOf"] then
            resultFrame.editBox:Insert("\n" .. GRA:GetShortName(name))
            for _, c in ipairs(columns) do
                -- concat selected columns
                if cbs[c]:GetChecked() then
                    if c == "DailyAttendance" then
                        for _, d in ipairs(dateColumns) do
                            if result[name]["DailyAttendance"][d] then -- player has attendance on d
                                resultFrame.editBox:Insert("," .. (GRA:SecondsToTime(result[name]["DailyAttendance"][d][1]) .. "-" .. GRA:SecondsToTime(result[name]["DailyAttendance"][d][2])))
                            else
                                resultFrame.editBox:Insert(",")
                            end
                        end
                    else
                        resultFrame.editBox:Insert("," .. (result[name][c] or ""))
                    end
                end
            end
        end
    end

    for _, c in ipairs(columns) do
        
    end

    resultFrame:Show()
end

function GRA:ShowExportFrame(d)
    GRA:Debug("|cff00FF7FShowExportFrame:|r " .. (d or "Overall"))
    if isCalculating then
        GRA:Print(L["Calculating...Please wait."])
        return
    end

    if GRA:Getn(cbs) == 0 then CreateCheckButtons() end
    LoadDropDown()

    if d then
        date1 = d
        fromDropDown:SetSelected(date("%x", GRA:DateToSeconds(d)))
        ShowSingleDayLayout()
    else
        fromDropDown:SetSelected(L["Overall"])
        ShowOverallLayout()
    end
    exportFrame:Show()
end

-----------------------------------------
-- generate button
-----------------------------------------
local generateBtn = GRA:CreateButton(exportFrame, L["Generate!"], "red", {exportFrame:GetWidth()-10, 20}, "GRA_FONT_SMALL")
exportFrame.generateBtn = generateBtn
generateBtn:SetPoint("BOTTOM", 0, 5)
generateBtn:SetScript("OnClick", function()
    PrepareResult()
end)

-----------------------------------------
-- progress bar
-----------------------------------------
local progressBar
progressBar = GRA:CreateProgressBar(exportFrame, generateBtn:GetWidth(), generateBtn:GetHeight(), 0, function()
    progressBar.fadeOut:Play()
end, true, [[Interface\AddOns\GuildRaidAttendance\Media\bar.tga]])
exportFrame.progressBar = progressBar
progressBar:Hide()
progressBar:SetAllPoints(generateBtn)

progressBar.fadeOut = progressBar:CreateAnimationGroup()
progressBar.fadeOut:SetScript("OnFinished", function()
    progressBar:Hide()
    progressBar:Reset()
    GRA:ChangeSizeWithAnimation(exportFrame, nil, HEIGHT_EXPAND, function() generateBtn:SetEnabled(false) end, function() generateBtn:SetEnabled(true) end)
    -- re-enable
    SetWidgetsEnabled(true)
    ShowResult()
    isCalculating = false
end)

local fadeOutAlpha = progressBar.fadeOut:CreateAnimation("Alpha")
fadeOutAlpha:SetFromAlpha(1)
fadeOutAlpha:SetToAlpha(0)
fadeOutAlpha:SetDuration(.3)
fadeOutAlpha:SetStartDelay(.5)

-----------------------------------------
-- script
-----------------------------------------
exportFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(exportFrame)
end)

exportFrame:SetScript("OnHide", function()
    isCalculating = false
    -- reset height
    exportFrame:SetHeight(HEIGHT_NORMAL)
    -- reset button and bar
    generateBtn:Show()
    progressBar:Hide()
    progressBar:Reset()
    -- reset dropdown, cbs
    Reset()
    -- reset others
    date1, date2 = nil, nil
    wipe(columns)
    wipe(dateColumns)
    wipe(result)
end)