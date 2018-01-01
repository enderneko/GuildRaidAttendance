local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

-- https://wow.gamepedia.com/ItemEquipLoc
local slotIDs = {
    ["INVTYPE_HEAD"] = 1,
	["INVTYPE_NECK"] = 2,
	["INVTYPE_SHOULDER"] = 3,
	["INVTYPE_BODY"] = 4,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] = 5,
	["INVTYPE_WAIST"] = 6,
	["INVTYPE_LEGS"] = 7,
	["INVTYPE_FEET"] = 8,
	["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER"] = {11, 12},
    ["INVTYPE_TRINKET"] = {13, 14},
	["INVTYPE_BACK"] = 15,
    ["INVTYPE_CLOAK"] = 15,
    ["INVTYPE_WEAPON"] = {16, 17}, -- One-Hand
    ["INVTYPE_SHIELD"] = 17,
    ["INVTYPE_2HWEAPON"] = {16, 17},
    ["INVTYPE_WEAPONMAINHAND"] = 16,
    ["INVTYPE_WEAPONOFFHAND"] = 17,
    ["INVTYPE_HOLDABLE"] = 17,
}

local bindTypes = {
	[ITEM_BIND_ON_PICKUP] = "BoP",
	[ITEM_BIND_ON_EQUIP] = "BoE",
	[ITEM_BIND_ON_USE] = "BoU"
}

function GRA:GetItemBindType(itemLink)
	GRA_ScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GRA_ScanningTooltip:SetHyperlink(itemLink)

	for i = 2, 5 do
		local text = _G["GRA_ScanningTooltipTextLeft" .. i]
		if text then
			text = _G["GRA_ScanningTooltipTextLeft" .. i]:GetText()
			if bindTypes[text] then
				return bindTypes[text], text
			end
		end
	end
end

function GRA:GetItemStatus(itemLink)
	if not itemLink then return "" end
	GRA_ScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GRA_ScanningTooltip:SetHyperlink(itemLink)
	
	local t = ""
	if GRA_ScanningTooltipTextLeft2 then
		t = GRA_ScanningTooltipTextLeft2:GetText()
		if not string.find(t, "cFF 0FF 0") then t = "" end
	end
	GRA_ScanningTooltip:Hide()
	return t
end

function GRA:GetItemID(itemLink)
    local itemID = select(2, string.split(":", string.match(itemLink, "item[%-?%d:]+")))
    return tonumber(itemID)
end

function GRA:GetItemSignatures(itemLink)
	local itemString = string.match(itemLink, "item[%-?%d:]+")
	-- print(itemString)
	-- item:itemID:enchantID:gemID1:gemID2:gemID3:gemID4:suffixID:uniqueID:linkLevel:specializationID:upgradeTypeID:instanceDifficultyID:numBonusIDs[:bonusID1:bonusID2:...][:upgradeValue1:upgradeValue2:...]:relic1NumBonusIDs[:relic1BonusID1:relic1BonusID2:...]:relic2NumBonusIDs[:relic2BonusID1:relic2BonusID2:...]:relic3NumBonusIDs[:relic3BonusID1:relic3BonusID2:...]
    local item, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel, specializationID, upgradeTypeID, instanceDifficultyID, numBonusIDs, bonusID1, bonusID2, bonusID3, bonusID4 = string.split(":", itemString)
    local sockets = 0
    -- GRA_ScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    -- GRA_ScanningTooltip:SetHyperlink(itemLink)

    -- for i = 1, GRA_ScanningTooltip:NumLines() do
    --     local text = _G["GRA_ScanningTooltipTextLeft" .. i]
	-- 	if text then
    --         text = _G["GRA_ScanningTooltipTextLeft" .. i]:GetText()
    --         if string.find(text, EMPTY_SOCKET_PRISMATIC) then
    --             sockets = sockets + 1
    --         end
    --     end
    -- end
    
    -- socket
    local itemStats = GetItemStats(itemLink)
    if itemStats and itemStats["EMPTY_SOCKET_PRISMATIC"] then sockets = itemStats["EMPTY_SOCKET_PRISMATIC"] end
    wipe(itemStats)

    return tonumber(itemID), sockets, tonumber(numBonusIDs) or "", tonumber(bonusID1) or "", tonumber(bonusID2) or "" -- , tonumber(bonusID3) or "", tonumber(bonusID4) or ""
end

function GRA:GetSlotID(itemEquipLoc)
	if not itemEquipLoc or itemEquipLoc == "" then return end
	
    if type(slotIDs[itemEquipLoc]) == "table" then
        return unpack(slotIDs[itemEquipLoc])
    else
        return slotIDs[itemEquipLoc]
    end
end

function GRA:CreateIconOverlay(icon, itemLink, itemSig)
	local _, _, itemRarity, itemLevel = GetItemInfo(itemLink)
    local tokenID, tierVersion = GRA:IsTier(itemSig)
	if tokenID then
		_, itemLevel = GRA:GetTierInfo(tokenID, tierVersion)
	end

    local itemStatus = string.lower(GRA:GetItemStatus(itemLink))
    icon.ilvlTex = icon:CreateTexture()
    if string.find(itemStatus:lower(), L["Warforged"]:lower()) or string.find(itemStatus:lower(), L["Titanforged"]:lower()) then
        icon.ilvlTex:SetColorTexture(unpack(gra.colors.firebrick.t))
    else
        icon.ilvlTex:SetColorTexture(_G.ITEM_QUALITY_COLORS[itemRarity].r, _G.ITEM_QUALITY_COLORS[itemRarity].g, _G.ITEM_QUALITY_COLORS[itemRarity].b, .7)
    end
    icon.ilvlTex:SetHeight(11)
    icon.ilvlTex:SetPoint("BOTTOM", 0, 1)
    icon.ilvlTex:SetPoint("LEFT", 1, 0)
    icon.ilvlTex:SetPoint("RIGHT", -1, 0)
    icon.ilvlTex:SetDrawLayer("OVERLAY")

    icon.ilvlText = icon:CreateFontString(nil, "OVERLAY", "GRA_FONT_GRID")
    icon.ilvlText:SetPoint("BOTTOM", 0, 1)
    if select(2, string.split(":", itemSig)) ~= "0" then
        icon.ilvlText:SetText(itemLevel .. gra.colors.skyblue.s .. " S")
    else
        icon.ilvlText:SetText(itemLevel)
	end
	
	icon.bindTypeText = icon:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
	icon.bindTypeText:SetPoint("TOPLEFT", 2, -1)
	local bindType = GRA:GetItemBindType(itemLink)
	if bindType == "BoE" or bindType == "BoU" then
		icon.bindTypeText:SetText(gra.colors.firebrick.s .. bindType)
	end
end

