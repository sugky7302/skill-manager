--[[
    Listener is an extension to deal with triggers which is designed by Observer Model.

    Require:
      subject

    Member:
      _object_ - object using the listener

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

local require = require
local cls = require 'std.class'("Listener", require 'framework.listener.event')
local subject = pcall(require, 'framework.listener.subject')

function cls:_new(obj)
    local this = self:super():new()
    this._object_ = obj
    return this
end

function cls:object()
    return self._object_
end

function cls:addBroadcast(name, arg, callback)
    if subject then
        subject:addEvent(name, self._object_, arg, callback)
    end

    return self
end

function cls:onTick(name, ...)
    -- 把 self 加入到參數列裡
    local arg = {...}
    arg[#arg+1] = self
    return self:super().onTick(self, name, table.unpack(arg))
end

return cls