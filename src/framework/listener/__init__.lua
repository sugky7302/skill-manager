--[[
    Listener is an extension to deal with triggers which is designed by Observer Model.

    Require:
      subject

    Member:
      _object_ - object using the listener
      _registry_ - record what event is registered.

    Function:
      new() - create a new instance

      object() - return the object of a listener

      addBroadcast(name, arg, callback) - add a broadcast to the event source.
        name - event name
        arg - event arg whose type is string
        callback - callback function

      addEvent(name, callback) - add an event to the listener.
        name - event name
        callback - callback function

      onTick(name, ...) - call all callback functions of the event we assigned.
        name - event name
        ... - args you want to put.
--]]

local require, xpcall, select = require, xpcall, select
local cls = require 'std.class'("Listener")
local error = function() return false end
local subject = select(2, xpcall(require, error, 'framework.listener.subject'))
local template = select(2, xpcall(require, error, "framework.listener.template"))

function cls:_new(obj)
    local this = {
        _event_ = {},
        _object_ = obj,
        _registry_ = {},  -- 記錄有沒有重複對主題註冊事件
    }

    if subject then
        subject.addListener(this)
    end

    return this
end

function cls:object()
    return self._object_
end

function cls:isRegistered(name)
    return self._registry_[name]
end

function cls:add(name, arg, callback)
    local type = type

    if not(type(name) == 'string' or type(name) == 'table') then
        return self
    end

    local event
    -- NOTE: 解析只有名字或是一個事件的情況
    if not (arg or callback) then
        if type(name) == 'table' then
            event = name
            name = name.name
        elseif template and template[name] then
            event = template[name]
        else
            return self
        end
    else
        event = {name=name, arg=arg, callback=callback}
    end

    if not self._event_[name] then
        self._event_[name] = {}
    end

    self._event_[name][#self._event_[name] + 1] = event

    if not self._registry_[name] and subject and subject.add(self, name, arg) then
        self._registry_[name] = true
    end

    return self
end

function cls:onTick(name, ...)
    if not self._event_[name] then
        return false
    end

    -- 把 self 加入到參數列裡
    local arg = {...}
    arg[#arg+1] = self

    local unpack = table.unpack
    for _, event in ipairs(self._event_[name]) do
        event.callback(unpack(arg))
    end

    return self
end

function cls:iterator(name)
    if not self._event_[name] then
        return function() return nil end  -- 防止for iterator報錯
    end

    local i = 1
    return function()
        if i > #self._event_[name] then
            return
        end

        local arg, callback = self._event_[name][i].arg or "", self._event_[name][i].callback
        i = i + 1
        return arg, callback
    end
end

return cls