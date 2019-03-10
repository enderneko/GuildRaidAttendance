local addonName, E =  ...
local GRA, gra = unpack(E)
local L = E.L
local LPP = LibStub:GetLibrary("LibPixelPerfect")
local Serializer = LibStub:GetLibrary("AceSerializer-3.0")
local Comm = LibStub:GetLibrary("AceComm-3.0")
local I = LibStub("LibItemUpgradeInfo-1.0")

-- 262, 15 rows
local distributionFrame = GRA:CreateMovableFrame("GRA Distribution Frame", "GRA_DistributionFrame", 478, 357, "GRA_FONT_TITLE", "DIALOG")
gra.distributionFrame = distributionFrame

--------------------------------------------------------
-- var
--------------------------------------------------------
gra.isLootMaster = false
local indices = {} -- 防止buttons顺序错乱，出现于end session时。 同步distribution与loot的顺序。
local currentIndex = 1
-- loots通过 LOOT_OPENED 获取的所有符合条件的掉落
local loots = {}
-- lootsToSend 要发送的物品table， lootsToSend[itemSig] = {itemLink, count}
local lootsToSend = {}
-- GET_ITEM_INFO_RECEIVED
local itemsNotFound, playerItemsNotFound = {}, {}
local buttons, frames = {}, {}
local replyColors = { "|cffFF3333", "|cffFF9933", "|cffFFFF33", "|cff99FF33", "|cff33FF33", "|cff33FF99", "|cff33FFFF"}

