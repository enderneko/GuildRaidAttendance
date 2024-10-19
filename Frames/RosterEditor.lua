local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local CLASS_ROLES = {
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
local rosterEditorFrame = GRA.CreateFrame(L["Roster Editor"], "GRA_RosterEditorFrame", gra.mainFrame, 190, gra.mainFrame:GetHeight())
gra.rosterEditorFrame = rosterEditorFrame
rosterEditorFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
rosterEditorFrame.header.closeBtn:SetText("←")
local fontName = GRA_FONT_BUTTON:GetFont()
rosterEditorFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
rosterEditorFrame.header.closeBtn:SetScript("OnClick", function() rosterEditorFrame:Hide() gra.configFrame:Show() end)

local tip = CreateFrame("Frame", nil, rosterEditorFrame)
tip:SetSize(rosterEditorFrame:GetWidth()-10, 15)
tip:SetPoint("TOP", 0, -4)
tip:SetScript("OnEnter", function()
    GRA_Tooltip:SetOwner(rosterEditorFrame.header, "ANCHOR_TOPRIGHT", 0, 1)
    GRA_Tooltip:AddLine(L["Roster Editor"])
    GRA_Tooltip:AddLine(L["Double-Click: "] .. "|cffffffff" .. L["Edit fullname (must contain realm name)."])
    GRA_Tooltip:AddLine(L["Right-Click: "] .. "|cffffffff" .. L["Set main."])
    GRA_Tooltip:AddLine(L["Shift Right-Click: "] .. "|cffffffff" .. L["Set class"] .. ".")
    GRA_Tooltip:Show()
end)
tip:SetScript("OnLeave", function() GRA_Tooltip:Hide() end)

local rosterText = tip:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
rosterText:SetText(gra.colors.chartreuse.s .. L["Hover for more information."])
rosterText:SetPoint("LEFT")

local deleted, renamed, roleChanged, mainChanged, classChanged = {}, {}, {}, {}, {}
local scroll = GRA.CreateScrollFrame(rosterEditorFrame, -20, 55)
local LoadRoster

---------------------------------------------------------------------
-- Discard
---------------------------------------------------------------------
local function DiscardChanges()
    if gra.popupEditBox then gra.popupEditBox:Hide() end
    if GRA.Getn(deleted) ~= 0 then
        -- undo deleted
        for n, g in pairs(deleted) do
            g:SetAlpha(1)
            g:Unhighlight(true)
        end
        wipe(deleted)
    end

    if GRA.Getn(renamed) ~= 0 then
        -- undo renamed
        for n, t in pairs(renamed) do
            t[2]:SetText(GRA.GetClassColoredName(n))
            t[2]:GetParent():Unhighlight(true)
        end
        wipe(renamed)
    end

    if GRA.Getn(roleChanged) ~= 0 then
        -- undo roleChanged
        for n, t in pairs(roleChanged) do
            for roleName, roleBtn in pairs(t[2]) do
                if roleName == GRA_Roster[n]["role"] then
                    roleBtn:SetAlpha(1)
                else
                    roleBtn:SetAlpha(.2)
                end
                roleBtn:GetParent():Unhighlight(true)
            end
        end
        wipe(roleChanged)
    end

    if GRA.Getn(mainChanged) ~= 0 then
        -- undo mainChanged
        for n, t in pairs(mainChanged) do
            if GRA_Roster[n]["altOf"] then
                t[2]:SetText(GRA.GetClassColoredName(n) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
            else
                t[2]:SetText(GRA.GetClassColoredName(n))
            end
            t[2]:GetParent():Unhighlight(true)
        end
        wipe(mainChanged)
    end

    if GRA.Getn(classChanged) ~= 0 then
        for n, t in pairs(classChanged) do
            if GRA_Roster[n]["altOf"] then
                t[2]:SetText(GRA.GetClassColoredName(n) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
            else
                t[2]:SetText(GRA.GetClassColoredName(n))
            end
            t[2]:GetParent():Unhighlight(true)
        end
        wipe(classChanged)
    end
end

local discardBtn = GRA.CreateButton(rosterEditorFrame, L["Discard All Changes"], "red", {rosterEditorFrame:GetWidth()-10, 20})
discardBtn:SetPoint("BOTTOMLEFT", 5, 5)
discardBtn:SetScript("OnClick", function()
    DiscardChanges()
end)

---------------------------------------------------------------------
-- Delete
---------------------------------------------------------------------
local function Delete()
    local names = {}
    for n, g in pairs(deleted) do
        table.insert(names, n)
    end
    for d, t in pairs(GRA_Logs) do
        -- delete
        t["attendances"] = GRA.RemoveElementsByKeys(t["attendances"], names)

        -- delete details
        for _, name in pairs(names) do
            -- GRA.Debug(name)
            -- 倒序删除！ details
            for i = #t["details"], 1, -1 do
                local detail = t["details"][i]
                -- if d == "20170824" then GRA.Debug(d .. ": (" .. i .. ") " .. detail[3]) end
                if detail[1] == "EP" or detail[1] == "PGP" or detail[1] == "PEP" or detail[1] == "DKP_A" or detail[1] == "DKP_P" then
                    GRA.Remove(detail[4], name)
                    if #detail[4] == 0 then
                        table.remove(t["details"], i)
                    end
                elseif detail[1] == "GP" or detail[1] == "DKP_C" then -- GP/DKP_C
                    if detail[4] == name then
                        -- just delete this entry
                        table.remove(t["details"], i)
                    end
                else -- LOOT
                    if detail[3] == name then
                        -- just delete this entry
                        table.remove(t["details"], i)
                    end
                end
            end
        end
    end

    -- check main-alt
    for n, t in pairs(GRA_Roster) do
        if t["altOf"] then
            if GRA.GetIndex(names, t["altOf"]) then -- main is deleted
                t["altOf"] = nil
            end
        end
    end

    GRA_Roster = GRA.RemoveElementsByKeys(GRA_Roster, names)
end

---------------------------------------------------------------------
-- Rename
---------------------------------------------------------------------
local function Rename()
    local names = {}
    -- renamed[old fullname] = {new fullname, FSObject}
    for n, t in pairs(renamed) do
        table.insert(names, n)
        -- GRA.Debug(n .. " --> " .. t[1])
    end
    -- rename in GRA_Logs
    for _, t in pairs(GRA_Logs) do
        for oldName, newName in pairs(renamed) do
            -- attendance
            if t["attendances"][oldName] then
                t["attendances"][newName[1]] = t["attendances"][oldName]
            end
            -- details
            for _, detail in pairs(t["details"]) do
                if detail[1] == "EP" or detail[1] == "PGP" or detail[1] == "PEP" or detail[1] == "DKP_A" or detail[1] == "DKP_P" then
                    if GRA.TContains(detail[4], oldName) then
                        -- delete old
                        GRA.Remove(detail[4], oldName)
                        -- insert new
                        table.insert(detail[4], newName[1])
                    end
                elseif detail[1] == "GP" or detail[1] == "DKP_C" then -- GP/DKP_C
                    if detail[4] == oldName then
                        detail[4] = newName[1]
                    end
                else -- LOOT
                    if detail[3] == oldName then
                        detail[3] = newName[1]
                    end
                end
            end
        end
        -- delete old
        t["attendances"] = GRA.RemoveElementsByKeys(t["attendances"], names)
    end
    -- rename in GRA_Roster
    for oldName, newName in pairs(renamed) do
        GRA_Roster[newName[1]] = GRA_Roster[oldName]
    end
    GRA_Roster = GRA.RemoveElementsByKeys(GRA_Roster, names)
end

---------------------------------------------------------------------
-- Set role
---------------------------------------------------------------------
local function SetRole()
    for n, t in pairs(roleChanged) do
        GRA_Roster[n]["role"] = t[1]
    end
end

---------------------------------------------------------------------
-- Set main
---------------------------------------------------------------------
local function SetMain()
    for n, t in pairs(mainChanged) do
        if t[1] then
            GRA_Roster[n]["altOf"] = t[1]
        else -- delete main
            GRA_Roster[n]["altOf"] = nil
        end
    end
    if GRA.Getn(mainChanged) ~= 0 then
        GRA.UpdateMainAlt()
        -- calc AR
        GRA.Fire("GRA_MAINALT")
    end
end

---------------------------------------------------------------------
-- Set class
---------------------------------------------------------------------
local function SetClass()
    for n, t in pairs(classChanged) do
        GRA_Roster[n]["class"] = t[1]
    end
end

---------------------------------------------------------------------
-- Save
---------------------------------------------------------------------
local function SaveChanges()
    if gra.popupEditBox then gra.popupEditBox:Hide() end
    if GRA.Getn(deleted) == 0
        and GRA.Getn(renamed) == 0
        and GRA.Getn(roleChanged) == 0
        and GRA.Getn(mainChanged) == 0
        and GRA.Getn(classChanged) == 0
        then return end

    local deletedDetails, renamedDetails, roleChangedDetails, mainChangedDetails, classChangedDetails = {}, {}, {}, {}, {}

    -- deleted names
    for n, g in pairs(deleted) do
        table.insert(deletedDetails, GRA.GetClassColoredName(n))

        -- if contains renamed player
        if renamed[n] then renamed[n] = nil end
        -- if contains role changed player
        if roleChanged[n] then roleChanged[n] = nil end
        -- if contains main changed player
        if mainChanged[n] then mainChanged[n] = nil end
        -- if contains class changed player
        if classChanged[n] then classChanged[n] = nil end
    end

    -- renamed names
    for n, t in pairs(renamed) do
        table.insert(renamedDetails, GRA.GetClassColoredName(t[1], GRA_Roster[n]["class"]) .. "(" .. GRA.GetClassColoredName(n) .. ")")

        -- if contains role changed player
        if roleChanged[n] then
            roleChanged[t[1]] = roleChanged[n]
            -- can't get unsaved player class, so temp save it in table.
            roleChanged[t[1]][3] = GRA_Roster[n]["class"]
            roleChanged[n] = nil
        end
        -- if contains main changed player
        if mainChanged[n] then
            mainChanged[t[1]] = mainChanged[n]
            -- can't get unsaved player class, so temp save it in table.
            mainChanged[t[1]][3] = GRA_Roster[n]["class"]
            mainChanged[n] = nil
        end
        -- if contains class changed player
        if classChanged[n] then
            classChanged[t[1]] = classChanged[n]
            classChanged[n] = nil
        end
    end

    -- primary role changed info
    for n, t in pairs(roleChanged) do
        table.insert(roleChangedDetails, GRA.GetClassColoredName(n, t[3]) .. "|TInterface\\AddOns\\GuildRaidAttendance\\Media\\Roles\\" .. t[1] .. ".blp:0|t")
    end

    -- main changed info
    for n, t in pairs(mainChanged) do
        table.insert(mainChangedDetails, GRA.GetClassColoredName(n, t[3]) .. "(" .. GRA.GetClassColoredName(t[1] or L["none"]) .. ")")
    end

    -- class changed info
    for n, t in pairs(classChanged) do
        table.insert(classChangedDetails, GRA.GetClassColoredName(n, t[1]))
    end

    local confirm = GRA.CreateConfirmPopup(rosterEditorFrame, rosterEditorFrame:GetWidth()-10, gra.colors.firebrick.s .. L["Apply changes to roster?"] .. "|r\n" .. L["All related logs will be updated."], function()
        -- delete!
        Delete()
        -- rename!
        Rename()
        -- set role!
        SetRole()
        -- set main!
        SetMain()
        -- set class!
        SetClass()
        -- load and show
        LoadRoster()

        -- show msg
        if GRA.Getn(deleted) ~= 0 then
            GRA.Print(L["Deleted: "] .. GRA.TableToString(deletedDetails))
        end
        if GRA.Getn(renamed) ~= 0 then
            GRA.Print(L["Renamed: "] .. GRA.TableToString(renamedDetails))
        end
        if GRA.Getn(roleChanged) ~= 0 then
            GRA.Print(L["Primary Role Changed: "] .. GRA.TableToString(roleChangedDetails))
        end
        if GRA.Getn(mainChanged) ~= 0 then
            GRA.Print(L["Main Changed: "] .. GRA.TableToString(mainChangedDetails))
        end
        if GRA.Getn(classChanged) ~= 0 then
            GRA.Print(L["Class Changed: "] .. GRA.TableToString(classChangedDetails))
        end

        wipe(deletedDetails)
        wipe(renamedDetails)
        wipe(roleChangedDetails)
        wipe(mainChangedDetails)
        wipe(deleted)
        wipe(renamed)
        wipe(roleChanged)
        wipe(mainChanged)
        wipe(classChanged)

        -- update sheet and log
        GRA.Fire("GRA_ROSTER")
    end, true)
    confirm:SetPoint("LEFT", 5, 0)
end

local saveBtn = GRA.CreateButton(rosterEditorFrame, L["Save All Changes"], "green", {rosterEditorFrame:GetWidth()-10, 20})
saveBtn:SetPoint("BOTTOMLEFT", discardBtn, "TOPLEFT", 0, 5)
saveBtn:SetScript("OnClick", function()
    SaveChanges()
end)

---------------------------------------------------------------------
-- grid
---------------------------------------------------------------------
local mains, availableMains = {}, {}
local function CreatePlayerGrid(name)
    -- local g = CreateFrame("Frame", nil, rosterEditorFrame.scrollFrame.content)
    local g = CreateFrame("Button", nil, rosterEditorFrame.scrollFrame.content, "BackdropTemplate")
    GRA.StylizeFrame(g)
    g:SetSize(rosterEditorFrame:GetWidth()-15, 20)
    g:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local s = g:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    g.s = s
    if GRA_Roster[name]["altOf"] then
        s:SetText(GRA.GetClassColoredName(name) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
    else
        s:SetText(GRA.GetClassColoredName(name))
    end
    s:SetWordWrap(false)
    s:SetJustifyH("LEFT")
    s:SetPoint("LEFT", 5, 0)
    s:SetPoint("RIGHT", -25, 0)

    local b = GRA.CreateButton(g, "×", nil, {20, 20}, "GRA_FONT_BUTTON")
    g.b = b
    b:SetPoint("RIGHT")
    b:SetScript("OnClick", function()
        if not deleted[name] then
            deleted[name] = g
            g:SetAlpha(.35)
            g:Highlight()
        else
            deleted[name] = nil
            g:SetAlpha(1)
            g:Unhighlight()
        end
    end)

    g.roles = {}
    local roles = CLASS_ROLES[GRA_Roster[name]["class"]]
    for i = #roles, 1, -1 do
        g.roles[roles[i]] = GRA.CreateButton(g, "", "none", {16, 16})
        g.roles[roles[i]]:SetAlpha(.2)
        g.roles[roles[i]]:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\Roles\]] .. roles[i])
        g.roles[roles[i]]:SetScript("OnClick", function()
            for roleName, roleBtn in pairs(g.roles) do
                if roleName ~= roles[i] then
                    roleBtn:SetAlpha(.2)
                else
                    roleBtn:SetAlpha(1)
                    if GRA_Roster[name]["role"] == roleName then
                        roleChanged[name] = nil
                        g:Unhighlight()
                    else
                        roleChanged[name] = {roleName, g.roles}
                        g:Highlight()
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
    if not GRA_Roster[name]["role"] then
        GRA_Roster[name]["role"] = "DPS"
        g.roles["DPS"]:SetAlpha(1)
    else
        g.roles[GRA_Roster[name]["role"]]:SetAlpha(1)
    end

    g:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() then
                local items = {}
                for _, class in ipairs(gra.CLASS_ORDER) do
                    -- highlight
                    local highlight = false
                    if classChanged[name] then
                        if class == classChanged[name][1] then
                            highlight = true
                        end
                    elseif class == GRA_Roster[name]["class"] then
                        highlight = true
                    end

                    table.insert(items, {
                        ["text"] = GRA.GetClassColoredName(GRA.GetLocalizedClassName(class), class),
                        ["onClick"] = function()
                            if class ~= GRA_Roster[name]["class"] then
                                classChanged[name] = {class, s}
                                if string.find(s:GetText(), " %(" .. L["alt"] .. "%)") then
                                    s:SetText(GRA.GetClassColoredName(name, class) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
                                else
                                    s:SetText(GRA.GetClassColoredName(name, class))
                                end
                                g:Highlight()
                            else
                                classChanged[name] = nil
                                s:SetText(GRA.GetClassColoredName(name))
                                g:Unhighlight()
                            end
                        end,
                        ["highlight"] = highlight,
                    })
                end
                GRA.ShowContextMenu(rosterEditorFrame, 100, L["Set class"], 12, items)
            else
                wipe(availableMains)
                -- clear button
                table.insert(availableMains, {
                    ["text"] = gra.colors.firebrick.s .. L["Clear"],
                    ["onClick"] = function()
                        if GRA.IsAlt(name) then
                            mainChanged[name] = {nil, s}
                            -- unmark
                            g:Highlight()
                        else
                            g:Unhighlight()
                        end
                        s:SetText(string.gsub(s:GetText(), " %(" .. L["alt"] .. "%)", ""))
                    end
                })
                -- main list
                for _, item in pairs(mains) do
                    if item.name ~= name then
                        item.onClick = function(text)
                            if GRA.IsAlt(name) ~= item.name then
                                mainChanged[name] = {item.name, s}
                                g:Highlight()
                            else
                                mainChanged[name] = nil
                                g:Unhighlight()
                            end
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
                        elseif item.name == GRA_Roster[name]["altOf"] then
                            item.highlight = true
                        end
                        table.insert(availableMains, item)
                    end
                end
                GRA.ShowContextMenu(rosterEditorFrame, 100, L["Alt of"], 10, availableMains)
            end
        end
    end)

    g:SetScript("OnDoubleClick", function(self, button)
        if button ~= "LeftButton" then return end
        if g:GetAlpha() ~= 1 then return end
        local p = GRA.CreatePopupEditBox(g, g:GetWidth(), g:GetHeight(), function(text)
            -- print(GRA_Roster[name]["class"])
            -- remove white space
            text =  string.gsub(text, " ", "")
            -- if name changed
            if text ~= name then
                -- new fullname, FSObject
                renamed[name] = {text, s}
                g:Highlight()
            else
                -- exists, change back
                if renamed[name] then
                    renamed[name] = nil
                    g:Unhighlight()
                end
            end

            if GRA_Roster[name]["altOf"] or mainChanged[name] then -- 已有或即将有
                s:SetText(GRA.GetClassColoredName(text, GRA_Roster[name]["class"]) .. gra.colors.grey.s .. " (" .. L["alt"] .. ")")
            else
                s:SetText(GRA.GetClassColoredName(text, GRA_Roster[name]["class"]))
            end
        end)
        p:SetText(name)
        p:SetPoint("LEFT")
        p.editBox:SetCursorPosition(0)
    end)

    function g:Highlight()
        b:SetBackdropBorderColor(1, 0, 0, 1)
        g:SetBackdropBorderColor(1, 0, 0, 1)
    end

    function g:Unhighlight(force)
        if force or not(deleted[name] or renamed[name] or roleChanged[name] or mainChanged[name] or classChanged[name]) then
            b:SetBackdropBorderColor(0, 0, 0, 1)
            g:SetBackdropBorderColor(0, 0, 0, 1)
        end
    end

    return g
end

LoadRoster = function()
    scroll:Reset()
    wipe(mains)

    -- sort
    local sorted = {}
    for name, t in pairs(GRA_Roster) do
        table.insert(sorted, {name, t["class"]})
    end

    table.sort(sorted, function(a, b)
		if a[2] ~= b[2] then
			return GRA.GetIndex(gra.CLASS_ORDER, a[2]) < GRA.GetIndex(gra.CLASS_ORDER, b[2])
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
            ["text"] = GRA.GetClassColoredName(t[1]),
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
    wipe(classChanged)
    LoadRoster()
end)