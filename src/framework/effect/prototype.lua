--[[
    EffectType is used to define a variaty of effects.
    Besides, dealing with a relationship of other's Effect Types is its another important task.
--]]

local require = require
local cls = require 'std.class'("EffectType")

function cls:_new(type)
    return {
        _type_ = type,
        _task_ = require 'std.list':new(),
        on_add = function() end,
        on_delete = function() end,
        on_finish = function() end,
        on_cover = function() end,
        on_pulse = function() end,
    }
end

function cls:_remove()
    self._task_:remove()
end

function cls:type()
    return self._type_
end

function cls:compare()
end

return cls