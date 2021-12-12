local effect1 = require 'framework.effect':new(123)
effect1:add{name="燃燒", source=1, value=0.2, time=10, period=3}
effect1:pause("燃燒"):resume("燃燒"):stop("燃燒")