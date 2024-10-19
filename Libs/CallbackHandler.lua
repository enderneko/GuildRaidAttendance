---------------------------------------------------------------------
-- File: CallbackHandler.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2024-03-04 17:24 +08:00
-- Modified: 2024-10-19 16:11 +08:00
---------------------------------------------------------------------

---@class GRA
local GRA = select(2, ...)

local callbacks = {
    -- invoke priority
    {}, -- 1
    {}, -- 2
    {}, -- 3
}

function GRA.RegisterCallback(eventName, onEventFuncName, onEventFunc, priority)
    local t = priority and callbacks[priority] or callbacks[2]
    if not t[eventName] then t[eventName] = {} end
    t[eventName][onEventFuncName] = onEventFunc
end

function GRA.UnregisterCallback(eventName, onEventFuncName)
    for _, t in pairs(callbacks) do
        if t[eventName] then
            t[eventName][onEventFuncName] = nil
        end
    end
end

function GRA.UnregisterAllCallbacks(eventName)
    for _, t in pairs(callbacks) do
        t[eventName] = nil
    end
end

function GRA.Fire(eventName, ...)
    for _, t in pairs(callbacks) do
        if t[eventName] then
            for _, fn in pairs(t[eventName]) do
                fn(...)
            end
        end
    end
end