------
-- Attribute is an extension for unit, hero, and item that needs to record additional attributes.
-- It can opperate attributes of the object via simple setting and getting.
--
-- Required:
--   list
--
-- Member:
--   _rank_ - sort all attributes by the priority
--   _data_ - record datas for all attributes
--
-- Function:
--   new(self) - create a new attribute instance
--     self - Class Attribute
--
--   add(self, key, value) - add the value into the attribute which is represented by the key
--     self - attribute instance
--     key - attribute name
--     value - attribute value
--
--   set(self, key, value) - set the value into the attribute which is represented by the key
--     self - attribute instance
--     key - attribute name
--     value - attribute value
--
--   get(self, key) - get the attribute value by the key
--     self - attribute instance
--     key - attribute name
------

local require = require
local DB = require 'data.attribute.database'
local Event = select(2, xpcall(require, debug.traceback, 'data.attribute.init'))
local Attribute = require 'std.class'('Attribute')
local ParseKey, CreateAttribute, SetValue, TriggerSetEvent, TriggerGetEvent

function Attribute:_new(object)
    return {
        _rank_ = require 'std.red_black_tree':new(),
        _data_ = {},
        _object_ = object,
    }
end

function Attribute:iterator()
    local iter = self._rank_:iterator()
    return function()
        local name = iter()

        if not name then
            return nil
        end

        return name, self[name]
    end
end

function Attribute:add(key, value)
    local name, has_percent = ParseKey(key)
    CreateAttribute(self, name)
    return self:set(key, self[name][has_percent and 2 or 1] + value) -- 利用三元運算符判斷要讀數值還是百分比
end

function Attribute:set(key, value)
    local name, has_percent = ParseKey(key)

    CreateAttribute(self, name)
    SetValue(self, name, has_percent, value)
    TriggerSetEvent(self, name, value)
    Ranking(self, name)

    return self
end

CreateAttribute = function(self, name)
    if not self[name] then
        --            數值、百分比、屬性文字敘述
        self[name] = {0, 0, DB:query(name) and DB:query(name)[2] or ""}  -- NOTE: 預設成空字串是怕要print的時候，若是nil的話還要額外判斷，更麻煩。
        self[name][1] = TriggerGetEvent(self, name)
    end
end

SetValue = function(self, name, has_percent, value)
    self[name][has_percent and 2 or 1] = value
end

TriggerSetEvent = function(self, name, value)
    if Event[name] and Event[name].set then
        Event[name].set(self, value)
    end
end

Ranking = function(self, name)
    local data = DB:query(name)
    if data and not self._rank_:find(data[0]) then
        self._rank_:insert(data[0], name)
    end
end

function Attribute:get(key)
    local name = ParseKey(key)

    if not self[name] then
        return 0
    end

    return TriggerGetEvent(self, name)
end

ParseKey = function(key)
    local string = string
    return string.match(key, '[^%%]+'), string.sub(key, -1, -1) == '%'
end

TriggerGetEvent = function(self, name)
    if Event[name] and Event[name].get then
        return Event[name].get(self)
    else
        return self[name][1] * (1 + self[name][2] / 100)
    end
end

return Attribute
