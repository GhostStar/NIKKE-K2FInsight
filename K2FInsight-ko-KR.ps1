#requires -Version 5.1
<#
.SYNOPSIS
    insight.bundle의 정적 규칙과 일치하는 파일을 목록으로 만듭니다.
.DESCRIPTION
    Windows PowerShell 5.1 또는 PowerShell 7에서 확인 대상 사용자 계정으로 실행합니다.
    insight.bundle에 내장된 빌드 식별자 K2F_LUA_BUILD = 722b99d8d0e9를 기준으로 합니다.
    샘플 크기는 205135바이트이며 LuaJIT 바이트코드 형식 버전은 1입니다.
    샘플 SHA256은 cc0ad05bfe85940a6067b3a72c182d3953339129206634141926d5d0b35973ec입니다.
    내장 자격 증명 경로와 지갑 확장 기능 ID는 함수 #205와 #141에서 추출했습니다.
    파일 설명은 파일 이름, 경로, 정적 규칙을 바탕으로 작성합니다.
    파일과 데이터 소스 항목을 같은 CSV에 저장합니다.
    재분석 지점, 오프라인 파일, 원격 경로는 건너뜁니다.
    번들에서 복원한 규칙으로 파일 목록을 만듭니다.
    CSV는 PowerShell의 현재 디렉터리에 저장합니다.
.EXAMPLE
    .\K2FInsight-ko-KR.ps1
