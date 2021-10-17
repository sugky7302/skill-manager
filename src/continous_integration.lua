local require = require
local LFS = require "bin.lfs"

if not LFS then 
    return
end

local function CI(test_list)
    local concat = table.concat
    for _, path in ipairs(test_list) do
        path = path .. ".test"
        for _, file in LFS.dir(path) do
            require(concat{path, "/", file})
        end
    end
end

CI{
    'std'
}