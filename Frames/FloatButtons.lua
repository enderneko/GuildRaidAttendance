local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local floatButtonsAnchor = CreateFrame("Frame", "GRA_FloatButtonsAnchor")
gra.floatButtonsAnchor = floatButtonsAnchor
GRA:StylizeFrame(floatButtonsAnchor, {.1, .1, .1, .5}, {0, 0, 0, .5})
floatButtonsAnchor:SetSize(335, 40)
floatButtonsAnchor:Hide()
floatButtonsAnchor:SetPoint("BOTTOMLEFT", 20, 200)
floatButtonsAnchor:EnableMouse(true)
floatButtonsAnchor:SetMovable(true)
floatButtonsAnchor:SetUserPlaced(true)
floatButtonsAnchor:SetClampedToScreen(true)
floatButtonsAnchor:RegisterForDrag("LeftButton")
LPP:PixelPerfectScale(floatButtonsAnchor)
floatButtonsAnchor:SetScript("OnDragStart", function() floatButtonsAnchor:StartMoving() end)
floatButtonsAnchor:SetScript("OnDragStop", function() floatButtonsAnchor:StopMovingOrSizing() end)
floatButtonsAnchor:RegisterEvent("VARIABLES_LOADED")

floatButtonsAnchor.text = floatButtonsAnchor:CreateFontString(nil, "OVERLAY", "GRA_FONT_TITLE")
floatButtonsAnchor.text:SetPoint("TOPLEFT")
floatButtonsAnchor.text:SetText("GRA Float Buttons Anchor")

function GRA:ShowHideFloatButtonsAnchor()
    if floatButtonsAnchor:IsShown() then
		floatButtonsAnchor:Hide()
		LPP:PixelPerfectPoint(floatButtonsAnchor)
	else
		floatButtonsAnchor:Show()
	end
end

local buttons = {}
local function ShowButtons()
    local last
    -- for _, b in pairs(buttons) do
    --     b:ClearAllPoints()
    --     if last then
    --         b:SetPoint("LEFT", last, "RIGHT", 5, 0)
    --     else
    --         b:SetPoint("BOTTOMLEFT", floatButtonsAnchor)
    --     end
    --     last = b
    -- end
    for i = 1, (#buttons > 10) and 10 or #buttons do
        buttons[i]:ClearAllPoints()
        if last then
            buttons[i]:SetPoint("LEFT", last, "RIGHT", 5, 0)
        else
            buttons[i]:SetPoint("BOTTOMLEFT", floatButtonsAnchor)
        end
        last = buttons[i]
    end
end

local raidDate
local function CreateItemButton(itemLink, looter)
    if not string.find(looter, "-") then looter = looter .. "-" .. GetRealmName() end

    local b = GRA:CreateIconButton(nil, 29, 29)
    b:SetScale(GRA:GetScale())
    table.insert(buttons, b)
    b.index = #buttons
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    if string.find(itemLink, "|Hitem") then
        local icon = GetItemIcon(itemLink)
        b:SetIcon(icon)

        b:SetScript("OnEnter", function(self)
            GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
            GRA_Tooltip:SetHyperlink(itemLink)
            GRA_Tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
        end)
        b:SetScript("OnLeave", function() GRA_Tooltip:Hide() end)

        b:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
                    GRA:ShowGPCreditFrame(raidDate, itemLink, nil, looter, _G[GRA_R_RaidLogs][raidDate]["attendees"], nil, b)
                else
                    GRA:ShowRecordLootFrame(raidDate, itemLink, nil, looter, _G[GRA_R_RaidLogs][raidDate]["attendees"], nil, b)
                end
            elseif button == "RightButton" then
                b:Hide()
            end
        end)

        b:SetScript("OnHide", function()
            -- hide & remove button
            b:ClearAllPoints()
            table.remove(buttons, b.index)
            for i = b.index, #buttons do
                buttons[i].index = buttons[i].index - 1
            end
            ShowButtons()
        end)
    end
    ShowButtons()
