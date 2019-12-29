# KDE SVN 翻譯管理工具 | 檢查工具

# 載入函式庫
LOADLIB=1
. ./libs.sh

# 顯示說明
if [[ $# == 0 ]]
then
    echo "KDE SVN 翻譯管理工具 | 檢查工具"
    echo "用法：$0 [分支] [語言]"
    echo ""
    echo "此工具將會使用 msgfmt 檢查 KDE[分支]/[語言] 檔案庫的翻譯檔。"
    echo ""
    echo "分支:         要檢查的分支，可以是：trunk、stable 和 all（全部）。"
    echo "語言:         要檢查的語言，可以是："
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

# start checking

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
        echoerr "正在檢查 $(basename $b "./") 分支 $(basename $l "./") 語言的格式…"

        cd $l
        for file in `find -name "*.po" -type f`
        do
            echo -ne "\r正在檢查下述檔案：$file…       " >&2
            result="`msgfmt -c -o /dev/null $file 2>&1`"
            if [[ "$result" != "" ]] && [[ "`echo $result | grep '嚴重錯誤\|fatal error'`" != "" ]]
            then
                echo "
檢查的分支：$(basename $b "./")
檢查的語言：$(basename $l "./")
檢查的檔案：$file
---
$result
" | less
            elif [[ "$result" != "" ]]
            then
                echo "
檢查的分支：$(basename $b "./")
檢查的語言：$(basename $l "./")
檢查的檔案：$file
---
$result
"
            fi
        done
        cd ..
    done
    cd .. # 回去原本的 WD
done
