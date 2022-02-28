#! zsh
date +'== %Y-%m-%d(%a) %H:%M:%S %Z(%z) :' # <-- cronのログにこのスクリプトの実行開始日時を残すようにするため。 

if [ -e $HOME/miniconda3/bin/du ] ; then PATH=$HOME/miniconda3/bin/:$PATH ; fi  # cronで実行可能とするため

STAT=stat.txt # 下記の計算結果を格納するための、ファイルの名前
CMD1='find . -name \*.csv -o -name \*.csv.gz | xargs cat | wc -c' #CMD1='cat **/*.csv{,.gz} | wc -c' 
CMD2='du -s -B1 | cut -f1' # 以前は、`case $HOST in iMacPro02.local) /Users/tshimono/miniconda3/bin/du -bs ;; *) du -bs ; esac | cut -f1 `

BYTE=$( printf "%'d" $(eval $CMD1) ) # %'d により千進法3桁区切りとした。
DUBS=$( printf "%'d" $(eval $CMD2) ) 
SWELL=$( perl -e " printf '%0.3f', ('$DUBS'=~s/,//gr) / ('$BYTE'=~s/,//gr) " ) # 何倍に膨らんだかを算出。

date +'%Y-%m-%d(%a) %H:%M:%S %Z(%z)' >| $STAT # 「2022-02-19(土) 14:21:54 JST(+0900)」のような書式で出力
printf "$BYTE\t# データファイルだけのバイト数の合計\t$CMD1\n" >> $STAT
printf "$DUBS\t# このレポジトリによるディスクスペースを使用バイト数(推定値)\t$CMD2\n" >> $STAT
printf "$SWELL\t# データファイル(最新のバージョン)のバイト数の合計に対して、レポジトリが何倍大きいかの推定値\t(前行2個の数の比)\n" >> $STAT

modified=`git diff --raw HEAD~..HEAD | grep -v -F $STAT | wc -l` # gitで扱っているファイルで変更のあったファイルが他にも有る場合のみコミットとする。↓
if [ $modified != 0 ] ; then git reset --mix ; git add $STAT ; git commit -m "$STAT ( $DUBS / $BYTE = $SWELL )" ; fi 


##  このスクリプトの機能 : 
##
##     # データを蓄えるGitレポジトリとしてのファイルサイズを記録する。
##
##  このスクリプトの実行方法 : 
##     1. 対象とするファイルを含むディレクトリまたはその上位のディレクトリで実行すること。
##     2. zsh $0 のようにzshにこのスクリプトファイルを渡しても良いし、
##         zshの環境でそのまま実行ファイルとして実行しても良い。(一応bashでも使えるようにしてみた。千進法区切りは使えなさそう。)
##     3. 計算機環境に依存する du コマンドを用いているので、PATHも設定が必要だし、
##         場合によっては、このスクリプトファイルの最初の方を書き換える必要がある。
## 
##  このスクリプトが出力する内容: 
##
##    あるGitレポジトリの、
##     (1) データファイルのバイトサイズの合計と、
##     (2) そのレポジトリの全てのファイルのサイズの合計を求め、
##     (3) さらに (2)÷(1)も残す(何倍に肥大化しているかを知るため)。
##    上記をあるファイルに書き残す。
## 
##    さらに、このファイルの他のファイルが、Gitレポジトリのインデックスに存在する場合に限り、
##    gitコミットを実行する。
##      - このスクリプトが生成するファイルである$STATのみが変化した場合のコミットは無駄なため。
##      - なお、コミットメッセージについては、ひとつひとつのファイルについての注釈としたい。
##
##
##  目的: 
##
##     レポジトリ肥大化の監視の為。
##  
## 
##  開発上のメモ: 
##
##    * du と言う環境に依存しているシェルのコマンドを用いている。従って、パス(PATH)を適切に通す必要がある。
##    * 単に if fi に慣れて無いので、 case in esac の構文を用いた。
##
##
##  このファイルの制作者: 下野寿之 (Toshiyuki Shimono) 統計数理研究所 特任研究員