--------------------------------------------------------
-- set button point and show frame
--------------------------------------------------------
local function ShowButtons()
    local last
    local maxIndex = (#indices > 10) and 10 or #indices

    for i = 1, maxIndex do
        buttons[indices[i]]:ClearAllPoints()
        if last then
            buttons[indices[i]]:SetPoint("TOP", last, "BOTTOM", 0, 1)
        else
            buttons[indices[i]]:SetPoint("TOPRIGHT", distributionFrame, "TOPLEFT", 1, 0)
        end
        last = buttons[indices[i]]
    end
end

local function ShowFrame(itemSig)
    currentIndex = GRA:GetIndex(indices, itemSig)
    if currentIndex == nil then -- all sessions ended
        distributionFrame:Hide()
        return
    end

    for sig, b in pairs(buttons) do
        if sig == itemSig then
            b.tex:SetAlpha(1)
            b.ilvlTex:SetAlpha(1)
            b.ilvlText:SetAlpha(1)
            frames[sig]:Show()
        else
            b.tex:SetAlpha(.4)
            b.ilvlTex:SetAlpha(.4)
            b.ilvlText:SetAlpha(.4)
            frames[sig]:Hide()
        end
    end
end

--------------------------------------------------------
-- create player row for each frame
--------------------------------------------------------
local function CreateRow(playerName, playerClassID, playerSpecID, itemSig)
    local row = CreateFrame("Button", nil, frames[itemSig].scrollFrame.content)
    frames[itemSig].scrollFrame:SetWidgetAutoWidth(row)
    frames[itemSig]["rows"][playerName] = row
    row:SetFrameLevel(5)
    row:SetSize(frames[itemSig].scrollFrame.content:GetWidth(), 20)
    row:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	row:SetBackdropColor(.5, .5, .5, .1) 
    row:SetBackdropBorderColor(0, 0, 0, 1)
    
    row.spec = GRA:CreateIconButton(row, 16, 16, "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
    row.spec:SetPoint("LEFT", 8, 0)
    row.spec:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .3) end)
    row.spec:SetScript("OnLeave", function() row:SetBackdropColor(.5, .5, .5, .1) end)
    
    local class = select(2, GetClassInfo(playerClassID))
    if playerClassID and playerSpecID then
        -- specID, name, description, iconID, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, specNum)
        local _, name, _, icon = GetSpecializationInfoForClassID(playerClassID, playerSpecID)
        row.spec:SetIcon(icon)
        -- tooltip
        row.spec:HookScript("OnEnter", function()
            GRA_Tooltip:SetOwner(row.spec, "ANCHOR_NONE")
            GRA_Tooltip:AddLine("|c" .. RAID_CLASS_COLORS[class].colorStr .. name)
            GRA_Tooltip:SetPoint("RIGHT", row.spec, "LEFT", -1, 0)
            GRA_Tooltip:Show()
        end)
        row.spec:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)
    end

    row.name = row:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    if class then
        row.name:SetText(GRA:GetClassColoredName(playerName, class))
    else
        row.name:SetText(gra.colors.grey.s .. playerName)
    end
    row.name:SetWidth(80)
    row.name:SetWordWrap(false)
    row.name:SetPoint("LEFT", row.spec, "RIGHT", 2, 0)
    
    row.response = row:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    row.response:SetWidth(100)
    row.response:SetWordWrap(false)
    row.response:SetPoint("LEFT", row.name, "RIGHT", 5, 0)

    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        row.pr = row:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
        row.prValue = GRA:GetPR(playerName) -- sort key
        if row.prValue == 0 then
            row.pr:SetText(gra.colors.grey.s .. row.prValue)
        else
            row.pr:SetText(row.prValue)
        end
        row.pr:SetWidth(45)
        row.pr:SetWordWrap(false)
        row.pr:SetPoint("LEFT", row.response, "RIGHT", 5, 0)
    elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
        row.dkp = row:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
        row.dkpValue = GRA:GetDKP(playerName) -- sort key
        if row.dkpValue == 0 then
            row.dkp:SetText(gra.colors.grey.s .. row.dkpValue)
        else
            row.dkp:SetText(row.dkpValue)
        end
        row.dkp:SetWidth(45)
        row.dkp:SetWordWrap(false)
        row.dkp:SetPoint("LEFT", row.response, "RIGHT", 5, 0)
    end
    
    row.g1 = GRA:CreateIconButton(row, 16, 16)
    row.g1:Hide()
    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        row.g1:SetPoint("LEFT", row.pr, "RIGHT", 5, 0)
    elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
        row.g1:SetPoint("LEFT", row.dkp, "RIGHT", 5, 0)
    else
        row.g1:SetPoint("LEFT", row.response, "RIGHT", 5, 0)
    end
    row.g1:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .3) end)
    row.g1:SetScript("OnLeave", function() row:SetBackdropColor(.5, .5, .5, .1) end)
    
    function row.g1:SetItem(link)
        -- local _, _, _, _, _, _, _, _, _, iconFileDataID = GetItemInfo(link)
        local iconFileDataID = GetItemIcon(link)
        -- player's gear may be upgraded, should use LibItemUpgradeInfo-1.0
        local iLevel = I:GetUpgradedItemLevel(link)
        row.g1:SetIcon(iconFileDataID)

        local diff = frames[itemSig].iLevel - iLevel
        if diff > 0 then
            diff = "|cFF00FF00+" .. diff
        elseif diff < 0 then
            diff = "|cFFFF0000" .. diff
        else
            diff = gra.colors.grey.s .. "+0"
        end
        row.g1:SetNormalFontObject("GRA_FONT_SMALL")
        row.g1:SetText(iLevel .. diff)
        row.g1:GetFontString():ClearAllPoints()
        row.g1:GetFontString():SetPoint("LEFT", row.g1, "RIGHT", 5, 0)

        row.g1:HookScript("OnEnter", function()
            GRA_Tooltip:SetOwner(row.g1, "ANCHOR_NONE")
            GRA_Tooltip:SetHyperlink(link)
            GRA_Tooltip:SetPoint("TOPLEFT", row.g1, "BOTTOMLEFT", 0, -1)
        end)
        row.g1:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)
        row.g1:Show()
    end
    
    row.g2 = GRA:CreateIconButton(row, 16, 16)
    row.g2:Hide()
    row.g2:SetPoint("LEFT", row.g1, "RIGHT", 52, 0)
    row.g2:SetScript("OnEnter", function() row:SetBackdropColor(.5, .5, .5, .3) end)
    row.g2:SetScript("OnLeave", function() row:SetBackdropColor(.5, .5, .5, .1) end)

    function row.g2:SetItem(link)
        -- local _, _, _, iLevel, _, _, _, _, _, iconFileDataID = GetItemInfo(link)
        local iconFileDataID = GetItemIcon(link)
        -- player's gear may be upgraded, should use LibItemUpgradeInfo-1.0
        local iLevel = I:GetUpgradedItemLevel(link)
        row.g2:SetIcon(iconFileDataID)

        local diff = frames[itemSig].iLevel - iLevel
        if diff > 0 then
            diff = "|cFF00FF00+" .. diff
        elseif diff < 0 then
            diff = "|cFFFF0000" .. diff
        else
            diff = gra.colors.grey.s .. "+0"
        end
        row.g2:SetNormalFontObject("GRA_FONT_SMALL")
        row.g2:SetText(iLevel .. diff)
        row.g2:GetFontString():ClearAllPoints()
        row.g2:GetFontString():SetPoint("LEFT", row.g2, "RIGHT", 5, 0)

        row.g2:HookScript("OnEnter", function()
            GRA_Tooltip:SetOwner(row.g2, "ANCHOR_NONE")
            GRA_Tooltip:SetHyperlink(link)
            GRA_Tooltip:SetPoint("TOPLEFT", row.g2, "BOTTOMLEFT", 0, -1)
        end)
        row.g2:HookScript("OnLeave", function() GRA_Tooltip:Hide() end)
        row.g2:Show()
    end

    -- row.note = row:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    row.note = CreateFrame("Frame", nil, row)
    row.note:SetHeight(20)
    row.note:SetPoint("LEFT", row.g2, "RIGHT", 55, 0)
    row.note:SetPoint("RIGHT", -8, 0)
    row.note.text = row.note:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    row.note.text:SetWordWrap(false)
    row.note.text:SetAllPoints(row.note)
    row.note:SetScript("OnEnter", function()
        row:SetBackdropColor(.5, .5, .5, .3)
        if row.note.text:IsTruncated() then
            GRA_Tooltip:SetOwner(row.g2, "ANCHOR_NONE")
            GRA_Tooltip:AddLine(L["Note"])
            GRA_Tooltip:AddLine(row.note.text:GetText(), 1, 1, 1, true)
            GRA_Tooltip:SetPoint("LEFT", row.note, "RIGHT")
            GRA_Tooltip:Show()
        end
    end)
    row.note:SetScript("OnLeave", function()
        row:SetBackdropColor(.5, .5, .5, .1)
        GRA_Tooltip:Hide()
    end)
    
    row:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, .5, .5, .3) end)
	row:SetScript("OnLeave", function(self) self:SetBackdropColor(.5, .5, .5, .1) end)
	
	return row
