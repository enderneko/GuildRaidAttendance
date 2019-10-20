local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LGN = LibStub:GetLibrary("LibGuildNotes")

local importFrame = GRA:CreateFrame(L["Import"], "GRA_ImportFrame", gra.mainFrame, 151, gra.mainFrame:GetHeight())
gra.importFrame = importFrame
importFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
importFrame.header.closeBtn:SetText("←")
local fontName = importFrame.header.closeBtn:GetFontString():GetFont()
importFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
importFrame.header.closeBtn:SetScript("OnClick", function() importFrame:Hide() gra.configFrame:Show() end)

-------------------------------------------------
-- page
-------------------------------------------------
local modified = {} -- {[playerName] = {["class"] = (string), ["checked"] = (boolean)}, ...}
local guildBtn, groupBtn, guildFrame, groupFrame, selectAllBtn, RefreshGuildRoster, RefreshGroupRoster
guildBtn = GRA:CreateButton(importFrame, L["Guild"], nil, {71, 20}, "GRA_FONT_SMALL")
guildBtn:SetPoint("TOPLEFT", 5, -5)
guildBtn:SetBackdropColor(.5, 1, 0, .6)
guildBtn:SetScript("OnEnter", nil)
guildBtn:SetScript("OnLeave", nil)
guildBtn:SetScript("OnClick", function()
	RefreshGuildRoster()
	guildFrame:Show()
	groupFrame:Hide()

	guildBtn:SetBackdropColor(.5, 1, 0, .6)
	guildBtn:SetScript("OnEnter", nil)
	guildBtn:SetScript("OnLeave", nil)
	
	groupBtn:SetBackdropColor(.1, .1, .1, .7)
	groupBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .6) end)
	groupBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(.1, .1, .1, .7) end)
end)

groupBtn = GRA:CreateButton(importFrame, L["Group"], nil, {71, 20}, "GRA_FONT_SMALL")
groupBtn:SetPoint("LEFT", guildBtn, "RIGHT", -1, 0)
groupBtn:SetScript("OnClick", function()
	RefreshGroupRoster()
	groupFrame:Show()
	guildFrame:Hide()

	groupBtn:SetBackdropColor(.5, 1, 0, .6)
	groupBtn:SetScript("OnEnter", nil)
	groupBtn:SetScript("OnLeave", nil)
	
	guildBtn:SetBackdropColor(.1, .1, .1, .7)
	guildBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .6) end)
	guildBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(.1, .1, .1, .7) end)
end)

-------------------------------------------------
-- guild
-------------------------------------------------
guildFrame = CreateFrame("Frame", nil, importFrame)
guildFrame:SetPoint("TOP", 0, -30)
guildFrame:SetPoint("BOTTOM", 0, 32)
guildFrame:SetPoint("LEFT")
guildFrame:SetPoint("RIGHT")

local rankText = guildFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
rankText:SetPoint("TOPLEFT", 5, -3)
rankText:SetJustifyH("LEFT")
rankText:SetWidth(guildFrame:GetWidth()-14)
rankText:SetWordWrap(false)
rankText:SetText("|cff80FF00"..L["Guild Rank:"])

-- dropdown
local rankDropDown = GRA:CreateDropDownMenu(guildFrame, guildFrame:GetWidth()-10)
rankDropDown:SetPoint("TOPLEFT", 5, -20)

-- scroll
GRA:CreateScrollFrame(guildFrame, -47)
guildFrame.scrollFrame:SetScrollStep(16)

-- guild ranks
local guildRanks = {}
local selectedRank
-- guild roster list
local cbs_guild = {} -- contains all checkbuttons (roster)
local currentGuildRank = {} -- sorted

