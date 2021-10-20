local Wait = require 'framework.behavior.node'("等待")

function Wait:_new(t)
    local this = self:super():new()
    this._wait_ = require 'framework.timer':new(t, 1, function(self) self.args[1]:success() end)
    return this
end

function Wait:run()
    self._wait_:start(self)
end

return Wait