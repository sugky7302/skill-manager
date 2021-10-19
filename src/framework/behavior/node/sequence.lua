-- Sequence是子節點調用success才會執行下一個節點，如果子節點調用fail則會回到root
local require = require
local Sequence = require 'std.class'("SequenceNode", require 'framework.skill.node.composite')

function Sequence:_new()
    return self:super():new()
end

function Sequence:success()
    self:super().success(self)

    self._index_ = self._index_ + 1
    if self._index_ <= #self._children_ then
        self:run()
    else
        self:super():super().success(self)
    end
end

function Sequence:fail()
    self:super().fail(self)
    self:super():super().fail(self)
end

return Sequence
