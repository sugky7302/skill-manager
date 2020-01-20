local require = require
local EventManager = require 'std.class'("EventManager")

local GetEvents, GetEvent

function EventManager:_new()
    if not self._instance_ then
        self._instance_ = {
            _events_ = Array:new(),
        }
    end

    return self._instance_
end

function EventManager:addEvent(event_name, callback)
    local event = require 'std.event':new(event_name, callback)
    SaveEvent(self._events_, event)
end

SaveEvent = function(events, event)
    local event_queue = events[event.name_]
    if not event_queue then
        event_queue = {}
        event_queue[#event_queue+1] = event
        events[event_name] = event_queue
    end

    return event
end

return EventManager
