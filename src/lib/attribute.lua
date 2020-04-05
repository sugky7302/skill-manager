------
-- Attribute is an extension for unit, hero, and item that needs to record additional attributes.
-- It can opperate attributes of the object via simple setting and getting.
--
-- Required:
--   red_black_tree
--
-- Member:
--   _rank_ - sort all attributes by the priority
--
-- Function:
--   new(self) - create a new attribute instance
--     self - Class Attribute
--
--   setPackage(self, path) - load a external package from the path
--     self - attribute instance
--     path - the package path
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
--
--   delete(self, key) - delete the attribute by the key
--     self - attribute instance
--     key - attribute name
------

local require = require
local select = select
local pcall = pcall
local xpcall = xpcall
local Attribute = require 'std.class'('Attribute')
local ParseKey, CreateAttribute, SetValue, SetAttributeToObject, GetAttributeFromObject

function Attribute:_new(object)
    return {
        _rank_ = require 'std.red_black_tree':new(),
        _object_ = object,
        _package_ = nil
    }
end

function Attribute:setPackage(path)
    self._package_ = select(2, xpcall(require, debug.traceback, path))
    return self
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

-- NOTE: key=屬性名，表示要提升總值(數值*百分比)；key=屬性名%，只會提升百分比 - 2020-02-27
function Attribute:add(key, value)
    local name, has_percent = ParseKey(key)
    CreateAttribute(self, name)

    -- NOTE: 會把數值和百分比分開處理的原因是數值可能會和遊戲實際數值不同，導致設值會有誤差，
    --       因此add必須要先利用實際數值校正，後續的運算才會正確；而百分比不會有這樣的問題，
    --       直接加總即可 - 2020-02-26
    if has_percent then
        return self:set(key, self[name][2] + value)
    else
        return self:set(key, self:get(key) + value)
    end
end

-- NOTE: key=屬性名，表示要設定總值(數值*百分比)；key=屬性名%，只會設定百分比 - 2020-02-27
function Attribute:set(key, value)
    local name, has_percent = ParseKey(key)

    CreateAttribute(self, name)
    SetValue(self, name, has_percent, value)
    SetAttributeToObject(self, name)
    Ranking(self, name)

    return self
end

SetValue = function(self, name, has_percent, value)
    if has_percent then
        self[name][2] = value
    else
        self[name][1] = value / (1 + self[name][2] / 100)
    end
end

SetAttributeToObject = function(self, name)
    if
        pcall(
            function()
                return self._package_[name].set
            end
        )
     then
        self._package_[name].set(self, self[name][1] * (1 + self[name][2] / 100))
    end
end

Ranking = function(self, name)
    if not self._rank_:find(self[name][0]) then
        self._rank_:insert(self[name][0], name)
    end
end

-- NOTE: key=屬性名，表示要取得總值(數值*百分比)；key=屬性名%，只會取得百分比 - 2020-02-27
function Attribute:get(key)
    local name, has_percent = ParseKey(key)

    CreateAttribute(self, name)

    if has_percent then
        return self[name][2]
    end

    return GetAttributeFromObject(self, name)
end

CreateAttribute = function(self, name)
    if not self[name] then
        local key =
            select(
            2,
            xpcall(
                function()
                    -- NOTE: table搜不到priority只會回傳nil，並不會跳到catch
                    --   因此只要是nil就回傳跟catch一樣的結果
                    return self._package_[name].priority or self._rank_:size() + 1
                end,
                function()
                    return self._rank_:size() + 1
                end
            )
        )
        -- 在紅黑數的索引（預設0）、數值、百分比
        self[name] = {[0] = key, 0, 0}
        self[name][1] = GetAttributeFromObject(self, name)
    end
end

GetAttributeFromObject = function(self, name)
    if
        pcall(
            function()
                return self._package_[name].get
            end
        )
     then
        return self._package_[name].get(self)
    else
        return self[name][1] * (1 + self[name][2] / 100)
    end
end

function Attribute:delete(key)
    local name = ParseKey(key)

    if self._rank_:find(self[name][0]) then
        self._rank_:delete(self[name][0])
    end

    self[name] = nil
end

ParseKey = function(key)
    local string = string
    return string.match(key, '[^%%]+'), string.sub(key, -1, -1) == '%'
end

return Attribute