end

--------------------------------------------------------
-- sort by reply
--------------------------------------------------------
local function Sort(itemSig)
    local sorted = {}
    
    for name, row in pairs(frames[itemSig]["rows"]) do
        table.insert(sorted, row)
    end

    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        table.sort(sorted, function(a, b)
            if a.responseIndex ~= b.responseIndex then
                return a.responseIndex < b.responseIndex
            else
                return a.prValue > b.prValue
            end
        end)
    elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
        table.sort(sorted, function(a, b)
            if a.responseIndex ~= b.responseIndex then
                return a.responseIndex < b.responseIndex
            else
                return a.dkpValue > b.dkpValue
            end
        end)
    else
        table.sort(sorted, function(a, b)
            return a.responseIndex < b.responseIndex
        end)
    end

    local last = nil
    for _, row in pairs(sorted) do
        row:ClearAllPoints()
        if last then
            row:SetPoint("TOP", last, "BOTTOM", 0, 1)
        else
            row:SetPoint("TOP")
        end
        last = row
    end
    frames[itemSig].scrollFrame:ResetScroll()
    frames[itemSig].scrollFrame:ResetHeight()
end

--------------------------------------------------------
-- update row info
--------------------------------------------------------
local function SetMemberResponse(playerName, playerClassID, playerSpecID, itemSig, responseIndex, g1, g2, note)
    if not frames[itemSig] then return end -- session already ended
    if not string.find(playerName, "-") then playerName = playerName .. "-" .. GRA:GetRealmName() end
    local row = frames[itemSig]["rows"][playerName] or CreateRow(playerName, playerClassID, playerSpecID, itemSig)
    
    row.responseIndex = responseIndex -- response index
    if responseIndex == 9 then -- considering
        row.response:SetText(gra.colors.grey.s .. L["Considering..."])
    elseif responseIndex == 8 then -- pass
        frames[itemSig]["rows"] = GRA:RemoveElementsByKeys(frames[itemSig]["rows"], {playerName})
        row:SetParent(nil)
        row:ClearAllPoints()
        row:Hide()
    else
        row.response:SetText((replyColors[responseIndex] or gra.colors.grey.s) .. (_G[GRA_R_Config]["replies"][responseIndex] or "Unkonw Reply"))
        -- if g1 and string.find(g1, "|Hitem") then row.g1:SetItem(g1) end
        -- if g2 and string.find(g2, "|Hitem") then row.g2:SetItem(g2) end
        if g1 then
            if GetItemInfo(g1) then
                row.g1:SetItem(g1)
            else
                table.insert(playerItemsNotFound, {GRA:GetItemID(g1), row.g1, g1})
            end
        end
        if g2 then
            if GetItemInfo(g2) then
                row.g2:SetItem(g2)
            else
                table.insert(playerItemsNotFound, {GRA:GetItemID(g2), row.g2, g2})
            end
        end

        if note then row.note.text:SetText(note) end
    end
    Sort(itemSig)
