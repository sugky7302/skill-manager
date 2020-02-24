local require = require
local DP = require 'lib.damage_processor':new()
local e = require 'lib.event_manager':new()
local Event = require 'lib.event'
local Unit = require 'war3.unit'
local Timer = require 'war3.timer'

e:addEvent(
    Event:new(
        '單位-受到傷害',
        'GetEventDamageSource GetTriggerUnit',
        function(_, source, target)
            -- 先將當前傷害值歸零，以免實際扣血 ~= 預計扣血
            require 'war3.enhanced_jass'.EXSetEventDamage(0)

            print(DP.run('普通攻擊', source, target))

            -- 測試直接扣血會不會觸發，結果是不會
            Timer:new(
                0.01,
                1,
                function()
                    print(Unit(target):getObject() .. ' is damaged')
                    Unit(target):addAttribute('生命', -40)
                end
            ):start()
        end
    )
)

require 'war3.group':new():enumUnitsInRange(0, 0, 999, 'Nil'):loop(
    function(self, i)
        Unit:new(self.units_[i]):listen('單位-受到傷害')
    end
)
