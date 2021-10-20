local function Main()
    require 'framework.timer':new(1, 1, function() print("test") end):start()
end

Main()

