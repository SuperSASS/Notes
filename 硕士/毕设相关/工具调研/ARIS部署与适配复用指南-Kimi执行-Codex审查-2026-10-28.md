# ARIS 部署与适配复用指南：Kimi 执行 + Codex 审查

整理日期：2026-10-28。基于 `WSL-Research-ARIS` 的实际配置、安装文件、本地差异和本次部署中的测试记录。

这份文档用于两种情况：在新 WSL 重建本次配置；或以本次经验为基础，改成 Codex 执行、Kimi 审查等其他角色组合。正文说明选型、机制和操作顺序；附录保存可提取的补丁、适配脚本、技能选择及脱敏配置。

## 1. 先确定要复用什么

本次建成的链路是：

```text
Kimi Code CLI（订阅认证，执行者）
  ├─ ARIS skills：调研、方案、实现、实验、分析、写作
  ├─ Codex MCP → ARIS 原生 codex-exec → Codex CLI（ChatGPT 认证，审查者）
  ├─ 研究状态 / 审查追踪 / 日志 / meta / 技能库写入保护
  └─ DeepXiv、Exa、OpenAlex、Gemini、Zotero、Obsidian
```

执行与审查是两个实际调用上下文：Kimi 产出材料，Codex 读取材料并给出裁决，Kimi 修改后可在同一 Codex 线程中复审；需要独立裁决时另开审查线程。本次没有把 Claude Code 作为必需依赖。

### 1.1 当前完成范围

- 用户级安装 59 个 ARIS skills，另有 1 个共享参考目录，共 60 个安装条目。
- 核心执行—审查—修改—复审链路、原生状态与追踪工具已接通。
- Kimi 日志、恢复提醒、结束前进度提醒、meta 就绪提醒和 corpus guard 已配置。
- 新上下文子代理、后台任务管理、Cron 注册/删除和一次实际唤醒已有测试记录。
- 六项本轮外部能力已完成各自配置和实际调用检查。
- 真实科研项目的 ARIS 任务状态、研究契约和产物路由尚待接入。

### 1.2 三种改动要分清

| 类别 | 本次含义 | 例子 |
|---|---|---|
| 原生复用 | 仓库已有机制，直接使用 | skills、codex-exec、run_state.py、save_trace.sh、meta 原生脚本、watchdog.py |
| 宿主适配 | 因执行平台从 Claude 换成 Kimi 而调整 | 技能目录、AGENTS.md、hook payload 与消息通道、安装器路径 |
| 本地兼容修复/安装配套 | 原文接口、跨阶段约定或 SDK 与实际版本不匹配 | Exa 的 urls 参数、DeepXiv 的 --mode、结果声明文件路径、Zotero md5 为 null |

项目初始化和实验运行是另外两个阶段。安装 skills 不会自动建立完整科研目录、启动训练、配置云平台或开通所有 API。

## 2. 环境、版本和目录

### 2.1 本次基线

| 组件 | 本次版本 / 方式 |
|---|---|
| Windows / WSL | Windows 11，WSL2，Ubuntu 24.04；发行版 `WSL-Research-ARIS` |
| Linux 用户 | `supersass`，HOME 为 `/home/supersass` |
| Git / Python | 起始环境 Git 2.43.0、Python 3.12.3 |
| nvm / Node | 起始 nvm 0.40.7；Node v24.22.0 |
| pnpm | 12.11.2 |
| Kimi Code | 2.2.0；包 `@moonshot-ai/kimi-code`；当前默认 `kimi-code/k3` |
| Codex CLI | 0.162.1；包 `@openai/codex`；ChatGPT 登录 |
| ARIS | 提交 `26b95cfa0d8747078e9e43b42e20952709e561b8`，加附录中的本地补丁 |
| uv | 0.13.1 |
| DeepXiv / Exa SDK | deepxiv-sdk 1.2.1；exa-py 2.25.0 |
| Gemini 相关 | Gemini CLI 0.64.0；gemini-mcp-tool 1.1.8；实际后端 Antigravity CLI 1.4.2 |
| Zotero MCP | Galaxy-Dawn 分支，0.1.7；源码提交 `97a449ae7e9c7a3b8b3c6a655b996d98c7232a9f` |
| Obsidian MCP | `@bitbonsai/mcpvault` 0.17.1 |

这是本次快照。新机器可以复现该基线；升级版本时，先重新核对 CLI 参数、SDK 接口和 hooks 行为，再决定是否继续套用补丁。Antigravity 安装器带自动更新能力，不能只凭安装日期判断运行版本。

### 2.2 主要持久化位置

以下 `~` 在本次主机均为 `/home/supersass`。

```text
~/.aris/
  aris_repo/                       真正的 ARIS Git 仓库
  repo                             原生仓库定位文件：内容是 aris_repo 的绝对路径
  tools -> aris_repo/tools          原生共享工具定位链接
  install_aris_kimi.sh              本地 Kimi 安装器
  installed-skills-kimi.txt         安装清单：59 skills + shared-references
  skills-declined-kimi.txt          25 个未注册技能
  agent-profiles-opt-out           不部署 Copilot reviewer profiles 的记号
  adapters/
    kimi_meta_log.py                Kimi 事件 → 原生日志协议
    kimi_state_hooks.py             Kimi 恢复、状态和 meta 提醒
  state/kimi-hooks/                 按工作目录和会话分离的计数/去重状态
  meta/events.jsonl                 跨项目 meta 日志，运行时追加
  venvs/deepxiv/                    DeepXiv 独立 Python 环境
  venvs/exa/                        Exa 独立 Python 环境
  credentials/exa.env              EXA_API_KEY，不进入文档或 Git
  credentials/openalex.env         OPENALEX_API_KEY，不进入文档或 Git
  gemini-search-workspace/          外部检索模型的独立工作目录
  installers/antigravity-install.sh 本次保存的官方安装脚本
  downloads/zotero/                 本次手动下载包与构建包，安装准备材料
  verification/                    隔离测试目录，不是科研资产
  backups/                         部分历史改动的备份，按实际内容处理

~/.kimi-code/
  skills/<skill>/                  每项分别链接到 aris_repo/skills/<skill>
  skills/shared-references/         共享协议链接
  AGENTS.md                        安装范围、Kimi 映射、恢复/持久化规则
  config.toml                      原有模型/认证设置 + hooks
  mcp.json                         codex、gemini-cli、zotero、obsidian-vault

~/.codex/state/codex-exec/threads/  Codex 桥接保存的审查线程选项
~/.local/bin/                     uv、uvx、agy、deepxiv、zotero-mcp
~/.local/share/pnpm/              Node CLI 包、命令入口和 store
~/.local/share/uv/tools/zotero-mcp-server/  Zotero 独立安装环境
~/.gemini/antigravity-cli/         agy 设置、登录及会话材料
~/.env                           DeepXiv 首次自动注册产生的 token
```

Kimi/Codex 自身还会生成登录材料、会话历史、日志和缓存。迁移时在新主机重新登录，不把认证目录作为普通配置附录复制。`downloads`、`verification` 与正式配置分开管理；下载目录可在确认重建材料已另存后清理，不能在工具仍使用它时随意移动源码安装来源。

### 2.3 Shell 与 PATH

本次同时存在 Windows Scoop Node 和 Linux nvm Node。错误调用 Windows `node.exe` 会造成 UNC 路径、模块定位和权限问题。

交互式 Linux Shell 中应先找到：

```text
/home/supersass/.nvm/versions/node/v24.22.0/bin
/home/supersass/.local/share/pnpm/bin
/home/supersass/.local/bin
```

`bash -lc` 不保证完整加载交互式 `.bashrc`；本次非交互检查就出现过 `kimi/codex/node: command not found`。MCP 的 Node 服务使用专门的显式 PATH，不能只看交互终端里命令能否运行。

检查方式：

```bash
type -a node pnpm kimi codex
readlink -f "$(command -v node)"
node --version
kimi --version
codex --version
```

这些命令在 Linux Shell 执行；从 Windows 访问时明确指定 `wsl -d WSL-Research-ARIS`。

## 3. 新 WSL 重建顺序

本节是新环境重建路线，不是要求在当前主机重复执行。每一步先核对目标路径和已有配置，涉及下载、覆盖、登录、模型调用与真实数据写入时按当次授权执行。

1. 建好独立 WSL，确认 Linux Python、Git、Node、pnpm 与 PATH。
2. 安装/登录执行 CLI 和审查 CLI；先分别跑通最小调用。
3. 克隆 ARIS 到 `~/.aris/aris_repo`，选择基线提交。
4. 从附录提取本地补丁和适配文件，先检查补丁能否应用。
5. 用 Kimi 安装器注册指定 skills，生成清单和定位文件。
6. 合并全局 AGENTS、hooks 和 Codex MCP；不要覆盖已有模型或凭据配置。
7. 做小型执行—审查—修改—复审与状态追踪测试。
8. 安装 uv，再逐项配置外部检索源。
9. 接入现有 Zotero 与 Obsidian，先做只读验收。
10. 读取真实项目治理规则，确定任务，再进行项目级接入。

### 3.1 初始工具

本次开始前，WSL、Git、Python、nvm、Node、pnpm、Kimi 和 Codex 已具备；它们不是 ARIS 安装器的产物。Node 工具偏好 pnpm，Python 工具按其原生方式安装。

```bash
# 在 Node/pnpm 已正常工作的全新环境中：
pnpm add -g @moonshot-ai/kimi-code@2.2.0 @openai/codex@0.162.1
codex login
codex login status
# 启动 kimi，按交互界面完成现有 Kimi Code 账号登录。
```

### 3.2 框架仓库与补丁

```bash
mkdir -p "$HOME/.aris"
git clone https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git \
  "$HOME/.aris/aris_repo"
git -C "$HOME/.aris/aris_repo" checkout 26b95cfa0d8747078e9e43b42e20952709e561b8
```

新环境采用原提交时，可按附录重建本次安装器并应用本地差异。若采用更新上游，先判断上游是否已经修复相同问题；不要把旧补丁强行套入新接口。

本次最初使用过 `~/aris_repo`，最终按用户选择将真仓库移到 `~/.aris/aris_repo`，避免 HOME 顶层杂乱。日后只保留一个权威仓库，技能与共享工具都指向它。

### 3.3 从单文件文档提取重建材料

附录中的 `ARIS-EMBED` 区块保存不含凭据的实际适配文件。将本 Markdown 放到新 WSL 可访问的位置后，可用以下 Python 提取到 `~/.aris/rebuild-kit/`。提取会写文件；输出已存在时停止，避免覆盖。

```bash
python3 -B - '/path/to/本配置文档.md' <<'PY'
from pathlib import Path
import re, sys
text = Path(sys.argv[1]).read_text(encoding="utf-8")
dest = Path.home() / ".aris/rebuild-kit"
dest.mkdir(parents=True, exist_ok=True)
pattern = r"<!-- ARIS-EMBED:([A-Za-z0-9_.-]+) -->\n```[^\n]*\n(.*?)\n```\n<!-- ARIS-EMBED:END -->"
blocks = re.findall(pattern, text, re.S)
if not blocks:
    raise SystemExit("未找到重建区块")
for name, body in blocks:
    p = dest / name
    if p.exists():
        raise SystemExit(f"目标已存在：{p}")
for name, body in blocks:
    # 当前快照中的主目录需要随新机器账号调整。
    body = body.replace("/home/supersass", str(Path.home()))
    (dest / name).write_text(body + "\n", encoding="utf-8")
print(dest)
PY
```

随后在同一基线版本上：

```bash
cp "$HOME/.aris/aris_repo/tools/install_aris.sh" "$HOME/.aris/install_aris_kimi.sh"
patch --dry-run "$HOME/.aris/install_aris_kimi.sh" < "$HOME/.aris/rebuild-kit/install_aris_kimi.patch"
patch "$HOME/.aris/install_aris_kimi.sh" < "$HOME/.aris/rebuild-kit/install_aris_kimi.patch"
git -C "$HOME/.aris/aris_repo" apply --check "$HOME/.aris/rebuild-kit/aris-local.patch"
git -C "$HOME/.aris/aris_repo" apply "$HOME/.aris/rebuild-kit/aris-local.patch"

SKILLS=$(paste -sd, "$HOME/.aris/rebuild-kit/skills-selected.txt")
bash "$HOME/.aris/install_aris_kimi.sh" "$HOME" \
  --aris-repo "$HOME/.aris/aris_repo" --platform claude \
  --skills "$SKILLS" --no-agent-profiles --quiet
```

`--platform claude` 在这里表示复用经改造的原版科研 skill 安装分支，防止自动委派给 Codex-native 安装器；执行者仍是 Kimi。以后本地更新注册时使用 `--reconcile`，先 `--dry-run`。不要把这个 Kimi 安装器当作原生 Codex 安装器。

部署 hooks 适配脚本：

```bash
mkdir -p "$HOME/.aris/adapters"
cp "$HOME/.aris/rebuild-kit/kimi_meta_log.py" "$HOME/.aris/adapters/kimi_meta_log.py"
cp "$HOME/.aris/rebuild-kit/kimi_state_hooks.py" "$HOME/.aris/adapters/kimi_state_hooks.py"
```

再按第 9 节把 `AGENTS.kimi.md` 的受控块、`hooks.toml` 和 `mcp.redacted.json` 合并到新主机配置。此时先注册 Codex；Gemini、Zotero、Obsidian 条目在完成各自安装、路径及凭据配置后再启用，避免一开始启动不存在的服务。这里不会复制原机器的登录状态。

## 4. 原生安装器做了什么，Kimi 改了什么

### 4.1 原版 Claude 安装的边界

基线 `tools/install_aris.sh` 的重点是项目级注册：

- 将每个 skill 平铺链接到 `<项目>/.claude/skills/<名称>`。
- 写 `<项目>/.aris/installed-skills.txt` 与 declined 清单。
- 建立 `<项目>/.aris/tools` 与 `~/.aris/repo` 定位关系。
- 在已有项目 `CLAUDE.md` 中更新受控 `ARIS Skill Scope` 块；原版会跳过不存在的文件。
- 按选择处理 `.github/agents` 的 Copilot reviewer profiles。

