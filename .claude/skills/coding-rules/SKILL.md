---
name: coding-rules
description: このSalesforceプロジェクトでApex・トリガー・LWC・フロー・SOQLを書く、直す、リファクタリングするときに必ず使う社内規約。ガバナ制限、一括処理、共有ルールと項目権限、命名、テストカバレッジ、組織の使い分けを定める。「Apexを書いて」「トリガーを作って」「LWCを作って」「修正して」などの依頼で使う。
---

# Salesforce 開発のコーディング規約

コードを書く前にこの規約を読み、書き終えたら末尾のチェックで自己確認する。
規約と既存コードが食い違う場合は、勝手にどちらかに寄せず、ユーザーに確認する。
作り方の詳細（テンプレートや手順）は公式スキル（platform-apex-generate など）に従い、
この規約はそれより優先される社内ルールとして扱う。

見本: `force-app/main/default/classes/AccountRatingService.cls` とそのテストクラス。

## 1. ガバナ制限（最優先）

Salesforce は1回の処理で使える量に上限がある。超えると処理全体が失敗する。

- **ループの中で SOQL・DML を書かない。** 先に Set/Map に集めて、ループの外で1回だけ実行する
- **常に200件まとめて来る前提で書く。** トリガーは最大200件ずつ呼ばれる
- 大量データは `Database.QueryLocator` を使うバッチ Apex にする
- SOQL は必要な項目だけ取得する（`SELECT *` 相当の書き方はしない）

## 2. セキュリティ

- クラスは原則 `with sharing`。`without sharing` を使うときはコメントで理由を書き、レビューで確認を取る
- SOQL には `WITH USER_MODE`、DML には `AccessLevel.USER_MODE` を使い、項目・オブジェクト権限を守る
- ユーザー入力を SOQL に文字列連結しない。バインド変数（`:value`）を使う
- IDやURL、メールアドレスをコードに直書きしない。カスタムメタデータかカスタム設定に置く

## 3. トリガー

- **1オブジェクトにトリガーは1つだけ。** 中身は書かず、ハンドラークラスに処理を渡す
- トリガー名: `<オブジェクト名>Trigger`、ハンドラー: `<オブジェクト名>TriggerHandler`
- 再帰で何度も動かないよう、ハンドラー側で制御する

## 4. 命名

| 種類 | ルール | 例 |
|---|---|---|
| クラス | PascalCase、役割を末尾に | `AccountRatingService`, `OpportunitySelector` |
| テストクラス | 対象クラス名 + `Test` | `AccountRatingServiceTest` |
| メソッド・変数 | camelCase、メソッドは動詞から | `applyRatings`, `accountIds` |
| 定数 | UPPER_SNAKE_CASE | `HOT_THRESHOLD` |
| カスタム項目 | 英語の PascalCase + `__c`、表示ラベルは日本語 | `ContractRank__c`（契約ランク） |
| LWC | camelCase のフォルダ名 | `accountRatingCard` |

## 5. テスト

- **カバレッジ75%以上は本番デプロイの最低条件。社内目標は85%以上**
- 数字合わせではなく、結果を `Assert` で確認する（`Assert.areEqual` など）
- 1件だけでなく **200件の一括テスト** を必ず入れる
- 境界値（null、0、閾値ちょうど）をテストする
- テストデータはテスト内で作る。`@IsTest(SeeAllData=true)` は使わない
- 実行: `sf apex run test --target-org <開発組織> --code-coverage --result-format human --wait 10`

## 6. LWC

- Salesforce の標準コンポーネント（`lightning-*`）を優先し、独自CSSは最小限にする
- データ取得は Lightning Data Service（`@wire`）を優先し、Apex 呼び出しは必要なときだけ
- 画面を作ったら experience-lwc-security-validate スキルでセキュリティを確認する

## 7. フローとApexの使い分け

- 単純な項目更新・通知・画面入力はフローで作る（管理者でも保守できる）
- 複雑な計算・大量データ・外部連携はApexで作る
- 同じオブジェクトで、フローとトリガーの両方が同じ項目を更新しないようにする

## 8. 組織の使い分け（重要）

| 組織 | 別名（alias）の付け方 | AIが触ってよいか |
|---|---|---|
| スクラッチ組織 | `scratch-<名前>` | 自由に使ってよい |
| Sandbox（開発・検証） | `dev-<名前>` / `uat` | デプロイ・テストOK |
| 本番 | 必ず `prod` を含める（例: `prod`, `prod-main`） | **検証（--dry-run）以外は禁止** |

- コマンドでは必ず `--target-org <別名>` を付けて、どの組織に対する操作か明示する
- 本番への反映は人がリリース手順に沿って行う（フックでも止めている）

## 書き終えたらのチェック

- [ ] ループ内に SOQL・DML がないか
- [ ] 200件まとめて来ても動くか
- [ ] `with sharing` と USER_MODE になっているか
- [ ] 直書きされたID・URL・メールアドレスがないか
- [ ] テストで Assert しているか、一括テストと境界値テストがあるか
- [ ] dx-code-analyzer-run スキルで静的解析を実行し、重大な指摘がないか
