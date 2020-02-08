return {
    name = "test1",
    class = "b",
    value = {0.5, 1},
    period = 0.5,
    time = 2,
    mode = 1,
    priority = 15,
    max = 1,
    on_add = function(self, task)
        print("add1-" .. task.time)
    end,
    on_delete = function(self, task)
        print("delete1-" .. task.time)
    end,
    on_finish = function(self, task)
        print("finish1-" .. task.time)
    end,
    on_cover = function(self, new)
        return self.time < new.time
    end,
    on_pulse = function(self, task)
        print("pulse1-" .. task.time)
    end
}
