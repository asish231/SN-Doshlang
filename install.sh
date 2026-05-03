#!/bin/bash

set -e

VERSION="v0.1.0"
REPO="asish231/SN-Doshlang"
INSTALL_DIR="/usr/local/bin"

echo "Installing SNlang ${VERSION}..."

# Check if running on ARM64 Mac
if [[ $(uname -m) != "arm64" ]]; then
    echo "Error: SNlang currently only supports ARM64 (Apple Silicon) Macs"
    exit 1
fi

# Download
curl -L "https://github.com/${REPO}/releases/download/${VERSION}/snc-macos-arm64-${VERSION}.zip" -o /tmp/snlang.zip

# Extract
cd /tmp
unzip -o snlang.zip

# Install
chmod +x snc
mv snc "${INSTALL_DIR}/"

# Cleanup
rm -f snlang.zip

echo "SNlang installed to ${INSTALL_DIR}/snc"
echo "Test with: snc examples/math.sn"
