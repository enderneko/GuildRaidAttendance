local addonName, E =  ...
local GRA, gra = {}, {}
-- just to make sure they're the first 2
E[1] = GRA -- functions
E[2] = gra -- global variables, frames...

--@debug@
local debugMode = true
--@end-debug@
function GRA:Debug(arg, ...)
	if debugMode then
		if type(arg) == "string" or type(arg) == "number" then
			print(arg)
		elseif type(arg) == "function" then
			arg(...)
		elseif arg == nil then
			return true
		end
	end
end

function GRA:Print(msg)
	print("|cff80FF00[GRA]|r " .. msg)
end

-----------------------------------------
-- constants & variables
-----------------------------------------
local region = GetCVar("portal")
if region == "CN" then
	gra.RAID_LOCKOUTS_RESET = 5 -- Thursday
elseif region == "EU" then
	gra.RAID_LOCKOUTS_RESET = 4 -- Wednesday
else
	gra.RAID_LOCKOUTS_RESET = 3 -- Tuesday
end
-- gra.CLASS_ORDER = {"WARRIOR", "HUNTER", "SHAMAN", "MONK", "ROGUE", "MAGE", "DRUID", "DEATHKNIGHT", "PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"}
gra.CLASS_ORDER = {"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "HUNTER", "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}

-----------------------------------------
-- color
-----------------------------------------
gra.colors = {
	grey = {s = "|cCCB2B2B2"},
	yellow = {s = "|cFFFFD100"},
	firebrick = {s = "|cFFFF3030", t = {1, .19, .19, .7}},
	skyblue = {s = "|cFF00CCFF"},
	main = {s = "|cFF80FF00", t = {.5, 1, 0, 1}},
}

-----------------------------------------
-- size
-----------------------------------------
gra.sizes = {
	normal = {
		fontSize = 11,
		height = 20,
		-- button_main = {100, 20},
		-- button_track = {60, 22},
		-- button_close = {16, 16},
		grid_name = 75,
		grid_others = 45,
		grid_dates = 30,
		mainFrame = {620, 400},
	},
	large = {
		fontSize = 13,
		height = 24,
		button_main = {120, 24},
		button_track = {80, 26},
		button_close = {20, 20},
		button_raidLogs = {84, 24},
		button_attendanceEditor = {122, 22},
		button_datePicker = {84, 24},
		button_datePicker_inner = {34, 24},
		button_datePicker_outter = {232, 183},
		button_refresh = {66, 24},
		grid_name = 90,
		grid_others = 54,
		grid_dates = 36,
		mainFrame = {770, 497},
		attendanceFrame = {-34, 422}, -- point, height
		raidLogsFrame = {-34, 429}, -- point, height
		raidLogsFrame_list = {-20, 28, 87}, -- top, bottom, width
	},
	extraLarge = {
		fontSize = 15,
		height = 28,
	}
}
gra.size = gra.sizes.normal

-----------------------------------------
-- font
-----------------------------------------
GRA_FORCE_ENGLISH = false
-----------------------------------------
local font = "Interface\\AddOns\\GuildRaidAttendance\\Media\\Fonts\\calibrib.ttf"
local useGameFont = false
if GetLocale() == "zhCN" or GetLocale() == "zhTW" or GetLocale() == "koKR" then
	useGameFont = true
end

-- tooltip
local font_tooltip_normal = CreateFont("GRA_FONT_TOOLTIP_NORMAL")
font_tooltip_normal:SetFont(GameTooltipText:GetFont(), 13)
font_tooltip_normal:SetTextColor(1, 1, 1, 1)
font_tooltip_normal:SetShadowColor(0, 0, 0)
font_tooltip_normal:SetShadowOffset(1, -1)
font_tooltip_normal:SetJustifyH("LEFT")
font_tooltip_normal:SetJustifyV("MIDDLE")

local font_tooltip_small = CreateFont("GRA_FONT_TOOLTIP_SMALL")
font_tooltip_small:SetFont(GameTooltipText:GetFont(), 11)
font_tooltip_small:SetTextColor(1, 1, 1, 1)
font_tooltip_small:SetShadowColor(0, 0, 0)
font_tooltip_small:SetShadowOffset(1, -1)
font_tooltip_small:SetJustifyH("LEFT")
font_tooltip_small:SetJustifyV("MIDDLE")