end

local function CreateBossButton(bossName)
    local b = GRA:CreateButton(nil, "BOSS\nKILL", "green", {29, 29}, "GRA_FONT_PIXEL", false, bossName)
    b:SetScale(GRA:GetScale())
    table.insert(buttons, b)
    b.index = #buttons
    b:GetFontString():SetWordWrap(true)
    b:GetFontString():SetSpacing(3)
    b:GetFontString():ClearAllPoints()
    b:GetFontString():SetPoint("CENTER",1,0)
    b:SetPushedTextOffset(0, 0)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    b:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            GRA:ShowEPAwardFrame(raidDate, bossName, "", nil, _G[GRA_R_RaidLogs][raidDate]["attendees"], _G[GRA_R_RaidLogs][raidDate]["absentees"], nil, b)
        elseif button == "RightButton" then
            b:Hide()
        end
    end)

    b:SetScript("OnHide", function()
        -- hide & remove button
        b:ClearAllPoints()
        table.remove(buttons, b.index)
        for i = b.index, #buttons do
            buttons[i].index = buttons[i].index - 1
        end
        ShowButtons()
    end)

    ShowButtons()
end

-----------------------------------------
-- events
-----------------------------------------
local awardedItemLink, awardedSlot, awardedTo
hooksecurefunc("GiveMasterLoot", function(slot, index)
    awardedSlot = slot
    awardedItemLink = GetLootSlotLink(slot)
    awardedTo = GetMasterLootCandidate(slot, index)
    -- print("slot: " .. slot .. "(" .. awardedItemLink .. "), index: " .. index .. "(" .. awardedTo .. ")")
end)

floatButtonsAnchor:SetScript("OnEvent", function(self, event, ...)
    if event == "VARIABLES_LOADED" then
        LPP:PixelPerfectPoint(floatButtonsAnchor)
    end

    if not gra.isLootMaster then return end

    if event == "CHAT_MSG_LOOT" then
        -- local msg, _, _, _, looter = ...
        -- if looter and looter ~= "" then
        --     local itemLink = msg:match("|c.+|Hitem:.+|h")
        --     -- if GetItemInfo(itemLink)
        --     CreateItemButton(itemLink, looter)
        -- end
    
    elseif event == "LOOT_SLOT_CLEARED" then
        local slot = ...
        if slot == awardedSlot then
            CreateItemButton(awardedItemLink, awardedTo)
            awardedItemLink, awardedSlot, awardedTo = nil, nil, nil
        end

    elseif event == "BOSS_KILL" then
        local encounterID, encounterName = ...
        CreateBossButton(encounterName)
    end
end)

GRA:RegisterEvent("GRA_TRACK", "FloatButtons_TrackStatus", function(d)
    if d then
        -- floatButtonsAnchor:RegisterEvent("CHAT_MSG_LOOT")
        if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
            floatButtonsAnchor:RegisterEvent("BOSS_KILL")
        end
        floatButtonsAnchor:RegisterEvent("LOOT_SLOT_CLEARED")
        -- floatButtonsAnchor:RegisterEvent("ENCOUNTER_END")
        raidDate = d
    else
        floatButtonsAnchor:UnregisterEvent("BOSS_KILL")
        floatButtonsAnchor:UnregisterEvent("LOOT_SLOT_CLEARED")
    end
end)

-----------------------------------------
-- test
-----------------------------------------
--@debug@
SLASH_FLOATBTNTEST1 = "/fbtest"
function SlashCmdList.FLOATBTNTEST(msg, editbox)
    for i = 1, 3 do
        CreateItemButton(GetInventoryItemLink("player", i), UnitName("player"))
        CreateItemButton(GetInventoryItemLink("player", i+1), UnitName("player"))
        CreateItemButton(GetInventoryItemLink("player", i+2), UnitName("player"))
        CreateBossButton(i)
        CreateBossButton(i)
    end
end
--@end-debug@