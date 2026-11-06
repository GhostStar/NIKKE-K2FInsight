#requires -Version 5.1
<#
.SYNOPSIS
    insight.bundle の静的ルールに該当するファイルを一覧にします。
.DESCRIPTION
    Windows PowerShell 5.1 または PowerShell 7 で、調査対象のユーザーとして実行します。
    insight.bundle の組み込みビルド識別子 K2F_LUA_BUILD = 722b99d8d0e9 を基にしています。
    サンプルは 205135 バイトで、LuaJIT バイトコード形式のバージョンは 1 です。
    サンプルの SHA256 は cc0ad05bfe85940a6067b3a72c182d3953339129206634141926d5d0b35973ec です。
    内蔵の資格情報パスとウォレット拡張機能 ID は関数 #205 と #141 から抽出しました。
    ファイルの説明はファイル名、パス、静的ルールに基づきます。
    ファイルとデータソースの項目を同じ CSV に保存します。
    再解析ポイント、オフラインのファイル、リモートパスはスキップします。
    バンドルから復元したルールでファイルを一覧にします。
    CSV は PowerShell の現在のディレクトリに保存します。
.EXAMPLE
    .\K2FInsight-ja-JP.ps1
#>
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$BundleBuild = '722b99d8d0e9'
$BundleSha256 = 'cc0ad05bfe85940a6067b3a72c182d3953339129206634141926d5d0b35973ec'
$InventoryLocale = 'ja-JP'
$InventoryText = @'
{
  "RequiresWindows": "このスクリプトは Windows 用です。",
  "InvalidParent": "CSV の出力先にはアクセス可能な既存のディレクトリを指定してください。",
  "Skipped": "一部のパスをスキップしました。スキャン統計を確認してください。",
  "Metadata": {
    "Headers": {
      "Type": "レコード種別",
      "Location": "ソースの場所",
      "Item": "項目"
    },
    "Source": {
      "ProcessEnvironment": "現在のプロセス環境",
      "RegistryEnvironment": "Windows 環境レジストリ",
      "CredentialManager": "Windows 資格情報マネージャー",
      "SavedSessions": "保存されたセッション",
      "File": "ファイル"
    },
    "Description": {
      "EnvironmentEmpty": "名前の条件に一致する変数は見つからなかった。",
      "CredentialEmpty": "絞り込み条件に一致する項目は見つからなかった。",
      "CredentialItem": "資格情報ターゲットのメタデータ。識別できるサービスやホストと項目の指紋を表示する。",
      "SessionEmpty": "このレジストリパスに保存済みセッションは見つからなかった。",
      "SessionItem": "セッションのレジストリサブキー。通常の名前または項目の指紋を表示する。",
      "Unavailable": "このソースの確認を完了できなかった。",
      "EnvironmentName": "名前のルールに一致した変数。"
    }
  },
  "File": {
    "SshIncludeFile": "SSH の Include が参照するローカル設定。ファイルの特定に必要な指示のみを解析する。",
    "SshIdentityFile": "SSH の IdentityFile が指定するローカル鍵ファイル候補。メタデータのみ確認。",
    "SessionKeyFile": "PuTTY または WinSCP の PublicKeyFile が参照するファイル。メタデータのみ確認。",
    "SshConfig": "SSH クライアントの設定ファイル。接続先、ユーザー名、認証鍵のパス、追加の設定ファイルを指定できます。",
    "SshFile": "SSH 設定ディレクトリ内のファイル。認証鍵、設定、その他の SSH データの可能性があります。",
    "KeySource": "サンプルが鍵や証明書の保存先として扱うパス内のファイル。実際の形式や秘密鍵の有無は未確認です。",
    "DotNetSecrets": ".NET 開発用のユーザーシークレット JSON。アプリの秘密情報や接続文字列を保存できます。",
    "EditorDatabase": "{0} の SQLite 状態データベース。エディターや拡張機能のデータを保存し、一部のレコードにアカウント、認証、セッションの状態が含まれることがあります。",
    "ContainerConfig": "{0} のコンテナレジストリ設定。認証情報や資格情報ヘルパーへの参照が含まれる場合があります。",
    "FtpSites": "FileZilla のサイト設定または最近の接続記録。サーバー、アカウント、保存済み認証情報の項目を含む場合があります。",
    "GitConfig": "Git の設定ファイル。リモートリポジトリ、ユーザー情報、資格情報ヘルパーなどを設定できます。",
    "GoEnv": "Go ツールチェーンの環境設定。モジュールプロキシや非公開リポジトリの設定を含む場合があります。",
    "CodexAuth": "Codex CLI の認証情報ファイル。ログイン方式に応じて、トークンや API 認証データを含む場合があります。",
    "CodexConfig": "Codex CLI の設定ファイル。モデル提供元、接続先、MCP などの連携を設定できます。",
    "PowerShellProfile": "PowerShell の起動時に読み込むプロファイルスクリプト。コマンド、パス、環境変数などを定義できます。",
    "ExtensionSettings": "エディター拡張機能が globalStorage に保存する JSON。設定、連携先、アカウントやセッションの情報を含む場合があります。",
    "ProtectedStore": "{0} の Windows DPAPI で保護された認証キャッシュ。値の復元には対応する Windows の保護コンテキストが必要です。",
    "CatalogDatabase": "{0} のローカル SQLite データベース。サンプルはアカウントや認証情報の取得元として扱います。",
    "McpConfig": "{0} の MCP 設定ファイル。サーバーの起動コマンド、URL、認証設定を定義できます。",
    "CatalogCache": "{0} のキャッシュファイル。サンプルのパスルールに該当し、一時的な認証やセッションの状態が含まれる場合があります。",
    "CatalogAuth": "{0} のファイル。ファイル名から認証情報、資格情報、トークンの保存に使われる可能性があります。",
    "CatalogConfig": "{0} の設定またはローカル状態ファイル。サンプルの一覧に含まれ、接続先や認証設定を保存する場合があります。",
    "ProjectEnv": "プロジェクトの環境変数ファイル。実行設定、接続文字列、API キーなどを定義できます。",
    "ProjectConfig": "プロジェクトの設定または秘密情報の候補ファイル。サンプルのファイル名ルールに該当します。",
    "GitCredentialStore": "Git の資格情報ファイル。資格情報付き URL にユーザー名、パスワード、トークンを保存する場合があります。",
    "TerminalHistory": "コマンドや対話シェルの履歴。過去に入力したコマンドにパス、URL、直接入力した秘密情報が含まれる場合があります。",
    "KubeConfig": "Kubernetes クライアントの設定。クラスター、コンテキスト、ユーザーの項目に加え、トークン、証明書、鍵ファイルへの参照を含む場合があります。",
    "GpgPublic": "GnuPG の公開鍵ボックス。公開鍵と関連する識別情報を保存します。",
    "GpgSecretRing": "旧形式の GnuPG 秘密鍵リング。格納された鍵はパスフレーズで保護されている場合があります。",
    "GpgPrivateKey": "GnuPG の秘密鍵コンテナー。鍵はパスフレーズで保護されている場合や、ハードウェアトークンへの参照だけを保持する場合があります。",
    "ChromiumLocalState": "{0} のブラウザー全体の設定と鍵のメタデータ。ブラウザーデータを保護する暗号鍵がラップされた状態で保存される場合があります。",
    "ChromiumCookies": "{0} のプロファイル別 Cookie データベース。Cookie の値は暗号化される場合があり、有効な Web セッションに関係することがあります。",
    "ChromiumLogins": "{0} の保存済みログイン用データベース。サイト、ユーザー名、暗号化されたパスワードの項目を含む場合があります。",
    "ChromiumWal": "{0} の SQLite 先行書き込みログ。メインファイルにまだ反映されていない新しいデータページを含む場合があります。",
    "ChromiumShm": "{0} の SQLite 共有メモリ補助ファイル。先行書き込みログの索引とアクセス調整に使われます。",
    "FirefoxKeys": "Firefox プロファイルの NSS 鍵データベース key4.db。保存済みログイン情報の保護に使われます。",
    "FirefoxLogins": "Firefox の保存済みログインファイル logins.json。サイト情報と暗号化されたユーザー名やパスワードの項目を含む場合があります。",
    "WalletLog": "{0} ウォレット拡張機能に関連付けられた保存先の LevelDB 書き込みログ。最近のレコードを含む場合があります。",
    "WalletTable": "{0} ウォレット拡張機能に関連付けられた保存先の LevelDB テーブル。拡張機能の状態や暗号化されたウォレットデータを含む場合があります。",
    "NikkeSavedPassword": "NIKKE ランチャーのアカウント保存ファイル psd.dat。サンプルは保存済みパスワードの復元処理に使います。",
    "NikkeLastUser": "NIKKE ランチャーの last_user.dat。最後に使用したアカウントに関するファイルです。"
  },
  "Branch": {
    "KeyscanDiscovery": "資格情報パスの検出（keyscan）",
    "KeyscanHostStore": "ローカル資格情報ストア（keyscan）",
    "KeyscanCollector": "専用収集処理（keyscan）",
    "BrowserCollector": "ブラウザーデータ収集（browserscan）",
    "WalletDiscovery": "ウォレットファイルの検出（wallet_files）",
    "NikkeCollector": "NIKKE アカウントの収集（creds）"
  },
  "Headers": {
    "Path": "ファイルパス",
    "SizeBytes": "サイズ（バイト）",
    "CreatedUtc": "作成日時（UTC）",
    "ModifiedUtc": "更新日時（UTC）",
    "MatchedBranches": "該当する処理",
    "RuleEvidence": "ルールの根拠",
    "FileDescription": "ファイルの説明"
  },
  "Summary": {
    "Csv": "CSV の保存先",
    "Files": "該当ファイル数",
    "EntriesChecked": "パスの確認回数",
    "ProtectedOrOfflineSkipped": "リンクまたはオフラインのため除外",
    "UnsupportedPaths": "非対応パスの確認回数",
    "UnsetPathVariables": "パス変数が未設定のため除外",
    "MetadataErrors": "メタデータ確認エラー数",
    "ElapsedSeconds": "所要時間（秒）",
    "BundleBuild": "Bundle のビルド識別子",
    "BundleSha256": "Bundle の SHA-256"
  },
  "Category": {
    "Project": "プロジェクトのファイル名ルール",
    "Ssh": "SSH 設定",
    "Git": "Git の資格情報ストア",
    "History": "ターミナル履歴",
    "Kube": "Kubernetes 設定",
    "KubeEnvironment": "KUBECONFIG のパス",
    "Gpg": "GnuPG の鍵ストア",
    "BrowserKeys": "{0} の鍵ストア",
    "BrowserDb": "{0} のデータベース候補",
    "BrowserSidecar": "{0} のデータベース補助ファイル",
    "FirefoxKeys": "Firefox の鍵データベース候補",
    "FirefoxLogins": "Firefox のログインストア候補",
    "Nikke": "保存済みアカウントデータ"
  },
  "Tool": {
    "Private keys": "秘密鍵",
    ".NET user-secrets": ".NET ユーザーシークレット",
    "AWS CLI cache": "AWS CLI キャッシュ",
    "VS Code extensions": "VS Code 拡張機能",
    "PowerShell profile": "PowerShell プロファイル",
    "Go env": "Go 環境設定"
  },
  "Format": {
    "text": "テキスト",
    "lines": "行形式のテキスト",
    "json": "JSON",
    "sqlite": "SQLite",
    "dpapi": "DPAPI",
    "yaml": "YAML",
    "toml": "TOML",
    "ini": "INI",
    "xml": "XML",
    "filezilla": "FileZilla",
    "netrc": "netrc",
    "pgpass": "pgpass",
    "ps": "PowerShell"
  },
  "Warning": "警告",
  "Prototype": "関数 #",
  "Source": " の取得元 ",
  "WalletCondition": "、一致する ids 引数が必要",
  "NonFileSystem": "現在の PowerShell の場所はローカルのファイルシステムディレクトリを指定してください。"
}
'@ | ConvertFrom-Json
if ($env:OS -ne 'Windows_NT') { throw $InventoryText.RequiresWindows }

