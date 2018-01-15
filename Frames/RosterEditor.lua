local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LGN = LibStub:GetLibrary("LibGuildNotes")

local class_roles = {
    ["DEATHKNIGHT"] = {"TANK", "DPS"},
    ["DEMONHUNTER"] = {"TANK", "DPS"},
    ["DRUID"] = {"TANK", "HEALER", "DPS"},
    ["HUNTER"] = {"DPS"},
    ["MAGE"] = {"DPS"},
    ["MONK"] = {"TANK", "HEALER", "DPS"},
    ["PALADIN"] = {"TANK", "HEALER", "DPS"},
    ["PRIEST"] = {"HEALER", "DPS"},
    ["ROGUE"] = {"DPS"},
    ["SHAMAN"] = {"HEALER", "DPS"},
    ["WARLOCK"] = {"DPS"},
    ["WARRIOR"] = {"TANK", "DPS"},
}

----------------------------------------------------------------------------------
-- roster editor
----------------------------------------------------------------------------------
local rosterEditorFrame = GRA:CreateFrame(L["Roster Editor"], "GRA_RosterEditorFrame", gra.mainFrame, 190, gra.mainFrame:GetHeight())
gra.rosterEditorFrame = rosterEditorFrame
rosterEditorFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
rosterEditorFrame.header.closeBtn:SetText("←")
local fontName = GRA_FONT_BUTTON:GetFont()
rosterEditorFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
rosterEditorFrame.header.closeBtn:SetScript("OnClick", function() rosterEditorFrame:Hide() gra.configFrame:Show() end)

local tip = CreateFrame("Frame", nil, rosterEditorFrame)
tip:SetSize(rosterEditorFrame:GetWidth()-10, 15)
tip:SetPoint("TOP", 0, -5)
tip:SetScript("OnEnter", function()
    GRA_Tooltip:SetOwner(rosterEditorFrame.header, "ANCHOR_TOPRIGHT", 0, 1)
    GRA_Tooltip:AddLine(L["Roster Editor"])
    GRA_Tooltip:AddLine(L["Double Click: "] .. "|cffffffff" .. L["Edit fullname (must contain realm name)."])
    GRA_Tooltip:AddLine(L["Right Click: "] .. "|cffffffff" .. L["Set main."])
    GRA_Tooltip:Show()
end)
tip:SetScript("OnLeave", function() GRA_Tooltip:Hide() end)

local rosterText = tip:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
rosterText:SetText(gra.colors.chartreuse.s .. L["Hover here for more details."])
rosterText:SetPoint("LEFT")

local deleted, renamed, roleChanged, mainChanged = {}, {}, {}, {}
local scroll = GRA:CreateScrollFrame(rosterEditorFrame, -25, 55)
local LoadRoster

