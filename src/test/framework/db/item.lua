local db = require 'std.database':new()

-- 裝備
db:update('abc', 'a')
db:update('def',"a", 'b')

-- 符文
db:update('crum', '符文', '攻擊力')
db:update('sde', '次級符文', "法術攻擊力")
db:update('s', '次級符文', "防禦力")
db:update('d', '次級符文', "火系元素傷害")
db:update('e', '次級符文', "水系元素傷害")
db:update('ae', '次級符文', "法術防禦力")
db:update('aq', '次級符文', "攻擊速度")

return db