RefreshGuildRoster = function()
	wipe(currentGuildRank)
	guildFrame.scrollFrame:Reset()
	-- roster above selected rank {"name", "class"}
	local roster = GRA:GetGuildRoster(GRA:GetIndex(guildRanks, rankDropDown.selected))
	GRA:Sort(roster, "rankIndex", "ascending", "class", "ascending", "name", "ascending")

	local last, lastRank
	-- create
	for i = 1, #roster do
		local playerName = roster[i].name
		if not cbs_guild[playerName] then
			cbs_guild[playerName] = GRA:CreateCheckButton(guildFrame.scrollFrame.content, string.split("-", playerName), RAID_CLASS_COLORS[roster[i].class], function(checked)
				-- clicked --> modified
				modified[playerName] = {["class"] = roster[i].class, ["checked"] = checked}
			end)
		end
		
		if modified[playerName] then -- exists in modified, changed guild rank
			cbs_guild[playerName]:SetChecked(modified[playerName]["checked"])
		else
			-- if player already in _G[GRA_R_Roster] then check
			cbs_guild[playerName]:SetChecked(_G[GRA_R_Roster][playerName])
		end

		cbs_guild[playerName]:SetParent(guildFrame.scrollFrame.content) -- important!
		cbs_guild[playerName]:Show()
		if i == 1 then
			cbs_guild[playerName]:SetPoint("TOPLEFT", 5, 0)
		else
			if lastRank ~= roster[i].rankIndex then
				cbs_guild[playerName]:SetPoint("TOP", last, "BOTTOM", 0, -16)
			else
				cbs_guild[playerName]:SetPoint("TOP", last, "BOTTOM")
			end
		end
		lastRank = roster[i].rankIndex
		last = cbs_guild[playerName]
	end
end

local function LoadDropDown()
	local items = {}
	local ranks = GuildControlGetNumRanks()
	for i = 1, ranks do
		local item = {}
		item.text = GuildControlGetRankName(i)
		item.onClick = function() 
			guildFrame.scrollFrame:ResetScroll()
			RefreshGuildRoster()
			selectedRank = GuildControlGetRankName(i)
		end
		table.insert(items, item)
		table.insert(guildRanks, item.text)
	end

	rankDropDown:SetItems(items)
	-- show rank 4 by default
	rankDropDown:SetSelected(selectedRank or guildRanks[4])
end

guildFrame:SetScript("OnShow", function()
	selectAllBtn:SetEnabled(false)
	wipe(guildRanks)
	LoadDropDown()
	RefreshGuildRoster()
end)

guildFrame:SetScript("OnHide", function()
	wipe(modified)
end)

-------------------------------------------------
-- group
-------------------------------------------------
groupFrame = CreateFrame("Frame", nil, importFrame)
groupFrame:SetPoint("TOP", 0, -30)
groupFrame:SetPoint("BOTTOM", 0, 31)
groupFrame:SetPoint("LEFT")
groupFrame:SetPoint("RIGHT")
groupFrame:Hide()

-- scroll
GRA:CreateScrollFrame(groupFrame)
groupFrame.scrollFrame:SetScrollStep(16)

local cbs_group, currentInGroup = {}, {}
RefreshGroupRoster = function()
	wipe(currentInGroup)
	for i = 1, GetNumGroupMembers("LE_PARTY_CATEGORY_HOME") do
		local playerName, _, _, _, _, classFileName = GetRaidRosterInfo(i)
		if playerName then
			if not string.find(playerName, "-") then playerName = playerName .. "-" .. GRA:GetRealmName() end
			
			table.insert(currentInGroup, {playerName, classFileName})
			if not cbs_group[playerName] then
				cbs_group[playerName] = GRA:CreateCheckButton(groupFrame.scrollFrame.content, string.split("-", playerName), RAID_CLASS_COLORS[classFileName], function(checked)
					-- clicked --> modified
					modified[playerName] = {["class"] = classFileName, ["checked"] = checked}
				end)
			end
		end
	end

	groupFrame.scrollFrame:Reset()

	table.sort(currentInGroup, function(a, b)
		if a[2] ~= b[2] then
			return GRA:GetIndex(gra.CLASS_ORDER, a[2]) < GRA:GetIndex(gra.CLASS_ORDER, b[2])
		else
            return a[1] < b[1]
		end
	end)

	local last
	for i = 1, #currentInGroup do
		local name = currentInGroup[i][1]
		if modified[name] then
			cbs_group[name]:SetChecked(modified[name]["checked"])
		else
			-- if player already in _G[GRA_R_Roster] then check
			cbs_group[name]:SetChecked(_G[GRA_R_Roster][name])
		end

		cbs_group[name]:SetParent(groupFrame.scrollFrame.content) -- important!
		cbs_group[name]:Show()
		if i == 1 then
			cbs_group[name]:SetPoint("TOPLEFT", 5, 0)
		else
			cbs_group[name]:SetPoint("TOP", last, "BOTTOM")
		end
		last = cbs_group[name]
	end
