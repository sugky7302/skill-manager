local DP = require 'lib.damage_processor'
return {
    name = "點燃",
    class = "a",
    value = {1, 0.5},
    period = 1,
    time = 5,
    mode = 0,
    priority = 15,
    max = 1,
    model = 'A001',
    on_add = function(self, task)
    end,
    on_delete = function(self, task)
    end,
    on_finish = function(self, task)
    end,
    on_pulse = function(self, task)
        print(DP:new().run(task.value, task.source, task.target))
    end
}