end

--------------------------------------------------------
-- create item detail frame
--------------------------------------------------------
local function CreateItemFrame(itemSig, itemLink, count)
    -- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
    local _, _, itemRarity, iLevel, _, itemType, itemSubType, _, itemEquipLoc, iconFileDataID = GetItemInfo(itemLink)
    local tokenID, tierVersion = GRA:IsTier(itemSig)
    if tokenID then
        itemEquipLoc, iLevel = GRA:GetTierInfo(tokenID, tierVersion)
    else
        iLevel = I:GetUpgradedItemLevel(itemLink)
    end
    
    local f = CreateFrame("Frame", nil, distributionFrame)
    f:Hide()
    f:SetAllPoints(distributionFrame)
    -- save ilvl for row diff
    f.iLevel = iLevel
    
    -- icon, info, end session
    local titleFrame = CreateFrame("Frame", nil, f)
    titleFrame:SetPoint("TOPLEFT")
    titleFrame:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -51)
    GRA:StylizeFrame(titleFrame, {1, 1, 1, .1}, {0, 0, 0, 1})

    local icon = GRA:CreateIconButton(titleFrame, 35, 35, iconFileDataID)
    icon:SetPoint("TOPLEFT", 8, -8)
    
    -- GRA:CreateIconOverlay(icon, itemLink, itemSig)

    icon:SetScript("OnEnter", function(self)
        GRA_Tooltip:SetOwner(self, "ANCHOR_NONE")
        GRA_Tooltip:SetHyperlink(itemLink)
        GRA_Tooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -1)
    end)
    icon:SetScript("OnLeave", function() GRA_Tooltip:Hide() end)

    local nameText = titleFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT2")
    nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -4)
    if count > 1 then
        nameText:SetText(itemLink .. gra.colors.yellow.s .. " × " .. count)
    else
        nameText:SetText(itemLink)
    end

    -- info text
    local itemStatus = GRA:GetItemStatus(itemLink)
    if itemStatus ~= "" then itemStatus = " " .. itemStatus end -- add space
    local itemSocket = (select(2, string.split(":", itemSig)) ~= "0") and (" " .. gra.colors.skyblue.s .. L["Socket"]) or ""
    local bindType, localizedBindType = GRA:GetItemBindType(itemLink)
    if bindType == "BoE" or bindType == "BoU" then
        localizedBindType = " " .. gra.colors.firebrick.s .. localizedBindType
    else
		localizedBindType = ""
	end
    
    local infoText = titleFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    infoText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 4)
    infoText:SetText(L["iLevel: "] .. iLevel .. itemStatus .. itemSocket .. localizedBindType .. "    " .. gra.colors.grey.s .. (itemSubType or "") .. " " .. (_G[itemEquipLoc] or ""))
    
    -- end session button
    local closeBtn = GRA:CreateButton(titleFrame, gra.isLootMaster and L["End Session"] or L["Dismiss"], "red", {90, 20})
    closeBtn:SetPoint("RIGHT", -8, 0)
    closeBtn:SetScript("OnClick", function()
        if gra.isLootMaster then
            -- hide loot frame
            Comm:SendCommMessage("GRA_LOOT_E", itemSig, "RAID", nil, "ALERT")
        end
        
        local nextIndex
        if currentIndex == #indices then -- 删除最后一个
            nextIndex = currentIndex - 1
        else
            nextIndex = currentIndex
        end

        -- local nextShown, found = nil, false
        -- for n, _ in pairs(frames) do
        --     if n ~= itemSig then
        --         nextShown = n
        --         if found then break end
        --     else
        --         found = true
        --     end
        -- end

        -- hide frame and button
        f:Hide()
        buttons[itemSig]:Hide()
        frames = GRA:RemoveElementsByKeys(frames, {itemSig})
        buttons = GRA:RemoveElementsByKeys(buttons, {itemSig})
        lootsToSend = GRA:RemoveElementsByKeys(lootsToSend, {itemSig})
        table.remove(indices, currentIndex)
        -- show
        ShowButtons()
        ShowFrame(indices[nextIndex])
    end)

    -- scroll frame
    f.scrollFrame = GRA:CreateScrollFrame(f, -71, 0)
    f.scrollFrame:SetScrollStep(19)

    -- header
    local hName = f:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    local hResponse = f:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    local hPR = f:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    local hDKP = f:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    local hCurrentGear = f:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
    local hNotes = f:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")

    hName:SetText(L["Name"])
    hResponse:SetText(L["Response"])
    hPR:SetText("PR")
    hDKP:SetText("DKP")
    hCurrentGear:SetText(L["Current Gear"])
    hNotes:SetText(L["Notes"])

    hName:SetPoint("BOTTOMLEFT", f.scrollFrame, "TOPLEFT", 26, 4)
    -- hResponse:SetPoint("BOTTOMLEFT", f.scrollFrame, "TOPLEFT", 111, 4)
    -- hCurrentGear:SetPoint("BOTTOMLEFT", f.scrollFrame, "TOPLEFT", 216, 4)
    -- hNotes:SetPoint("BOTTOMLEFT", f.scrollFrame, "TOPLEFT", 354, 4)
    hResponse:SetPoint("LEFT", hName, 85, 0)
    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        distributionFrame:SetWidth(528)
        hPR:SetPoint("LEFT", hResponse, 105, 0)
        hCurrentGear:SetPoint("LEFT", hPR, 50, 0)
    elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
        distributionFrame:SetWidth(528)
        hDKP:SetPoint("LEFT", hResponse, 105, 0)
        hCurrentGear:SetPoint("LEFT", hDKP, 50, 0)
    else
        distributionFrame:SetWidth(478)
        hCurrentGear:SetPoint("LEFT", hResponse, 105, 0)
    end
    hNotes:SetPoint("LEFT", hCurrentGear, 138, 0)

    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then -- update epgp
        f:SetScript("OnShow", function()
            for playerName, row in pairs(f["rows"]) do
                row.prValue = GRA:GetPR(playerName)
                if row.prValue == 0 then
                    row.pr:SetText(gra.colors.grey.s .. row.prValue)
                else
                    row.pr:SetText(row.prValue)
                end
            end
            -- re-sort
            Sort(itemSig)
        end)
    elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then -- update dkp
        f:SetScript("OnShow", function()
            for playerName, row in pairs(f["rows"]) do
                row.dkpValue = GRA:GetDKP(playerName)
                if row.dkpValue == 0 then
                    row.dkp:SetText(gra.colors.grey.s .. row.dkpValue)
                else
                    row.dkp:SetText(row.dkpValue)
                end
            end
            -- re-sort
            Sort(itemSig)
        end)
    end

    return f
