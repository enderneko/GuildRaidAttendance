local GRA, gra = unpack(select(2, ...))

local classArtifact = {
    ["DEATHKNIGHT"] = {128402, 128292, 128403},
    ["DEMONHUNTER"] = {127829, 128832},
    ["DRUID"] = {128858, 128860, 128821, 128306},
    ["HUNTER"] = {128861, 128826, 128808},
    ["MAGE"] = {127857, 128820, 128862},
    ["MONK"] = {128938, 128937, 128940},
    ["PALADIN"] = {128823, 128866, 120978},
    ["PRIEST"] = {128868, 128825, 128827},
    ["ROGUE"] = {128870, 128872, 128476},
    ["SHAMAN"] = {128935, 128819, 128911},
    ["WARLOCK"] = {128942, 128943, 128941},
    ["WARRIOR"] = {128910, 128908, 128289},
}

local relicSlots = {
	[128402] = {"Blood", "Shadow", "Iron"}, -- Blood DK
	[128292] = {"Frost", "Shadow", "Frost"}, -- Frost DK
    [128403] = {"Fire", "Shadow", "Blood"}, -- Unholy DK
    
    [127829] = {"Fel", "Shadow", "Fel"}, -- Havoc DH
	[128832] = {"Iron", "Arcane", "Fel"}, -- Vengeance DH

	[128858] = {"Arcane", "Life", "Arcane"}, -- Balance Druid
	[128860] = {"Frost", "Blood", "Life"}, -- Feral Druid
	[128821] = {"Fire", "Blood", "Life"}, -- Guardian Druid
	[128306] = {"Life", "Frost", "Life"}, -- Restoration Druid

	[128861] = {"Wind", "Arcane", "Iron"}, -- Beast Mastery Hunter
	[128826] = {"Wind", "Blood", "Life"}, -- Marksmanship Hunter
	[128808] = {"Wind", "Iron", "Blood"}, -- Survival Hunter

	[127857] = {"Arcane", "Frost", "Arcane"}, -- Arcane Mage
	[128820] = {"Fire", "Arcane", "Fire"}, -- Fire Mage
	[128862] = {"Frost", "Arcane", "Frost"}, -- Frost Mage

	[128938] = {"Life", "Wind", "Iron"}, -- Brewmaster Monk
	[128937] = {"Frost", "Life", "Wind"}, -- Mistweaver Monk
	[128940] = {"Wind", "Iron", "Wind"}, -- Windwalker Monk

	[128823] = {"Holy", "Life", "Holy"}, -- Holy Paladin
	[128866] = {"Holy", "Iron", "Arcane"}, -- Protection Paladin
	[120978] = {"Holy", "Fire", "Holy"}, -- Retribution Paladin

	[128868] = {"Holy", "Shadow", "Holy"}, -- Discipline Priest
	[128825] = {"Holy", "Life", "Holy"}, -- Holy Priest
	[128827] = {"Shadow", "Blood", "Shadow"}, -- Shadow Priest

	[128870] = {"Shadow", "Iron", "Blood"}, -- Assassination Rogue
	[128872] = {"Blood", "Iron", "Wind"}, -- Outlaw Rogue
	[128476] = {"Fel", "Shadow", "Fel"}, -- Subtlety Rogue

	[128935] = {"Wind", "Frost", "Wind"}, -- Elemental Shaman
	[128819] = {"Fire", "Iron", "Wind"}, -- Enhancement Shaman
	[128911] = {"Life", "Frost", "Life"}, -- Restoration Shaman

	[128942] = {"Shadow", "Blood", "Shadow"}, -- Affliction Warlock
	[128943] = {"Shadow", "Fire", "Fel"}, -- Demonology Warlock
	[128941] = {"Fel", "Fire", "Fel"}, -- Destruction Warlock

	[128910] = {"Iron", "Blood", "Shadow"}, -- Arms Warrior
	[128908] = {"Fire", "Wind", "Iron"}, -- Fury Warrior
	[128289] = {"Iron", "Blood", "Fire"}, -- Protection Warrior
}

local relicTypes = {
	["Arcane"] = RELIC_SLOT_TYPE_ARCANE,
	["Blood"] = RELIC_SLOT_TYPE_BLOOD,
	["Fel"] = RELIC_SLOT_TYPE_FEL,
	["Fire"] = RELIC_SLOT_TYPE_FIRE,
	["Frost"] = RELIC_SLOT_TYPE_FROST,
	["Holy"] = RELIC_SLOT_TYPE_HOLY,
	["Iron"] = RELIC_SLOT_TYPE_IRON,
	["Life"] = RELIC_SLOT_TYPE_LIFE,
	["Shadow"] = RELIC_SLOT_TYPE_SHADOW,
	["Wind"] = RELIC_SLOT_TYPE_WIND,
}

function GRA:IsRelic(itemLink)
    -- texplore(GetItemStats(itemLink))
	--或者使用 GetItemStats(itemLink) --> RELIC_ITEM_LEVEL_INCREASE
	local itemSubType = select(7, GetItemInfo(itemLink))
	return EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC:lower() == itemSubType:lower()
end

function GRA:GetRelicType(itemLink)
	GRA_ScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GRA_ScanningTooltip:SetHyperlink(itemLink)
	for i = 2, 6 do
		local text = _G["GRA_ScanningTooltipTextLeft" .. i]
		if text then
			text = _G["GRA_ScanningTooltipTextLeft" .. i]:GetText()
			for relicType, localizedRelicType in pairs(relicTypes) do
				if string.find(text, localizedRelicType) then
					return relicType
				end
			end
		end
    end
end

-- get relic from artifact link, SMARTER!
function GRA:GetEquipedRelicLink(relicTypeSource)
    local relic1, relic2

    local artifactID = classArtifact[select(2, UnitClass("player"))][GetSpecialization()]

    for relicSlotIndex, relicType in pairs(relicSlots[artifactID]) do
        if relicTypeSource == relicType then
            local relicLink = select(2, GetItemGem(GetInventoryItemLink("player", 16), relicSlotIndex)) 
                or select(2, GetItemGem(GetInventoryItemLink("player", 17), relicSlotIndex))
            if not relic1 then
                relic1 = relicLink
            else
                relic2 = relicLink
            end
        end
    end

    return relic1, relic2
end

--[[
function GRA:GetEquipedRelicLink2(relicTypeSource)
    local relic1, relic2
    SocketInventoryItem(17)
	SocketInventoryItem(16)
    LoadAddOn("Blizzard_ArtifactUI")
    
    for i = 1, C_ArtifactUI.GetNumRelicSlots() do
        local relicName, relicIcon, relicType, relicLink = C_ArtifactUI.GetRelicInfo(i);
        if relicLink then
            local relicType = GRA:GetRelicType(relicLink)
            if relicTypeSource:lower() == relicType:lower() then
                if not relic1 then
                    relic1 = relicLink
                else
                    relic2 = relicLink
                end
            end
        end
    end

    HideUIPanel(ArtifactFrame)
    return relic1, relic2
end
]]