# KDE SVN 翻譯管理工具
嗨！感謝您選用此 KDE SVN 翻譯管理系統（KDE SVN Translation Manager - KSVNTManage）！
這份文件會告訴您該怎麼使用這款管理系統。

## 安裝
首先，您必須安裝 git 和 svn，在我的電腦上是得跑：

```bash
$ sudo pacman -Sy git svn
```

安裝完之後，就來看看〈初始化〉吧！

## 初始化
這款管理系統的初始化工具是 `init.sh`，你可以輸入

```bash
$ bash init.sh
```

看看使用方式，或是看看這篇文章的說明。

### KDE Developer Account 的設定
首先，你得先弄個 KDE Developer Account (下略 DA)，如果你還沒有，
去 Telegram 找 [@goodhorse](https://t.me/goodhorse) 請求一隻，
這位 KDE 繁體中文的協調者對於註冊 DA 帳號的過程比我更懂 XDD

搞到之後，你必須先產生 ssh 金鑰：
```bash
# 先安裝 SSH
$ sudo pacman -Sy openssh

# 產生金鑰
$ ssh-keygen
```

產生到的 ssh 金鑰（家目錄的 .ssh 目錄）請妥善保管，
例如丟在 Google Drive 或是自建的 NextCloud 平台等等。

備份好後，請把 ssh 公鑰 (家目錄 .ssh 目錄的 id_rsa.pub 檔案）傳到 DA 的後台，
就可以開始初始化囉！

### 真正開始初始化！
輸入：

```bash
$ bash init.sh --dev trunk zh_TW
```

這串指令的意思是「使用 DA 帳號來 clone 存放在 KDE 翻譯庫 trunk (下一版) 分支的 zh_TW 語言內容。」。

如果不加 `--dev`，就代表「我不用 DA 帳號來 clone」，DA 帳號是用來上傳翻譯的「鑰匙」，如果
不加 `--dev`，代表「我只是看看，什麼也不做」，到時候提交翻譯時可會報錯的！

好的，我們 clone 好 trunk 分支了，正常情況下這樣就行…… 但假如我也想翻譯 stable (目前的穩定版) 分支呢？
請輸入：

```bash
$ bash init.sh --dev stable zh_TW
```

這樣就 clone 完 stable 分支的 zh_TW 了。

### 進階：讓自己的語言保持最新！
因為 KDE 在把新程式的翻譯檔丟上去的時候，**並不會把所有語言都丟一遍**，只會放在 `templates`
資料夾等你同步，所以需要同步範本才能讓自己的語言保持最新。

首先，我們先初始化範本（因為我們不用把變動提交到範本區，所以…… 就不用加 `--dev` 了）：

```bash
$ bash init.sh trunk templates
# 如果你也有 clone stable…
$ bash init.sh stable templates
```

之後，使用附在這檔案庫的 `sync_po_file.py` 來同步 PO 檔：

```bash
# 不可以 python3 sync_po_file.py KDE[分支]/templates/ KDE[分支]/zh_TW/
# 每個目錄後面也一定得加斜槓 (/)，不然會出錯 QAQ
# 這程式是我之前寫的，所以有點不符合現在需求……
$ python3 sync_po_file.py KDE[分支]/templates/messages/ KDE[分支]/zh_TW/messages/
# 可以不執行，畢竟我們通常都不翻文件。
$ python3 sync_po_file.py KDE[分支]/templates/docmessages/ KDE[分支]/zh_TW/docmessages/
```

之後，把新同步的 PO 檔翻完之後提交（或是先加 `--no-push` 提交，翻譯，再提交）。

## 翻譯
<!-- TODO: 將 https://websvn.kde.org/trunk/l10n-support/zh_TW/README.txt?revision=1538626&view=markup 也寫進來 -->
