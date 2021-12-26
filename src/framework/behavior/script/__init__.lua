-- 註冊基本腳本
local type, ipairs, assert = type, ipairs, assert
local DATABASE = require 'framework.loader'.loadFolder('framework.behavior.script', {
    'test.json'
})

for _, json in pairs(DATABASE) do
    for i, v in pairs(json) do
        print(i, v)
    end
end

return {
    import = function(name, script)
        if type(name) == 'string' then
            DATABASE[name] = script
            return
        end

        for i, v in ipairs(name) do
            assert(script[i], v + "沒有對應的腳本，請檢查兩者數量是否相符。")
            DATABASE[v] = script[i]
        end
    end,
    export = function(name)
        if type(name) == 'string' then
            name = {name}
        end

        local scripts = {}
        for _, v in ipairs(name) do
            assert(DATABASE[v], "腳本庫搜尋不到此腳本，請檢查腳本名稱是否正確。")
            scripts[#scripts+1] =  DATABASE[v]
        end

        return scripts
    end
}