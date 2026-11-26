#!/bin/bash

: "${CONFIG_FILE:?CONFIG_FILE 未设置}"
: "${MAKEFILE:?MAKEFILE 未设置}"

declare -a KCFG_HIDDEN=()

kcfg_set() {
  local val="$1"
  local key="${val%%=*}"
  if grep -qF "${key}=" "$CONFIG_FILE" || grep -qF "# ${key} is not set" "$CONFIG_FILE"; then
    VAL="$val" awk -v key="$key" '
      $0 == "# " key " is not set" || index($0, key "=") == 1 { print ENVIRON["VAL"]; next }
      { print }
    ' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE" || rm -f "${CONFIG_FILE}.tmp"
  else
    printf '%s\n' "$val" >> "$CONFIG_FILE"
  fi
}

kcfg_set_hidden() {
  local val="$1"
  local key="${val%%=*}"
  kcfg_set "$val"
  KCFG_HIDDEN+=("$key")
}

kcfg_inject_fake() {
  [ "${#KCFG_HIDDEN[@]}" -eq 0 ] && return 0
  local marker="# --- fake_config injector ---"
  if ! grep -qF "$marker" "$MAKEFILE"; then
    {
      printf '\n%s\n' "$marker"
      printf 'ifneq ($(strip $(CONFIG_FAKE_DISABLE)),)\n'
      printf '$(obj)/config_data: $(KCONFIG_CONFIG) FORCE\n'
      printf '\t$(Q)sed $(foreach opt,$(CONFIG_FAKE_DISABLE),-e '"'"'s|^$(opt)=.*|# $(opt) is not set|'"'"') $(KCONFIG_CONFIG) > $@\n'
      printf 'endif\n'
    } >> "$MAKEFILE"
  fi
  echo "CONFIG_FAKE_DISABLE=${KCFG_HIDDEN[*]}" >> "$GITHUB_ENV"
}