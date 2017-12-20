local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")
local Serializer = LibStub:GetLibrary("AceSerializer-3.0")
local Comm = LibStub:GetLibrary("AceComm-3.0")
-- _G.ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS

local lootFrame = CreateFrame("Frame", "GRA_LootFrame")
gra.lootFrame = lootFrame
LPP:PixelPerfectScale(lootFrame)
lootFrame:Hide()
lootFrame:SetSize(280, 17)
lootFrame:SetPoint("RIGHT", 0, 100)
lootFrame:SetFrameStrata("DIALOG")
lootFrame:SetToplevel(true)
lootFrame:EnableMouse(true)
lootFrame:SetMovable(true)
lootFrame:SetClampedToScreen(true)
lootFrame:SetUserPlaced(true)
lootFrame:RegisterForDrag("LeftButton")
lootFrame:SetScript("OnDragStart", function() lootFrame:StartMoving() end)
lootFrame:SetScript("OnDragStop", function() lootFrame:StopMovingOrSizing() end)
GRA:StylizeFrame(lootFrame, {.1, .1, .1, 1})

local title = lootFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TITLE")
title:SetText("GRA Loot Frame")
title:SetPoint("CENTER")

-- local classID, specID
local indices, frames, frameWidth = {}, {}
local itemsNotFound = {}
--------------------------------------------------------
-- show loot frames
--------------------------------------------------------
local function ShowFrames()
    if #indices > 0 then
        lootFrame:Show()
        lootFrame:SetWidth(frameWidth)
    else
        lootFrame:Hide()
        return
    end

    local last = lootFrame
    for _, itemSig in pairs(indices) do
        frames[itemSig]:ClearAllPoints()
        frames[itemSig]:SetPoint("TOP", last, "BOTTOM", 0, 1)
        frames[itemSig]:SetPoint("LEFT")
        frames[itemSig]:SetPoint("RIGHT")
        frames[itemSig]:Show()
        last = frames[itemSig]
    end
end

--------------------------------------------------------
-- SendReply
--------------------------------------------------------
-- {classID, specID, itemSig, responseIndex, g1, g2, note}
local function SendReply(replyTable, hide)
    -- still need to send class & spec info again, 除了loot master以外的其他成员可能并没有收到
    table.insert(replyTable, 1, select(3, UnitClass("player")))
    table.insert(replyTable, 2, GetSpecialization())
    Comm:SendCommMessage("GRA_LOOT_R", Serializer:Serialize(replyTable), "RAID", nil, "ALERT")
    
    if hide then
        frames[replyTable[3]]:ClearAllPoints()
        frames[replyTable[3]]:Hide()
        frames = GRA:RemoveElementsByKeys(frames, {replyTable[3]})
        table.remove(indices, GRA:GetIndex(indices, replyTable[3]))
        ShowFrames()
    end

    wipe(replyTable)
end

