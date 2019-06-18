# KDE SVN 翻譯管理工具 | 提交工具

# 載入函式庫
. ./libs.sh

# 顯示說明
if [[ $# == 0 ]]
then
    echo "KDE SVN 翻譯管理工具 | 提交工具"
    echo "用法：$0 [--no-push] [--msg] [分支] [語言]"
    echo ""
    echo "此工具將會提交存放於 KDE[分支]/[語言] 的檔案庫。"
    echo ""
    echo "[--no-push]:  不要推送至遠端。"
    echo "[--msg]:      變更預設的提交訊息。"
    echo "              預設：Update [語言] in [分支] to the latest."
    echo "分支:         要提交的分支，可以是：trunk、stable 和 all（全部）。"
    echo "語言:         要提交的語言，可以是："
    echo "              https://websvn.kde.org/trunk/l10n-kf5/"
    echo "              所列出的語言（templates 則是範本）或"
    echo "              all（全部）。"
    exit 1
fi

push=1
customMsg=0
for arg in $@
do
    case $arg in
        "--no-push") 
            push=0
            shift
            ;;
        "--msg")
            customMsg=1
            shift
            ;;
    esac
done

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
        # usage: commit (dir) (message) (option) (is_push) (is_msg)
        # help:  提交變更。
        commit "$l" "Update $(basename "${l}" "./") in $(basename "${b}" "./") to the latest." "$push" "$customMsg"
    done
    cd .. # 回去原本的 WD
done
