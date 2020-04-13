return function(func)
    -- 直接F5測試程式碼有無問題，不用再開啟war3.exe
    local clock = os.clock
    local start_time = clock()

    func()

    local end_time = clock()
    print("--------")
    print(string.format("cost: %.4f (s)", end_time - start_time))
    print("--------")
end