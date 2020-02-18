local require = require
local ej = require 'war3.enhanced_jass'
local Trigger = require 'war3.trigger'

local Listener = require 'std.class'('Listener')
local SetSourceTriggerEvent

local EVENTS = {
    ['單位-死亡'] = ej.EVENT_UNIT_DEATH,
    ['單位-受到傷害'] = ej.EVENT_UNIT_DAMAGED,
    ['單位-被選取'] = ej.EVENT_UNIT_SELECTED,
    ['單位-施放技能'] = ej.EVENT_UNIT_SPELL_CAST,
    ['測試'] = 4,
}

-- 觸發器的動作函數，獨立出來是因為一次性觸發器也會用到。
local function Condition()
    local pairs = pairs

    local event_name
    for k, v in pairs(EVENTS) do
        if v == ej.GetTriggerEventId() then
            event_name = k
            break
        end
    end

    -- 搜尋不到就跳出
    if not event_name then
        return false
    end

    -- 將參數名轉成真正的參數
    local args = {}
    for _, v in pairs(Listener._instance_._events_:getArgs(event_name)) do
        args[#args + 1] = ej[v]()
    end

    -- 執行事件的處理方法
    Listener._instance_._events_:dispatch(event_name, table.unpack(args))

    return true
end

function Listener:_new(event_manager)
    if not self._instance_ then
        self._instance_ = {
            _events_ = event_manager,
            _trigger_ = Trigger:new(Condition)
        }
    end

    return self._instance_
end

function Listener:_remove()
    self._trigger_:remove()
end

function Listener:__call(event_name)
    return function(event_source)
        SetSourceTriggerEvent(self, event_name, event_source)
    end
end

SetSourceTriggerEvent = function(self, event_name, event_source)
    local string = string

    -- 用正則表達式篩選事件是否為一次性
    local trg
    if string.match(event_name, '*') then
        trg = Trigger:new()
        trg:setAction(function()
            Condition()
            trg:remove()
            return true
        end)
    else
        trg = self._trigger_
    end

    -- 用正則表達式篩選出"-"之前的文字
    event_name = string.gsub(event_name, "*", "")
    local event_type = string.match(event_name, '[^-]+')

    if event_type == '單位' then
        ej.TriggerRegisterUnitEvent(trg:object(), event_source, EVENTS[event_name])
    elseif event_type == '測試' then
        ej.TriggerRegisterTimerEvent(trg:object(), 0, false)
    end
end

return Listener
