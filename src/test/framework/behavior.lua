local BT = require 'framework.behavior'
local Node = require 'framework.behavior.node'
local Rand = require 'std.math'.rand

local patrol = Node("巡邏")

function patrol:start()
    self._stage_ = 1
end

function patrol:run()
    if self._stage_ == 1 then
        self._cur_dis_ = 0
        self._dis_ = Rand(50, 100)
        self._stage_ = 2
        print("patrol has set the distance.", os.clock())
    elseif self._cur_dis_ >= self._dis_ then
        print("patrol is finished.", os.clock())
        return self:success()
    else
        self._cur_dis_ = self._cur_dis_ + Rand(10, 15)
        print(table.concat{self.tree_:getParam("目標"), " is patroling."}, os.clock())
    end

    self:running()
end

local b = Node("碰到敵人")
function b:run()
    if Rand(1, 100) < 51 then
        print("encounter an enemy.", os.clock())
        self:success()
    else
        print("It's safe.", os.clock())
        self:fail()
    end
end

local c = Node("生命值檢測")

function c:run()
    if Rand(1, 100) < self._args_[1] then
        print("可以攻擊", os.clock())
        self:success()
    else
        print("它太強了", os.clock())
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
        print(self.tree_:getParam("目標"), "has escaped.", os.clock())
        self:success()
    else
        print(self.tree_:getParam("目標"), "is escaping.", os.clock())
        self:running()
    end
end

local death = Node("死亡")
function death:run()
    if Rand(1, 100) < 30 then
        print("death", os.clock())
        self:success()
    else
        print("alive", os.clock())
        self:fail()
    end
end

local attack = Node("攻擊")
function attack:run()
    print(self.tree_:getParam("目標"), "is attacking.", os.clock())
    self:running()
end

local bt = BT:new(123, {id="Condition", nodes={
        {id="碰到敵人"},
        {id="Condition", args={30}, nodes={
            {id="生命值檢測", args={"$1"}},
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

for i, node in bt._tree_:iterator() do
    print(i, node:getName())
end

print(bt)
bt:insert("2", Node("攻擊"):new())
print(bt)
bt:insert("3-3-3", Node("逃跑"):new())
print(bt)

local qw = BT:new(1, {id="Loop", args={-1}, nodes={
    {id="Condition", nodes={
        {id="碰到敵人"},
        {id="Condition", nodes={
            {id="生命值檢測", args={30}},
            {id="逃跑"},
            {id="攻擊"}
        }},
        {id="巡邏"}
    }},
    {id="等待", args={1}}
}}):setParam("目標", "工作人員"):run()

print("a", os.clock())
print(BT:new(1, {id="等待", args={1}}):run())
print("b", os.clock())

local k = BT:new(1, {id="Timer", args={0.5}, nodes={
    {id="逃跑"},
    {id="Condition", nodes={
        {id="死亡"},
        {id="None"},
        {id="攻擊"}
    }},
    {id="巡邏"}
}}):setParam("目標", "工作人員"):run()
print(k)

-- 裝飾器測試
local function a(node)
    local run = node.run
    node.run = function(self)
        print("攻擊測試")
        run(self)
    end
end

local function b(node)
    local start = node.start
    node.start = function(self)
        print("測試...")
        start(self)
    end
end

print(k:decorate{{"攻擊-a", a}, {"巡邏-b", b}}:run())
print(BT:new(1, {{id="逃跑"}, {id="攻擊"}}):decorate({"攻擊-a", "逃跑-a"}, {a, b}):run())