-- text
local font_text = CreateFont("GRA_FONT_TEXT")
font_text:SetFont(useGameFont and GameFontNormal:GetFont() or font, 11)
font_text:SetTextColor(1, 1, 1, 1)
font_text:SetShadowColor(0, 0, 0)
font_text:SetShadowOffset(1, -1)
font_text:SetJustifyH("LEFT")

local font_text2 = CreateFont("GRA_FONT_TEXT2")
font_text2:SetFont(useGameFont and GameFontNormal:GetFont() or font, 12)
font_text2:SetTextColor(1, 1, 1, 1)
font_text2:SetShadowColor(0, 0, 0)
font_text2:SetShadowOffset(1, -1)
font_text2:SetJustifyH("LEFT")

local font_text3 = CreateFont("GRA_FONT_TEXT3")
font_text3:SetFont(useGameFont and GameFontNormal:GetFont() or font, 13)
font_text3:SetTextColor(.5, .9, 0, 1)
font_text3:SetShadowColor(0, 0, 0)
font_text3:SetShadowOffset(1, -1)
font_text3:SetJustifyH("LEFT")

-- small button
local font_small = CreateFont("GRA_FONT_SMALL")
font_small:SetFont((useGameFont and not GRA_FORCE_ENGLISH) and GameFontNormal:GetFont() or font, 11)
font_small:SetTextColor(1, 1, 1, 1)
font_small:SetShadowColor(0, 0, 0)
font_small:SetShadowOffset(1, -1)
font_small:SetJustifyH("CENTER")

local font_small_disabled = CreateFont("GRA_FONT_SMALL_DISABLED")
font_small_disabled:SetFont((useGameFont and not GRA_FORCE_ENGLISH) and GameFontNormal:GetFont() or font, 11)
font_small_disabled:SetTextColor(.4, .4, .4, 1)
font_small_disabled:SetShadowColor(0, 0, 0)
font_small_disabled:SetShadowOffset(1, -1)
font_small_disabled:SetJustifyH("CENTER")

-- header
local font_normal = CreateFont("GRA_FONT_NORMAL")
font_normal:SetFont((useGameFont and not GRA_FORCE_ENGLISH) and GameFontNormal:GetFont() or font, 13)
font_normal:SetTextColor(.5, 1, 0, 1)
font_normal:SetShadowColor(0, 0, 0)
font_normal:SetShadowOffset(1, -1)
font_normal:SetJustifyH("CENTER")

local font_title = CreateFont("GRA_FONT_TITLE")
font_title:SetFont(font, 13)
font_title:SetTextColor(.5, 1, 0, 1)
font_title:SetShadowColor(0, 0, 0)
font_title:SetShadowOffset(1, -1)
font_title:SetJustifyH("CENTER")

-- large button
local font_large_button = CreateFont("GRA_FONT_BUTTON")
font_large_button:SetFont(font, 15)
font_large_button:SetTextColor(1, 1, 1, 1)
font_large_button:SetShadowColor(0, 0, 0)
font_large_button:SetShadowOffset(1, -1)
font_large_button:SetJustifyH("CENTER")

-- grid text
local font_grid = CreateFont("GRA_FONT_GRID")
font_grid:SetFont(font, 11)
font_grid:SetTextColor(1, 1, 1, 1)
font_grid:SetShadowColor(0, 0, 0)
font_grid:SetShadowOffset(1, -1)
font_grid:SetJustifyH("CENTER")

local font_pixel = CreateFont("GRA_FONT_PIXEL")
font_pixel:SetFont("Interface\\AddOns\\GuildRaidAttendance\\Media\\Fonts\\SWF!T___.TTF", 6, "MONOCHROME")
font_pixel:SetTextColor(1, 1, 1, 1)
font_pixel:SetShadowColor(0, 0, 0)
font_pixel:SetShadowOffset(1, -1)
font_pixel:SetJustifyH("CENTER")

-- loot frame ilvl
-- local font_loot = CreateFont("GRA_FONT_LOOT")
-- font_loot:SetFont(font, 10, "OUTLINE")
-- font_loot:SetJustifyH("CENTER")

-----------------------------------------
-- LDB
-----------------------------------------
local icon = LibStub("LibDBIcon-1.0")
local graLDB = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRaidAttendance", {
	type = "data source",
	text = "GuildRaidAttendance",
	icon = "Interface\\AddOns\\GuildRaidAttendance\\Media\\minimap",
	OnClick = function()
		if gra.mainFrame:IsVisible() then
			gra.mainFrame:Hide()
		else
			gra.mainFrame:Show()
		end
	end,
})

