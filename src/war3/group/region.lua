local require = require
local ej = require 'war3.enhanced_jass'
local Manager = require 'war3.group.manager'
local Math = require 'std.math'
local unpack = table.unpack

return {
    rectangle = function(p, vars, angle)
        local length, width = unpack(vars)  -- 解包額外參數
        local group, enumers = Manager.get(), Manager.get()

        -- 選取比原先範圍大一些的區域，好讓有些處在範圍邊緣的單位能夠被正確選取
        ej.GroupEnumUnitsInRange(group, p.x, p.y, Math.sqrt(length^2 + width^2) + 10, nil)

        local x, y, cos, sin
        local enum_unit = ej.FirstOfGroup(group)
        while enum_unit ~= 0 do
            -- 利用旋轉矩陣將矩形和點旋轉到0度的位置
            cos, sin = Math.cos(Math.pi / 2 - angle), Math.sin(Math.pi / 2 - angle)
            x, y = ej.GetUnitX(enum_unit), ej.GetUnitY(enum_unit)
            x, y = cos * x - sin * y, sin * x + cos * y

            if Math.inRange(x, p.x - length / 2, p.x + length / 2) and Math.inRange(y, p.y - width / 2, p.y + width / 2) then
                ej.GroupAddUnit(enumers, enum_unit)
            end

            ej.GroupRemoveUnit(group, enum_unit)
            enum_unit = ej.FirstOfGroup(group)
        end

        Manager.release(group)
        return enumers
    end,
    triangle = function(p, vars, angle)
    end,
    line = function(p, vars, angle)
    end,
    circle = function(p, r)
        local group = Manager.get()
        ej.GroupEnumUnitsInRange(group, p.x, p.y, r + 10, nil)
        return group
    end,
    sector = function(p, vars, angle)
    end
}