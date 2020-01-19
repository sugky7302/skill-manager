local require = require

local Random = require 'std.class'("RandomNode", require 'skill_tree.decider_node')

function Random:_new()
    return self:super():_new()
end

function Random:start()
    if not self._is_child_running_ then
        local Rand = require 'math_lib'.rand
        self._index_ = Rand(1, #self._children_)
    end
end

function Random:success()
    self:super().success(self)

    self._index_ = self._index_ + 1
    if self._index_ <= #self._children then
        self:_run()
    else
        self:super():super().success(self)
    end
end

function Random:fail()
    self:super().fail(self)
    self:super():super().fail(self)
end

return Random
