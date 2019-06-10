# KDE SVN 翻譯管理工具 及 KDE 翻譯流程說明
嗨！感謝您選用此 KDE SVN 翻譯管理系統（KDE SVN Translation Manager - KSVNTManage）！
這份文件會告訴您該怎麼使用這款管理系統。

## 安裝
首先，您必須安裝 git 和 svn，在我的電腦上是得跑：

```bash
$ sudo pacman -Sy git svn
```

安裝完之後，就來看看〈初始化〉吧！

## 初始化
這款管理系統的初始化工具是 `init.sh`，
你可以看看程式內附的使用方式，
或是看看這篇文章的說明。

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

這樣就 clone 完 stable 分支的 zh_TW 了。我們會稱 clone 回來的目錄叫
「 _檔案庫 (repository)_ 」。

### **進階**：讓自己的語言保持最新！
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
### 怎麼翻譯？
翻譯之前，請先閱讀
[自由軟體中文化工作流程指引](https://docs.google.com/document/d/1Zs4CS_ZjN-imnImq4aEsiVYih8zkIkVZTSQim13_kYg)，
讓整個翻譯樣式能夠一致。

KDE 的翻譯檔是 PO (gettext) 格式，可以用 Poedit 甚至線上翻譯平台 Crowdin、Transifex 開起來翻譯。
但 KDE 畢竟是個大專案，一個一個開 PO 檔翻譯可能會累死，
因此 KDE 有提供一個非常好用的 PO 翻譯工具：Lokalize！

首先，我們先安裝 Lokalize 以及 gettext 常用的一些工具：

```bash
# 安裝 lokalize
$ sudo pacman -Sy lokalize

# 安裝 gettext
$ sudo pacman -Sy gettext
```

接著，就開始 Lokalize 的設定吧！

### Lokalize 設定
首先，打開 Lokalize，並按下選單列上「專案(P)」的「建立軟體翻譯專案」（每個分支都得新增一個專案）。

接著會跳出「選擇要翻譯的 Gettext .po 檔放置的資料夾」檔案選擇框。
名稱隨便你取，而目錄請放在跟這工具同位置，比較好找。

接著，就會要你設定專案了。首先，為了防止重複勞動，我們通常都會希望「我翻 trunk 時，
stable 也跟著翻譯」，Lokalize 有提供這個功能「同步翻譯」。請依照底下的說明設定：

- 一般
  - ID: 把他改成你能識別的名字，例如「KDEtrunk」「KDEstable」
  - 郵件論壇: 把他改成「l10n-tw@linux.org.tw」或其他郵件論壇，保留原本的亦可。
  - 根目錄: 改成你想翻譯的分支，例如 trunk 或 stable 分支。
- 進階
  - 分支目錄: 改成你想要同步的 PO 翻譯檔分支，例如 stable 或 trunk 分支。
  - 其他翻譯目錄: 改成你目前的翻譯分支，例如 trunk 或 stable 分支。

到時候，兩個分支的 PO 檔就可以互相同步了。

### **進階**：Pology 使用
Pology 是翻譯 KDE 的神器啊！Pology 不僅能把 PO 檔裡面的過期翻譯清掉，還有其他實用的功能。

#### 安裝
最新的 Pology 存放在 [KDE SVN 庫](https://websvn.kde.org/trunk/l10n-support/pology/)。

請使用以下方式來 clone 或更新 Pology：

```bash
# clone pology
$ git svn clone -rHEAD svn://anonsvn.kde.org/home/kde/trunk/l10n-support/pology pology

# 更新 Pology
$ cd pology
$ git svn rebase
## 更新完成，回到原來的 Working Directory
$ cd ..
```

#### 工具箱
Pology 本身就已經附送了很多實用的工具，而我們通常使用 Pology
裡面的 posieve 居多，它使用的方法是：

```bash
# 記得先安裝 Python 2！
sudo pacman -Sy python2
# 用法
python2 [pology 存放目錄]/scripts/posieve.py 動作 [-s 參數] [-s 第二個參數] [-s ...] ...
```

而常用的動作有這些：

- `remove-obsolete`
    - 移除已經過時的字串。除非過時字串真的太多，否則沒什麼必要執行。
    - 沒有參數
- `remove-previous`
    - 移除無 fuzzy 標記的舊訊息。
    - 參數
        - `all`：移除包括 fuzzy 標記的舊訊息。
- `normalize-header`
    - 標準化每個 PO 檔案的檔頭，讓 PO 的檔頭一致化。
    - 沒有參數
- `check-kde4`
    - 檢查每個 PO 檔案的字串，看 HTML Tag 是否對稱、內容是否有效等等。
    - 參數
        - `strict`：嚴格檢查模式。建議不加。
        - `lokalize`：使用 lokalize 開啟有問題的 PO 檔，讓你比較好修正。建議加上。
            - 注意：lokalize 必須要是開著的。
- `unfuzzy-context-only`
    - 將只更改翻譯備註 (context) 的 fuzzy 翻譯取消 fuzzy 標記。
    - 沒有參數
- `unfuzzy-inplace-only`
    - 修正 HTML 標籤，並將因標籤問題而標為 fuzzy 的字串取消 fuzzy 標記。
    - 沒有參數

## 檢查翻譯成果（產生差異）
檢查翻譯成果可以在翻譯送交前找出翻譯的問題之處，減少未來的維護成本。
這款管理工具有提供一款檢查待提交翻譯的工具 -- `diff.sh`。

`diff.sh` 的功能就是「把還沒提交的變更，比較最新一個提交的內容，並得出 _差異_ 。」，
在檢查之後，如果沒有什麼問題，就可以使用 `commit.sh` 提交，關於提交的部份請參閱
〈送出翻譯成果（提交變更）〉。

假如我翻完「trunk 分支的 zh_TW 語言」，那檢查翻譯成果的指令長這樣：

```bash
$ bash diff.sh trunk zh_TW
```

看完之後按「`q`」退出檢查介面。（如果差異極少，可能就不會跳出
顯示差異的介面，此時就不需要按 `q`）

現在設想一種情況，但假如你同時翻完好幾個分支的
zh_TW 語言，一條一條輸入太慢，因此 `diff.sh`
也可以「檢視所有已初始化分支某語言的差異」，作法如下：

```bash
$ bash diff.sh all [某語言]
```

all 就是「所有已初始化分支 / 語言」的意思。依此類推，
如果要檢視「所有分支所有語言的差異」，就是 `bash diff.sh
all all` 囉！

## 送出翻譯成果（提交變更與推送）
翻譯完、檢查完之後，肯定就是要把成果丟到上游了。
此時我們使用管理工具的 `commit.sh` 來 _提交_ 並
_推送_ ！

### **基礎**：提交並推送到遠端
輸入以下指令來把「trunk 分支 zh_TW 語言的變動」提交到遠端。

```bash
$ bash commit.sh trunk zh_TW
```

這工具跟 `diff.sh` 一樣，也支援 `all`，用法如下：

```bash
# 將所有分支 zh_TW 語言的變動提交到遠端
$ bash commit.sh all zh_TW

# 將所有分支所有語言的變動提交到遠端
$ bash commit.sh all all
```

提交時會需要輸入你 ssh 的密碼（如果當初沒指定就不必），
輸入完之後…… 噹噹！你的第一個提交就完成啦！ 🎉🎉🎉

### **進階**：更多細項設定
設想一種情況，假如我們只需要先提交
（尤其是巨大變更，建議翻譯到一部分就先本機提交一次），
而先不推送到遠端，那可以透過在 commit.sh 加上 `--no-push`
選項來「先提交而不推送」。

```bash
# 只提交 trunk 分支 zh_TW 語言的變動，而不先推送
# 選項必須先加在分支和語言前面！！
$ bash commit.sh --no-push all zh_TW

# 全部翻完之後，再一起推送……
# NOTE: 如果沒有更動，直接輸入這個指令就是把
#       「待推送提交」推送出去。
$ bash commit.sh all zh_TW
```

接著我們試想另一種情況，假如我覺得預設的提交訊息
太無聊，想改提交訊息，可以透過在 commit.sh 加上 `--msg`
讓你能自己寫提交訊息。

```bash
# 用自訂的提交訊息提交 trunk 分支 zh_TW 語言的變動。
$ bash commit.sh --msg all zh_TW

# --no-push 也可以跟 --msg 混用……
$ bash commit.sh --no-push --msg all zh_TW
```

## 更新檔案庫！
某天你突然想 KDE 翻譯，而目前的檔案庫太舊…… **不要
砍掉重練啊！** ，這款管理工具有提供 `update.sh` 能讓你
把檔案庫更新到上游的最新狀態。

用法十分簡單，語法跟 `commit.sh` `diff.sh` 很像 :)

```bash
# 更新 trunk 分支 zh_TW 語言的檔案庫
$ bash update.sh trunk zh_TW

# 更新所有分支 zh_TW 語言的檔案庫
$ bash update.sh all zh_TW

# 更新所有分支所有語言的檔案庫
$ bash update.sh all all
```

## 🎉🎉🎉 **恭喜！** 🎉🎉🎉
恭喜你把這篇又臭又長的說明文件看完了！
本文件作者希望您在未來的自由軟體翻譯路上能夠順利，
並且永保翻譯初衷！😁

## 聯絡我們！
有任何關於這份文件或工具的問題，歡迎到這些地方諮詢我們：

- Telegram：[@l10n-tw](https://t.me/l10n-tw)
    - 此份文件的製作 / 貢獻者
        - [@bystartw_tw](https://t.me/bystartw_tw), 2019.
        - [@goodhorse](https://t.me/goodhorse), 2019.
- E-mail
    - 作者信箱：<pan93412@gmail.com> 
    - 郵件論壇（雖然現在是壞的）：<l10n-tw@linux.org.tw>
