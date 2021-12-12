local require = require
local cls = require 'std.class'( "Flame", require 'framework.effect.set')

cls.name = "燃燒"

function cls:_new()
    return self:super():_new{
        name = "燃燒",
        states = {"dot"},
        priority = 1,
        mode = 0,
        on = {
            add = function()
                print('add')
            end,
            delete = function()
                print('delete')
            end,
            finish = function()
                print('finish')
            end,
            cover = function()
                print('cover')
            end,
            pulse = function()
                print('pulse')
            end
        }
    }
end

return cls