end

groupFrame:SetScript("OnEvent", function()
	RefreshGroupRoster()
end)

groupFrame:SetScript("OnShow", function()
	selectAllBtn:SetEnabled(true)
	RefreshGroupRoster()
	groupFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
end)

groupFrame:SetScript("OnHide", function()
	wipe(modified)
	groupFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
end)

-------------------------------------------------
-- button
-------------------------------------------------
local importBtn = GRA:CreateButton(importFrame, L["Import"], "red", {68, 20}, "GRA_FONT_SMALL")
importBtn:SetPoint("BOTTOMLEFT", 5, 5)
importBtn:SetFrameLevel(129)
importBtn:SetScript("OnClick", function()
	GRA:Debug("|cff87CEEB---------- Import ----------|r")
	for n, t in pairs(modified) do
		GRA:Debug(n .. " " .. GRA:GetLocalizedClassName(t.class) .. " (" .. (t.checked and "imported" or "removed") .. ")")
		if t.checked then  -- show this player
			if LGN:IsInGuild(n) then
				-- create new
				if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
					-- retrieve EPGP
					local note = LGN:GetOfficerNote(n)
					if note then
						local ep, gp = string.split(",", note)
						ep, gp = tonumber(ep), tonumber(gp)
						-- make sure epgp has been initialized
						if not ep or not gp then
							ep = 0
							gp = 0
							LGN:SetOfficerNote(n, "0,0")
						end
						_G[GRA_R_Roster][n] = {["class"]=t.class, ["role"]="DPS", ["EP"]=ep, ["GP"]=gp}
					end
				elseif _G[GRA_R_Config]["raidInfo"]["system"] == "DKP" then
					-- retrieve DKP
					local note = LGN:GetOfficerNote(n)
					if note then
						local current, spent, total = string.split(",", note)
						current, spent, total = tonumber(current), tonumber(spent), tonumber(total)
						-- make sure dkp has been initialized
						if not current or not spent or not total then
							current = 0
							spent = 0
							total = 0
							LGN:SetOfficerNote(n, "0,0,0")
						end
						_G[GRA_R_Roster][n] = {["class"]=t.class, ["role"]="DPS", ["DKP_Current"]=current, ["DKP_Spent"]=spent, ["DKP_Total"]=total}
					end
				else -- loot council
					_G[GRA_R_Roster][n] = {["class"]=t.class, ["role"]="DPS"}
				end
			else
				GRA:Print(L["Failed to import, %s is not in your guild."]:format(GRA:GetClassColoredName(n, t.class)))
			end
		elseif _G[GRA_R_Roster][n] then  -- already exists, t.checked = false, then delete it
			_G[GRA_R_Roster] = GRA:RemoveElementsByKeys(_G[GRA_R_Roster], {n})
		end
	end
	wipe(modified) -- imported, empty this table
	importFrame:Hide()
	
	gra.configFrame:Show()
	-- refresh the sheet now!
	GRA:FireEvent("GRA_ROSTER")
end)

selectAllBtn = GRA:CreateButton(importFrame, L["Select All"], "red", {68, 20}, "GRA_FONT_SMALL")
selectAllBtn:SetEnabled(false)
selectAllBtn:SetPoint("BOTTOMRIGHT", -5, 5)
selectAllBtn:SetFrameLevel(129)
selectAllBtn:SetScript("OnClick", function()
	for i = 1, #currentInGroup do
		local name = currentInGroup[i][1]
		local class = currentInGroup[i][2]
		cbs_group[name]:SetChecked(true)
		modified[name] = {["class"] = class, ["checked"] = true}
	end
end)

-------------------------------------------------
-- show/hide
-------------------------------------------------
importFrame:SetScript("OnHide", function(self)
	self:Hide()
end)