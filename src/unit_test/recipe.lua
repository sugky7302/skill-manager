local Recipe = require 'lib.recipe'

Recipe:add("a,1;b,3;c,4;d,5", "e")
print(Recipe:find("b,4;a,8;d,5;c,6"))
