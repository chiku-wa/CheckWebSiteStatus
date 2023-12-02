<#
  対象のWebサイトにアクセスし、アクセスに成功するかどうかをチェックするスクリプト。
  成功の基準は以下の通り。

  - 指定したURLに問題なくアクセスできること(=例外が発生しないこと)

  - HTTPステータスコードとして2XXが返ってくること
    ※タイムアウトは408を指すため、タイムアウトの場合は暗黙的にNGとなる

#>

# ===========================
# 共通変数

# ----- ログファイルの設定
# ログ出力先：スクリプトが動作しているディレクトリ配下の「logs」ディレクトリを出力先とする
$LogDir = "${PSScriptRoot}/logs"

# ログファイル名：「execute_<現在日時>.log」とする
$LogDateTimeStr = $(Get-Date -Format "yyyyMMdd_HHmmss")
$LogFileName = "execute_${LogDateTimeStr}.log"

# ----- チェック結果OK/NGを意味する文字列
$ResultOKStr = "★★★チェック結果OK！★★★"
$ResultNGStr = "★★★チェック結果NG！★★★"

# ----- アクセス先のWebサイトのURI
$AccessUri = "https://google.co.jp"

# ===========================
# 関数

#  -------------------------
#  [概要]
#   Webリクエストを行い、ステータスコードをもとに確認結果を返す。
#
function ValidateStatusCodeFromWebSite($uri) {
  # Googleにリクエストを行い、HTTPステータスコードを変数に格納する
  $StatusCode = (
    Invoke-WebRequest -uri $uri | Select StatusCode
  ).StatusCode

  echo "ステータスコード：${StatudCode}"

  if($StatusCode -like "2??"){
    # ステータスコードが成功を意味する文字列の場合（「2」から始まる3桁）
    return $True
  } else{
    # ステータスコードが成功を意味する文字列でない場合
    return $False
  }
}

# ===========================
# メイン処理

# ログ出力開始
Start-Transcript "${LogDir}/${LogFileName}"

echo ""
echo "======================================"
echo "チェック開始"
echo ""

try {
  echo "アクセス先のWebサイト：${AccessUri}"

  $IsValid = ValidateStatusCodeFromWebSite $AccessUri

  if($IsValid){
    echo $ResultOKStr
  }else{
    echo $ResultNGStr
  }
} catch {
  # 予期せぬ例外が発生した場合はNGとする(指定したURLが存在しない場合も例外扱いとなる)
  echo $ResultNGStr
}

echo ""
echo "チェック終了"
echo "======================================"
echo ""

# ログ出力終了
Stop-Transcript