$catalog = @'
[
  {"number":1,"tool":"SSH","format":"text","hostStore":false,"paths":["~\\\\.ssh\\\\*"]},
  {"number":2,"tool":"Private keys","format":"text","hostStore":false,"paths":["~\\.keys\\*","~\\.certs\\*","~\\.config\\age\\*","%APPDATA%\\age\\*","~\\.oci\\*","~\\\\.cloudflared\\\\*"]},
  {"number":3,"tool":".NET user-secrets","format":"json","hostStore":false,"paths":["%APPDATA%\\Microsoft\\UserSecrets\\*\\secrets.json"]},
  {"number":4,"tool":"AWS","format":"lines","hostStore":false,"paths":["~\\.aws\\config","$AWS_CONFIG_FILE"]},
  {"number":5,"tool":"AWS","format":"lines","hostStore":false,"paths":["~\\.aws\\credentials","$AWS_SHARED_CREDENTIALS_FILE"]},
  {"number":6,"tool":"AWS CLI cache","format":"json","hostStore":false,"paths":["~\\.aws\\cli\\cache\\*.json"]},
  {"number":7,"tool":"Kiro","format":"json","hostStore":false,"paths":["~\\.aws\\sso\\cache\\kiro-auth-token.json"]},
  {"number":8,"tool":"AWS SSO","format":"json","hostStore":false,"paths":["~\\.aws\\sso\\cache\\*.json"]},
  {"number":9,"tool":"Aider","format":"yaml","hostStore":false,"paths":["~\\.aider.conf.yml"]},
  {"number":10,"tool":"Alibaba Cloud","format":"json","hostStore":false,"paths":["~\\.aliyun\\config.json"]},
  {"number":11,"tool":"Anyscale","format":"json","hostStore":false,"paths":["~\\.anyscale\\credentials.json"]},
  {"number":12,"tool":"Argo CD","format":"lines","hostStore":false,"paths":["~\\.config\\argocd\\config","~\\.argocd\\config","$ARGOCD_CONFIG_DIR\\config"]},
  {"number":13,"tool":"Azure CLI","format":"json","hostStore":false,"paths":["~\\.Azure\\accessTokens.json","$AZURE_CONFIG_DIR\\accessTokens.json"]},
  {"number":14,"tool":"Azure CLI","format":"dpapi","hostStore":true,"paths":["~\\.Azure\\msal_token_cache.bin","$AZURE_CONFIG_DIR\\msal_token_cache.bin"]},
  {"number":15,"tool":"Azure CLI","format":"dpapi","hostStore":true,"paths":["~\\.Azure\\service_principal_entries.bin","$AZURE_CONFIG_DIR\\service_principal_entries.bin"]},
  {"number":16,"tool":"Backblaze B2","format":"sqlite","hostStore":true,"paths":["~\\.b2_account_info","$B2_ACCOUNT_INFO"]},
  {"number":17,"tool":"Baidu Cloud","format":"json","hostStore":false,"paths":["~\\.bce\\config.json"]},
  {"number":18,"tool":"Buildkite Agent","format":"lines","hostStore":false,"paths":["C:\\buildkite-agent\\buildkite-agent.cfg","$BUILDKITE_AGENT_CONFIG"]},
  {"number":19,"tool":"Buildkite CLI","format":"yaml","hostStore":false,"paths":["%APPDATA%\\Buildkite CLI\\bk.yaml"]},
  {"number":20,"tool":"Cargo","format":"toml","hostStore":false,"paths":["~\\.cargo\\credentials.toml","~\\.cargo\\credentials","$CARGO_HOME\\credentials.toml"]},
  {"number":21,"tool":"CircleCI","format":"yaml","hostStore":false,"paths":["~\\.config\\circleci\\config.yml","~\\.circleci\\cli.yml"]},
  {"number":22,"tool":"Claude Code","format":"json","hostStore":false,"paths":["%APPDATA%\\Anthropic\\credentials\\*.json"]},
  {"number":23,"tool":"Claude Code","format":"json","hostStore":false,"paths":["~\\.claude.json","$CLAUDE_CONFIG_DIR\\.claude.json"]},
  {"number":24,"tool":"Claude Code","format":"json","hostStore":false,"paths":["~\\.claude\\.credentials.json","$CLAUDE_CONFIG_DIR\\.credentials.json"]},
  {"number":25,"tool":"Claude Code","format":"json","hostStore":false,"paths":["~\\.claude\\settings.json","$CLAUDE_CONFIG_DIR\\settings.json"]},
  {"number":26,"tool":"Claude Desktop","format":"json","hostStore":false,"paths":["%APPDATA%\\Claude\\claude_desktop_config.json"]},
  {"number":27,"tool":"Cloudflare Wrangler","format":"toml","hostStore":false,"paths":["%APPDATA%\\.wrangler\\config\\default.toml","%USERPROFILE%\\.config\\.wrangler\\config\\default.toml"]},
  {"number":28,"tool":"Cloudsmith","format":"ini","hostStore":false,"paths":["%APPDATA%\\cloudsmith\\credentials.ini","~\\.cloudsmith\\credentials.ini"]},
  {"number":29,"tool":"Composer","format":"json","hostStore":false,"paths":["%APPDATA%\\Composer\\auth.json","$COMPOSER_HOME\\auth.json"]},
  {"number":30,"tool":"Conda","format":"text","hostStore":false,"paths":["%LOCALAPPDATA%\\ContinuumIO\\binstar\\*.token","~\\.continuum\\anaconda-client\\tokens\\*.token"]},
  {"number":31,"tool":"Continue.dev","format":"yaml","hostStore":false,"paths":["~\\.continue\\config.yaml","~\\.continue\\assistants\\*.yaml"]},
  {"number":32,"tool":"Continue.dev","format":"json","hostStore":false,"paths":["~\\.continue\\config.json"]},
  {"number":33,"tool":"Cursor","format":"sqlite","hostStore":true,"paths":["%APPDATA%\\Cursor\\User\\globalStorage\\state.vscdb"]},
  {"number":34,"tool":"Cursor","format":"json","hostStore":false,"paths":["%APPDATA%\\Cursor\\User\\settings.json"]},
  {"number":35,"tool":"Cursor","format":"json","hostStore":false,"paths":["~\\.cursor\\mcp.json"]},
  {"number":36,"tool":"Dart/pub","format":"json","hostStore":false,"paths":["%APPDATA%\\dart\\pub-tokens.json","%APPDATA%\\dart\\pub-credentials.json"]},
  {"number":37,"tool":"Databricks","format":"lines","hostStore":false,"paths":["~\\.databrickscfg","$DATABRICKS_CONFIG_FILE"]},
  {"number":38,"tool":"Datadog","format":"lines","hostStore":false,"paths":["~\\.dogrc"]},
  {"number":39,"tool":"DeepSeek Harness","format":"yaml","hostStore":false,"paths":["~\\.dsh\\.credentials.yaml","$DSH_HOME\\.credentials.yaml"]},
  {"number":40,"tool":"DigitalOcean","format":"yaml","hostStore":false,"paths":["%APPDATA%\\doctl\\config.yaml"]},
  {"number":41,"tool":"Docker","format":"json","hostStore":false,"paths":["~\\.docker\\config.json","$DOCKER_CONFIG\\config.json"]},
  {"number":42,"tool":"Expo/EAS","format":"json","hostStore":false,"paths":["~\\.expo\\state.json"]},
  {"number":43,"tool":"FileZilla","format":"filezilla","hostStore":false,"paths":["%APPDATA%\\FileZilla\\sitemanager.xml","%APPDATA%\\FileZilla\\recentservers.xml"]},
  {"number":44,"tool":"Firebase","format":"json","hostStore":false,"paths":["~\\.config\\configstore\\firebase-tools.json","$XDG_CONFIG_HOME\\configstore\\firebase-tools.json"]},
  {"number":45,"tool":"Fly.io","format":"yaml","hostStore":false,"paths":["~\\.fly\\config.yml"]},
  {"number":46,"tool":"Gemini CLI","format":"json","hostStore":false,"paths":["~\\.gemini\\oauth_creds.json","~\\.gemini\\google_accounts.json","$GEMINI_CLI_HOME\\.gemini\\oauth_creds.json"]},
  {"number":47,"tool":"Gemini CLI","format":"json","hostStore":false,"paths":["~\\.gemini\\settings.json","$GEMINI_CLI_HOME\\.gemini\\settings.json","%PROGRAMDATA%\\gemini-cli\\settings.json"]},
  {"number":48,"tool":"Git","format":"lines","hostStore":false,"paths":["~\\.gitconfig","%PROGRAMDATA%\\Git\\config","%PROGRAMFILES%\\Git\\etc\\gitconfig","~\\.config\\git\\config"]},
  {"number":49,"tool":"GitHub CLI","format":"yaml","hostStore":false,"paths":["%APPDATA%\\GitHub CLI\\hosts.yml","~\\.config\\gh\\hosts.yml","$GH_CONFIG_DIR\\hosts.yml"]},
  {"number":50,"tool":"GitHub Copilot CLI","format":"json","hostStore":false,"paths":["~\\.copilot\\mcp-config.json","$COPILOT_HOME\\mcp-config.json"]},
  {"number":51,"tool":"GitLab CLI","format":"yaml","hostStore":false,"paths":["%LOCALAPPDATA%\\glab-cli\\config.yml","~\\.config\\glab-cli\\config.yml"]},
  {"number":52,"tool":"GitLab Runner","format":"toml","hostStore":false,"paths":["C:\\GitLab-Runner\\config.toml","C:\\config.toml"]},
  {"number":53,"tool":"Gitea/Forgejo","format":"yaml","hostStore":false,"paths":["~\\.config\\tea\\config.yml"]},
  {"number":54,"tool":"Go env","format":"lines","hostStore":false,"paths":["%APPDATA%\\go\\env"]},
  {"number":55,"tool":"Google Cloud","format":"sqlite","hostStore":true,"paths":["%APPDATA%\\gcloud\\access_tokens.db","$CLOUDSDK_CONFIG\\access_tokens.db"]},
  {"number":56,"tool":"Google Cloud","format":"json","hostStore":false,"paths":["%APPDATA%\\gcloud\\application_default_credentials.json","$CLOUDSDK_CONFIG\\application_default_credentials.json","$GOOGLE_APPLICATION_CREDENTIALS"]},
  {"number":57,"tool":"Google Cloud","format":"sqlite","hostStore":true,"paths":["%APPDATA%\\gcloud\\credentials.db","$CLOUDSDK_CONFIG\\credentials.db"]},
  {"number":58,"tool":"Gradle","format":"lines","hostStore":false,"paths":["~\\.gradle\\gradle.properties","$GRADLE_USER_HOME\\gradle.properties"]},
  {"number":59,"tool":"HashiCorp Vault","format":"text","hostStore":false,"paths":["~\\.vault-token"]},
  {"number":60,"tool":"Helm","format":"yaml","hostStore":false,"paths":["%APPDATA%\\helm\\repositories.yaml","$HELM_REPOSITORY_CONFIG","$HELM_CONFIG_HOME\\repositories.yaml"]},
  {"number":61,"tool":"Hetzner","format":"toml","hostStore":false,"paths":["%APPDATA%\\hcloud\\cli.toml"]},
  {"number":62,"tool":"Huawei Cloud","format":"json","hostStore":false,"paths":["~\\.hcloud\\config.json"]},
  {"number":63,"tool":"Hugging Face","format":"ini","hostStore":false,"paths":["~\\.cache\\huggingface\\stored_tokens","$HF_HOME\\stored_tokens"]},
  {"number":64,"tool":"Hugging Face","format":"text","hostStore":false,"paths":["~\\.cache\\huggingface\\token","$HF_HOME\\token","$HF_TOKEN_PATH"]},
  {"number":65,"tool":"JFrog","format":"json","hostStore":false,"paths":["~\\.jfrog\\jfrog-cli.conf.v6","~\\.jfrog\\jfrog-cli.conf","$JFROG_CLI_HOME_DIR\\jfrog-cli.conf.v6"]},
  {"number":66,"tool":"Jenkins","format":"text","hostStore":false,"paths":["~\\.jenkins\\secrets\\initialAdminPassword","C:\\Program Files\\Jenkins\\secrets\\initialAdminPassword"]},
  {"number":67,"tool":"Kaggle","format":"text","hostStore":false,"paths":["~\\.kaggle\\access_token","$KAGGLE_CONFIG_DIR\\access_token"]},
  {"number":68,"tool":"Kaggle","format":"json","hostStore":false,"paths":["~\\.kaggle\\kaggle.json","$KAGGLE_CONFIG_DIR\\kaggle.json"]},
  {"number":69,"tool":"Kimi CLI","format":"toml","hostStore":false,"paths":["~\\.kimi\\config.toml","$KIMI_SHARE_DIR\\config.toml"]},
  {"number":70,"tool":"Kimi CLI","format":"json","hostStore":false,"paths":["~\\.kimi\\mcp.json","~\\.kimi\\credentials\\*.json"]},
  {"number":71,"tool":"Linode","format":"lines","hostStore":false,"paths":["~\\.config\\linode-cli"]},
  {"number":72,"tool":"Maven","format":"xml","hostStore":false,"paths":["~\\.m2\\settings.xml"]},
  {"number":73,"tool":"MinIO","format":"json","hostStore":false,"paths":["~\\mc\\config.json"]},
  {"number":74,"tool":"Modal","format":"toml","hostStore":false,"paths":["~\\.modal.toml","$MODAL_CONFIG_PATH"]},
  {"number":75,"tool":"MongoDB Atlas","format":"toml","hostStore":false,"paths":["%APPDATA%\\atlascli\\config.toml"]},
  {"number":76,"tool":"Naver Cloud","format":"lines","hostStore":false,"paths":["~\\.ncloud\\configure"]},
  {"number":77,"tool":"Neon","format":"json","hostStore":false,"paths":["%USERPROFILE%\\.config\\neonctl\\credentials.json"]},
  {"number":78,"tool":"Netlify","format":"json","hostStore":false,"paths":["%APPDATA%\\netlify\\Config\\config.json"]},
  {"number":79,"tool":"netrc","format":"netrc","hostStore":false,"paths":["~\\.netrc","~\\_netrc"]},
  {"number":80,"tool":"NuGet","format":"xml","hostStore":false,"paths":["%APPDATA%\\NuGet\\NuGet.Config","%ProgramFiles(x86)%\\NuGet\\Config\\NuGet.Config"]},
  {"number":81,"tool":"Octopus Deploy","format":"json","hostStore":false,"paths":["%APPDATA%\\octopus\\cli_config.json"]},
  {"number":82,"tool":"OpenAI Codex CLI","format":"json","hostStore":false,"paths":["~\\.codex\\auth.json","$CODEX_HOME\\auth.json"]},
  {"number":83,"tool":"OpenAI Codex CLI","format":"toml","hostStore":false,"paths":["~\\.codex\\config.toml","$CODEX_HOME\\config.toml"]},
  {"number":84,"tool":"OpenCode","format":"json","hostStore":false,"paths":["%USERPROFILE%\\.local\\share\\opencode\\auth.json"]},
  {"number":85,"tool":"Oracle Cloud","format":"lines","hostStore":false,"paths":["~\\.oci\\config","$OCI_CONFIG_FILE","~\\.oraclebmc\\config"]},
  {"number":86,"tool":"PlanetScale","format":"text","hostStore":false,"paths":["~\\.config\\planetscale\\access-token"]},
  {"number":87,"tool":"Podman","format":"json","hostStore":false,"paths":["%USERPROFILE%\\.config\\containers\\auth.json"]},
  {"number":88,"tool":"Poetry","format":"toml","hostStore":false,"paths":["%APPDATA%\\pypoetry\\auth.toml"]},
  {"number":89,"tool":"PostgreSQL","format":"ini","hostStore":false,"paths":["~\\.pg_service.conf","%APPDATA%\\postgresql\\.pg_service.conf","$PGSERVICEFILE"]},
  {"number":90,"tool":"PostgreSQL","format":"pgpass","hostStore":false,"paths":["%APPDATA%\\postgresql\\pgpass.conf","$PGPASSFILE"]},
  {"number":91,"tool":"PowerShell profile","format":"ps","hostStore":false,"paths":["~\\Documents\\PowerShell\\profile.ps1","~\\Documents\\PowerShell\\Microsoft.PowerShell_profile.ps1","~\\Documents\\WindowsPowerShell\\profile.ps1","~\\Documents\\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1"]},
  {"number":92,"tool":"Pulumi","format":"json","hostStore":false,"paths":["~\\.pulumi\\credentials.json","$PULUMI_HOME\\credentials.json"]},
  {"number":93,"tool":"PyPI/pip","format":"ini","hostStore":false,"paths":["~\\.pypirc","%APPDATA%\\pip\\pip.ini","~\\pip\\pip.ini","%PROGRAMDATA%\\pip\\pip.ini","$PIP_CONFIG_FILE"]},
  {"number":94,"tool":"Qwen Code","format":"json","hostStore":false,"paths":["~\\.qwen\\settings.json"]},
  {"number":95,"tool":"Qwen Code","format":"lines","hostStore":false,"paths":["~\\.qwen\\.env"]},
  {"number":96,"tool":"R","format":"lines","hostStore":false,"paths":["~\\Documents\\.Renviron","~\\Documents\\.Rprofile"]},
  {"number":97,"tool":"Railway","format":"json","hostStore":false,"paths":["~\\.railway\\config.json"]},
  {"number":98,"tool":"RubyGems","format":"yaml","hostStore":false,"paths":["~\\.gem\\credentials"]},
  {"number":99,"tool":"RunPod","format":"toml","hostStore":false,"paths":["~\\.runpod\\config.toml"]},
  {"number":100,"tool":"Sakura Cloud","format":"json","hostStore":false,"paths":["~\\.usacloud\\*\\config.json","$SAKURA_PROFILE_DIR\\*\\config.json"]},
  {"number":101,"tool":"Semgrep","format":"yaml","hostStore":false,"paths":["~\\.semgrep\\settings.yml","%XDG_CONFIG_HOME%\\.semgrep\\settings.yml"]},
  {"number":102,"tool":"Sentry","format":"ini","hostStore":false,"paths":["~\\.sentryclirc"]},
  {"number":103,"tool":"Snowflake","format":"toml","hostStore":false,"paths":["~\\.snowflake\\config.toml","~\\.snowflake\\connections.toml","%LOCALAPPDATA%\\snowflake\\config.toml","%LOCALAPPDATA%\\snowflake\\connections.toml","$SNOWFLAKE_HOME\\config.toml"]},
  {"number":104,"tool":"Snowflake","format":"ini","hostStore":false,"paths":["~\\.snowsql\\config"]},
  {"number":105,"tool":"Snyk","format":"json","hostStore":false,"paths":["%USERPROFILE%\\.config\\configstore\\snyk.json"]},
  {"number":106,"tool":"Stripe","format":"toml","hostStore":false,"paths":["%USERPROFILE%\\.config\\stripe\\config.toml","%XDG_CONFIG_HOME%\\stripe\\config.toml"]},
  {"number":107,"tool":"Stripe","format":"json","hostStore":false,"paths":["%USERPROFILE%\\.config\\stripe\\credentials.json"]},
  {"number":108,"tool":"Supabase","format":"text","hostStore":false,"paths":["~\\.supabase\\access-token"]},
  {"number":109,"tool":"TeamCity","format":"yaml","hostStore":false,"paths":["~\\.config\\tc\\config.yml"]},
  {"number":110,"tool":"Tencent Cloud","format":"json","hostStore":false,"paths":["~\\.tccli\\*.credential"]},
  {"number":111,"tool":"Terraform","format":"json","hostStore":false,"paths":["%APPDATA%\\terraform.d\\credentials.tfrc.json","~\\.terraform.d\\credentials.tfrc.json"]},
  {"number":112,"tool":"Terraform","format":"lines","hostStore":false,"paths":["%APPDATA%\\terraform.rc","~\\.terraformrc","$TF_CLI_CONFIG_FILE"]},
  {"number":113,"tool":"Twilio","format":"json","hostStore":false,"paths":["~\\.twilio-cli\\config.json","$TWILIO_CONFIG_DIR\\config.json"]},
  {"number":114,"tool":"VS Code","format":"sqlite","hostStore":true,"paths":["%APPDATA%\\Code\\User\\globalStorage\\state.vscdb","%APPDATA%\\Code - Insiders\\User\\globalStorage\\state.vscdb","%APPDATA%\\Code\\User\\workspaceStorage\\*\\state.vscdb"]},
  {"number":115,"tool":"VS Code","format":"json","hostStore":false,"paths":["%APPDATA%\\Code\\User\\mcp.json","%APPDATA%\\Code\\User\\profiles\\*\\mcp.json"]},
  {"number":116,"tool":"VS Code","format":"json","hostStore":false,"paths":["%APPDATA%\\Code\\User\\settings.json","%APPDATA%\\Code - Insiders\\User\\settings.json","%APPDATA%\\Code\\User\\profiles\\*\\settings.json"]},
  {"number":117,"tool":"VS Code extensions","format":"json","hostStore":false,"paths":["%APPDATA%\\Code\\User\\globalStorage\\**\\*.json","%APPDATA%\\Cursor\\User\\globalStorage\\**\\*.json","%APPDATA%\\Windsurf\\User\\globalStorage\\**\\*.json"]},
  {"number":118,"tool":"Vercel","format":"json","hostStore":false,"paths":["%APPDATA%\\xdg.data\\com.vercel.cli\\auth.json"]},
  {"number":119,"tool":"Volcengine","format":"json","hostStore":false,"paths":["~\\.volcengine\\config.json"]},
  {"number":120,"tool":"Windsurf","format":"sqlite","hostStore":true,"paths":["%APPDATA%\\Windsurf\\User\\globalStorage\\state.vscdb"]},
  {"number":121,"tool":"Windsurf","format":"json","hostStore":false,"paths":["%APPDATA%\\Windsurf\\User\\globalStorage\\storage.json"]},
  {"number":122,"tool":"Windsurf","format":"json","hostStore":false,"paths":["%APPDATA%\\Windsurf\\User\\settings.json"]},
  {"number":123,"tool":"Windsurf","format":"json","hostStore":false,"paths":["~\\.codeium\\windsurf\\mcp_config.json"]},
  {"number":124,"tool":"Yarn","format":"yaml","hostStore":false,"paths":["~\\.yarnrc.yml"]},
  {"number":125,"tool":"Yarn","format":"lines","hostStore":false,"paths":["~\\.yarnrc"]},
  {"number":126,"tool":"dbt","format":"yaml","hostStore":false,"paths":["~\\.dbt\\profiles.yml"]},
  {"number":127,"tool":"ngrok","format":"yaml","hostStore":false,"paths":["%LOCALAPPDATA%\\ngrok\\ngrok.yml"]},
  {"number":128,"tool":"npm","format":"lines","hostStore":false,"paths":["~\\.npmrc","%APPDATA%\\npm\\etc\\npmrc","$NPM_CONFIG_USERCONFIG"]},
  {"number":129,"tool":"rclone","format":"lines","hostStore":false,"paths":["%APPDATA%\\rclone\\rclone.conf","~\\.rclone.conf","$RCLONE_CONFIG"]},
  {"number":130,"tool":"s3cmd","format":"ini","hostStore":false,"paths":["%APPDATA%\\s3cmd.ini","~\\.s3cfg"]},
  {"number":131,"tool":"sbt","format":"lines","hostStore":false,"paths":["~\\.sbt\\.credentials","~\\.sbt\\sonatype_central_credentials"]}
]
'@ | ConvertFrom-Json
$walletCatalog = @'
[
  {"id":"acmacodkjbdgmoleebolmdjonilkdbch","name":"rabby"},
  {"id":"aflkmfhebedbjioipglgcbcmnbpgliof","name":"backpack"},
  {"id":"bfnaelmomeimhlpmgjnjophhpkkoljpa","name":"phantom"},
  {"id":"bhhhlbepdkbapadjdnnojkbgioiodbic","name":"solflare"},
  {"id":"cadiboklkpojfamcoggejbbdjcoiljjk","name":"binance"},
  {"id":"dmkamcknogkgcdfhhbddcghachkejeap","name":"keplr"},
  {"id":"egjidjbpglichdcondbcbdnbeeppgdph","name":"trust"},
  {"id":"fnjhmkhhmkbjkkabndcnnogagogbneec","name":"ronin"},
  {"id":"hnfanknocfeofbddgcijnmhnfnkdnaad","name":"coinbase"},
  {"id":"ibnejdfjmmkpcnlpebklmnkoeoihofec","name":"tronlink"},
  {"id":"jiidiaalihmmhddjgbnbgdfflelocpak","name":"bitget"},
  {"id":"mcohilncbfahbmgdjkbpemcciiolgcge","name":"okx"},
  {"id":"nkbihfbeogaeaoehlefnkodbefgpgknn","name":"metamask"},
  {"id":"omaabbefbmiijedngplfjmnooppbclkk","name":"tonkeeper"},
  {"id":"opcgpfmipidbgpenhmajoajpbobppdil","name":"slush"},
  {"id":"pdliaogehgdbhbnmkklieghmmjkpigpa","name":"bybit"},
  {"id":"jblndlipeogpafnldhgmapagcccfchpi","name":"kaia"},
  {"id":"aiifbnbfobpmeekipheeijimdpnlpgpp","name":"station"},
  {"id":"ppbibelpcjmhbdihakflkdcoccbgbkpo","name":"unisat"},
  {"id":"idnnbdplmphpflfnlkomgpfbpcgelopg","name":"xverse"},
  {"id":"mkpegjkblkkefacfnmkajcjmabijhclg","name":"magiceden"},
  {"id":"ejjladinnckdgjemekebdpeokbikhfci","name":"petra"},
  {"id":"dlcobpjiigpikoobohmabehhmhfoodbb","name":"ready"},
  {"id":"gjagmgiddbbciopjhllkdnddhcglnemk","name":"hashpack"},
  {"id":"onhogfjeacnfoofkfgppdlbmlmnplgbn","name":"subwallet"},
  {"id":"opfgelmcmbiajamepnmloijbpoleiama","name":"rainbow"},
  {"id":"jnlgamecbpmbajjfhmmmlhejkemejdma","name":"braavos"},
  {"id":"phkbamefinggmakgklpkljjmgibohnba","name":"pontem"}
]
'@ | ConvertFrom-Json

