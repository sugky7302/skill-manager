------
-- cls is an extension of jass group, it integrates the most jass group features
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
--     self - class cls
--
--   remove(self) - remove ths group instance
--     self - group instance
--
--   select(self, selector) - select all matched units with specified selectors
--     self - group instance
--     selector - { 多個以table包住
--       選取區域的類型(string)
--       p:{x, y} 中心點的座標
--       vars: 額外參數。如果有多個參數，會以table方式儲存。
--       comparser 比對單位
--     }
--   filter(self, filter) - filter unmatached units with specified filter
--     self - group instance
--     filter - {
--       name: 條件名
--       comparer: 比對單位
--     }
-- 
--   sort(self, sorter) - sort units with specified sorter
--     self - group instance
--     sorter: { name } 排序單位
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
--   size(self) - get the number of the units in the group
--     self - group instance
--     return - the number of the units
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
local type, ipairs = type, ipairs
local ej = require 'war3.enhanced_jass'

local cls = require 'std.class'('Group')
cls._VERION = '1.3.0'

local GetDirection

function cls:_new()
    return {
        _blacklist_ = {},
        _units_ = require 'std.array':new(),
    }
end

function cls:select(selector)
    if type(selector[1]) == 'string' then
        selector = {selector}
    end

    local manager, region = require 'framework.group.manager', require 'framework.group.region'
    for _, args in ipairs(selector) do
        manager.traverse(
            region[args[1]](args[2], args[3], GetDirection(args[2], args[4])),
            function(unit)
                return not (self._blacklist_[unit] or unit == (args[4] or 0))
            end,
            function(unit)
                self:addUnit(unit)
            end
        )
    end

    return self
end

GetDirection = function(p, comparser)
    local Math = require 'std.math'

    if not comparser or comparser == 0 then
        return Math.pi / 2
    end

    -- NOTE: 如果目標點跟匹配源同個座標，認定為原地施法，因此角度會取匹配源的朝向
    -- NOTE: Facing出來是角度，因此要轉成弧度
    if p.x == ej.GetUnitX(comparser) and p.y == ej.GetUnitY(comparser) then
        return Math.pi * ej.GetUnitFacing(comparser) / 180
    else
        return Math.angle(ej.GetUnitX(comparser), ej.GetUnitY(comparser), p.x, p.y)
    end
end

function cls:filter(filter)
    if type(filter[1]) == "string" or type(filter[1]) == "function" then
        filter = {filter}
    end

    local Cnd
    for unit in self:iterator() do
        for _, args in ipairs(filter) do
            Cnd = type(args[1]) == "function" and args[1] or require('framework.group.condition')[args[1]]
            if (not Cnd(unit, self._units_)) or  self._blacklist_[unit] or unit == (args[2] or 0) then
                self:removeUnit(unit)
                break
            end
        end
    end

    return self
end

function cls:sort(sorter)
    local sort = table.sort
    for _, fn in ipairs(sorter) do
        sort(self._units_, fn)
    end

    return self
end

function cls:addUnit(unit)
    if not self._units_:exist(unit) then
        self._units_:append(unit)
    end

    return self
end

function cls:removeUnit(unit)
    self._units_:erase(unit)
    return self
end

function cls:_remove()
    self:clear()
    self._units_:remove()
end

function cls:clear()
    self._blacklist_ = {}
    self._units_:clear()
    return self
end

function cls:iterator()
    local i = self._units_:size() + 1
    local iter = function(t)
        i = i - 1
        if i == 0 then return nil end
        return t[i]
    end
    return iter, self._units_, 0
end

function cls:In(unit)
    return self._units_:exist(unit)
end

function cls:size()
    return self._units_:size()
end

function cls:isEmpty()
    return self._units_:isEmpty()
end

function cls:mark(unit)
    self._blacklist_[unit] = true
    return self
end

function cls:unmark(unit)
    self._blacklist_[unit] = nil
    return self
end

return cls
