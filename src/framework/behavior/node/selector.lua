-- Sequence是子節點調用success才會執行下一個節點，如果子節點調用fail則會回到root
local require = require
local cls = require 'std.class'("SequenceNode", require 'framework.skill.node.composite')

function cls:_new()
    return self:super():new()
end

function cls:success()
    self:super().success(self)
    self:super():super().success(self)
end

function cls:fail()
    self:super().fail(self)

    self._index_ = self._index_ + 1
    if self._index_ <= #self._children_ then
        self:run()
    else
        self:super():super().fail(self)
    end
end

return cls
