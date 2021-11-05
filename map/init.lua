-- 此module啟用lua訊息框，並加載路徑，使後續module在require時，能夠省去父路徑
local require = require
local Runtime = require 'jass.runtime'
local Console = require 'jass.console'

-- 打開控制台
Runtime.console = true

-- 重載print，自動轉換編碼
print = Console.write

-- 將handle等級設為0(地圖中所有的handle均使用table封裝)
Runtime.handle_level = 0

-- 設定lua調試器
Runtime.debugger = 4278

-- 關閉等待
Runtime.sleep = false

-- 錯誤匯報


function Runtime.error_handle(msg)
    print("[Error] ".. msg)
    print(debug.traceback())
end

-- 設定require路徑
-- NOTE: 一定要絕對路徑，不然lua會找不到
local concat = table.concat

local WORK_DIR = ';' .. string.match(debug.getinfo(1, "S").source, "@(.+)map")
package.path = concat{package.path, WORK_DIR, 'src\\?.lua'}
package.path = concat{package.path, WORK_DIR, 'src\\?\\__init__.lua'}
package.path = concat{package.path, WORK_DIR, 'tools\\w3x2lni\\script\\?.lua'}
package.cpath = concat{package.cpath, WORK_DIR, 'bin\\?.dll'}
package.cpath = concat{package.cpath, WORK_DIR, 'tools\\w3x2lni\\bin\\?.dll'}

-- 進入主函數
require 'main'
