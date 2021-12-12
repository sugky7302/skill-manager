local require = require
local ipairs = ipairs
local cls = require 'std.class'("EffectState")
local TABLE = require 'framework.effect.table'
local Stop

function cls:add(set)
    if not set:isType("EffectSet") then
        return self
    end

    for _, state in ipairs(set:states()) do
        if not self[state] then
            self[state] = {set}
        else
            self[state][#self[state]+1] = set
        end
    end

    return self
end

--[[
    狀態定義：

    互斥(0):舊狀態被移除
    排斥(1):無法加入新狀態
    抵銷(2):兩者都被移除
    共存(3):兩種狀態無關
--]]
function cls:isAllow(set)
    if not set:isType("EffectSet") then
        return false
    end

    for _, state in pairs(set:states()) do
        for k, v in ipairs(TABLE[state] or {}) do
            if v == 0 then
                Stop(self[k])
            elseif v == 1 then
                Stop(set)
                return false
            elseif v == 2 then
                Stop(self[k])
                Stop(set)
                return false
            end
        end
    end

    return true
end

Stop = function(sets)
    if not sets then
        return
    end

    for _, set in ipairs(sets) do
        set:stop()
    end
end

return cls