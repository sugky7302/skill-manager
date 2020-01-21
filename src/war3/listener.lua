local require = require
local ej = require 'war3.enhanced_jass'
local Debug = require 'jass.debug'
local Queue = require 'std.queue'

local Listener = require 'std.class'('Listener')
local trg = ej.CreateTrigger()

local EVENTS = {
    ["死亡"] = ej.EVENT_UNIT_DEATH,
}

function Listener:_new(name, args)
    local instance = {
        _name_ = name,
        _events_ = Queue:new(),
        _event_manager_ = nil,
        _args_ = args,
    }

    -- 每種監聽器只存在一個
    self[name] = instance

    return instance
end

function Listener:_remove()
    self._events_:remove()

    ej.TriggerRemoveCondition(self._condition_)
    ej.DestroyCondtion(self._condition_func_)
    ej.DestroyTrigger(self._trigger_)

    -- 減少handle的引用
    Debug.handle_unref(self._trigger_)
end

function Listener:__call(name)
    return self[name]
end

function Listener:getListenerByEvent(event_id)
    for k, v in pairs(EVENTS) do
        if v == event_id then
            return k
        end
    end
end

function Listener:addEvent(event)
    self._events_:push_back(event)
end

function Listener:setEventManager(event_manager)
    self._event_manager_ = event_manager
end

function Listener:listen()
    local args = {}
    for arg_name in ipairs(self._args_) do
        args[arg_name] = ej[arg_name]()
    end

    for i = self._events_:begin(), self._events_:end_() do
        self._events_[i]:dispatch(args)
    end
end

function Listener:setSource(event_source)
    if self._name_ == '死亡' then
        ej.TriggerRegisterUnitEvent(trg, event_source, EVENTS[self._name_])
    elseif self._name_ == '被攻擊' then
        ej.TriggerRegisterUnitEvent(trg, event_source, ej.EVENT_UNIT_DAMAGED)
    end
end

-- 放在這裡才能調用Listener
ej.TriggerAddCondition(
    trg,
    ej.Condition(
        function()
            local listener = Listener:getListenerByEvent(ej.GetTriggerEventId)
            listener:listen()
        end
    )
)

return Listener
