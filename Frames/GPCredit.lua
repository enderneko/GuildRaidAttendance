local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

-----------------------------------------
-- GP Credit Frame
-----------------------------------------
local gpReason, gpValue, gpLooter, gpDate, gpIndex, gpFloatBtn

local gpCreditFrame = GRA:CreateMovableFrame(L["GP Credit"], "GRA_GPCreditFrame", 200, 300, nil, true, "DIALOG")
gpCreditFrame:SetToplevel(true)
gra.gpCreditFrame = gpCreditFrame

local dateText = gpCreditFrame.header:CreateFontString(nil, "OVERLAY", "GRA_FONT_PIXEL")
dateText:SetPoint("LEFT", 10, 0)

local creditBtn = GRA:CreateButton(gpCreditFrame, L["Credit GP"], "red", {gpCreditFrame:GetWidth(), 20}, "GRA_FONT_SMALL")
creditBtn:SetPoint("BOTTOM")
creditBtn:SetScript("OnClick", function()
    -- change officer note
    if gpIndex then
        GRA:ModifyGP(gpDate, gpValue, gpReason, gpLooter, gpIndex)
    else
        GRA:CreditGP(gpDate, gpValue, gpReason, gpLooter)
    end
    gpCreditFrame:Hide()

    if gpFloatBtn then gpFloatBtn:Hide() end
end)

-- gp reason text
local gpReasonText = gpCreditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
gpReasonText:SetText("|cff80FF00" .. L["Reason"])
gpReasonText:SetPoint("TOPLEFT", 10, -10)

-- gp reason editbox
local gpReasonEditBox = GRA:CreateEditBox(gpCreditFrame, 160, 20)
gpReasonEditBox:SetPoint("TOPLEFT", gpReasonText, 10, -15)

-- Interface\FrameXML\ChatFrame.lua  ChatEdit_InsertLink
hooksecurefunc("ChatEdit_InsertLink", function(link)
    if gpReasonEditBox:HasFocus() then
        gpReasonEditBox:SetText(link)
        -- GRA_Config["test"] = link
    end
end)

-- gp value text
local gpValueText = gpCreditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
gpValueText:SetText("|cff80FF00" .. L["Value"])
gpValueText:SetPoint("TOPLEFT", gpReasonText, 0, -45)

local gpValueEditBox = GRA:CreateEditBox(gpCreditFrame, 160, 20)
gpValueEditBox:SetPoint("TOPLEFT", gpValueText, 10, -15)
gpValueEditBox:SetScript("OnEnterPressed", function()
    local ex = gpValueEditBox:GetText()
    if string.find(ex,"=") == 1 then
        ex = string.sub(ex, 2)
        local status, result = GRA:Calc(ex)
        if status then
            gpValueEditBox:SetText(result)
            gpValueEditBox:ClearFocus()
        else
            GRA:ShowNotificationString(gra.colors.firebrick.s .. result, "TOPLEFT", gpValueEditBox, "BOTTOMLEFT", 0, -3)
        end
    else
        gpValueEditBox:ClearFocus()
    end
end)

local looterText = gpCreditFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
looterText:SetText("|cff80FF00" .. L["Looter"])
looterText:SetPoint("TOPLEFT", gpValueText, 0, -45)

local looterDropDown = GRA:CreateScrollDropDownMenu(gpCreditFrame, 160, 100)
looterDropDown:SetPoint("TOPLEFT", looterText, 10, -15)

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

function GRA:ShowGPCreditFrame(d, link, gp, looter, attendees, index, floatBtn)
    gpDate = d
    gpIndex = index
    gpLooter = looter
    gpFloatBtn = floatBtn

    gpReasonEditBox:SetText(link and link or "")
    gpValueEditBox:SetText(gp and gp or "")

    -- sort gra.attendees k1:class k2:name
    local sorted = {}
    for k, v in pairs(attendees) do
        if GRA_Roster[k] then
            table.insert(sorted, {k, GRA_Roster[k]["class"]}) -- {"name", "class"}
        end
    end
    SortByClass(sorted)

    local items = {}
    for _, t in pairs(sorted) do
        local item = {
            ["text"] = GRA:GetClassColoredName(t[1], t[2]),
            ["onClick"] = function(text)
                gpLooter = t[1]
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

    if index then
        creditBtn:SetText(L["Modify GP"])
    else
        creditBtn:SetText(L["Credit GP"])
    end

    dateText:SetText(gra.colors.grey.s .. date("%x", GRA:DateToTime(d)))

    gpCreditFrame:Show()
end

-- check form
gpCreditFrame:SetScript("OnUpdate", function()
    gpReason = gpReasonEditBox:GetText()
    gpValue = tonumber(gpValueEditBox:GetText())
    -- gpLooter = looterDropDown.selected

    if gpValue and gpValue >= 0 and gpReason ~= "" and looterDropDown.selected and looterDropDown.selected ~= "" then
        creditBtn:SetEnabled(true)
    else
        creditBtn:SetEnabled(false)
    end
end)

local tooltip = GRA:CreateTooltip("GRA_GPCreditTooltip")
-- tooltip:SetPoint("TOPLEFT", gpCreditFrame, "TOPRIGHT", 5, 0)

gpCreditFrame:SetScript("OnHide", function()
    tooltip:Hide()
    -- or tooltip will not show
    gpReasonEditBox:SetText("")
end)

gpReasonEditBox:SetScript("OnTextSet", function()
    local text = gpReasonEditBox:GetText()
    if string.find(text, "|Hitem") then
        tooltip:SetOwner(gpCreditFrame, "ANCHOR_NONE")
        tooltip:SetHyperlink(text)
        tooltip:SetPoint("TOPLEFT", gpCreditFrame.header, "TOPRIGHT", 2, 0)
    else
        tooltip:Hide()
    end
end)

gpReasonEditBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        tooltip:Hide()
    end
end)

gpCreditFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(gpCreditFrame)
    -- gpReasonEditBox:SetText(GRA_Config["test"])
    gra.epAwardFrame:Hide()
    gra.penalizeFrame:Hide()
    -- gra.tooltip:SetText("233")
    -- gra.tooltip:AddLine("looterDropDown")
    -- gra.tooltip:SetPoint("TOPLEFT", gpCreditFrame, "TOPRIGHT", 5, 0)
    -- gra.tooltip:Show()
end)