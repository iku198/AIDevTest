#!/usr/bin/env bash
# Claude Code の PreToolUse フック（Bash ツール用）
# 危険な git 操作と本番デプロイを実行前にブロックする。
# 終了コード 2 で止めると、標準エラーの内容が Claude に理由として伝わる。

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
else
  cmd="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))')"
fi

[ -z "$cmd" ] && exit 0

block() {
  echo "ブロックしました: $1" >&2
  echo "このリポジトリのルール（CLAUDE.md）で禁止されている操作です。必要な場合は人が手で実行してください。" >&2
  exit 2
}

# 強制 push
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push([[:space:]].*)?[[:space:]](-f|--force|--force-with-lease)([[:space:]=]|$)'; then
  block "強制 push（git push --force）"
fi

# main / master への直接 push
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push([[:space:]].*)?[[:space:]](origin[[:space:]]+)?(HEAD:)?(main|master)([[:space:]]|$)'; then
  block "main への直接 push。作業ブランチから PR を作ってください"
fi

# 作業内容を消す操作
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+(reset[[:space:]]+--hard|clean[[:space:]]+-[a-zA-Z]*f|branch[[:space:]]+-D)'; then
  block "作業内容を消す git 操作（reset --hard / clean -f / branch -D）"
fi

# 本番デプロイ
if printf '%s' "$cmd" | grep -Eiq '(npm|pnpm|yarn)[[:space:]]+run[[:space:]]+deploy(:prod)?|vercel[[:space:]].*--prod|terraform[[:space:]]+(apply|destroy)|kubectl[[:space:]].*(prod|production)'; then
  block "本番環境へのデプロイ・インフラ変更"
fi

exit 0
