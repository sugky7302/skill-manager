return {
    name = "test",
    class = "測試",
    value = {0.5, 1},
    period = 1,
    time = 3,
    mode = 1,
    max = 2,
    on_add = function(self)
        print("add")
    end,
    on_delete = function(self)
        print("delete")
    end,
    on_finish = function(self)
        print("finish")
    end,
    on_cover = function(self, new)
        return self.time < new.time
    end,
    on_pulse = function(self)
        print("pulse")
    end
}
