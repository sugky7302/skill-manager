local require = require

local SkillTree = require 'std.class'('SkillTree', require 'lib.skill_tree.node')
local SequenceNode = require 'lib.skill_tree.sequence_node'
local RandomNode = require 'lib.skill_tree.random_node'
local NodeList = require 'lib.skill_tree.node_list'
local skill_decorator = require 'lib.skill_decorator':new()

NodeList:insert('seq', SequenceNode)
NodeList:insert('rand', RandomNode)

function SkillTree:_new(object, root)
    local instance = self:super()._new(self)
    instance._root_ = root or SequenceNode:new()
    instance.object_ = object
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
        local decider = NodeList:query(data.type):new()
        parent:append(decider)
        decider.tree_ = self

        for _, v in ipairs(data) do
            self:_append(decider, v)
        end
    -- 處理節點
    elseif type(data) == 'table' then
        local node
        if type(data.id) == "string" then
            node = NodeList:query(data.id):new(data.args)
        else
            node = data.id:new(data.args)
        end

        parent:append(node)
        node.tree_ = self
        
        -- 裝飾節點
        skill_decorator:wrap(self.object_, node)
    end
end

function SkillTree:setPeriod(period)
    self.period_ = period
    return self
end

return SkillTree
