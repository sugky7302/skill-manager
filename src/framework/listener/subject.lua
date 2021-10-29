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
local string = string
local EVENT = require 'framework.listener.type'

local event = {}
local Register, AddArg, Dispatch, NotifyListener

local function Add(self, name, arg)
    if not EVENT.ID[name] then
        return true  -- 讓listener記錄這個事件被註冊過，下一次就不會調用這個函數了。
    end

    AddArg(name, arg)
    return Register(self, name)
end

AddArg = function(name, arg)
    if not arg or string.len(arg) == 0 then
        return false
    end

    if not event[name] then
        event[name] = arg
        return true
    end

    local str = {event[name]}
    for s in string.gmatch(arg, "%w+") do
        if not string.match(event[name], s) then
            str[#str+1] = s
        end
    end

    event[name] = table.concat(str, " ")
    
    return true
end

-- 觸發器的動作函數，獨立出來是因為一次性觸發器也會用到。
-- NOTE: 因為MAIN_TRG馬上要用到，所以沒辦法先宣告再實作
local function Condition()
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

    -- 將參數名轉成真正的參數。如果找不到就設定空字串，防止gmatch報錯
    local args = {}
    for arg in string.gmatch(event[event_name] or "", "%w+") do
        args[arg] = ej[arg]()
    end

    -- 執行broadcast以及listener的tick
    -- NOTE: 有時候事件沒有事件對象，因此會回傳nil，而ej讀到nil會直接I/O Error
    local obj = EVENT.OBJECT[string.match(event_name, '[^-]+')]
    NotifyListener(event_name, obj and ej[obj](), args)

    return true
end

local MAIN_TRG = Trigger:new(Condition)

Register = function(self, name)
    -- 用正則表達式篩選事件是否為一次性
    local trg = MAIN_TRG
    if string.match(name, '*') then
        trg = Trigger:new()
        trg:setAction(function()
            Condition()
            trg:remove()
            return true
        end)
    -- NOTE: 監聽器不得重複註冊事件
    elseif self:isRegistered(name) then
        return false
    end

    -- NOTE: 因為event name不一定有*，所以要用gsub去搜尋加取代
    EVENT.Register(trg:object(), string.gsub(name, "*", ""), self:object())

    return true
end

local listeners = {}  -- 記錄監聽器

NotifyListener = function(name, obj, args)
    -- 沒有obj表示是廣播事件
    if not obj then
        for _, listener in pairs(listeners) do
            Dispatch(listener, name, args)
        end
    elseif listeners[obj] then
        Dispatch(listeners[obj], name, args)
    end
end

Dispatch = function(self, name, args)
    local unpack, vars = table.unpack
    for arg, callback in self:iterator(name) do
        vars = {}
        for s in string.gmatch(arg or "", "%w+") do
            if args[s] then
                vars[#vars+1] = args[s]
            end
        end
        vars[#vars+1] = self
        callback(unpack(vars))
    end
end


local function AddListener(listener)
    listeners[listener._object_] = listener
end

return {
    addListener = AddListener,
    add = Add,
}


