local require = require
local Func = select(2, xpcall(require, debug.traceback, 'data.status.init'))
local Status = require 'std.class'("Status")

function Status:_new(object, tb)
    if tb then
        tb.object_ = object
        return tb
    end

    return {object_ = object}
end

function Status:set(key, status)
    self[key] = status

    if Func[key] then
        Func[key].set(self, status)
    end

    return self
end

function Status:has(key)
    return self[key]
end

return Status
