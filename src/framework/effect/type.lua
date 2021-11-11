--[[
    EffectType is used to define a variaty of effects.
    Besides, dealing with a relationship of other's Effect Types is its another important task.
--]]

local require = require
local cls = require 'std.class'("EffectType")

local function None() return true end

function cls:_new(data)
    return {
        _tasks_ = require 'std.list':new(),
        _name_ = data.name,
        _type_ = require 'framework.effect.atom':new(data.type),
        _priority_ = data.priority,
        _mode_ = data.mode,
        _max_ = data.max,
        _keep_after_death_ = data._keep_after_death_,
        on_add = data.on_add or None,
        on_delete = data.on_delete or None,
        on_finish = data.on_finish or None,
        on_cover = data.on_cover or None,
        on_pulse = data.on_pulse or None,
    }
end

function cls:_remove()
    self._tasks_:remove()
end

function cls:type()
    return self._type_:name()
end

function cls:link(effect_type)
    self._type_:add(effect_type)
    return self
end

function cls:compare()
end

return cls