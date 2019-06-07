# KDE SVN 翻譯庫 | 函式庫

##      ##
## 共識 ##
##      ##
# 1 = true 啟用
# 0 = false 停用

##          ##
## 底層函式 ##
##          ##

# help:  將文字輸出至 stderr
# usage: echoerr (message..)
# varlist:       $@
echoerr() {
    echo "$@" > /dev/stderr
}

##          ##
## 外部函式 ##
##          ##

# help:  檢查使用者環境。
# usage: envcheck
# varlist: 無
envcheck() {
    # git-svn 所需：git && svn
    for prog in "git svn"
    do
        if [[ ! -x -s /usr/bin/$prog ]]
        then
            echoerr "錯誤：未找到 $prog 程式。"
            exit 1
        fi
    done
    echoerr "檢查成功：git & svn 皆存在。"
}

# help:  初始化 SVN 翻譯庫 (使用 git-svn)
# usage: init (url) (path) (desc)
# varlist:    $1    $2     $3
init() {
    echo "正在初始化 KDE SVN 翻譯庫：$3"
    git svn clone -rHEAD $1 $2
}

# help:  提交變更。
# usage: commit (folder) (message) (option)
# varlist:      $1        $2        ...
# option:
# $3 = is_push (default: 1, option: 0/1)
#      是否推送至 SVN 伺服器？
commit() {
    cd $1
    git add -A
    git commit -m "$2"
    if [ $3 == 1 ] || [ $3 == "" ]
    then
        git svn dcommit
    fi
    cd ..
}

# help: 更新 SVN 庫。
# usage: upd (folder)
# varlist:   $1
upd() {
    cd $1
    git svn rebase
    cd ..
}
