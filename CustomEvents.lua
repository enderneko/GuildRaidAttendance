---@class GRA
local GRA = select(2, ...)
---@class Funcs
local F = GRA.funcs

-- local Compresser = LibStub:GetLibrary("LibCompress")
-- local Encoder = Compresser:GetAddonEncodeTable()
local serializer = LibStub:GetLibrary("AceSerializer-3.0")
local comm = LibStub:GetLibrary("AceComm-3.0")
---------------------------------------------------------------------
-- custom events
---------------------------------------------------------------------
local customEventFunctions = {}

local function distribute(prefix, message, channel, sender)
    local deserialized = {serializer:Deserialize(message)}
    if deserialized[1] then -- successfully deserialized?
        for funcName, func in pairs(customEventFunctions[prefix]) do
            func(unpack(deserialized, 2))
            -- print(unpack(deserialized, 2))
        end
    else
        GRA.Print("|cffFF3030Custom event deserialize failed!|r " .. prefix)
    end
end

function GRA.RegisterComm(prefix, funcName, func)
    if not customEventFunctions[prefix] then customEventFunctions[prefix] = {} end
    customEventFunctions[prefix][funcName] = func

    comm:RegisterComm(prefix, distribute)
end

function GRA.UnregisterComm(prefix, funcName)
    customEventFunctions[prefix] = F.RemoveElementsByKeys(customEventFunctions[prefix], funcName)
    if F.IsEmpty(customEventFunctions[prefix]) then
        comm:UnregisterComm(prefix)
    end
end

function GRA.SendComm(prefix, ...)
    comm:SendCommMessage(prefix, serializer:Serialize(...), "WHISPER", UnitName("player"))
end