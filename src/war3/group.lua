------
-- Group is an extension of jass group, it integrates the most jass group feature
-- and strengthens the user experience.
--
-- Required:
--   enhanced_jass
--   queue
--
-- Member:
--   _ignore_label_(table) - save ths ignored units
--   _object_(jass group object) - save the new jass group object
--   units_(queue) - save the jass units
--   filter_(jass unit object) - record a jass unit to filter enum units
--
-- Function:
--   new(self, filter) - create a new group instance
--     self - class Group
--     filter - a jass unit as the condition which filters enum units
--
--   remove(self) - remove ths group instance
--     self - group instance
-- 
--   enumUnitsInRange(self, x, y, r, cnd_name) - select all eligible units in the circle with center(x, y) and radius r
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
--     action - an anomymous function, its argument list must have self and index i
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
local Queue = require 'std.queue'
local ej = require 'war3.enhanced_jass'

local Group = require 'std.class'('Group')
Group._VERION = '1.1.0'

-- constants
local QUANTITY = 128

-- 使用queue是因為要重複利用we的單位組，減少ram的開銷
local recycle_group = Queue:new()
local GetEmptyGroup, RecycleGroup

local Condition = {
    IsEnemy = function(enumer, filter)
        return ej.GetUnitState(enumer, ej.UNIT_STATE_LIFE) > 0.3 and ej.IsUnitEnemy(enumer, ej.GetOwningPlayer(filter))
    end,
    IsAlly = function(enumer, filter)
        return ej.GetUnitState(enumer, ej.UNIT_STATE_LIFE) > 0.3 and ej.IsUnitAlly(enumer, ej.GetOwningPlayer(filter))
    end,
    IsHero = function(enumer, filter)
        return ej.IsUnitType(enumer, ej.UNIT_TYPE_HERO)
    end,
    IsUnit = function(enumer, filter)
        return not (ej.IsUnitType(enumer, ej.UNIT_TYPE_HERO))
    end,
    Nil = function(enumer, filter)
        return true
    end
}

-- 建構函式
function Group:_new(filter)
    return {
        _ignore_label_ = {},
        _object_ = GetEmptyGroup(),
        units_ = require 'std.array':new(),
        filter_ = filter or 0 -- 如果filter沒有傳參，要設定成0才不會出問題
    }
end

-- cnd_name 有 IsEnemy、IsAlly、IsHero、IsUnit、Nil
function Group:enumUnitsInRange(x, y, r, cnd_name)
    local enum_range_units = GetEmptyGroup()

    -- 選取比原先範圍大一些的區域，好讓有些處在範圍邊緣的單位能夠被正確選取
    ej.GroupEnumUnitsInRange(enum_range_units, x, y, r + 10, nil)

    local enum_unit = ej.FirstOfGroup(enum_range_units)
    while ej.H2I(enum_unit) ~= 0 do
        if
            Condition[cnd_name](enum_unit, self.filter_) and (not self._ignore_label_[ej.H2I(enum_unit) .. '']) and
                ej.H2I(enum_unit) ~= ej.H2I(self.filter_)
        then
            self:addUnit(enum_unit)
        end

        ej.GroupRemoveUnit(enum_range_units, enum_unit)

        enum_unit = ej.FirstOfGroup(enum_range_units)
    end

    RecycleGroup(enum_range_units)

    return self
end

GetEmptyGroup = function()
    -- 用 ">" 是因為這個函式會減少recycle_group的數量
    if recycle_group:size() > QUANTITY then
        return false
    end

    if recycle_group:isEmpty() then
        return ej.CreateGroup()
    end

    local empty_group = recycle_group:front()
    recycle_group:pop_front()

    return empty_group
end

function Group:addUnit(unit)
    ej.GroupAddUnit(self._object_, unit)
    self.units_:append(unit)
    return self
end

function Group:_remove()
    RecycleGroup(self._object_)
    self:clear()
    self.units_:remove()
end

RecycleGroup = function(group)
    -- 用 ">=" 是因為這個函式會增加recycle_group的數量
    if recycle_group:size() >= QUANTITY then
        ej.DestroyGroup(group)
    else
        recycle_group:push_back(group)
    end
end

function Group:clear()
    self:loop(
        function(this, i)
            -- false self[i]
            -- true self.units_[i]
            this:removeUnit(this.units_[i])
        end
    )

    ej.GroupClear(self._object_)
    self.units_:clear()
    return self
end

-- action的格式要是
-- function(self, i, ...)
--     body
-- end
-- 順序循環在執行改變array長度的動作時，由於最後一個元素會補到空位，而導致順序不正確
-- 只有2個元素的array，如果delete array[1]刪掉，會讀不到array[2]
-- 使用倒序循環就不會出現這樣的問題
function Group:loop(action, ...)
    for i = self.units_:size(), 1, -1 do
        action(self, i, ...)
    end

    return self
end

function Group:removeUnit(unit)
    ej.GroupRemoveUnit(self._object_, unit)
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
    self._ignore_label_[ej.H2I(unit) .. ''] = true
    return self
end

return Group
