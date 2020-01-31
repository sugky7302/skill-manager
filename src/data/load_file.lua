local function ErrorHandler(err)
    print(string.format("[Error] %s", err))
    print(debug.traceback())
end

return function(path, file_names)
    local files = {}
    for _, file_name in ipairs(file_names) do
        files[file_name] = select(2, xpcall(require, ErrorHandler, table.concat({path, file_name})))
    end

    return files
end