安装器不会一次性创建完整科研目录、填好 Pipeline Status、安装全部 MCP、部署恢复 hooks 或启动 watchdog。文档里提到这些机制，不等于运行安装器后已自动配置。

### 4.2 Kimi 安装适配

本次在独立的 `~/.aris/install_aris_kimi.sh` 中修改安装目标，保留原安装器的清单、协调和 symlink 管理逻辑：

| 原版 | Kimi 本次 |
|---|---|
| `.claude/skills` | `.kimi-code/skills` |
| 项目 `CLAUDE.md` | 用户级 `.kimi-code/AGENTS.md` |
| `installed-skills.txt` | `installed-skills-kimi.txt` |
| `skills-declined.txt` | `skills-declined-kimi.txt` |
| `ARIS:BEGIN/END` | `ARIS-KIMI:BEGIN/END` |
| 项目级 scope 文案 | 用户级 scope 文案，引用绝对路径 |
| 指令文件不存在则跳过 | 可创建用户级 AGENTS.md |
| 条件部署 Copilot profiles | 本次显式 `--no-agent-profiles` |

在专用 WSL 上以 `$HOME` 为安装目标，获得用户级 skills；将来进入新项目无需再拷贝这些技能。实际研究状态仍写到项目/任务。

### 4.3 技能选择

本次上游 84 个可选 skills 中注册 59 个。具体选择和排除名单均在附录。

- 保留 `auto-review-loop`；其职责是编排审查闭环，实际裁决仍调用 Codex。
- 不注册 `auto-review-loop-llm`、`auto-review-loop-minimax`，避免同时引入不同审查后端路线。
- 保留 DeepXiv、Exa、Gemini、OpenAlex 及实验平台技能，让它们能被发现；平台账号是否可用另行配置。
- 不注册已不适用或当前方向不需要的基金、专利、面试、部分证明/机器人/展示类技能。
- `dse-loop` 本次仍保留；`lean-formalize`、`proof-orchestrator` 未注册。需要严格形式化证明时再评估。
- `shared-references` 是共享协议目录，不计入 59 个技能。

ARIS 有上层流程调用下层技能的关系，但不应假设未注册技能一定能被宿主发现。选择范围应由实际研究需求决定，不额外构建一套自定义技能推荐系统。

## 5. Codex 独立审查：复用原生桥接

### 5.1 为什么不是 codex mcp-server

本次 Codex CLI 0.162.1 已不使用旧 `codex mcp-server` 入口。ARIS 仓库自带：

```text
~/.aris/aris_repo/mcp-servers/codex-exec/server.py
```

桥接对外提供 `codex` 和 `codex-reply`，对内启动 `codex exec`，输出 `threadId` 和回复内容。它是原生组件，本次没有另造一套审查服务。

MCP 服务名必须是 `codex`，才能与 `mcp__codex__codex`、`mcp__codex__codex-reply` 一致。审查示例参数：

```json
{
  "model": "gpt-6-astra",
  "config": {"model_reasoning_effort": "ultra"},
  "sandbox": "read-only",
  "cwd": "/absolute/path/to/test-or-project",
  "prompt": "读取指定材料，给出裁决、证据定位和最小修改建议。不要修改文件。"
}
```

新机器先确认账号支持指定模型和推理级别。模型 ID 是配置选择，不是永远有效的常量。

### 5.2 线程、身份和追踪

- 续审使用实际返回的 threadId；桥接恢复原线程 model/config/sandbox/cwd，避免 resume 偷换为默认设置。
- 本地桥接状态在 `~/.codex/state/codex-exec/threads/`；Codex 自身会话材料由 CLI 维护。
- 原生追踪在 `<项目>/.aris/traces/<skill>/<date>_runNN/`，包括运行元数据、调用元数据、请求与完整回复。
- 执行者身份通过已有参数明确填写，例如 `--executor kimi-code --executor-model kimi-code/k3`。
- 区分请求的模型和后端实际报告的模型。后端未报告时保留 null / requested 来源；不能从一次 MCP 成功就填写“身份已独立认证”。
- `family_relation=different` 表示已记录的家族不同；本次真实调用追踪仍保留 `independence_verified=unverified`。

本次给 `tools/save_trace.sh` 增加 Moonshot/Kimi 家族识别。原生停止门禁已有 Kimi 家族支持；这两者应分别核对。

### 5.3 状态工具的含义

`tools/run_state.py` 的 start / set / resume / status / accept 用来管理阶段。实际测试中，某阶段标记 `done` 但尚未接受时，resume 仍返回该阶段；只有完成审查/接受流程后才能继续相应门禁。保存追踪不会自动把 FAIL 改成 PASS，也不会自动接受阶段。

## 6. AGENTS、hooks、日志与 meta

### 6.1 AGENTS.md 的三部分

用户级 `~/.kimi-code/AGENTS.md` 保留：

1. `ARIS-KIMI`：技能范围、清单、仓库链接与更新命令。
2. `ARIS-KIMI-COMPAT`：原文项目 CLAUDE.md 映射为项目 AGENTS.md；初始化参照原生模板；状态/追踪工具填写 Kimi 身份。
3. `ARIS-KIMI-RECOVERY`：阶段切换、选题/基线确定、训练启停、保存/交接时更新状态；压缩后回读项目状态、研究契约、findings 和活动任务。

用户级文件放规则；Pipeline Status、当前实验和待办属于项目/任务。ARIS Scope 管理块与 Pipeline Status 是两种不同内容。

### 6.2 原生 Claude hooks 不能机械复制

本次实际 CLI 测试确认：Kimi 的 `UserPromptSubmit` 输出可以进入模型上下文；`PreToolUse`、`PostToolUse` 的普通成功输出没有以相同方式进入上下文。Kimi 的 `Stop` 阻止结束机制能注入原因并让模型继续。

据此选择：事件 hook 负责计数和标记，真正的状态提醒延迟到 Stop 阶段；不通过频繁阻止工具来打断正常工作。

### 6.3 正式配置的 10 项 hooks

| 事件 | 脚本 | 用途 |
|---|---|---|
| SessionStart | `~/.aris/adapters/kimi_meta_log.py` | 会话日志 |
| UserPromptSubmit | 同上 | 用户输入/技能调用日志归一化 |
| PostToolUse | 同上 | 工具成功日志 |
| PostToolUseFailure | 同上 | 工具失败日志 |
| SessionEnd | 同上 | 会话结束日志 |
| PreToolUse，matcher=Bash | `~/.aris/aris_repo/templates/claude-hooks/corpus_write_guard.py` | 原生技能库 Bash 写入保护 |
| UserPromptSubmit | `~/.aris/adapters/kimi_state_hooks.py` | 新会话第一次用户输入时提醒恢复 |
| PreToolUse | 同上 | 工具调用计数 |
| PostToolUse | 同上 | 非状态文件 Write/Edit 次数 |
| Stop | 同上 | 状态刷新、进度和 meta 就绪提醒 |

这些 hooks 合并到 `~/.kimi-code/config.toml`。附录仅提供 hooks 段，保留新机器已有的 providers/models/login 设置。脚本在本次专用主机全局使用，没有额外增加“只处理 ARIS 目录”的过滤层。

### 6.4 日志适配的具体工作

`kimi_meta_log.py` 继续调用原生 `tools/meta_opt/log_event.sh`，不另建日志格式：

- 校验 cwd 并设置原生脚本需要的 `CLAUDE_PROJECT_DIR`；该变量是兼容字段名。
- 将 Kimi 的 Write/Edit `path` 对应到原生 `file_path`。
- 归一化列表形式的 prompt。
- 将直接 `/skill:名称` 激活时宿主注入的 `skill-loaded` 结构归一化为原生日志可识别的技能调用；保留普通用户输入。
- 记录成功、失败和会话生命周期，输出到 `<cwd>/.aris/meta/events.jsonl` 与 `~/.aris/meta/events.jsonl`。

直接 skill 激活可能不出现一个独立 Skill 工具调用，不能只靠 PostToolUse 中的 Skill 事件计数。真实 CLI 会话和退出后的日志回读用于发现这一点。

### 6.5 状态提醒的具体行为

- 每个 cwd + session_id 独立保存状态，使用文件锁与原子替换。
- 首次 UserPromptSubmit 注入恢复指令。
- 每累计 30 次 PreToolUse，在 Stop 时提醒回读 Pipeline Status 并核对。
- 每累计 10 次非状态文件 Write/Edit，在 Stop 时提醒按实质进度更新 Pipeline Status / EXPERIMENT_TRACKER。
- 调用原生 `tools/meta_opt/check_ready.sh`，按稳定条件去重 meta 提醒；次数从 5 到 6 不重复提醒同一就绪状态。
- 使用 stop_sent 防止同一轮反复阻止结束；用户新一轮输入时重置。
- 提醒遵守当前轮的只读/禁写限制；meta 就绪只提醒，不自动执行优化或应用变更。

### 6.6 明确保留的差异

1. 进度提醒在 Stop 阶段发生，不是每次工具调用中途刷新。
2. 严格的“压缩前模型先保存状态，再允许压缩”尚未实现，因此继续保留 AGENTS 持久化与压缩后恢复协议。
3. skill 的 `allowed-tools` 文案与 Kimi 原生 tools 配置应分开理解；并非所有 Claude 的按 skill 动态工具限制都已自动移植。
4. corpus guard 检查 Bash 对技能库的写入；它不代替完整文件系统沙箱。实际配置中禁用某个工具时，不应再用另一个工具绕过。
5. meta 闭环使用原生暂存、审查和人工门禁；优化建议不自动授权改写 skills。

## 7. 本地修改清单

### 7.1 ARIS 仓库内的 9 个修改文件

以下路径均相对于 `~/.aris/aris_repo/`，完整 diff 在附录。

| 文件 | 修改原因与分类 |
|---|---|
| `skills/auto-review-loop/SKILL.md` | 明确 review-stage 只放本阶段产物；CLAIMS_FROM_RESULTS.md、findings.md、MANIFEST.md 仍按共享协议放项目根。原生文档交接约定的本地修复。 |
| `skills/result-to-claim/SKILL.md` | 要求把真实裁决、声明范围、证据路径和完整性标签写入根目录 CLAIMS_FROM_RESULTS.md；保留 REVIEW_UNAVAILABLE。原生跨阶段交接补齐。 |
| `tools/save_trace.sh` | 新增 kimi/moonshot → moonshot 家族识别。Kimi 身份追踪兼容修复。 |
| `tools/deepxiv_fetch.py` | search 默认不传 SDK 1.2.1 不支持的 --mode；显式传入时明确报错。SDK 兼容。 |
| `skills/deepxiv/SKILL.md` | 标出本版本不可用的 mode / wsearch / sc 分支。SDK 兼容说明。 |
| `tools/exa_search.py` | `get_contents` 参数从 ids 改为 urls。SDK 兼容。 |
| `skills/exa-search/SKILL.md` | 4 处调用改用 Exa 独立环境的 Python。安装配套。 |
| `skills/research-lit/SKILL.md` | 2 处 Exa 调用使用同一独立 Python；补 Gemini MCP 声明及 agy 调用/权限/错误处理。安装配套与后端适配。 |
| `skills/gemini-search/SKILL.md` | 改用 agy 登录/后端，移除错误工具和固定模型假设，保留错误信息，允许读取网页工具返回的内容缓存。后端适配。 |

这些是基线上的本地差异；没有在本次工作中完成向 ARIS 上游提交。新机器升级前检查问题是否已被上游修复。保持事实和输出契约，不通过改变验收含义来让测试通过。

### 7.2 仓库外的改动

- `~/.aris/install_aris_kimi.sh`：安装器适配，完整差异在附录。
- `~/.aris/adapters/kimi_meta_log.py`、`kimi_state_hooks.py`：Kimi hooks 适配，完整源码在附录。
- `~/.kimi-code/AGENTS.md`、`config.toml`、`mcp.json`：宿主规则、hooks 与服务注册。
- `~/.bashrc`：ARIS_REPO、Exa/OpenAlex 凭据加载，以及工具安装器写入的 PATH。
- `~/.profile`、`~/.zshrc`：uv / Antigravity 官方安装器追加的启动项；新环境审阅后合并，避免重复追加。
- `~/.gemini/antigravity-cli/settings.json`：增加 `permissions.allow` 中的 `read_url(*)`；保留原有设置。
- `~/.local/share/uv/tools/zotero-mcp-server/lib/python3.12/site-packages/zotero_mcp/client.py`：`len(child_data.get("md5", ""))` 改为 `len(child_data.get("md5") or "")`。Zotero 本地 API 的 md5=null 兼容修复。

Zotero 补丁位于已安装环境，重新安装/升级可能覆盖；复用时应重新判断是否仍需要该一行修复。

## 8. 外部工具：安装、凭据与验证

### 8.1 uv 与 Python 环境

uv 是本次额外安装的 Python 工具管理器，DeepXiv、Exa 与 Zotero 分别隔离。官方安装入口：<https://docs.astral.sh/uv/getting-started/installation/>。

本次使用官方默认安装方式，安装到 `~/.local/bin`，产生 `env`/安装记录并修改 Shell 启动项。讨论过的 `UV_NO_MODIFY_PATH=1` 是禁止官方安装器改 PATH 的可选开关，不是本次最终配置的额外要求。

```bash
curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
# 阅读脚本并确认后执行：
sh /tmp/uv-install.sh
```

不要把所有 SDK 塞进系统 Python，也不要把整个虚拟环境加入全局 PATH 来改变 `python3` 的含义。

### 8.2 DeepXiv

```bash
uv venv "$HOME/.aris/venvs/deepxiv" --python /usr/bin/python3
uv pip install --python "$HOME/.aris/venvs/deepxiv/bin/python" 'deepxiv-sdk==1.2.1'
ln -s "$HOME/.aris/venvs/deepxiv/bin/deepxiv" "$HOME/.local/bin/deepxiv"
```

