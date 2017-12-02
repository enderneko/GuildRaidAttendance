local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LGN = LibStub:GetLibrary("LibGuildNotes")

----------------------------------------------------------------------------------
-- roster editor: change player name, delete player from roster
----------------------------------------------------------------------------------
local rosterEditorFrame = GRA:CreateFrame(L["Roster Editor"], "GRA_RosterEditorFrame", gra.mainFrame, 150, gra.mainFrame:GetHeight())
gra.rosterEditorFrame = rosterEditorFrame
rosterEditorFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
rosterEditorFrame.header.closeBtn:SetText("←")
local fontName = GRA_FONT_BUTTON:GetFont()
rosterEditorFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
rosterEditorFrame.header.closeBtn:SetScript("OnClick", function() rosterEditorFrame:Hide() gra.configFrame:Show() end)

-- help button
rosterEditorFrame.header.helpBtn = GRA:CreateButton(rosterEditorFrame.header, "?", "red", {16, 16}, "GRA_FONT_BUTTON")
rosterEditorFrame.header.helpBtn:SetPoint("RIGHT", rosterEditorFrame.header.closeBtn, "LEFT", 1, 0)
rosterEditorFrame.header.helpBtn:GetFontString():SetFont(fontName, 12)

rosterEditorFrame.header.helpBtn:HookScript("OnEnter", function()
    GRA_Tooltip:SetOwner(rosterEditorFrame.header, "ANCHOR_TOPRIGHT", 0, 1)
    GRA_Tooltip:AddLine(L["Edit Name"])
    GRA_Tooltip:AddLine(L["Double Click: "] .. "|cffffffff" .. L["Edit fullname (must contain realm name)."])
    GRA_Tooltip:Show()
end)

rosterEditorFrame.header.helpBtn:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)


local rosterText = rosterEditorFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
rosterText:SetPoint("TOPLEFT", 5, -8)

local deleted, renamed = {}, {}
local scroll = GRA:CreateScrollFrame(rosterEditorFrame, -25, 55)
local LoadRoster

local function DiscardChanges()
    if gra.popupEditBox then gra.popupEditBox:Hide() end
    if GRA:Getn(deleted) ~= 0 then
        -- undo deleted
        for n, g in pairs(deleted) do
            g:SetAlpha(1)
            g.b:SetEnabled(true)
        end
        wipe(deleted)
    end

    if GRA:Getn(renamed) ~= 0 then
        -- undo renamed
        for n, t in pairs(renamed) do
            t[1]:SetText(GRA:GetClassColoredName(n))
        end
        wipe(renamed)
    end
end

local discardBtn = GRA:CreateButton(rosterEditorFrame, L["Discard All Changes"], "red", {rosterEditorFrame:GetWidth()-10, 20})
discardBtn:SetPoint("BOTTOMLEFT", 5, 5)
discardBtn:SetScript("OnClick", function()
    DiscardChanges()
end)

local function Delete()
    local names = {}
    for n, g in pairs(deleted) do
        table.insert(names, n)
    end
    for d, t in pairs(GRA_RaidLogs) do
        -- delete
        t["attendees"] = GRA:RemoveElementsByKeys(t["attendees"], names)
        t["absentees"] = GRA:RemoveElementsByKeys(t["absentees"], names)
        
        -- delete details
        for _, name in pairs(names) do
            -- GRA:Debug(name)
            -- 倒序删除！
            for i = #t["details"], 1, -1 do
                local detail = t["details"][i]
                -- if d == "20170824" then GRA:Debug(d .. ": (" .. i .. ") " .. detail[3]) end
                if detail[1] == "EP" then
                    GRA:Remove(detail[4], name)
                    if #detail[4] == 0 then
                        table.remove(t["details"], i)
                    end
                elseif detail[1] == "GP" then
                    if detail[4] == name then
                        -- just delete this entry
                        table.remove(t["details"], i)
                    end
                else -- PGP PEP
                    GRA:Remove(detail[4], name)
                    if #detail[4] == 0 then
                        table.remove(t["details"], i)
                    end
                end
            end
        end
    end
    GRA_Roster = GRA:RemoveElementsByKeys(GRA_Roster, names)
end

local function Rename()
    local names = {}
    -- FSObject, old fullname, new fullname
    for n, t in pairs(renamed) do
        table.insert(names, n)
        -- GRA:Debug(n .. " --> " .. t[2])
    end
    -- rename in GRA_RaidLogs
    for _, t in pairs(GRA_RaidLogs) do
        for oldName, newName in pairs(renamed) do
            -- attendees
            if t["attendees"][oldName] then
                t["attendees"][newName[2]] = t["attendees"][oldName]
            end
            -- absentees
            if t["absentees"][oldName] then
                t["absentees"][newName[2]] = t["absentees"][oldName]
            end
            -- details
            for _, detail in pairs(t["details"]) do
                if detail[1] == "EP" then
                    if tContains(detail[4], oldName) then
                        -- delete old
                        GRA:Remove(detail[4], oldName)
                        -- insert new
                        table.insert(detail[4], newName[2])
                    end
                else -- GP
                    if detail[4] == oldName then
                        detail[4] = newName[2]
                    end
                end
            end
        end
        -- delete old
        t["attendees"] = GRA:RemoveElementsByKeys(t["attendees"], names)
        t["absentees"] = GRA:RemoveElementsByKeys(t["absentees"], names)
    end
    -- rename in GRA_Roster
    for oldName, newName in pairs(renamed) do
        GRA_Roster[newName[2]] = GRA_Roster[oldName]
    end
    GRA_Roster = GRA:RemoveElementsByKeys(GRA_Roster, names)
