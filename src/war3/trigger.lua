local require = require
local ej = require 'war3.enhanced_jass'
local Debug = require 'jass.debug'

local Trigger = require 'std.class'("Trigger")

function Trigger:_new(condition)
    local instance = {
        __mode = "kv",  -- 設定為弱引用，怕一次性觸發器沒清乾淨。
        _object_ = ej.CreateTrigger(),
        _condition_func_ = nil,
        _condition_ = nil,
    }

    if condition then
        self.setAction(instance, condition)
    end

    -- 增加handle的引用
    Debug.handle_ref(instance._object_)

    return instance
end

function Trigger:setAction(condition)
    if self._condition_ then
        self:removeAction()
    end

    self._condition_func_ = ej.Condition(condition)
    self._condition_ = ej.TriggerAddCondition(self._object_, self._condition_func_)

    return self
end

function Trigger:_remove()
    self:removeAction()
    ej.DestroyTrigger(self._object_)

    -- 減少handle的引用
    Debug.handle_unref(self._object_)
end

function Trigger:removeAction()
    ej.TriggerRemoveCondition(self._condition_)
    ej.DestroyCondition(self._condition_func_)
    return self
end

function Trigger:object()
    return self._object_
end

return Trigger
