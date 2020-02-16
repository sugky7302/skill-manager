------
-- Database is an simple database for Lua. It's suitable for small data. Maybe 1000 records.
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
--   append(self, ...) - add new datas into database
--     self - Database instance
--     ... - datas
--
--   query(self, key) - search for datas corresponding to the key
--     self - Database instance
--     key - index or the data in the primary column
--
--   update(self, key, ...) - search datas corresponding to the key
--     self - Database instance
--     key -  index or the data in the primary column
--     ... - datas
--
--   delete(self, key) - delete datas corresponding to the key
--     self - Database instance
--     key - index or the data in the primary column
-----

local Database = {}
local GetIndex

function Database:new(column_count, primary_key)
    local instance = {
        __index = self,
        _data_numbers_ = {}, -- 以主欄位資料當作索引，記錄資料編號
        _primary_key_ = primary_key or 1, -- 資料庫的主鍵，用於搜尋
        _row_ = 0,
        _column_ = column_count
    }

    for i = 1, column_count do
        instance[#instance + 1] = {}
    end

    return setmetatable(instance, instance)
end

function Database:append(...)
    local data = {...}

    -- 如果有相同主鍵就覆蓋資料
    if self._data_numbers_[data[self._primary_key_]] then
        return self:update(data[self._primary_key_], ...)
    end

    self._row_ = self._row_ + 1

    -- 如果data超過欄位，則不填入
    -- 如果data不足，則設定nil
    for i = 1, self._column_ do
        self[i][self._row_] = data[i]

        -- 將主欄位資料當作索引記錄資料編號
        if i == self._primary_key_ then
            self._data_numbers_[data[i]] = self._row_
        end
    end

    return self
end

function Database:query(key)
    local i = GetIndex(self, key)

    if not i then
        return nil
    end

    local data = {[0] = i}  -- 記錄資料的排名，有些會當成優先級使用

    for j = 1, self._column_ do
        data[#data + 1] = self[j][i]
    end

    -- 如果沒有資料回傳nil，好讓外部簡易判斷，不用再用 # 去檢查長度
    if not data[1] then
        return nil
    end

    return data
end

function Database:update(key, ...)
    local i = GetIndex(self, key)

    if not i then
        return self
    end

    for col, data in pairs({...}) do
        -- 有資料才更新
        if data then
            self[col][i] = data
        end
    end

    return self
end

function Database:delete(key)
    local i = GetIndex(self, key)

    if not i then
        return self
    end

    -- 移動的資料要重新記錄資料編號
    -- 一定要在資料轉換的前面，不然會搜尋不到舊的主鍵資料
    self._data_numbers_[self[self._primary_key_][self._row_]] = i
    self._data_numbers_[self[self._primary_key_][i]] = nil

    -- 最後一筆資料會補進空格
    for j = 1, self._column_ do
        self[j][i] = self[j][self._row_]
        self[j][self._row_] = nil
    end

    self._row_ = self._row_ - 1
    return self
end

GetIndex = function(self, key)
    local type = type

    if type(key) == 'number' then
        return key
    elseif type(key) == 'string' then
        return self._data_numbers_[key]
    end
end

return Database
