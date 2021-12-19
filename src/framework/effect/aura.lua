local require = require
local cls = require 'std.class'("AuraEffect")

function cls:_new(data, selector)
    local this = {
        _units_ = require 'framework.group':new(),
        _effects_ = require 'framework.effect.set':new(data)
    }

    if selector.range then
        this._units_:select()
    end
    return this
end