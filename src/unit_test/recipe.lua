-- local Recipe = require 'lib.recipe'

a = {"A001", 2, "B222", 3, "C912", 1}
print(table.concat(a, ','))
-- for item in H.items() do
--     if item is Material then
--         a.append(item.type_name).append(item.count)
--     end
-- end

-- product = Recipe:find(a)
-- if product then
--     for item in H.items() do
--         H:removeItem(item)
--     end

--     ej.UnitAddItemByIdSwapped(product, H)
-- end
