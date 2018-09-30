local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local lastFrame = nil

-----------------------------------------
-- main frame
-----------------------------------------
gra.mainFrame = GRA:CreateMovableFrame("Guild Raid Attendance", "GRA_MainFrame", 620, 400, "GRA_FONT_TITLE")

-----------------------------------------
-- Guild Message of the Day
-----------------------------------------
-- guildMOTDScroll : scroll effect (SetHorizontalScroll(scroll) @ OnUpdate)
--		└ content : scroll child
--			└ text : the guild message of the day (get scroll range from string width)
--				└ animation : fade-in effect
		
local guildMOTDScroll = CreateFrame("ScrollFrame", nil, gra.mainFrame)
guildMOTDScroll:Hide() -- hide by default
guildMOTDScroll:SetPoint("TOPLEFT", 8, -5)
guildMOTDScroll:SetPoint("BOTTOMRIGHT", gra.mainFrame, "TOPRIGHT", -8, -25)
gra.mainFrame.guildMOTDScroll = guildMOTDScroll

guildMOTDScroll.content = CreateFrame("Frame", nil, guildMOTDScroll)
guildMOTDScroll.content:SetSize(100, 20)
guildMOTDScroll:SetScrollChild(guildMOTDScroll.content)

guildMOTDScroll.content.text = guildMOTDScroll.content:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
guildMOTDScroll.content.text:SetWordWrap(false)
guildMOTDScroll.content.text:SetPoint("LEFT")

-- alpha changing animation
local fadeIn = guildMOTDScroll.content.text:CreateAnimationGroup()
local alpha = fadeIn:CreateAnimation("Alpha")
alpha:SetFromAlpha(0)
alpha:SetToAlpha(1)
alpha:SetDuration(.5)

local elapsedTime, delay, scroll, maxHScrollRange, doScroll -- delay: delay before scroll (include time for alpha changing), 5 by default
local MOTD = ""
-- init guildMOTDScroll
guildMOTDScroll:SetScript("OnShow", function()
	if MOTD == "" then -- if empty, hide
		guildMOTDScroll:Hide()
		return
	end
	
	guildMOTDScroll.content.text:SetText("|cff40ff40" .. string.format(GUILD_MOTD_TEMPLATE, MOTD) .. "|r")
	-- init
	fadeIn:Play()
	guildMOTDScroll:SetHorizontalScroll(0)
	elapsedTime, delay, scroll = 0, 0, 0
	maxHScrollRange = guildMOTDScroll.content.text:GetStringWidth() + 30 -- 30*0.05 = 1.5s delay to next round
	if guildMOTDScroll.content.text:GetStringWidth() <= guildMOTDScroll:GetWidth() then
		doScroll = false 
	else
		doScroll = true
	end
end)

guildMOTDScroll:SetScript("OnUpdate", function(self, elapsed)
	elapsedTime = elapsedTime + elapsed
	delay = delay + elapsed
	if elapsedTime >= 0.025 then
		if doScroll and delay >= 5 then	-- when the text opacity is full
			if scroll >= maxHScrollRange then	-- prepare for next round
				scroll = 0 
				delay = 0
				fadeIn:Play()
			end
			guildMOTDScroll:SetHorizontalScroll(scroll)
			-- print(guildMOTDScroll:GetHorizontalScroll() .. "/" .. maxHScrollRange)
			scroll = scroll + .5
		end
		elapsedTime = elapsedTime - 0.025
	end
end)

-----------------------------------------
-- button
-----------------------------------------
local configBtn = GRA:CreateButton(gra.mainFrame, L["Config"], "red", {55, 20}, "GRA_FONT_SMALL")
configBtn:SetPoint("BOTTOMRIGHT", -8, 5)
configBtn:SetScript("OnClick", function()
	gra.importFrame:Hide()
	-- gra.epgpOptionsFrame:Hide()
	-- gra.dkpOptionsFrame:Hide()
	gra.rosterEditorFrame:Hide()
	gra.appearanceFrame:Hide()
	if gra.configFrame:IsShown() then
		gra.configFrame:Hide()
	else
		gra.configFrame:Show()
	end
end)

