local require = require
local ej = require 'war3.enhanced_jass'
local Trigger = require 'war3.trigger'

local Listener = require 'std.class'('Listener')
local SetSourceTriggerEvent

-- NOTE: 值必須要進入遊戲測試，看觸發事件對應的GetTriggerEventId是什麼。
--   步驟1：EVENTS添加事件名的鍵索引
--   （可選）步驟2：於SetSourceTriggerEvent新增事件類型和註冊事件函數
--   步驟3：在line 31的for迴圈前添加print(ej.GetTriggerEventId)以得到事件編號。有些可以直接從common.lua去查，不需要進到遊戲測試。
--   步驟4：填入該事件名的值
local EVENTS = {
    ['單位-死亡'] = ej.EVENT_UNIT_DEATH,
    ['單位-受到傷害'] = ej.EVENT_UNIT_DAMAGED,
    ['單位-被選取'] = ej.EVENT_UNIT_SELECTED,
    ['單位-施放技能'] = ej.EVENT_UNIT_SPELL_CAST,
    ['單位-拾取物品'] = ej.EVENT_UNIT_PICKUP_ITEM,
    ['單位-丟棄物品'] = ej.EVENT_UNIT_DROP_ITEM,
    ['單位-使用物品'] = ej.EVENT_UNIT_USE_ITEM,
    ['單位-出售物品'] = ej.EVENT_UNIT_SELL_ITEM,
    ['測試'] = 4,
    ['對話框-被點擊'] = 92,
}

-- 觸發器的動作函數，獨立出來是因為一次性觸發器也會用到。
local function Condition()
    local pairs = pairs
    local event_name

    -- NOTE: 可以用print(ej.GetTriggerEventId)獲得本次觸發的事件編號
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

    -- NOTE: 請在這加入該類型事件的註冊方法函數！！
    if event_type == '單位' then
        ej.TriggerRegisterUnitEvent(trg:object(), event_source, EVENTS[event_name])
    elseif event_type == '對話框' then
        ej.TriggerRegisterDialogEvent(trg:object(), event_source)
    elseif event_type == '測試' then
        ej.TriggerRegisterTimerEvent(trg:object(), 0, false)
    end
end

return Listener
