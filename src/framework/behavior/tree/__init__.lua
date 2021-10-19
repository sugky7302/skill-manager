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
local Node = require 'framework.skill.node.__init__'
local cls = require 'std.class'('SkillTree', Node)
local Parse

-- CONSTANT
local COMPOSITE = {
    Sequence = require 'framework.skill.node.sequence',
    Selector = require 'framework.skill.node.selector',
    Random = require 'framework.skill.node.random',
    Parallel = require 'framework.skill.node.parallel',
    Condition = require 'framework.skill.node.condition'}


function cls:_new(skill_id, script)
    local this = self:super():new()

    this._root_ = Parse(this, script)
    this.skill_ = skill_id
    this.params_ = {}
    this.is_pause = false
    -- this.period_ = 1  -- NOTE: 用來記錄外部計時器的週期，動作節點會用到。 - 2020-02-28

    return this
end

Parse = function(self, data)
    if type(data) ~= 'table' then
        return
    end

    local parent = data.id and COMPOSITE[data.id]:new() or COMPOSITE.Sequence:new()
    parent.tree_ = self

    local node
    for _, child in ipairs(data.nodes or data) do
        if not child.id or COMPOSITE[child.id] then  -- 組合節點
            parent:append(Parse(child))
        else  -- 葉節點
            node = Node(child.id):new(child.args)
            node.tree_ = self
            parent:append(node)
            -- TODO: 使用裝飾器包裝節點
        end
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

function cls:run()
    if not self._root_ then
        return self
    end

    self._root_.parent_ = self
    self._root_:start()
    self._root_:run()
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

return cls