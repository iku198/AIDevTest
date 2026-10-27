#!/usr/bin/env bash
# Claude Code の PreToolUse フック（入口）。中身は guard.py。
# git の危険操作、本番組織へのデプロイ・データ更新、MCP からの本番接続を止める。
exec python3 "$(dirname "$0")/guard.py"
