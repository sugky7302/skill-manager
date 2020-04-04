local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)

e:addEvent(
    "測試", "",
    function()
        print("測試")
    end
)

l("測試")()
