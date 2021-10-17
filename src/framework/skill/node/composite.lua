local require = require
local cls = require 'std.class'("ControlNode", require 'framework.skill.node.__init__')

function cls:_new()
    local instance = self:super():new()

    instance._children_ = {}
    instance._index_ = 1
    instance._is_child_running_ = false

    return instance
end

function cls:_remove()
    for i, node in ipairs(self._children_) do
        node:remove()
        self._children_[i] = nil
    end
end

function cls:append(child)
    self._children_[#self._children_+1] = child
    child.parent_ = self
end

function cls:start()
    if not self._is_child_running_ then
        self._index_ = 1
    end
end

function cls:run()
    if self._index_ > #self._children_ then
        return true
    end

    if not self._is_child_running_ then
        self._children_[self._index_]:start()
    end

    self._children_[self._index_]:run()
end

function cls:success()
    self._is_child_running_ = false

    if self._index_ <= #self._children_ then
        self._children_[self._index_]:finish()
    end
end

function cls:fail()
    self._is_child_running_ = false

    if self._index_ <= #self._children_ then
        self._children_[self._index_]:finish()
    end
end

function cls:running()
    self._is_child_running_ = true
    self:super():running()
end

return cls
