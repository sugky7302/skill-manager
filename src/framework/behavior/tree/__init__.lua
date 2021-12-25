--[[
  BehaviorTree is a powerful framework to run the process of specified behavior. It has similiar structures of programming language.
  Thus, we can expand, modify and reuse easily.

  Required:
    Node

  Member:
    _root_ - 根節點
    object_ - 對象
    _params_ - 樹裡面所有節點都可以讀取的參數列表
    _is_pause_ - 是否處於暫停
    _is_running_ - 是否正在執行

  Function:
    new(obj, script) - create a new instance of behavior tree
      obj - object in war3
      script - skill action script

    iterator() - traverser all nodes

    isRunning() - check whether the tree is running.
      return - true / false
    
    setParam(key, value) - save a key-value pair into the parameter list.
    
    getParam(key) - get the pair with the key from the parameter list.
      return - value
    
    run() - run all nodes

    get(pos) - get the node in the position of the tree.
      return - tree node

    insert(pos, new_node) - insert a new_node into the position of the tree.

    pause() - pause the action of the tree

    restore() - restore the action of the tree
--]]
local require, assert = require, assert
local Script = require 'framework.behavior.script'
local Node = require 'framework.behavior.node'
local cls = require 'std.class'('BehaviorTree', Node)
local Parse, Print

function cls:_new(obj, script)
    local this = self:super():new()

    this._root_ = Parse(this, script, {})
    this.object_ = obj
    this._params_ = {}
    this._is_pause_ = false
    this._is_running_ = false
    -- this.period_ = 1  -- NOTE: 用來記錄外部計時器的週期，動作節點會用到。 - 2020-02-28

    return this
end

Parse = function(self, data, parent_args)
    assert(type(data) == "table", "腳本內容錯誤，請重新檢查。")

    -- 匯入腳本
    if data.import then
        data = Script.export(data.import)
    end

    -- 如果節點的參數是以 $%d+ 組成，將繼承父類參數
    if data.args then
        local match, type = string.match, type
        local n
        for i, v in ipairs(data.args) do
            if type(v) == 'string' and match(v, '$(%d+)') then
                n = tonumber(match(v, '$(%d+)'))
                assert(#parent_args >= n, "此索引超出父類參數的數量，請重新檢查。")
                data.args[i] = parent_args[n]
            end
        end
    end

    local parent = Node.exist(data.id) and Node.exist(data.id):new(data.args) or Node.exist("Sequence"):new(data.args)
    parent.tree_ = self
    
    -- 如果只有單一節點表示沒有底下沒有節點了
    if parent.type == "ActionNode" then
        return parent
    end

    -- 只有多節點的情況下才繼續
    -- local node
    for _, child in pairs(data.nodes or data) do
        parent:append(Parse(self, child, data.args))
    end

    return parent
end

function cls:_remove()
    self._root_:remove()

    for k in pairs(self._params_) do
        self._params_[k] = nil
    end

    self._params_ = nil
end

local rep, concat = string.rep, table.concat
function cls:__tostring()
    if not self._root_ then
        return ""
    end

    return concat(Print({}, self._root_, 0), "\n")
end

Print = function(str, node, depth)
    local s = {}
    for i = 1, depth do
        s[#s+1] = (i < depth) and "|   " or "|-- "
    end
    s[#s+1] = node:getName()
    str[#str+1] = concat(s)

    if node._children_ then
        for _, child in ipairs(node._children_) do
            Print(str, child, depth + 1)
        end
    end

    return str
end

function cls:iterator()
    local index = require "std.stack":new()
    local node = self._root_
    while node._children_ do
        node = node._children_[1]
        index:push(1)
    end
    return function()
        if index:isEmpty() then
            index:remove()
            return nil
        end

        local pos = {}
        for i = 1, index:size() do
            pos[#pos+1] = index[i]
        end

        local ret = node
        local i = index:top() + 1
        index:pop()
        if i > #node.parent_._children_ then
            node = node.parent_
        else
            index:push(i)
            node = node.parent_._children_[i]

            while node._children_ do
                node = node._children_[1]
                index:push(1)
            end
        end
        return table.concat(pos, "-"), ret
    end
end

function cls:isRunning()
    return self._is_running_
end

-- NOTE: 方便使用鏈式語法 - 2021-10-22
function cls:setParam(key, value)
    self._params_[key] = value
    return self
end

-- NOTE: 方便使用鏈式語法 - 2021-10-22
function cls:getParam(key)
    return self._params_[key]
end

function cls:run()
    if not self._root_ or self._is_running_ then
        return self
    end

    self._is_running_ = true
    self._root_.parent_ = self
    self._root_:start()
    self._root_:run()
    return self
end

function cls:get(pos)
    if not self._root_ then
        return self
    end

    local node, v = self._root_
    for s in string.gmatch(pos, "%d+") do
        v = tonumber(s)
        if node._children_ and v <= #node._children_ then
            node = node._children_[v]
        else break
        end
    end

    return node
end

function cls:insert(pos, new_node)
    if not self._root_ then
        return self
    end

    local t = {}
    for s in string.gmatch(pos, "%d+") do
        t[#t+1] = tonumber(s)
    end

    local node = self._root_
    for i, v in ipairs(t) do
        if i == #t then
            table.insert(node._children_, v, new_node)
            new_node.parent_ = node
            new_node.tree_ = self
        elseif node._children_ and v <= #node._children_ then
            node = node._children_[v]
        -- NOTE: 中途發現找不到節點就停止
        else
            break
        end
    end

    return self
end

function cls:pause()
    self._is_pause_ = true
    return self
end

function cls:restore()
    self._is_pause_ = false
    return self
end

function cls:success()
    self._is_running_ = false
end

function cls:fail()
    self._is_running_ = false
end

function cls:running()
    self._is_running_ = false
end

return cls