# 更新日誌

## 0.4.0 - 2020-01-22

### Added:
- **[war3]**
    - 新增Trigger類別。由於部分事件會採用臨時觸發，觸發完畢即刪除，減少event占用記憶體的問題。
    - enhanced_jass新增object函數，能夠獲得遊戲內的全域變數。

### Changed:
- **[init.lua]** 調整錯誤追蹤的格式。
- **[std]**
    - 完善EventManager類別。
    - Event的引數新增參數表，以字串+正則表達式呈現。
- **[war3]** 完善Listener類別。

### Todo:
- 考慮一次性事件要如何加入監聽器。

## 0.3.0 - 2020-01-21

### Added:
- **[std]** math加入gcf函數，能夠求最大公因數。

### Changed:
- **[std]**
    - 完善Event類別。
    - 調整RNG的數學依賴庫。

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