end

--------------------------------------------------------
-- create item button (left)
--------------------------------------------------------
local function CreateItemButton(itemSig, itemLink, count)
    -- button
    local itemBtn = GRA:CreateIconButton(distributionFrame, 35, 35, GetItemIcon(itemLink))
    buttons[itemSig] = itemBtn
    itemBtn:SetFrameLevel(2)

    GRA:CreateIconOverlay(itemBtn, itemLink, itemSig)

    ShowButtons()

    -- frame
    frames[itemSig] = CreateItemFrame(itemSig, itemLink, count)
    frames[itemSig]["rows"] = {}

    -- script
    itemBtn:SetScript("OnClick", function()
        ShowFrame(itemSig)
    end)
end

--------------------------------------------------------
-- announce loots
--------------------------------------------------------
local function SendLoots()
    -- send replies
    Comm:SendCommMessage("GRA_LOOT", Serializer:Serialize(_G[GRA_R_Config]["replies"]), "RAID", nil, "ALERT")

    -- send items to loot frame
    -- texplore(lootsToSend)
    for _, itemSig in pairs(indices) do
        -- 从非物品分配者变为物品分配者时，lootsToSend里边没有之前的物品
        if lootsToSend[itemSig] and (not lootsToSend[itemSig].sent) then
            Comm:SendCommMessage("GRA_LOOT_S", Serializer:Serialize(lootsToSend[itemSig]), "RAID", nil, "ALERT")
            lootsToSend[itemSig].sent = true -- mark as "sent"
        end
    end
