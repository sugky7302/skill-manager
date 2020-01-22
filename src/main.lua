local require = require
local EventManager = require 'std.event_manager'
local Event = require 'std.event'
local Listener = require 'war3.listener'
local ej = require 'war3.enhanced_jass'

local function Main()
    local a = EventManager:new()
    local listener = Listener:new(a)
    a:addEvent(Event:new("測試", nil, function()
        print("Hello World")
    end))

    listener("測試")(nil)
end

Main()
