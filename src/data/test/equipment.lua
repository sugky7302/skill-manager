local db = require 'std.database':new()

db:update('abc', '攻擊力', '力量')
db:update('def',"法術攻擊力", '元素傷害')

return db