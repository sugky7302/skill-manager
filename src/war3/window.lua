local require = require
local type = type
local math = math
local ej = require 'war3.enhanced_jass'
local event_manager = require 'lib.event_manager':new()
local Listener = require 'war3.listener'

local Window = require 'std.class'('Window')
local Refresh, SetTitle, CreateItem, CreateOperator, FixPageNumber

event_manager:addEvent(
    '對話框-被點擊',
    'GetClickedDialog GetClickedButton',
    function(_, dialog, button)
        local window = Window(dialog)

        if window:isPrev(button) then
            window:prev()
        elseif window:isNext(button) then
            window:next()
        end
    end
)

function Window:_new(player, max_length_for_one_page)
    local this = {
        _object_ = ej.DialogCreate(), -- NOTE: 不能在初始化時創建
        _user_ = player,
        _lists_ = {},
        _items_ = {},
        _page_number_ = 1,
        _length_ = max_length_for_one_page or 6,
        _operator_ = {false, false, false}, -- 關閉鈕、下一頁、上一頁
        _is_opened_ = false,
        _title_ = nil
    }

    -- 將實例綁在類別上，方便呼叫
    self[this._object_] = this

    -- 對此物件綁定操作鈕的觸發
    Listener:new(event_manager)('對話框-被點擊')(this._object_)

    return this
end

function Window:__call(object)
    return Window[object]
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

function Window:close()
    ej.DialogDisplay(self._user_, self._object_, false)
    self._is_opened_ = false
    return self
end

function Window:findText(key)
    if type(key) == 'string' then
        return key
    end

    if key > #self._lists_ then
        return self._lists_[self._items_[key]]
    end

    return self._lists_[key]
end

function Window:setTitle(title)
    self._title_ = title
    Refresh(self)
    return self
end

function Window:open()
    ej.DialogDisplay(self._user_, self._object_, true)
    self._is_opened_ = true
    Refresh(self)
    return self
end

function Window:next()
    self._page_number_ = self._page_number_ + 1
    Refresh(self)
    return self
end

function Window:prev()
    self._page_number_ = self._page_number_ - 1
    Refresh(self)
    return self
end

function Window:add(text)
    self._lists_[#self._lists_ + 1] = text
    Refresh(self)
    return self
end

function Window:delete(key)
    local number = self:findRank(key)
    if number then
        table.remove(self._lists_, number)
        FixPageNumber(self)
        Refresh(self)
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

function Window:setLength(new_length)
    self._length_ = new_length
    FixPageNumber(self)
    Refresh(self)
    return self
end

FixPageNumber = function(self)
    -- NOTE: 修正後可能會產生該頁沒選項的情況，這時候必須將頁碼調到最後一頁
    self._page_number_ = math.min(self._page_number_, math.ceil(#self._lists_ / self._length_))
end

Refresh = function(self)
    self:clear()
    SetTitle(self)
    CreateItem(self)
    CreateOperator(self)

    if self._is_opened_ then
        ej.DialogDisplay(self._user_, self._object_, true)
    end
end

SetTitle = function(self)
    if self._title_ then
        ej.DialogSetMessage(self._object_, self._title_)
    end
end

CreateItem = function(self)
    local item
    for i = (self._page_number_ - 1) * self._length_ + 1, math.min(self._page_number_ * self._length_, #self._lists_), 1 do
        item = ej.DialogAddButton(self._object_, self._lists_[i], 0)
        self._items_[item] = i
    end
end

-- NOTE: hotkey是ascii表查詢該按鍵於10進位的值
-- NOTE: 上一頁、下一頁沒有新建的話，要記得清空舊的物件，不然id會碰撞到，就莫名其妙觸發了
CreateOperator = function(self)
    local concat = table.concat

    if self._page_number_ > 1 then
        self._operator_[3] =
            ej.DialogAddButton(self._object_, concat {'|cff00ff00↑|r(p.', self._page_number_ - 1, ')'}, 0)
    else
        self._operator_[3] = false
    end

    if self._page_number_ * self._length_ < #self._lists_ then
        self._operator_[2] =
            ej.DialogAddButton(self._object_, concat {'|cff00ff00↓|r(p.', self._page_number_ + 1, ')'}, 0)
    else
        self._operator_[2] = false
    end

    self._operator_[1] = ej.DialogAddButton(self._object_, '|cffff0000x|r', 0)
end

function Window:_remove()
    self:reset()
    ej.DialogDestroy(self._object_)
end

function Window:reset()
    self:clear()
    self._lists_ = {}
    return self
end

function Window:clear()
    ej.DialogDisplay(self._user_, self._object_, false)
    ej.DialogClear(self._object_)
    self._items_ = {}
    return self
end

return Window
