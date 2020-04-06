return {
    a = {
        res = "hello world",
        set = function()
            print("set a")
        end,
        get = function()
            print("get a")
            return 5
        end
    },
    b = {
        vec = 10,
        set = function()
            print("set b")
        end,
        get = function()
            print("get b")
            return 3
        end
    }
}
