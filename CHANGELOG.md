# 更新日誌

## 0.31.0 - 2020-02-28

- 注意不要在包的最上面直接新建一個依賴包的實例，很容易會產生無窮循環調用的問題，要使用就在真的調用函數內使用。

### Added:
- **[data/attribute]** 新增屬性-轉身速度。
- **[std/point]** 新增相等比較運算符。
- **[war3/effect]** 任務新增source參數，能夠設定效果來源，方便回調函數(on_add, on_pulse, ...)執行傷害處理器或其他同時需要source和target的元件。
- **[war3/text]**
  - 加入週期回調函數，讓使用者能夠外部修改數據。
  - start函數加入鏈式語法。
- **[war3/unit]** 新增getLoc函數，能獲得單位目前的位置。

### Changed:
- **[lib/damage_processor]** 現在能夠傳入已經生成好的技能表，解決傷害處理器自己生成的表和技能樹的表不同的問題。

### Fixed:
- **[lib/damager_processor]** 修正skill_manager在調用LoadSkillScript時，因為烈焰風暴腳本依賴DamageProcessor，而DP又直接創建skill_manager，所以產生無窮循環調用的問題。只要把DP對SkillManager的建構函數放到實際函數內調用即可。
- **[war3/hero]** 修改skill_manager和skill_decorator的依賴方式。
- **[war3/unit]** 修改event_manager和listener的依賴方式。

### Todo:
- [x] 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- [ ] 完成紅黑樹的刪除。
- [ ] 計時器的隊列回收機制。
- [ ] effect_manager、effect有print。

## 0.30.0 - 2020-02-27

### Changed:
- **[lib/attribute]** add/set/get函數對於key=屬性名，會對加總值(數值*百分比)進行處理；如果key=屬性名%，就只會對百分比做處理。
- **[std/ascii]** 如果參數為空，則回傳空字串或0。
- **[war3/effect]** 修改AddModel、DeleteModel裡調用的函數名，並開通刪除技能模型的功能。

### Fixed:
- **[war3/effect]** 修正調用target:hasSkill時，因為._model_沒有預設值而導致報錯的問題。

### Todo:
- [x] 測試新改的attribute在unit_test/damager_processor下跟昨天有無差別。
- [ ] 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- [ ] 完成紅黑樹的刪除。
- [ ] 計時器的隊列回收機制。
- [ ] effect_manager、effect有print。

## 0.29.0 - 2020-02-26

### Changed:
- **[war3/timer]** 調整中心計時器的補幀方法和迴圈索引，刪減不必要的參數開銷。

### Fixed:
- **[lib/attribute]** 修正實際數值和估計數值不同的問題。
- **[war3/timer]**
  - 修正計時器有可能掉幀的問題。
  - 修正同一幀下第n個命令調用刪除動作，會導致第n+1個命令被跳過的問題。

### Todo:
- 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- 完成紅黑樹的刪除。
- 計時器的隊列回收機制。

## 0.28.0 - 2020-02-25

### Added:
- **[data/attribute]** 新增生命、生命上限、最小攻擊力、最大攻擊力等屬性。

### Changed:
- **[lib/attribute]** get函數如果找不到屬性，會新建一個，並觸發取值事件。
- **[lib/damage_processor]** 完成。

### Fixed:
- **[war3/timer]** 修正count為小數時，實際執行次數和目標執行次數不同的問題。

### Bug:
- **[war3/text]** 啟動後，有幾個文字執行到一半就不再更新，也不會刪除。目前有在text和timer放入print測試，但還沒找到原因。

### Todo:
- 新增戰鬥結算系統。
- 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- 完成紅黑樹的刪除。

## 0.27.0 - 2020-02-24

### Added:
- **[lib/damage_processor]** 完成大部分函數的撰寫。

### Changed:
- **[lib/damage_processor]** run函數改成三個參數，比較簡單且不占記憶體。

### Todo:
- 新增戰鬥結算系統。
- 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- 完成紅黑樹的刪除。

## 0.26.0 - 2020-02-23

### Added:
- **[data/attribute]** 新增生命屬性。
- **[lib/attribute]** 建構函數加入對象的引用，方便設值、取值事件能夠操作對象。
- **[lib]** 新增damage_processor，為專職處理任意兩個單位的戰鬥結算系統。

## 0.25.0 - 2020-02-22

### Added:
- **[lib/skill_manager]** 新增query函數，可查詢技能資訊，主要是方便傷害處理器讀取資訊。

### Changed:
- **[lib/attribute]** get函數找不到屬性的回傳值改成0，讓使用者在調用時不需額外判斷有無此屬性。

### Todo:
- 新增戰鬥結算系統。
- 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- 完成紅黑樹的刪除。

## 0.24.0 - 2020-02-20

### Added:
- **[war3]** 新增Hero類別。