$scan = @{
    Entries = 0; ProtectedSkipped = 0
    UnsupportedPaths = 0; UnsetVariables = 0; Errors = 0
}
$timer = [Diagnostics.Stopwatch]::StartNew()
$rows = [Collections.Generic.Dictionary[string,object]]::new([StringComparer]::OrdinalIgnoreCase)
$driveTypes = @{}
# ReparsePoint, Offline, RecallOnOpen, RecallOnDataAccess.
$avoidAttributes = 0x00441400

function Expand-TargetPath([string] $Pattern) {
    if ($Pattern.StartsWith('~\')) { $Pattern = '%USERPROFILE%' + $Pattern.Substring(1) }
    $Pattern = [regex]::Replace($Pattern, '\$([a-zA-Z_][a-zA-Z0-9_]*)', '%$1%')
    foreach ($variable in [regex]::Matches($Pattern, '%([A-Za-z_][A-Za-z0-9_()]*)%')) {
        if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($variable.Groups[1].Value))) {
            $scan.UnsetVariables++
            return
        }
    }
    [Environment]::ExpandEnvironmentVariables($Pattern)
}

function Get-LocalPath([string] $Path, [switch] $Pattern) {
    if ($Path -notmatch '^[a-zA-Z]:[\\/]' -or $Path.Substring(2) -match '[:<>"|\x00-\x1f]' -or
        (-not $Pattern -and $Path -match '[*?]')) {
        $scan.UnsupportedPaths++
        return
    }
    $root = $Path.Substring(0, 2).ToUpperInvariant() + '\'
    $parts = @($Path.Substring(3).Replace('/', '\').Split('\') | Where-Object { $_ })
    foreach ($part in $parts) {
        if ($part -match '[ .]$' -or $part -match '^(CON|PRN|AUX|NUL|COM[1-9\u00b9\u00b2\u00b3]|LPT[1-9\u00b9\u00b2\u00b3])(?:\.|$)') {
            $scan.UnsupportedPaths++
            return
        }
    }
    if (-not $driveTypes.ContainsKey($root)) {
        try { $driveTypes[$root] = [IO.DriveInfo]::new($root).DriveType }
        catch { $driveTypes[$root] = [IO.DriveType]::Unknown }
    }
    if ($driveTypes[$root] -notin @('Fixed', 'Removable', 'Ram')) {
        $scan.UnsupportedPaths++
        return
    }
    [pscustomobject]@{ Root = $root; Parts = $parts; FullName = $root + ($parts -join '\') }
}

function Get-ItemMetadata([string] $Path) {
    $scan.Entries++
    try {
        $attributes = [IO.File]::GetAttributes($Path)
        if ([int]$attributes -band $avoidAttributes) { $scan.ProtectedSkipped++; return }
        if ($attributes -band [IO.FileAttributes]::Directory) {
            [IO.DirectoryInfo]::new($Path)
        } else {
            [IO.FileInfo]::new($Path)
        }
    } catch {
        $cause = $_.Exception.GetBaseException()
        if ($cause -isnot [IO.FileNotFoundException] -and $cause -isnot [IO.DirectoryNotFoundException]) {
            $scan.Errors++
        }
    }
}

function Get-ChildrenMetadata([IO.DirectoryInfo] $Directory) {
    try {
        foreach ($child in $Directory.EnumerateFileSystemInfos()) {
            $scan.Entries++
            if ([int]$child.Attributes -band $avoidAttributes) { $scan.ProtectedSkipped++; continue }
            $child
        }
    } catch {
        $scan.Errors++
    }
}

function Find-PathSegments($Item, [string[]] $Parts, [int] $Index, [int] $RecursiveDepth = 0) {
    if ($Index -eq $Parts.Length) { $Item; return }
    if ($Item -isnot [IO.DirectoryInfo]) { return }
    $component = $Parts[$Index]
    if ($component -eq '**') {
        # #185 consumes at least one child directory and stops recursing above depth 6.
        if ($RecursiveDepth -gt 6) { return }
        foreach ($child in (Get-ChildrenMetadata $Item)) {
            if ($child -isnot [IO.DirectoryInfo]) { continue }
            Find-PathSegments $child $Parts ($Index + 1) ($RecursiveDepth + 1)
            Find-PathSegments $child $Parts $Index ($RecursiveDepth + 1)
        }
    } elseif ($component -match '[*?]') {
        $regex = '\A' + [regex]::Escape($component).Replace('\*', '.*').Replace('\?', '.') + '\z'
        foreach ($child in (Get-ChildrenMetadata $Item)) {
            if ($child.Name -cmatch $regex) { Find-PathSegments $child $Parts ($Index + 1) $RecursiveDepth }
        }
    } else {
        $child = Get-ItemMetadata ([IO.Path]::Combine($Item.FullName, $component))
        if ($null -ne $child) { Find-PathSegments $child $Parts ($Index + 1) $RecursiveDepth }
    }
}

function Find-LocalPath([string] $Path, [switch] $Pattern, [switch] $LiteralInput) {
    if (-not $LiteralInput) { $Path = Expand-TargetPath $Path }
    if ([string]::IsNullOrEmpty($Path)) { return }
    $parsed = Get-LocalPath $Path -Pattern:$Pattern
    if ($null -eq $parsed) { return }
    $root = Get-ItemMetadata $parsed.Root
    if ($null -ne $root) { Find-PathSegments $root $parsed.Parts 0 }
}

function Get-CatalogDescriptionKey([IO.FileInfo] $File, $Rule) {
    switch ([int]$Rule.number) {
        1 { if ($File.Name -ieq 'config') { return 'SshConfig' }; return 'SshFile' }
        2 { return 'KeySource' }
        3 { return 'DotNetSecrets' }
        33 { return 'EditorDatabase' }
        41 { return 'ContainerConfig' }
        43 { return 'FtpSites' }
        48 { return 'GitConfig' }
        54 { return 'GoEnv' }
        82 { return 'CodexAuth' }
        83 { return 'CodexConfig' }
        87 { return 'ContainerConfig' }
        90 { return 'CatalogAuth' }
        91 { return 'PowerShellProfile' }
        114 { return 'EditorDatabase' }
        117 { return 'ExtensionSettings' }
        120 { return 'EditorDatabase' }
    }
    if ($Rule.hostStore) {
        if ($Rule.format -eq 'dpapi') { return 'ProtectedStore' }
        return 'CatalogDatabase'
    }
    if ($File.Name -match '^(?:\.?mcp(?:[-_]config)?|mcp_config)\.json$') { return 'McpConfig' }
    if ($File.Name -match 'cache|accessTokens') { return 'CatalogCache' }
    if ($File.Name -match 'auth|token|credentials|secrets|netrc|pgpass') { return 'CatalogAuth' }
    return 'CatalogConfig'
}

function Add-File($File, [string] $Branch, [string] $Category, [string] $Evidence,
    [string] $DescriptionKey, [string] $Product = '') {
    if ($File -isnot [IO.FileInfo]) { return }
    $path = $File.FullName
    if (-not $rows.ContainsKey($path)) {
        try {
            $rows[$path] = @{
                Path = $path
                SizeBytes = $File.Length
                CreatedUtc = $File.CreationTimeUtc.ToString('o')
                ModifiedUtc = $File.LastWriteTimeUtc.ToString('o')
                Branches = [Collections.Generic.HashSet[string]]::new()
                Matches = [Collections.Generic.HashSet[string]]::new()
                Descriptions = [Collections.Generic.HashSet[string]]::new()
            }
        } catch { $scan.Errors++; return }
    }
    [void]$rows[$path].Branches.Add($Branch)
    $reference = $Evidence.Replace('proto', $InventoryText.Prototype).Replace(' source ', $InventoryText.Source)
    $reference = $reference.Replace(', requires matching ids argument', $InventoryText.WalletCondition)
    [void]$rows[$path].Matches.Add("$Category [$reference]")
    $description = $InventoryText.File.PSObject.Properties[$DescriptionKey].Value -f $Product
    [void]$rows[$path].Descriptions.Add($description)
}

function Add-Pattern([string] $Pattern, [string] $Branch, [string] $Category, [string] $Evidence, [string] $DescriptionKey) {
    Find-LocalPath $Pattern -Pattern | ForEach-Object { Add-File $_ $Branch $Category $Evidence $DescriptionKey }
}

function Add-SourceMetadata([string] $Source, [string] $Location, [string] $Item,
    [string] $Reference, [string] $Description) {
    $headers = $InventoryText.Headers
    $metadata = $InventoryText.Metadata
    $sourceRows.Add([pscustomobject][ordered]@{
        ($headers.Path) = $null
        ($headers.SizeBytes) = $null
        ($headers.CreatedUtc) = $null
        ($headers.ModifiedUtc) = $null
        ($headers.MatchedBranches) = $InventoryText.Branch.KeyscanCollector
        ($headers.RuleEvidence) = $Reference
        ($headers.FileDescription) = $metadata.Description.PSObject.Properties[$Description].Value
        ($metadata.Headers.Type) = $metadata.Source.PSObject.Properties[$Source].Value
        ($metadata.Headers.Location) = $Location
        ($metadata.Headers.Item) = $Item
    })
}

function Get-ReportFingerprint([string] $Text) {
    $hash = [Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $hash.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text))
        ([BitConverter]::ToString($bytes).Replace('-', '')).Substring(0, 16)
    } finally { $hash.Dispose() }
}

function Get-CredentialReportItem([string] $Kind, [string] $Target) {
    # Keep service/host metadata and a stable fingerprint. Never copy raw target suffixes.
    $id = Get-ReportFingerprint ($Kind + ':target=' + $Target)
    $service = $Kind
    if ($Target -match '^(TERMSRV|cifs|git|gh|glab|cargo|docker|npm|pypi|nuget|azure|aws|vscode)(?=[:/_.-]|$)') {
        $service += ' / ' + $Matches[1].ToLowerInvariant()
    } elseif ($Target -match '^(?:com\.)?adobe(?=[:/_. -]|$)') {
        $service += ' / Adobe'
    }

    $targetHost = ''
    $url = [regex]::Match($Target, 'https?://[^\s<>"\x00-\x1f]+', [Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($url.Success) {
        $uri = $null
        if ([Uri]::TryCreate($url.Value, [UriKind]::Absolute, [ref]$uri)) {
            $targetHost = $uri.DnsSafeHost
        } elseif ($url.Value -match '^https?://((?:[a-z0-9-]+\.)*(?:xboxlive\.com|xbox\.com|xboxservices\.com|microsoft\.com|live\.com))\|') {
            # These credential targets use a known service authority followed by an opaque pipe-delimited suffix.
            $targetHost = $Matches[1]
        }
    } elseif ($Target -match '^(?:TERMSRV/|cifs/)?([a-z0-9][a-z0-9.-]*\.[a-z0-9]+)(?::[0-9]{1,5})?$') {
        $targetHost = $Matches[1]
    } elseif ($Kind -eq 'Domain' -and $Target -match '^(?:TERMSRV/|cifs/)?([a-z0-9][a-z0-9-]{0,14})(?::[0-9]{1,5})?$') {
        $targetHost = $Matches[1]
    }

    if ($targetHost -match '^[a-z0-9][a-z0-9.-]{0,126}$' -and
        $targetHost -notmatch '(?:^|\.)(?:[a-f0-9]{20,}|[a-z0-9-]{33,})(?:\.|$)') {
        if ($targetHost -match '(?:^|\.)(?:xboxlive\.com|xbox\.com|xboxservices\.com)$') {
            $service += ' / Xbox Live'
        }
        $service += ' / ' + $targetHost
    }
    "$service [$id]"
}

function Get-SessionReportItem([string] $Tool, [string] $Location, [string] $Name) {
    $id = Get-ReportFingerprint ($Location + '\' + $Name)
    $label = [Uri]::UnescapeDataString($Name)
    if ($label -match '^[\p{L}\p{Nd}][\p{L}\p{Nd} ._-]{0,47}$' -and
        $label -notmatch 'token|password|passwd|passphrase|secret|api.?key|authorization|credential|bearer|[a-z0-9_-]{24,}') {
        return "$Tool / $label [$id]"
    }
    "$Tool [$id]"
}

function Add-EnvironmentMetadata([string] $Source, [string] $Location, [string[]] $Names) {
    # Name-only projection of #202. Value-based detectors are outside this inventory.
    $pattern = 'api_?key|access_?key|client_?secret|private_?key|(?:^|_)(?:tokens?|secrets?|password|passwd|passphrase|pat|credentials?|auth|authorization)(?:_|$)|(?:^|_)key$'
    $candidates = @($Names | Where-Object {
        $_ -match '^[a-z_][a-z0-9_]*$' -and $_ -notmatch '(?:^|_)public(?:_|$)' -and $_ -match $pattern
    } | Sort-Object -Unique)
    if ($candidates.Count -eq 0) { Add-SourceMetadata $Source $Location '' '#202/216' 'EnvironmentEmpty' }
    foreach ($name in $candidates) {
        Add-SourceMetadata $Source $Location $name '#202/216' 'EnvironmentName'
    }
}

function Add-RegistryEnvironmentMetadata($Hive, [string] $KeyPath, [string] $Location) {
    try {
        $key = $Hive.OpenSubKey($KeyPath, $false)
        $names = @()
        if ($null -ne $key) {
            try { $names = @($key.GetValueNames()) } finally { $key.Dispose() }
        }
        Add-EnvironmentMetadata 'RegistryEnvironment' $Location $names
    } catch {
        $scan.Errors++
        Add-SourceMetadata 'RegistryEnvironment' $Location '' '#202/216' 'Unavailable'
    }
}

function Add-CredentialManagerMetadata {
    # cmdkey lists target metadata without returning the password/credential blob.
    # Parse the target envelope, then retain only safe target metadata.
    try {
        $cmdkey = Join-Path ([Environment]::SystemDirectory) 'cmdkey.exe'
        $lines = @(& $cmdkey /list 2>$null)
        if ($LASTEXITCODE -ne 0) { throw 'cmdkey failed' }
        $count = 0
        $recognized = 0
        foreach ($line in $lines) {
            if ($line -notmatch '^\s*[^:=：]+[:：]\s*([a-z][a-z0-9]*):target=(.+)$') { continue }
            $recognized++
            $kind = $Matches[1]
            $targetName = $Matches[2]
            $target = $kind + ':target=' + $targetName
            if ($target -notmatch 'MicrosoftAccount:|web credentials|WindowsLive:|virtualapp/didlogical|sso_pop_|^LegacyGeneric:target=Microsoft') {
                $count++
                $item = Get-CredentialReportItem $kind $targetName
                Add-SourceMetadata 'CredentialManager' 'cmdkey /list' $item '#164/166' 'CredentialItem'
            }
        }
        if ($recognized -eq 0 -and ($lines -join ' ') -notmatch '(?i)\*+\s*none\s*\*+|currently stored credentials:\s*$') {
            throw 'cmdkey output format was not recognized'
        }
        if ($count -eq 0) { Add-SourceMetadata 'CredentialManager' 'cmdkey /list' '' '#164/166' 'CredentialEmpty' }
    } catch {
        $scan.Errors++
        Add-SourceMetadata 'CredentialManager' 'cmdkey /list' '' '#164/166' 'Unavailable'
    }
}

function Add-SavedSessionMetadata($Hive, [string] $Tool, [string] $KeyPath) {
    $location = 'HKCU\' + $KeyPath
    try {
        $root = $Hive.OpenSubKey($KeyPath, $false)
        $names = @()
        if ($null -ne $root) {
            try {
                $names = @($root.GetSubKeyNames())
                foreach ($name in $names) {
                    $item = Get-SessionReportItem $Tool $location $name
                    Add-SourceMetadata 'SavedSessions' $location $item '#174/176' 'SessionItem'
                    try {
                        $session = $root.OpenSubKey($name, $false)
                        if ($null -eq $session) { continue }
                        try {
                            $path = $session.GetValue('PublicKeyFile', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                            if ($path -is [string] -and $path.Trim()) {
                                $keyPathValue = $path.Trim().Trim('"').Trim("'")
                                $file = Find-LocalPath $keyPathValue
                                Add-File $file 'KeyscanCollector' $Tool 'proto173/174/176' 'SessionKeyFile'
                            }
                        } finally { $session.Dispose() }
                    } catch { $scan.Errors++ }
                }
            } finally { $root.Dispose() }
        }
        if ($names.Count -eq 0) { Add-SourceMetadata 'SavedSessions' $location '' '#174/176' 'SessionEmpty' }
    } catch {
        $scan.Errors++
        Add-SourceMetadata 'SavedSessions' $location '' '#174/176' 'Unavailable'
    }
}

function Find-SshConfigReferences($Config, [int] $Depth = 0) {
    if ($Config -isnot [IO.FileInfo] -or $Depth -gt 3 -or -not $sshVisited.Add($Config.FullName)) { return }
    try {
        if ($Config.Length -gt 4194304 -or $Config.Extension -in @('.pem', '.key', '.ppk', '.pfx', '.p12')) { return }
        # Parse only the directives needed to resolve the file inventory.
        # Do not parse identity file contents or emit raw lines.
        $identities = [Collections.Generic.List[string]]::new()
        $includes = [Collections.Generic.List[string]]::new()
        $hostSelected = $false
        $identity = ''
        foreach ($line in [IO.File]::ReadLines($Config.FullName)) {
            if ($line -match '^\s*(?:-----BEGIN .*PRIVATE KEY-----|PuTTY-User-Key-File-|AGE-SECRET-KEY-)') { return }
            if ($line -notmatch '^\s*(Host|Include|IdentityFile)\s+(.+)$') { continue }
            $directive = $Matches[1]
            $argument = ($Matches[2] -replace '\s+#.*$', '').Trim().Trim('"').Trim("'")
            switch ($directive) {
                'Host' {
                    if ($identity) { $identities.Add($identity) }
                    $identity = ''
                    $hostSelected = @($argument -split '\s+' | Where-Object { $_ -and $_ -notmatch '[*?]' }).Count -gt 0
                }
                'IdentityFile' { if ($hostSelected) { $identity = $argument } }
                'Include' {
                    if ($Depth -lt 3) {
                        foreach ($entry in ($argument -split '\s+')) {
                            if ($entry) { $includes.Add($entry) }
                        }
                    }
                }
            }
        }
        if ($identity) { $identities.Add($identity) }
        foreach ($candidate in $identities) {
            $file = Find-LocalPath ($candidate.Replace('/','\'))
            if ($file -isnot [IO.FileInfo]) { continue }
            [void]$sshIdentityPaths.Add($file.FullName)
            if ($candidate -notmatch '^~[/\\]\.ssh[/\\]') {
                Add-File $file 'KeyscanCollector' 'SSH IdentityFile' 'proto210/211' 'SshIdentityFile'
            }
        }
        foreach ($entry in $includes) {
            # #210 splits on whitespace, prefixes relative Include paths and calls read directly.
            $include = $entry.Replace('/','\')
            if ($entry -notmatch '^[~/]') { $include = '~\.ssh\' + $include }
            $file = Find-LocalPath $include
            if ($file -isnot [IO.FileInfo] -or $sshIdentityPaths.Contains($file.FullName)) { continue }
            Add-File $file 'KeyscanCollector' 'SSH Include' 'proto210' 'SshIncludeFile'
            Find-SshConfigReferences $file ($Depth + 1)
        }
    } catch { $scan.Errors++ }
}


function Test-CatalogExclusion([IO.FileInfo] $File) {
    $name = $File.Name
    return ($name -cin @('toolEmbeddings.json','package-lock.json','.package-lock.json',
        'diagnosticMessages.generated.json','inheritance.json','hooks-index.json',
        'codex-index-v1.json','cloudformation.schema.json','mcp_marketplace_catalog.json') -or
        $name -cmatch 'Embeddings|embeddings|(?:\.deps\.json|\.lock|\.lock\.json)$' -or
        $File.FullName -cmatch '\\Skills-|\\ChatSessions\\' -or
        $name -match '\.pub$|^known_hosts(?:\.old)?$')
}

function Find-ProjectFiles([IO.DirectoryInfo] $Directory, [int] $Depth = 0) {
    # #168 supplies the filename rules. #170 and #180 define traversal and exclusions.
    $projectPattern = '(^\.env$|\.env(?:\.|$)|\.tfvars(?:\.json)?$|^(?:appsettings.*\.json|application.*\.(?:ya?ml|properties)|credentials.*\.json|service-account.*\.json|secrets\..+|\.?mcp\.json|docker-compose\.ya?ml|config\.ini)$)'
    foreach ($child in (Get-ChildrenMetadata $Directory)) {
        if ($child -is [IO.DirectoryInfo]) {
            if ($Depth -lt 2 -and $child.Name -notin @('.git', 'node_modules')) {
                Find-ProjectFiles $child ($Depth + 1)
            }
        } elseif ($child.Name -notmatch '\.(example|sample|template)$' -and
            $child.Name -match $projectPattern -and -not (Test-CatalogExclusion $child)) {
            $child
        }
    }
}

if ($PWD.Provider.Name -ne 'FileSystem') { throw $InventoryText.NonFileSystem }
$stamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
$csvPath = [IO.Path]::Combine($PWD.ProviderPath, "InsightBundleInventory-$InventoryLocale-$stamp-$PID.csv")
$destination = Get-LocalPath $csvPath
if ($null -eq $destination) { throw $InventoryText.NonFileSystem }
if (-not [IO.Directory]::Exists($PWD.ProviderPath)) { throw $InventoryText.InvalidParent }

$sourceRows = [Collections.Generic.List[object]]::new()
$sshVisited = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$sshIdentityPaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

try {
    Add-EnvironmentMetadata 'ProcessEnvironment' 'Process' @(Get-ChildItem -LiteralPath Env: -Name)
} catch {
    $scan.Errors++
    Add-SourceMetadata 'ProcessEnvironment' 'Process' '' '#202/216' 'Unavailable'
}
Add-RegistryEnvironmentMetadata ([Microsoft.Win32.Registry]::CurrentUser) 'Environment' 'HKCU\Environment'
$machineEnvironment = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
Add-RegistryEnvironmentMetadata ([Microsoft.Win32.Registry]::LocalMachine) $machineEnvironment "HKLM\$machineEnvironment"
Add-CredentialManagerMetadata
Add-SavedSessionMetadata ([Microsoft.Win32.Registry]::CurrentUser) 'PuTTY' 'Software\SimonTatham\PuTTY\Sessions'
Add-SavedSessionMetadata ([Microsoft.Win32.Registry]::CurrentUser) 'WinSCP' 'Software\Martin Prikryl\WinSCP 2\Sessions'

foreach ($rule in $catalog) {
    $branch = if ($rule.hostStore) { 'KeyscanHostStore' } else { 'KeyscanDiscovery' }
    foreach ($pattern in $rule.paths) {
        foreach ($file in (Find-LocalPath $pattern -Pattern)) {
            if ($file -isnot [IO.FileInfo]) { continue }
            if (-not $rule.hostStore -and (Test-CatalogExclusion $file)) { continue }
            if ($rule.number -eq 8 -and $file.Name -ceq 'kiro-auth-token.json') { continue }
            $descriptionKey = Get-CatalogDescriptionKey $file $rule
            $tool = $rule.tool
            $translatedTool = $InventoryText.Tool.PSObject.Properties[$tool]
            if ($null -ne $translatedTool) { $tool = $translatedTool.Value }
            $format = $InventoryText.Format.PSObject.Properties[$rule.format].Value
            Add-File $file $branch "$tool ($format)" "proto205 source $($rule.number)" $descriptionKey $tool
        }
    }
}

foreach ($folder in @('source','code','dev','Programming','Documents','Desktop')) {
    $directory = Find-LocalPath ("%USERPROFILE%\" + $folder)
    if ($directory -is [IO.DirectoryInfo]) {
        Find-ProjectFiles $directory | ForEach-Object {
            $descriptionKey = if ($_.Name -match '\.env(?:\.|$)') { 'ProjectEnv' } else { 'ProjectConfig' }
            Add-File $_ 'KeyscanDiscovery' $InventoryText.Category.Project 'proto168/170/180/235' $descriptionKey
        }
    }
}

$sshConfig = Find-LocalPath '~\.ssh\config'
Add-File $sshConfig 'KeyscanCollector' $InventoryText.Category.Ssh 'proto211' 'SshConfig'
Find-SshConfigReferences $sshConfig
foreach ($pattern in @('~\.git-credentials','~\.config\git\credentials')) {
    Add-Pattern $pattern 'KeyscanCollector' $InventoryText.Category.Git 'proto213' 'GitCredentialStore'
}
foreach ($pattern in @(
    '%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt',
    '~\.bash_history','~\.zsh_history','%APPDATA%\fish\fish_history',
    '~\.local\share\fish\fish_history','~\.python_history','~\.psql_history',
    '~\.mysql_history','%APPDATA%\postgresql\psql_history','~\.rediscli_history',
    '~\.sqlite_history','~\.node_repl_history'
)) { Add-Pattern $pattern 'KeyscanCollector' $InventoryText.Category.History 'proto217/229' 'TerminalHistory' }
Add-Pattern '~\.kube\config' 'KeyscanCollector' $InventoryText.Category.Kube 'proto228' 'KubeConfig'
if ($env:KUBECONFIG) {
    foreach ($config in $env:KUBECONFIG.Split(';')) {
        if ($config) { Add-Pattern $config 'KeyscanCollector' $InventoryText.Category.KubeEnvironment 'proto228' 'KubeConfig' }
    }
}
$gpgHome = $env:GNUPGHOME
if (-not $gpgHome) {
    try {
        $gpgKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\GNU\GnuPG', $false)
        if ($null -ne $gpgKey) {
            try { $gpgHome = $gpgKey.GetValue('HomeDir') } finally { $gpgKey.Dispose() }
        }
    } catch { $scan.Errors++ }
}
if ($gpgHome -isnot [string] -or -not $gpgHome) { $gpgHome = '%APPDATA%\gnupg' }
foreach ($filePattern in @('pubring.kbx','secring.gpg','private-keys-v1.d\*.key')) {
    $descriptionKey = switch ($filePattern) {
        'pubring.kbx' { 'GpgPublic' }
        'secring.gpg' { 'GpgSecretRing' }
        default { 'GpgPrivateKey' }
    }
    Add-Pattern ($gpgHome + '\' + $filePattern) 'KeyscanCollector' $InventoryText.Category.Gpg 'proto177/179' $descriptionKey
}

$browserRoots = [ordered]@{
    Chrome = '%LOCALAPPDATA%\Google\Chrome\User Data'
    Edge = '%LOCALAPPDATA%\Microsoft\Edge\User Data'
    Brave = '%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data'
    Vivaldi = '%LOCALAPPDATA%\Vivaldi\User Data'
    Opera = '%APPDATA%\Opera Software\Opera Stable'
}
foreach ($browser in $browserRoots.Keys) {
    $root = Find-LocalPath $browserRoots[$browser]
    if ($root -isnot [IO.DirectoryInfo]) { continue }
    Add-File (Get-ItemMetadata ([IO.Path]::Combine($root.FullName, 'Local State'))) 'BrowserCollector' ($InventoryText.Category.BrowserKeys -f $browser) 'proto246/271' 'ChromiumLocalState' $browser
    foreach ($profile in (Get-ChildrenMetadata $root)) {
        if ($profile -isnot [IO.DirectoryInfo]) { continue }
        foreach ($relative in @('Login Data','Login Data For Account','Network\Cookies','Cookies')) {
            $path = [IO.Path]::Combine($profile.FullName, $relative)
            $file = Find-LocalPath $path -LiteralInput
            if ($file -isnot [IO.FileInfo]) { continue }
            $descriptionKey = if ($file.Name -ieq 'Cookies') { 'ChromiumCookies' } else { 'ChromiumLogins' }
            Add-File $file 'BrowserCollector' ($InventoryText.Category.BrowserDb -f $browser) 'proto252/271' $descriptionKey $browser
            foreach ($suffix in @('-wal','-shm')) {
                $sidecarKey = if ($suffix -eq '-wal') { 'ChromiumWal' } else { 'ChromiumShm' }
                Add-File (Find-LocalPath ($path + $suffix) -LiteralInput) 'BrowserCollector' ($InventoryText.Category.BrowserSidecar -f $browser) 'proto253/254' $sidecarKey $browser
            }
        }
        if ($browser -ne 'Chrome') { continue }
        foreach ($wallet in $walletCatalog) {
            $id = $wallet.id
            $extension = Find-LocalPath ([IO.Path]::Combine($profile.FullName, "Extensions\$id")) -LiteralInput
            if ($extension -isnot [IO.DirectoryInfo]) { continue }
            $storage = switch ($wallet.name) {
                { $_ -in @('coinbase','station','hashpack') } { 'Local Storage\leveldb'; break }
                'slush' { "IndexedDB\chrome-extension_$($id)_0.indexeddb.leveldb"; break }
                default { "Local Extension Settings\$id" }
            }
            $directory = Find-LocalPath ([IO.Path]::Combine($profile.FullName, $storage)) -LiteralInput
            if ($directory -isnot [IO.DirectoryInfo]) { continue }
            foreach ($file in (Get-ChildrenMetadata $directory)) {
                if ($file.Name -cmatch '\.(ldb|sst|log)$') {
                    $descriptionKey = if ($file.Extension -ceq '.log') { 'WalletLog' } else { 'WalletTable' }
                    Add-File $file 'WalletDiscovery' "$($wallet.name) ($id)" 'proto135-141, requires matching ids argument' $descriptionKey $wallet.name
                }
            }
        }
    }
}
foreach ($profile in (Find-LocalPath '%APPDATA%\Mozilla\Firefox\Profiles\*' -Pattern)) {
    if ($profile -isnot [IO.DirectoryInfo]) { continue }
    $key = Get-ItemMetadata ([IO.Path]::Combine($profile.FullName, 'key4.db'))
    $login = Get-ItemMetadata ([IO.Path]::Combine($profile.FullName, 'logins.json'))
    # #274 plans reads only for pairs whose individual sizes fit #58's MAX_READ_BYTES.
    if ($key -isnot [IO.FileInfo] -or $login -isnot [IO.FileInfo]) { continue }
    try {
        if ($key.Length -gt 4194304 -or $login.Length -gt 4194304) { continue }
    } catch { $scan.Errors++; continue }
    Add-File $key 'BrowserCollector' $InventoryText.Category.FirefoxKeys 'proto274-279' 'FirefoxKeys'
    Add-File $login 'BrowserCollector' $InventoryText.Category.FirefoxLogins 'proto274-279' 'FirefoxLogins'
}
foreach ($folder in @('nikke_launcher','nikke_launcher_hmt')) {
    foreach ($name in @('psd.dat','last_user.dat')) {
        $descriptionKey = if ($name -eq 'psd.dat') { 'NikkeSavedPassword' } else { 'NikkeLastUser' }
        Add-Pattern ("%APPDATA%\$folder\$name") 'NikkeCollector' $InventoryText.Category.Nikke 'proto309/312/313' $descriptionKey
    }
}
function Format-InventoryRow($Row) {
    $branchNames = foreach ($branch in ($Row.Branches | Sort-Object)) {
        $InventoryText.Branch.PSObject.Properties[$branch].Value
    }
    $headers = $InventoryText.Headers
    [pscustomobject][ordered]@{
        ($headers.Path) = $Row.Path
        ($headers.SizeBytes) = $Row.SizeBytes
        ($headers.CreatedUtc) = $Row.CreatedUtc
        ($headers.ModifiedUtc) = $Row.ModifiedUtc
        ($headers.MatchedBranches) = $branchNames -join ' | '
        ($headers.RuleEvidence) = ($Row.Matches | Sort-Object) -join ' | '
        ($headers.FileDescription) = ($Row.Descriptions | Sort-Object) -join ' '
        ($InventoryText.Metadata.Headers.Type) = $InventoryText.Metadata.Source.File
        ($InventoryText.Metadata.Headers.Location) = $null
        ($InventoryText.Metadata.Headers.Item) = $null
    }
}

# CreateNew protects existing reports, including concurrent runs.
$csvStream = [IO.FileStream]::new($destination.FullName, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::Read)
try {
    $writer = [IO.StreamWriter]::new($csvStream, [Text.UTF8Encoding]::new($true))
    try {
        & {
            $rows.Values | Sort-Object Path | ForEach-Object { Format-InventoryRow $_ }
            $sourceRows
        } | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $writer.WriteLine($_) }
    } finally { $writer.Dispose() }
} finally { $csvStream.Dispose() }

if ($scan.Errors -or $scan.ProtectedSkipped -or $scan.UnsupportedPaths) {
    Write-Host ($InventoryText.Warning + ' ' + $InventoryText.Skipped) -ForegroundColor Yellow
}
$summary = $InventoryText.Summary
[pscustomobject][ordered]@{
    ($summary.Csv) = $destination.FullName
    ($summary.Files) = $rows.Count
    ($summary.EntriesChecked) = $scan.Entries
    ($summary.ProtectedOrOfflineSkipped) = $scan.ProtectedSkipped
    ($summary.UnsupportedPaths) = $scan.UnsupportedPaths
    ($summary.UnsetPathVariables) = $scan.UnsetVariables
    ($summary.MetadataErrors) = $scan.Errors
    ($summary.ElapsedSeconds) = [Math]::Round($timer.Elapsed.TotalSeconds, 2)
    ($summary.BundleBuild) = "insight.bundle / $BundleBuild"
    ($summary.BundleSha256) = $BundleSha256
}
