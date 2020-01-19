local require = require

local SkillTree = require 'std.class'('SkillTree', require 'skill_tree.node')
local SequenceNode = require 'skill_tree.sequence_node'
local RandomNode = require 'skill_tree.random_node'
local NodeList = require 'skill_tree.node_list'

NodeList:insert('seq', SequenceNode)
NodeList:insert('rand', RandomNode)

function SkillTree:_new(root, object)
    local instance = self:super()._new(self)
    instance._root_ = root or SequenceNode:new()
    instance.object_ = object
    return instance
end

function SkillTree:run()
    self._root_.parent_ = self
    self._root_:start()
    self._root_:run()
end

-- 資料強制要是「表」
local ipairs = ipairs
function SkillTree:append(data)
    for _, v in ipairs(data) do
        self:_append(self._root_, v)
    end
end

function SkillTree:_append(parent, data)
    local type = type

    -- 處理子結構
    if type(data) == 'table' and data.decider then
        local decider = NodeList:query(data.decider):new()
        parent:append(decider)
        decider.tree_ = self

        for _, v in ipairs(data) do
            self:_append(decider, v)
        end
    -- 處理節點
    elseif type(data) == 'table' then
        parent:append(data)
        data.tree_ = self
    -- 處理已記錄在NodeList的節點
    elseif type(data) == 'string' then
        local node = NodeList:query(data):new()
        parent:append(node)
        node.tree_ = self
    end
end

return SkillTree
