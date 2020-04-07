local require = require
local ej = require 'war3.enhanced_jass'
local EventManger = require 'lib.event_manager'
local Listener = require 'war3.listener'

local Player = require 'std.class'("Player")

function Player:_new(player)
    local this = {
        _object_ = player,
        _name_ = ej.GetPlayerName(player),
        _id_ = ej.GetPlayerId(player),
    }

    self[player] = this

    return this
end

function Player:__call(player)
    return Player[player] or self:new(player)
end

function Player:getObject()
    return self._object_
end

function Player:getName()
    return self._name_
end

function Player:getId()
    return self._id_
end

function Player:addAttribute(name, value)
end

function Player:setAttribute(name, value)
end

function Player:getAttribute(name)
end

function Player:listen(event_name)
    Listener:new()(event_name)(self._object_)
    return self
end

function Player:eventDispatch(event_name, ...)
    EventManager:new():dispatch(event_name, self, ...)
    return self
end

return Player