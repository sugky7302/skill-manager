--[[
  SkillTree is a powerful framework to run the process of a skill. It has similiar structures of programming language.
  Thus, we can expand, modify and reuse easily.

  Required:
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
    Parallel = require 'framework.skill.node.parallel'}


function cls:_new(skill_id, script)
    local this = self:super():new()

    this._root_ = Parse(self, script)
    this.skill_ = skill_id
    this.params_ = {}
    this._is_finished_ = false
    this.period_ = 1  -- NOTE: 用來記錄外部計時器的週期，動作節點會用到。 - 2020-02-28

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

function cls:__tostring()
    if not self._root_ then
        return ""
    end

    
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

return cls