--------------------------------------------------------
-- buttons on each loot frame
--------------------------------------------------------
local function CreateButtons(frame, itemSig, itemEquipLoc, itemLink)
    local buttons = {}
    local qns = {}
    local g1, g2, note = nil, nil, nil
    local eb = GRA:CreateEditBox(frame, 20, 20)
    local okBtn = GRA:CreateButton(eb, L["OK"], "blue", {30, 20})
    local qnFrame = CreateFrame("Frame", nil, frame)

    if itemEquipLoc == "" and GRA:IsRelic(itemLink) then
        -- is relic
        local relicType = GRA:GetRelicType(itemLink)
        g1, g2 = GRA:GetEquipedRelicLink(relicType)
    else
        -- get current gear
        local slotID1, slotID2 = GRA:GetSlotID(itemEquipLoc)
        if slotID1 then g1 = GetInventoryItemLink("player", slotID1) end
        if slotID2 then g2 = GetInventoryItemLink("player", slotID2) end
    end

    -- reply buttons
    for k, reply in pairs(_G[GRA_R_Config]["replies"]) do
        local b = GRA:CreateButton(frame, reply, nil, {20, 20})
        table.insert(buttons, b)
        b:SetScript("OnClick", function()
            SendReply({itemSig, k, g1, g2, note}, true)
        end)
    end
    
    -- note
    local noteBtn = GRA:CreateButton(frame, L["Note"], "blue", {20, 20})
    table.insert(buttons, noteBtn)
    noteBtn:SetScript("OnClick", function()
        eb:Show()
        eb:SetFocus()
        qnFrame:Show()
    end)
    
    -- pass
    local passBtn = GRA:CreateButton(frame, L["Pass"], "red", {20, 20})
    table.insert(buttons, passBtn)
    passBtn:SetScript("OnClick", function()
        SendReply({itemSig, 8}, true)
    end)
    
    -- note editbox
    eb:Hide()
    eb:SetFrameLevel(5)
    GRA:StylizeFrame(eb, {.1, .1, .1, 1})
    eb:SetPoint("LEFT", buttons[1])
    eb:SetPoint("RIGHT", passBtn)
    eb:SetTextInsets(5, 25, 0, 0)
    eb:SetScript("OnEscapePressed", function()
        eb:SetText("")
        eb:Hide()
        qnFrame:Hide()
    end)
    eb:SetScript("OnEnterPressed", function()
        if strtrim(eb:GetText()) ~= "" then
            note = strtrim(eb:GetText())
        else
            note = nil
        end
        eb:Hide()
        qnFrame:Hide()
    end)

    okBtn:SetPoint("RIGHT")
    okBtn:SetScript("OnClick", function()
        if strtrim(eb:GetText()) ~= "" then
            note = strtrim(eb:GetText())
        else
            note = nil
        end
        eb:Hide()
        qnFrame:Hide()
    end)
    
    -- quick notes
    qnFrame:SetPoint("BOTTOMLEFT", eb, "TOPLEFT", 0, 1)
    qnFrame:SetPoint("TOPRIGHT", eb, 0, 20)
    qnFrame:Hide()
    for i = 1, #_G[GRA_R_Config]["notes"] do
        qns[i] = GRA:CreateButton(qnFrame, " ", "blue-hover", {35, 20})
        qns[i]:SetText(_G[GRA_R_Config]["notes"][i])
        qns[i]:SetScript("OnClick", function()
            note = _G[GRA_R_Config]["notes"][i]
            eb:SetText(note)
            C_Timer.NewTimer(.2, function()
                eb:Hide()
                qnFrame:Hide()
            end)
        end)

        if i == 1 then
            qns[i]:SetPoint("BOTTOMRIGHT")
        else
            qns[i]:SetPoint("RIGHT", qns[i - 1], "LEFT", 1, 0)
        end
    end
    
    -- set point
    local last
    frameWidth = 55
    for _, b in pairs(buttons) do
        local newWidth = (b:GetTextWidth() > 30) and (b:GetTextWidth() + 10) or 40
        frameWidth = frameWidth + newWidth
        b:SetWidth(newWidth)
        b:GetFontString():SetWidth(b:GetWidth())
        if last then
            b:SetPoint("LEFT", last, "RIGHT", -1, 0)
        else
            b:SetPoint("BOTTOMLEFT", 50, 5)
        end
        last = b
    end
    frameWidth = frameWidth - (#buttons - 1)
end

--------------------------------------------------------
-- create loot frame
--------------------------------------------------------
local function CreateItemFrame(itemSig, itemLink, count)
    local itemName, _, itemRarity, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, iconFileDataID = GetItemInfo(itemLink)
    local tokenID, tierVersion = GRA:IsTier(itemSig)
    if tokenID then
        itemEquipLoc, itemLevel = GRA:GetTierInfo(tokenID, tierVersion)
    end

    local f = CreateFrame("Frame", nil, lootFrame)
    frames[itemSig] = f

    f:Hide()
    -- f:SetSize(lootFrame:GetWidth(), 51)
    f:SetHeight(51)
    f:EnableMouse(true)
    GRA:StylizeFrame(f, {.17, .17, .17, .9})
    -- GRA:StylizeFrame(f, nil, nil, {11, -10, -11, 11})

    local icon = GRA:CreateIconButton(f, 41, 41, iconFileDataID)
    icon:SetPoint("TOPLEFT", 5, -5)
    
    GRA:CreateIconOverlay(icon, itemLink, itemSig)

    icon:SetScript("OnEnter", function(self)
        if IsAddOnLoaded("RelicInspector") and GRA:IsRelic(itemLink) then
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:SetPoint("RIGHT", self, "LEFT", -6, 0)
        else
            GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
            GRA_Tooltip:SetHyperlink(itemLink)
            GRA_Tooltip:SetPoint("RIGHT", self, "LEFT", -6, 0)
            GameTooltip_ShowCompareItem(GRA_Tooltip, GRA_Tooltip)
        end
    end)
    icon:SetScript("OnLeave", function()
        GRA_Tooltip:Hide()
        GameTooltip:Hide()
    end)

    local nameText = f:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT2")
    nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, -2)
    if count > 1 then
        nameText:SetText(itemLink .. gra.colors.yellow.s .. " × " .. count)
    else
        nameText:SetText(itemLink)
    end
    
    CreateButtons(f, itemSig, itemEquipLoc, itemLink)

    ShowFrames()
