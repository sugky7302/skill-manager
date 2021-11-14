local require = require
local cls = require 'std.class'("EffectState")
local TABLE = require 'framework.effect.table'
local Clear

function cls:add(set)
    if not(set:isType("EffectSet") and set:type()) then
        return self
    end

    local last
    for _, tp in ipairs(set:getType()) do
        if not self[tp] then
            self[tp] = set
        else
            last = self[tp]
            while(last.next_ ~= nil) do last = last.next_ end
            last.next_ = set
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
function cls:compare(set)
    if not(set:isType("EffectSet") and set:type()) then
        return false
    end

    for _, tp in pairs(set:getType()) do
        for k, state in ipairs(TABLE[tp]) do
            if state == 0 then
                Clear(self[k])
            elseif state == 1 then
                Clear(set)
                return false
            elseif state == 2 then
                Clear(self[k])
                Clear(set)
                return false
            end
        end
    end

    return true
end

Clear = function(set)
    while(set ~= nil) do
        set:clear()
        set = set.next_
    end
end

return cls