#!/usr/bin/env python3
import argparse
import os
import re
import sys
import unicodedata

RED = "\033[31m"
RESET = "\033[0m"


def check_build_time(s: str) -> bool:
    """允许前两个空格，之后的空格及所有格式字符(Cf)/其他空白标红"""
    warn = False
    out = []
    space_count = 0
    for c in s:
        if c == " ":
            space_count += 1
            if space_count <= 2:
                out.append(f"U+{ord(c):04X} ")
            else:
                warn = True
                out.append(f"{RED}U+{ord(c):04X}{RESET} ")
            continue
        else:
            space_count = 0

        if unicodedata.category(c) == "Cf" or (c.isspace() and c != " "):
            warn = True
            out.append(f"{RED}U+{ord(c):04X}{RESET} ")
        else:
            out.append(f"U+{ord(c):04X} ")

    print("".join(out))
    if warn:
        print("::warning title=BUILD_TIME Error::检测到自定义构建时间异常符号调用，请注意!")
    return warn


def check_suffix(s: str) -> bool:
    warn = False
    out = []
    for c in s:
        if c.isspace() or unicodedata.category(c) == "Cf":
            warn = True
            out.append(f"{RED}U+{ord(c):04X}{RESET} ")
        else:
            out.append(f"U+{ord(c):04X} ")

    print("".join(out))
    if warn:
        print("::warning title=SUFFIX Error::检测到自定义内核后缀异常符号调用，请注意!")

    if re.search(r"^\d{1,3}\.\d{1,3}\.\d{1,3}|-?android\d{2,3}-", s):
        print("::warning title=SUFFIX Format Error::检测到自定义内核后缀存在重复或冗余内容调用，请注意!")
        warn = True

    return warn


def main() -> int:
    parser = argparse.ArgumentParser(description="Unicode / 格式异常检测")
    parser.add_argument("--mode", choices=["build_time", "suffix"], required=True)
    args = parser.parse_args()

    text = os.environ.get("CHECK_TEXT", "")

    if args.mode == "build_time":
        warn = check_build_time(text)
    else:
        warn = check_suffix(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())