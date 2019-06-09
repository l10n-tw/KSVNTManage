# KDE SVN 翻譯庫 | 初始化工具

# 載入函式庫
. ./libs.sh

# 檢查參數
if [[ $# == 0 ]] || [[ $# == "--help" ]] || [[ $# == "-h" ]]
then
    echo "KDE SVN 翻譯庫 | 初始化工具"
    echo "用法：$0 [--dev] 分支 語言"
    echo ""
    echo "預設初始化工具會將 checkout (clone) 回來的"
    echo "檔案庫放在 KDE[分支]/[語言] 當中。"
    echo ""
    echo "[--dev]:  使用 KDE Developer 帳戶 checkout 檔案庫。"
    echo "分支:     要 checkout 的分支，可以是：trunk 和 stable。"
    echo "語言:     要 checkout 的語言，可以是："
    echo "          https://websvn.kde.org/trunk/l10n-kf5/"
    echo "          所列出的語言。（templates 則是範本。）"
    exit 1
fi

for arg in $@
do
    case $arg in
        "--dev") 
            devAccount=1
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

# starting checkout.
cloneDir="KDE${branch}"
if [[ ! -d $cloneDir ]]
then
    mkdir $cloneDir
fi

case $branch in
    "trunk")
        if [ "$devAccount" == "1" ]
        then
            init "${TRUNK_REPO}/${lang}" "${cloneDir}/${lang}" "KDE ${branch} ${lang} - KDE Developer Account Mode"
        else
            init "${TRUNK_ANONYMOUS_REPO}/${lang}" "${cloneDir}/${lang}" "KDE ${branch} ${lang} - Anonymous Mode"
        fi
        ;;
    "stable")
        if [ "$devAccount" == "1" ]
        then
            init "${STABLE_REPO}/${lang}" "${cloneDir}/${lang}" "KDE ${branch} ${lang} - KDE Developer Account Mode"
        else
            init "${STABLE_ANONYMOUS_REPO}/${lang}" "${cloneDir}/${lang}" "KDE ${branch} ${lang} - Anonymous Mode"
        fi
        ;;
    *)
        rmdir $cloneDir # Remove the useless directory...
        invaild_arg
        ;;
esac
        
