#!/usr/bin/env bash
TARGET_ZSHRC="$1"

if grep -q "# [OPENJDK.SH] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[OPENJDK.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo ""
    echo "# [OPENJDK.SH] STARTED ------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

if grep -q "^export JAVA_HOME=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^export JAVA_HOME=.*|export JAVA_HOME=\$(brew --prefix)/opt/openjdk"| "$TARGET_ZSHRC"
else
  echo "export JAVA_HOME=\$(brew --prefix)/opt/openjdk" >> "$TARGET_ZSHRC"
fi

# 성공 마커가 없으면 삽입
if ! grep -q "# \[OPENJDK.SH\] APPLIED" "$TARGET_ZSHRC"; then
  echo "# [OPENJDK.SH] APPLIED ------------------------------------------------------- #" >> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0
