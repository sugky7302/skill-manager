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
--   _blacklist_(table) - save ths marked units
--   _units_(queue) - save the jass units
--
-- Function:
--   new(self) - create a new group instance
--     self - class Group
--
--   remove(self) - remove ths group instance
--     self - group instance
--
--   circleUnits(self, args) - select all matched units in a assigned region
--     self - group instance
--     args - {
--       p:{x, y} 中心點的座標
--       vars: 額外參數。如果有多個參數，會以table方式儲存。
--       type: 選取區域的類型
--       (optional) cnd: 選取單位的條件，有IsEnemy、IsAlly、IsHero、IsUnit
--       (optional) filter: 比較對象
--     }
--
--   addUnit(self, unit) - add a unit into the group
--     self - group instance
--     unit - a jass unit
--
--   removeUnit(self, unit) - remove a unit from the group
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
--   In(self, unit) - check whether the unit is in the group or not
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
--   mark(self, unit) - mark an unit such that the unit will be ignored while the group is circling units.
--     self - group instance
--     unit - a jass unit
--
--   unmark(self, unit) - cancel the marked state of the unit
--     self - group instance
--     unit - a jass unit
------

local require = require
local ej = require 'war3.enhanced_jass'

local Group = require 'std.class'('Group')
Group._VERION = '1.2.0'

local InitArgs, GetDirection

function Group:_new()
    return {
        _blacklist_ = {},
        _units_ = require 'std.array':new(),
    }
end

function Group:circleUnits(args)
    InitArgs(args)

    require('war3.group.manager').traverse(
        require 'war3.group.region'[args.type](args.p, args.vars, GetDirection(args)),
        function(unit)
            return args.cnd(unit) and (not self._blacklist_[unit]) and unit ~= args.filter
        end,
        function(unit)
            self:addUnit(unit)
        end)

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
    -- NOTE: Facing出來是角度，因此要轉成弧度
    if args.p.x == ej.GetUnitX(args.filter) and args.p.y == ej.GetUnitY(args.filter) then
        return Math.pi * ej.GetUnitFacing(args.filter) / 180
    else
        return Math.angle(ej.GetUnitX(args.filter), ej.GetUnitY(args.filter), args.p.x, args.p.y)
    end
end

function Group:addUnit(unit)
    self._units_:append(unit)
    return self
end

function Group:removeUnit(unit)
    self._units_:erase(unit)
    return self
end

function Group:_remove()
    self:clear()
    self._units_:remove()
end

function Group:clear()
    self._blacklist_ = {}
    self._units_:clear()
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
    for i = self._units_:size(), 1, -1 do
        action(self, self._units_[i], ...)
    end

    return self
end

function Group:iterator()
    local i = self._units_:size() + 1
    local iter = function(t)
        i = i - 1
        if i == 0 then return nil end
        return t[i]
    end
    return iter, self._units_, 0
end

function Group:In(unit)
    return self._units_:exist(unit)
end

function Group:getCount()
    return self._units_:size()
end

function Group:isEmpty()
    return self._units_:isEmpty()
end

function Group:mark(unit)
    self._blacklist_[unit] = true
    return self
end

function Group:unmark(unit)
    self._blacklist_[unit] = nil
    return self
end

return Group
