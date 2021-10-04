--[[
  cls is an extension recorded extra attributes of unit, hero or item.
  It can operate attributes of the object via simple setting and getting.

  Required:
    red_black_tree

  Note:
    An attribute script is reserved 4 keywords, set(set value function), get(get value function),
    format(a text of describing the attribute, N would be replaced by a number ),
    priority(priority for ranking).

  Member:
    _object_ - record the operated object
    _rank_ - sort all attributes by the priority.
    _package_ - record external package

  Function:
    new(self) - create a new attribute instance
      self - Class cls

    setPackage(self, path) - load a external package from the path
      self - attribute instance
      path - the package path

    iterator(self) - Traverse all elements in _rank_ by Lua iterator
      self - attribute instance

    getDescription(self, key) - get the attribute description by the key
      self - attribute instance
      key - attribute name

    getProperty(self, key, property_name) - get the attribute extra property in the database by the key
      self - attribute instance
      key - attribute name
      property_name - the extra property name

    add(self, key, value) - add the value into the attribute which is represented by the key
      self - attribute instance
      key - attribute name
      value - attribute value

    set(self, key, value) - set the value into the attribute which is represented by the key
      self - attribute instance
      key - attribute name
      value - attribute value

    get(self, key) - get the attribute value by the key
      self - attribute instance
      key - attribute name

    delete(self, key) - delete the attribute by the key
      self - attribute instance
      key - attribute name

    sum(self, key) - get the summation of values by the key
      self - attribute instance
      key - attribute name
--]]

local require = require
local select = select
local pcall = pcall
local xpcall = xpcall

local cls = require 'std.class'('Attribute')

-- 指定符號
TOTAL = "!"
PERCENT = "%"
FIX = "*"

local ParseKey, CreateAttribute, Sync, GetFormat

function cls:_new(object)
    return {
        _rank_ = {},
        _object_ = object,
        _package_ = nil
    }
end

function cls:setPackage(path)
    local status, retval = pcall(require, path)  -- 搜不到會回傳 false
    self._package_ = status and retval
    return self
end

function cls:iterator()
    local iter = function(t, i)
        return next(t, i)
    end
    return iter, self._rank_, nil
end

-- 獲得外部資料庫的屬性
function cls:getProperty(key, property_name)
    local name = ParseKey(key)

    if not (self._package_ and self._package_[name]) then
        return nil
    end

    return self._package_[name][property_name]
end

-- NOTE: 不儲存描述格式是因為不管基本的描述格式還是外部資料庫的描述格式都已經有字串存在lua了，多存一個只是佔空間。
--       用搜尋取代記憶可以減少空間的浪費，並且不會慢到哪裡去。 - 2020-04-10
function cls:getDescription(key)
    local name = ParseKey(key)

    -- NOTE: gsub會返回兩個值，一個是替換後的字串，另一個是替換後的次數。
    --   如果在外面加一層，便只回傳替換後的字串，使用select(1, ...)沒辦法達到這樣的效果。
    return (string.gsub(GetFormat(self, name), 'N', self:get(name)))
end

GetFormat = function(self, name)
    return select(2,
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

-- key=屬性名，提昇數值；+% 提昇百分比；+*提昇固定值
-- NOTE: 如果用提昇總值的方法，會產生提昇順序不同，總值不同的問題。 - 2021-10-04
-- NOTE: key=屬性名，表示要提升總值(數值*百分比)；key=屬性名%，只會提升百分比 - 2020-02-27
function cls:add(key, value)
    return self:set(key, self:get(key) + value)
end

-- key=屬性名，提昇數值；+% 提昇百分比；+*提昇固定值
-- NOTE: 如果用提昇總值的方法，會產生提昇順序不同，總值不同的問題。 - 2021-10-04
-- NOTE: key=屬性名，表示要設定總值(數值*百分比)；key=屬性名%，只會設定百分比 - 2020-02-27
function cls:set(key, value)
    local name, sign = ParseKey(key)

    CreateAttribute(self, name)
    Sync(self, name)

    if sign == PERCENT then
        self[name][2] = value
    elseif sign == FIX then
        self[name][3] = value
    else
        self[name][1] = value
    end

    -- 調用設值函數
    pcall(function()
        self._package_[name].set(self, value)
    end)

    return self
end

-- key=屬性名，提昇數值；+% 提昇百分比；+*提昇固定值
-- NOTE: 如果用提昇總值的方法，會產生提昇順序不同，總值不同的問題。 - 2021-10-04
-- NOTE: key=屬性名，表示要取得總值(數值*百分比)；key=屬性名%，只會取得百分比 - 2020-02-27
function cls:get(key)
    local name, sign = ParseKey(key)

    CreateAttribute(self, name)
    Sync(self, name)

    if sign == PERCENT then
        return self[name][2]
    elseif sign == FIX then
        return self[name][3]
    elseif sign == TOTAL then
        return self:sum(name)
    end

    return self[name][1]
end

CreateAttribute = function(self, name)
    if self[name] then
        return
    end

    local key
    if self._package_ and self._package_[name] and self._package_[name].priority then
        key = self._package_[name].priority
    else
        -- NOTE: 因為 # 只會搜到連續空間的最後一格，因此 +1 一定會是空格
        key = #self._rank_ + 1
    end

    -- 如果priority的位置上有值，就把它搬到空位
    if self._rank_[key] then
        local new_key = #self._rank_ + 1
        self._rank_[new_key] = self._rank_[key]
        self[self._rank_[key]][0] = new_key
    end

    -- 在紅黑數的索引（預設0）、數值、百分比、固定值
    self[name] = {[0] = key, 0, 0, 0}

    -- 把優先級加入索引表
    self._rank_[key] = name
end

-- NOTE: 利用取值函數來同步遊戲內的數值和紀錄值。如果沒有取值函數，就回傳0，保證使用它的函數不會出錯。 - 2021-10-04
Sync = function(self, name)
    -- 因為pcall第一個參數一定要是函數，但 get 沒有設定就不是函數，所以會報錯
    pcall(function()
        self[name][1] = (self._package_[name].get(self) - self[name][3]) / ( 1 + self[name][2] / 100)
    end)
end

function cls:sum(name)
    return self[name] and self[name][1] * (1 + self[name][2] / 100) + self[name][3] or 0
end

function cls:delete(key)
    local name = ParseKey(key)
    self._rank_[self[name][0]] = nil
    self[name] = nil
end

ParseKey = function(key)
    local string = string
    return string.match(key, table.concat{'[^%',PERCENT,FIX,TOTAL,']+'}), string.sub(key, -1, -1)
end

return cls
