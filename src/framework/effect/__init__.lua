-- Effect is a collector and manager which control states and relationships of all of effects

local require = require
local cls = require 'std.class'("Effect")
local TYPE_SIGN = "@"
local Template

function cls:_new(object)
    return {
        _object_ = object,
        _effects_ = {},  -- 收集所有效果以及記錄效果類型
    }
end

-- {name, source, value, time, (optional) period}
function cls:add(new_effect)
    Validate(new_effect)

    if AddEffect(self, new_effect) then
        new_effect:on_add()
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

AddEffect = function(self, effect)
    if not Template[effect.name] then
        return false
    end

    -- 新建模板
    if not self._effects_[effect.name] then
        local atom = Template[effect.name]:new()
        self._effects_[effect.name] = atom
        
        -- 記錄效果類型
        local type_name = TYPE_SIGN .. atom:getType()
        if not self._effects_[type_name] then
            self._effects_[type_name] = atom
        else  -- 如果已經有記錄類型了，就搜尋末端，與其建立連結，方便比較時搜尋
            local effect_type = self._effects_[type_name]
            while(effect_type.next_ ~= nil) do effect_type = effect_type.next_ end
            effect_type:link(atom)
        end
    end

    self._effects_[effect.name]:add(effect)

    return true
end

function cls:pause(name)
    self._effects_[name]:pause()
    return self
end

function cls:resume(name)
    self._effects_[name]:resume()
    return self
end

function cls:delete(name)
    self._effects_[name]:clear()
    return self
end

-- TODO: 如何從一個效果組中找到指定的效果
function cls:getRemaining(name)
end

function cls:setRemaining(name, v)
end

return cls