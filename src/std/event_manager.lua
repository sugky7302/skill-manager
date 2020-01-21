local EventManager = require 'std.class'("EventManager")

function EventManager:_new()
    if not self._instance_ then
        self._instance_ = {
            _events_ = {},
        }
    end

    return self._instance_
end

function EventManager:addEvent(event)
    local event_queue = self._events_[event.name_]
    if not event_queue then
        event_queue = {}
        self._events_[event.name_] = event_queue
    end

    event_queue[#event_queue+1] = event

    return event
end

function EventManager:dispatch(event_name, ...)
    if not self._events_[event_name] then
        return false
    end

    for _, event in ipairs(self._events_[event_name]) do
        event:dispatch(...)
    end
end

return EventManager
