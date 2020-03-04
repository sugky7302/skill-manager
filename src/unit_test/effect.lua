local require = require
local Timer = require 'war3.timer'
local Group = require 'war3.group'
local Unit = require 'war3.unit'

local effect = require 'lib.effect_manager':new()
local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)
e:addEvent(
    '單位-施放技能',
    'GetTriggerUnit',
    function(_, source)
        effect:add(
            {
                name = 'test',
                target = Unit(source),
                time = 2
            }
        ):add(
            {
                name = 'test',
                target = Unit(source),
                time = 3
            }
        )

        Timer:new(
            1,
            1,
            function()
                effect:add(
                    {
                        name = 'test1',
                        target = Unit(source),
                        time = 2
                    }
                ):add(
                    {
                        name = 'test1',
                        target = Unit(source),
                        period = 2,
                        time = 4
                    }
                )
            end
        ):start()
    end
)
Group:new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        l('單位-施放技能')(self.units_[i])
    end
)
