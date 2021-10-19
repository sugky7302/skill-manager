-- Random是子節點調用success才會隨機執行一個節點，如果子節點調用fail則會回到root
local require = require
local Random = require 'std.class'("RandomNode", require 'framework.skill.node.composite')

function Random:_new()
    return self:super():new()
end

function Random:start()
    if not self._is_child_running_ then
        self._index_ = require('std.math').rand(1, #self._children_)
    end
end

function Random:success()
    self:super().success(self)

    self._index_ = self._index_ + 1
    if self._index_ <= #self._children_ then
        self:run()
    else
        self:super():super().success(self)
    end
end

function Random:fail()
    self:super().fail(self)
    self:super():super().fail(self)
end

return Random
