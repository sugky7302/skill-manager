local require = require
local Wait = require 'framework.behavior.node'("等待")

function Wait:_new(t)
    local this = self:super():new()
    this._wait_ = require 'framework.timer':new(t, 1, function(self)
        if self.args[1].parent_:getName() == "Selector" then
            self.args[1]:fail()
        else
            self.args[1]:success()
        end
    end)

    return this
end

function Wait:run()
    self._wait_:start(self)
end

return Wait