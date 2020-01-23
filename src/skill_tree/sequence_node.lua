local require = require

local Sequence = require 'std.class'("SequenceNode", require 'skill_tree.decider_node')

function Sequence:_new()
    return self:super():_new()
end

function Sequence:success()
    self:super().success(self)

    self._index_ = self._index_ + 1
    if self._index_ <= #self._children_ then
        self:_run()
    else
        self:super():super().success(self)
    end
end

function Sequence:fail()
    self:super().fail(self)
    self:super():super().fail(self)
end

return Sequence
