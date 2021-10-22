local BT = require 'framework.behavior'
local Node = require 'framework.behavior.node'
local Rand = require 'std.math'.rand

local patrol = Node("巡邏")

function patrol:run()
    print(table.concat{self.tree_:getParam("目標"), " is patroling."})
    self:running()
end

local b = Node("碰到敵人")
function b:run()
    if Rand(1, 100) < 51 then
        self:success()
    else
        self:fail()
    end
end

local c = Node("生命值檢測")

function c:run()
    if Rand(1, 100) < self._args_[1] then
        self:success()
    else
        self:fail()
    end
end

local d = Node("距離檢測")
function d:run()
    if Rand(1, 200) < self._args_[1] then
        self:success()
    else
        self:fail()
    end
end

local escape = Node("逃跑")

function escape:start()
    self._dis_ = 300
    self._cur_dis_ = 0
end

function escape:run()
    self._cur_dis_ = self._cur_dis_ + Rand(20, 50)

    if self._cur_dis_ > self._dis_ then
        print(self.tree_:getParam("目標"), "has escaped.")
        self:suceess()
    else
        print(self.tree_:getParam("目標"), "is escaping.")
        self:running()
    end
end

local death = Node("死亡")
function death:run()
    if Rand(1, 10) < 5 then
        self:success()
    else
        self:fail()
    end
end

local attack = Node("攻擊")
function attack:run()
    print(self.tree_:getParam("目標"), "is attacking.")
    self:running()
end

-- TODO: 如果遇到節點需要while的狀況要怎麼處理
-- {id="計時器", args={0.3, -1}, nodes={
local bt = BT:new(123, {id="Condition", nodes={
        {id="碰到敵人"},
        {id="Condition", nodes={
            {id="生命值檢測", args={30}},
            {id="Condition", nodes={
                {id="距離檢測", args={100}},
                {id="None"},
                {id="逃跑"}
            }},
            {id="Condition", nodes={
                {id="死亡"},
                {id="None"},
                {id="攻擊"}
            }}
        }},
        {id="巡邏"}
    }}):setParam("目標", "步兵123"):run()

print(bt)
bt:insert("2", Node("攻擊"):new())
print(bt)
bt:insert("3-3-3", Node("逃跑"):new())
print(bt)

