local db = require 'std.database':new()

db:update('abc', '攻擊力', function(self) return 5 end, '力量', 1, 3)
db:update('def',"法術攻擊力", 1, 3, '元素傷害', 5)

return db