local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L

local Compresser = LibStub:GetLibrary("LibCompress")
local Encoder = Compresser:GetAddonEncodeTable()
local Serializer = LibStub:GetLibrary("AceSerializer-3.0")
local Comm = LibStub:GetLibrary("AceComm-3.0")

-- from WeakAuras
local function TableToString(inTable)
    local serialized = Serializer:Serialize(inTable)
    local compressed = Compresser:CompressHuffman(serialized)
    return Encoder:Encode(compressed)
end

local function StringToTable(inString)
    local decoded = Encoder:Decode(inString)
    local decompressed, errorMsg = Compresser:Decompress(decoded)
    if not(decompressed) then
        GRA:Debug("Error decompressing: " .. errorMsg)
        return nil
    end
    local success, deserialized = Serializer:Deserialize(decompressed)
    if not(success) then
        GRA:Debug("Error deserializing: " .. deserialized)
        return nil
    end
    return deserialized
end

-----------------------------------------
-- send roster
-----------------------------------------
local receiveRosterPopup
-- send roster data and raidInfo to a raid member
-- _G[GRA_R_Roster], _G[GRA_R_Config]["raidInfo"]
function GRA:SendRoster(sheetTable, targetName)
    local encoded = TableToString(sheetTable)
    -- send roster
    Comm:SendCommMessage("GRA_R_SEND", encoded, "WHISPER", targetName, "BULK", function(arg, done, total)
        local popup = GRA:CreateDataTransferSendPopup(targetName, total)
        popup:SetValue(done)
        -- send progress
        Comm:SendCommMessage("GRA_R_PROG", done.."|"..total, "WHISPER", targetName, "ALERT")
    end)
end

function GRA:SendRosterToRaid()
    Comm:SendCommMessage("GRA_R_ASK", "", "RAID", nil, "BULK")
end

-- whether to revieve
Comm:RegisterComm("GRA_R_ASK", function(prefix, message, channel, sender)
    if sender == UnitName("player") then return end
    GRA:CreateStaticPopup(L["Receive Raid Roster"], L["Receive roster data from %s?"]:format(GRA:GetClassColoredName(sender, select(2, UnitClass(sender)))),
    function()
        -- on accept, members send a message to RL
        Comm:SendCommMessage("GRA_R_ACCEPT", "", "WHISPER", sender, "BULK")

        -- if receving then hide it immediately
        if receiveRosterPopup then receiveRosterPopup:Hide() end
        -- init
        receiveRosterPopup = nil
    end)
end)

-- send roster to player who accepted
Comm:RegisterComm("GRA_R_ACCEPT", function(prefix, message, channel, sender)
    GRA:SendRoster({_G[GRA_R_Roster], _G[GRA_R_Config]["raidInfo"], _G[GRA_R_Config]["useEPGP"]}, sender)
end)

-- recieve roster finished
Comm:RegisterComm("GRA_R_SEND", function(prefix, message, channel, sender)
    local t = StringToTable(message)
    _G[GRA_R_Roster] = t[1]
    _G[GRA_R_Config]["raidInfo"] = t[2]
    _G[GRA_R_Config]["useEPGP"] = t[3]

    GRA:FireEvent("GRA_R_DONE")
end)

-- recieve roster progress
Comm:RegisterComm("GRA_R_PROG", function(prefix, message, channel, sender)
    local done, total = strsplit("|", message)
    done, total = tonumber(done), tonumber(total)
    if not receiveRosterPopup then
        receiveRosterPopup = GRA:CreateDataTransferReceivePopup(L["Receiving roster data from %s"]:format(GRA:GetClassColoredName(sender, select(2, UnitClass(sender)))), total)
    end
    -- progress bar
    receiveRosterPopup:SetValue(done)
    -- GRA:Debug("GRA_R_PROG: " .. message)
end)

-----------------------------------------
-- send logs
-----------------------------------------
local receiveLogsPopup
local dates
function GRA:SendLogs(logsTable, targetName)
    local encoded = TableToString(logsTable)
    -- send logs
    Comm:SendCommMessage("GRA_LOGS_SEND", encoded, "WHISPER", targetName, "BULK", function(arg, done, total)
        local popup = GRA:CreateDataTransferSendPopup(targetName, total)
        popup:SetValue(done)
        -- send progress
        Comm:SendCommMessage("GRA_LOGS_PROG", done.."|"..total, "WHISPER", targetName, "ALERT")
    end)
