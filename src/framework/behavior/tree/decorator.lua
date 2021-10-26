local table_insert, type, ipairs, pairs, gmatch = table.insert, type, ipairs, pairs, string.gmatch
local cls = require 'std.class'("BehaviorDecorator")
local DATABASE = {}
local Save

function cls:_new(script)
    local this = {}
    self.add(this, script)
    return this
end

function cls:__tostring()
    local rep, concat = string.rep, table.concat
    local str = {}

    for name, list in pairs(self) do
        str[#str+1] = name
        for k, fn_name in ipairs(list) do
            str[#str+1] = "|-- " .. fn_name
        end
    end

    return concat(str, '\n')
end

-- BUG: 遇到相同的裝飾器會重複包裝
function cls:wrap(node, list)
    local node_name = node:getName()
    if not self[node_name] then
        return self
    end

    if not list then
        for _, name in ipairs(self[node_name]) do
            DATABASE[node_name][name](node)  -- 調用資料庫裡的函數
        end
    else  -- 只對節點裝飾指定的裝飾器
        for _, name in ipairs(list) do
            -- 透過正則表達式取得裝飾名
            for s in gmatch(name, '[^-]+') do
                name = s
            end

            DATABASE[node_name][name](node)  -- 調用資料庫裡的函數
        end
    end

    return self
end

--[[
    NOTE: 支援 2 種寫法，第一種是(名字, 函數)
          第二種是{(名字1, 函數1), (名字2, 函數2)} - 2021-10-26
--]]
function cls:add(list)
    if type(list) ~= 'table' then
        return {}
    end

    local names = {}
    if type(list[1]) == 'table' then -- 有多個裝飾函數
        for _, t in ipairs(list) do
            table_insert(names, Save(self, t))
        end
    else  -- 單一裝飾函數
        table_insert(names, Save(self, list))
    end

    return names
end

Save = function(self, list)
    local name = {}
    for s in gmatch(list[1], '[^-]+') do
        name[#name+1] = s
    end

    -- 更新資料庫
    if not DATABASE[name[1]] then
        DATABASE[name[1]] = {}
    end

    DATABASE[name[1]][name[2]] = list[2]

    -- 更新裝飾器
    if not self[name[1]] then
        self[name[1]] = {}
    end

    table_insert(self[name[1]], name[2])

    return list[1]
end

return cls