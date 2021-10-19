-- Parallel是不管子節點調用success或fail都會執行下一個節點，遍歷後回到root
local require = require
local cls = require 'std.class'("ParallelNode", require 'framework.skill.node.composite')

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
