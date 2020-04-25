local ipairs = ipairs

local function Sort(recipe)
    local table = table
    local String = require 'std.string'

    local split = String.split(recipe, ';')
    table.sort(split)

    local first, last
    local material, demands = {}, {}
    for _, v in ipairs(split) do
        first, last = String.find(v, ',', 1)
        material[#material + 1] = String.sub(v, 1, first-1)
        demands[#demands + 1] = tonumber(String.sub(v, last+1, String.len(v)))
    end

    return table.concat(material, ','), demands
end

return {
    add = function(self, recipe, product)
        local material, demands = Sort(recipe)
        demands[0] = product

        if not self[material] then
            self[material] = {}
        end

        self[material][#self[material] + 1] = demands

        return self
    end,
    find = function(self, recipe)
        local material, demands = Sort(recipe)

        if not self[material] then
            return nil
        end

        -- 遍歷所有產品需求表，符合即回傳產品id
        for i, product in ipairs(self[material]) do
            for j, demand in ipairs(demands) do
                if product[j] > demand then
                    break
                end

                if j == #demands then
                    return self[material][i][0]
                end
            end
        end

        return nil
    end
}
