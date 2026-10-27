# プロジェクトの前提（Claude Code 向け）

このリポジトリは **Salesforce 開発専用** です（Salesforce DX 形式、Apex・LWC・フロー）。

## 進め方
- 回答・コミットメッセージ・PR説明は日本語で書く
- 実装の前に計画を作り、ユーザーの確認を取る（brainstorming → writing-plans の順）
- 新しい Apex はテストクラスを先に書く（test-driven-development、platform-apex-test-generate）
- 「完了」と言う前に Apex テストと静的解析を実行し、結果を示す（verification-before-completion）
- コードは coding-rules スキルの規約に従う。作り方の詳細は platform-* / experience-* / automation-* の公式スキルに従う

## 場所
- ソースは `force-app/main/default/` 以下（classes, triggers, lwc, objects, flows, permissionsets）
- 見本コード: `force-app/main/default/classes/AccountRatingService.cls`

## 組織（org）のルール
- 別名の付け方: スクラッチ組織 `scratch-<名前>`、Sandbox `dev-<名前>` / `uat`、本番は必ず `prod` を含める
- sf コマンドでは必ず `--target-org <別名>` を付ける
- **本番組織にはデプロイ・データ変更・匿名 Apex を実行しない。** 本番に対して行ってよいのは `--dry-run` の検証だけ（フックでも止めている）
- 既定の組織（`sf config set target-org`）には本番を設定しない

## 禁止事項
- `main` への直接 push、強制 push
- `.env`、`.sf/`、`.sfdx/`、認証URL などの秘密情報を読む・出力する
