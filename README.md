# Skill Manager
Create a high-scalable, easy-modified and modularized skill system.

## Structure
  - std：標準函數庫，類似C++/Python內建的常用模組庫。std內所有模組的測試檔會從unit_test移動到此資料夾內。
  - war3：魔獸函數庫。放置由YDWE提供的jass2lua的模組。
  - framework：遊戲內會使用到的物件類別，如單位、物品等等。這些框架都是使用std和war3提供的模組組合而成，因此改動時要非常注意。因為部份模組含有資料庫，怕各自引用會讓之後模組維護有問題，所以會有一個類似目錄的.lua統一管理、引用模組。
    - behavior：行為樹
    - listener：監聽器
    - attribute：屬性
    - timer：計時器
    - group：單位組
    - effect：buff、debuff、狀態、法術場、彈道
  - share：存放服務間會共用的服務模版，防止有害的重複。
  - profession：職業模板服務。
  - magic_furnace：魔導爐服務。
  - knowledge：知識＆專精服務。
  - talent：種族特性服務。
  - skill：施法技巧服務。
  - quest：任務服務。
  - achievement：成就服務。
  - loot：戰利品服務。

## Design Idea
### Loader
Loader is a simple filesystem to load .txt or .json and require .lua or .dll. Its recursive loading would combine all lists into the one. Then users control only one lists to do anything you want to do.

### Behavior
Behavior is the most useful feature of this project. It allows users can create a AI-decision tree or a skill tree with a simple coding. Its most powerful part is that you can reuse your node which has written. Besides, users also import a tree which you have had into another tree and the sub-tree can load parameters of its parent-tree. I think that it can decrease a huge workload.

### Listener
The Listener Framework is based on the Observer Pattern. In order to solve problems of the previous version, I re-designed required relationships, communicated techniques, argument parsers, event store mechanisms, request/response techniques and reused event templates among listener, event_manager and event.

With the new framework, I split the communicated technique in two parts. The first part is Listener, it mainly deals with callbacks which are only run when someone call the listener outside. The second part is Subject, its important thing is managering listeners, trackcling with triggered events and invoking callbacks of corresponded listeners. Besides, I extract some data code into a independent script. Thus, I can easily add new events and not to modify my framework code.

Moreover, I add a new template feature in the new design. The feature allows that users create some common events and add an event with its event name. With the new feature, users do not write the same events again and again.

### Attribute
Attribute is changed with teh orginal version which only supported value, percent and fixed value. Now, I adjust some designs of set, get and add which start to support that using signs to read sub-attributes, such as ! represents the summation, % represents percent part of value and * represents fixed value.

### Timer
In the past, Timer was only tested in the War3. Now, I create a lua timer by using lua coroutine. Although coroutine can not split in multi thread to run, it still satisfy base test demands.

### Group
In the current version of Group, I split jass code into an independent lua script and reserve non-jass code for controlling a group behavior. The split make me test it in the pure lua environment.