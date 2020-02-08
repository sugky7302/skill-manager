local require = require
local SkillManager = require 'lib.skill_manager'
local SkillTree = require 'lib.skill_tree.skill_tree'
local Timer = require 'war3.timer'
local Event = require 'lib.event'
local Group = require 'war3.group'

local effect = require 'lib.effect_manager':new()
local d = require 'lib.skill_decorator':new()
local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)
e:addEvent(
    Event:new(
        '單位-施放技能',
        'GetTriggerUnit GetSpellAbilityId',
        function(_, source, ability)
            d:append(source, "烈焰風暴-火焰強化")
            local skill = SkillManager:new():get('烈焰風暴', source)
            local skill_tree = SkillTree:new(skill):append(skill.scripts):setPeriod(0.01):run()
            Timer:new(
                0.01,
                -1,
                function(timer)
                    skill_tree:run()

                    if skill_tree.is_finished_ then
                        -- effect:add({
                        --     name = "test",
                        --     target = source,
                        --     time = 2,
                        -- }):add({
                        --     name = "test",
                        --     target = source,
                        --     time = 3,
                        -- })

                        Timer:new(1, 1, function()
                            effect:add({
                                name = "test1",
                                target = source,
                                time = 2,
                            }):add({
                                name = "test1",
                                target = source,
                                period = 2,
                                time = 4,
                            })
                        end):start()

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
