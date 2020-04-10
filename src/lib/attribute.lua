------
-- Attribute is an extension for unit, hero, and item that needs to record additional attributes.
-- It can opperate attributes of the object via simple setting and getting.
--
-- Required:
--   red_black_tree
--
-- Note:
--   An attribute script is reserved 4 keywords, set(set value function), get(get value function),
--   format(format for describing the attribute, N represents the position to be replaced by a number ),
--   priority(priority for ranking).
--
-- Member:
--   _object_ - record the operated object
--   _rank_ - sort all attributes by the priority
--   _package_ - record external package
--
-- Function:
--   new(self) - create a new attribute instance
--     self - Class Attribute
--
--   setPackage(self, path) - load a external package from the path
--     self - attribute instance
--     path - the package path
--
--   iterator(self) - Traverse all elements in _rank_ by Lua iterator
--     self - attribute instance
--
--   getDescription(self, key) - get the attribute description by the key
--     self - attribute instance
--     key - attribute name
--
--   getProperty(self, key, property_name) - get the attribute extra property in the database by the key
--     self - attribute instance
--     key - attribute name
--     property_name - the extra property name
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
local ParseKey, CreateAttribute, SetValue, SetAttributeToObject, GetAttributeFromObject, GetFormat

function Attribute:_new(object)
    return {
        _rank_ = require 'std.red_black_tree':new(),
        _object_ = object,
        _package_ = nil
    }
end

function Attribute:setPackage(path)
    self._package_ =
        select(
        2,
        xpcall(
            require,
            function()
                return nil
            end,
            path
        )
    )
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

-- NOTE: 不儲存描述格式是因為不管基本的描述格式還是外部資料庫的描述格式都已經有字串存在lua了，多存一個只是佔空間。
--       用搜尋取代記憶可以減少空間的浪費，並且不會慢到哪裡去。 - 2020-04-10
function Attribute:getDescription(key)
    local name = ParseKey(key)

    -- NOTE: gsub會返回兩個值，一個是替換後的字串，另一個是替換後的次數。
    --   如果在外面加一層，便只回傳替換後的字串，使用select(1, ...)沒辦法達到這樣的效果。
    return (string.gsub(GetFormat(self, name), 'N', self:get(name)))
end

GetFormat = function(self, name)
    return select(
        2,
        xpcall(
            function()
                return self._package_[name].format
            end,
            function()
                return '+N ' .. name
            end
        )
    )
end

-- 獲得外部資料庫的屬性
function Attribute:getProperty(key, property_name)
    local name = ParseKey(key)

    if not (self._package_ and self._package_[name]) then
        return nil
    end

    return self._package_[name][property_name]
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
    return select(
        2,
        xpcall(
            function()
                return self._package_[name].get(self)
            end,
            function()
                return self[name][1] * (1 + self[name][2] / 100)
            end
        )
    )
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
