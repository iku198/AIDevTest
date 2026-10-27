# プロジェクトの前提（Claude Code 向け）

- 回答・コミットメッセージ・PR説明は日本語で書く
- 実装の前に計画を作り、ユーザーの確認を取る（brainstorming → writing-plans の順）
- 新しい処理はテストを先に書く（test-driven-development）
- 「完了」と言う前にテストを実行し、結果を示す（verification-before-completion）
- コーディング規約は coding-rules スキルに従う
- 本番環境へのデプロイ、`main` への直接 push、強制 push は行わない（フックでも止めている）
- `.env` や秘密情報は読まない・出力しない
