local Group = require 'framework.group'
local ej = require 'war3.enhanced_jass'

local a = Group:new()

a:circleUnits{
    p = {x=0, y=0},
    vars = 999999,
    type = "circle"
}

a:loop(function(self, unit)
    print("I'm " .. ej.U2S(unit))
    local b = Group:new():circleUnits{
        p = {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        vars = {1000, 268},
        type = 'rectangle',
        cnd = 'IsEnemy',
        filter = unit
    }
    print("Rectangle selected " .. b:getCount() .. " enemies")

    b = Group:new():circleUnits{
        p = {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        vars = {1000, 134},
        type = 'line',
        cnd = 'IsEnemy',
        filter = unit
    }
    print("Line selected " .. b:getCount() .. " enemies")

    b = Group:new():circleUnits{
        p = {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        vars = {134, -15, 60},
        type = 'sector',
        cnd = 'IsEnemy',
        filter = unit
    }
    print("Sector selected " .. b:getCount() .. " enemies")

    b = Group:new():circleUnits{
        p = {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        vars = {134, 30},
        type = 'fix_sector',
        cnd = 'IsEnemy',
        filter = unit
    }
    print("Fixed sector selected " .. b:getCount() .. " enemies")
end)