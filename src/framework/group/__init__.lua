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
--   select(self, args) - select all matched units with args
--     self - group instance
--     args - { 單個直接寫在表裡，多個用table包住
--       (optional) selector: {
--         選取區域的類型(string)
--         p:{x, y} 中心點的座標
--         vars: 額外參數。如果有多個參數，會以table方式儲存。
--         comparser 比對單位
--       } 選取器
--       (optional) filter: {
--         name: 條件名
--         comparer: 比對單位
--       } 選取單位的條件
--       (optional) sorter: { name } 排序單位
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
local type, ipairs = type, ipairs
local ej = require 'war3.enhanced_jass'

local Group = require 'std.class'('Group')
Group._VERION = '1.3.0'

local InitArgs, GetDirection

function Group:_new()
    return {
        _blacklist_ = {},
        _units_ = require 'std.array':new(),
    }
end

function Group:select(args)
    InitArgs(args)

    local manager = require 'framework.group.manager'
    local region = require 'framework.group.region'

    if args.selector then
        if type(args.selector[1]) == 'string' then
            manager.traverse(
                region[args.selector[1]](args.selector[3], args.selector[2], GetDirection(args.selector[3], args.selector[4])),
                function(unit)
                    return (not self._blacklist_[unit]) and unit ~= args.selector[4]
                end,
                function(unit)
                    self:addUnit(unit)
                end
            )
        elseif type(args.selector[1]) == 'table' then
            for _, selector in ipairs(args.selector) do
                manager.traverse(
                    region[selector[1]](selector[3], selector[2], GetDirection(selector[3], selector[4])),
                    function(unit)
                        return (not self._blacklist_[unit]) and unit ~= args.selector[4]
                    end,
                    function(unit)
                        self:addUnit(unit)
                    end
                )
            end
        end
    end

    if args.filter then
        self:loop(function(unit)
            if type(args.filter[1]) == 'function' then
                if (not args.filter[1](unit)) or self._blacklist_[unit] or unit == args.filter[2] then
                    self:removeUnit(unit)
                end
            elseif type(args.filter[1]) == 'table' then
                for _, filter in ipairs(args.filter) do
                    if (not filter[1](unit)) or self._blacklist_[unit] or unit == filter[2] then
                        self:removeUnit(unit)
                    end
                end
            end
        end)
    end

    if args.sorter then
        local sort = table.sort
        for _, sorter in ipairs(args.sorter) do
            sort(self._units_, sorter)
        end
    end

    return self
end

InitArgs = function(args)
    -- 如果有條件，就生成條件表達式，沒有就直接生成一個真值的匿名函數
    if args.filter then
        local cnd
        if type(args.filter[1]) == "string" then
            cnd = args.filter[1]
            args.filter[1] = function(unit)
                return require('framework.group.condition')[cnd](unit, args.filter[2])
            end
        elseif type(args.filter[1]) == "table" then
            for i, filter in ipairs(args.filter) do
                args.filter[i][1] = function(unit)
                    return require('framework.group.condition')[filter[1]](unit, filter[2])
                end
            end
        end
    end
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

function Group:addUnit(unit)
    if not self._units_:exist(unit) then
        self._units_:append(unit)
    end

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
