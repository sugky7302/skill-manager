local function ErrorHandler(err)
    print(string.format("[Error] %s", err))
end

return function(path, file_names)
    local files = {}
    for _, file_name in ipairs(file_names) do
        print(file_name)
        files[#files+1] = select(2, xpcall(require, ErrorHandler, table.concat({path, file_name})))
    end

    return files
end
