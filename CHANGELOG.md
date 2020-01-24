# 更新日誌

## 0.6.0 - 2020-01-24

### Added:
- 新增lib資料夾，儲存開發魔獸地圖專用、沒調用jass的lua腳本。
- 新增unit_test資料夾，儲存單元測試劇本。
- 新增data資料夾，儲存由lua記錄的數據資料。
- **[data]**
  - skill_tree的public搬到skill子目錄內。
  - 新增load_file函數讀取資料，並以table回傳。
- **[lib]** 新增skill_manager類別，統一管理技能並生成副本。
- **[std]** 新增Table類別，擴充原lua table的功能。
- **[war3]** 新增Timer類別，採中心計時器分發，並整合jass計時器功能，方便使用。

### Changed:
- skill_tree資料夾搬到lib下。
- **[lib/skill_tree]** 更改skill_tree下所有腳本的引用路徑。
- **[std/event_manager]** 把可變參數和event_manager引用的位置調換，方便event的參數列表調用。

## 0.5.0 - 2020-01-23

### Added:
- **[init]** Global類別加入error_handle函數，讓lua腳本能直接調用報錯機制。
- **[skill_tree]**
  - 新增public資料夾，儲存共用的動作節點。資料夾內的所有節點統一由同層的init.lua註冊。
  - public下新增test、test1兩個測試節點。
- **[skill_tree/node]** 原先的註冊方式不正確，因此新增靜態方法register，讓繼承node的類別可以註冊進node_list。
- **[war3]** 新增Group類別，強化war3內部的group功能，並加入鏈式語法，方便使用者操作。此外，開頭撰寫說明文件，便利使用此模塊的使用者，不需要翻閱所有程式碼才能使用模塊。

### Changed:
- **[std/array]** push_back函數更名為append。
- **[std/event_manager]** dispatch函數在傳遞參數給event時，會順便把manager傳過去，方便使用者在事件內調用別的事件。
- **[std/listener]** 事件名加入"*"後綴，會被listener辨識為一次性事件。
- **[war3/trigger]** 
  - 加入鏈式語法。
  - 設定Condition的動作獨立成函數，讓使用者能夠從外部再設定，目前用於導入trigger實例。

### Fixed:
- **[skill_tree/random_node]** 修正success函數的_children_名稱錯誤的問題。
- **[skill_tree/sequence_node]** 修正success函數的_children_名稱錯誤的問題。
- **[war3/listener]** Trigger的條件函數修正第一次讀取不到事件就會跳出的問題。

### Todo:
- 規劃技能流程並開發技能動作節點。

## 0.4.0 - 2020-01-22

### Added:
- **[war3]**
    - 新增Trigger類別。由於部分事件會採用臨時觸發，觸發完畢即刪除，減少event占用記憶體的問題。
    - enhanced_jass新增object函數，能夠獲得遊戲內的全域變數。

### Changed:
- **[init]** 調整錯誤追蹤的格式。
- **[std/event_manager]** 完善EventManager類別。
- **[std/event]** Event的引數新增參數表，以字串+正則表達式呈現。
- **[war3/listener]** 完善Listener類別。

### Todo:
- 考慮一次性事件要如何加入監聽器。

## 0.3.0 - 2020-01-21

### Added:
- **[std]** math加入gcf函數，能夠求最大公因數。

### Changed:
- **[std/event]** 完善Event類別。
- **[std/random_number_generator]** 調整RNG的數學依賴庫。

### Todo:
- 完善Listener和EventManager，並確定職責。

## 0.2.0 - 2020-01-20

### Added:
- **[std]**
    - 新增Event(事件)類別。
    - 新增EventManager(事件管理器)類別，統一註冊事件。目前尚未完成。
    - Queue新增loop函數，能遍歷所有元素。
- **[war3]** 新增Listener(監聽器)類別，統一監聽事件，並調用對應該事件的處理方法。目前尚未完成。

### Changed:
- base.lua更名為init.lua。

## 0.1.0 - 2020-01-19
- 設計技能管理器與相關套件功能，目標是做出一套高擴充性、易編輯、模組化的技能系統。