### Todo:
- 撰寫Hero單元測試。
- 新增Hero類別，並通過測試。
- 新增戰鬥結算系統。
- 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- 完成紅黑樹的刪除。

## 0.23.0 - 2020-02-19

- Monster不能直接調用Unit:__call()，還是要寫一個__call。
- Monster()和Unit()會生成同一個實例。

### Added:
- **[war3]**
  - 新增Monster類別，專職處理野外怪物。
  - 新增Follower類別，專職處理寵物、追隨者。

### Changed:
- **[war3/enhanced_jass]** setTimedLife函數更名為setLifeTime。
- **[war3/unit]** registerEvent函數更名為listen。

### Fixed:
- **[war3/unit]** 修正子類別新建實例後，若呼叫__call函數，可能會搜尋不到實例的問題。

### Todo:
- 新增Monster類別、Follower(寵物、隨從之類)類別。
- 測試Hero()能不能調用Unit:__call()。
- 測試Hero()和Unit()同一個單位會不會生成同一個實例。
- 新增戰鬥結算系統。
- 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- 完成紅黑樹的刪除。

## 0.22.0 - 2020-02-18

### Added:
- **[war3]** 新增Unit類別，用來處理所有遊戲單位。

### Changed:
- **[lib/attribute]** CreateAtrribute函數在創建文字時，如果資料庫找不到該署性的文字，會預設為空字串，防止讀取時報錯。
- **[std/ascii]**
  - 如果encode函數的引數是字串會直接返回。
  - 如果decode函數的引數是數字會直接返回。
- **[war3/listener]** _setSourceTriggerEvent函數改為區域函數，讀取起來較快，且不會被外部呼叫。

### Fixed:
- **[lib/attribute]** 修正新建屬性時，若遇到資料庫不存在的屬性便報錯的問題。

### Todo:
- 新增Unit類別、Hero類別、Monster類別、Follower(寵物、隨從之類)類別。
- 新增戰鬥結算系統。
- 寫一個完整、可裝飾的烈焰風暴，將所有系統都串連起來。
- 完成紅黑樹的刪除。

## 0.21.0 - 2020-02-17

- require只能讀取全英文路徑，想要讀中文路徑必須使用魔獸的lua編譯器。

### Added:
- **[data]** 新增attribute資料夾，儲存所有屬性的設值/取值函數。
- **[std/red_black_tree]** 新增size函數，能獲得紅黑樹的節點數量。

### Changed:
- **[data/load_file]** 現在指向檔案的索引可以會先搜尋檔案內有無file_key，有的話會優先設定為file_key的值，沒有才會同檔案名。
- **[lib/attribute]** 完善。

### Todo:
- 完成紅黑樹的刪除。

## 0.20.0 - 2020-02-17

### Added:
- **[std/red_black_tree]** 新增iterator，可從最小遍歷到最大。

## 0.19.0 - 2020-02-16

### Added:
- **[data]** 新增attribute_database，儲存所有屬性的資料。
- **[lib]** 新增Attribute類別，能對操作對象設定/獲得屬性。
- **[std]** 新增紅黑樹，但目前只實現插入和標記刪除，實際的刪除太麻煩，後面再做。

### Changed:
- **[std/database]** query函數現在回傳的資料的索引0可拿到該資料在資料庫的索引。

### Todo:
- 完成紅黑樹的刪除。

## 0.18.0 - 2020-02-14

### Added:
- **[std]** 新增資料庫類別。

### Todo:
- 新增屬性類別，並且add/set/get會觸發屬性事件。

## 0.17.1 - 2020-02-12

### Fixed:
- **[std/point]** 修正乘法常數只能放在右手邊，而不能隨意擺放的問題。

### Todo:
- 完成單位、英雄類別。

## 0.17.0 - 2020-02-11

### Changed:
- **[war3/text]** 現在位置和位移量只要輸入數值就好，內部會自動新建點。

### Fixed:
- **[std/point]** 修正加減乘除創建新對象錯誤的問題。
- **[war3/timer]** 修正總運行時間和實際運行時間差一個循環的問題。

## 0.16.0 - 2020-02-11

### Added:
- **[war3]** 新增Text類別，為漂浮文字的強化版。
- **[war3/timer]** Timer加入getRuntime函數，能夠獲取計時器總運行時間。

### Changed:
- **[std.point]**
  - 整併distance、distance3D函數。
  - 整併slope函數，現在會回傳兩個值，一個是x-y的斜率，另一個是xy-z的斜率。

### Todo:
- 計時器加入總運行時間的功能。
- 撰寫文字管理器，包含一般文字和戰鬥文字。
- timer、effect_manager、effect有print。

## 0.15.0 - 2020-02-08

### Added:
- **[lib/effect_manager]** delete函數現在會刪除效果，解決效果自己刪除導致無限循環的問題。
- **[std/array]** 新增delete函數，刪除指定元素。

