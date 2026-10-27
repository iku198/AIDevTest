# 外部スキルの出所一覧

外部から取り込んだスキルは、ここに必ず1行ずつ記録する。更新するときは同じ表の「取り込んだコミット」を書き換え、PRで差分をレビューする。

| スキル | 取得元 | 取り込んだコミット | 取得日 | ライセンス | 担当ゲート |
|---|---|---|---|---|---|
| brainstorming | [obra/superpowers](https://github.com/obra/superpowers) `skills/brainstorming` | 2ce8aa15d05bd57213e6f746f953aafb7ded7a8b | 2026-10-28 | MIT | ① 要件 |
| writing-plans | obra/superpowers `skills/writing-plans` | 同上 | 2026-10-28 | MIT | ② 設計 |
| using-git-worktrees | obra/superpowers `skills/using-git-worktrees` | 同上 | 2026-10-28 | MIT | ② 設計 |
| executing-plans | obra/superpowers `skills/executing-plans` | 同上 | 2026-10-28 | MIT | ③ 実装 |
| subagent-driven-development | obra/superpowers `skills/subagent-driven-development` | 同上 | 2026-10-28 | MIT | ③ 実装 |
| test-driven-development | obra/superpowers `skills/test-driven-development` | 同上 | 2026-10-28 | MIT | ④ テスト |
| systematic-debugging | obra/superpowers `skills/systematic-debugging` | 同上 | 2026-10-28 | MIT | ④ テスト |
| verification-before-completion | obra/superpowers `skills/verification-before-completion` | 同上 | 2026-10-28 | MIT | ④ テスト |
| requesting-code-review | obra/superpowers `skills/requesting-code-review` | 同上 | 2026-10-28 | MIT | ⑤ レビュー |
| receiving-code-review | obra/superpowers `skills/receiving-code-review` | 同上 | 2026-10-28 | MIT | ⑤ レビュー |
| finishing-a-development-branch | obra/superpowers `skills/finishing-a-development-branch` | 同上 | 2026-10-28 | MIT | ⑥ 出荷 |
| writing-skills | obra/superpowers `skills/writing-skills` | 同上 | 2026-10-28 | MIT | 横断（スキル作成） |
| skill-creator | [anthropics/skills](https://github.com/anthropics/skills) `skills/skill-creator` | dbd4588f9e1033efb41dad4bef2f7947c8993d44 | 2026-10-28 | Apache-2.0 | 横断（スキル作成） |
| differential-review | [trailofbits/skills](https://github.com/trailofbits/skills) `plugins/differential-review/skills/differential-review` | bf23bfb21f10a2a4b0406086d690dc8cb1b3ccf3 | 2026-10-28 | CC-BY-SA-4.0（© Trail of Bits） | ⑤ レビュー（セキュリティ） |

各スキルのフォルダに、取得元の `LICENSE`（skill-creator は `LICENSE.txt`）を同梱している。

## 社内での変更点

- obra/superpowers の各スキル内にある `superpowers:xxx` という参照を `xxx` に置換（プラグインではなくプロジェクトのスキルとして読み込むため）
- differential-review から Codex 用メタデータ `agents/openai.yaml` を削除（Claude Code では不要）
- 上記以外は無改変

## レビューで確認したこと

- brainstorming の `scripts/` は画面プレビュー用のローカルサーバー（既定で 127.0.0.1 のみで待ち受け）。外部への通信はない
- systematic-debugging の `find-polluter.sh` はテストを1件ずつ実行して原因を探すだけのスクリプト
- differential-review は CC-BY-SA-4.0 のため、改変して社外に再配布する場合は同じライセンスでの公開と出典表示が必要（社内利用のみなら問題なし）

## 取り込みを見送ったもの

| 候補 | 理由 |
|---|---|
| trailofbits/skills の ask-questions-if-underspecified | 取得時点の main に存在しなかった |
| Code-Shock/claude-skills の git-guardrails | ライセンス表記がなく再配布できないため、同等のフックを自作（`.claude/hooks/guard.sh`） |
| tilomitra/release-kit, wshobson/agents の運用系 | 今回は最小構成のため未導入。必要になったら同じ手順で追加 |

## 更新手順

```bash
git checkout -b chore/skills-update-YYYYMMDD
git clone --depth=1 https://github.com/obra/superpowers /tmp/superpowers
diff -r /tmp/superpowers/skills/test-driven-development .claude/skills/test-driven-development
# 差分を確認してからコピー → 上の「社内での変更点」を再適用 → この表のコミットを更新 → PR
```
