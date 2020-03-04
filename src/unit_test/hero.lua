local require = require
local Hero = require 'war3.hero'
local em = require 'lib.event_manager':new()

em:addEvent(
    '單位-施放技能',
    'GetTriggerUnit',
    function(_, unit)
        local u = Hero(unit)
        u:decorateSkill('烈焰風暴-火焰強化')
        local skill_tree = u:spell('烈焰風暴', u, 0.01)

        require 'war3.timer':new(
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
require 'war3.group':new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        Hero(self.units_[i]):listen('單位-施放技能')
    end
)
