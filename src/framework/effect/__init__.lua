-- Effect is a collector and manager which control states and relationships of all of effects

local require = require
local cls = require 'std.class'("EffectManager")
local Template

function cls:_new(object)
    return {
        _object_ = object,
        _types_ = {},  -- 收集所有效果類型
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
        local atom = Template[effect.name]:new()
        self._sets_[effect.name] = atom
        
        -- 記錄效果類型
        local type_name = atom:getType()
        if not self.types_[type_name] then
            self.types_[type_name] = atom

        -- 如果已經有記錄類型了，就搜尋末端，與其建立繫結，方便原子狀態比較時搜尋
        else
            local effect_type = self.types_[type_name]
            while(effect_type.next_ ~= nil) do effect_type = effect_type.next_ end
            effect_type:bind(atom)
        end
    end

    -- 根據狀態關係表，比對所有效果類型之間的狀態
    if IsTypeAllow(self._types_, self._sets_[effect.name]) then
        self._sets_[effect.name]:add(effect)
    end
end

IsTypeAllow = function(types, set)
    for _, v in ipairs(types) do
        if not set:compareRelation(v) then
            return false
        end
    end

    return true
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