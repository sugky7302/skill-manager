local db = require 'std.database':new()

db:update('crum', '攻擊力', function(lv) return lv*5 end)
db:update('sde', "法術攻擊力", function(lv) return lv*2+3 end)

return db