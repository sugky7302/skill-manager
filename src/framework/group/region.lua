local require = require
local ej = require 'war3.enhanced_jass'
local gj = require 'framework.group.manager'
local Math = require 'std.math'
local unpack = table.unpack

function PassThrough(p, r, cnd)
    local group, enumers = gj.get(), gj.get()

    -- 選取比原先範圍大一些的區域，好讓有些處在範圍邊緣的單位能夠被正確選取
    ej.GroupEnumUnitsInRange(group, p.x, p.y, r + 10, nil)

    gj.traverse(group, cnd, function(unit) ej.GroupAddUnit(enumers, unit) end)

    return enumers
end

-- vars = {長度, 寬度}
function Rectangle(p, vars, angle)
    -- 旋轉矩陣
    -- | cosθ -sinθ |
    -- | sinθ cosθ |
    local cos, sin = Math.cos(Math.pi / 2 - angle), Math.sin(Math.pi / 2 - angle)

    local l, w = unpack(vars)
    return PassThrough(p, Math.sqrt(l^2 + w^2), function(unit)
        -- 先將選取單位平移到以中心點為原點的座標系，再對選取單位進行旋轉
        local x, y = ej.GetUnitX(unit) - p.x, ej.GetUnitY(unit) - p.y
        x, y = cos * x - sin * y, sin * x + cos * y

        -- NOTE: 因為座標系已經以 p 為原點了，所以判斷範圍的時候不用再計算 p。
        return Math.inRange(x, -l/2, l/2) and Math.inRange(y, -w/2, w/2)
    end)
end

-- vars = {長度, 寬度}
function Line(p, vars, angle)
    local _, width = unpack(vars)

    -- 將中心點移到矩形的中央，這樣就等價於矩形
    p.x = p.x + width / 2 * Math.cos(angle)
    p.y = p.y + width / 2 * Math.sin(angle)
    return Rectangle(p, vars, angle)
end

-- 只適用正三角形
function Triangle(p, r, angle)
    return PassThrough(p, r, function(unit)
        -- 計算正三角形的頂點
        local vertex = {
            {x = p.x + r * Math.cos(angle), y = p.y + r * Math.sin(angle)},
            {x = p.x + r * Math.cos(angle + 2 * Math.pi / 3), y = p.y + r * Math.sin(angle + 2 * Math.pi / 3)},
            {x = p.x + r * Math.cos(angle - 2 * Math.pi / 3), y = p.y + r * Math.sin(angle - 2 * Math.pi / 3)}
        }

        return Math.inPolygon({x = ej.GetUnitX(unit), y = ej.GetUnitY(unit)}, vertex)
    end)
end

function Circle(p, r)
    local group = gj.get()
    ej.GroupEnumUnitsInRange(group, p.x, p.y, r + 10, nil)
    return group
end

-- 以面向角左右各撐開 n 度（利用向量夾角公式計算）
-- vars = {半徑, 撐開角}
function FixSector(p, vars, angle)
    -- 把角度轉成360度制，之後再轉成弧度
    local theta = Math.rad(vars[2] % 360)

    -- 獲取中線向量
    local ux, uy = Math.cos(angle), Math.sin(angle)

    return PassThrough(p, vars[1], function(unit)
        -- NOTE: pc向量是中心點到角色，所以記得要減p
        local x, y = ej.GetUnitX(unit) - p.x, ej.GetUnitY(unit) - p.y

        return ux * x + uy * y > Math.sqrt(x^2 + y^2) * Math.cos(theta)
    end)
end

-- NOTE: 角度記得要用弧度
-- vars = {半徑, 起始角, 終止角}
function Sector(p, vars)
    -- 把角度轉成360度制
    -- NOTE: 因為vars[3] mod 360一定落在[0, 360]之間，所以利用fmod向零取整的特性，讓vars[2]恆小於vars[3]
    vars[2] = Math.fmod(vars[2], 360)
    vars[3] = vars[3] % 360

    -- 計算中心角和展開角
    local angle = (vars[2] + vars[3]) / 2
    vars[2] = Math.min(vars[3] - angle, 180)  -- 因為圓為360度，所以展開角最大不可能超過圓的一半 = 180 度
    return FixSector(p, vars, Math.rad(angle))
end

return {
    rectangle = Rectangle,
    triangle = Triangle,
    line = Line,
    circle = Circle,
    sector = Sector,
    fix_sector = FixSector,
}