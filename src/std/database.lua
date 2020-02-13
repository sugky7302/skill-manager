------
-- Database is an simple database for Lua. It can use CRUD methods to save your data.
--
-- Member:
--   _primary_key_(int) - the column number for the keyword, query method can use it
--   _associate_keys_(table) - a table which records the association beteween the keyword and the index
--   _column_(int) - record the column counts
--
-- Function:
--   new(self, column_count) - create a database which assigns the column count
--     self - class Database
--     column_count - the database max column count
--
--   append(self, ...) - a
--
--   query(self, key)
--
--   update(self, key, ...)
--
--   delete(self, key)
-----



local Database = {}
local Associate, GetData

function Database:new(column_count)
    local instance = {
        _association = {},
        _primary_key = 1,
    }

    for i = 1, column_count do
        instance[#instance + 1] = {}
    end

    setmetatable(instance, instance)
    instance.__index = self
    return instance
end

function Database:setPrimaryKey(index)
    self._primary_key = index
end

function Database:append(...)
    local args = {...}
    local index = #self[1] + 1
    local column

    -- 如果args超過欄位，則不填入
    -- 如果args不足，則設定false(用nil會造成'#'無法正確返回表長度)
    for i = 1, #self do
        column = self[i]
        column[index] = args[i] or false
    end

    Associate(self._association, args[self._primary_key], index)
end

Associate = function(tb, arg, id)
    local key = table.concat{arg, ""}
    tb[key] = id
end

function Database:queryAll(action)
    for i = 1, #self[1] do
        action(GetData(self, i))
    end
end

function Database:query(key)
    local type = type

    if type(key) == "number" then
        return GetData(self, key)
    end

    if type(key) == "string" then
        return GetData(self, self._association[key])
    end
end

GetData = function(self, key)
    local column
    local data = {[0]=key}

    for i = 1, #self do
        column = self[i]
        data[#data+1] = column[key]
    end

    if #data < 1 then
        return nil
    end
    
    return data
end

function Database:size()
    return #self[1]
end

return Database