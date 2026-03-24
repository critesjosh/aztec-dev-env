#!/usr/bin/env bash

input=$(cat)

# Workspace name
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // .cwd // empty')
workspace_name=$(basename "$project_dir")
workspace_part="[${workspace_name}]"

# Model display name
model_name=$(echo "$input" | jq -r '.model.display_name // empty')

# Context window progress bar
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  bar_total=15
  filled=$(( used_int * bar_total / 100 ))
  empty_blocks=$(( bar_total - filled ))
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty_blocks); do bar="${bar}░"; done
  context_part="${bar} ${used_int}%"
else
  context_part="░░░░░░░░░░░░░░░ 0%"
fi

# Current working subdirectory
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$project_dir" ] && [ -n "$cwd" ]; then
  rel=$(echo "$cwd" | sed "s|^${project_dir}||" | sed 's|^/||')
  if [ -z "$rel" ]; then
    subdir=$(basename "$cwd")
  else
    subdir=$(echo "$rel" | cut -d'/' -f1)
  fi
else
  subdir=$(basename "$cwd")
fi

# Git branch and file change stats
git_part=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  diff_stat=$(git -C "$cwd" diff --no-lock-index --stat HEAD 2>/dev/null | tail -1)
  if [ -n "$diff_stat" ]; then
    num_files=$(echo "$diff_stat" | grep -oP '^\s*\K[0-9]+(?= file)')
    added=$(echo "$diff_stat" | grep -oP '[0-9]+(?= insertion)' || echo "0")
    removed=$(echo "$diff_stat" | grep -oP '[0-9]+(?= deletion)' || echo "0")
    [ -z "$num_files" ] && num_files=0
    [ -z "$added" ] && added=0
    [ -z "$removed" ] && removed=0
    git_part="(${branch} | ${num_files} files +${added} -${removed})"
  else
    git_part="(${branch})"
  fi
fi

# Assemble output
parts="${workspace_part} | ${model_name} | ${context_part} | ${subdir}"
if [ -n "$git_part" ]; then
  parts="${parts} | ${git_part}"
fi

echo "$parts"
