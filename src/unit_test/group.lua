local Group = require 'war3.group'
local ej = require 'war3.enhanced_jass'

local a = Group:new()

a:circleUnits{
    p = {x=0, y=0},
    vars = 999999,
    type = "circle"
}
print(a:getCount())
a:loop(function(self, unit)
    print("I'm " .. unit)
    local b = Group:new():circleUnits{
        p = {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        vars = {500, 500},
        type = 'rectangle',
        cnd = 'IsEnemy',
        filter = unit
    }
    print("There are " .. b:getCount() .. " enemies near me")
    b:loop(function(this, u)
        ej.KillUnit(u)
    end)
end)