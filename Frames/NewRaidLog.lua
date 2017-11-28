local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local newRaidLogFrame, datePicker, newBtn, cancelBtn, newLogDate

local function ValidateDate()
    if GRA_RaidLogs[newLogDate] then -- exists
        newBtn:SetEnabled(false)
    else
        newBtn:SetEnabled(true)
    end
end

function GRA:NewRaidLog(parent)
    if not newRaidLogFrame then
        newRaidLogFrame = CreateFrame("Frame", "GRA_NewRaidLogFrame", parent)
        newRaidLogFrame:Hide()
        -- gra.newRaidLogFrame = newRaidLogFrame
        GRA:StylizeFrame(newRaidLogFrame, nil, nil, {11, -11, -11, 11})
        newRaidLogFrame:EnableMouse(true)
        newRaidLogFrame:SetFrameStrata("DIALOG")
        newRaidLogFrame:SetFrameLevel(1)
        newRaidLogFrame:SetSize(158, 20)
        LPP:PixelPerfectScale(newRaidLogFrame)

        datePicker = GRA:CreateDatePicker(newRaidLogFrame, 70, 20, function(d)
            newLogDate = tostring(d)
            ValidateDate()
        end)
        datePicker:SetPoint("LEFT")

        newBtn = GRA:CreateButton(newRaidLogFrame, L["Create"], "green", {45, 20})
        newBtn:SetPoint("LEFT", datePicker, "RIGHT", -1, 0)
        newBtn:SetScript("OnClick", function()
            GRA_RaidLogs[newLogDate] = {["attendees"]={}, ["absentees"]={}, ["details"]={}}
            -- manually edit attendance later
            GRA:FireEvent("GRA_RAIDLOGS", newLogDate)
            newRaidLogFrame:Hide()
            GRA:Print(L["New raid log"] .. ": " .. date("%x", GRA:DateToTime(newLogDate)))
        end)
        
        cancelBtn = GRA:CreateButton(newRaidLogFrame, L["Cancel"], "red", {45, 20})
        cancelBtn:SetPoint("LEFT", newBtn, "RIGHT", -1, 0)
        cancelBtn:SetScript("OnClick", function() newRaidLogFrame:Hide() end)

        newRaidLogFrame:SetScript("OnHide", function(self) self:Hide() end)
        newRaidLogFrame:SetScript("OnShow", function(self) 
            newLogDate = tostring(datePicker:GetDate())
            ValidateDate()
        end)
    end

    newRaidLogFrame:SetPoint("BOTTOM", parent, "TOP", 0, 4)
    newRaidLogFrame:Show()
end