local buttons = {}
local function HighlightButton(button)
	for n, b in pairs(buttons) do
		if n == button then
			b:SetBackdropBorderColor(.5, 1, 0, 1)
		else
			b:SetBackdropBorderColor(0, 0, 0, 1)
		end
	end
end

buttons["attendanceSheetBtn"] = GRA:CreateButton(gra.mainFrame, L["Attendance Sheet"], "red", {100, 20}, "GRA_FONT_SMALL")
buttons["attendanceSheetBtn"]:SetPoint("BOTTOMLEFT", 8, 5)
buttons["attendanceSheetBtn"]:SetScript("OnClick", function()
	HighlightButton("attendanceSheetBtn")
	lastFrame = gra.attendanceFrame
	gra.attendanceFrame:Show()
	gra.announcementsFrame:Hide()
	gra.raidLogsFrame:Hide()
end)

buttons["raidLogsBtn"] = GRA:CreateButton(gra.mainFrame, L["Raid Logs"], "red", {100, 20}, "GRA_FONT_SMALL")
buttons["raidLogsBtn"]:SetPoint("LEFT", buttons["attendanceSheetBtn"], "RIGHT", 5, 0)
buttons["raidLogsBtn"]:SetScript("OnClick", function()
	HighlightButton("raidLogsBtn")
	lastFrame = gra.raidLogsFrame
	gra.attendanceFrame:Hide()
	gra.announcementsFrame:Hide()
	gra.raidLogsFrame:Show()
end)

-----------------------------------------
-- top buttons
-----------------------------------------
-- track button, change text and color OnClick
local trackBtn = GRA:CreateButton(gra.mainFrame.header, "TRACK", nil, {60, 22}, "GRA_FONT_PIXEL")
trackBtn:SetPoint("LEFT", gra.mainFrame.header)
trackBtn:SetScript("OnClick", function()
	if gra.isTracking then
		GRA:StopTracking()
	else
		GRA:StartTracking()
	end
end)
trackBtn:Hide()

GRA:RegisterEvent("GRA_TRACK",  "Main_TrackStatus", function(raidDate)
	if raidDate then
		trackBtn:GetFontString():SetText("TRACKING...")
		trackBtn:SetBackdropColor(.5, 1, 0, .5)
		trackBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .7) end)
		trackBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(.5, 1, 0, .5) end)
	else
		trackBtn:GetFontString():SetText("TRACK")
		trackBtn:SetBackdropColor(.1, .1, .1, .7)
		trackBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(.5, 1, 0, .6) end)
		trackBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(.1, .1, .1, .7) end)
	end
end)

-- invite button
local inviteBtn = GRA:CreateButton(gra.mainFrame.header, "INVITE", "red-hover", {60, 22}, "GRA_FONT_PIXEL")
inviteBtn:SetPoint("LEFT", trackBtn, "RIGHT", -1, 0)
inviteBtn:Hide()

inviteBtn:SetScript("OnClick", function()
	ConvertToRaid()
	inviteBtn:RegisterEvent("GROUP_ROSTER_UPDATE")
	
	local onlineMembers = GRA:GetGuildOnlineRoster()
	for n, _ in pairs(_G[GRA_R_Roster]) do
		if onlineMembers[n] and not(UnitInParty(GRA:GetShortName(n)) or UnitInRaid(GRA:GetShortName(n))) then
			InviteUnit(n)
		end
	end
	wipe(onlineMembers)
end)

inviteBtn:SetScript("OnEvent", function()
	if not IsInRaid() then
		ConvertToRaid()
		inviteBtn:UnregisterEvent("GROUP_ROSTER_UPDATE")
	end
end)

GRA:RegisterEvent("GRA_PERMISSION", "MainFrame_CheckPermissions", function(isAdmin)
	if isAdmin then
		trackBtn:Show()
		inviteBtn:Show()
	end
end)

-----------------------------------------
-- script
-----------------------------------------
local function EnableMiniMode(f)
	if f then
		buttons["attendanceSheetBtn"]:Hide()
		buttons["raidLogsBtn"]:Hide()
		buttons["attendanceSheetBtn"]:Click()
		-- gra.mainFrame:SetHeight(420)
	else
		buttons["attendanceSheetBtn"]:Show()
		buttons["raidLogsBtn"]:Show()
		-- gra.mainFrame:SetHeight(400)
	end
