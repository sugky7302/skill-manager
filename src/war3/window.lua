local require = require
local type = type
local ej = require 'war3.enhanced_jass'

local Window = require 'std.class'('Window')
local Update

function Window:_new(player, max_length_for_one_page)
    local this = {
        _object_ = ej.DialogCreate(), -- NOTE: 不能在初始化時創建
        _user_ = player,
        _lists_ = nil,
        _items_ = nil,
        _page_number_ = 1,
        _length_ = max_length_for_one_page or 6,
        _operator_ = {false, false, false}, -- 關閉鈕、下一頁、上一頁
        _is_opened_ = false,
    }

    -- 將實例綁在類別上，方便呼叫
    self[player] = this

    return this
end

function Window:__call(player)
    return Window[player] or self:new(player)
end

function Window:isPrev(item)
    return self._operator_[3] == item
end

function Window:isNext(item)
    return self._operator_[2] == item
end

function Window:getObject()
    return self._object_
end

function Window:setTitle(title)
    ej.DialogSetMessage(self._object_, title)
    return self
end

function Window:open()
    ej.DialogDisplay(self._user_, self._object_, true)
    self._is_opened_ = true
    return self
end

function Window:close()
    ej.DialogDisplay(self._user_, self._object_, false)
    self._is_opened_ = false
    return self
end

function Window:findText(key)
    if not self._lists_ then
        return nil
    end

    if type(key) == 'string' then
        return key
    end

    if key > #self._lists_ then
        return self._lists_[self._items_[key]]
    end
    
    return self._lists_[key]
end

function Window:setLength(new_length)
    self._length_ = new_length
    Update(self)
    return self
end

function Window:next()
    self._page_number_ = self._page_number_ + 1
    Update(self)
    return self
end

function Window:prev()
    self._page_number_ = self._page_number_ - 1
    Update(self)
    return self
end

function Window:add(text)
    if not self._lists_ then
        self._lists_ = {}
    end

    self._lists_[#self._lists_+1] = text
    Update(self)

    return self
end

function Window:delete(key)
    if not self._lists_ then
        return
    end

    local number = self:findRank(key)
    if number then
        table.remove(self._lists_, number)
        Update(self)
    end

    return self
end

function Window:findRank(key)
    if type(key) == 'string' then
        for i, text in ipairs(self._lists_) do
            if key == text then
                return i
            end
        end
    end

    if key > #self._lists_ then
        return self._items_[key]
    end
    
    return key
end

Update = function(self)
    self:clear()

    local item
    for i = (self._page_number_-1) * self._length_ + 1, math.min(self._page_number_ * self._length_, #self._lists_) do
        item = ej.DialogAddButton(self._object_, self._lists_[i], 0)
        self._items_[item] = i
    end

    -- 添加操作鈕
    if self._page_number_ > 1 then
        self._operator_[3] = ej.DialogAddButton(self._object_, '|cff00ff00↑', 0)
    end

    if self._page_number_ * self._length_ < #self._lists_ then
        self._operator_[2] = ej.DialogAddButton(self._object_, '|cff00ff00↓', 0)
    end

    self._operator_[1] = ej.DialogAddButton(self._object_, '|cffff0000x', 0)

    if self._is_opened_ then
        ej.DialogDisplay(self._user_, self._object_, true)
    end
end

function Window:_remove()
    self:clear()
    ej.DialogDestroy(self._object_)
end

function Window:clear()
    ej.DialogDisplay(self._user_, self._object_, false)
    ej.DialogClear(self._object_)
    self._items_ = {}
    return self
end

return Window
