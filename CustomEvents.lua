local GRA, gra = unpack(select(2, ...))

-- local Compresser = LibStub:GetLibrary("LibCompress")
-- local Encoder = Compresser:GetAddonEncodeTable()
local serializer = LibStub:GetLibrary("AceSerializer-3.0")
local comm = LibStub:GetLibrary("AceComm-3.0")
-----------------------------------------
-- custom events
-----------------------------------------
local customEventFunctions = {}

local function distribute(prefix, message, channel, sender)
	local deserialized = {serializer:Deserialize(message)}
	if deserialized[1] then -- successfully deserialized?
		for onEventFuncName, onEventFunc in pairs(customEventFunctions[prefix]) do
			onEventFunc(unpack(deserialized, 2))
			-- print(unpack(deserialized, 2))
		end
	else
		GRA:Print("|cffFF3030Custom event deserialize failed!|r " .. prefix)
	end
end

function GRA:RegisterEvent(customEvent, onEventFuncName, onEventFunc)
	if not customEventFunctions[customEvent] then customEventFunctions[customEvent] = {} end
	customEventFunctions[customEvent][onEventFuncName] = onEventFunc

	comm:RegisterComm(customEvent, distribute)
end

function GRA:UnregisterEvent(customEvent, onEventFuncName)
	customEventFunctions[customEvent] = GRA:RemoveElementsByKeys(customEventFunctions[customEvent], {onEventFuncName})
end

function GRA:FireEvent(customEvent, ...)
	comm:SendCommMessage(customEvent, serializer:Serialize(...), "WHISPER", UnitName("player"))
end

-- local customEventFrame = CreateFrame("Frame")
-- customEventFrame:RegisterEvent("CHAT_MSG_ADDON")
-- customEventFrame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
-- 	-- table.concat({UnitFullName("player")}, "-")
-- 	if not customEventFunctions[prefix] or not string.find(sender, UnitName("player")) or channel ~= "WHISPER" then return end
-- 	local deserialized = {serializer:Deserialize(message)}
-- 	if deserialized[1] then -- successfully deserialized?
-- 		for onEventFuncName, onEventFunc in pairs(customEventFunctions[prefix]) do
-- 			onEventFunc(unpack(deserialized, 2))
-- 		end
-- 	else
-- 		GRA:Print("|cffFF3030Custom event deserialize failed!|r " .. prefix)
-- 	end
-- end)

-- function GRA:RegisterEvent(customEvent, onEventFuncName, onEventFunc)
-- 	RegisterAddonMessagePrefix(customEvent)
-- 	if not customEventFunctions[customEvent] then customEventFunctions[customEvent] = {} end
-- 	customEventFunctions[customEvent][onEventFuncName] = onEventFunc
-- end

-- function GRA:FireEvent(customEvent, ...)
-- 	SendAddonMessage(customEvent, serializer:Serialize(...), "WHISPER", UnitName("player"))
-- end