-----------------------------------------
-- event
-----------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

-- initialize!
function frame:ADDON_LOADED(arg1)
	if arg1 == addonName then
		frame:UnregisterEvent("ADDON_LOADED")
		if type(GRA_RaidLogs) ~= "table" then GRA_RaidLogs = {} end
		if type(GRA_Roster) ~= "table" then GRA_Roster = {} end
		if type(GRA_Config) ~= "table" then GRA_Config = {} end

		if type(GRA_Config["firstRun"]) ~= "boolean" then GRA_Config["firstRun"] = true end

		-- size
		if type(GRA_Config["size"]) ~= "string" then GRA_Config["size"] = "normal" end
		if GRA_Config["size"] ~= "normal" then
			gra.size = gra.sizes[GRA_Config["size"]]
			for name, f in pairs(gra) do
				if gra.size[name] then
					f:Resize()
					GRA:Debug("Resized " .. name)
				end
			end
		end

		if type(GRA_Config["raidInfo"]) ~= "table" then
			GRA_Config["raidInfo"] = {
				["EPGP"] = {100, 0, 10},
				["days"] = {gra.RAID_LOCKOUTS_RESET},
				["startTime"] = "19:30",
			}
		end

		-- previous version, TODO: delete
		if type(GRA_Config["raidInfo"]["startTime"]) ~= "string" then
			GRA_Config["raidInfo"]["startTime"] = GRA_Config["raidInfo"]["deadline"]
			GRA_Config["raidInfo"] = GRA:RemoveElementsByKeys(GRA_Config["raidInfo"], {"deadline"})
		end

		-- disable epgp by default
		if type(GRA_Config["useEPGP"]) ~= "boolean" then GRA_Config["useEPGP"] = false end
		
		-- disable minimal mode by default
		if type(GRA_Config["minimalMode"]) ~= "boolean" then GRA_Config["minimalMode"] = false end
		
		-- sheet columns
		if type(GRA_Config["columns"]) ~= "table" then
			GRA_Config["columns"] = {
				["AR_30"] = false,
				["AR_60"] = false,
				["AR_90"] = false,
				["AR_Lifetime"] = false,
			}
		end

		-- sort
		if type(GRA_Config["sortKey"]) ~= "string" then GRA_Config["sortKey"] = "name" end
		-- class filter
		if type(GRA_Config["classFilter"]) ~= "table" then GRA_Config["classFilter"] = {["WARRIOR"]=true, ["HUNTER"]=true, ["SHAMAN"]=true, ["MONK"]=true, ["ROGUE"]=true, ["MAGE"]=true, ["DRUID"]=true, ["DEATHKNIGHT"]=true, ["PALADIN"]=true, ["WARLOCK"]=true, ["PRIEST"]=true, ["DEMONHUNTER"]=true} end

		if type(GRA_Config["startDate"]) ~= "string" then GRA_Config["startDate"] = GRA:GetLockoutsResetDate() end -- this lockouts reset day
		-- GRA:Debug("startDate: " .. GRA_Config["startDate"])

		-- loot distr tool
		if type(GRA_Config["enableLootDistr"]) ~= "boolean" then GRA_Config["enableLootDistr"] = false end
		-- reply buttons
		if type(GRA_Config["replies"]) ~= "table" then
			GRA_Config["replies"] = {"configure", "your", "buttons"}
		end
		-- quick notes
		if type(GRA_Config["notes"]) ~= "table" then
			GRA_Config["notes"] = {"BiS", "4p", "2p"}
		end

		if type(GRA_Config["minimap"]) ~= "table" then GRA_Config["minimap"] = {["hide"] = false} end
		icon:Register("GuildRaidAttendance", graLDB, GRA_Config["minimap"])
		
		gra.version = GetAddOnMetadata(addonName, "version")

		-- update font & fontsize
		if GRA_Config["useGameFont"] then
			GRA_FONT_SMALL:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
			GRA_FONT_SMALL_DISABLED:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
			GRA_FONT_NORMAL:SetFont(GameFontNormal:GetFont(), gra.size.fontSize+2)
			GRA_FONT_TEXT:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
			GRA_FONT_TEXT2:SetFont(GameFontNormal:GetFont(), gra.size.fontSize+1)
			GRA_FONT_TEXT3:SetFont(GameFontNormal:GetFont(), gra.size.fontSize+2)
			GRA_FONT_TITLE:SetFont(GameFontNormal:GetFont(), gra.size.fontSize+2)
			GRA_FONT_GRID:SetFont(GameFontNormal:GetFont(), gra.size.fontSize)
		else
			GRA_FONT_TOOLTIP_NORMAL:SetFont(GRA_FONT_TOOLTIP_NORMAL:GetFont(), gra.size.fontSize+2)
			GRA_FONT_TOOLTIP_SMALL:SetFont(GRA_FONT_TOOLTIP_SMALL:GetFont(), gra.size.fontSize)
			GRA_FONT_SMALL:SetFont(GRA_FONT_SMALL:GetFont(), gra.size.fontSize)
			GRA_FONT_SMALL_DISABLED:SetFont(GRA_FONT_SMALL_DISABLED:GetFont(), gra.size.fontSize)
			GRA_FONT_NORMAL:SetFont(GRA_FONT_NORMAL:GetFont(), gra.size.fontSize+2)
			GRA_FONT_TEXT:SetFont(GRA_FONT_TEXT:GetFont(), gra.size.fontSize)
			GRA_FONT_TEXT2:SetFont(GRA_FONT_TEXT2:GetFont(), gra.size.fontSize+1)
			GRA_FONT_TEXT3:SetFont(GRA_FONT_TEXT3:GetFont(), gra.size.fontSize+2)
			GRA_FONT_TITLE:SetFont(GRA_FONT_TITLE:GetFont(), gra.size.fontSize+2)
			GRA_FONT_BUTTON:SetFont(GRA_FONT_BUTTON:GetFont(), gra.size.fontSize+4)
			GRA_FONT_GRID:SetFont(GRA_FONT_GRID:GetFont(), gra.size.fontSize)
			GRA_FONT_PIXEL:SetFont(GRA_FONT_PIXEL:GetFont(), gra.size.fontSize-5, "MONOCHROME")
		end
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

