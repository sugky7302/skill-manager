local require = require
require 'framework.behavior.load'
local Tree = require 'framework.behavior.tree'
local Decorator = require 'framework.behavior.tree.decorator'

local cls = require 'std.class'("BehaviorManager")

function cls:_new()
    return {
        _tree_ = Tree:new(),
        _decorator_ = Decorator:new()
    }
end

function cls:__tostring()
    return table.concat({"(Tree)", self._tree_:__tostring(), "\n(Decorator)", self._decorator_:__tostring()}, '\n')
end

function cls:run()
    self._tree_:run()
    return self
end

function cls:setParam(key, value)
    self._tree_:setParam(key, value)
    return self
end

return cls