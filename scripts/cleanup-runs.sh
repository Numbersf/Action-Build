#!/usr/bin/env bash
# Cleanup helper for GitHub Actions runs.
# Usage: cleanup-runs.sh <validate|delete-by-target|cancel-active|delete-by-conclusion|self-history|summary>
# Env: REPO, GH_TOKEN, GITHUB_STEP_SUMMARY, CURRENT_RUN_ID, WORKFLOW_NAME, COUNT (0 = unlimited),
# TARGET_RUN_NUMBERS, TARGET_RUN_IDS, DELETE_FAILED, DELETE_SUCCESS, DELETE_CANCELLED, REVERSE_ORDER
set -e

COUNT="${COUNT:-0}"

wf_id() {
  gh api --paginate "repos/$REPO/actions/workflows?per_page=100" --jq '.workflows[] | [.id, .name] | @tsv' | awk -F'\t' -v n="$1" '$2==n{id=$1} END{print id}'
}

require_wf_id() {
  local id
  id=$(wf_id "$1")
  if [ -z "$id" ]; then
    echo "❌ 找不到工作流: $1" >&2
    exit 1
  fi
  echo "$id"
}

list_runs() {
  gh api --paginate "repos/$REPO/actions/workflows/$1/runs?per_page=100${2:-}" --jq '.workflow_runs[] | [.id, .run_number, .status, (.conclusion // "-")] | join(" ")'
}

api_one() {
  local method="$1" suffix="$2" id="$3" out i
  for i in 1 2 3 4; do
    if out=$(gh api -X "$method" "repos/$REPO/actions/runs/$id$suffix" 2>&1); then
      echo "OK $id"
      return 0
    fi
    if grep -qiE 'rate limit|secondary|429|abuse' <<<"$out"; then
      sleep $((i * 10))
    else
      break
    fi
  done
  echo "FAIL $id ${out:0:100}"
}

delete_run() { api_one DELETE "" "$1"; }
cancel_run() { api_one POST "/cancel" "$1"; }
export -f api_one delete_run cancel_run


run_in_parallel() {
  local log ok fail
  log=$(mktemp)
  xargs -r -n1 -P 6 bash -c '"$0" "$1"' "$2" | tee "$log" | grep '^FAIL' || true
  ok=$(grep -c '^OK' "$log" || true)
  fail=$(grep -c '^FAIL' "$log" || true)
  echo "$1: 成功 $ok，失败 $fail"
  echo "| $1 | $ok | $fail |" >> "$RUNNER_TEMP/cleanup-rows.md"
}

limit_file() {
  if [ "$COUNT" -gt 0 ]; then
    head -n "$COUNT" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
  fi
}

validate() {
  local pair value
  for pair in "target_run_numbers=$TARGET_RUN_NUMBERS" "target_run_ids=$TARGET_RUN_IDS"; do
    value="${pair#*=}"
    if [[ -n "$value" && ! "$value" =~ ^[0-9\ \#,]+$ ]]; then
      echo "❌ ${pair%%=*} 包含非法值: '$value'（必须为纯数字，逗号分隔）"
      exit 1
    fi
  done
  if [[ ! "$COUNT" =~ ^[0-9]*$ ]]; then
    echo "❌ count 必须为非负整数（0 = 不限制）"
    exit 1
  fi
  echo "✅ 输入校验通过"
}

summary() {
  {
    echo "### 🧹 清理结果汇总"
    echo ""
    echo "| 项目 | 成功 | 失败 |"
    echo "|---|---|---|"
    cat "$RUNNER_TEMP/cleanup-rows.md" 2>/dev/null || true
  } >> "$GITHUB_STEP_SUMMARY"
}

delete_by_target() {
  local numbers wid
  if [ -n "$TARGET_RUN_IDS" ]; then
    echo "$TARGET_RUN_IDS" | tr -d ' ' | tr ',' '\n' | grep -E '^[0-9]+$' | run_in_parallel "按 Run-ID 删除" delete_run
  fi
  if [ -n "$TARGET_RUN_NUMBERS" ]; then
    numbers=$(echo "$TARGET_RUN_NUMBERS" | tr -d ' #')
    wid=$(require_wf_id "$WORKFLOW_NAME")
    # One pass over the list matches every requested number; unfinished runs are skipped.
    list_runs "$wid" | awk -v nums=",$numbers," '
      index(nums, ","$2",") {
        if ($3 == "completed") print $1
        else print "跳过运行中 #" $2 > "/dev/stderr"
      }' | run_in_parallel "按运行编号删除" delete_run
  fi
}

cancel_active() {
  local wid status
  wid=$(require_wf_id "$WORKFLOW_NAME")
  for status in in_progress queued waiting; do
    list_runs "$wid" "&status=$status"
  done | awk -v cur="$CURRENT_RUN_ID" '$1 != cur {print $1}' | run_in_parallel "取消运行" cancel_run
}

delete_by_conclusion() {
  local conclusions=() pattern wid runs ids
  if [ "$DELETE_FAILED" = "true" ]; then conclusions+=("failure"); fi
  if [ "$DELETE_SUCCESS" = "true" ]; then conclusions+=("success"); fi
  if [ "$DELETE_CANCELLED" = "true" ]; then conclusions+=("cancelled"); fi
  pattern="^($(IFS='|'; echo "${conclusions[*]}"))$"

  wid=$(require_wf_id "$WORKFLOW_NAME")
  runs=$(mktemp)
  ids=$(mktemp)
  list_runs "$wid" | awk -v cur="$CURRENT_RUN_ID" '$1 != cur' > "$runs"
  if [ "$REVERSE_ORDER" = "true" ]; then
    tac "$runs" > "$runs.tmp" && mv "$runs.tmp" "$runs"
  fi
  limit_file "$runs"
  awk -v re="$pattern" '$4 ~ re {print $1}' "$runs" > "$ids"
  echo "按顺序取 $(wc -l < "$runs") 条，其中匹配 $(wc -l < "$ids") 条待删除（${conclusions[*]}，上限: $COUNT）"
  run_in_parallel "批量删除" delete_run < "$ids"
}

self_history() {
  local wid ids
  wid=$(gh api "repos/$REPO/actions/runs/$CURRENT_RUN_ID" --jq .workflow_id)
  ids=$(mktemp)
  list_runs "$wid" | awk -v cur="$CURRENT_RUN_ID" '$3 == "completed" && $1 != cur {print $1}' > "$ids"
  limit_file "$ids"
  run_in_parallel "清理自身记录" delete_run < "$ids"
}

case "$1" in
  validate) validate ;;
  delete-by-target) delete_by_target ;;
  cancel-active) cancel_active ;;
  delete-by-conclusion) delete_by_conclusion ;;
  self-history) self_history ;;
  summary) summary ;;
  *)
    echo "用法: $0 <validate|delete-by-target|cancel-active|delete-by-conclusion|self-history|summary>" >&2
    exit 2
    ;;
esac