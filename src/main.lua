local function Main()
    local sleep = require 'ffi.sleep'
    print(os.clock())
    sleep(10)
    print(os.clock())
end

Main()

