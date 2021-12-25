--[[
    Behavior is a powerful tool used in areas of skill, unit AI, etc.
    Here, we extract designs of skill_tree in my original project and behavior tree in my Python's work.
    With the new structure, we can easily design game logics and extend and decorate trees.

    Require:
      tree
      decorator

    Member:
      _tree_ - save a tree instance
      _decorator_ = save a decorator instance

    Function:
      new(obj, tree_script, decorator_script) - create a new instance
        obj - an object which is the main role in the tree
        tree_script - a script which is analyzed for the tree
        decorator_script - a script which is analyzed for the decorator

      print() - print all nodes in the tree and decorators

      run() - invake the tree

      setParam(key, value) - set a parameter to the tree

      insert(pos, node) - insert a node into the tree
        pos - a position which want to be inserted into the tree
        node - a node to be inserted into the tree

      decorate(list, fn) - add a decorator to the tree
        list - a list of decorators
        fn - functions of decorators

      import(name, script) - import scripts into the SCRIPT DATABASE
        name: string / table - script name
        script: table - script
--]]

local require = require
require 'framework.behavior.load'
local Script = require 'framework.behavior.script'
local Tree = require 'framework.behavior.tree'
local Decorator = require 'framework.behavior.tree.decorator'

local cls = require 'std.class'("BehaviorManager")

function cls:_new(obj, tree_script, decorator_script)
    local this = {
        _tree_ = Tree:new(obj, tree_script),
        _decorator_ = Decorator:new(decorator_script)
    }

    for _, node in this._tree_:iterator() do
        this._decorator_:wrap(node)
    end

    return this
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

function cls:insert(pos, node)
    self._decorator_:wrap(node)
    self._tree_:insert(pos, node)
    return self
end

--[[
    NOTE: 支援 6 種裝飾器腳本寫法，
          1. 名字
          2. 名字 & 函數
          3. (名字, 函數)
          4. [名字1, ...], [函數1, ...]
          5. [名字1, ...]
          6. [(名字1, 函數1), ...]
--]]
function cls:decorate(list, fn)
    list = self._decorator_:add(Sort(list, fn))

    for _, node in self._tree_:iterator() do
        self._decorator_:wrap(node, list)
    end
    return self
end

Sort = function(list, fn)
    local type = type
    -- Case 1 & 2
    if type(list) == "string" then
        return list, fn
    elseif type(list) == 'table' then
        -- Case 4 & 5
        if type(fn) == 'table' or type(list[1]) == 'string' then
            return list, fn
        -- Case 3
        elseif #list == 2 and type(list[2]) == 'function' then
            return list[1], list[2]
        -- Case 6
        elseif type(list[1]) == 'table' then
            local t1, t2 = {}, {}
            for _, v in ipairs(list) do
                t1[#t1+1] = v[1]
                t2[#t2+1] = v[2]
            end

            return t1, t2
        end
    end
end

function cls:import(name, script)
    Script.import(name, script)
    return self
end

return cls