end

--------------------------------------------------------
-- reply considering (addon check), create loot frame
--------------------------------------------------------
Comm:RegisterComm("GRA_LOOT_S", function(prefix, message, channel, sender)
    local success, t = Serializer:Deserialize(message)
    if success then
        -- {itemLink, count}
        if GetItemInfo(t[1]) then
            local itemSig = strjoin(":", GRA:GetItemSignatures(t[1]))
            SendReply({itemSig, 9}) -- considering

            -- item exists. 物品分配者重载了界面，再次发送此装备，不再创建
            if frames[itemSig] then return end

            table.insert(indices, itemSig)
            CreateItemFrame(itemSig, t[1], t[2])
            
            -- distribution frame
            if not gra.isLootMaster then
                GRA:DistributionFrame_AddItem(itemSig, t[1], t[2])
            end
        else
            table.insert(itemsNotFound, {GRA:GetItemID(t[1]), t[1], t[2]})
        end
    end
end)

Comm:RegisterComm("GRA_LOOT_E", function(prefix, message, channel, sender)
    if not gra.isLootMaster then
        GRA:DistributionFrame_RemoveItem(message)
    end
    
    if not frames[message] then return end
    frames[message]:Hide()
    frames = GRA:RemoveElementsByKeys(frames, {message})
    table.remove(indices, GRA:GetIndex(indices, message))
    ShowFrames()
end)

--------------------------------------------------------
-- GET_ITEM_INFO_RECEIVED
--------------------------------------------------------
lootFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
lootFrame:SetScript("OnEvent", function(self, event, arg1)
    for i = #itemsNotFound, 1, -1 do
        if tonumber(arg1) == itemsNotFound[i][1] then
            local itemSig = strjoin(":", GRA:GetItemSignatures(itemsNotFound[i][2]))
            SendReply({itemSig, 9}) -- considering

            -- item exists. 物品分配者重载了界面，再次发送此装备，不再创建
            if frames[itemSig] then return end

            table.insert(indices, itemSig)
            CreateItemFrame(itemSig, itemsNotFound[i][2], itemsNotFound[i][3])
            -- distribution frame
            if not gra.isLootMaster then
                GRA:DistributionFrame_AddItem(itemSig, itemsNotFound[i][2], itemsNotFound[i][3])
            end
            
            table.remove(itemsNotFound, i)
        end
    end
end)

--------------------------------------------------------
-- prepare replies
--------------------------------------------------------
Comm:RegisterComm("GRA_LOOT", function(prefix, message, channel, sender)
    -- classID = select(3, UnitClass("player"))
    -- specID = GetSpecialization()

    if sender == UnitName("player") then return end
    
    local success, t = Serializer:Deserialize(message)
    if success then
        _G[GRA_R_Config]["replies"] = t
    end
end)