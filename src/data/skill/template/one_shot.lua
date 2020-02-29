local require = require
local Math = require 'std.math'
local DP = require 'lib.damage_processor'
local Text = require 'war3.text'

local OneShot = require 'std.class'('ActionNode', require 'lib.skill_tree.node')

function OneShot:_new()
    return self:super():new()
end

function OneShot:run()
    self:showText(self:dealDamage())
    self:success()
end

function OneShot:dealDamage()
    return DP:new().run(self.tree_.skill_, self.tree_.skill_.source, self.tree_.skill_.target)
end

function OneShot:showText(status, value)
    if not status then
        return
    end

    if status[2] == 1 then
        Text:new(
            {
                text = '|cffff0000閃避!',
                loc = {self.tree_.skill_.target:getLoc()},
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
                loc = {self.tree_.skill_.target:getLoc()},
                time = 1.2,
                mode = 'sin',
                font_size = {scale * 0.0162, 0, scale * 0.03},
                height = {20, 5, 120},
                offset = {70, 'random'}
            }
        ):start()
    end
end

return OneShot
