local require = require
local ej = require 'war3.enhanced_jass'
local Debug = require 'jass.debug'

local Trigger = require 'std.class'("Trigger")

function Trigger:_new(condition)
    local instance = {
        _object_ = ej.CreateTrigger(),
        _condition_func_ = ej.Condition(condition),
        _condition_ = nil,
    }

    instance._condition_ = ej.TriggerAddCondition(instance._object_, instance._condition_func_)

    -- 增加handle的引用
    Debug.handle_ref(instance._object_)

    return instance
end

function Trigger:_remove()
    ej.TriggerRemoveCondition(self._condition_)
    ej.DestroyCondtion(self._condition_func_)
    ej.DestroyTrigger(self._object_)

    -- 減少handle的引用
    Debug.handle_unref(self._object_)
end

function Trigger:object()
    return self._object_
end

return Trigger
