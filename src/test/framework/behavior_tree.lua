local BT = require 'framework.behavior.tree'
local Node = require 'framework.behavior.node'

local patrol = Node("巡邏")

function patrol:run()
    print(table.concat{self._args_[1], "is patroling."})
    self:running()
end

local b, c = Node("test1"), 0
function b:run()
    print("Testing", self._args_[1])
    if c < 10 then
        c = c + 1
        self:running()
    else
        self:success()
    end
end

-- TODO: 如果遇到節點需要while的狀況要怎麼處理
BT:new(123, {id="計時器", args={0.3, -1}, nodes={
    {id="Condition", nodes={
        {id="碰到敵人"},
        {id="Condition", nodes={
            {id="生命值檢測", args={30}},
            {id="Condition", nodes={
                {id="距離檢測", args={100}},
                nil,
                {id="逃跑"}
            }},
            {id="Condition", nodes={
                {id="死亡"},
                nil,
                {id="攻擊"}
            }}
        }},
        {id="巡邏", args={"步兵123"}}
    }},
}}):run()
