--[[
    Decorator is a plug-in of behavior that can decorate the assigned node.
    The most important function is extending functions of the node, which can realize many special effects.

    Function:
      new(name, fn) - create an instance and record decorators.

      print() - print the decorators

      wrap(node, list?) - wrap the node with all decorators in the list.
        node - Behavior Node
        list? - decorators list. If not list, all decorateors would wrap the node.

      add(name, fn) - add a decorator into the queue and update to the database.
        name - decorator name
        fn - decorator function

      has(name) - find whether the instance has the decorator.
        name - decorator name
        return - true if the instance has the decorator
--]]

local type, ipairs, pairs, gmatch, concat = type, ipairs, pairs, string.gmatch, table.concat
local cls = require 'std.class'("BehaviorDecorator")
local DATABASE = {}
local UpdateDataBase, AddDecorator, ParseName

function cls:_new(name, fn)
    local this = {}
    
    if name then
        self.add(this, name, fn)
    end

    return this
end

function cls:__tostring()
    local str = {}

    for name, list in pairs(self) do
        str[#str+1] = name
        for k, fn_name in ipairs(list) do
            str[#str+1] = "|-- " .. fn_name
        end
    end

    return concat(str, '\n')
end

function cls:wrap(node, list)
    local node_name = node:getName()
    if not self[node_name] then
        return self
    end

    -- 針對單一裝飾名進行包裝，好讓迭代器執行
    if type(list) == 'string' then
        list = {list}
    end

    local t
    for _, name in ipairs(list or self[node_name]) do
        -- 透過正則表達式取得裝飾名
        -- NOTE: list的名字跟self[node_name]會有差別，因此要解析。 - 2021-10-27
        t = ParseName(name)

        if #t == 1 then
            t[2] = t[1]
            t[1] = node_name
        end

        -- 添加裝飾器到節點，如果成功則調用資料庫裡的函數
        -- NOTE: Node儲存的只有裝飾名，不需要節點名 - 2021-10-27
        if DATABASE[t[1]][t[2]] and (t[1] == node_name) and node:addDecorator(t[2]) then
            DATABASE[t[1]][t[2]](node)
        end
    end

    return self
end

--[[
    NOTE: 此函數會檢測有無此裝飾名，沒有的話會添加至裝飾器，然後再添加裝飾函數到裝飾器以及更新資料庫。
          格式為 name(string/table)、fn(function/table)。
          這裡會透過遞迴的方式處理單一元素以及元素陣列 - 2021-10-27
--]]
function cls:add(name, fn)
    if type(name) == 'string' then
        if type(fn) == 'function' then
            UpdateDataBase(name, fn)
        end

        return AddDecorator(self, name)
    elseif type(name) == 'table' then
        local decorators = {}
        if type(fn) == 'table' and #name == #fn then
            for i, v in ipairs(name) do
                decorators[#decorators+1] = cls.add(self, v, fn[i])
            end
        else
            for _, v in ipairs(name) do
                decorators[#decorators+1] = cls.add(self, v)
            end
        end

        return decorators
    end
end

UpdateDataBase = function(name, fn)
    if type(name) ~= 'string' and type(fn) ~= 'function' then
        return
    end
    
    local t = ParseName(name)
    if #t ~= 2 then
        return
    end

    if not DATABASE[t[1]] then
        DATABASE[t[1]] = {}
    end

    if not DATABASE[t[1]][t[2]] then
        DATABASE[t[1]][t[2]] = fn

    end
end

AddDecorator = function(self, name)
    if type(name) ~= 'string' then
        return
    end

    local t = ParseName(name)
    if #t ~= 2 then
        return
    end

    -- 檢查資料庫有無此裝飾函數
    if not (DATABASE[t[1]] and DATABASE[t[1]][t[2]]) then
        return
    end

    if not self[t[1]] then
        self[t[1]] = {}
    end

    local is_exist = false
    for _, dcr_name in ipairs(self[t[1]]) do
        if dcr_name == t[2] then
            is_exist = true
        end
    end

    if is_exist then
        return
    end

    self[t[1]][ #self[t[1]] + 1] = t[2]

    return name
end

ParseName = function(name)
    local t = {}
    for s in gmatch(name, '[^-]+') do
        t[#t+1] = s
    end

    return t
end

function cls:has(name)
    for _, node_name in pairs(self) do
        for _, dcr_name in ipairs(node_name) do
            if dcr_name == name or concat{node_name, "-", dcr_name} == name then
                return true
            end
        end
    end

    return false
end

return cls