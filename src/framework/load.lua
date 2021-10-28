local function ErrorHandler(err)
    print(string.format("[Error] %s", err))
    print(debug.traceback())
end

return function(folder, file_names)
    local files, state, data = {}
    for _, file_name in ipairs(file_names) do
        state, data = xpcall(require, ErrorHandler, table.concat{folder, ".", file_name})

        if state then
            files[data.name or file_name] = data
        end
    end

    return files
end
