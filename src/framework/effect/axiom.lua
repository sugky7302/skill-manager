local require = require
local cls = require 'std.class'("AxiomEffect", require 'framework.effect.prototype')

function cls:_new()
    local this = self:super():new()
    this._name_ = ""
    this._mode_ = ""
    this._max_ = ""
    this._priority_ = ""
    this._keep_after_death_ = ""
    return this
end

return cls