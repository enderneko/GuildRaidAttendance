local GRA, gra = unpack(select(2, ...))

local tierLevel = {
	["t21"] = {930, 945, 960},
	["t20"] = {900, 915, 930},
	["t19"] = {875, 890, 905},
	["t18"] = {695, 710, 725},
	["t17"] = {670, 685, 700},
}

local tierInfo = {
    -- Tier 21 -- Antorus, the Burning Throne
	[152524] = {"INVTYPE_HEAD", "t21"},
	[152525] = {"INVTYPE_HEAD", "t21"},
	[152526] = {"INVTYPE_HEAD", "t21"},

	[152530] = {"INVTYPE_SHOULDER", "t21"},
	[152531] = {"INVTYPE_SHOULDER", "t21"},
	[152532] = {"INVTYPE_SHOULDER", "t21"},

	[152518] = {"INVTYPE_CHEST", "t21"},
	[152519] = {"INVTYPE_CHEST", "t21"},
	[152520] = {"INVTYPE_CHEST", "t21"},

	[152521] = {"INVTYPE_HAND", "t21"},
	[152522] = {"INVTYPE_HAND", "t21"},
	[152523] = {"INVTYPE_HAND", "t21"},

	[152527] = {"INVTYPE_LEGS", "t21"},
	[152528] = {"INVTYPE_LEGS", "t21"},
	[152529] = {"INVTYPE_LEGS", "t21"},

	[152515] = {"INVTYPE_BACK", "t21"},
	[152516] = {"INVTYPE_BACK", "t21"},
	[152517] = {"INVTYPE_BACK", "t21"},

	-- Tier 20 -- Tomb of Sargeras
	[147322] = {"INVTYPE_HEAD", "t20"},
	[147323] = {"INVTYPE_HEAD", "t20"},
	[147324] = {"INVTYPE_HEAD", "t20"},

	[147328] = {"INVTYPE_SHOULDER", "t20"},
	[147329] = {"INVTYPE_SHOULDER", "t20"},
	[147330] = {"INVTYPE_SHOULDER", "t20"},

	[147316] = {"INVTYPE_CHEST", "t20"},
	[147317] = {"INVTYPE_CHEST", "t20"},
	[147318] = {"INVTYPE_CHEST", "t20"},

	[147319] = {"INVTYPE_HAND", "t20"},
	[147320] = {"INVTYPE_HAND", "t20"},
	[147321] = {"INVTYPE_HAND", "t20"},

	[147325] = {"INVTYPE_LEGS", "t20"},
	[147326] = {"INVTYPE_LEGS", "t20"},
	[147327] = {"INVTYPE_LEGS", "t20"},

	[147331] = {"INVTYPE_BACK", "t20"},
	[147332] = {"INVTYPE_BACK", "t20"},
	[147333] = {"INVTYPE_BACK", "t20"},

	-- Tier 19 -- The Nighthold
	[143565] = {"INVTYPE_HEAD", "t19"},
	[143575] = {"INVTYPE_HEAD", "t19"},
	[143568] = {"INVTYPE_HEAD", "t19"},

	[143566] = {"INVTYPE_SHOULDER", "t19"},
	[143576] = {"INVTYPE_SHOULDER", "t19"},
	[143570] = {"INVTYPE_SHOULDER", "t19"},

	[143562] = {"INVTYPE_CHEST", "t19"},
	[143572] = {"INVTYPE_CHEST", "t19"},
	[143571] = {"INVTYPE_CHEST", "t19"},

	[143563] = {"INVTYPE_HAND", "t19"},
	[143573] = {"INVTYPE_HAND", "t19"},
	[143567] = {"INVTYPE_HAND", "t19"},

	[143564] = {"INVTYPE_LEGS", "t19"},
	[143574] = {"INVTYPE_LEGS", "t19"},
	[143569] = {"INVTYPE_LEGS", "t19"},

	[143577] = {"INVTYPE_BACK", "t19"},
	[143579] = {"INVTYPE_BACK", "t19"},
	[143578] = {"INVTYPE_BACK", "t19"},

	-- Tier 18 -- Hellfire Citadel
	[127956] = {"INVTYPE_HEAD", "t18"},
	[127959] = {"INVTYPE_HEAD", "t18"},
	[127966] = {"INVTYPE_HEAD", "t18"},

	[127957] = {"INVTYPE_SHOULDER", "t18"},
	[127961] = {"INVTYPE_SHOULDER", "t18"},
	[127967] = {"INVTYPE_SHOULDER", "t18"},

	[127962] = {"INVTYPE_CHEST", "t18"},
	[127953] = {"INVTYPE_CHEST", "t18"},
	[127963] = {"INVTYPE_CHEST", "t18"},

	[127958] = {"INVTYPE_HAND", "t18"},
	[127954] = {"INVTYPE_HAND", "t18"},
	[127964] = {"INVTYPE_HAND", "t18"},

	[127955] = {"INVTYPE_LEGS", "t18"},
	[127960] = {"INVTYPE_LEGS", "t18"},
	[127965] = {"INVTYPE_LEGS", "t18"},

	[127968] = {"INVTYPE_TRINKET", {705, 720, 735}},
	[127969] = {"INVTYPE_TRINKET", {705, 720, 735}},
	[127970] = {"INVTYPE_TRINKET", {705, 720, 735}},

	-- Tier 17 -- Blackrock Foundry
	[119308] = {"INVTYPE_HEAD", "t17"},
	[119312] = {"INVTYPE_HEAD", "t17"},
    [119321] = {"INVTYPE_HEAD", "t17"},

	[119309] = {"INVTYPE_SHOULDER", "t17"},
	[119314] = {"INVTYPE_SHOULDER", "t17"},
    [119322] = {"INVTYPE_SHOULDER", "t17"},

	[119305] = {"INVTYPE_CHEST", "t17"},
	[119315] = {"INVTYPE_CHEST", "t17"},
    [119318] = {"INVTYPE_CHEST", "t17"},

	[119306] = {"INVTYPE_HAND", "t17"},
	[119311] = {"INVTYPE_HAND", "t17"},
	[119319] = {"INVTYPE_HAND", "t17"},

	[119307] = {"INVTYPE_LEGS", "t17"},
	[119313] = {"INVTYPE_LEGS", "t17"},
	[119320] = {"INVTYPE_LEGS", "t17"},
}

function GRA.IsTier(itemSig)
	local itemID, _, _, bonusID1 = string.split(":", itemSig)
	itemID = tonumber(itemID)
	bonusID1 = tonumber(bonusID1)
	local tierVersion
	if bonusID1 == 569 then -- mythic
		tierVersion = 3
	elseif bonusID1 == 570 then -- heroic
		tierVersion = 2
	else
		tierVersion = 1
	end

	if tierInfo[itemID] then
        return itemID, tierVersion
    else
        return false
    end
end

function GRA.GetTierInfo(tokenID, tierVersion)
	-- slot, ilvl
	return tierInfo[tokenID][1], tierLevel[tierInfo[tokenID][2]][tierVersion]
end