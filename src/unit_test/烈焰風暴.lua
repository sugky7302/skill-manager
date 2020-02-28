local require = require
local Timer = require 'war3.timer'
local Event = require 'lib.event'
local Group = require 'war3.group'
local Hero = require 'war3.hero'
local ej = require 'war3.enhanced_jass'

local d = require 'lib.skill_decorator':new()
local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)
e:addEvent(
    Event:new(
        '單位-施放技能',
        'GetTriggerUnit GetSpellTargetLoc',
        function(_, source, loc)
            d:append(Hero(source), "烈焰風暴-火焰強化")
            local skill_tree = Hero(source):spell('烈焰風暴', loc, 0.01)
            Timer:new(
                0.01,
                -1,
                function(timer)
                    skill_tree:run()

                    if skill_tree.is_finished_ then
                        timer:stop()
                        ej.RemoveLocation(loc)
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
