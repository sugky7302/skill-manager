local effect1 = require 'framework.effect':new{name="火焰環繞", target=123, value=0.2, time=10, period=3}
effect1:run():pause():resume():stop()

local e2 = require 'framework.effect':new{name="test", value=2, time=3}
print(e2:run():pause():getRemaining())
e2:setRemaining(3):resume()