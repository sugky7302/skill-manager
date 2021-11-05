local require = require
local cls = require 'std.class'("Effect", require 'framework.effect')

function cls:_new(data)
    local this = self:super():new()
    this._value_ = data.value
    this._period_ = data.period or data.time
    this._time_ = data.time
    this._level_ = data.level
    return this
end

return cls