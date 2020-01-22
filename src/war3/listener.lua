local require = require
local ej = require 'war3.enhanced_jass'
local Trigger = require 'war3.trigger'

local Listener = require 'std.class'('Listener')

local EVENTS = {
    ['單位-死亡'] = ej.EVENT_UNIT_DEATH,
    ['單位-受到傷害'] = ej.EVENT_UNIT_DAMAGED,
    ['單位-被選取'] = ej.EVENT_UNIT_SELECTED,
    ['測試'] = 4
}

function Listener:_new(event_manager)
    if not self._instance_ then
        self._instance_ = {
            _events_ = event_manager,
            _trigger_ = Trigger:new(
                function()
                    local pairs = pairs

                    local event_name = ''
                    for k, v in pairs(EVENTS) do
                        if v == ej.GetTriggerEventId() then
                            event_name = k
                            break
                        end

                        -- 搜尋不到就跳出
                        return false
                    end

                    -- 將參數名轉成真正的參數
                    local args = {}
                    for _, v in pairs(self._instance_._events_:getArgs(event_name)) do
                        args[#args + 1] = ej[v]()
                    end

                    -- 執行事件的處理方法
                    self._instance_._events_:dispatch(event_name, table.unpack(args))

                    return true
                end
            )
        }
    end

    return self._instance_
end

function Listener:_remove()
    self._trigger_:remove()
end

function Listener:__call(event_name)
    return function(event_source)
        self:_setSourceTriggerEvent(event_name, event_source)
    end
end

function Listener:_setSourceTriggerEvent(event_name, event_source)
    local event_type = string.match(event_name, '[^-]+')

    if event_type == '單位' then
        ej.TriggerRegisterUnitEvent(self._trigger_:object(), event_source, EVENTS[event_name])
    elseif event_type == '測試' then
        ej.TriggerRegisterTimerEvent(self._trigger_:object(), 0, false)
    end
end

return Listener
