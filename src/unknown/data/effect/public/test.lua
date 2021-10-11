return {
    name = "test",
    class = "a",
    value = {1, 0.5},
    period = 1,
    time = 3,
    mode = 1,
    priority = 10,
    max = 2,
    on_add = function(self, task)
        print("add-" .. task.time)
    end,
    on_delete = function(self, task)
        print("delete-" .. task.time)
    end,
    on_finish = function(self, task)
        print("finish-" .. task.time)
    end,
    on_cover = function(self, new)
        return self.time < new.time
    end,
    on_pulse = function(self, task)
        print("pulse-" .. task.time)
    end
}
