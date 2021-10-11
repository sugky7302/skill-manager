local require = require
local ej = require 'war3.enhanced_jass'
local DP = require 'lib.damage_processor':new()
local e = require 'lib.event_manager':new()
local Unit = require 'war3.unit'
local Timer = require 'war3.timer'
local Text = require 'war3.text'
local Math = require 'std.math'

local ShowText

e:addEvent(
    '單位-受到傷害',
    'GetEventDamageSource GetTriggerUnit',
    function(_, source, target)
        -- 先將當前傷害值歸零，以免實際扣血 ~= 預計扣血
        require 'jass.japi'.EXSetEventDamage(0)

        local status, value = DP.run('普通攻擊', Unit(source), Unit(target))
        if status then
            ShowText(target, status, value)
        end
    end
)

ShowText = function(target, status, value)
    if status[2] == 1 then
        Text:new(
            {
                text = '|cffff0000閃避!',
                loc = {ej.GetUnitX(target), ej.GetUnitY(target)},
                time = 1,
                mode = 'move',
                font_size = {0.022, 0, 0.022},
                height = {50, 100, 400},
                offset = {0, 90}
            }
        ):start()
    else
        local scale = status[3] + 1
        Text:new(
            {
                text = Math.modf(Math.round(value)) .. '',
                loc = {ej.GetUnitX(target), ej.GetUnitY(target)},
                time = 1.2,
                mode = 'sin',
                font_size = {scale * 0.0162, 0, scale * 0.03},
                height = {20, 5, 120},
                offset = {70, 'random'}
            }
        ):start()
    end
end

require 'war3.group':new():enumUnitsInRange(0, 0, 999, 'Nil'):loop(
    function(self, i)
        Unit:new(self.units_[i]):listen('單位-受到傷害')
    end
)
