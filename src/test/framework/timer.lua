local Timer = require 'framework.timer'

-- print("Timer1 Start", os.clock())
-- Timer:new(1, 1, function()
--     print("Timer1 End", os.clock())
-- end):start()

-- print("Timer2 Start", os.clock())
-- Timer:new(5, 3, function()
--     print("Timer2 End", os.clock())
-- end):start()

print("Timer3 Start", os.clock())
local a = Timer:new(2, 2, function(self)
    if self.runtime_ > 1.5 then
        self:pause()
    end
    print("Timer3 End", os.clock())
end):start()

print(coroutine.status(a._timer_))
Timer:new(5, 1, function()
    a:resume()
end):start()
