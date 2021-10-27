# 使用指南

請參考https://philipzheng.gitbooks.io/docker_practice/content/image/create.html

## 注意事項
- 如果要切換到別的槽，例如d槽，請輸入 cd /d

## image
### 安裝
- docker build -t {名稱} {Dockerfile所在目錄的位置}

### 刪除
- docker rmi {image名稱}

### 更新
- docker commit {OPTIONS} {容器id} {image名稱[:TAG]}

## container
### 建立
- docker run -it {image名稱} bash

### 進入創建好的container
- docker ps -a : 查看container名稱
- docker exec -it {container名稱或ID} bash
- docker container start {container名稱或ID}：啟動已經關閉的container

### 刪除
- docker rm {container名稱或ID}

### 檔案傳輸
- 傳入: docker cp 本地檔案路徑(絕對路徑) {container ip}:目標路徑
- 傳出: 先刪除本地檔案；再docker cp {container ip}:檔案路徑 本地目標路徑

### 雲端
- 上傳: docker push [OPTIONS] NAME[:TAG]
- 下載: docker pull [OPTIONS] NAME[:TAG|@DIGEST]