end

local function SaveChanges()
    if gra.popupEditBox then gra.popupEditBox:Hide() end
    if GRA:Getn(deleted) == 0 and GRA:Getn(renamed) == 0 then return end
    local deletedShortNames, renamedDetails = {}, {}, {}

    -- deleted names
    for n, g in pairs(deleted) do
        -- table.insert(deletedFullNames, n)
        table.insert(deletedShortNames, GRA:GetClassColoredName(n))

        -- if contains renamed player
        if renamed[n] then renamed = GRA:RemoveElementsByKeys(renamed, {n}) end
    end
    -- renamed names
    for n, t in pairs(renamed) do
        table.insert(renamedDetails, t[1]:GetText() .. "|cffffffff(" .. GRA:GetClassColoredName(n) .. "|cffffffff)|r")
    end

    local confirm = GRA:CreateConfirmBox(rosterEditorFrame, rosterEditorFrame:GetWidth()-10, gra.colors.firebrick.s .. L["Apply changes to roster?"] .. "|r\n" .. L["All related logs will be updated."], function()
        -- delete!
        Delete()
        -- rename!
        Rename()
        -- load and show
        LoadRoster()
        rosterText:SetText("|cff80FF00" .. GRA:Getn(GRA_Roster) .. " " .. L["members"])
        -- deleted = {}
        -- renamed = {}
        if GRA:Getn(deleted) ~= 0 then
            GRA:Print(L["Deleted: "] .. GRA:TableToString(deletedShortNames))
        end
        if GRA:Getn(renamed) ~= 0 then
            GRA:Print(L["Renamed: "] .. GRA:TableToString(renamedDetails))
        end
        wipe(deleted)
        wipe(renamed)

        -- update sheet
        GRA:ShowAttendanceSheet()
        -- update current log
        GRA:RefreshCurrentLog()
    end, true)
    confirm:SetPoint("LEFT", 5, 0)
end

local saveBtn = GRA:CreateButton(rosterEditorFrame, L["Save All Changes"], "green", {rosterEditorFrame:GetWidth()-10, 20})
saveBtn:SetPoint("BOTTOMLEFT", discardBtn, "TOPLEFT", 0, 5)
saveBtn:SetScript("OnClick", function()
    SaveChanges()
end)


local function CreatePlayerGrid(name)
    -- local g = CreateFrame("Frame", nil, rosterEditorFrame.scrollFrame.content)
    local g = CreateFrame("Button", nil, rosterEditorFrame.scrollFrame.content)
    GRA:StylizeFrame(g)
    g:SetSize(rosterEditorFrame:GetWidth()-15, 20)
    
    local s = g:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    g.s = s
    s:SetText(GRA:GetClassColoredName(name))
    s:SetWordWrap(false)
    s:SetJustifyH("LEFT")
    s:SetPoint("LEFT", 5, 0)
    s:SetPoint("RIGHT", -25, 0)

    local b = GRA:CreateButton(g, "×", nil, {20, 20}, "GRA_FONT_BUTTON")
    g.b = b
    b:SetPoint("RIGHT")
    b:SetScript("OnClick", function()
        deleted[name] = g
        g:SetAlpha(.35)
        b:SetEnabled(false)
    end)

    g:SetScript("OnDoubleClick", function(self, button)
        if g:GetAlpha() ~= 1 then return end
        local p = GRA:CreatePopupEditBox(g, g:GetWidth(), g:GetHeight(), function(text)
            -- print(GRA_Roster[name]["class"])
            -- if name changed
            if text ~= name then
                -- FSObject, new fullname
                renamed[name] = {g.s, text}
            else
                -- exists, change back
                if renamed[name] then
                    renamed = GRA:RemoveElementsByKeys(renamed, {name})
                end
            end
            g.s:SetText("|c" .. RAID_CLASS_COLORS[GRA_Roster[name]["class"]].colorStr .. GRA:GetShortName(text))
        end)
        p:SetText(name)
        p:SetPoint("LEFT")
        p.editBox:SetCursorPosition(0)
    end)

    return g
end

LoadRoster = function()
    scroll:Reset()
    
    local last
    for n, t in pairs(GRA_Roster) do
        local g = CreatePlayerGrid(n)
        -- scroll:SetWidgetAutoWidth(g)

        if last then
            g:SetPoint("TOP", last, "BOTTOM", 0, -5)
        else
            g:SetPoint("TOPLEFT", 5, 0)
        end
        last = g
    end
end

rosterEditorFrame:SetScript("OnShow", function()
    wipe(deleted)
    wipe(renamed)
    rosterText:SetText("|cff80FF00" .. GRA:Getn(GRA_Roster) .. " " .. L["members"])
    LoadRoster()
end)