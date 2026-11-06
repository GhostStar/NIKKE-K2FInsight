# K2FInsight

[简体中文](#简体中文) · [日本語](#日本語) · [한국어](#한국어) · [English](#english)

| 语言 / Language | PowerShell |
| --- | --- |
| 简体中文 | [K2FInsight-zh-CN.ps1](K2FInsight-zh-CN.ps1) |
| 日本語 | [K2FInsight-ja-JP.ps1](K2FInsight-ja-JP.ps1) |
| 한국어 | [K2FInsight-ko-KR.ps1](K2FInsight-ko-KR.ps1) |
| English | [K2FInsight.ps1](K2FInsight.ps1) |

## 简体中文

K2FInsight 根据从 `insight.bundle` 还原的规则，为当前 Windows 账户生成只读检查清单。内置范围包括凭据路径、项目配置、浏览器数据库、Chrome 钱包扩展存储、NIKKE 账号存档及下文列出的数据源。

### 事件参考来源

- [NGA 论坛讨论帖（47843502）](https://ngabbs.com/read.php?tid=47843502)
- [WormW 的 NIKKE 启动器与 K2F 样本分析](https://github.com/WormW/nikke_malware_analysis)
- [MotherSphere 的 NIKKE PC 启动器事件报告](https://gist.github.com/MotherSphere/d6c049a09ba8ac3085c51ee9df24a4e5)

### Windows 使用说明

1. 下载上表对应的 `.ps1` 文件。用要检查的 Windows 账户登录，按 `Win + R`，输入 `powershell` 后回车。也可以在 Windows 终端打开 PowerShell 7。普通用户权限即可运行。
2. 切换到脚本保存的目录并运行。下面以 `Downloads` 为例，若脚本保存在其他目录，替换为实际路径。

```powershell
Set-Location -LiteralPath "$env:USERPROFILE\Downloads"
.\K2FInsight-zh-CN.ps1
```

如果 PowerShell 提示执行策略禁止运行脚本，确认下载的是上表中的 K2FInsight 脚本后，可在同一目录运行以下命令。该设置仅对新启动的 PowerShell 进程生效。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\K2FInsight-zh-CN.ps1
```

脚本把文件和数据源条目写入同一份 `InsightBundleInventory-zh-CN-*.csv`，保存在**运行命令时 PowerShell 所在的目录**，采用带 BOM 的 UTF-8 编码。运行摘要显示保存路径、命中文件数、扫描统计和样本构建标记。

- 文件行包含文件路径、大小（字节）、创建时间（UTC）、修改时间（UTC）、命中分支、规则依据和文件说明。
- 数据源行逐项列出当前 PowerShell 进程和 HKCU／HKLM 环境注册表中命中的变量名、Windows 凭据管理器候选条目，以及 PuTTY／WinSCP 会话。可按「记录类型」「数据源位置」「条目」筛选。数据源行的「条目」为空时，可在「文件说明」区分无匹配项和检查未完成。

凭据条目显示 Windows 凭据类型，以及从目标名称提取的服务、域名或短目标名。方括号内是目标标识的 SHA-256 前 16 个十六进制字符，用于区分和对照记录。无法提取可辨识标签时，仅显示类型和指纹。短目标名标识保存的目标，创建凭据的应用需另行核实。PuTTY／WinSCP 的常规会话名与指纹一起显示，其余会话用指纹区分。CSV 省略变量值、凭据内容和用户名字段。URL 目标只保留主机。

文件说明依据名称、路径和命中规则生成。扫描读取文件系统元数据，跳过重解析点、离线文件和远程路径。历史读取、解密或外传需另有证据。CSV 中的绝对路径可能包含用户名和项目名称。

直接运行即可使用样本规则。项目配置搜索以样本的六个用户目录为起点，向下检查两层。Firefox 配置要求 `key4.db` 与 `logins.json` 同时存在，且各自不超过 4 MiB。钱包命中对应 `wallet_files` 收到匹配扩展 ID 时的路径。脚本解析样本规则覆盖的 SSH `Include` 和 `IdentityFile`，并检查 PuTTY 和 WinSCP 的 `PublicKeyFile` 引用。`Include` 按样本字面路径规则最多递归三层。密钥文件只检查元数据。

## 日本語

K2FInsight は `insight.bundle` から復元したルールを使い、現在の Windows アカウントを読み取り専用で調べます。対象には資格情報の保存先、プロジェクト設定、ブラウザーのデータベース、Chrome ウォレット拡張機能、NIKKE のアカウント保存ファイル、および以下のデータソースが含まれます。

### インシデントの参考資料

- [NGA フォーラムのスレッド（47843502）](https://ngabbs.com/read.php?tid=47843502)
- [WormW による NIKKE ランチャーと K2F サンプルの解析](https://github.com/WormW/nikke_malware_analysis)
- [MotherSphere による NIKKE PC ランチャーのインシデント報告](https://gist.github.com/MotherSphere/d6c049a09ba8ac3085c51ee9df24a4e5)

### Windows での実行手順

1. 上の表から該当する `.ps1` ファイルをダウンロードします。調査対象の Windows アカウントで `Win + R` を押し、`powershell` と入力して Enter を押します。Windows Terminal で PowerShell 7 を開くこともできます。通常のユーザー権限で実行できます。
2. スクリプトの保存先に移動して実行します。以下は `Downloads` に保存した場合の例です。別の場所に保存した場合は実際のパスに置き換えてください。

```powershell
Set-Location -LiteralPath "$env:USERPROFILE\Downloads"
.\K2FInsight-ja-JP.ps1
```

実行ポリシーでスクリプトがブロックされた場合は、上の表から取得した K2FInsight スクリプトであることを確認し、同じディレクトリで次のコマンドを実行できます。この設定は起動した PowerShell プロセスだけに適用されます。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\K2FInsight-ja-JP.ps1
```

ファイルとデータソースの項目は、BOM 付き UTF-8 の `InsightBundleInventory-ja-JP-*.csv` にまとめて、**PowerShell の現在のディレクトリ**に保存します。実行結果には保存先、該当ファイル数、スキャン統計、サンプルのビルド識別子が表示されます。

- ファイル行にはパス、サイズ、作成日時と更新日時（UTC）、該当する処理、ルールの根拠、ファイルの説明が含まれます。
- データソース行には、現在の PowerShell プロセスと HKCU／HKLM の環境レジストリで一致した変数名、Windows 資格情報マネージャーの候補、PuTTY／WinSCP セッションを記録します。「レコード種別」「ソースの場所」「項目」で絞り込めます。「項目」が空欄のデータソース行は「ファイルの説明」で、該当なしと確認未完了を区別できます。

資格情報の項目には Windows 資格情報の種類と、ターゲット名から抽出したサービス名、ドメイン名、または短いターゲット名を表示します。角括弧内はターゲット識別子の SHA-256 の先頭 16 桁で、項目の照合に使えます。識別できる名前がない場合は種類と指紋だけを表示します。短いターゲット名から作成元アプリを特定するには、別の証拠が必要です。PuTTY／WinSCP では通常のセッション名と指紋を表示し、その他は指紋で区別します。CSV には変数値、資格情報の内容、ユーザー名のフィールドを出力しません。URL からはホスト名だけを抽出します。

ファイルの説明は名前、パス、ルールに基づきます。スキャンはファイルシステムのメタデータを取得し、再解析ポイント、オフラインファイル、リモートパスをスキップします。過去の読み取り、復号、外部送信の確認には別の証拠が必要です。CSV の絶対パスにユーザー名やプロジェクト名が含まれる場合があります。

引数なしでサンプル由来のルールを使用します。プロジェクト設定はサンプルの六つのユーザーディレクトリを起点に二階層まで確認します。Firefox は `key4.db` と `logins.json` がそろい、それぞれが 4 MiB 以下のプロファイルを対象にします。ウォレットの該当項目は、対応する拡張機能 ID が `wallet_files` に渡された場合のパスです。サンプルの規則に従って SSH `Include`、`IdentityFile`、PuTTY と WinSCP の `PublicKeyFile` を確認します。`Include` はリテラルパスとして最大 3 階層まで処理します。鍵ファイルはメタデータのみ確認します。

## 한국어

K2FInsight는 `insight.bundle`에서 복원한 규칙으로 현재 Windows 계정을 읽기 전용으로 검사합니다. 검사 범위에는 자격 증명 경로, 프로젝트 설정, 브라우저 데이터베이스, Chrome 지갑 확장 기능 저장소, NIKKE 계정 저장 파일과 아래 데이터 소스가 포함됩니다.

### 사건 참고 자료

- [NGA 포럼 게시글 (47843502)](https://ngabbs.com/read.php?tid=47843502)
- [WormW의 NIKKE 런처 및 K2F 샘플 분석](https://github.com/WormW/nikke_malware_analysis)
- [MotherSphere의 NIKKE PC 런처 사건 보고서](https://gist.github.com/MotherSphere/d6c049a09ba8ac3085c51ee9df24a4e5)

### Windows 사용 방법

1. 위 표에서 해당 `.ps1` 파일을 다운로드합니다. 검사할 Windows 계정에서 `Win + R`을 누르고 `powershell`을 입력한 뒤 Enter를 누릅니다. Windows 터미널에서 PowerShell 7을 열어도 됩니다. 일반 사용자 권한으로 실행할 수 있습니다.
2. 스크립트를 저장한 디렉터리로 이동한 뒤 실행합니다. 아래는 `Downloads`에 저장했을 때의 예시입니다. 다른 위치에 저장했다면 실제 경로로 바꾸세요.

```powershell
Set-Location -LiteralPath "$env:USERPROFILE\Downloads"
.\K2FInsight-ko-KR.ps1
```

실행 정책으로 스크립트가 차단되면 위 표에서 받은 K2FInsight 스크립트인지 확인한 뒤 같은 디렉터리에서 아래 명령을 실행할 수 있습니다. 이 설정은 새로 시작되는 PowerShell 프로세스에만 적용됩니다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\K2FInsight-ko-KR.ps1
```

파일과 데이터 소스 항목을 BOM이 포함된 UTF-8 `InsightBundleInventory-ko-KR-*.csv`에 합쳐 **PowerShell의 현재 디렉터리**에 저장합니다. 실행 요약에는 저장 경로, 일치한 파일 수, 검사 통계, 샘플 빌드 식별자가 표시됩니다.

- 파일 행에는 경로, 크기, 생성 및 수정 시각(UTC), 일치한 분기, 규칙 근거, 파일 설명이 포함됩니다.
- 데이터 소스 행에는 현재 PowerShell 프로세스와 HKCU／HKLM 환경 레지스트리에서 일치한 변수 이름, Windows 자격 증명 관리자 후보, PuTTY／WinSCP 세션을 기록합니다. 「레코드 유형」「데이터 소스 위치」「항목」으로 필터링할 수 있습니다. 데이터 소스의 「항목」이 비어 있으면 「파일 설명」에서 일치 항목 없음과 검사 미완료를 구분할 수 있습니다.

자격 증명 항목에는 Windows 자격 증명 유형과 대상 이름에서 추출한 서비스명, 도메인명 또는 짧은 Windows 대상 이름을 표시합니다. 대괄호 안에는 대상 식별자의 SHA-256 앞 16자리가 표시되어 항목을 대조할 수 있습니다. 식별 가능한 이름이 없으면 유형과 지문만 표시합니다. 자격 증명을 생성한 앱을 확인하려면 별도 증거가 필요합니다. PuTTY／WinSCP의 일반적인 세션 이름에는 지문을 함께 표시하며 나머지는 지문으로 구분합니다. CSV에는 변수 값, 자격 증명 내용, 사용자 이름 필드를 기록하지 않습니다. URL에서는 호스트 이름만 추출합니다.

파일 설명은 이름, 경로, 규칙을 바탕으로 작성합니다. 검사는 파일 시스템 메타데이터를 확인하며 재분석 지점, 오프라인 파일, 원격 경로를 건너뜁니다. 과거 읽기, 복호화, 외부 전송을 확인하려면 별도의 증거가 필요합니다. CSV의 절대 경로에는 사용자 이름이나 프로젝트 이름이 포함될 수 있습니다.

인수 없이 실행하면 샘플에서 복원한 규칙을 사용합니다. 프로젝트 설정은 샘플의 사용자 디렉터리 여섯 곳에서 두 단계까지 확인합니다. Firefox는 `key4.db`와 `logins.json`이 모두 있고 각각 4 MiB 이하인 프로필을 대상으로 합니다. 지갑 항목은 일치하는 확장 기능 ID가 `wallet_files`에 전달되는 경우의 경로입니다. 샘플 규칙에 따라 SSH `Include`와 `IdentityFile`, PuTTY 및 WinSCP의 `PublicKeyFile`을 확인합니다. `Include`는 리터럴 경로로 최대 세 단계까지 처리합니다. 키 파일은 메타데이터만 확인합니다.

## English

K2FInsight uses rules recovered from `insight.bundle` to build a read-only inventory for the current Windows account. It covers credential paths, project configuration, browser databases, Chrome wallet extension storage, NIKKE saved account files, and the data sources listed below.

### Incident references

- [NGA forum thread (47843502)](https://ngabbs.com/read.php?tid=47843502)
- [WormW’s NIKKE launcher and K2F sample analysis](https://github.com/WormW/nikke_malware_analysis)
- [MotherSphere’s NIKKE PC launcher incident report](https://gist.github.com/MotherSphere/d6c049a09ba8ac3085c51ee9df24a4e5)

### Running on Windows

1. Download the matching `.ps1` file from the table above. Sign in as the Windows account you want to inspect. Press `Win + R`, type `powershell`, and press Enter. You can also open PowerShell 7 in Windows Terminal. Standard user permissions are sufficient.
2. Change to the folder where you saved the script and run it. The example uses `Downloads`. Substitute the actual folder if you saved the script elsewhere.

```powershell
Set-Location -LiteralPath "$env:USERPROFILE\Downloads"
.\K2FInsight.ps1
```

If PowerShell blocks the script because of its execution policy, confirm you have the K2FInsight script from the table above, then run the following command from the same directory. The policy setting applies only to the new PowerShell process.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\K2FInsight.ps1
```

The script writes file and data source entries to one UTF-8 CSV with a BOM, `InsightBundleInventory-en-US-*.csv`, in **the current PowerShell directory**. The console summary shows the output path, number of matched files, scan counts, and sample build.

- File rows include the path, size in bytes, creation and modification times in UTC, matched branches, rule evidence, and file description.
- Data source rows list matching variable names from the current PowerShell process and HKCU/HKLM environment registry, Windows Credential Manager candidates, and PuTTY/WinSCP sessions. Filter by **Record type**, **Source location**, or **Item**. If **Item** is blank for a data source, **File description** distinguishes no matches from an incomplete check.

Credential entries show the Windows credential type and any recognizable service, domain, or short Windows target name. The brackets contain the first 16 hex characters of the target identifier's SHA-256 hash for comparing entries. If the target name yields no recognizable label, the CSV shows the type and fingerprint. A short target name identifies the saved target. Identifying the application that created the entry requires separate evidence. PuTTY/WinSCP entries show ordinary session names with fingerprints, or fingerprints alone for other names. The CSV omits variable values, credential contents, and username fields. For URL targets, it extracts only the host.

Descriptions come from the file name, path, and matched rule. The scan collects filesystem metadata and skips reparse points, offline files, and remote paths. Historical reads, decryption, and transfers require separate evidence. Absolute paths in the CSV may include usernames and project names.

Run without arguments to use the recovered rules. Project checks descend two levels from the sample’s six user directories. Firefox requires both `key4.db` and `logins.json`, each within 4 MiB. Wallet matches describe paths eligible when `wallet_files` receives a matching extension ID. The script follows the sample's SSH `Include` and `IdentityFile` rules and checks PuTTY and WinSCP `PublicKeyFile` references. `Include` processing follows literal paths up to three levels deep. Key checks use metadata only.

## 样本 / サンプル / 샘플 / Sample

| | |
| --- | --- |
| File | `insight.bundle` |
| Embedded build | `K2F_LUA_BUILD = 722b99d8d0e9` |
| SHA-256 | `cc0ad05bfe85940a6067b3a72c182d3953339129206634141926d5d0b35973ec` |
| Size | `205135` bytes |
| LuaJIT bytecode format version | `1` |
| Recovered rules | `131` credential source entries and `234` path patterns from prototype `#205`. `28` wallet extension IDs from prototype `#141`. |

