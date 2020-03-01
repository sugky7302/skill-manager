local Combat = require 'war3.combat'
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
    on_pulse = function(self, task)
        Combat(task.value, task.source, task.target)
    end
}
