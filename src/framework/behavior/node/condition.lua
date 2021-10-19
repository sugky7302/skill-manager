-- Condition是條件節點成功會執行then節點，否則執行else節點
local require = require
local cls = require 'std.class'("ConditionNode", require 'framework.skill.node.__init__')

function cls:_new()
    return self:super():new()
end

function cls:success()
    self:super().success(self)

    self._index_ = self._index_ + 1
    if self._index_ <= #self._children_ then
        self:run()
    else
        self:super():super().success(self)
    end
end

function cls:fail()
    self:super().fail(self)
    self:super():super().fail(self)
end

return cls
