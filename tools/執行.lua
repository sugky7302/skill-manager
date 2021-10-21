require 'filesystem'
local registry = require 'registry'
local ydwe = require 'tools.ydwe'
local process = require 'process'

if not ydwe then
    return
end

-- 搜尋地圖
local MAP = nil
for file in fs.path(arg[1]):list_directory() do
    if not fs.is_directory(file) then
        if string.match(file:filename():string(), ".+.w3x") then
            MAP = file
            break
        end
    end
end

if not MAP then
    print('地圖不存在')
    return
end

local command = (registry.open [[HKEY_CURRENT_USER\SOFTWARE\Classes\YDWEMap\shell\run_war3\command]])['']
command = command:gsub("%%1", MAP:string())

-- 開啟進程執行war3.exe
local p = process()
if p:create(nil, command, nil) then
    print(command)
    p:close()
end

