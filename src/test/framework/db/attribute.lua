local Math = require 'std.math'
local MAX_LEVEL = 25

local function Linear(l_min, h_min, l_max, h_max)
    return function(level)
        local min = Math.round(l_min + (h_min - l_min) * level / MAX_LEVEL)
        local max = Math.round(l_max + (h_max - l_max) * level / MAX_LEVEL)
        return Math.rand(min, max)
    end
end

return {
    ["攻擊力"] = {
        value = Linear(1, 20, 2, 30),
        res = "hello world",
        set = function(self, i, v)
            print("觸發a的設值函數")
        end,
        get = function(self)
            print("觸發a的取值函數")
            return 5
        end
    },
    ["法術攻擊力"] = {
        value = Linear(2, 15, 3, 25),
        vec = 10,
        set = function(self, i, v)
            print("觸發b的設值函數")
        end,
        get = function(self)
            print("觸發b的取值函數")
            return 3
        end
    }
}
