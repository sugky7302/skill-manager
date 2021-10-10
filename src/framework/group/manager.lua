local Queue = require 'std.queue'
local ej = require 'war3.enhanced_jass'

-- constants
local QUANTITY = 128

-- 使用queue是因為要重複利用we的單位組，減少ram的開銷
local recycle_group = Queue:new()

function Get()
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
end

function Release(group)
    -- 用 ">=" 是因為這個函式會增加recycle_group的數量
    if recycle_group:size() >= QUANTITY then
        ej.DestroyGroup(group)
    else
        recycle_group:push_back(group)
    end
end

-- 遍歷會清空group內的所有單位
function Traverse(group, cnd, action)
    local enum_unit = ej.FirstOfGroup(group)
    while enum_unit ~= 0 do
        if cnd(enum_unit) then
            action(enum_unit)
        end

        ej.GroupRemoveUnit(group, enum_unit)
        enum_unit = ej.FirstOfGroup(group)
    end

    Release(group)
end

return {
    get = Get,
    release = Release,
    traverse = Traverse,
}