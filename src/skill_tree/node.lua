local require = require
local NodeList = require 'skill_tree.node_list'

local Node = require 'std.class'('Node')

function Node:_new(name)
    local instance = {
        parent_ = nil,
        tree_ = nil
    }

    if name then
        NodeList:insert(name, instance)
    end

    return instance
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

return Node
