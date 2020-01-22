local Event = require 'std.class'("Event")

function Event:_new(name, args, callback)
    return {
        name_ = name,
        args_ = args or "",  -- 參數和參數之間用空格隔開
        _callback_ = callback,
    }
end

function Event:dispatch(...)
    return self._callback_(...)
end

return Event
