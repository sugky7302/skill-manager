-- 此module啟用lua訊息框，並加載路徑，使後續module在require時，能夠省去父路徑
local require = require
local Runtime = require 'jass.runtime'
local Console = require 'jass.console'

Global = {}

-- Debug模式
Global.debug_mode = true

-- 打開控制台
Runtime.console = Global.debug_mode and true or false

-- 重載print，自動轉換編碼
local print = Console.write

-- 將handle等級設為0(地圖中所有的handle均使用table封裝)
Runtime.handle_level = 0

-- 設定lua調試器
Runtime.debugger = 4278

-- 關閉等待
Runtime.sleep = false

-- 錯誤匯報
function Runtime.error_handle(msg)
    print(string.format("[Error] %s", msg))
end

local abs_path = ';D:\\Program\\SkillManager\\src\\'

-- 一定要絕對路徑，不然lua會找不到
package.path = package.path .. abs_path .. '?.lua'

function Global.addPath(dir)
    if dir ~= '' then
        dir = dir .. [[\]]
    end
    local path = dir .. '?.lua'
    package.path = package.path .. abs_path .. path
end

-- Global.AddPath 'data'
-- Global.AddPath 'lib'
-- Global.AddPath 'war3'
-- Global.AddPath 'util'

-- 進入主函數
require 'main'
