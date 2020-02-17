local function ErrorHandler(err)
    print(string.format("[Error] %s", err))
    print(debug.traceback())
end

return function(path, file_names)
    local files, data = {}
    for _, file_name in ipairs(file_names) do
        print(file_name)
        data = select(2, xpcall(require, ErrorHandler, table.concat({path, file_name})))
        files[data.file_key or file_name] = data
    end

    return files
end