--------------------------------------------------
-- Discard
--------------------------------------------------
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
            t[2]:SetText(GRA:GetClassColoredName(n))
        end
        wipe(renamed)
    end

    if GRA:Getn(roleChanged) ~= 0 then
        -- undo roleChanged
        for n, t in pairs(roleChanged) do
            for roleName, roleBtn in pairs(t[2]) do
                if roleName == _G[GRA_R_Roster][n]["role"] then
                    roleBtn:SetAlpha(1)
                else
                    roleBtn:SetAlpha(.2)
                end
            end
        end
        wipe(roleChanged)
    end

    if GRA:Getn(mainChanged) ~= 0 then
        -- undo mainChanged
        for n, t in pairs(mainChanged) do
            if _G[GRA_R_Roster][n]["altOf"] then
                t[2]:SetText(GRA:GetClassColoredName(n) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
            else
                t[2]:SetText(GRA:GetClassColoredName(n))
            end
        end
        wipe(mainChanged)
    end
end

local discardBtn = GRA:CreateButton(rosterEditorFrame, L["Discard All Changes"], "red", {rosterEditorFrame:GetWidth()-10, 20})
discardBtn:SetPoint("BOTTOMLEFT", 5, 5)
discardBtn:SetScript("OnClick", function()
    DiscardChanges()
end)

--------------------------------------------------
-- Delete
--------------------------------------------------
local function Delete()
    local names = {}
    for n, g in pairs(deleted) do
        table.insert(names, n)
    end
    for d, t in pairs(_G[GRA_R_RaidLogs]) do
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
                if detail[1] == "EP" or detail[1] == "PGP" or detail[1] == "PEP" or detail[1] == "DKP_A" or detail[1] == "DKP_P" then
                    GRA:Remove(detail[4], name)
                    if #detail[4] == 0 then
                        table.remove(t["details"], i)
                    end
                else -- GP/DKP_C
                    if detail[4] == name then
                        -- just delete this entry
                        table.remove(t["details"], i)
                    end
                end
            end
        end
    end
    _G[GRA_R_Roster] = GRA:RemoveElementsByKeys(_G[GRA_R_Roster], names)
end

--------------------------------------------------
-- Rename
--------------------------------------------------
local function Rename()
    local names = {}
    -- renamed[old fullname] = {new fullname, FSObject}
    for n, t in pairs(renamed) do
        table.insert(names, n)
        -- GRA:Debug(n .. " --> " .. t[1])
    end
    -- rename in _G[GRA_R_RaidLogs]
    for _, t in pairs(_G[GRA_R_RaidLogs]) do
        for oldName, newName in pairs(renamed) do
            -- attendees
            if t["attendees"][oldName] then
                t["attendees"][newName[1]] = t["attendees"][oldName]
            end
            -- absentees
            if t["absentees"][oldName] then
                t["absentees"][newName[1]] = t["absentees"][oldName]
            end
            -- details
            for _, detail in pairs(t["details"]) do
                if detail[1] == "EP" or detail[1] == "PGP" or detail[1] == "PEP" or detail[1] == "DKP_A" or detail[1] == "DKP_P" then
                    if tContains(detail[4], oldName) then
                        -- delete old
                        GRA:Remove(detail[4], oldName)
                        -- insert new
                        table.insert(detail[4], newName[1])
                    end
                else -- GP/DKP_C
                    if detail[4] == oldName then
                        detail[4] = newName[1]
                    end
                end
            end
        end
        -- delete old
        t["attendees"] = GRA:RemoveElementsByKeys(t["attendees"], names)
        t["absentees"] = GRA:RemoveElementsByKeys(t["absentees"], names)
    end
    -- rename in _G[GRA_R_Roster]
    for oldName, newName in pairs(renamed) do
        _G[GRA_R_Roster][newName[1]] = _G[GRA_R_Roster][oldName]
    end
    _G[GRA_R_Roster] = GRA:RemoveElementsByKeys(_G[GRA_R_Roster], names)
end

--------------------------------------------------
-- Set role
--------------------------------------------------
local function SetRole()
    for n, t in pairs(roleChanged) do
        _G[GRA_R_Roster][n]["role"] = t[1]
    end
end

--------------------------------------------------
-- Set main
--------------------------------------------------
local function SetMain()
    for n, t in pairs(mainChanged) do
        if t[1] then
            _G[GRA_R_Roster][n]["altOf"] = t[1]
        else -- delete main
            _G[GRA_R_Roster][n] = GRA:RemoveElementsByKeys(_G[GRA_R_Roster][n], {"altOf"})
        end
    end
end

--------------------------------------------------
-- Save
--------------------------------------------------
local function SaveChanges()
    if gra.popupEditBox then gra.popupEditBox:Hide() end
    if GRA:Getn(deleted) == 0 
        and GRA:Getn(renamed) == 0 
        and GRA:Getn(roleChanged) == 0 
        and GRA:Getn(mainChanged) == 0 
        then return end

    local deletedDetails, renamedDetails, roleChangedDetails, mainChangedDetails = {}, {}, {}, {}

    -- deleted names
    for n, g in pairs(deleted) do
        table.insert(deletedDetails, GRA:GetClassColoredName(n))

        -- if contains renamed player
        if renamed[n] then renamed = GRA:RemoveElementsByKeys(renamed, {n}) end
        -- if contains role changed player
        if roleChanged[n] then roleChanged = GRA:RemoveElementsByKeys(roleChanged, {n}) end
        -- if contains main changed player
        if mainChanged[n] then mainChanged = GRA:RemoveElementsByKeys(mainChanged, {n}) end
    end

    -- renamed names
    for n, t in pairs(renamed) do
        table.insert(renamedDetails, GRA:GetClassColoredName(t[1], _G[GRA_R_Roster][n]["class"]) .. "(" .. GRA:GetClassColoredName(n) .. ")")
    
        -- if contains role changed player
        if roleChanged[n] then
            roleChanged[t[1]] = roleChanged[n]
            -- can't get unsaved player class, so temp save it in table.
            roleChanged[t[1]][3] = _G[GRA_R_Roster][n]["class"]
            roleChanged = GRA:RemoveElementsByKeys(roleChanged, {n})
        end
        -- if contains main changed player
        if mainChanged[n] then
            mainChanged[t[1]] = mainChanged[n]
            -- can't get unsaved player class, so temp save it in table.
            mainChanged[t[1]][3] = _G[GRA_R_Roster][n]["class"]
            mainChanged = GRA:RemoveElementsByKeys(mainChanged, {n})
        end
    end

    -- primary role changed info
    for n, t in pairs(roleChanged) do
        table.insert(roleChangedDetails, GRA:GetClassColoredName(n, t[3]) .. "|TInterface\\AddOns\\GuildRaidAttendance\\Media\\Roles\\" .. t[1] .. ".blp:0|t")
    end

    -- main changed info
    for n, t in pairs(mainChanged) do
        table.insert(mainChangedDetails, GRA:GetClassColoredName(n, t[3]) .. "(" .. GRA:GetClassColoredName(t[1] or L["none"]) .. ")")
    end

    local confirm = GRA:CreateConfirmBox(rosterEditorFrame, rosterEditorFrame:GetWidth()-10, gra.colors.firebrick.s .. L["Apply changes to roster?"] .. "|r\n" .. L["All related logs will be updated."], function()
        -- delete!
        Delete()
        -- rename!
        Rename()
        -- set role!
        SetRole()
        -- set main!
        SetMain()
        -- load and show
        LoadRoster()
        
        -- show msg
        if GRA:Getn(deleted) ~= 0 then
            GRA:Print(L["Deleted: "] .. GRA:TableToString(deletedDetails))
        end
        if GRA:Getn(renamed) ~= 0 then
            GRA:Print(L["Renamed: "] .. GRA:TableToString(renamedDetails))
        end
        if GRA:Getn(roleChanged) ~= 0 then
            GRA:Print(L["Primary Role Changed: "] .. GRA:TableToString(roleChangedDetails))
        end
        if GRA:Getn(mainChanged) ~= 0 then
            GRA:Print(L["Main Changed: "] .. GRA:TableToString(mainChangedDetails))
        end

        wipe(deletedDetails)
        wipe(renamedDetails)
        wipe(roleChangedDetails)
        wipe(mainChangedDetails)
        wipe(deleted)
        wipe(renamed)
        wipe(roleChanged)
        wipe(mainChanged)

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

--------------------------------------------------
-- grid
--------------------------------------------------
local mains, availableMains = {}, {}
local function CreatePlayerGrid(name)
    -- local g = CreateFrame("Frame", nil, rosterEditorFrame.scrollFrame.content)
    local g = CreateFrame("Button", nil, rosterEditorFrame.scrollFrame.content)
    GRA:StylizeFrame(g)
    g:SetSize(rosterEditorFrame:GetWidth()-15, 20)
    g:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    local s = g:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    g.s = s
    if _G[GRA_R_Roster][name]["altOf"] then
        s:SetText(GRA:GetClassColoredName(name) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
    else
        s:SetText(GRA:GetClassColoredName(name))
    end
    s:SetWordWrap(false)
    s:SetJustifyH("LEFT")
    s:SetPoint("LEFT", 5, 0)
    s:SetPoint("RIGHT", -25, 0)

    local b = GRA:CreateButton(g, "×", nil, {20, 20}, "GRA_FONT_BUTTON")
    g.b = b
    b:SetPoint("RIGHT")
    b:SetScript("OnClick", function()
        if not deleted[name] then
            deleted[name] = g
            g:SetAlpha(.35)
        else
            deleted = GRA:RemoveElementsByKeys(deleted, {name})
            g:SetAlpha(1)
        end
    end)

    g.roles = {}
    local roles = class_roles[_G[GRA_R_Roster][name]["class"]]
    for i = #roles, 1, -1 do
        g.roles[roles[i]] = GRA:CreateButton(g, "", "none", {16, 16})
        g.roles[roles[i]]:SetAlpha(.2)
        g.roles[roles[i]]:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\Roles\]] .. roles[i])
        g.roles[roles[i]]:SetScript("OnClick", function()
            for roleName, roleBtn in pairs(g.roles) do
                if roleName ~= roles[i] then
                    roleBtn:SetAlpha(.2)
                else
                    roleBtn:SetAlpha(1)
                    if _G[GRA_R_Roster][name]["role"] == roleName then
                        roleChanged = GRA:RemoveElementsByKeys(roleChanged, {name})
                    else
                        roleChanged[name] = {roleName, g.roles}
                    end
                end
            end
        end)
        
        if roles[i + 1] then
            g.roles[roles[i]]:SetPoint("RIGHT", g.roles[roles[i + 1]], "LEFT", 1, 0)
        else
            g.roles[roles[i]]:SetPoint("RIGHT", b, "LEFT", -1, 0)
        end
    end

    -- no role, set to "DPS"
    if not _G[GRA_R_Roster][name]["role"] then
        _G[GRA_R_Roster][name]["role"] = "DPS"
        g.roles["DPS"]:SetAlpha(1)
    else
        g.roles[_G[GRA_R_Roster][name]["role"]]:SetAlpha(1)
    end

    g:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            wipe(availableMains)
            -- clear button
            table.insert(availableMains, {
                ["text"] = gra.colors.firebrick.s .. L["Clear"],
                ["onClick"] = function()
                    mainChanged[name] = {nil, s}
                    -- unmark
                    s:SetText(string.gsub(s:GetText(), " %(" .. L["alt"] .. "%)", ""))
                end
            })
            -- main list
            for _, item in pairs(mains) do
                if item.name ~= name then
                    item.onClick = function(text)
                        mainChanged[name] = {item.name, s}
                        -- mark
                        if not string.find(s:GetText(), " %(" .. L["alt"] .. "%)") then
                            s:SetText(s:GetText() .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
                        end
                    end

                    -- remove highlight
                    item.highlight = false
                    -- highlight current
                    if mainChanged[name] then
                        if item.name == mainChanged[name][1] then
                            item.highlight = true
                        end
                    elseif item.name == _G[GRA_R_Roster][name]["altOf"] then
                        item.highlight = true
                    end
                    table.insert(availableMains, item)
                end
            end
            
            GRA:ShowContextMenu(rosterEditorFrame, 100, L["Alt of"], 10, availableMains)
        end
    end)

    g:SetScript("OnDoubleClick", function(self, button)
        if button ~= "LeftButton" then return end
        if g:GetAlpha() ~= 1 then return end
        local p = GRA:CreatePopupEditBox(g, g:GetWidth(), g:GetHeight(), function(text)
            -- print(_G[GRA_R_Roster][name]["class"])
            -- if name changed
            if text ~= name then
                -- new fullname, FSObject
                renamed[name] = {text, s}
            else
                -- exists, change back
                if renamed[name] then
                    renamed = GRA:RemoveElementsByKeys(renamed, {name})
                end
            end

            if _G[GRA_R_Roster][name]["altOf"] or mainChanged[name] then -- 已有或即将有
                s:SetText(GRA:GetClassColoredName(text, _G[GRA_R_Roster][name]["class"]) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
            else
                s:SetText(GRA:GetClassColoredName(text, _G[GRA_R_Roster][name]["class"]))
            end
        end)
        p:SetText(name)
        p:SetPoint("LEFT")
        p.editBox:SetCursorPosition(0)
    end)

    return g
end

LoadRoster = function()
    scroll:Reset()
    wipe(mains)

    -- sort
    local sorted = {}
    for name, t in pairs(_G[GRA_R_Roster]) do
        table.insert(sorted, {name, t["class"]})
    end

    table.sort(sorted, function(a, b)
		if a[2] ~= b[2] then
			return GRA:GetIndex(gra.CLASS_ORDER, a[2]) < GRA:GetIndex(gra.CLASS_ORDER, b[2])
		else
            return a[1] < b[1]
		end
	end)

    local last
    for k, t in pairs(sorted) do
        local g = CreatePlayerGrid(t[1])
        -- scroll:SetWidgetAutoWidth(g)

        -- init mains in context menu
        table.insert(mains, {
            ["text"] = GRA:GetClassColoredName(t[1]),
            ["name"] = t[1],
            -- ["onClick"] = function(text)
            -- end
        })

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
    wipe(roleChanged)
    wipe(mainChanged)
    LoadRoster()
end)