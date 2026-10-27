---
name: pre-pr-review
description: プルリクエストを作る前、または「レビューして」「PR出す前に確認して」「プルリク作って」と言われたときに使う。Salesforceの変更差分（Apex・LWC・フロー・メタデータ）を社内規約とチェックリストで確認し、Apexテスト・静的解析・デプロイ検証を実行してから、PRの説明文の下書きを作る。
---

# PR前セルフレビュー（Salesforce）

## 手順

1. `git diff main...HEAD --stat` と `git diff main...HEAD` で変更内容を確認する
2. `checklist.md` の観点で1つずつチェックする
3. 次のコマンドを実行し、結果をそのまま示す（`<開発組織>` は scratch- か dev- で始まる別名）
   - 静的解析: dx-code-analyzer-run スキルの手順で `sf code-analyzer run --rule-selector Recommended` を実行
   - Apexテスト: `sf apex run test --target-org <開発組織> --code-coverage --result-format human --wait 10`
   - デプロイ検証: `sf project deploy start --dry-run --source-dir force-app --target-org <開発組織> --wait 30`
4. 指摘を「必須修正」「推奨」に分けて報告する
5. 共有設定・権限・外部連携・Apexの `without sharing` に関わる変更があれば、differential-review スキルでもセキュリティ観点を確認する
6. 必須修正がなければ、下の型で PR の説明文の下書きを作る

## 注意

- 勝手にコードを修正しない。修正は指摘してから確認を取る
- `main` へ直接 push しない。PR は作業ブランチから作る
- 本番組織（別名に prod を含む）には、検証も含めてこのスキルからは何も実行しない

## PR説明文の型

```markdown
## 何を変えたか
（1〜3行。追加・変更したメタデータの種類も書く：Apexクラス、項目、フローなど）

## なぜ変えたか
（背景・関連Issue）

## 確認したこと
- [ ] Apexテスト: 成功 ◯件 / 失敗 0件、カバレッジ ◯%
- [ ] 静的解析（Code Analyzer）: 重大な指摘なし
- [ ] デプロイ検証（--dry-run）: 成功（対象組織: ◯◯）
- [ ] 画面での動作確認: （該当する場合、組織名と確認した手順）

## リリース時の注意
（手動で行う設定、権限セットの割り当て、データ移行があれば）
```
