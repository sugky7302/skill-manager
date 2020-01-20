local Event = require 'std.class'("Event")

function Event:_new(name, callback)
    return {
        name_ = name,
        _callback_ = callback,
    }
end

function Event:dispatch(...)
    return self._callback_(...)
end

return Event