### Changed:
- **[lib/effect_manager]** 整理程式碼。
- **[std/array]** 整理程式碼。
- **[std/list]** 整理程式碼。
- **[war3/effect]** 整理程式碼。

### Fixed:
- **[std/array]** 修正在迭代器迴圈內刪除元素後，索引停止條件錯誤的問題。
- **[war3/effect]** 修正remove->clear->delete->remove無限循環的問題。

## 0.14.2 - 2020-02-08

### Fixed:
- **[lib/effect_manager]** delete函數不用先搜尋效果再刪除，多此一舉。
- **[std/array]** 修正erase函數刪除資料後，因元素數量改變，導致下一個循環會出錯的問題。
- **[war3/timer]** 修正計時器動作內自己pause會無效的問題。

### Todo:
- timer、effect_manager、effect有print。

## 0.14.1 - 2020-02-08

### Fixed:
- **[std/array]** 修正table無法print的問題。
- **[std/list]** 修正迭代器在空列表的情況下，會搜尋不到下一個節點而報錯的問題。
- **[lib/event_manager]** dispatch函數將引數傳入evnet時，變長參數只能放在最後面，它後面不能再有任何引數，不然無法返回全部的值。
- **[war3/effect]** 修正在共存模式下，新效果如果沒有在有效範圍內，也會調用pause函數，導致偵測不到計時器而報錯的問題。
- **[war3/timer]** 修正重複pause，會造成幀計算錯誤，導致計時器無法恢復的問題。

### Todo:
- 確認狀態關係表能夠運行。
- 解決test1暫停後恢復不會終止以及明明所有效果已經結束，但下次添加會搜尋到舊效果的問題。

## 0.14.0 - 2020-02-06

### Added:
- **[data/effect]** 新增狀態關係表。
- **[std/array]** 新增iterator、reverseIterator函數，能夠利用lua的for語法執行迴圈。
- **[war3/effect]** 新增getClass函數，能夠獲得效果的分類。

### Fixed:
- **[war3/effect]** 修正沒有任務後，管理器不會移除效果的問題。

## 0.13.0 - 2020-02-05

### Added:
- **[data/effect/public]**
  - 新增init.lua，用於讀取資料夾內的所有.lua。
  - 新增test.lua，編輯一個effect範本，檢驗effect_manager是否可行。
- **[lib/effect_manager]** 新增getTempalte函數，可以獲得效果模板，方便撰寫on_*函數時復用。
- **[unit_test]** 新增list.lua，為list的單元測試。
- **[war3/effect]**
  - 新增getName函數，可獲得effect的名稱。
  - 所有公開函數都加入鏈式語法。

### Fixed:
- **[lib/effect_manager]**
  - 修正add函數找不到模板還會繼續執行的問題。
  - 修正delete函數沒有實際刪除effect的問題。
- **[war3/effect]**
  - 修正AddTask函數在共存模式下，無法添加新效果的問題。
  - 目前target無法添加/移除模型，因此先註解調函數，修正effect無法動作的問題。

### Todo:
- 設計效果管理器的狀態類型關係表，並編寫CompareEffectAssociation函數。

## 0.12.0 - 2020-02-05

### Added:
- **[war3]** 新增effect類別，處理所有效果。

### Changed:
- **[war3/timer]** resume函數現在會辨識能不能恢復。

## 0.11.0 - 2020-02-04

### Added:
- **[std/Table]** 新增isNil函數，可以檢查table是否為空。

### Changed:
- **[std/array]** exist函數現在回傳值會有兩個(索引、值)。
- **[std/list]** 修改iterator和reverseIterator的寫法。

## 0.10.0 - 2020-02-02

### Added:
- **[lib]** 新增EffectManager，為外部統一操作效果的窗口。

## 0.9.0 - 2020-01-31

### Added:
- **[lib/skill_decorator]** 完善。
- **[lib/skill_manager]** 現在註冊劇本會順便註冊裝飾器。
- **[lib/skill_tree/skill_tree]** 生成樹時，會搜尋每一個節點，查詢是否需要裝飾。

### Changed:
- **[lib/skill_tree/node]** 現在註冊節點會順便讓節點記錄名字，好讓裝飾器能夠辨認是哪個節點。

## 0.8.0 - 2020-01-28

### Added:
- **[lib]** 新增SkillDecorator類別，裝飾技能樹的動作節點，達到跟Heros of the storm的天賦一樣的功能，目前尚未完成。
- **[lib/skill_manager]** get函數加入裝飾器包裝技能的功能。

## 0.7.0 - 2020-01-27

### Added:
- **[data/skill/public]** 新增烈焰風暴腳本。
- **[lib/skill_tree/skill_tree]** 腳本加入參數功能，新建節點會讀取參數供內部使用。

### Fixed:
- **[war3/timer]** 修正執行函數時，調用刪除函數，會導致序列處理報錯的問題。

## Todo:
- [x] 實現烈焰風暴的技能流程。
- [ ] 開發裝飾器。

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
