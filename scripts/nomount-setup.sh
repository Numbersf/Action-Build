#!/usr/bin/env bash
#
# NoMount source integration helpers. Sourced, not executed.
# Depends on lib/git-helpers.sh and lib/kernel-helpers.sh.
#

insert_line_before_last_match() {
  local file="$1"
  local match_line="$2"
  local insert_line="$3"
  local tmp_file

  grep -qxF "$insert_line" "$file" && return 0
  tmp_file="$(mktemp)"
  awk -v match_line="$match_line" -v insert_line="$insert_line" '
    { lines[NR] = $0 }
    $0 == match_line { last_match = NR }
    END {
      if (!last_match) exit 1
      for (i = 1; i <= NR; i++) {
        if (i == last_match) print insert_line
        print lines[i]
      }
    }
  ' "$file" > "$tmp_file" || {
    rm -f "$tmp_file"
    return 1
  }
  mv "$tmp_file" "$file"
}

install_nomount() {
  local repo="$1"
  local ref="$2"
  local commit="$3"
  local repo_dir="NoMount"
  local fs_dir
  local kconfig_source
  local version

  if [[ -d fs ]]; then
    fs_dir="fs"
  elif [[ -d common/fs ]]; then
    fs_dir="common/fs"
  else
    echo "::error::NoMount requires an fs/ or common/fs/ directory in the kernel tree."
    exit 1
  fi

  rm -rf "$repo_dir"
  git init -q "$repo_dir"
  git -C "$repo_dir" remote add origin "$repo"
  git_fetch_retry "$repo_dir" --depth=1 --no-tags origin "$commit"
  git -C "$repo_dir" checkout -q --detach FETCH_HEAD
  test "$(git -C "$repo_dir" rev-parse HEAD)" = "$commit" || {
    echo "::error::NoMount checkout does not match resolved commit $commit ($ref)."
    exit 1
  }

  test -f "$repo_dir/kernel/src/nomount.c"
  test -f "$repo_dir/kernel/src/nomount.h"
  test -f "$repo_dir/kernel/src/Kconfig"
  test -f "$repo_dir/kernel/src/Makefile"

  rm -rf "$fs_dir/nomount"
  ln -s "$(realpath --relative-to="$fs_dir" "$repo_dir/kernel/src")" "$fs_dir/nomount"
  ensure_line_in_file "$fs_dir/Makefile" 'obj-$(CONFIG_NOMOUNT) += nomount/'
  kconfig_source="source \"${fs_dir}/nomount/Kconfig\""
  insert_line_before_last_match "$fs_dir/Kconfig" "endmenu" "$kconfig_source" || {
    echo "::error::Could not add NoMount Kconfig to $fs_dir/Kconfig."
    exit 1
  }

  version="$(sed -nE 's/^#define NOMOUNT_VERSION "([^"]+)"/\1/p' "$repo_dir/kernel/src/nomount.h" | head -n 1)"
  if [[ -z "$version" ]]; then
    echo "::error::Could not detect the integrated NoMount version."
    exit 1
  fi

  NOMOUNT_VERSION="$version"
  NOMOUNT_FS_DIR="$fs_dir"
  export NOMOUNT_VERSION NOMOUNT_FS_DIR
  {
    echo "NOMOUNT_VERSION=$NOMOUNT_VERSION"
    echo "NOMOUNT_FS_DIR=$NOMOUNT_FS_DIR"
  } >> "$GITHUB_ENV"

  {
    echo "nomount_ref=$ref"
    echo "nomount_commit=$commit"
    echo "nomount_version=$NOMOUNT_VERSION"
    echo "nomount_fs_dir=$fs_dir"
    grep -Fn 'obj-$(CONFIG_NOMOUNT) += nomount/' "$fs_dir/Makefile"
    grep -Fn "$kconfig_source" "$fs_dir/Kconfig"
  } | tee nomount-source-proof.txt

  echo "[+] Integrated NoMount v${NOMOUNT_VERSION} from $commit ($ref)."
}
