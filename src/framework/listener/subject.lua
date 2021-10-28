local require = require


--# 觸發器
local ej = require 'war3.enhanced_jass'
local Debug = require 'jass.debug'

local Trigger = require 'std.class'("Trigger")

function Trigger:_new(condition)
    local this = {
        _object_ = ej.CreateTrigger(),
        _condition_func_ = nil,
        _condition_ = nil,
    }

    if condition then
        self.setAction(this, condition)
    end

    -- 增加handle的引用
    Debug.handle_ref(this._object_)

    return this
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


--# 主題
local subject = require 'framework.listener.event':new()
subject._listeners_ = {}  -- 記錄監聽器
subject._registry_ = {}  -- 記錄已註冊事件，避免重複

local Condition, Register

function subject:addListener(listener)
    self._listeners_[listener:object()] = listener
    return self
end

-- NOTE: 因為觸發傳來的第一個參數一定是object，所以可以拿來讀取監聽器
function subject:notifyListener(name, event_obj, ...)
    if self._listeners_[event_obj] then
        self._listeners_[event_obj]:onTick(name, event_obj, ...)
    end

    return self
end

local AddEvent, AddArg = subject.addEvent
function subject:addEvent(name, obj, arg, callback)
    AddEvent(self, name, callback)
    AddArg(self._event_[name], arg)
    Register(self._registry_, name, obj)
    return self
end

AddArg = function(list, arg)
    local string = string

    if not arg or string.len(arg) == 0 then
        return false
    end

    if not list[0] then
        list[0] = arg
        return true
    end

    local str = {list[0]}
    for s in string.gmatch(arg, "%w+") do
        if not string.match(list[0], s) then
            str[#str+1] = s
        end
    end

    list[0] = table.concat(str)

    return true
end

local EVENT = require 'framework.event.type'
local MAIN_TRG = Trigger:new(Condition)

Register = function(event_source, event_name, event_obj)
    local string = string

    -- 用正則表達式篩選事件是否為一次性
    local trg = MAIN_TRG
    if string.match(event_name, '*') then
        trg = Trigger:new()
        trg:setAction(function()
            Condition()
            trg:remove()
            return true
        end)
    -- NOTE: 已經註冊過的事件對象就跳過
    elseif event_source[event_name .. event_obj] then
        return false
    end

    -- 記錄事件對象，防止重複註冊，使觸發器多重觸發
    event_source[event_name .. event_obj] = true

    -- NOTE: 因為event name不一定有*，所以要用gsub去搜尋加取代
    EVENT.Register(trg:object(), string.gsub(event_name, "*", ""), event_obj)
end

-- 觸發器的動作函數，獨立出來是因為一次性觸發器也會用到。
-- BUG: 尚未解決像 「受到傷害」事件的兇手的監聽器觸發
Condition = function()
    -- NOTE: 可以用print(ej.GetTriggerEventId)獲得本次觸發的事件編號
    local event_name
    for k, v in pairs(EVENT.ID) do
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
    for arg in string.gmatch(subject._event_[event_name][0], "%w+") do
        args[#args + 1] = ej[arg]()
    end
    args = table.unpack(args)

    -- 執行broadcast以及listener的tick
    -- NOTE: args第一個參數通常都會是觸發者，因此我們可以把它當作參數讀取對應的監聽器
    subject:onTick(event_name, args)
    subject:notifyListener(event_name, args)

    return true
end

return subject


