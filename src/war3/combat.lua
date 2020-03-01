local require = require
local Math = require 'std.math'
local DP = require 'lib.damage_processor'
local Text = require 'war3.text'

local IsDodge, CheckCritToGetFontScale

local function Show(target, status, value)
    if not status then
        return
    end

    if IsDodge(status) then
        Text:new(
            {
                text = '|cffff0000閃避!',
                loc = {target:getLoc()},
                time = 1,
                mode = 'move',
                font_size = {0.022, 0, 0.022},
                height = {50, 100, 400},
                offset = {0, 90}
            }
        ):start()
    else
        local scale = CheckCritToGetFontScale(status)
        Text:new(
            {
                text = Math.modf(Math.round(value)) .. '',
                loc = {target:getLoc()},
                time = 1.2,
                mode = 'sin',
                font_size = {scale * 0.0162, 0, scale * 0.03},
                height = {20, 5, 120},
                offset = {70, 'random'}
            }
        ):start()
    end
end

IsDodge = function(status)
    return status[2] == 1
end

CheckCritToGetFontScale = function(status)
    -- status[3] = 0(未暴擊)/1(暴擊)
    return status[3] + 1
end

return function(name, source, target)
    Show(target, DP:new().run(name, source, target))
end
