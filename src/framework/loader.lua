local function LoadFile(path)
    local WORK_DIR = string.match(debug.getinfo(1, "S").source, "@(.+\\src\\)")
    local string = string
    local match = string.match

    -- 檢查副檔名並將路徑的 . 替換成 /
    path = table.concat{string.gsub(string.sub(path, 1, string.find(path, "[^.]+$")-2), "%.", "/"),
                        ".", match(path, "[^.]+$")}

    local f = io.open(WORK_DIR .. path)

    if f then
        local buf = f:read 'a'

        if match(path, ".json") then
            buf = require 'std.json'.decode(buf)
        end

        f:close()
        return buf
    end
end

local function ErrorHandler(err)
    print(table.concat{"[File Error] ", err})
    print(debug.traceback())
end

local function LoadFolder(folder, file_names)
    local concat, xpcall, match = table.concat, xpcall, string.match
    local data, path
    local files = {}

    for _, file_name in ipairs(file_names) do
        path = concat{folder, ".", file_name}
        if match(file_name, ".json") then
            files[file_name] = LoadFile(path)
        else
            data = select(2, xpcall(require, ErrorHandler, path))
        
            -- 讀取成功且有資料才儲存
            if data then
                -- 如果回傳的是table就合併
                if type(data) == 'table' then
                    require 'std.table'.merge(files, data)
                else
                    files[data.name or file_name] = data
                end
            end
        end
    end

    return files
end

return {
    loadFile = LoadFile,
    loadFolder = LoadFolder,
}