end

--------------------------------------------------------
-- prepare data and show main frame
--------------------------------------------------------
local function ShowDistributionFrame()
    -- loots[itemSig] = {itemLink, quantity}
    for itemSig, t in pairs(loots) do
        if not lootsToSend[itemSig] then
            lootsToSend[itemSig] = {t[1], t[2]}
            table.insert(indices, itemSig)
            CreateItemButton(itemSig, t[1], t[2])
        end
    end

    if #indices > 0 then
        SendLoots()
        distributionFrame:Show()
    end
end

distributionFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(distributionFrame)
    if #indices > 0 then
        if not currentIndex then currentIndex = 1 end
        ShowFrame(indices[currentIndex])
    end
end)

--------------------------------------------------------
-- event
--------------------------------------------------------
-- distributionFrame:RegisterEvent("ADDON_LOADED")
distributionFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
distributionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
distributionFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
-- distributionFrame:RegisterEvent("LOOT_OPENED")
-- distributionFrame:RegisterEvent("LOOT_SLOT_CLEARED")
function GRA:UpdateLootMaster()
    local method, partyMaster, raidMaster = GetLootMethod()
    -- master looter and player is loot master
    gra.isLootMaster = (method == "master") and (raidMaster == UnitInRaid("player")) and IsInInstance()

    if gra.isLootMaster and _G[GRA_R_Config]["enableLootDistr"] then 
        distributionFrame:RegisterEvent("LOOT_OPENED")
        GRA:Print(L["Loot distribution tool enabled."])
    else
        distributionFrame:UnregisterEvent("LOOT_OPENED")
    end
end

distributionFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" or event == "PARTY_LOOT_METHOD_CHANGED" then
        GRA:UpdateLootMaster()

    elseif event == "LOOT_OPENED" then
        wipe(loots) -- clear loots
        for i = 1, GetNumLootItems() do
            local itemLink = GetLootSlotLink(i)
            -- texture, item, quantity, quality, locked = GetLootSlotInfo(i)
            -- 0. Poor (gray)
            -- 1. Common (white)
            -- 2. Uncommon (green)
            -- 3. Rare / Superior (blue)
            -- 4. Epic (purple)
            -- 5. Legendary (orange)
            -- 6. Artifact (golden yellow)
            -- 7. Heirloom (light yellow)
            local texture, itemName, quantity, quality = GetLootSlotInfo(i)
            if itemLink and quality and quality > 3 then -- TODO: filter
                -- 同一件物品 不同bonusID 应视为不同物品
                local itemSig = strjoin(":", GRA:GetItemSignatures(itemLink))
                if loots[itemSig] then
                    loots[itemSig][2] = loots[itemSig][2] + 1
                else
                    loots[itemSig] = {itemLink, quantity}
                end
            end
        end
        ShowDistributionFrame()
        -- texplore(loots)
    
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        -- for non loot master
        -- for i = #itemsNotFound, 1, -1 do
        --     if tonumber(arg1) == itemsNotFound[i][1] then
        --         local itemSig = strjoin(":", GRA:GetItemSignatures(itemsNotFound[i][2]))
        --         if not lootsToSend[itemSig] then
        --             table.insert(indices, itemSig)
        --             CreateItemButton(itemSig, itemsNotFound[i][2], itemsNotFound[i][3])
        --         end
        --         table.remove(itemsNotFound, i)
        --     end
        -- end

        for i = #playerItemsNotFound, 1, -1 do 
            if tonumber(arg1) == playerItemsNotFound[i][1] then
                playerItemsNotFound[i][2]:SetItem(playerItemsNotFound[i][3])
                table.remove(playerItemsNotFound, i)
            end
        end
    end
end)

--------------------------------------------------------
-- comm
--------------------------------------------------------
-- GRA_LOOT: send all "replies"
-- GRA_LOOT_R: reply/response
-- GRA_LOOT_S: start/send loot
-- GRA_LOOT_E: end loot
Comm:RegisterComm("GRA_LOOT_R", function(prefix, message, channel, sender)
    -- if not gra.isLootMaster then return end
    local success, reply = Serializer:Deserialize(message)
    if success then
        -- {class, spec, itemSig, responseIndex, g1, g2, note}
        SetMemberResponse(sender, reply[1], reply[2], reply[3], reply[4], reply[5], reply[6], reply[7])
    end
end)

--------------------------------------------------------
-- for non loot master
--------------------------------------------------------
function GRA:DistributionFrame_AddItem(itemSig, itemLink, count)
    table.insert(indices, itemSig)
    CreateItemButton(itemSig, itemLink, count)
end

function GRA:DistributionFrame_RemoveItem(itemSig)
    local indexToRemove = GRA:GetIndex(indices, itemSig)
    if not indexToRemove then return end -- no such frame

    local nextIndex
    if indexToRemove == #indices then -- 删除最后一个
        nextIndex = indexToRemove - 1
    else
        nextIndex = indexToRemove
    end

    -- hide frame and button
    frames[itemSig]:Hide()
    buttons[itemSig]:Hide()
    frames = GRA:RemoveElementsByKeys(frames, {itemSig})
    buttons = GRA:RemoveElementsByKeys(buttons, {itemSig})
    table.remove(indices, indexToRemove)
    
    -- show
    ShowButtons()
    ShowFrame(indices[nextIndex])
end

--------------------------------------------------------
-- loot distr test
--------------------------------------------------------
--@debug@
SLASH_LOOTDISTRTEST1 = "/ldtest"
function SlashCmdList.LOOTDISTRTEST(msg, editbox)
    if not gra.isLootMaster then return end
    -- gra.isLootMaster = true

    wipe(loots)
    -- wipe(lootsToSend)
    -- wipe(indices)
    -- currentIndex = 1

    for i = 1, 2 do
        -- local itemLink = GetInventoryItemLink("player", math.random(14))
        -- local itemLink = GetInventoryItemLink("player", i)
        local itemLink = GetContainerItemLink(0, i)
        if itemLink then
            local itemSig = strjoin(":", GRA:GetItemSignatures(itemLink))
            loots[itemSig] = {itemLink, math.random(i)}
        end
    end

    ShowDistributionFrame()

    local replies = {}
    for i in ipairs(_G[GRA_R_Config]["replies"]) do
        table.insert(replies, i)
    end
    table.insert(replies, 8)
    
    for i = 1, #indices do
        for j = 1, 20 do
            SetMemberResponse("player" .. j, math.random(12), math.random(2), indices[i], replies[math.random(#replies)], nil, nil, [[Best in slot (also "best-in-slot"; usually shortened to "BiS")]])
        end
    end
end
--@end-debug@