local function ErrorHandler(err)
    print(string.format("[Error] %s", err))
    print(debug.traceback())
end

return function(path, file_names)
    local files, data = {}
    for _, file_name in ipairs(file_names) do
        data = select(2, xpcall(require, ErrorHandler, table.concat({path, file_name})))
        files[data.name or file_name] = data
    end

    return files
end
