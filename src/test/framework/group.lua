local Group = require 'framework.group'
local ej = require 'war3.enhanced_jass'

local a = Group:new()

a:select{"circle", {x=0, y=0}, 999999}

for unit in a:iterator() do
    print("I'm " .. ej.U2S(unit))
    local b = Group:new():select({
        'rectangle',
        {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        {1000, 268},
        unit
    }):filter{"IsEnemy", unit}
    print("Rectangle selected " .. b:size() .. " enemies")

    b = Group:new():select({
        'line',
        {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        {1000, 134},
        unit
    }):filter{"IsEnemy", unit}
    print("Line selected " .. b:size() .. " enemies")

    b = Group:new():select({
        'sector',
        {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        {134, -15, 60},
        unit
    }):filter{"IsEnemy", unit}
    print("Sector selected " .. b:size() .. " enemies")

    b = Group:new():select({
        'fix_sector',
        {x=ej.GetUnitX(unit), y=ej.GetUnitY(unit)},
        {134, 30},
        unit
    }):filter{"IsEnemy", unit}
    print("Fixed sector selected " .. b:size() .. " enemies")
end