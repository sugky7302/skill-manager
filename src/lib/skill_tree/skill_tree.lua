local require = require

local SkillTree = require 'std.class'('SkillTree', require 'lib.skill_tree.node')
local SequenceNode = require 'lib.skill_tree.sequence_node'
local RandomNode = require 'lib.skill_tree.random_node'
local NodeList = require 'lib.skill_tree.node_list'

NodeList:insert('seq', SequenceNode)
NodeList:insert('rand', RandomNode)

function SkillTree:_new(skill, root)
    local instance = self:super()._new(self)
    instance._root_ = root or SequenceNode:new()
    instance.skill_ = skill
    instance.is_finished_ = false
    instance.period_ = 1

    return instance
end

function SkillTree:run()
    self._root_.parent_ = self
    self._root_:start()
    self._root_:run()
    return self
end

-- 資料強制要是「表」
local ipairs = ipairs
function SkillTree:append(data)
    for _, v in ipairs(data) do
        self:_append(self._root_, v)
    end

    return self
end

function SkillTree:_append(parent, data)
    local type = type

    -- 處理子結構
    if type(data) == 'table' and data.type then
        -- 處理節點
        local decider = NodeList:query(data.type):new()
        parent:append(decider)
        decider.tree_ = self

        for _, v in ipairs(data) do
            self:_append(decider, v)
        end
    elseif type(data) == 'table' then
        local node
        if type(data.id) == 'string' then
            node = NodeList:query(data.id):new(data.args)
        else
            node = data.id:new(data.args)
        end

        parent:append(node)
        node.tree_ = self

        -- 裝飾節點
        require 'lib.skill_decorator':new():wrap(self.skill_, node)
    end
end

-- NOTE: 用來記錄外部計時器的週期給動作節點用的。 - 2020-02-28
function SkillTree:setPeriod(period)
    self.period_ = period
    return self
end

return SkillTree
