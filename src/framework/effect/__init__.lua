-- Effect is a collector and manager which control states and relationships of all of effects

local require = require
local cls = require "std.class"("EffectManager")
local Template = require 'framework.effect.template'
local Init

function cls:_new(object)
    return {
        _object_ = object,
        _state_ = require 'framework.effect.state':new(),
        _sets_ = {}
    }
end

-- {name, source, value, time, (optional) period}
-- NOTE: 解耦manager和effect的關係，不需要把太多effect的判斷放在這裡。 - 2021-12-11
function cls:add(new_effect)
    Init(new_effect, self._object_)

    if not Template[new_effect.name] then
        return false
    end

    if not self._sets_[new_effect.name] then
        self._sets_[new_effect.name] = Template[new_effect.name]:new()
        self._state_:add(self._sets_[new_effect.name])  -- 加入到原子狀態
    end

    -- 狀態不允許
    if not self._state_:isAllow(self._sets_[new_effect.name]) then
        return false
    end
    
    return self._sets_[new_effect.name]:add(new_effect)
end

Init = function(effect, target)
    assert(effect.name and effect.source and effect.value and effect.time, "效果缺失部份參數，無法成功添加。")

    -- 如果沒有週期，表示是一次性的效果，因此週期會等於時間
    effect.period = effect.period or effect.time

    -- 初始化層數
    effect.stock = 1

    -- 設定目標為管理器的擁有者
    effect.target = target
end

function cls:pause(name)
    if not(name and self._sets_[name]) then
        return self
    end

    self._sets_[name]:pause()
    return self
end

function cls:resume(name)
    if not(name and self._sets_[name]) then
        return self
    end

    self._sets_[name]:resume()
    return self
end

function cls:stop(name)
    if not(name and self._sets_[name]) then
        return self
    end

    self._sets_[name]:stop()
    return self
end

function cls:getRemaining(name)
    if not(name and self._sets_[name]) then
        return 0
    end

    return self._sets_[name]:getRemaining()
end

function cls:setRemaining(name, v)
    if not(name and self._sets_[name]) then
        return self
    end

    self._sets_[name]:setRemaining(v)
    return self
end

return cls