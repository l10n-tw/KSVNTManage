# KDE SVN 翻譯管理工具 | 差異工具

# 載入函式庫
. ./libs.sh

# 顯示說明
if [[ $# == 0 ]]
then
    echo "KDE SVN 翻譯管理工具 | 差異工具"
    echo "用法：$0 [分支] [語言]"
    echo ""
    echo "此工具將會顯示 KDE[分支]/[語言] 檔案庫的變動。"
    echo ""
    echo "分支:         要比較的分支，可以是：trunk、stable 和 all（全部）。"
    echo "語言:         要比較的語言，可以是："
    echo "              https://websvn.kde.org/trunk/l10n-kf5/"
    echo "              所列出的語言（templates 則是範本）或"
    echo "              all（全部）。"
    exit 1
fi

branch=$1
lang=$2
if [[ $branch == "" ]] || [[ $lang == "" ]]
then
    invaild_arg
fi

inputBranch="$branch"
if [[ $branch == "all" ]]
then
    branch=$(find -maxdepth 1 -type d -name "KDE*" -not -path ".")
else
    branch="KDE$branch"
fi

# start diffing

## 判斷輸入之 branch 及 lang
dir="${branch}/${lang}"
if [[ -d $dir ]] || [[ "$inputBranch$lang" == "allall" ]] || [[ "$inputBranch$lang" == "${inputBranch}all" ]] || [[ "$inputBranch$lang" == "all${lang}" ]]
then
    true  # 通過！
else
    noInit # help:  顯示「尚未初始化」訊息。
fi

userInputLang="$lang"

for b in $branch
do
    cd "$b"
    if [[ $userInputLang == "all" ]]
    then
        lang=$(find -maxdepth 1 -type d -name '*' -not -path '.')
    fi
    
    for l in $lang
    do
        echoerr "正在產生 $(basename $b "./") 分支 $(basename $l "./") 語言的差異…"
        # usage: diff (dir)
        # help: 產生 SVN 庫的變動。
        diff "$l"
    done
    cd .. # 回去原本的 WD
done
