local require = require
local SkillManager = require 'lib.skill_manager'
local SkillTree = require 'lib.skill_tree.skill_tree'
local Timer = require 'war3.timer'
local Event = require 'lib.event'
local EventManager = require 'lib.event_manager'
local Listener = require 'war3.listener'
local Group = require 'war3.group'

local e = EventManager:new()
local l = Listener:new(e)
e:addEvent(
    Event:new(
        '單位-施放技能',
        'GetTriggerUnit GetSpellAbilityId',
        function(_, source, ability)
            local skill = SkillManager:new():get('烈焰風暴', source)
            local skill_tree = SkillTree:new(skill):append(skill.scripts):setPeriod(0.01):run()
            Timer:new(
                0.01,
                -1,
                function(timer)
                    skill_tree:run()

                    if skill_tree.is_finished_ then
                        timer:stop()
                    end
                end
            ):start()
        end
    )
)
Group:new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        l('單位-施放技能')(self.units_[i])
    end
)
