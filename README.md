# AIDevTest（Salesforce × Claude Code）

Claude Code で **Salesforce 開発** を AI 駆動で行うための本番用テンプレートリポジトリです。
Salesforce 公式スキルと、進め方のスキル、社内規約、ガードレール（安全装置）を Git で管理しています。

## はじめに用意するもの

| ツール | 何のため |
|---|---|
| [Claude Code](https://claude.com/claude-code) | AIに開発を頼むためのツール |
| [Salesforce CLI（sf）](https://developer.salesforce.com/tools/salesforcecli) | Salesforce の組織とやり取りするためのコマンド |
| [Node.js（LTS）](https://nodejs.org) | Salesforce の MCP サーバーと一部のスキルが使う |
| Python 3.8 以上 | 安全装置（フック）と一部のスキルが使う |
| Git | このリポジトリを取得・更新する |

## 使い方

```bash
git clone https://github.com/iku198/AIDevTest.git
cd AIDevTest

# 開発用の組織にログインし、別名を付ける（本番ではなく Sandbox かスクラッチ組織）
sf org login web --alias dev-yourname --instance-url https://test.salesforce.com
sf config set target-org dev-yourname

claude    # Claude Code を起動
```

初回起動時は「このフォルダを信頼するか」と「Salesforce の MCP サーバーを使うか」を聞かれます。どちらも許可してください。

あとは日本語で頼むだけです。例:「取引先に契約ランクの項目を追加して、年間売上から自動で決まるようにして」

## 構成

| 場所 | 役割 |
|---|---|
| `CLAUDE.md` | AI が常に守る前提（Salesforce 専用、組織の使い分けなど） |
| `force-app/main/default/` | Salesforce のソース（Apex、LWC、項目、フローなど） |
| `.claude/skills/` | 作業ごとの手順書（スキル）。Salesforce 公式17件＋進め方14件＋自作2件 |
| `.claude/skills/SOURCES.md` | 外部スキルの出所・コミット・ライセンス |
| `.claude/settings.json` / `.claude/hooks/` | 安全装置。本番組織への変更や危険な git 操作を止める |
| `.mcp.json` | Salesforce 公式の MCP サーバー設定（AI が組織を直接操作するための接続口） |
| `.github/workflows/` | PR ごとの自動チェック（静的解析、セキュリティレビュー、デプロイ検証） |

## 組織の別名ルール

| 組織 | 別名 | AI が触ってよいか |
|---|---|---|
| スクラッチ組織 | `scratch-<名前>` | 自由に使ってよい |
| Sandbox | `dev-<名前>` / `uat` | デプロイ・テスト OK |
| 本番 | `prod` を含める | 検証（`--dry-run`）以外は自動で止まる |

## スキルを追加・更新するルール

1. `chore/skills-xxx` ブランチを切る
2. 外部スキルは **コピーして取り込む**（プラグイン直入れはしない）
3. `SOURCES.md` に出所・コミット・ライセンス・社内での変更点を書く
4. PR を出し、SKILL.md と同梱スクリプトの中身を必ずレビューしてからマージ
