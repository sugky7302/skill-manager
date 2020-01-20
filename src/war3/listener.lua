local require = require
local ej = require 'war3.enhanced_jass'
local Debug = require 'jass.debug'
local Queue = require 'std.queue'

local Listener = require 'std.class'('Listener')

function Listener:_new(name, condition_func)
    local instance = {
        _trigger_ = ej.CreateTrigger(),
        _condition_func_ = ej.Condition(condition_func),
        _condition_ = nil,
        name_ = name,
        actions_ = Queue:new()
    }

    instance._condition_ = ej.TriggerAddCondition(instance._trigger_, instance._condition_func_)

    -- 每種監聽器只存在一個
    self[name] = instance

    -- 增加handle的引用
    Debug.handle_ref(instance._trigger_)

    return instance
end

function Listener:__call(name)
    return self[name]
end

function Listener:_remove()
    self._actions_:remove()

    ej.TriggerRemoveCondition(self._condition_)
    ej.DestroyCondtion(self._condition_func_)
    ej.DestroyTrigger(self._trigger_)

    -- 減少handle的引用
    Debug.handle_unref(self._trigger_)
end

function Listener:registerEvent(type_name, object)
    if type_name == '單位死亡' then
        ej.TriggerRegisterUnitEvent(self._trigger_, object, ej.EVENT_UNIT_DEATH)
    elseif type_name == "被攻擊" then
        ej.TriggerRegisterUnitEvent(self._trigger_, object, ej.EVENT_UNIT_DAMAGED)
    end
end

return Listener