-----------------------------------------
-- slash command
-----------------------------------------
local num = 1

SLASH_GUILDRAIDATTENDANCE1 = "/gra"
function SlashCmdList.GUILDRAIDATTENDANCE(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "" then
		gra.mainFrame:Show()
	elseif command == "table" then
		texplore(E)
	elseif command == "anchor" then
		GRA:ShowHidePopupsAnchor()
	elseif command == "exportlocale" then
		local f = GRA:CreateFrame("Export Locale", nil, UIParent, 300, 400)
		f:SetPoint("CENTER")
		
		local eb = CreateFrame("EditBox", nil, f)
		GRA:StylizeFrame(eb, {.1, .1, .1, .9})
		eb:SetFontObject("GRA_FONT_TEXT")
		eb:SetMultiLine(true)
		eb:SetMaxLetters(0)
		eb:SetJustifyH("LEFT")
		eb:SetJustifyV("TOP")
		eb:SetTextInsets(5, 30, 0, 0)
		eb:SetAutoFocus(false)
		eb:SetSize(300, 400)

		local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
		scroll:SetPoint("TOPLEFT", 5, -5)
		scroll:SetPoint("BOTTOMRIGHT", -25, 5)
		scroll:SetScrollChild(eb)

		local text = ""
		for k, v in pairs(E.L) do
			text = text .. "L[\"" .. k .. "\"] = \"" .. v .. "\"\n"
		end
		eb:SetText(text)
		f:Show()
	elseif command == "minimap" then
		GRA_Config.minimap.hide = not GRA_Config.minimap.hide
		if GRA_Config.minimap.hide then
			icon:Hide("GuildRaidAttendance")
		else
			icon:Show("GuildRaidAttendance")
		end
	elseif command == "resetposition" then
		gra.mainFrame:ClearAllPoints()
		gra.mainFrame:SetPoint("CENTER")
		gra.mainFrame:Show()
	elseif command == "loot" then
		gra.distributionFrame:Show()
	elseif command == "test" then
		if rest == "receivePopup" then
			local class = select(2, UnitClass("player"))
			local name = GRA:GetClassColoredName(strjoin("-",UnitFullName("player")), class)
			local p = GRA:CreateDataTransferReceivePopup(format("Receiving roster data from %s", name), 300)
			p:Test(true)
		elseif rest == "sendPopup" then
			local p = GRA:CreateDataTransferSendPopup("player" .. num, 100)
			p:Test(true)
			num = num + 1
		elseif rest == "popup" then
			GRA:CreatePopup(time())
		end
	elseif command == "testL" then
		GRA_Config["size"] = "large"
	elseif command == "testN" then
		GRA_Config["size"] = "normal"
	end
end