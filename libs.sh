# KDE SVN 翻譯管理工具 | 函式庫

##          ##
## 常數共識 ##
##          ##
# 1 = true 啟用
# 0 = false 停用
# null = 空值

##          ##
##  函式庫  ##
##          ##

# 暫無 // TODO: 未來可能會支援 gettext（嗎

##          ##
## 底層函式 ##
##          ##

# usage: error_msg (message..)
# help:  輸出「錯誤：XXX」至 stderr
# varlist:         $@
error_msg() {
    # &2 = /dev/stderr
    echo -e "\x1b[1m\x1b[31m錯誤：$@\x1b[0m" >&2
}

# usage: warn_msg (message..)
# help:  輸出「警告：XXX」至 stderr
# varlist:        $@
warn_msg() {
    # &2 = /dev/stderr
    echo -e "\x1b[1m\x1b[33m警告：$@\x1b[0m" >&2
}

# usage: info_msg (message..)
# help:  輸出「資訊：XXX」至 stdout
# varlist:        $@
info_msg() {
    # &2 = /dev/stderr
    echo -e "\x1b[36m資訊：$@\x1b[0m"
}

# usage: debug_msg (message..)
# help:  輸出「除錯：XXX」至 stdout
# varlist:         $@
debug_msg() {
    # &2 = /dev/stderr
    echo -e "\x1b[90m除錯：$@\x1b[0m"
}

##          ##
## 外部函式 ##
##          ##

# usage: envcheck
# help:  檢查使用者環境。
# varlist: 無
envcheck() {
    # git-svn 所需：git && svn
    for prog in git svn msgfmt diff find
    do
        if [[ -x "/usr/bin/$prog" ]] && [[ -s "/usr/bin/$prog" ]]
        then
            true # 正確
        else
            error_msg "錯誤：未找到 $prog 程式。"
            info_msg  "請先安裝 $prog 程式後再重新啟動程式。"
            exit 1
        fi
    done
    # error_msg "檢查成功：git & svn 皆存在。" # [debug]
}

# usage: init (url) (path) (desc)
# help:  初始化 SVN 翻譯庫 (使用 git-svn)
# varlist:    $1    $2     $3
init() {
    info_msg "正在初始化 KDE SVN 翻譯庫：$3"
    git svn clone -rHEAD $1 $2
}

# usage: commit (dir) (message) (option)
# help:  提交變更。
# varlist:      $1    $2        ...
# option:
# $3 = is_push (default: 1, option: 0/1)
#      是否推送至 SVN 伺服器？
# $4 = is_msg (default: 0, option: 0/1)
#      是否手動指定訊息？
commit() {
    cd $1
    git add -A # add all the staging file.

    if [ "$4" == "1" ]
    then
        git commit
    else
        git commit -m "$2"
    fi

    if [ "$3" != "0" ]
    then
        git svn dcommit
    fi

    cd ..
}

# usage: upd (dir)
# help: 更新 SVN 庫。
# varlist:   $1
upd() {
    cd $1
    git svn rebase
    cd ..
}

# usage: diff (dir)
# help: 產生 SVN 庫的變動。
# varlist:    $1
diff() {
    cd $1
    git diff -U15
    cd ..
}

# usage: invaild_arg
# help:  顯示「參數無效」訊息。
# varlist: 無
invaild_arg() {
    error_msg "參數無效。輸入 $0 取得說明。"
    exit 1
}

# usage: noInit
# help:  顯示「尚未初始化」訊息。
# varlist: 無
noInit() {
    error_msg "尚未初始化 ${inputBranch} 分支，${lang} 語言的檔案庫。"
    exit 2
}

##          ##
## 標準常數 ##
##          ##

## KDE 5 Repos

# usage: ${TRUNK_REPO}/[語言][/{messages, docmessages}]
# help:  KDE trunk 的 repo (developer account)
TRUNK_REPO="svn+ssh://svn@svn.kde.org/home/kde/trunk/l10n-kf5"

# usage: ${TRUNK_ANONYMOUS_REPO}/[語言][/{messages, docmessages}]
# help:  KDE trunk 的 repo (anonymous)
TRUNK_ANONYMOUS_REPO="svn://anonsvn.kde.org/home/kde/trunk/l10n-kf5"

# usage: ${STABLE_REPO}/[語言][/{messages, docmessages}]
# help:  KDE stable 的 repo (developer account)
STABLE_REPO="svn+ssh://svn@svn.kde.org/home/kde/branches/stable/l10n-kf5"

# usage: ${STABLE_ANONYMOUS_REPO}/[語言][/{messages, docmessages}]
# help:  KDE stable 的 repo (anonymous)
STABLE_ANONYMOUS_REPO="svn://anonsvn.kde.org/home/kde/branches/stable/l10n-kf5"

##          ##
## 初始指令 ##
##          ##
if [ ! "$LOADLIB" == "1" ]
then
    error_msg "錯誤：這是函式庫，不應直接執行！"
    info_msg  "提示：如要將此函式庫載入您的程式，請在載入前插入："
    info_msg  "      LOADLIB=1"
    exit 1
fi
envcheck # 檢查環境
