return {
    a = {
        format = "我要成為偉大的第N位海賊王",
        res = "hello world",
        set = function()
            print("觸發a的設值函數")
        end,
        -- get = function()
        --     print("觸發a的取值函數")
        --     return 5
        -- end
    },
    b = {
        format = "提高N點b",
        vec = 10,
        set = function()
            print("觸發b的設值函數")
        end,
        get = function()
            print("觸發b的取值函數")
            return 3
        end
    }
}
