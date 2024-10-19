local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local newRaidLogFrame, datePicker, newBtn, cancelBtn, newLogDate

local function ValidateDate()
    if GRA_Logs[newLogDate] then -- exists
        newBtn:SetEnabled(false)
    else
        newBtn:SetEnabled(true)
    end
end

function GRA.NewRaidLog(parent)
    if not newRaidLogFrame then
        newRaidLogFrame = CreateFrame("Frame", "GRA_NewRaidLogFrame", parent, "BackdropTemplate")
        newRaidLogFrame:Hide()
        -- gra.newRaidLogFrame = newRaidLogFrame
        GRA.StylizeFrame(newRaidLogFrame)
        newRaidLogFrame:EnableMouse(true)
        newRaidLogFrame:SetFrameStrata("DIALOG")
        newRaidLogFrame:SetFrameLevel(1)
        newRaidLogFrame:SetSize(158, 20)

        datePicker = GRA.CreateDatePicker(newRaidLogFrame, 70, 20, function(d)
            newLogDate = tostring(d)
            ValidateDate()
        end)
        datePicker:SetPoint("LEFT")

        newBtn = GRA.CreateButton(newRaidLogFrame, L["Create"], "green", {45, 20})
        newBtn:SetPoint("LEFT", datePicker, "RIGHT", -1, 0)
        newBtn:SetScript("OnClick", function()
            GRA_Logs[newLogDate] = {["attendances"]={}, ["details"]={}, ["bosses"]={}}
            -- init startTime & endTime
            GRA_Logs[newLogDate]["startTime"] = select(2, GRA.GetRaidStartTime(newLogDate))
            GRA_Logs[newLogDate]["endTime"] = select(2, GRA.GetRaidEndTime(newLogDate))
            -- manually edit attendance later
            GRA.Fire("GRA_RAIDLOGS", newLogDate)
            newRaidLogFrame:Hide()
            GRA.Print(L["New raid log"] .. ": " .. date("%x", GRA.DateToSeconds(newLogDate)))
        end)

        cancelBtn = GRA.CreateButton(newRaidLogFrame, L["Cancel"], "red", {45, 20})
        cancelBtn:SetPoint("LEFT", newBtn, "RIGHT", -1, 0)
        cancelBtn:SetScript("OnClick", function() newRaidLogFrame:Hide() end)

        newRaidLogFrame:SetScript("OnHide", function(self) self:Hide() end)
        newRaidLogFrame:SetScript("OnShow", function(self)
            newLogDate = tostring(datePicker:GetDate())
            ValidateDate()
        end)
    end

    newRaidLogFrame:SetParent(parent)
    newRaidLogFrame:ClearAllPoints()
    newRaidLogFrame:SetPoint("BOTTOM", parent, "TOP", 0, 1)
    newRaidLogFrame:Show()
end