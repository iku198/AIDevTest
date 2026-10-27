#!/usr/bin/env python3
"""Claude Code の PreToolUse フック。

Bash コマンドと Salesforce DX MCP ツールを実行前に検査し、危険な操作を止める。
終了コード 2 で止めると、標準エラーの内容が Claude に理由として伝わる。

組織の別名ルール（CLAUDE.md と coding-rules スキルに記載）:
  本番は別名に prod を含める（prod, prod-main など）。
  スクラッチ組織は scratch-、Sandbox は dev- / uat。
"""
import json
import re
import sys

PROD = re.compile(r"(^|[^a-z0-9])(prod|production)([^a-z0-9]|$)|本番", re.I)
ORG_FLAG = re.compile(r"(?:--target-org|--targetusername|-o|-u)(?:\s+|=)['\"]?([^\s'\"]+)")

RULE_HINT = "このリポジトリのルール（CLAUDE.md）で禁止されている操作です。必要な場合は人が手で実行してください。"


def block(reason: str) -> None:
    print(f"ブロックしました: {reason}", file=sys.stderr)
    print(RULE_HINT, file=sys.stderr)
    sys.exit(2)


def check_git(cmd: str) -> None:
    if re.search(r"git\s+push(\s.*)?\s(-f|--force|--force-with-lease)(\s|=|$)", cmd):
        block("強制 push（git push --force）")
    if re.search(r"git\s+push(\s.*)?\s(origin\s+)?(HEAD:)?(main|master)(\s|$)", cmd):
        block("main への直接 push。作業ブランチから PR を作ってください")
    if re.search(r"git\s+(reset\s+--hard|clean\s+-[a-zA-Z]*f|branch\s+-D)", cmd):
        block("作業内容を消す git 操作（reset --hard / clean -f / branch -D）")


def check_salesforce(cmd: str) -> None:
    if not re.search(r"(^|[\s;&|(])(sf|sfdx)\s", cmd):
        return

    orgs = ORG_FLAG.findall(cmd)
    targets_prod = any(PROD.search(o) for o in orgs)

    is_deploy = re.search(r"\b(project\s+deploy\s+(start|resume|quick)|force:source:deploy|force:mdapi:deploy|force:source:push|project\s+delete\s+source)\b", cmd)
    is_validate = re.search(r"\bproject\s+deploy\s+validate\b", cmd) or "--dry-run" in cmd or "--checkonly" in cmd.lower()
    is_data_write = re.search(r"\bdata\s+(delete|update|upsert|import|create|record\s+(create|update|delete))\b|\bforce:data:", cmd)
    is_anon_apex = re.search(r"\bapex\s+run(?!\s+test)\b|force:apex:execute", cmd)
    is_org_delete = re.search(r"\b(org\s+delete|force:org:delete)\b", cmd)
    mutates = bool((is_deploy and not is_validate) or is_data_write or is_anon_apex or is_org_delete)

    if "--purge-on-delete" in cmd or re.search(r"destructiveChanges", cmd):
        block("メタデータの完全削除（--purge-on-delete / destructiveChanges）")

    if is_org_delete and not all(o.startswith("scratch-") for o in orgs or ["?"]):
        block("組織の削除。削除してよいのは scratch- で始まるスクラッチ組織だけです")

    if targets_prod and mutates:
        block("本番組織への変更（デプロイ・データ更新・匿名Apex）。本番は --dry-run の検証だけ許可しています")

    if mutates and not orgs:
        block("対象組織が指定されていません。--target-org <別名> を付けて、どの組織への操作か明示してください")


def check_mcp(tool_name: str, tool_input) -> None:
    values = []

    def walk(node, key=""):
        if isinstance(node, dict):
            for k, v in node.items():
                walk(v, k)
        elif isinstance(node, list):
            for v in node:
                walk(v, key)
        elif isinstance(node, str) and re.search(r"org|username|alias", key, re.I):
            values.append(node)

    walk(tool_input)
    if any(PROD.search(v) for v in values):
        block(f"本番組織に対する MCP ツール（{tool_name}）の実行。MCP からは本番に接続しません")


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool = data.get("tool_name", "")
    tool_input = data.get("tool_input") or {}

    if tool == "Bash":
        cmd = tool_input.get("command", "") or ""
        check_git(cmd)
        check_salesforce(cmd)
        if re.search(r"(npm|pnpm|yarn)\s+run\s+deploy(:prod)?", cmd):
            block("本番環境へのデプロイスクリプト")
    elif tool.startswith("mcp__salesforce_dx__"):
        check_mcp(tool, tool_input)

    sys.exit(0)


if __name__ == "__main__":
    main()
