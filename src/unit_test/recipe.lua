local Recipe = require 'lib.recipe'

Recipe:add("a,1,b,3,c,4,d,5", "e")
print(Recipe:find("a,1,b,3,c,4,d,5"))
