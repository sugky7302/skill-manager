local SkillTree = require 'framework.skill.tree.__init__'
local Node = require 'framework.skill.node.__init__'

local a = Node("test")

function a:run()
    print("Testing", self._args_[1])
    self:success()
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
SkillTree:new(123, {
    {id="test", args={1, 2}},
    {id='test1', args={3, 4}}
}):run()
