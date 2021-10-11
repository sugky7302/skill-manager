local require = require
local Table = require 'std.table'
local Event = require 'lib.event'
local EventManager = require 'std.class'("EventManager")
local AddArgs

function EventManager:_new()
    if not self._instance_ then
        self._instance_ = {
            _events_ = {},
        }
    end

    return self._instance_
end

function EventManager:addEvent(name, args, callback)
    -- NOTE: 內部新建Event實例，外部就不用特別require - 2020-03-04
    local event = Event:new(name, args, callback)

    local event_queue = self._events_[event.name_]
    if not event_queue then
        event_queue = {args={}}
        self._events_[event.name_] = event_queue
    end

    event_queue[#event_queue+1] = event
    AddArgs(event_queue.args, event.args_)

    return event
end

AddArgs = function(arg_list, args)
    local string = string
    local arg_string

    if string.len(args) == 0 then
        return false
    end

    -- 先將arg_list從table轉成由空格作為分隔符的字串，再用正則表達式搜尋
    -- 這樣會比用arg一一比對arg_list的元素快
    for arg in string.gmatch(args, "%w+") do
        arg_string = Table.concat(arg_list, " ")

        if not string.match(arg_string, arg) then
            arg_list[#arg_list+1] = arg
        end
    end
end

function EventManager:getArgs(event_name)
    if not self._events_[event_name] then
        return {}
    end

    return self._events_[event_name].args
end

function EventManager:dispatch(event_name, ...)
    if not self._events_[event_name] then
        return false
    end

    for _, event in ipairs(self._events_[event_name]) do
        -- NOTE: 變長參數只能放在最後面，它後面不能再有任何引數，不然無法返回全部的值。
        -- NOTE: 會傳入管理器的引用，是因為能讓回調函數裡面可以使用dispatch函數。
        event:dispatch(self, ...)
    end
end

return EventManager
