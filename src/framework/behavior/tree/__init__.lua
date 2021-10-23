--[[
  SkillTree is a powerful framework to run the process of a skill. It has similiar structures of programming language.
  Thus, we can expand, modify and reuse easily.

  Required:
    Node

  Member:
    _root_ - 根節點
    skill_ - 技能
    params_ - 樹裡面所有節點都可以讀取的參數列表
    period_ - 計時器的週期

  Function:
    new(skill_id, script) - create a new instance of skill tree
      skill_id - skill id in war3
      script - skill action script

    run() - run all nodes
--]]
local require = require
local Node = require 'framework.behavior.node'
local cls = require 'std.class'('BehaviorTree', Node)
local Parse, Print

function cls:_new(obj, script)
    local this = self:super():new()

    this._root_ = Parse(this, script)
    this.object_ = obj
    this._params_ = {}
    this._is_pause_ = false
    this._is_running_ = false
    -- this.period_ = 1  -- NOTE: 用來記錄外部計時器的週期，動作節點會用到。 - 2020-02-28

    return this
end

Parse = function(self, data)
    assert(type(data) == "table", "腳本內容錯誤，請重新檢查。")

    local parent = Node.exist(data.id) and Node.exist(data.id):new(data.args) or Node.exist("Sequence"):new(data.args)
    parent.tree_ = self
    -- TODO: 使用裝飾器包裝節點
    -- 如果只有單一節點表示沒有底下沒有節點了
    if parent.type == "ActionNode" then
        return parent
    end

    -- 只有多節點的情況下才繼續
    -- local node
    for _, child in pairs(data.nodes or data) do
        parent:append(Parse(self, child))
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