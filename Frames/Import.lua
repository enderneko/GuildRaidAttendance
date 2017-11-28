local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local LGN = LibStub:GetLibrary("LibGuildNotes")
-------------------------------------------------
-- import frame 2017-06-19 04:05:47
-------------------------------------------------
local importFrame = GRA:CreateFrame(L["Import"], "GRA_ImportFrame", gra.mainFrame, 150, gra.mainFrame:GetHeight())
gra.importFrame = importFrame
importFrame:SetPoint("TOPLEFT", gra.mainFrame, "TOPRIGHT", 2, 0)
importFrame.header.closeBtn:SetText("←")
local fontName = importFrame.header.closeBtn:GetFontString():GetFont()
importFrame.header.closeBtn:GetFontString():SetFont(fontName, 11)
importFrame.header.closeBtn:SetScript("OnClick", function() importFrame:Hide() gra.configFrame:Show() end)

local rankText = importFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
rankText:SetPoint("TOPLEFT", 5, -7)
rankText:SetJustifyH("LEFT")
rankText:SetWidth(importFrame:GetWidth()-14)
rankText:SetWordWrap(false)
rankText:SetText("|cff80FF00"..L["Guild Rank:"])

-- dropdown
local rankDropDown = GRA:CreateDropDownMenu(importFrame, 140)
rankDropDown:SetPoint("TOPLEFT", 5, -22)

-- scroll
local rosterFrame = CreateFrame("Frame", nil, importFrame)
rosterFrame:SetPoint("TOPLEFT", rankDropDown, "BOTTOMLEFT", -5, -5)
rosterFrame:SetPoint("BOTTOMRIGHT", 0, 31)
GRA:CreateScrollFrame(rosterFrame)

-- guild ranks
local guildRanks = {}
-- import roster
local modified = {} -- {[playerName] = {["class"] = (string), ["checked"] = (boolean)}, ...}
-- guild roster list
local cbs = {} -- contains all checkbuttons (roster)
local function RefreshRoster()
	-- roster above selected rank {"name", "class"}
	local roster = GRA:GetGuildRoster(GRA:GetIndex(guildRanks, rankDropDown.selected))
	local last = nil
	-- create & setpoint
	for i = 1, #roster do
		if not cbs[i] then
			local name = string.split("-", roster[i].name)
			cbs[i] = GRA:CreateCheckButton(rosterFrame.scrollFrame.content, name, RAID_CLASS_COLORS[roster[i].class], function(checked)
				-- clicked --> modified
				modified[roster[i].name] = {["class"] = roster[i].class, ["checked"] = checked}
			end)
		end
		-- if player already in GRA_Roster then check else uncheck
		cbs[i]:SetChecked(GRA_Roster[roster[i].name]) -- belongs to current team
		
		cbs[i]:SetParent(rosterFrame.scrollFrame.content) -- important!
		if i == 1 then
			cbs[i]:SetPoint("TOPLEFT")
		else
			cbs[i]:SetPoint("TOPLEFT", last, 0, -20)
		end
		cbs[i]:Show()
		last = cbs[i]
	end
	-- hide others
	for i = #roster+1, #cbs do
		-- cbs[i]:SetPoint("TOPLEFT", rosterFrame.scrollFrame.content)
		cbs[i]:SetParent(nil) -- important!
		cbs[i]:ClearAllPoints()
		cbs[i]:Hide()
	end
	-- reset content height
	rosterFrame.scrollFrame:ResetHeight()
end

-- load drop down only once
local dropdownLoaded = false
local function LoadDropDown()
	if not dropdownLoaded then
		local items = {}
		local ranks = GuildControlGetNumRanks()
		for i = 1, ranks do
			local item = {}
			item.text = GuildControlGetRankName(i)
			item.onClick = function() 
				rosterFrame.scrollFrame:ResetScroll()
				RefreshRoster()
			end
			table.insert(items, item)
			table.insert(guildRanks, item.text)
		end

		rankDropDown:SetItems(items)
		-- show rank 4 by default
		rankDropDown:SetSelected(guildRanks[4])
		dropdownLoaded = true
	end
end

-- button
local importBtn = GRA:CreateButton(importFrame, L["Import"], nil, {67, 20}, "GRA_FONT_SMALL")
importBtn:SetPoint("BOTTOMLEFT", 5, 5)
importBtn:SetFrameLevel(129)
importBtn:SetScript("OnClick", function()
	GRA:Debug("|cff87CEEB---------- Import ----------|r")
	for n, t in pairs(modified) do
		GRA:Debug(n .. " " .. GRA:GetLocalizedClassName(t.class) .. " (" .. (t.checked and "imported" or "removed") .. ")")
		if t.checked then  -- show this player
			-- create new
			if GRA_Config["useEPGP"] then
				-- read EPGP
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
					GRA_Roster[n] = {["class"]=t.class, ["EP"]=ep, ["GP"]=gp}
				else
					GRA:Print(L["Failed to import player %s."]:format(n))
				end
			else
				-- don't use EPGP
				GRA_Roster[n] = {["class"]=t.class}
			end
		elseif GRA_Roster[n] then  -- already exists, t.checked = false, then delete it
			GRA_Roster = GRA:RemoveElementsByKeys(GRA_Roster, {n})
		end
	end
	modified = {} -- imported, empty this table
	importFrame:Hide()
	
	gra.configFrame:Show()
	-- refresh the sheet now!
	GRA:ShowAttendanceSheet()
	-- GRA:RefreshCurrentRaidLog() no need to refresh
end)

local selectAllBtn = GRA:CreateButton(importFrame, L["Select All"], nil, {67, 20}, "GRA_FONT_SMALL")
selectAllBtn:SetEnabled(false)
selectAllBtn:SetPoint("LEFT", importBtn, "RIGHT", 5, 0)
selectAllBtn:SetFrameLevel(129)
selectAllBtn:SetScript("OnClick", function()
	print("Select All!!!")
end)

importFrame:SetScript("OnShow", function()
	modified = {}
	LoadDropDown()
	RefreshRoster()
end)

importFrame:SetScript("OnHide", function(self)
	self:Hide()
end)