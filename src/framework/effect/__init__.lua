--[[
    Effect is a collector and manager which control states and relationships of all of effects
--]]

local require = require
local cls = require 'std.class'("Effect")
local Template, Atom

function cls:_new(object)
    return {
        _object_ = object,
        _atom_ = {},  -- 記錄原子效果
    }
end

-- {name, source, value, time, (optional) period}
function cls:add(new_effect)
    Validate(new_effect)

    if AddEffect(new_effect) then
        new_effect:on_add()
        Run(new_effect)
    end

    return self
end

Validate = function(effect)
    assert(effect.name and effect.source and effect.value and effect.time, "效果缺失部份參數，無法成功添加。")

    -- 如果沒有週期，表示是一次性的效果，因此週期會等於時間
    effect.period = effect.period or effect.time
    
    -- 初始化層數
    effect.stock = 1
end

AddEffect = function(effect)
    
end

function cls:pause(name)
end

function cls:resume(name)
end

function cls:delete(name)
end

function cls:getRemaining(name)
end

function cls:setRemaining(name, v)
end

return cls