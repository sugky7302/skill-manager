local cls = require 'std.class'("Event")

function cls:_new()
    return {_event_ = {}}
end

function cls:addEvent(name, callback)
    if not self._event_[name] then
        self._event_[name] = {}
    end

    self._event_[name][#self._event_[name] + 1] = callback

    return self
end

function cls:onTick(name, ...)
    if not self._event_[name] then
        return false
    end

    for _, callback in ipairs(self._event_[name]) do
        callback(...)
    end

    return self
end

return cls