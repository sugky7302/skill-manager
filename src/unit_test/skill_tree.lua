local require = require
local SkillTree = require 'lib.skill_tree.skill_tree'
local EventManager = require 'lib.event_manager'
local Listener = require 'war3.listener'
local Group = require 'war3.group'
require 'data.skill.public.init'

for i = 1, 10 do
    local t =
        require 'war3.timer':new(
        i,
        1,
        function()
            print('a' .. i)
        end
    ):start()
end
local e = EventManager:new()
local l = Listener:new(e)
e:addEvent(
    '單位-施放技能',
    'GetTriggerUnit',
    function(_, source)
        local sk = SkillTree:new(source)
        sk:append(
            {
                'test',
                'test1'
            }
        ):run()
    end
)
Group:new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        l('單位-施放技能')(self.units_[i])
    end
)
