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

-- TODO: 缺少屬性事件的引用
local require = require
local DB = require 'data.attribute_database'
local Attribute = require 'std.class'("Attribute")
local ParseKey, CreateAttribute

function Attribute:_new(self)
    return {
        _rank_ = require 'std.list':new(),
        _data_ = {},
    }
end

function Attribute:add(key, value)
    self:set(key, self:get(key) + value)
    return self
end

function Attribute:set(key, value)
    local name, has_percent = ParseKey(key)
    if not self[name] then
        CreateAttribute(self, name)
    end

    if has_percent then
        self[name][2] = value
    else
        self[name][1] = value
    end

    -- TODO: 觸發設值事件
    -- TODO: 重新排名

    return self
end

CreateAttribute = function(self, name)
    self[name] = {0, 0, ""}  -- 數值、百分比、文字
    -- TODO: 觸發取值事件
end

function Attribute:get(key)
    local name = ParseKey(key)

    if not self[name]  then
        return nil
    end

    -- 特殊屬性直接回傳
    local type = type
    if type(self[name]) == 'string' or type(self[name]) == 'table' then
        return self[name]
    end

    -- TODO: 有取值事件就回傳

    return self[name][1] * (1 + self[name][2])
end

ParseKey = function(key)
    local string = string
    return string.match(key, "[^%%]+"), string.sub(key, -1, -1) == "%"
end

function Attribute:iterator()
    local iter = self._rank_:iterator()
    return function()
        local i, node = iter()

        if not i then
            return nil
        end

        return i, node:getData()
    end
end

return Attribute
