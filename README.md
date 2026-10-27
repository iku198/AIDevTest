# my-product

Claude Code で AI駆動開発を行うためのサンプル本番リポジトリです。
開発の7つのゲート（要件→設計→実装→テスト→レビュー→出荷→運用）ごとに、
公開スキルと自作スキルを `.claude/skills/` に入れて Git で管理しています。

## 使い方

```bash
git clone <このリポジトリ>
cd my-product
claude          # Claude Code を起動すると .claude/skills/ のスキルが自動で読み込まれる
```

スキルは依頼内容に合わせて自動で呼ばれます。明示したいときは `/test-driven-development` のようにスラッシュで呼べます。

## 構成

| 場所 | 役割 |
|---|---|
| `CLAUDE.md` | 常に守ってほしい前提（全作業共通） |
| `.claude/skills/` | 作業ごとの手順書（スキル） |
| `.claude/skills/SOURCES.md` | 外部スキルの出所・コミット・ライセンス |
| `.claude/settings.json` | 権限とフック（危険な操作を物理的に止める） |
| `.claude/hooks/` | フックのスクリプト |
| `.github/workflows/` | PRごとのセキュリティレビュー（CI） |

## スキルを追加・更新するルール

1. `chore/skills-xxx` ブランチを切る
2. 外部スキルは **コピーして取り込む**（プラグイン直入れはしない）
3. `SOURCES.md` に出所・コミット・ライセンス・社内での変更点を書く
4. PR を出し、SKILL.md と同梱スクリプトの中身を必ずレビューしてからマージ
