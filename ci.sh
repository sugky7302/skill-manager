#!/bin/bash
# Program:
#	Load files in the specified folder. Then, run the file if the type of the file is lua.
# History:
# 2021/10/18	Arvin Yang	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

export LUA_PATH="/usr/local/lib/lua/5.4/?.lua;/usr/local/lib/lua/5.4/?/__init__.lua;"
export LUA_CPATH="/usr/local/lib/lua/5.4/?.so;/usr/local/lib/lua/5.4/?/__init__.so;"

read_dir(){
    for file in $(ls -a "$1")
    do
        if [[ "$file" != "." && "$file" != ".." ]]; then
            if [ -d "$1/$file" ]; then
                read_dir "$1/$file"
            elif [ "${file##*.}" == "lua" ]; then
                echo "$1/$file"
                lua "$1/$file"
            fi
        fi
    done
}
#測試目錄 test
read_dir "/home/test"