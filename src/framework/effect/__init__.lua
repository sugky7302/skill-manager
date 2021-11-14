-- Effect is a collector and manager which control states and relationships of all of effects

local require = require
local cls = require 'std.class'("EffectManager")
local Template

function cls:_new(object)
    return {
        _object_ = object,
        _state_ = require 'framework.effect.state':new(),
        _sets_ = {},  -- 收集所有效果集
    }
end

-- {name, source, value, time, (optional) period}
function cls:add(new_effect)
    Validate(new_effect)
    AddEffect(self, new_effect)

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
        return
    end

    if not self._sets_[effect.name] then
        -- 新建模板
        self._sets_[effect.name] = Template[effect.name]:new(self._object_)

        -- 註冊原子狀態
        self._state_:add(self._sets_[effect.name])
    end

    -- 根據狀態關係表，比對所有效果類型之間的狀態
    if self._state_:compare(self._sets_[effect.name]) then
        self._sets_[effect.name]:add(effect)
    end
end

function cls:pause(name)
    self._sets_[name]:pause()
    return self
end

function cls:resume(name)
    self._sets_[name]:resume()
    return self
end

function cls:delete(name)
    self._sets_[name]:clear()
    return self
end

-- TODO: 如何從一個效果組中找到指定的效果
function cls:getRemaining(name)
end

function cls:setRemaining(name, v)
end

return cls