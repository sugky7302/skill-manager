local function ErrorHandler(err)
    print(string.format("[Error] %s", err))
    print(debug.traceback())
end

local function Load(folder, file_names)
    local files = {}
    for _, file_name in ipairs(file_names) do
        xpcall(require, ErrorHandler, table.concat{folder, ".", file_name})
    end
end

Load("framework.behavior.node", {
    'condition',
    'loop',
    'not',
    'parallel',
    'random',
    'selector',
    'sequence',
    'wait',
    'none',
})
