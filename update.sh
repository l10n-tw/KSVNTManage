# KDE SVN 翻譯管理工具 | 更新工具

# 載入函式庫
. ./libs.sh

# 顯示說明
if [[ $# == 0 ]]
then
    echo "KDE SVN 翻譯管理工具 | 更新工具"
    echo "用法：$0 [分支] [語言]"
    echo ""
    echo "此工具將會更新存放於 KDE[分支]/[語言] 的檔案庫。"
    echo ""
    echo "分支:         要更新的分支，可以是：trunk、stable 和 all（全部）。"
    echo "語言:         要更新的語言，可以是："
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

# start commiting

## 判斷輸入之 branch 及 lang
dir="${branch}/${lang}"
if [[ -d $dir ]] || [[ "$inputBranch$lang" == "allall" ]] || [[ "$inputBranch$lang" == "${inputBranch}all" ]] || [[ "$inputBranch$lang" == "all${lang}" ]]
then
    true  # 通過！
else
    echo "尚未初始化 ${inputBranch} 分支，${lang} 語言的檔案庫。"
    exit 1
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
        # usage: upd (dir)
        # help: 更新 SVN 庫。
        echoerr "正在更新 $(basename $b "./") 分支 的 $(basename $l "./") 語言…"
        upd "$l"
    done
    cd .. # 回去原本的 WD
done
