#!/bin/bash
set -euo pipefail

if [ -z "${APT_PACKAGES:-}" ]; then
  echo "❌ 未设置 APT_PACKAGES 环境变量" >&2
  exit 1
fi
read -ra PACKAGES <<< "$APT_PACKAGES"

CACHE_DIR="${1:-$HOME/.apt-pkg-cache}"
REQUEST_MANIFEST="$CACHE_DIR/request-manifest.txt"
FULL_MANIFEST="$CACHE_DIR/full-manifest.txt"
EXPECTED_REQUEST="$(printf '%s\n' "${PACKAGES[@]}" | sort)"

mkdir -p "$CACHE_DIR"

cache_hit=false
if [ -f "$REQUEST_MANIFEST" ] && [ "$(cat "$REQUEST_MANIFEST")" = "$EXPECTED_REQUEST" ] && [ -f "$FULL_MANIFEST" ]; then
  missing=0
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    [ -f "$CACHE_DIR/${pkg}.tar" ] || { missing=1; break; }
  done < "$FULL_MANIFEST"
  [ "$missing" -eq 0 ] && cache_hit=true
fi

if [ "$cache_hit" = true ]; then
  n=0
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    sudo tar -xf "$CACHE_DIR/${pkg}.tar" -C /
    n=$((n+1))
  done < "$FULL_MANIFEST"
  sudo ldconfig || true
  echo "✅ APT 文件缓存命中，已恢复 $n 个包(含依赖)"
  exit 0
fi

echo "🔧 APT 文件缓存未命中(或包列表变了)，执行正常安装并计算依赖闭包"
echo "请求: ${PACKAGES[*]}"


BEFORE="$(dpkg-query -W -f='${Package}\n' 2>/dev/null | sort)"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PACKAGES[@]}"

AFTER="$(dpkg-query -W -f='${Package}\n' 2>/dev/null | sort)"
NEW_PKGS="$(comm -13 <(echo "$BEFORE") <(echo "$AFTER"))"
FULL_SET="$(printf '%s\n%s\n' "$NEW_PKGS" "$(printf '%s\n' "${PACKAGES[@]}")" | sort -u)"

n=0
while IFS= read -r pkg; do
  [ -z "$pkg" ] && continue
  dpkg -s "$pkg" >/dev/null 2>&1 || continue
  tar_path="$CACHE_DIR/${pkg}.tar"
  tar -cf "$tar_path" -C / -T <(
    dpkg -L "$pkg" | while IFS= read -r f; do
      [ -f "$f" ] && echo "${f#/}"
    done
  )
  n=$((n+1))
done <<< "$FULL_SET"

printf '%s\n' "${PACKAGES[@]}" | sort > "$REQUEST_MANIFEST"
echo "$FULL_SET" | sed '/^$/d' | sort -u > "$FULL_MANIFEST"
echo "✅ 缓存写入完成，共 $n 个包"