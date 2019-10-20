local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- Credit Frame
-----------------------------------------
local cReason, cValue, cLooter, cNote, cDate, cIndex, cFloatBtn

local creditFrame = GRA:CreateMovableFrame("XX Credit", "GRA_CreditFrame", 200, 300, nil, "DIALOG")
creditFrame:SetToplevel(true)
gra.creditFrame = creditFrame

local dateText = creditFrame.header:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
dateText:SetPoint("LEFT", 10, 0)

local creditBtn = GRA:CreateButton(creditFrame, "Credit XX", "red", {creditFrame:GetWidth(), 20}, "GRA_FONT_SMALL")
creditBtn:SetPoint("BOTTOM")
creditBtn:SetScript("OnClick", function()
    -- change officer note
    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        if cIndex then
            GRA:ModifyGP(cDate, cValue, cReason, cLooter, cNote, cIndex)
        else
            GRA:CreditGP(cDate, cValue, cReason, cLooter, cNote)
        end
    else -- dkp
        if cIndex then
            GRA:ModifyDKP_C(cDate, cValue, cReason, cLooter, cNote, cIndex)
        else
            GRA:CreditDKP(cDate, cValue, cReason, cLooter, cNote)
        end
    end
    creditFrame:Hide()

    if cFloatBtn then cFloatBtn:Hide() end
end)

-- reason text
local cReasonText = creditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
cReasonText:SetText("|cff80FF00" .. L["Reason"])
cReasonText:SetPoint("TOPLEFT", 10, -10)

-- reason editbox
local cReasonEditBox = GRA:CreateEditBox(creditFrame, 160, 20)
cReasonEditBox:SetPoint("TOPLEFT", cReasonText, 10, -15)

-- Interface\FrameXML\ChatFrame.lua  ChatEdit_InsertLink
hooksecurefunc("ChatEdit_InsertLink", function(link)
    if cReasonEditBox:HasFocus() then
        cReasonEditBox:SetText(link)
        -- _G[GRA_R_Config]["test"] = link
    end
end)

-- value text
local cValueText = creditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
cValueText:SetText("|cff80FF00" .. L["Value"])
cValueText:SetPoint("TOPLEFT", cReasonText, 0, -45)

local cValueEditBox = GRA:CreateEditBox(creditFrame, 160, 20)
cValueEditBox:SetPoint("TOPLEFT", cValueText, 10, -15)
cValueEditBox:SetScript("OnEnterPressed", function()
    local ex = cValueEditBox:GetText()
    if string.find(ex,"=") == 1 then
        ex = string.sub(ex, 2)
        local status, result = GRA:Calc(ex)
        if status then
            cValueEditBox:SetText(result)
            cValueEditBox:ClearFocus()
        else
            GRA:ShowNotificationString(creditFrame, gra.colors.firebrick.s .. result, "TOPLEFT", cValueEditBox, "BOTTOMLEFT", 0, -3)
        end
    else
        cValueEditBox:ClearFocus()
    end
end)

-- looter text
local looterText = creditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
looterText:SetText("|cff80FF00" .. L["Looter"])
looterText:SetPoint("TOPLEFT", cValueText, 0, -45)

local looterDropDown = GRA:CreateScrollDropDownMenu(creditFrame, 160, 100)
looterDropDown:SetPoint("TOPLEFT", looterText, 10, -15)

-- note text
local cNoteText = creditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
cNoteText:SetText("|cff80FF00" .. L["Note"])
cNoteText:SetPoint("TOPLEFT", looterText, 0, -45)

-- note editbox
local cNoteEditBox = GRA:CreateEditBox(creditFrame, 160, 20)
cNoteEditBox:SetPoint("TOPLEFT", cNoteText, 10, -15)

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

function GRA:ShowCreditFrame(d, link, value, looter, note, index, floatBtn)
    cDate = d
    cIndex = index
    cLooter = looter
    cNote = note
    cFloatBtn = floatBtn

    cReasonEditBox:SetText(link or "")
    cValueEditBox:SetText(value or "")
    cNoteEditBox:SetText(note or "")

    local attendees = GRA:GetAttendeesAndAbsentees(d)
    -- sort gra.attendees k1:class k2:name
    local sorted = {}
    for _, n in pairs(attendees) do
        if _G[GRA_R_Roster][n] then
            table.insert(sorted, {n, _G[GRA_R_Roster][n]["class"]}) -- {"name", "class"}
        end
    end
    SortByClass(sorted)

    local items = {}
    for _, t in pairs(sorted) do
        local item = {
            ["text"] = GRA:GetClassColoredName(t[1], t[2]),
            ["onClick"] = function(text)
                cLooter = t[1]
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

    local system
    if _G[GRA_R_Config]["raidInfo"]["system"] == "EPGP" then
        system = "GP"
    else
        system = "DKP"
    end
    creditFrame.header.text:SetText(L[system .. " Credit"])

    if index then
        creditBtn:SetText(L["Modify " .. system])
    else
        creditBtn:SetText(L["Credit " .. system])
    end

    dateText:SetText(gra.colors.grey.s .. date("%x", GRA:DateToSeconds(d)))

    creditFrame:Show()
end

-- check form
creditFrame:SetScript("OnUpdate", function()
    cReason = cReasonEditBox:GetText()
    cValue = tonumber(cValueEditBox:GetText())
    -- cLooter = looterDropDown.selected
    cNote = cNoteEditBox:GetText()

    if cValue and cValue >= 0 and cReason ~= "" and looterDropDown.selected and looterDropDown.selected ~= "" then
        creditBtn:SetEnabled(true)
    else
        creditBtn:SetEnabled(false)
    end
end)

local tooltip = GRA:CreateTooltip("GRA_CreditTooltip")
-- tooltip:SetPoint("TOPLEFT", creditFrame, "TOPRIGHT", 5, 0)

creditFrame:SetScript("OnHide", function()
    tooltip:Hide()
    -- or tooltip will not show
    cReasonEditBox:SetText("")
end)

cReasonEditBox:SetScript("OnTextSet", function()
    local text = cReasonEditBox:GetText()
    if string.find(text, "|Hitem") then
        tooltip:SetOwner(creditFrame, "ANCHOR_NONE")
        tooltip:SetHyperlink(text)
        tooltip:SetPoint("TOPLEFT", creditFrame.header, "TOPRIGHT", 2, 0)
    else
        tooltip:Hide()
    end
end)

cReasonEditBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        tooltip:Hide()
    end
end)

creditFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(creditFrame)
    gra.awardFrame:Hide()
    gra.penalizeFrame:Hide()
end)