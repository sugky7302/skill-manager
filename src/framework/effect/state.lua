local require = require
local cls = require 'std.class'("EffectState")
local TABLE = require 'framework.effect.table'

function cls:add(set)
    if not(set:isType("EffectSet") and set:getType()) then
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
    延遲(4):加入新狀態但暫停，待舊狀態結束後恢復
    凍結(5):舊狀態暫停，待新狀態結束後恢復
--]]
function cls:compare(set)
    if not(set:isType("EffectSet") and set:getType()) then
        return false
    end

    local list
    for _, tp in pairs(set:getType()) do
        list = TABLE[tp]
        if list then
            for k, state in ipairs(list) do
                if self[k] then
                    if state == 0 then
                        self[k]:clear()
                    elseif state == 1 then
                        set:clear()
                    elseif state == 2 then
                        self[k]:clear()
                        set:clear()
                    elseif state == 3 then
                    elseif state == 4 then
                        set:pause()
                        self[k].on_end[#self[k].on_end+1] = function()
                            set:resume()
                        end
                    elseif state == 5 then
                    end
                end
            end
        end
    end
end

return cls