end

function GRA:SendLogsToRaid(selectedDates)
    dates = selectedDates
    local encoded = TableToString(selectedDates)
    Comm:SendCommMessage("GRA_LOGS_ASK", encoded, "RAID", nil, "BULK")
end

-- whether to revieve
Comm:RegisterComm("GRA_LOGS_ASK", function(prefix, message, channel, sender)
    if sender == UnitName("player") or _G[GRA_R_Config]["minimalMode"] then return end
    dates = StringToTable(message)
    GRA:CreateStaticPopup(L["Receive Raid Logs"], L["Receive raid logs data from %s?"]:format(GRA:GetClassColoredName(sender, select(2, UnitClass(sender)))) .. "\n" ..
    GRA:TableToString(dates), -- TODO: text format
    function()
        -- on accept, members send a message to RL
        Comm:SendCommMessage("GRA_LOGS_ACCEPT", "", "WHISPER", sender, "BULK")

        -- if receving then hide it immediately
        if receiveLogsPopup then receiveLogsPopup:Hide() end
        -- init
        receiveLogsPopup = nil
    end)
end)

-- send logs data to player who accepted
Comm:RegisterComm("GRA_LOGS_ACCEPT", function(prefix, message, channel, sender)
    local t = {}
    for _, d in pairs(dates) do
        t[d] = _G[GRA_R_RaidLogs][d]
    end
    -- TODO: send AR only, not all _G[GRA_R_Roster]
    GRA:SendLogs({t, _G[GRA_R_Roster]}, sender)
end)

-- "recieve logs data" finished
Comm:RegisterComm("GRA_LOGS_SEND", function(prefix, message, channel, sender)
    local t = StringToTable(message)
    for d, tbl in pairs(t[1]) do
        _G[GRA_R_RaidLogs][d] = tbl
    end
    -- TODO: send AR only, not all _G[GRA_R_Roster]
    _G[GRA_R_Roster] = t[2]
    -- tell addon to show logs
    GRA:FireEvent("GRA_LOGS_DONE", GRA:Getn(t[1]), dates)
end)

-- "recieve logs data" progress
Comm:RegisterComm("GRA_LOGS_PROG", function(prefix, message, channel, sender)
    local done, total = strsplit("|", message)
    done, total = tonumber(done), tonumber(total)
    if not receiveLogsPopup then
        -- UnitClass(name) is available for raid/party members
        receiveLogsPopup = GRA:CreateDataTransferReceivePopup(L["Receiving raid logs data from %s"]:format(GRA:GetClassColoredName(sender, select(2, UnitClass(sender)))), total)
    end
    -- progress bar
    receiveLogsPopup:SetValue(done)
    -- GRA:Debug("GRA_LOGS_PROG: " .. message)
end)


-----------------------------------------
-- Check Version
-----------------------------------------
local f = CreateFrame("Frame")
local versionChecked = false
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    f:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if IsInGuild() then
        Comm:SendCommMessage("GRA_VERSION", gra.version, "GUILD", nil, "BULK")
    end
end)

Comm:RegisterComm("GRA_VERSION", function(prefix, message, channel, sender)
    if sender == UnitName("player") then return end
    if not versionChecked and gra.version < message then
        versionChecked = true
        GRA:Print(L["New version found (%s). Please visit %s to get the latest version."]:format(message, gra.colors.skyblue.s .. "https://www.curseforge.com/wow/addons/guild-raid-attendance|r"))
    end
end)

-----------------------------------------
-- popup message
-----------------------------------------
function GRA:SendEPGPMsg(msgType, name, value, reason)
    if UnitIsConnected(GRA:GetShortName(name)) then
        Comm:SendCommMessage("GRA_MSG", "|cff80FF00" .. msgType .. ":|r " .. value
        .. "  |cff80FF00" .. L["Reason"] .. ":|r " .. reason, "WHISPER", name, "ALERT")
    end
end

Comm:RegisterComm("GRA_MSG", function(prefix, message, channel, sender)
    GRA:CreatePopup(message)
end)