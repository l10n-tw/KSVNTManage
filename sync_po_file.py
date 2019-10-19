#!/usr/bin/python3
'''
可以同步您語言目錄和範本的應用程式。

[注意]
 - 確保 template 與語言目錄是最新的
 - 確保已經安裝 gettext-tools
 - 確保您系統有安裝 python3.7 或更新版本
'''

import sys, shutil, os
import argparse
import subprocess
import shlex # for subprocess

argp = argparse.ArgumentParser(
    description="同步 KDE SVN 檔案庫中範本與語言中的翻譯檔案",
    epilog="請將問題回報至 <pan93412@gmail.com>",
    formatter_class=argparse.RawTextHelpFormatter
)

argp.add_argument(
    "template_path",
    action="store",
    type=str,
    help="""\
範本檔存放位置。（末端需要「/」！！！）

以 KDE 5 的應用程式翻譯檔範本為例，它通常會像這樣：
https://websvn.kde.org/trunk/l10n-kf5/templates/messages/
"""
)
argp.add_argument(
    "translation_path",
    action="store",
    type=str,
    help="""\
翻譯檔存放位置。（末端需要「/」！！！）

以 KDE 5 的應用程式翻譯檔 (zh_TW) 為例，它通常會像這樣：
https://websvn.kde.org/trunk/l10n-kf5/zh_TW/messages/
"""
)
argp.add_argument(
    "--merge",
    action="store_true",
    help="是否完整合併所有翻譯檔（使用範本檔作來源）？\n除非翻譯檔存放位置與範本脫節非常嚴重，否則不建議使用此功能。",
    dest="mergeSwitch"
)

argv = argp.parse_args()

def merge_translations(template, old):
    '''
    使用 msgmerge 工具合併翻譯。
    
    template: 範本檔
    old:      原翻譯檔
    回傳值:    msgmerge 執行的回傳值，預設為 0
    '''
    # -q 必須，否則會導致進度列無法正常運作。
    merge = subprocess.Popen(shlex.split(f"msgmerge -U --backup=none --previous -q {old} {template}"))
    merge.wait()
    
    return merge.returncode

def copy(source, target):
    '''
    將 source 複製到 target。
    
    source: 來源檔案
    target: 目標位置
    回傳值:  一律為 None。
    '''
    shutil.copyfile(source, target)
    return None

def recursive(path):
    '''
    遞迴目錄，並回傳檔案列表。
    
    傳入：
      path: 要遞迴的目錄
    
    回傳：檔案列表與所有目錄列表。
    '''
    filelist = []
    dirlist = []
    # 要排除的檔案 / 目錄名稱
    excludes = [".git", ".svn"]
    for dirbase, dirnames, filenames in os.walk(path):
        for dirname in dirnames:
            # 這迴圈將遞迴檢查以下項目：
            #  - 曾未出現在 dirlist 中。
            #
            # 並將「dirbase/dirname」加入 dirlist 中。
            if dirlist.count(dirname) == 0:
                dirlist.append(os.path.join(dirbase, dirname))
        
        for filename in filenames:
            # 此迴圈將遞迴檢查以下項目：
            #  - 曾未出現在 filelist 中。
            #  - 檔名結尾必須是 ".po" 或 ".pot"
            #
            # 並將「dirbase/filename」加入 filelist 中。
            if ".po" in filename or ".pot" in filename and filelist.count(filename) == 0:
                filelist.append(os.path.join(dirbase, filename))
    
    for filename in filelist:
        for exclude in excludes:
            if exclude in filename:
                filelist.remove(filename)
                continue
    
    for dirname in dirlist:
        for exclude in excludes:
            if exclude in dirname:
                dirlist.remove(dirname)
                continue

    return filelist, dirlist

symbol = "^" # 一開始的動畫
def symbolChanger(symbol):
    '''
    毫無意義的概念www
    
    symbol: 傳入 "." "-" "=" "^" 任一個，將會不斷重複這幾個動畫
    '''
    
    if symbol == "^":
        return "."
    elif symbol == ".":
        return "-"
    elif symbol == "-":
        return "="
    elif symbol == "=":
        return "^"
    else:
        raise Exception("動畫好像未初始成功……")

def determine_translationfile(templatedir, translationdir):
    '''
    檢查目前的翻譯檔案是要合併還是要複製範本檔
    
    templatedir:     範本目錄
    translationdir:  翻譯檔目錄
    '''
    global symbol # 把這裡的 symbol 提升到全域。
    
    templateFileList, templateFolderList = recursive(templatedir)
    # 處理最後一個檔案時，「剩餘 xx 數：[y]」的 [y] 我希望是 0，所以皆 -1。 
    templateFileCount, templateFolderCount = len(templateFileList)-1, len(templateFolderList)-1
    
    translationFileList, translationFolderList = recursive(translationdir)

    print("""\
[->] 開始檢查範本資料夾數是否與翻譯檔的資料夾數相同……

     假如有一個資料夾範本有，但翻譯檔資料夾沒有，則會在翻譯檔資料夾建立同名資料夾。
     假如有一個資料夾範本沒有，但翻譯檔資料夾有，則不進行任何動作。
""")
    
    # 開始檢查範本資料夾數是否與翻譯檔的資料夾數相同……
    for templateFolder in templateFolderList:
        symbol = symbolChanger(symbol)
        print("\r{0} 剩餘 {1} 個未複製目錄……     ".format(symbol, templateFolderCount), end="", flush=True)
        copyToDir = templateFolder.replace(templatedir, translationdir)
        
        if os.path.exists(copyToDir) == False:
            os.mkdir(copyToDir)
            print(f"\n[!] 已建立資料夾：{copyToDir}")
            
        templateFolderCount -= 1
        
    print("""\
\n[->] 開始更新翻譯檔資料夾中的翻譯檔案……

     假如有一個 PO 檔，翻譯檔資料夾沒有但範本資料夾卻有，則會使用
       msginit 來初始化範本檔中的 POT 檔，並複製到
       翻譯檔資料夾。
     假如有一個 PO 檔，範本和翻譯檔資料夾都有，且有傳入 --merge
       參數，則會使用 msgmerge 合併。
""")


    # 開始更新翻譯檔資料夾中的翻譯檔案……
    for templateFile in templateFileList:
        symbol = symbolChanger(symbol)
        print("\r{0} 剩餘 {1} 個未處理檔案……     ".format(symbol, templateFileCount), end="", flush=True)
        
        toProcessFile = templateFile.replace(templatedir, translationdir).replace(".pot", ".po")
 
        if os.path.exists(toProcessFile):
            if argv.mergeSwitch == True:
                merge_translations(templateFile, toProcessFile)
        else:
            copyPot = subprocess.Popen(
                shlex.split(f"msginit --no-translator -l zh_TW.UTF-8 -o {toProcessFile} -i {templateFile}"),
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            copyPot.wait()
            
            if copyPot.returncode != 0:
                print(f"\n[*] 警告：初始化 {templateFile} 至 {toProcessFile} 時發生錯誤……")
            else:
                print(f"\n[!] 已初始化 PO 檔：{toProcessFile}")
            
        templateFileCount -= 1
        
    # 空白得保留。
    print("\r處理完成。請再次檢查結果，以確保合併沒有任何錯誤！   ")
    return

determine_translationfile(argv.template_path, argv.translation_path)
