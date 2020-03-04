local require = require
local Unit = require 'war3.unit'
local ev = require 'lib.event_manager':new()

ev:addEvent(
    "單位-測試",
    nil,
    function(_, u)
        print(u:getType())
    end
)

require 'war3.group':new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        local u = Unit:new(self.units_[i])
        u:addAttribute("生命", 5)
        u:addSkill('ANcl')
        print(u:getId())
        print(u:isAlive())
        print(u:getAttribute("生命"))
        u:eventDispatch("單位-測試")
    end
)