#>
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$BundleBuild = '722b99d8d0e9'
$BundleSha256 = 'cc0ad05bfe85940a6067b3a72c182d3953339129206634141926d5d0b35973ec'
$InventoryLocale = 'ko-KR'
$InventoryText = @'
{
  "RequiresWindows": "이 스크립트는 Windows에서 실행해야 합니다.",
  "InvalidParent": "CSV 출력 디렉터리는 이미 존재하고 접근 가능해야 합니다.",
  "Skipped": "일부 경로를 건너뛰었습니다. 검사 통계를 확인하세요.",
  "Metadata": {
    "Headers": {
      "Type": "레코드 유형",
      "Location": "데이터 소스 위치",
      "Item": "항목"
    },
    "Source": {
      "ProcessEnvironment": "현재 프로세스 환경",
      "RegistryEnvironment": "Windows 환경 레지스트리",
      "CredentialManager": "Windows 자격 증명 관리자",
      "SavedSessions": "저장된 세션",
      "File": "파일"
    },
    "Description": {
      "EnvironmentEmpty": "이름 규칙과 일치하는 후보 변수가 없다.",
      "CredentialEmpty": "필터 조건에 일치하는 후보 항목이 없다.",
      "CredentialItem": "자격 증명 대상의 메타데이터다. 식별 가능한 서비스나 호스트 및 항목 지문을 표시한다.",
      "SessionEmpty": "이 레지스트리 경로에 저장된 세션이 없다.",
      "SessionItem": "세션 레지스트리 하위 키다. 일반적인 이름 또는 항목 지문을 표시한다.",
      "Unavailable": "이 데이터 소스의 검사를 완료하지 못했다.",
      "EnvironmentName": "이름 규칙에 일치한 변수다."
    }
  },
  "File": {
    "SshIncludeFile": "SSH Include가 참조하는 로컬 설정 파일이다. 파일 위치 확인에 필요한 지시문만 분석한다.",
    "SshIdentityFile": "SSH IdentityFile이 지정한 로컬 키 파일 후보다. 메타데이터만 확인한다.",
    "SessionKeyFile": "PuTTY 또는 WinSCP의 PublicKeyFile이 가리키는 파일이다. 메타데이터만 확인한다.",
    "SshConfig": "SSH 클라이언트 설정 파일입니다. 접속 대상, 사용자 이름, 인증 키 경로, 추가 설정 파일을 지정할 수 있습니다.",
    "SshFile": "SSH 설정 디렉터리에 있는 파일입니다. 인증 키, 설정 또는 기타 SSH 데이터일 수 있습니다.",
    "KeySource": "샘플이 키 또는 인증서 저장소로 분류한 경로의 파일입니다. 실제 형식과 개인 키 포함 여부는 확인하지 않았습니다.",
    "DotNetSecrets": ".NET 개발용 사용자 비밀 JSON입니다. 애플리케이션 비밀 값과 연결 문자열을 담을 수 있습니다.",
    "EditorDatabase": "{0}의 SQLite 상태 데이터베이스입니다. 편집기와 확장 기능 데이터를 저장하며 일부 레코드에는 계정, 인증 또는 세션 상태가 포함될 수 있습니다.",
    "ContainerConfig": "{0}의 컨테이너 레지스트리 설정입니다. 인증 항목이나 자격 증명 도우미 참조가 포함될 수 있습니다.",
    "FtpSites": "FileZilla 사이트 또는 최근 연결 데이터입니다. 서버, 계정, 저장된 인증 필드가 포함될 수 있습니다.",
    "GitConfig": "Git 설정 파일입니다. 원격 저장소, 사용자 식별 정보, 자격 증명 도우미 등을 지정할 수 있습니다.",
    "GoEnv": "Go 도구 체인의 환경 설정입니다. 모듈 프록시와 비공개 저장소 설정이 포함될 수 있습니다.",
    "CodexAuth": "Codex CLI 인증 파일입니다. 로그인 방식에 따라 토큰이나 API 인증 데이터가 포함될 수 있습니다.",
    "CodexConfig": "Codex CLI 설정 파일입니다. 모델 제공자, 엔드포인트, MCP 등의 연동을 지정할 수 있습니다.",
    "PowerShellProfile": "PowerShell 시작 프로필 스크립트입니다. 명령, 경로, 환경 설정을 정의할 수 있습니다.",
    "ExtensionSettings": "편집기 확장 기능이 globalStorage에 저장하는 JSON입니다. 환경설정, 연동 주소, 계정 또는 세션 설정이 포함될 수 있습니다.",
    "ProtectedStore": "{0}의 Windows DPAPI 보호 인증 캐시입니다. 값 복구는 해당 Windows 보호 컨텍스트에 따라 달라집니다.",
    "CatalogDatabase": "{0}의 로컬 SQLite 데이터베이스입니다. 샘플은 이를 계정 또는 인증 데이터 출처로 분류합니다.",
    "McpConfig": "{0}의 MCP 설정 파일입니다. 서버 실행 명령, URL, 인증 설정을 정의할 수 있습니다.",
    "CatalogCache": "{0}의 캐시 파일로 샘플의 경로 규칙에 해당합니다. 임시 인증 또는 세션 상태가 포함될 수 있습니다.",
    "CatalogAuth": "{0}의 파일입니다. 이름으로 볼 때 인증 정보, 자격 증명 또는 토큰을 저장하는 데 쓰일 수 있습니다.",
    "CatalogConfig": "{0}의 설정 또는 로컬 상태 파일입니다. 샘플 목록에 포함되며 서비스 주소나 인증 설정을 담을 수 있습니다.",
    "ProjectEnv": "프로젝트 환경 변수 파일입니다. 실행 설정, 연결 문자열 또는 API 키를 정의할 수 있습니다.",
    "ProjectConfig": "프로젝트 설정 또는 비밀 정보 후보 파일입니다. 샘플의 파일명 규칙에 해당합니다.",
    "GitCredentialStore": "Git 자격 증명 저장 파일입니다. 자격 증명 URL에 사용자 이름, 비밀번호 또는 토큰이 들어갈 수 있습니다.",
    "TerminalHistory": "명령 또는 대화형 셸 기록입니다. 이전에 입력한 명령에 경로, URL 또는 직접 입력한 비밀 값이 포함될 수 있습니다.",
    "KubeConfig": "Kubernetes 클라이언트 설정입니다. 클러스터, 컨텍스트, 사용자 항목과 함께 토큰, 인증서 또는 키 파일 참조가 포함될 수 있습니다.",
    "GpgPublic": "GnuPG 공개 키 저장소입니다. 공개 키와 관련 식별 정보를 저장합니다.",
    "GpgSecretRing": "이전 형식의 GnuPG 비밀 키링입니다. 저장된 키 자료는 암호 문구로 보호되어 있을 수 있습니다.",
    "GpgPrivateKey": "GnuPG 개인 키 컨테이너입니다. 키 자료가 암호 문구로 보호되어 있거나 하드웨어 토큰의 키를 참조할 수 있습니다.",
    "ChromiumLocalState": "{0} 브라우저 전체 설정과 키 메타데이터입니다. 브라우저 데이터를 보호하는 암호화 키가 래핑된 상태로 저장될 수 있습니다.",
    "ChromiumCookies": "{0} 프로필의 쿠키 데이터베이스입니다. 쿠키 값은 암호화되어 있을 수 있으며 활성 웹 세션에 사용될 수 있습니다.",
    "ChromiumLogins": "{0} 프로필의 저장된 로그인 데이터베이스입니다. 사이트, 사용자 이름, 암호화된 비밀번호 필드가 포함될 수 있습니다.",
    "ChromiumWal": "{0} SQLite 데이터베이스의 선행 기록 로그입니다. 아직 주 데이터베이스에 반영되지 않은 최신 페이지가 포함될 수 있습니다.",
    "ChromiumShm": "{0} SQLite 데이터베이스의 공유 메모리 보조 파일입니다. 선행 기록 로그의 인덱싱과 접근 조정에 사용됩니다.",
    "FirefoxKeys": "Firefox 프로필의 NSS 키 데이터베이스 key4.db입니다. 저장된 로그인 정보 보호에 사용됩니다.",
    "FirefoxLogins": "Firefox의 저장된 로그인 파일 logins.json입니다. 사이트 메타데이터와 암호화된 사용자 이름, 비밀번호 필드가 포함될 수 있습니다.",
    "WalletLog": "{0} 지갑 확장 기능의 관련 저장 경로에 있는 LevelDB 쓰기 로그입니다. 최근 레코드가 포함될 수 있습니다.",
    "WalletTable": "{0} 지갑 확장 기능의 관련 저장 경로에 있는 LevelDB 테이블입니다. 확장 기능 상태나 암호화된 지갑 데이터가 포함될 수 있습니다.",
    "NikkeSavedPassword": "NIKKE 런처의 계정 저장 파일 psd.dat입니다. 샘플은 이 파일을 저장된 비밀번호 복구의 입력으로 사용합니다.",
    "NikkeLastUser": "NIKKE 런처의 last_user.dat 파일입니다. 런처에서 마지막으로 사용한 계정과 관련됩니다."
  },
  "Branch": {
    "KeyscanDiscovery": "자격 증명 경로 탐색(keyscan)",
    "KeyscanHostStore": "로컬 자격 증명 저장소(keyscan)",
    "KeyscanCollector": "전용 수집기(keyscan)",
    "BrowserCollector": "브라우저 데이터 수집(browserscan)",
    "WalletDiscovery": "지갑 파일 탐색(wallet_files)",
    "NikkeCollector": "NIKKE 계정 수집(creds)"
  },
  "Headers": {
    "Path": "파일 경로",
    "SizeBytes": "크기(바이트)",
    "CreatedUtc": "생성 시각(UTC)",
    "ModifiedUtc": "수정 시각(UTC)",
    "MatchedBranches": "일치한 분기",
    "RuleEvidence": "규칙 근거",
    "FileDescription": "파일 설명"
  },
  "Summary": {
    "Csv": "CSV 저장 경로",
    "Files": "일치한 파일 수",
    "EntriesChecked": "경로 확인 횟수",
    "ProtectedOrOfflineSkipped": "링크 또는 오프라인 상태로 건너뛴 경로",
    "UnsupportedPaths": "지원하지 않는 경로 확인 횟수",
    "UnsetPathVariables": "경로 변수가 설정되지 않아 건너뛴 횟수",
    "MetadataErrors": "메타데이터 확인 오류 수",
    "ElapsedSeconds": "소요 시간(초)",
    "BundleBuild": "Bundle 빌드 식별자",
    "BundleSha256": "Bundle SHA-256"
  },
  "Category": {
    "Project": "프로젝트 파일명 규칙",
    "Ssh": "SSH 설정",
    "Git": "Git 자격 증명 저장소",
    "History": "터미널 기록",
    "Kube": "Kubernetes 설정",
    "KubeEnvironment": "KUBECONFIG 경로",
    "Gpg": "GnuPG 키 저장소",
    "BrowserKeys": "{0} 키 저장소",
    "BrowserDb": "{0} 데이터베이스 후보",
    "BrowserSidecar": "{0} 데이터베이스 보조 파일",
    "FirefoxKeys": "Firefox 키 데이터베이스 후보",
    "FirefoxLogins": "Firefox 로그인 저장소 후보",
    "Nikke": "저장된 계정 데이터"
  },
  "Tool": {
    "Private keys": "개인 키",
    ".NET user-secrets": ".NET 사용자 비밀",
    "AWS CLI cache": "AWS CLI 캐시",
    "VS Code extensions": "VS Code 확장 기능",
    "PowerShell profile": "PowerShell 프로필",
    "Go env": "Go 환경 설정"
  },
  "Format": {
    "text": "텍스트",
    "lines": "줄 단위 텍스트",
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
  "Warning": "경고",
  "Prototype": "함수 #",
  "Source": " 출처 ",
  "WalletCondition": "이며 일치하는 ids 인수가 필요함",
  "NonFileSystem": "현재 PowerShell 위치는 로컬 파일 시스템 디렉터리여야 합니다."
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
