local ipairs, table = ipairs, table
local String = require 'std.string'
local combine, reverse = {}, {}

local function Sort(recipe)
    local split = String.split(recipe, ';')
    table.sort(split)

    local first, last
    local material, demands = {}, {}
    for _, v in ipairs(split) do
        first, last = String.find(v, ',', 1)
        material[#material + 1] = String.sub(v, 1, first-1)
        demands[#demands + 1] = tonumber(String.sub(v, last+1, String.len(v)))
    end

    return material, demands
end

return {
    add = function(recipe, product)
        local material, demands = Sort(recipe)
        demands[0] = product

        -- 記錄拆分
        reverse[product] = recipe

        local key = table.concat(material, ',')

        if not combine[key] then
            combine[key] = {}
        end

        combine[key][#combine[key] + 1] = demands
    end,
    find = function(recipe)
        local material, demands = Sort(recipe)
        local key = table.concat(material, ',')

        if not combine[key] then
            return nil
        end

        -- 遍歷所有產品需求表，符合即回傳產品id
        for i, product in ipairs(combine[key]) do
            for j, demand in ipairs(demands) do
                if product[j] > demand then
                    break
                end

                if j == #demands then
                    return combine[key][i][0]
                end
            end
        end

        return nil
    end,
    reverse = function(product)
        if not reverse[product] then
            return nil
        end

        local material, demands = Sort(reverse[product])
        local recipe = {}
        for i, v in ipairs(material) do
            recipe[#recipe + 1] = v
            recipe[#recipe + 1] = demands[i]
        end

        return recipe
    end
}
