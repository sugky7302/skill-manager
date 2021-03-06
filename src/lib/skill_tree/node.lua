local require = require
local NodeList = require 'lib.skill_tree.node_list'

local Node = require 'std.class'('Node')

function Node:_new()
    local instance = {
        parent_ = nil,
        tree_ = nil,
        _name_ = nil,
    }

    return instance
end

function Node:register(name)
    if name then
        NodeList:insert(name, self)
        self._name_ = name
    end
end

function Node:condition()
    return true
end

function Node:start()
end

function Node:run()
end

function Node:finish()
end

function Node:success()
    if self.parent_ then
        self.parent_:success()
    end
end

function Node:fail()
    if self.parent_ then
        self.parent_:fail()
    end
end

function Node:running()
    if self.parent_ then
        self.parent_:running()
    end
end

function Node:getName()
    return self._name_
end

return Node
