#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

TARGET_PATH="$1"

# Advisory from https://www.aikido.dev/blog/axios-npm-compromised-maintainer-hijacked-rat
echo "Finding all package-lock.json files under $TARGET_PATH ..."
PACKAGE_LOCK_FILES=$(find "$TARGET_PATH" -type f -name "package-lock.json" -print)

echo "--- Found the following package-lock.json files ---"
echo -e "$PACKAGE_LOCK_FILES\n"
found=0
for file in $PACKAGE_LOCK_FILES; do
    echo "[*] Checking $file"
    if grep -A1 '"axios"' "$file" | grep -qE "1\.14\.1|0\.30\.4"; then
        echo "🚨 Vulnerable axios version found in $file 🚨"
        found=1
    else
        echo -e "SAFE ✅\n"
    fi
done

# Only check for com.apple.act.mond if running on MacOS
if [[ "$(uname)" == "Darwin" ]]; then
    ls -la /Library/Caches/com.apple.act.mond 2>/dev/null && echo "🚨 COMPROMISED: com.apple.act.mond file present 🚨"!
else
    ls -la /tmp/ld.py 2>/dev/null && echo "COMPROMISED"
fi

# Advisory from https://safedep.io/axios-npm-supply-chain-compromise/
echo "--- Running checksum Trojan check ---"
find $TARGET_PATH -type f -name "setup.js" -exec shasum -a 256 {} \; 2>/dev/null | grep e10b1fa84f1d6481625f741b69892780140d4e0e7769e7491e5f4d894c2e0e09 | while read -r line; do
    file_path=$(echo "$line" | awk '{print $2}')
    echo "🚨 Malicious setup.js found at: $file_path 🚨"
done
echo "Scan finished!"
