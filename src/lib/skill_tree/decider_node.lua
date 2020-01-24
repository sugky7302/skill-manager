local require = require

local Decider = require 'std.class'("DeciderNode", require 'lib.skill_tree.node')

function Decider:_new()
    local instance = self:super():_new()

    instance._children_ = {}
    instance._index_ = 1
    instance._is_child_running_ = false

    return instance
end

function Decider:append(leaf_node)
    self._children_[#self._children_+1] = leaf_node
    leaf_node.parent_ = self
end

function Decider:start()
    if not self._is_child_running_ then
        self._index_ = 1
    end
end

function Decider:run()
    if self._index_ <= #self._children_ then
        self:_run()
    end
end

function Decider:_run()
    if not self._children_[self._index_]:condition() then
        self._index_ = self._index_ + 1
        self:run()
        return false
    end

    if not self._is_child_running_ then
        self._children_[self._index_]:start()
    end

    self._children_[self._index_]:run()
end

function Decider:success()
    self._is_child_running_ = false
    self._children_[self._index_]:finish()
end

function Decider:fail()
    self._is_child_running_ = false
    self._children_[self._index_]:finish()
end

function Decider:running()
    self._is_child_running_ = true
    self:super():running()
end

return Decider
