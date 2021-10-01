local Queue = require 'std.queue'
local ej = require 'war3.enhanced_jass'

-- constants
local QUANTITY = 128

-- 使用queue是因為要重複利用we的單位組，減少ram的開銷
local recycle_group = Queue:new()

return {
    get = function()
        -- 用 ">" 是因為這個函式會減少recycle_group的數量
        if recycle_group:size() > QUANTITY then
            return false
        end

        if recycle_group:isEmpty() then
            return ej.CreateGroup()
        end

        local empty_group = recycle_group:front()
        recycle_group:pop_front()

        return empty_group
    end,
    release = function(group)
        -- 用 ">=" 是因為這個函式會增加recycle_group的數量
        if recycle_group:size() >= QUANTITY then
            ej.DestroyGroup(group)
        else
            recycle_group:push_back(group)
        end
    end
}