end

GRA:RegisterEvent("GRA_MINI", "MiniMode", function(enabled)
	EnableMiniMode(enabled)
end)

gra.mainFrame:SetScript("OnShow", function(self)
	GRA:UpdateFont()
	EnableMiniMode(GRA_Variables["minimalMode"])
	LPP:PixelPerfectPoint(gra.mainFrame)

	if not IsInGuild() then
		GRA:CreateMask(gra.mainFrame, GRA_FORCE_ENGLISH and "You are not in a guild." or ERR_GUILD_PLAYER_NOT_IN_GUILD, {1, -1, -1, 1})
		return
	end

	if lastFrame then
		lastFrame:Show()
	else
		HighlightButton("attendanceSheetBtn")
		gra.attendanceFrame:Show()
	end
end)

-- OnHide: 
gra.mainFrame:SetScript("OnHide", function()
	
end)

local trial, count = nil, 0
-- Get MOTD
guildMOTDScroll:RegisterEvent("PLAYER_ENTERING_WORLD")
guildMOTDScroll:SetScript("OnEvent", function(self, event, arg)
	if event == "PLAYER_ENTERING_WORLD" then -- after login (in world)
		guildMOTDScroll:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if IsInGuild() then
			guildMOTDScroll:RegisterEvent("GUILD_ROSTER_UPDATE")
			guildMOTDScroll:RegisterEvent("GUILD_MOTD")
		end
	elseif event == "GUILD_ROSTER_UPDATE" then
		local motd = GetGuildRosterMOTD()
		GRA:Debug("|cff66CD00GUILD_ROSTER_UPDATE:|r " .. (motd=="" and "MOTD empty" or "MOTD non-empty"))
		if motd ~= "" then	-- ALWAYS can get MOTD (RIGHT AFTER LOGIN), but NOT sure after RELOAD
			MOTD = motd
			guildMOTDScroll:Show() -- get non-empty motd, show it
			guildMOTDScroll:UnregisterEvent("GUILD_ROSTER_UPDATE") -- already get non-empty motd, using GUILD_MOTD instead
			if trial then -- stop timer
				trial:Cancel()
				GRA:Debug("motd_trial cancelled")
			end
		elseif not trial then -- get empty motd (maybe not the true motd, try 10 more times)
			trial = C_Timer.NewTicker(10, function()
				securecall("GuildRoster") -- try again
				count = count + 1
				GRA:Debug("motd_trial: " .. count)
				-- trial._remainingIterations
			end, 10)
		else
			if count == 10 then
				-- tried 10 times, still get empty motd, then MOTD = ""
				guildMOTDScroll:UnregisterEvent("GUILD_ROSTER_UPDATE")
				MOTD = ""
				GRA:Debug("motd_trial ends, MOTD = \"\"")
			end
		end
	elseif event == "GUILD_MOTD" then
		guildMOTDScroll:UnregisterEvent("GUILD_ROSTER_UPDATE") -- got motd, GUILD_ROSTER_UPDATE is no longer need
		if trial then -- stop timer
			trial:Cancel()
			trial = nil
			GRA:Debug("trial:Cancel()")
		end
		
		GRA:Debug("|cff66CD00GUILD_MOTD:|r " .. arg)
		MOTD = arg
		
		-- re-show, whether motd == "" or not (judgement in guildMOTDScroll_OnShow)
		guildMOTDScroll:Hide()
		guildMOTDScroll:Show()
	end
end)

-----------------------------------------
-- resize
-----------------------------------------
function gra.mainFrame:Resize()
	gra.mainFrame:SetSize(unpack(gra.size.mainFrame))
	gra.mainFrame.header:SetHeight(gra.size.height+2)
	gra.mainFrame.header.closeBtn:SetSize(unpack(gra.size.button_close))
	for _, b in pairs(buttons) do
		b:SetSize(unpack(gra.size.button_main))
	end
	configBtn:SetSize(unpack(gra.size.button_main))
	trackBtn:SetSize(unpack(gra.size.button_track))
end