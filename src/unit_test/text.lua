local require = require
local Event = require 'lib.event'
local Group = require 'war3.group'
local Text = require 'war3.text'

local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)
e:addEvent(
    Event:new(
        '單位-受到傷害',
        'GetTriggerUnit GetSpellAbilityId',
        function(_, source, ability)
            Text:new({
                text = "測試",
                loc = {0, 0},
                time = 1.3,
                mode = "sin",
                font_size = {0.018, 0.005, 0.04},
                height = {20, 5, 120},
                offset = {70, "random"},
            }):start()
        end
    )
)
Group:new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        l('單位-受到傷害')(self.units_[i])
    end
)
