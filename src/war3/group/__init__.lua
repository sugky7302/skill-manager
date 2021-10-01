------
-- Group is an extension of jass group, it integrates the most jass group features
-- and enhances the user experience.
--
-- Required:
--   enhanced_jass
--   array
--   group/condition
--   group/region
--
-- Member:
--   _ignore_label_(table) - save ths ignored units
--   units_(queue) - save the jass units
--
-- Function:
--   new(self) - create a new group instance
--     self - class Group
--
--   remove(self) - remove ths group instance
--     self - group instance
--
--   circleUnits(self, x, y, r, cnd_name) - select all matched units in the circle with center(x, y) and radius r
--     self - group instance
--     x - x coordinate of the circle center
--     y - y coordinate of the circle center
--     r - circle radius
--     cnd_name - a condition name, it calls the corresponding function in Condition to filter enum units.
--                It has IsEnemy, IsAlly, IsHero, IsUnit, and Nil currently.
--
--   addUnit(self, unit) - add a unit into the group
--     self - group instance
--     unit - a jass unit
--
--   clear(self) - clear all units in the group
--     self - group instance
--
--   loop(self, action, args) - call the action on all units in the group
--     self - group instance
--     action - an anomymous function, its argument list must have self and unit
--     args - argument list of any length
--
--   in(self, unit) - check whether the unit is in the group or not
--     self - group instance
--     unit - a jass unit
--     return - exists or not
--
--   getCount(self) - get the count of the units in the group
--     self - group instance
--     return - the count of the units
--
--   isEmpty(self) - check whether the group has no unit or not
--     self - group instance
--     return - empty or not
--
--   ignore(self, unit) - label the unit such that calling function enumUnitsInRange could ignore the unit
--     self - group instance
--     unit - a jass unit we want to ignore
------


local require = require
local ej = require 'war3.enhanced_jass'

local Group = require 'std.class'('Group')
Group._VERION = '1.2.0'

local InitArgs, GetDirection

-- 建構函式
function Group:_new(filter)
    return {
        _ignore_label_ = {},
        units_ = require 'std.array':new(),
    }
end

-- args = {
--     p:{} 中心點的座標
--     vars:{} 額外參數。如果區域需要angle這個參數的話，最後一個是它
--     type: 選取區域的類型
--     (optional) cnd: 選取單位的條件
--     (optional) filter: 比較對象
-- }
function Group:circleUnits(args)
    InitArgs(args)

    local enum_range_units = require 'war3.group.region'[args.type](args.p, args.vars, GetDirection(args))

    local enum_unit = ej.FirstOfGroup(enum_range_units)
    while enum_unit ~= 0 do
        if args.cnd(enum_unit) and (not self._ignore_label_[enum_unit]) and enum_unit ~= args.filter then
            self:addUnit(enum_unit)
        end

        ej.GroupRemoveUnit(enum_range_units, enum_unit)
        enum_unit = ej.FirstOfGroup(enum_range_units)
    end

    require('war3.group.manager').release(enum_range_units)

    return self
end

InitArgs = function(args)
    -- NOTE: 因為condtion會檢查filter，所以不能讓filter=nil
    args.filter = args.filter or 0

    -- 如果有條件，就生成條件表達式，沒有就直接生成一個真值的匿名函數
    if args.cnd then
        -- NOTE: 如果直接在匿名函數裡使用args.cnd加上讓 args.cnd 等於匿名函數，在函數被調用時，會因為args.cnd已經變成函數而造成內部調用args.cnd時發生錯誤。
        local cnd = args.cnd
        args.cnd = function(unit)
            return require('war3.group.condition')[cnd](unit, args.filter)
        end
    else
        args.cnd = function() return true end
    end
end

GetDirection = function(args)
    local Math = require 'std.math'

    if args.filter == 0 then
        return Math.pi / 2
    end

    -- NOTE: 如果目標點跟匹配源同個座標，認定為原地施法，因此角度會取匹配源的朝向
    if args.p.x == ej.GetUnitX(args.filter) and args.p.y == ej.GetUnitY(args.filter) then
        return ej.GetUnitFacing(args.filter)
    else
        return Math.angle(ej.GetUnitX(args.filter), ej.GetUnitY(args.filter), args.p.x, args.p.y)
    end
end

function Group:addUnit(unit)
    self.units_:append(unit)
    return self
end

function Group:_remove()
    self:clear()
    self.units_:remove()
end

function Group:clear()
    self._ignore_label_ = {}
    self.units_:clear()
    return self
end

-- action的格式要是
-- function(self, unit, ...)
--     body
-- end
-- 順序循環在執行改變array長度的動作時，由於最後一個元素會補到空位，而導致順序不正確
-- 只有2個元素的array，如果delete array[1]刪掉，會讀不到array[2]
-- 使用倒序循環就不會出現這樣的問題
function Group:loop(action, ...)
    for i = self.units_:size(), 1, -1 do
        action(self, self.units_[i], ...)
    end

    return self
end

function Group:removeUnit(unit)
    self.units_:erase(unit)
    return self
end

function Group:In(unit)
    return self.units_:exist(unit)
end

function Group:getCount()
    return self.units_:size()
end

function Group:isEmpty()
    return self.units_:isEmpty()
end

function Group:ignore(unit)
    self._ignore_label_[unit] = true
    return self
end

return Group