首次实际使用会自动注册 token 并写入 `~/.env`。这是有网络和凭据持久化影响的动作。API/服务配额以后以账号实际状态为准。

本次确认 search、brief、head、section、trending 路径可用。SDK 1.2.1 不接受旧文档中的 `--mode`，也没有文档部分示例的 wsearch/sc 命令；采用附录补丁后使用服务默认搜索。

### 8.3 Exa

```bash
uv venv "$HOME/.aris/venvs/exa" --python /usr/bin/python3
uv pip install --python "$HOME/.aris/venvs/exa/bin/python" 'exa-py==2.25.0'
```

在 [Exa 控制台](https://dashboard.exa.ai/) 获取自己的 key。凭据保存为 `~/.aris/credentials/exa.env`，目录权限 700，文件 600。不要在聊天中发送 key，不把 key 直接写进命令参数。

适配必须同时处理 `exa-search` 的 4 处和 `research-lit` 的 2 处调用；只改独立 skill 会导致上层调研仍用错误解释器。

```bash
"$HOME/.aris/venvs/exa/bin/python" "$HOME/.aris/aris_repo/tools/exa_search.py" \
  search 'automated driving scenario generation' --max 3 --content highlights
```

本次 search、find-similar、get-contents、research paper 分类检索均已有实际结果。SDK 2.25.0 的内容抓取参数是 `urls`，对应源码补丁保存在附录。

### 8.4 OpenAlex

从 [OpenAlex](https://openalex.org/) 账号获取 key，保存为 `~/.aris/credentials/openalex.env`，变量名 `OPENALEX_API_KEY`。本次系统 Python 已有 requests，无需另建 SDK 环境。新机器先验证 `python3 -c 'import requests'`，没有时在合适的隔离环境中补齐，并同步调用解释器。

```bash
python3 "$HOME/.aris/aris_repo/tools/openalex_fetch.py" \
  search 'automated driving scenario generation' --max 3 --json
python3 "$HOME/.aris/aris_repo/tools/openalex_fetch.py" \
  work '10.1038/s41586-021-03819-2' --json
```

本次验证 search、过滤、DOI 和 OpenAlex ID 查询；不额外要求邮箱。API key 与用量政策按新账号现状核对。

### 8.5 Exa / OpenAlex 的本地输入与自动加载

新机器可在自己的终端中使用 getpass 输入；以下脚本只创建指定凭据文件，已存在时停止。它会产生凭据文件，需在可信本机执行。

```bash
python3 -B - <<'PY'
from pathlib import Path
from getpass import getpass
import os, shlex
root = Path.home() / ".aris/credentials"
root.mkdir(parents=True, exist_ok=True)
root.chmod(0o700)
for filename, variable in [("exa.env", "EXA_API_KEY"), ("openalex.env", "OPENALEX_API_KEY")]:
    p = root / filename
    if p.exists():
        raise SystemExit(f"凭据文件已存在：{p}")
    value = getpass(f"本机输入 {variable}: ").strip()
    if not value:
        raise SystemExit("输入为空，停止")
    fd = os.open(p, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(f"export {variable}={shlex.quote(value)}\n")
    print(f"已保存 {p}，未显示密钥")
PY
```

本次将以下内容放在 `~/.bashrc` 的“非交互则 return”之前；框架位置同样在前面导出：

```bash
# ARIS-OPENALEX-CREDENTIALS
if [ -r "$HOME/.aris/credentials/openalex.env" ]; then
    . "$HOME/.aris/credentials/openalex.env"
fi
# ARIS-EXA-CREDENTIALS
if [ -r "$HOME/.aris/credentials/exa.env" ]; then
    . "$HOME/.aris/credentials/exa.env"
fi
export ARIS_REPO="$HOME/.aris/aris_repo"
```

重新打开终端并从该终端启动 Kimi。已有进程不会自动获得后来写入 Shell 配置的变量；从服务或其他宿主启动时要显式安排环境加载。检查变量是否存在时只输出布尔值，不输出内容。

### 8.6 Gemini：实际使用 Antigravity 后端

本次先安装过：

```bash
pnpm add -g @google/gemini-cli@0.64.0 gemini-mcp-tool@1.1.8
```

Gemini CLI 的个人 Google 账号登录路径返回“不再支持该客户端，迁移到 Antigravity”。最终链路改为：

```text
Kimi → gemini-cli MCP → gemini-mcp-tool → agy → Google 账号与联网工具
```

`@google/gemini-cli` 留在本机，但当前检索链路不依赖它；新机器走相同账号路线时，可优先只准备 `gemini-mcp-tool` 与 agy。

官方入口见 [Antigravity CLI](https://antigravity.google/docs/cli/tutorial)。本次安装流程：

```bash
mkdir -p "$HOME/.aris/installers" "$HOME/.aris/gemini-search-workspace"
curl -fsSL https://antigravity.google/cli/install.sh \
  -o "$HOME/.aris/installers/antigravity-install.sh"
# 阅读安装脚本并确认后：
bash "$HOME/.aris/installers/antigravity-install.sh"
# 在专用检索目录启动 agy，按交互界面选择 Google 账号登录。
```

需要用户亲自完成浏览器授权，不让 Agent 读取或转发授权码。本次出现过登录后 403/地区错误，最终通过更换路由器 OpenClash 出站节点解决；这是网络路径问题，不能直接归因为账号资格。

设置文件 `~/.gemini/antigravity-cli/settings.json` 合并：

```json
{"permissions": {"allow": ["read_url(*)"]}}
```

该项允许 URL 读取；不要改成所有工具自动批准。保留原 colorScheme、trustedWorkspaces 等设置。真实模型默认值由后端决定，gemini-mcp-tool 的 agy 后端忽略 model 参数，因此技能不再硬填 `auto-gemini-3`。

运行要点：

- MCP 中配置 `GEMINI_MCP_BACKEND=agy`、`AGY_CLI_PATH`、显式 Node/Pnpm PATH、独立检索 cwd。
- `ask-gemini` 传 `sandbox: true`；CLI 备用路径使用 `--sandbox --output-format json --print-timeout 120s`，宿主超时 180 秒。
- 提示模型真实调用网络搜索和网页读取，返回来源 URL；允许读取这些工具返回的网页缓存，禁止无关本地文件、项目写入、Shell 和子代理。
- 解析 JSON 的 response、error、denied_actions；保留 stderr，不能把权限错误吞掉后输出一个正常答案。
- 桥接有旧 agy 版本的能力警告，是否有足够隔离应以实际工具限制与行为检查，不把一个参数名当作权限证明。
- 本次发现网页读取的正文先存入提供方缓存，若把所有本地读取一概禁止，模型拿不到已获取的页面。因此允许“本次网页工具返回的内容缓存”，而非开放整个科研项目。
- 已验证工具包含 ask-gemini、ping、Help、brainstorm、fetch-chunk；当前桥接没有 sandbox-test。

实际联网测试找到了 AlphaFold 论文并读取 Nature 页面；MCP 与 CLI 备用路径均获得正确标题、年份、DOI。网页正文很长时会显著增加上下文用量，按任务控制范围。

### 8.7 Zotero：复用已有文献库

本次已有 Scholar 环境为 `WSL-Research-Kimi-Scholar`，MCP 配置是 `~/.kimi-code/mcp.json`，服务名 zotero。读取其配置只检查连接方式与凭据是否存在；复制凭据时不输出到终端或文档。

ARIS 官方文档推荐 54yyyu/zotero-mcp；本次选择其 [Galaxy-Dawn 分支](https://github.com/Galaxy-Dawn/zotero-mcp)，保留 Scholar 已使用的导入、编辑、集合管理等能力。

网络稳定时的安装方式：

```bash
uv tool install --python /usr/bin/python3 \
  'git+https://github.com/Galaxy-Dawn/zotero-mcp.git@97a449ae7e9c7a3b8b3c6a655b996d98c7232a9f'
```

本次在线安装下载 CUDA 依赖时超时，最终由用户在 WSL 下载，Agent 离线安装。采用的是原依赖组合，没有切换 CPU PyTorch；下载运行包约 3.08 GiB、185 个文件，之后补构建包。

```bash
mkdir -p "$HOME/.aris/downloads/zotero"
UV_HTTP_TIMEOUT=600 uv tool run --python /usr/bin/python3 --from pip \
  pip download --dest "$HOME/.aris/downloads/zotero" \
  --timeout 600 --retries 10 --prefer-binary \
  'git+https://github.com/Galaxy-Dawn/zotero-mcp.git@97a449ae7e9c7a3b8b3c6a655b996d98c7232a9f'
UV_HTTP_TIMEOUT=600 uv tool run --python /usr/bin/python3 --from pip \
  pip download --dest "$HOME/.aris/downloads/zotero" \
  --timeout 600 --retries 10 hatchling setuptools wheel
uv tool install --python /usr/bin/python3 --offline --no-index \
  --find-links "$HOME/.aris/downloads/zotero" \
  "$HOME/.aris/downloads/zotero/zotero-mcp-server-0.1.7.zip"
```

`pip download` 收集包，不会把 Zotero 安装进运行环境；源码的构建依赖需要单独补齐。大包下载完还报缺 hatchling 时，不要重新下载全部 CUDA。

本次配置：`ZOTERO_LOCAL=true`，Windows Zotero 监听 `127.0.0.1:23119`；保留本机 API key、library ID/type 和必要的网络设置，去掉 Scholar 的 `UNSAFE_OPERATIONS=all`。服务具有导入/编辑能力；受该开关控制的删除操作关闭。`mcp.json` 权限设为 600。

```bash
# 只检查服务可达；不写文献：
curl --noproxy '*' -fsS http://127.0.0.1:23119/connector/ping
```

Windows Zotero 没打开时，两台 WSL 访问都超时；打开后均 HTTP 200。Windows 当前采用 mirrored WSL networking，该设置是共享环境配置，不是此处给每个新发行版偷偷修改的项目。

全文故障按三层诊断：

1. **附件识别错误**：本地 API 返回 md5=null，`len(None)` 被吞掉，误报没有附件。已做一行兼容修复，见第 7.2 节。
2. **附件尚未下载**：能列出 PDF 元数据，但 Windows storage 中文件不存在。请用户在 Zotero 打开论文使其下载。
3. **全文与路径**：下载后 Zotero 完成全文索引，MCP 成功返回约 21.8 万字符正文。本次未新增 `~/Zotero` 映射，也未修复“未索引 PDF 的 Windows file:// 路径备用转换”。

检验时实时重新查询 child key；用户补充附件后 key 可能改变。打开中的 Zotero 使用 WAL，`immutable=1` 读取主数据库可能看不到最新记录；以实时 API 和实际文件为准，不写数据库或强行 checkpoint。

当前服务发现 38 个工具。元数据、集合、主题检索、附件、BibTeX、索引全文已通过；语义索引尚未初始化，写入功能未用真实文献试写。现有依赖组合会产生部分 Context.info 未 await 的日志警告，数据读取路径已正常；可按实际需求再修复日志兼容。

### 8.8 Obsidian：连接现有目录，不重新建库

最初记录为 `F:\Research-KB`，接入时该路径已不存在。经用户确认，当前权威目录是：

```text
Windows: F:\Obsidian Vault\Research\edge-scenario-research
WSL:     /mnt/f/Obsidian Vault/Research/edge-scenario-research
```

本次使用 ARIS 官方推荐的 [mcpvault](https://github.com/bitbonsai/mcpvault)，直接访问文件，无需 Obsidian 运行、插件或额外 API key。

```bash
pnpm add -g @bitbonsai/mcpvault@0.17.1
```

服务名用 `obsidian-vault`，与 `research-lit` 的 `mcp__obsidian-vault__*` 声明对齐。采用原生读写模式；若某台机器只做检索，可在 vault 参数后加 `--read-only`，它会隐藏并拒绝修改工具。

本次发现 18 个工具，成功列目录、读取 00-Hub.md，并按“场景”检索出已有论文笔记。测试未调用写、删、移工具；没有 bootstrap、同步、迁移或新建第二个库，也没有安装可选 obsidian-skills。

## 9. 配置如何合并

附录保存当前四个 MCP 的脱敏配置和 hooks TOML。恢复时：

1. 以新机器实际 HOME、Node 版本路径和 vault 路径替换绝对路径。
2. 保留已有 MCP 条目，只增加/调整这四个服务；不要把带占位符的 Zotero 凭据当成有效配置启动。
3. Zotero 凭据在用户本机填入或由现有配置直接复制，不经聊天中转。
4. hooks 仅合并 `[[hooks]]` 项，不替换已有 Kimi 模型与认证配置。
5. 将两个适配器放到 `~/.aris/adapters/`；合并 AGENTS 中的受控块。
6. `mcp.json` 含凭据时设为 600；外部 key 文件为 600，凭据目录为 700。
7. 重新启动 Kimi，在实际 CLI 会话验证宿主加载了新配置。

四条服务：

| MCP 名 | command | 关键参数 |
|---|---|---|
| codex | `/usr/bin/python3` | 原生 codex-exec/server.py；超时 900000 ms |
| gemini-cli | `/bin/bash` | `-c` 切换专用 cwd 后 exec gemini-mcp；agy 环境和 Node PATH；超时 180000 ms |
| zotero | `~/.local/bin/zotero-mcp` | serve；本机 Zotero/账号环境 |
| obsidian-vault | `~/.local/share/pnpm/bin/mcpvault` | vault 绝对路径作为单个参数；显式 Node PATH |

服务配置、独立协议调用和宿主实际可调用分层检查。Kimi doctor 通过不替代 MCP 真实工具调用；某些服务能初始化也不代表对应账号、检索或全文已可用。

## 10. 验收方法与排障经验

### 10.1 最小但有区分力的验证

| 要验证的机制 | 测试方法 | 关键观察 |
|---|---|---|
| skill 可发现 | 隔离目录放无副作用 probe；实际 `/skill:名称` 激活 | 真的加载技能，不是模型凭描述模仿 |
| 工具权限 | 先读已知文件，再尝试唯一授权临时标记写入 | 分清工具不在定义、被宿主拒绝、执行失败；禁用后不换工具绕过 |
| hook 上下文可见性 | 各事件输出不可猜的随机标记，让模型报告实际收到的标记 | 不能让模型读脚本/日志后再声称收到提醒 |
| 日志 | 成功 Read、预期失败 Read、Skill 工具和直接 slash 各一次 | 退出后回读原生日志，对照事件和 skill 名 |
| 状态恢复 | 合成项目写随机检查编号；恢复→保存→新会话→压缩后回读 | 区分磁盘重读与摘要复述，保留未解决问题 |
| Codex 闭环 | 含明确错误的小草稿，read-only 审查→修改→同线程复审 | 真线程、真裁决、材料变更与停止条件 |
| 原生状态门禁 | start/set/resume/status；接受阶段另行授权 | done、accepted、FAIL 和恢复阶段含义不混淆 |
| 子代理隔离 | 父会话独有随机标记，子代理读指定文档执行唯一命令 | 子上下文不含父标记，结果能回收 |
| 后台/调度 | 短命令完成与取消；Cron 建立/删除和实际唤醒 | 不遗留测试任务；一发唤醒与长期周期稳定性分开 |
| 外部检索 | 选有已知标题/DOI 的论文，检查实际源与网页读取 | 排除无联网工具的记忆回答 |
| 真实知识库读取 | 已知 Hub、主题检索、论文元数据/BibTeX/全文 | 不用真实库试写来证明连通 |

隔离验证目录与会话历史分开。临时目录归档后可清理；正式适配器、配置、追踪与真实科研资产不随测试清理。失败的测试记录保留真实失败，不为了“全通过”改动统计定义。

本次核心合成例中，Codex 常规科研审查仍给出 1/10、not ready；另一个窄范围声明审查只支持固定行数据上的描述性结论。配置成功的依据是闭环能执行和保存裁决，不是逼审查者给出 PASS。

### 10.2 常见故障与正确处理

| 现象 | 本次原因 / 处理 |
|---|---|
| Windows 调 WSL 返回 Wsl/E_ACCESSDENIED | 先区分 Codex 沙箱与主机权限；申请对应执行权限，不据此重装 WSL，不换工具绕过拒绝 |
| 口头说只读，却执行 git clone | clone 会写磁盘；把下载/安装/写配置/启服务/模型调用列入操作影响，按范围批准 |
| 只有 skill 文件，以为 hook/MCP 也装好了 | 分别检查源码、注册、进程和实际效果；安装器范围与文档可选机制分开 |
| 非交互 Shell 找不到 Node，或落到 node.exe | 明确 Linux PATH，MCP 环境单独设置；不要任意改 Windows 环境 |
| uv 在线安装耗时或超时 | 看实际下载进展；可手动下载并拉长 timeout，补齐源码构建包后离线安装；不自动换源 |
| Gemini 登录/地区错误 | 区分过期登录入口与 OpenClash 出站节点问题；使用官方 agy 登录并检查实际网络 |
| Gemini 有回答但没有网页来源 | 确认 search/page 工具真实执行，检查 denied_actions、网页缓存和 URL |
| 两个 skill 共用 SDK，只改一个 | 同时修复上层调用方、专用技能和解释器路径；Exa 的六处调用是典型 |
| Zotero 无附件 / 无正文 | 先查 md5=null，再查真实文件下载，再查索引和路径；不要直接判定全部 MCP 不可用 |
| Obsidian 旧路径找不到 | 从现有目录和项目绑定定位，再由用户确认；不要自动新建旧库 |
| reviewer 模型身份没有后端报告 | 保留请求身份和 unknown/null 字段；不补造服务端身份 |
| evidence_check.py 对 CSV 1.0 返回 value_not_found | 原生保守边界匹配存在适用限制；让审查者回读原 CSV，而非改写数据或静默放宽原生策略 |
| 自动测试与真实 CLI 现象不同 | 优先对实际用户入口采集证据；确实需要时让用户执行明确、最少的测试 prompt |

## 11. 与现有科研项目和知识库的接入原则

### 11.1 本次已确定的分层

```text
F:\Research                         主科研项目
  AGENTS.md                          共用 Agent 入口
  .agents/                           项目地图、三条主线、任务、规则、交接

Zotero                               文献条目、附件、标注、分类、引用

F:\Obsidian Vault\Research\edge-scenario-research
  Sources/Papers/                    一篇论文一份权威笔记，含 Evidence Record
  Knowledge/、Maps/、Writing/…        综合知识、图谱、写作材料

Kimi Scholar / Codex Scholar / ARIS   各自的执行方法与审查流程
```

现有治理明确区分 PROJECT、THESIS、CLASSROOM 三条主线；主仓 main 没有唯一默认任务。对外模型调用要遵守主线的材料边界，公开知识库只放合规公开文献。接入 ARIS 时先读项目规则和目标任务，不把用户级 hook 的“恢复项目”理解成自动选题或启动实验授权。

### 11.2 下一阶段应做的最小接入

1. 只读审查 `/mnt/f/Research/AGENTS.md`、`.agents/context/README.md`、`.agents/tasks/INDEX.md`、`.agents/FRAMEWORK.md` 与相关记录规范。
2. 核对项目级 `.kimi-code`、`.agents/skills` 等是否覆盖用户级同名技能或配置。
3. 选定已有任务作为 ARIS 首个真实任务；按既有 Git/写入占用规则行动。
4. 将 ARIS Pipeline Status、研究契约、findings、审查/实验记录路由到该任务。根入口负责路由，不维护第二份冲突的“唯一当前任务”。
5. 先读现有 Zotero/Obsidian 证据，在小范围真实产物上完成执行—审查—交接—新会话恢复。
6. 接入期间逐项列出持久化修改，让项目治理与 ARIS 输出协议保持一致。

### 11.3 暂不直接执行 research-wiki init

ARIS Research Wiki 原生有 `papers/ideas/experiments/claims/graph`、`edges.jsonl`、query_pack 等结构；当前 Obsidian 已有权威论文笔记和 Evidence Record。直接初始化并全量 ingest，容易产生两份论文解释和两套状态。

优先复用现有笔记；以后需要 ARIS 的想法—实验—声明关系图时，再决定用引用/派生索引接入哪些部分。这个接口尚未实施，不把“Obsidian MCP 已连通”写成“Research Wiki 已融合”。

## 12. 以后改成 Codex 执行、Kimi 审查

这是下一种角色组合的设计路线，本次尚未部署。可复用的是分层方法、外部工具配置、证据与状态约定；执行宿主和 reviewer 调用接口必须重新接好。

### 12.1 可以直接借鉴的部分

- 独立 WSL、单一 ARIS 仓库、凭据隔离、显式 PATH、逐层验收。
- 同一 Zotero 库、Obsidian 库和项目 `.agents` 治理入口。
- DeepXiv/Exa/OpenAlex 的工具与对应 SDK 修复；使用新 HOME 时更新硬编码路径。
- Gemini MCP 后端、Zotero 和 mcpvault 的服务启动参数，可转换为 Codex MCP 配置格式。
- 真实审查原文、声明范围、证据定位、完整性标签、阶段接受门禁、循环上限和错误处理。

### 12.2 应采用 Codex-native 执行基础

ARIS 已有 `skills/skills-codex/`、`tools/install_aris_codex.sh` 和 Claude/Gemini reviewer overlay 示例。原生 Codex 路线中有些审查是同家族子代理，若目标是 Kimi 审查，需要新增或调整 reviewer overlay。

先阅读 `docs/CODEX_CLAUDE_REVIEW_GUIDE.md` 和安装器参数，参照其“基础 skills + 审查覆盖层”的做法。不要把本次 Claude 主体科研 skills 的 Kimi 安装器原封不动改个目录就当作 Codex-native。

### 12.3 Kimi 订阅审查需要一个真实 CLI 适配

优先调查当时 ARIS 是否已有 Kimi CLI reviewer 服务。有就复用；没有则用小型桥接调用 Kimi CLI 的非交互输出与会话恢复，保留以下契约：

- 真实独立进程/上下文，返回实际 session/thread ID 和完整回复。
- 新审查与同线程复审分开；续审保留原模型、工作目录、工具限制和推理设置。
- 明确只读工具集合与文件权限；仅写一段“不要修改”不能代替宿主限制。需要 Shell 时重新评估只读执行边界。
- 审查者配置不再继承可反调执行者的审查 MCP，避免递归互调。
- 支持超时、非零退出、用户取消、限流、认证过期；失败时显式保留 REVIEW_UNAVAILABLE 等状态。
- 记录 executor=openai、reviewer=moonshot 的来源；actual identity 未报告时继续区分请求与报告。

不要为了省事把 Kimi Code 订阅自动换成 Moonshot 按量 API。若采用 API 路线，这是单独的认证、费用与角色适配选择。

### 12.4 需要重做而非复制的部分

| 当前 Kimi 执行的组件 | Codex 执行时的处理 |
|---|---|
| `.kimi-code/skills` 与 Kimi 安装器 | 改用当时 Codex-native 的官方发现与安装方式 |
| `.kimi-code/mcp.json` | 转换到 Codex 的 MCP 配置，保留服务名/接口语义 |
| Kimi hooks 事件、stderr exit 2、Stop 继续机制 | 检查 Codex 当时支持的 lifecycle/notification；不假设同名事件存在 |
| Kimi `path`、`skill-loaded` 日志归一化 | 按 Codex 实际事件格式重写最小归一化层 |
| `mcp__codex__codex` 作为审查入口 | 接入真实 Kimi reviewer 工具，并修改所有实际调用方 |
| Kimi 原生 Agent/后台/Cron | 按 Codex 宿主实际工具做对应验收 |
| 用户级恢复协议 | 保留项目权威状态，按 Codex 指令层级合并，不复制另一份相互竞争的状态 |

新组合从一个带明确错误的合成草稿开始，先跑通 Codex→Kimi→Codex 修改→同会话 Kimi 复审，再进入真实科研任务。

## 13. 已知剩余事项与日常使用

### 13.1 尚未完成/按需配置

- 严格压缩前保存机制；按 skill 动态强制工具限制的完整等价移植。
- 长期 Cron 多次周期触发、退出/恢复后的生命周期及真实长实验监控验收。
- Zotero 语义索引与未索引 PDF 的 Windows 路径备用转换；日志 API await 兼容修复。
- 真实项目的任务路由、Pipeline Status、research contract、产物目录与 Research Wiki 接口。
- Modal、Vast、qzcli、W&B、Overleaf、LaTeX、图像服务等实际账号/依赖；已注册技能不自动获得服务能力。
- 本地补丁向上游提交与升级整合；本次未做。

### 13.2 当前日常入口

从正常 Linux 终端进入目标科研项目，再启动 Kimi；确认本轮目标任务与材料边界。新会话加载最新 MCP 配置。Windows Zotero 保持运行；Obsidian 应用可关闭。

```text
/skill:research-lit 自动驾驶边缘场景生成 — sources: zotero, obsidian
/skill:research-lit 自动驾驶边缘场景生成 — sources: all, exa, deepxiv, openalex, gemini
```

`sources: all` 是本基线的默认源集合，不自动打开所有 opt-in 外部检索源；额外源按名称明确列出。Google 检索登录不等于 Gemini 图像 API 权限，Codex reviewer MCP 也不提供独立图像生成服务。

### 13.3 简单维护顺序

先查看 `git diff` 和版本，再升级；保留这份文档与脱敏适配材料，凭据另行保护。不要用 reset --hard 清掉本地修复，也不要把 symlink 技能目录当成可随意删改的副本。

对一个未知问题，先找最能区分原因的检查：服务是否启动、宿主是否注册、模型是否实际收到提醒、文件是否存在、原始证据是什么。结果有了就修对应一层，不为局部错误重新搭一套框架。

## 14. 来源与历史证据

### 官方/原生资料

- [ARIS 仓库](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep)
- [AGENT_GUIDE](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/AGENT_GUIDE.md)
- [MODEL_COMBINATIONS](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/MODEL_COMBINATIONS.md)
- [SESSION_RECOVERY_GUIDE_CN](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/SESSION_RECOVERY_GUIDE_CN.md)
- [WATCHDOG_GUIDE_CN](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/WATCHDOG_GUIDE_CN.md)
- [PROJECT_FILES_GUIDE_CN](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/PROJECT_FILES_GUIDE_CN.md)
- [Codex + Claude reviewer overlay 示例](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/CODEX_CLAUDE_REVIEW_GUIDE.md)
- [Cursor](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/CURSOR_ADAPTATION.md)、[Copilot](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/COPILOT_CLI_ADAPTATION.md)、[Trae](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/TRAE_ARIS_RUNBOOK_EN.md)、[Antigravity](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/ANTIGRAVITY_ADAPTATION.md) 的适配参考
- [Zotero integration](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/integrations/ZOTERO.md)、[Obsidian integration](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep/blob/main/docs/integrations/OBSIDIAN.md)
- [uv](https://docs.astral.sh/uv/)、[pip download](https://pip.pypa.io/en/stable/cli/pip_download/)
- [Antigravity CLI 安装](https://antigravity.google/docs/cli/tutorial)、[权限](https://antigravity.google/docs/permissions?tab=cli)、[gemini-mcp-tool](https://github.com/jamubc/gemini-mcp-tool)
- [Galaxy-Dawn Zotero MCP](https://github.com/Galaxy-Dawn/zotero-mcp)、[mcpvault](https://github.com/bitbonsai/mcpvault)

上述 main 链接会随上游变化；复现本次行为以第 2 节提交与附录差异为准。

### 本机原始报告

历史工作区：`C:\Users\SuperSASS\Documents\Codex\2026-10-16\windows-wsl2-ubuntu-24-04-aris\outputs\`。

- `ARIS验证报告.html`、`ARIS验证结果.json`、`ARIS验证证据.zip`：初始执行/审查闭环与声明检查。
- `ARIS最小适配.patch`：早期三项补丁；当前完整差异以本 Markdown 附录为准。
- `ARIS-Claude与Kimi-持久化文件对照.html`、`ARIS-持久化文件逐项清单.csv`：当时的持久化影响审计。
- `ARIS-state-trace-verification-20261017.zip`：状态、真实审查、追踪与阶段门禁证据。
- `ARIS-kimi-logging-verification-20261017.zip`、`ARIS-corpus-guard-verification-20261017.zip`、`ARIS-kimi-permissions-verification-20261017.zip`：日志/保护/权限验证。
- `ARIS-Kimi-state-hooks-final-report.html`、`ARIS-Kimi-state-hooks-final-audit.json`、`ARIS-Kimi-state-hooks-evidence-20261017.zip`：正式状态 hooks 与已知差异。
- `ARIS-Kimi-native-host-report.html`、`ARIS-Kimi-native-host-verification.json`、`ARIS-Kimi-native-host-evidence-20261017.zip`：Agent、后台任务与 Cron 原生能力。

这些报告按生成日期理解；本次后续外部工具配置在正文和当前配置附录中续记，没有改写历史报告。

---

# 附录：单文件重建材料

下面保存实际配置的脱敏副本、当前两个适配器源码和本地差异。只需要重建某一部分时，可直接阅读相应区块；完整提取见第 3.3 节。带 `LOCAL_...` 的值必须在本机填入，不是可用凭据。

## A. 当前四个 MCP 服务（已脱敏）

文件：`~/.kimi-code/mcp.json`。凭据占位符必须在本机填入；新机器合并已有条目。

<!-- ARIS-EMBED:mcp.redacted.json -->
```json
{
  "mcpServers": {
    "codex": {
      "command": "/usr/bin/python3",
      "args": [
        "/home/supersass/.aris/aris_repo/mcp-servers/codex-exec/server.py"
      ],
      "toolTimeoutMs": 900000
    },
    "gemini-cli": {
      "command": "/bin/bash",
      "args": [
        "-c",
        "cd /home/supersass/.aris/gemini-search-workspace && exec /home/supersass/.local/share/pnpm/bin/gemini-mcp"
      ],
      "env": {
        "GEMINI_MCP_BACKEND": "agy",
        "AGY_CLI_PATH": "/home/supersass/.local/bin/agy",
        "AGY_PRINT_TIMEOUT": "120s",
        "GEMINI_MCP_TIMEOUT": "3",
        "PATH": "/home/supersass/.nvm/versions/node/v24.22.0/bin:/home/supersass/.local/share/pnpm/bin:/home/supersass/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      },
      "toolTimeoutMs": 180000
    },
    "zotero": {
      "command": "/home/supersass/.local/bin/zotero-mcp",
      "args": [
        "serve"
      ],
      "transport": "stdio",
      "env": {
        "ZOTERO_LOCAL": "true",
        "NO_PROXY": "*",
        "ALL_PROXY": "",
        "FASTMCP_CHECK_FOR_UPDATES": "off",
        "FASTMCP_SHOW_SERVER_BANNER": "false",
        "ZOTERO_API_KEY": "<LOCAL_ZOTERO_API_KEY: do not commit>",
        "ZOTERO_LIBRARY_ID": "<LOCAL_ZOTERO_LIBRARY_ID: do not commit>",
        "ZOTERO_LIBRARY_TYPE": "user",
        "UNPAYWALL_EMAIL": "<LOCAL_UNPAYWALL_EMAIL: do not commit>"
      }
    },
    "obsidian-vault": {
      "command": "/home/supersass/.local/share/pnpm/bin/mcpvault",
      "args": [
        "/mnt/f/Obsidian Vault/Research/edge-scenario-research"
      ],
      "env": {
        "PATH": "/home/supersass/.nvm/versions/node/v24.22.0/bin:/home/supersass/.local/share/pnpm/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```
<!-- ARIS-EMBED:END -->

## B. Kimi hooks TOML

合并到 `~/.kimi-code/config.toml`，不覆盖现有模型和认证设置；先部署下面两个适配脚本。

<!-- ARIS-EMBED:hooks.toml -->
```toml
[[hooks]]
event = "SessionStart"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_meta_log.py"
timeout = 5

[[hooks]]
event = "UserPromptSubmit"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_meta_log.py"
timeout = 5

[[hooks]]
event = "PostToolUse"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_meta_log.py"
timeout = 5

[[hooks]]
event = "PostToolUseFailure"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_meta_log.py"
timeout = 5

[[hooks]]
event = "SessionEnd"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_meta_log.py"
timeout = 5

[[hooks]]
event = "PreToolUse"
matcher = "Bash"
command = "/usr/bin/python3 -B /home/supersass/.aris/aris_repo/templates/claude-hooks/corpus_write_guard.py"
timeout = 5

[[hooks]]
event = "UserPromptSubmit"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_state_hooks.py"
timeout = 5

[[hooks]]
event = "PreToolUse"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_state_hooks.py"
timeout = 5

[[hooks]]
event = "PostToolUse"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_state_hooks.py"
timeout = 5

[[hooks]]
event = "Stop"
command = "/usr/bin/python3 -B /home/supersass/.aris/adapters/kimi_state_hooks.py"
timeout = 5
```
<!-- ARIS-EMBED:END -->

## C. 用户级 AGENTS.md

本次三个受控块的完整内容。新机器若已有 AGENTS.md，按块合并；不要直接覆盖个人规则。

<!-- ARIS-EMBED:AGENTS.kimi.md -->
```markdown
<!-- ARIS-KIMI:BEGIN -->
## ARIS Skill Scope
ARIS skills installed for this user: 60 entries.
Manifest: `/home/supersass/.aris/installed-skills-kimi.txt` (lists every skill ARIS installed and its upstream target).
For ARIS workflows, use the user-level skills under `/home/supersass/.kimi-code/skills/`.
Do not modify or delete files inside any skill that is a symlink (symlinks point into `/home/supersass/.aris/aris_repo`).
Update with: `bash /home/supersass/.aris/install_aris_kimi.sh "/home/supersass" --aris-repo "/home/supersass/.aris/aris_repo" --platform claude --reconcile --no-agent-profiles`  (re-runnable; reconciles new/removed skills).
<!-- ARIS-KIMI:END -->

<!-- ARIS-KIMI-COMPAT:BEGIN -->
## ARIS on Kimi Code

- In ARIS instructions, the project's CLAUDE.md corresponds to
  the project's AGENTS.md on this host.
- When the user requests project initialization, follow
  templates/CLAUDE_MD_TEMPLATE.md and the native session-recovery
  protocol, preserving existing project instructions and artifacts.
- When invoking native state, tracing, or provenance helpers,
  identify the executor as Kimi using their existing parameters
  instead of inheriting Claude defaults.
<!-- ARIS-KIMI-COMPAT:END -->

<!-- ARIS-KIMI-RECOVERY:BEGIN -->
## ARIS State Persistence and Recovery

Update the project's Pipeline Status when:
- The stage changes, an idea is selected, a baseline is confirmed,
  or training starts or ends.
- The user requests saving state or starting a new session.
- Before a long pause or handoff.

After context compaction:
1. Read the project's AGENTS.md and Pipeline Status.
2. Read idea-stage/docs/research_contract.md
   (legacy fallback: docs/research_contract.md).
3. Read recent project findings and relevant workflow state files.
4. If active tasks exist, check their actual status and rebuild monitoring.
5. Resume the appropriate workflow from the recorded state.
<!-- ARIS-KIMI-RECOVERY:END -->
```
<!-- ARIS-EMBED:END -->

## D. 安装器适配补丁

基线是第 2 节的原生 `tools/install_aris.sh`；补丁应用于复制出的 `~/.aris/install_aris_kimi.sh`。

<!-- ARIS-EMBED:install_aris_kimi.patch -->
```diff
--- install_aris.sh
+++ install_aris_kimi.sh
@@ -79,18 +79,18 @@
 
 # ─── Constants ────────────────────────────────────────────────────────────────
 MANIFEST_VERSION="1"
-MANIFEST_NAME="installed-skills.txt"
-MANIFEST_PREV_NAME="installed-skills.txt.prev"
+MANIFEST_NAME="installed-skills-kimi.txt"
+MANIFEST_PREV_NAME="installed-skills-kimi.txt.prev"
 AGENT_MANIFEST_NAME="installed-agent-profiles.txt"
-DECLINED_NAME="skills-declined.txt"
+DECLINED_NAME="skills-declined-kimi.txt"
 CATALOG_REL="tools/skill-groups.tsv"
 GLOBAL_POINTER="$HOME/.aris/repo"
 ARIS_DIR_NAME=".aris"
 LOCK_DIR_NAME=".install.lock.d"
-SKILLS_REL=".claude/skills"
-DOC_FILE_NAME="CLAUDE.md"
-BLOCK_BEGIN="<!-- ARIS:BEGIN -->"
-BLOCK_END="<!-- ARIS:END -->"
+SKILLS_REL=".kimi-code/skills"
+DOC_FILE_NAME=".kimi-code/AGENTS.md"
+BLOCK_BEGIN="<!-- ARIS-KIMI:BEGIN -->"
+BLOCK_END="<!-- ARIS-KIMI:END -->"
 SAFE_NAME_REGEX='^[A-Za-z0-9][A-Za-z0-9._-]*$'
 SUPPORT_NAMES=("shared-references")
 AGENT_PROFILES_SRC=".github/agents"  # Copilot agent profiles deployed alongside skills (F5)
@@ -670,7 +670,7 @@
 # (.aris and .claude/skills may not exist yet — only check if present.)
 check_no_symlinked_parents() {
     local p
-    for p in "$PROJECT_ARIS_DIR" "$PROJECT_PATH/.claude" "$PROJECT_SKILLS_DIR" "$PROJECT_PATH/.github" "$PROJECT_PATH/.github/agents"; do
+    for p in "$PROJECT_ARIS_DIR" "$PROJECT_PATH/.kimi-code" "$PROJECT_SKILLS_DIR" "$PROJECT_PATH/.github" "$PROJECT_PATH/.github/agents"; do
         if is_symlink "$p"; then
             die "S9: $p is a symlink — refusing to install (would mutate symlink target)"
         fi
@@ -1164,20 +1164,20 @@
 # ─── CLAUDE.md best-effort update (compare-and-swap) ──────────────────────────
 update_claude_doc() {
     local installed_names_file="$1"
-    [[ -f "$DOC_FILE" ]] || { log "  (skip CLAUDE.md: file not present)"; return 0; }
     if $NO_DOC; then return 0; fi
 
     local original new_block tmp
-    original="$(cat "$DOC_FILE")"
+    original=""
+    if [[ -f "$DOC_FILE" ]]; then original="$(cat "$DOC_FILE")"; fi
     # Build new block
     local count; count="$(wc -l < "$installed_names_file" | tr -d ' ')"
     new_block="$BLOCK_BEGIN
 ## ARIS Skill Scope
-ARIS skills installed in this project: $count entries.
-Manifest: \`$ARIS_DIR_NAME/$MANIFEST_NAME\` (lists every skill ARIS installed and its upstream target).
-For ARIS workflows, prefer the project-local skills under \`$SKILLS_REL/\` over global skills.
+ARIS skills installed for this user: $count entries.
+Manifest: \`$PROJECT_ARIS_DIR/$MANIFEST_NAME\` (lists every skill ARIS installed and its upstream target).
+For ARIS workflows, use the user-level skills under \`$PROJECT_SKILLS_DIR/\`.
 Do not modify or delete files inside any skill that is a symlink (symlinks point into \`$ARIS_REPO\`).
-Update with: \`bash $ARIS_REPO/tools/install_aris.sh\`  (re-runnable; reconciles new/removed skills).
+Update with: \`bash $HOME/.aris/install_aris_kimi.sh \"$PROJECT_PATH\" --aris-repo \"$ARIS_REPO\" --platform claude --reconcile --no-agent-profiles\`  (re-runnable; reconciles new/removed skills).
 $BLOCK_END"
 
     # Compute new content
@@ -1206,7 +1206,8 @@
     if $DRY_RUN; then log "  (dry-run) would update CLAUDE.md ARIS block"; return 0; fi
     tmp="$DOC_FILE.aris-tmp.$$"
     printf '%s' "$new_content" > "$tmp"
-    local current; current="$(cat "$DOC_FILE")"
+    local current=""
+    if [[ -f "$DOC_FILE" ]]; then current="$(cat "$DOC_FILE")"; fi
     if [[ "$current" != "$original" ]]; then
         rm -f "$tmp"
         warn "CLAUDE.md changed during install — skipping doc update (rerun to retry)"
```
<!-- ARIS-EMBED:END -->

## E. ARIS 仓库内完整本地补丁

包括第 7.1 节全部 9 个文件。与基线提交对应；用户主目录在提取时可替换。

<!-- ARIS-EMBED:aris-local.patch -->
```diff
diff --git a/skills/auto-review-loop/SKILL.md b/skills/auto-review-loop/SKILL.md
index 51de523..c9d3eda 100644
--- a/skills/auto-review-loop/SKILL.md
+++ b/skills/auto-review-loop/SKILL.md
@@ -27,7 +27,7 @@ Autonomously iterate: review → implement fixes → re-review, until an indepen
 - REVIEW_DOC: `review-stage/AUTO_REVIEW.md` (cumulative log) *(fall back to `./AUTO_REVIEW.md` for legacy projects)*
 - REVIEWER_MODEL = `gpt-6-astra` — Default model for the Codex backend. Must be an OpenAI model (e.g., `gpt-6-astra`, `o3`, `gpt-4o`). Manual backend uses a model the user chooses — it must be a recognized model from a different family (OpenAI, Anthropic, Google, DeepSeek, Moonshot/Kimi, Qwen).
 - **REVIEWER_BACKEND** — With no reviewer directive, start as `auto`; Step -1 runs exactly one two-call native marker/challenge probe for the first review. A bound Copilot CLI root session uses `copilot-native` (built-in complementary `rubber-duck` subagent); an unbound/non-Copilot host keeps the existing `codex` default. Explicit `— reviewer: codex`, `oracle-pro`, `agy`, or `manual` bypasses the probe and selects that external backend. Explicit `— reviewer: copilot` retains the compatibility `copilot --agent` drive mode and its later Codex/manual finalizer. The native path gets both actual model IDs from host session events; it never needs `COPILOT_CLI` or caller-provided `--executor-model`. See `shared-references/reviewer-routing.md`.
-- **OUTPUT_DIR = `review-stage/`** — All review-stage outputs go here. Create the directory if it doesn't exist.
+- **OUTPUT_DIR = `review-stage/`** — Review-stage artifacts go here. Cross-stage `CLAIMS_FROM_RESULTS.md`, `findings.md`, and `MANIFEST.md` remain at the project root per the shared output protocols. Create the directory if it doesn't exist.
 - **HUMAN_CHECKPOINT = false** — When `true`, pause after each round's review (Phase B) and present the score + weaknesses to the user. Wait for user input before proceeding to Phase C. The user can: approve the suggested fixes, provide custom modification instructions, skip specific fixes, or stop the loop early. When `false` (default), the loop runs fully autonomously.
 - **COMPACT = false** — When `true`, (1) read `EXPERIMENT_LOG.md` and `findings.md` instead of parsing full logs on session recovery, (2) append key findings to `findings.md` after each round.
 - **REVIEWER_DIFFICULTY = medium** — Controls how adversarial the reviewer is. Three levels:
@@ -945,7 +945,7 @@ When loop ends (positive assessment or max rounds):
 2. Write final summary to `review-stage/AUTO_REVIEW.md`
 3. Update project notes with conclusions
 4. **Write method/pipeline description** to `review-stage/AUTO_REVIEW.md` under a `## Method Description` section — a concise 1-2 paragraph description of the final method, its architecture, and data flow. This serves as input for `/paper-illustration` in Workflow 3 (so it can generate architecture diagrams automatically).
-5. **Generate claims from results** — invoke `/result-to-claim` to convert experiment results from `review-stage/AUTO_REVIEW.md` into structured paper claims. Output: `CLAIMS_FROM_RESULTS.md`. This bridges Workflow 2 → Workflow 3 so `/paper-plan` can directly use validated claims instead of extracting them from scratch. If `/result-to-claim` is not installed, skip this step (no `CLAIMS_FROM_RESULTS.md` is produced; `/paper-plan` extracts claims from the narrative as before) — but NEVER fabricate the file or its verdict. If it ran but its output starts with `verdict: REVIEW_UNAVAILABLE`, keep that file AS-IS (do not overwrite or paraphrase it) and record in `AUTO_REVIEW.md` that claims are UNADJUDICATED — downstream paper stages must not treat them as validated.
+5. **Generate claims from results** — invoke `/result-to-claim` to convert experiment results from `review-stage/AUTO_REVIEW.md` into structured paper claims. Output: project-root `CLAIMS_FROM_RESULTS.md` (the canonical handoff consumed by `/paper-plan`). This bridges Workflow 2 → Workflow 3 so `/paper-plan` can directly use validated claims instead of extracting them from scratch. If `/result-to-claim` is not installed, skip this step (no `CLAIMS_FROM_RESULTS.md` is produced; `/paper-plan` extracts claims from the narrative as before) — but NEVER fabricate the file or its verdict. If it ran but its output starts with `verdict: REVIEW_UNAVAILABLE`, keep that file AS-IS (do not overwrite or paraphrase it) and record in `AUTO_REVIEW.md` that claims are UNADJUDICATED — downstream paper stages must not treat them as validated.
 6. If stopped at max rounds without positive assessment:
    - List remaining blockers
    - Estimate effort needed for each
diff --git a/skills/deepxiv/SKILL.md b/skills/deepxiv/SKILL.md
index f299d5d..e30b895 100644
--- a/skills/deepxiv/SKILL.md
+++ b/skills/deepxiv/SKILL.md
@@ -50,6 +50,14 @@ pip install deepxiv-sdk
 
 On first use, `deepxiv` auto-registers a free token and stores it in `~/.env`.
 
+## Installed SDK compatibility
+
+This installation uses deepxiv-sdk 1.2.1.
+Search uses the service default; do not pass --mode.
+The web/wsearch and sc branches documented below are unavailable in this
+SDK version. Do not execute those commands. Explain the limitation and
+suggest another configured search source or /semantic-scholar instead.
+
 ## Workflow
 
 ### Step 1: Parse Arguments
diff --git a/skills/exa-search/SKILL.md b/skills/exa-search/SKILL.md
index 1da87d7..6b2bb6a 100644
--- a/skills/exa-search/SKILL.md
+++ b/skills/exa-search/SKILL.md
@@ -106,12 +106,12 @@ EXA_FETCHER=".aris/tools/exa_search.py"
 
 **Standard search:**
 ```bash
-python3 "$EXA_FETCHER" search "QUERY" --max 10 --content highlights
+"/home/supersass/.aris/venvs/exa/bin/python" "$EXA_FETCHER" search "QUERY" --max 10 --content highlights
 ```
 
 **With filters:**
 ```bash
-python3 "$EXA_FETCHER" search "QUERY" --max 10 \
+"/home/supersass/.aris/venvs/exa/bin/python" "$EXA_FETCHER" search "QUERY" --max 10 \
   --category "research paper" \
   --start-date 2025-01-01 \
   --content text --max-chars 8000
@@ -119,12 +119,12 @@ python3 "$EXA_FETCHER" search "QUERY" --max 10 \
 
 **Find similar pages:**
 ```bash
-python3 "$EXA_FETCHER" find-similar "URL" --max 5 --content highlights
+"/home/supersass/.aris/venvs/exa/bin/python" "$EXA_FETCHER" find-similar "URL" --max 5 --content highlights
 ```
 
 **Get content for known URLs:**
 ```bash
-python3 "$EXA_FETCHER" get-contents "URL1" "URL2" --content text
+"/home/supersass/.aris/venvs/exa/bin/python" "$EXA_FETCHER" get-contents "URL1" "URL2" --content text
 ```
 
 ### Step 4: Present Results
diff --git a/skills/gemini-search/SKILL.md b/skills/gemini-search/SKILL.md
index b87c4c8..4763ba3 100644
--- a/skills/gemini-search/SKILL.md
+++ b/skills/gemini-search/SKILL.md
@@ -27,90 +27,33 @@ Use Gemini when you want AI-driven discovery that goes beyond keyword matching 
 
 - **MAX_RESULTS = 15** — Target number of papers Gemini should find.
 - **MIN_YEAR = 2022** — Default minimum publication year. Override with `— year: 2020-`.
-- **DEFAULT_MODEL = auto-gemini-3** — Auto-routes within the Gemini 3 family (Pro / Flash) by server-side capacity. Required by `mcp__gemini-cli__ask-gemini` and `gemini-cli` v0.40+; explicit `gemini-3-pro-preview` is **silently downgraded to `gemini-2.5-pro`** on OAuth-personal / Google One AI Pro accounts when capacity is exhausted. Override with `— model: gemini-3-flash-preview` (Gemini 3 Flash explicit, faster, higher quota), or `— model: gemini-2.5-pro` / `gemini-2.5-flash` (legacy, only for users on older `gemini-cli` < v0.40). The MCP tool accepts all of these verbatim.
+- **Model selection** — This installation uses the Antigravity (`agy`) backend through gemini-mcp-tool 1.1.8. Omit the MCP `model` argument: this bridge ignores it. Use the backend default; if a specific model is requested, explain this limitation before running. Do not infer the actual model identity from the bridge notice.
 
 > Overrides (append to arguments):
 > - `/gemini-search "topic" — max: 20` — request up to 20 papers
 > - `/gemini-search "topic" — year: 2020-` — papers from 2020 onward
 > - `/gemini-search "topic" — code-only` — only papers with open-source code
 > - `/gemini-search "topic" — venues: NeurIPS,ICML,ICLR` — focus on specific venues
-> - `/gemini-search "topic" — model: gemini-3-flash-preview` — Gemini 3 Flash (faster, higher quota, less capable than Pro)
-> - `/gemini-search "topic" — model: auto-gemini-3` — auto-routes within the Gemini 3 family by load
-> - `/gemini-search "topic" — model: gemini-2.5-pro` — legacy (only if your `gemini-cli` < v0.40)
 
 ## Environment & Setup
 
-### Prerequisites
+This WSL installation uses Antigravity CLI (`agy`) with Google account
+sign-in and the installed `gemini-mcp-tool` bridge. Gemini CLI personal-account
+sign-in was retired; use `agy` for authentication and CLI fallback.
+
+- CLI: `/home/supersass/.local/bin/agy`
+- MCP entry: `gemini-cli` in `/home/supersass/.kimi-code/mcp.json`
+- Backend: `GEMINI_MCP_BACKEND=agy`
+- Search working directory: `/home/supersass/.aris/gemini-search-workspace`
+- Web access: `permissions.allow` includes `read_url(*)` in
+  `/home/supersass/.gemini/antigravity-cli/settings.json`.
+- Use `ask-gemini` with `sandbox: true`. The bridge forwards `--sandbox`;
+  its legacy capability warning describes older agy versions.
+- Other available MCP tools: `ping`, `Help`, `brainstorm`, `fetch-chunk`.
+  `sandbox-test` is not provided by this installed bridge.
 
-1. **Node.js** v16.0.0+
-2. **Google Gemini CLI** — installed and authenticated
-   ```bash
-   npm install -g @google/gemini-cli
-   gemini auth
-   ```
-3. **gemini-mcp-tool** — MCP bridge for Claude Code ([jamubc/gemini-mcp-tool](https://github.com/jamubc/gemini-mcp-tool))
-   ```bash
-   npm install -g gemini-mcp-tool
-   ```
-
-### MCP Configuration
-
-In `~/.claude.json` (or `%APPDATA%\Claude\claude_desktop_config.json` for Claude Desktop), add:
-
-```json
-{
-  "mcpServers": {
-    "gemini-cli": {
-      "command": "gemini-mcp"
-    }
-  }
-}
-```
-
-Alternative via `npx` (auto-install):
-```json
-{
-  "mcpServers": {
-    "gemini-cli": {
-      "command": "npx",
-      "args": ["-y", "gemini-mcp-tool"]
-    }
-  }
-}
-```
-
-Or one-line setup:
 ```bash
-claude mcp add gemini-cli -- npx -y gemini-mcp-tool
-```
-
-### Authentication
-
-Gemini CLI uses your Google account or an API key. Add to `.claude/.env`:
-
-```bash
-# .claude/.env
-GEMINI_API_KEY=your-key-here
-```
-
-Claude Code automatically loads `.claude/.env` as environment variables.
-
-- Free key from [Google AI Studio](https://aistudio.google.com/apikey)
-- Flash model (`gemini-2.5-flash`) has a generous free tier (500 req/min)
-
-### Available MCP Tools
-
-| Tool | Parameters | Description |
-|------|-----------|-------------|
-| `mcp__gemini-cli__ask-gemini` | `prompt` (required), `model` (optional), `sandbox` (optional) | Ask Gemini for analysis or research; supports `@file` syntax |
-| `mcp__gemini-cli__sandbox-test` | `prompt` (required), `model` (optional) | Safe code execution in sandbox |
-| `mcp__gemini-cli__ping` | — | Connection test |
-| `mcp__gemini-cli__help` | — | Show Gemini CLI help |
-
-### Verify Setup
-
-```bash
-gemini --version
+agy --version
 ```
 
 ## Workflow
@@ -123,7 +66,7 @@ Parse `$ARGUMENTS` for:
 - **year**: Minimum publication year (e.g., `2020-`)
 - **code-only**: Only include papers with open-source code
 - **venues**: Comma-separated venue filter
-- **model**: Override DEFAULT_MODEL
+- **model**: If specified, report that this installed MCP bridge ignores model selection; do not silently substitute.
 
 ### Step 2: Execute Search (MCP Priority)
 
@@ -140,6 +83,7 @@ IMPORTANT CONSTRAINTS:
 2. Prefer papers that are genuinely relevant, not merely keyword-adjacent.
 3. Include top venues, journals, surveys, recent preprints, and papers with code when available.
 4. Focus on papers from MIN_YEAR onward unless older foundational work is necessary.
+5. Use web search and page-reading tools and include source URLs. Report denied or unavailable tools. You may read the web-content cache files returned by the web tools. Do not read unrelated local files, modify project files, execute shell commands, or invoke subagents.
 
 For EACH paper found, provide ALL of the following in this exact format:
 - Title: [exact title]
@@ -158,25 +102,22 @@ Find at least MAX_RESULTS papers with good coverage across:
 - closely related variants of the topic
 
 Format as a numbered list with all fields for each paper.',
-  model: 'auto-gemini-3'
+  sandbox: true
 })
 ```
 
-**Priority 2 — Gemini CLI fallback** (if MCP unavailable):
+**Priority 2 — Antigravity CLI fallback** (if MCP unavailable):
 
-If `mcp__gemini-cli__ask-gemini` fails or is not configured, fall back to CLI:
+Run the same search prompt in the dedicated search directory:
 
 ```bash
-gemini -p 'You are a research literature scout. Search comprehensively for papers on: "QUERY"
-...same prompt as above...' 2>/dev/null
+(cd /home/supersass/.aris/gemini-search-workspace && /home/supersass/.local/bin/agy --sandbox --output-format json --print-timeout 120s -p '...same search prompt...')
 ```
 
-- **Timeout**: 120 seconds
-- **Stderr**: Pipe to `/dev/null` — contains hook warnings, not part of the response
-
-**When to use which:**
-- MCP is preferred because it integrates natively with Claude Code's tool system, handles model selection, and avoids shell escaping issues.
-- CLI fallback ensures the skill works even when MCP is not configured or the MCP server process has crashed.
+Read the JSON `response`; report `error` or `denied_actions` when present.
+Keep stderr visible for authentication, quota and permission errors.
+Use a 180-second host timeout. If no usable response is returned, report
+this source as unavailable and follow the alternative-source rules below.
 
 ### Step 3: Parse Results
 
@@ -223,9 +164,9 @@ After presenting results, suggest:
 
 ## Key Rules
 
-- **MCP first, CLI second.** Always try `mcp__gemini-cli__ask-gemini` before falling back to `gemini -p`.
+- **MCP first, CLI second.** Always try `mcp__gemini-cli__ask-gemini` before falling back to `agy --sandbox --output-format json -p`.
 - **Gemini is a discovery source, not a database.** Its results may include papers it "knows about" from training data. Always cross-verify critical details (exact titles, venues, years) via `/semantic-scholar` or `/arxiv` when precision matters.
 - **Do not use Gemini for citation counts.** It may hallucinate citation numbers. Use Semantic Scholar for authoritative citation data.
-- **Pipe stderr to `/dev/null` in CLI mode** — Gemini CLI emits hook warnings on stderr.
-- **Timeout generously in CLI mode** — Gemini's thorough search can take 30-60 seconds. Set timeout to 120s.
+- Preserve CLI errors and permission denials; do not discard stderr.
+- CLI timeout: 120 seconds internally, 180 seconds for the host tool.
 - If both MCP and CLI are unreachable, suggest using `/semantic-scholar`, `/arxiv`, or `/research-lit "topic" — sources: web` as alternatives.
diff --git a/skills/research-lit/SKILL.md b/skills/research-lit/SKILL.md
index f76d4db..6b2d0fc 100644
--- a/skills/research-lit/SKILL.md
+++ b/skills/research-lit/SKILL.md
@@ -2,7 +2,7 @@
 name: research-lit
 description: Search and analyze research papers, find related work, summarize key ideas. Use when user says "find papers", "related work", "literature review", "what does this paper say", or needs to understand academic papers.
 argument-hint: "[paper-topic-or-url]"
-allowed-tools: Bash(*), Read, Glob, Grep, WebSearch, WebFetch, Write, Agent, mcp__zotero__*, mcp__obsidian-vault__*
+allowed-tools: Bash(*), Read, Glob, Grep, WebSearch, WebFetch, Write, Agent, mcp__zotero__*, mcp__obsidian-vault__*, mcp__gemini-cli__*
 ---
 
 # Research Literature Review
@@ -72,7 +72,7 @@ Examples:
 | 5 | **Semantic Scholar API** | `semantic-scholar` | `$S2_FETCHER` resolves (canonical name `semantic_scholar_fetch.py`, per integration-contract §2) | Published venue papers (IEEE, ACM, Springer) with structured metadata: citation counts, venue info, TLDR. **Only runs when explicitly requested** via `— sources: semantic-scholar` or `— sources: web, semantic-scholar` |
 | 6 | **DeepXiv CLI** | `deepxiv` | `$DEEPXIV_FETCHER` resolves (canonical name `deepxiv_fetch.py`, per integration-contract §2) **and** `deepxiv` CLI present (`command -v deepxiv`) | Progressive paper retrieval: search, brief, head, section, trending, web search. **Only runs when explicitly requested** via `— sources: deepxiv` or `— sources: all, deepxiv` |
 | 7 | **Exa Search** | `exa` | `$EXA_FETCHER` resolves (canonical name `exa_search.py`, per integration-contract §2); fetcher handles `exa-py` SDK + API key internally | AI-powered broad web search with content extraction (highlights, text, summaries). Covers blogs, docs, news, companies, and research papers beyond arXiv/S2. **Only runs when explicitly requested** via `— sources: exa` or `— sources: all, exa` |
-| 8 | **Gemini** (MCP / CLI) | `gemini` | `mcp__gemini-cli__ask-gemini` tool available, or `gemini` CLI installed | AI-powered broad literature discovery — decomposes topics into sub-problems, aliases, and variants for wider retrieval. Prefers MCP, falls back to CLI. **Only runs when explicitly requested** via `— sources: gemini` or `— sources: all, gemini` |
+| 8 | **Gemini** (MCP / CLI) | `gemini` | `mcp__gemini-cli__ask-gemini` tool available, or `agy` CLI installed | AI-powered broad literature discovery — decomposes topics into sub-problems, aliases, and variants for wider retrieval. Prefers MCP, falls back to CLI. **Only runs when explicitly requested** via `— sources: gemini` or `— sources: all, gemini` |
 | 9 | **OpenAlex** | `openalex` | `$OPENALEX_FETCHER` resolves (canonical name `openalex_fetch.py`, per integration-contract §2) **and** Python `requests` module importable | Open citation graph with institutional affiliations, funding data, and comprehensive metadata across 250M+ works. Fully open API. **Only runs when explicitly requested** via `— sources: openalex` or `— sources: all, openalex` |
 
 > **Graceful degradation**: If no MCP servers are configured, the skill works exactly as before (local PDFs + web search). Zotero and Obsidian are pure additions.
@@ -323,13 +323,13 @@ if [ -n "$EXA_FETCHER" ]; then
   # Search for research papers with highlights.
   # Wrap with if/then/else so set -e doesn't abort the SKILL.
   exa_contributed=false
-  if python3 "$EXA_FETCHER" search "QUERY" --max 10 --category "research paper" --content highlights; then
+  if "/home/supersass/.aris/venvs/exa/bin/python" "$EXA_FETCHER" search "QUERY" --max 10 --category "research paper" --content highlights; then
     exa_contributed=true
   else
     echo "WARN: exa_search.py research-paper invocation failed; D2 aggregate continues." >&2
   fi
   # Search for broader web content (blogs, docs, news)
-  if python3 "$EXA_FETCHER" search "QUERY" --max 10 --content highlights; then
+  if "/home/supersass/.aris/venvs/exa/bin/python" "$EXA_FETCHER" search "QUERY" --max 10 --content highlights; then
     exa_contributed=true
   else
     echo "WARN: exa_search.py broad-web invocation failed; D2 aggregate continues." >&2
@@ -362,6 +362,7 @@ IMPORTANT CONSTRAINTS:
 2. Prefer papers that are genuinely relevant, not merely keyword-adjacent.
 3. Include top venues, journals, surveys, recent preprints, and papers with code when available.
 4. Focus on papers from 2022 onward unless older foundational work is necessary.
+5. Use web search and page-reading tools and include source URLs. Report denied or unavailable tools. You may read the web-content cache files returned by the web tools. Do not read unrelated local files, modify project files, execute shell commands, or invoke subagents.
 
 For EACH paper found, provide ALL of the following:
 - Title: [exact title]
@@ -374,11 +375,23 @@ For EACH paper found, provide ALL of the following:
 - Summary: [one-sentence core contribution]
 
 Find at least 15 papers.',
-  model: 'auto-gemini-3'
+  sandbox: true
 })
 ```
 
-**Priority 2 — Gemini CLI fallback** (if MCP unavailable): Use `gemini -p "...same prompt..." 2>/dev/null` via Bash (timeout: 120s).
+The installed MCP uses `GEMINI_MCP_BACKEND=agy`. Omit `model`: this bridge
+ignores model selection. If the user requests a specific model, explain
+that limitation before running. Pass `sandbox: true`.
+
+**Priority 2 — Antigravity CLI fallback** (if MCP unavailable):
+
+```bash
+(cd /home/supersass/.aris/gemini-search-workspace && /home/supersass/.local/bin/agy --sandbox --output-format json --print-timeout 120s -p '...same search prompt...')
+```
+
+Use a 180-second host timeout. Read JSON `response`; report `error` or
+`denied_actions` and keep stderr visible. An empty or denied response does
+not contribute to the aggregate.
 
 If both MCP and CLI are unavailable, skip this source gracefully and continue with the remaining requested sources.
 
diff --git a/skills/result-to-claim/SKILL.md b/skills/result-to-claim/SKILL.md
index 248e59d..401091a 100644
--- a/skills/result-to-claim/SKILL.md
+++ b/skills/result-to-claim/SKILL.md
@@ -195,6 +195,10 @@ else:
 
 See `shared-references/experiment-integrity.md` for the full integrity protocol.
 
+**Required handoff artifact.** Before routing, write the normalized verdict, claim scope, evidence paths, and integrity label to project-root `CLAIMS_FROM_RESULTS.md`, not `review-stage/CLAIMS_FROM_RESULTS.md`. This is the canonical cross-stage input consumed by `/paper-plan`.
+
+Write the actual adjudication for `yes`, `partial`, and `no`; preserve the existing single-line `verdict: REVIEW_UNAVAILABLE` rule when no reviewer verdict is available.
+
 ### Step 4: Route Based on Verdict
 
 #### `no` — Claim not supported
diff --git a/tools/deepxiv_fetch.py b/tools/deepxiv_fetch.py
index 598bd59..269e89e 100644
--- a/tools/deepxiv_fetch.py
+++ b/tools/deepxiv_fetch.py
@@ -71,7 +71,7 @@ def build_parser() -> argparse.ArgumentParser:
     search.add_argument("--max", type=int, default=10, dest="max_results")
     search.add_argument(
         "--mode",
-        default="hybrid",
+        default=None,
         choices=("bm25", "vector", "hybrid"),
     )
     search.add_argument("--categories")
@@ -128,13 +128,13 @@ def build_parser() -> argparse.ArgumentParser:
 
 def _dispatch_json(args: argparse.Namespace) -> dict | list:
     if args.command == "search":
+        if args.mode is not None:
+            raise RuntimeError("deepxiv-sdk 1.2.1 does not support --mode; omit it to use the service default.")
         cli_args = [
             "search",
             args.query,
             "--limit",
             str(args.max_results),
-            "--mode",
-            args.mode,
             "--format",
             "json",
         ]
diff --git a/tools/exa_search.py b/tools/exa_search.py
index 131af87..f31594d 100644
--- a/tools/exa_search.py
+++ b/tools/exa_search.py
@@ -238,7 +238,7 @@ def get_contents(
     """Retrieve content for specific URLs."""
     client = _get_client()
 
-    kwargs: dict[str, Any] = {"ids": urls}
+    kwargs: dict[str, Any] = {"urls": urls}
     kwargs.update(_build_content_kwargs(content_mode, max_chars))
 
     response = client.get_contents(**kwargs)
diff --git a/tools/save_trace.sh b/tools/save_trace.sh
index 1def610..e39581c 100755
--- a/tools/save_trace.sh
+++ b/tools/save_trace.sh
@@ -97,6 +97,8 @@ if re.search(r"(^|[^a-z0-9])(claude|sonnet|opus|haiku|anthropic)([^a-z0-9]|$)",
     families.add("anthropic")
 if re.search(r"(^|[^a-z0-9])(gemini|google)([^a-z0-9]|$)", name):
     families.add("google")
+if re.search(r"(^|[^a-z0-9])(kimi|moonshot)[0-9.]*([^a-z0-9]|$)", name):
+    families.add("moonshot")
 print(next(iter(families)) if len(families) == 1 else "unknown")
 '
 }
```
<!-- ARIS-EMBED:END -->

## F. Kimi 日志适配器

目标：`~/.aris/adapters/kimi_meta_log.py`。

<!-- ARIS-EMBED:kimi_meta_log.py -->
```python
import json
import os
import pathlib
import subprocess
import sys

NATIVE = "/home/supersass/.aris/aris_repo/tools/meta_opt/log_event.sh"

def normalize_skill_prompt(prompt):
    import html
    import re
    import xml.etree.ElementTree as ET

    if not isinstance(prompt, str):
        return prompt
    match = re.match(
        r'\AUser activated the skill "([^"\n]*)"\. Follow the loaded skill instructions\.\n\n'
        r'(<skill-loaded\b[^>]*>)',
        prompt,
    )
    if not match:
        return prompt
    try:
        tag = ET.fromstring(match.group(2)[:-1] + " />")
    except ET.ParseError:
        return prompt
    name = tag.get("name", "")
    if (
        tag.get("trigger") != "user-slash"
        or not name
        or any(char.isspace() for char in name)
        or html.unescape(match.group(1)) != name
    ):
        return prompt
    args = tag.get("args", "").strip()
    return "/" + name + (" " + args if args else "")

def main():
    try:
        payload = json.load(sys.stdin)
    except (ValueError, TypeError):
        return 0
    if not isinstance(payload, dict):
        return 0
    cwd = payload.get("cwd")
    if not isinstance(cwd, str) or not pathlib.Path(cwd).is_absolute():
        return 0
    ROOT = pathlib.Path(cwd).resolve()
    if not ROOT.is_dir():
        return 0

    tool_input = payload.get("tool_input")
    if isinstance(tool_input, dict):
        if "file_path" not in tool_input and isinstance(tool_input.get("path"), str):
            tool_input["file_path"] = tool_input["path"]

    prompt = payload.get("prompt")
    if isinstance(prompt, list):
        payload["prompt"] = "\n".join(
            item["text"] for item in prompt
            if isinstance(item, dict) and isinstance(item.get("text"), str)
        )

    if payload.get("hook_event_name") == "UserPromptSubmit":
        payload["prompt"] = normalize_skill_prompt(payload.get("prompt"))

    env = os.environ.copy()
    env["CLAUDE_PROJECT_DIR"] = str(ROOT)
    result = subprocess.run(
        ["/bin/bash", NATIVE],
        input=json.dumps(payload, ensure_ascii=False),
        text=True, env=env, cwd=str(ROOT), timeout=4
    )
    return result.returncode

if __name__ == "__main__":
    sys.exit(main())
```
<!-- ARIS-EMBED:END -->

## G. Kimi 状态与 meta 提醒适配器

目标：`~/.aris/adapters/kimi_state_hooks.py`。

<!-- ARIS-EMBED:kimi_state_hooks.py -->
```python
"""Kimi state reminders adapted from ARIS; see limitations below.
Native reference: SESSION_RECOVERY_GUIDE_CN.md and check_ready.sh.
Refresh/progress reminders are deferred to Stop, NOT mid-turn refresh.
No pre-compaction save guarantee. Notifications are not completion evidence.
"""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

STATE_DIR = Path('/home/supersass/.aris/state/kimi-hooks')
META_SCRIPT = '/home/supersass/.aris/aris_repo/tools/meta_opt/check_ready.sh'
STATE_NAMES = {'AGENTS.md', 'CLAUDE.md', 'IDEA_REPORT.md', 'AUTO_REVIEW.md',
               'REVIEW_STATE.json', 'EXPERIMENT_TRACKER.md', 'research_contract.md', 'findings.md'}
RECOVERY = ('[ARIS recovery] Read the current project AGENTS.md Pipeline Status, '
            'idea-stage/docs/research_contract.md (legacy: docs/research_contract.md), '
            'recent findings and relevant workflow state files. Recover the recorded stage, '
            'unresolved issues and next step. Distinguish recorded task status from live verification. '
            'Check active tasks and restore monitoring only within the user-authorized scope. '
            'Do not create missing project files or start work merely because of this reminder.')

def initial():
    return dict(tools=0, writes=0, refreshed=0, progress_notified=0,
                recovered=False, stop_sent=False, meta_signature=None)

def transition(state, payload, meta_text='', meta_epoch=''):
    """Return (stdout context, stderr block reason). Caller persists notification state."""
    event = payload.get('hook_event_name')
    if event == 'UserPromptSubmit':
        state['stop_sent'] = False
        if not state['recovered']:
            state['recovered'] = True
            return RECOVERY, ''
    elif event == 'PreToolUse':
        state['tools'] += 1
    elif event == 'PostToolUse' and payload.get('tool_name') in ('Write', 'Edit'):
        args = payload.get('tool_input') or {}
        name = Path(str(args.get('path') or args.get('file_path') or '')).name
        if name and name not in STATE_NAMES:
            state['writes'] += 1
    elif event == 'Stop' and not state['stop_sent']:
        messages = []
        refresh_bucket = state['tools'] // 30
        write_bucket = state['writes'] // 10
        if refresh_bucket > state['refreshed']:
            messages.append('[ARIS context refresh] Re-read the project Pipeline Status and reconcile it '
                            'with current work before finishing. This reminder does not require an edit '
                            'when the recorded state is already current.')
            state['refreshed'] = refresh_bucket
        if write_bucket > state['progress_notified']:
            messages.append('[ARIS progress] At least ten additional non-state Write/Edit operations '
                            'have completed. If there is substantive progress, update Pipeline Status '
                            'and EXPERIMENT_TRACKER.md as appropriate. Preserve unresolved issues; '
                            'do not invent results or create unrelated files.')
            state['progress_notified'] = write_bucket
        signature = hashlib.sha256((meta_epoch + '\n' + meta_text).encode()).hexdigest() if meta_text else None
        if signature and signature != state['meta_signature']:
            messages.append('[ARIS meta readiness]\n' + meta_text + '\nNotify the user only; '
                            'this suggestion does not authorize running meta-optimize or applying changes.')
            state['meta_signature'] = signature
        if messages:
            state['stop_sent'] = True
            messages.append('Follow the current user restrictions. If saving or reading is disallowed, '
                            'report the pending work instead. Do not bypass tool restrictions. '
                            'This notification is not proof that state was saved.')
            return '', '\n\n'.join(messages)
    return '', ''

def meta_readiness(cwd):
    env = os.environ.copy()
    env['CLAUDE_PROJECT_DIR'] = str(cwd)
    result = subprocess.run(['/bin/bash', META_SCRIPT], cwd=cwd, env=env,
                            text=True, capture_output=True, timeout=3)
    if result.returncode:
        raise RuntimeError('Native meta readiness check failed: ' + result.stderr[:300])
    text = result.stdout.strip()
    # Counts changing from 5 to 6 must not produce another readiness reminder.
    # Native messages remain verbatim; stable conditions define the notification key.
    conditions = []
    if 'skill runs since last optimization' in text:
        conditions.append('usage-threshold')
    if 'Model changed since last optimization' in text:
        conditions.extend(line for line in text.splitlines() if 'Model changed' in line)
    meta = cwd / '.aris/meta'
    epoch = '\n'.join((meta / name).read_text() if (meta / name).exists() else ''
                      for name in ('.last_optimize', '.last_optimize_model'))
    return text, epoch, '|'.join(conditions)

def main():
    payload = json.load(sys.stdin)
    if not payload.get('cwd') or not payload.get('session_id'):
        return 0
    cwd = Path(payload['cwd']).resolve()
    payload['cwd'] = str(cwd)
    key = hashlib.sha256((payload['cwd'] + '\n' + payload['session_id']).encode()).hexdigest()[:24]
    folder = STATE_DIR
    folder.mkdir(parents=True, exist_ok=True)
    with (folder / (key + '.lock')).open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        path = folder / (key + '.json')
        state = json.loads(path.read_text()) if path.exists() else initial()
        text = epoch = condition = ''
        if payload.get('hook_event_name') == 'Stop':
            text, epoch, condition = meta_readiness(cwd)
        # Use stable readiness identity for deduplication while preserving native text.
        out, error = transition(state, payload, condition, epoch)
        if condition and '[ARIS meta readiness]' in error:
            error = error.replace('[ARIS meta readiness]\n' + condition,
                                  '[ARIS meta readiness]\n' + text, 1)
        tmp = path.with_suffix('.tmp')
        tmp.write_text(json.dumps(state, indent=2))
        tmp.replace(path)
    if out:
        print(out)
    if error:
        print(error, file=sys.stderr)
        return 2
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
```
<!-- ARIS-EMBED:END -->

## H. 完整技能选择

59 个技能；安装器另行处理 shared-references。该名单用于第 3.3 节的 --skills。

<!-- ARIS-EMBED:skills-selected.txt -->
```text
ablation-planner
alphaxiv
analyze-results
arxiv
auto-paper-improvement-loop
auto-review-loop
citation-audit
deepxiv
dse-loop
exa-search
experiment-audit
experiment-bridge
experiment-plan
experiment-queue
figure-spec
formula-derivation
gemini-search
idea-creator
idea-discovery
integrity-forensics
kill-argument
mermaid-diagram
meta-apply
meta-optimize
monitor-experiment
novelty-check
openalex
overleaf-sync
paper-claim-audit
paper-compile
paper-figure
paper-illustration-image2
paper-illustration
paper-plan
paper-write
paper-writing
proof-checker
proof-writer
qzcli
rebuttal
render-html
research-implement-feature
research-lit
research-pipeline
research-refine-pipeline
research-refine
research-review
research-wiki
resubmit-pipeline
result-to-claim
run-experiment
semantic-scholar
serverless-modal
system-profile
training-check
vast-gpu
web-debug-search
wiki-enrich
writing-systems-papers
```
<!-- ARIS-EMBED:END -->

未注册的 25 个技能：

<!-- ARIS-EMBED:skills-declined.txt -->
```text
auto-review-loop-llm
auto-review-loop-minimax
claims-drafting
comm-lit-review
embodiment-description
feishu-notify
figure-description
grant-proposal
idea-discovery-robot
interview-cheatsheet
invention-structuring
jurisdiction-format
lean-formalize
paper-poster
paper-poster-html
paper-slides
paper-talk
patent-novelty-check
patent-pipeline
patent-review
pixel-art
prior-art-search
proof-orchestrator
slides-polish
specification-writing
```
<!-- ARIS-EMBED:END -->

## I. 本次安装清单快照

用于核对 symlink 源、目标和安装范围；新机器让安装器重新生成自己的清单，不直接覆盖新清单。

<!-- ARIS-EMBED:installed-skills-kimi.snapshot.tsv -->
```tsv
version	1
repo_root	/home/supersass/.aris/aris_repo
project_root	/home/supersass
generated	2026-10-15T19:24:24Z
kind	name	source_rel	target_rel	mode
skill	ablation-planner	skills/ablation-planner	.kimi-code/skills/ablation-planner	symlink
skill	alphaxiv	skills/alphaxiv	.kimi-code/skills/alphaxiv	symlink
skill	analyze-results	skills/analyze-results	.kimi-code/skills/analyze-results	symlink
skill	arxiv	skills/arxiv	.kimi-code/skills/arxiv	symlink
skill	auto-paper-improvement-loop	skills/auto-paper-improvement-loop	.kimi-code/skills/auto-paper-improvement-loop	symlink
skill	auto-review-loop	skills/auto-review-loop	.kimi-code/skills/auto-review-loop	symlink
skill	citation-audit	skills/citation-audit	.kimi-code/skills/citation-audit	symlink
skill	deepxiv	skills/deepxiv	.kimi-code/skills/deepxiv	symlink
skill	dse-loop	skills/dse-loop	.kimi-code/skills/dse-loop	symlink
skill	exa-search	skills/exa-search	.kimi-code/skills/exa-search	symlink
skill	experiment-audit	skills/experiment-audit	.kimi-code/skills/experiment-audit	symlink
skill	experiment-bridge	skills/experiment-bridge	.kimi-code/skills/experiment-bridge	symlink
skill	experiment-plan	skills/experiment-plan	.kimi-code/skills/experiment-plan	symlink
skill	experiment-queue	skills/experiment-queue	.kimi-code/skills/experiment-queue	symlink
skill	figure-spec	skills/figure-spec	.kimi-code/skills/figure-spec	symlink
skill	formula-derivation	skills/formula-derivation	.kimi-code/skills/formula-derivation	symlink
skill	gemini-search	skills/gemini-search	.kimi-code/skills/gemini-search	symlink
skill	idea-creator	skills/idea-creator	.kimi-code/skills/idea-creator	symlink
skill	idea-discovery	skills/idea-discovery	.kimi-code/skills/idea-discovery	symlink
skill	integrity-forensics	skills/integrity-forensics	.kimi-code/skills/integrity-forensics	symlink
skill	kill-argument	skills/kill-argument	.kimi-code/skills/kill-argument	symlink
skill	mermaid-diagram	skills/mermaid-diagram	.kimi-code/skills/mermaid-diagram	symlink
skill	meta-apply	skills/meta-apply	.kimi-code/skills/meta-apply	symlink
skill	meta-optimize	skills/meta-optimize	.kimi-code/skills/meta-optimize	symlink
skill	monitor-experiment	skills/monitor-experiment	.kimi-code/skills/monitor-experiment	symlink
skill	novelty-check	skills/novelty-check	.kimi-code/skills/novelty-check	symlink
skill	openalex	skills/openalex	.kimi-code/skills/openalex	symlink
skill	overleaf-sync	skills/overleaf-sync	.kimi-code/skills/overleaf-sync	symlink
skill	paper-claim-audit	skills/paper-claim-audit	.kimi-code/skills/paper-claim-audit	symlink
skill	paper-compile	skills/paper-compile	.kimi-code/skills/paper-compile	symlink
skill	paper-figure	skills/paper-figure	.kimi-code/skills/paper-figure	symlink
skill	paper-illustration-image2	skills/paper-illustration-image2	.kimi-code/skills/paper-illustration-image2	symlink
skill	paper-illustration	skills/paper-illustration	.kimi-code/skills/paper-illustration	symlink
skill	paper-plan	skills/paper-plan	.kimi-code/skills/paper-plan	symlink
skill	paper-write	skills/paper-write	.kimi-code/skills/paper-write	symlink
skill	paper-writing	skills/paper-writing	.kimi-code/skills/paper-writing	symlink
skill	proof-checker	skills/proof-checker	.kimi-code/skills/proof-checker	symlink
skill	proof-writer	skills/proof-writer	.kimi-code/skills/proof-writer	symlink
skill	qzcli	skills/qzcli	.kimi-code/skills/qzcli	symlink
skill	rebuttal	skills/rebuttal	.kimi-code/skills/rebuttal	symlink
skill	render-html	skills/render-html	.kimi-code/skills/render-html	symlink
skill	research-implement-feature	skills/research-implement-feature	.kimi-code/skills/research-implement-feature	symlink
skill	research-lit	skills/research-lit	.kimi-code/skills/research-lit	symlink
skill	research-pipeline	skills/research-pipeline	.kimi-code/skills/research-pipeline	symlink
skill	research-refine-pipeline	skills/research-refine-pipeline	.kimi-code/skills/research-refine-pipeline	symlink
skill	research-refine	skills/research-refine	.kimi-code/skills/research-refine	symlink
skill	research-review	skills/research-review	.kimi-code/skills/research-review	symlink
skill	research-wiki	skills/research-wiki	.kimi-code/skills/research-wiki	symlink
skill	resubmit-pipeline	skills/resubmit-pipeline	.kimi-code/skills/resubmit-pipeline	symlink
skill	result-to-claim	skills/result-to-claim	.kimi-code/skills/result-to-claim	symlink
skill	run-experiment	skills/run-experiment	.kimi-code/skills/run-experiment	symlink
skill	semantic-scholar	skills/semantic-scholar	.kimi-code/skills/semantic-scholar	symlink
skill	serverless-modal	skills/serverless-modal	.kimi-code/skills/serverless-modal	symlink
skill	system-profile	skills/system-profile	.kimi-code/skills/system-profile	symlink
skill	training-check	skills/training-check	.kimi-code/skills/training-check	symlink
skill	vast-gpu	skills/vast-gpu	.kimi-code/skills/vast-gpu	symlink
skill	web-debug-search	skills/web-debug-search	.kimi-code/skills/web-debug-search	symlink
skill	wiki-enrich	skills/wiki-enrich	.kimi-code/skills/wiki-enrich	symlink
skill	writing-systems-papers	skills/writing-systems-papers	.kimi-code/skills/writing-systems-papers	symlink
support	shared-references	skills/shared-references	.kimi-code/skills/shared-references	symlink
```
<!-- ARIS-EMBED:END -->

## J. Antigravity 设置快照

文件：`~/.gemini/antigravity-cli/settings.json`。快照仅供对照；通常只合并 permissions.allow，trustedWorkspaces 和配色由新机器自己选择。登录材料不在本区块中。

<!-- ARIS-EMBED:agy-settings.reference.json -->
```json
{
  "colorScheme": "tokyo night",
  "permissions": {
    "allow": [
      "read_url(*)"
    ]
  },
  "trustedWorkspaces": [
    "/home/supersass"
  ]
}
```
<!-- ARIS-EMBED:END -->

