local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- Record Loot
-----------------------------------------
local rlItem, rlNote, rlLooter, rlDate, rlIndex, rlFloatBtn

local recordLootFrame = GRA:CreateMovableFrame(L["Record Loot"], "GRA_RecordLootFrame", 200, 300, nil, "DIALOG")
recordLootFrame:SetToplevel(true)
gra.recordLootFrame = recordLootFrame

local recordBtn = GRA:CreateButton(recordLootFrame, L["Record it!"], "red", {recordLootFrame:GetWidth(), 20}, "GRA_FONT_SMALL")
recordBtn:SetPoint("BOTTOM")
recordBtn:SetScript("OnClick", function()
    local lootTable = {"GP", 0, rlItem, rlLooter, rlNote}
    if rlIndex then -- modify
        _G[GRA_R_RaidLogs][rlDate]["details"][rlIndex] = lootTable
        GRA:FireEvent("GRA_ENTRY_MODIFY", rlDate)
    else -- create new
        table.insert(_G[GRA_R_RaidLogs][rlDate]["details"], lootTable)
        GRA:FireEvent("GRA_ENTRY", rlDate)
    end
    recordLootFrame:Hide()

    if rlFloatBtn then rlFloatBtn:Hide() end
end)

-- loot text
local lootText = recordLootFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
lootText:SetText("|cff80FF00" .. L["Item"])
lootText:SetPoint("TOPLEFT", 10, -10)

-- loot editbox
local lootEditBox = GRA:CreateEditBox(recordLootFrame, 160, 20)
lootEditBox:SetPoint("TOPLEFT", lootText, 10, -15)

-- Interface\FrameXML\ChatFrame.lua  ChatEdit_InsertLink
hooksecurefunc("ChatEdit_InsertLink", function(link)
    if lootEditBox:HasFocus() then
        lootEditBox:SetText(link)
    end
end)

-- note text
local noteText = recordLootFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
noteText:SetText("|cff80FF00" .. L["Note"])
noteText:SetPoint("TOPLEFT", lootText, 0, -45)

local noteEditBox = GRA:CreateEditBox(recordLootFrame, 160, 20)
noteEditBox:SetPoint("TOPLEFT", noteText, 10, -15)

local looterText = recordLootFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
looterText:SetText("|cff80FF00" .. L["Looter"])
looterText:SetPoint("TOPLEFT", noteText, 0, -45)

local looterDropDown = GRA:CreateScrollDropDownMenu(recordLootFrame, 160, 100)
looterDropDown:SetPoint("TOPLEFT", looterText, 10, -15)

local dateText = recordLootFrame.header:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
dateText:SetPoint("LEFT", 10, 0)

-- test ------------------------------------------
-- local attendees = {}
-- local classes = {"WARRIOR", "HUNTER", "SHAMAN", "MONK", "ROGUE", "MAGE", "DRUID", "DEATHKNIGHT", "PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"}
-- for i = 1, random(15, 30) do
--     local name = ""
--     for j = 1, random(3, 12) do
--         name = name .. string.char(random(97, 122))
--     end
--     attendees[name] = {"", classes[random(1, 12)]}
-- end
--------------------------------------------------

local function SortByClass(t)
	table.sort(t, function(a, b)
		if a[2] ~= b[2] then
			return GRA:GetIndex(gra.CLASS_ORDER, a[2]) < GRA:GetIndex(gra.CLASS_ORDER, b[2])
		else
            return a[1] < b[1]
		end
	end)
end

function GRA:ShowRecordLootFrame(d, link, note, looter, attendees, index, floatBtn)
    rlDate = d
    rlIndex = index
    if type(looter) ~= "string" then looter = nil end
    rlLooter = looter
    rlFloatBtn = floatBtn

    lootEditBox:SetText(link or "")
    noteEditBox:SetText(note or "")

    -- sort gra.attendees k1:class k2:name
    local sorted = {}
    for k, v in pairs(attendees) do
        if _G[GRA_R_Roster][k] then
            table.insert(sorted, {k, _G[GRA_R_Roster][k]["class"]}) -- {"name", "class"}
        end
    end
    SortByClass(sorted)

    local items = {}
    for _, t in pairs(sorted) do
        local item = {
            ["text"] = GRA:GetClassColoredName(t[1], t[2]),
            ["onClick"] = function(text)
                rlLooter = t[1]
            end,
        }
        table.insert(items, item)
    end

    looterDropDown:SetItems(items)
    if looter then
        looterDropDown:SetSelected(GRA:GetClassColoredName(looter))
    else
        looterDropDown:SetSelected("")
    end

    dateText:SetText(gra.colors.grey.s .. date("%x", GRA:DateToTime(d)))

    recordLootFrame:Show()
end

-- check form
recordLootFrame:SetScript("OnUpdate", function()
    rlItem = lootEditBox:GetText()
    rlNote = noteEditBox:GetText()
    -- rlLooter = looterDropDown.selected

    if rlItem ~= "" and looterDropDown.selected and looterDropDown.selected ~= "" then
        recordBtn:SetEnabled(true)
    else
        recordBtn:SetEnabled(false)
    end
end)

recordLootFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(recordLootFrame)
end)

local tooltip = GRA:CreateTooltip("GRA_RecordLootTooltip")

recordLootFrame:SetScript("OnHide", function()
    tooltip:Hide()
    -- or tooltip will not show
    lootEditBox:SetText("")
end)

lootEditBox:SetScript("OnTextSet", function()
    local text = lootEditBox:GetText()
    if string.find(text, "|Hitem") then
        tooltip:SetOwner(recordLootFrame, "ANCHOR_NONE")
        tooltip:SetHyperlink(text)
        tooltip:SetPoint("TOPLEFT", recordLootFrame.header, "TOPRIGHT", 2, 0)
    else
        tooltip:Hide()
    end
end)

lootEditBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        tooltip:Hide()
    end
end)