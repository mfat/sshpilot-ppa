#!/bin/bash

set -e

REPO_URL="https://mahdi.github.io/sshpilot-ppa"

echo "Testing SSH Pilot PPA..."
echo

echo "1. Checking if web page is accessible..."
if curl -f -s "$REPO_URL/" > /dev/null; then
    echo "   ✅ Web page is accessible"
else
    echo "   ❌ Web page is not accessible"
    exit 1
fi

echo "2. Checking if public key exists..."
if curl -f -s "$REPO_URL/pubkey.gpg" > /dev/null; then
    echo "   ✅ Public key is available"
else
    echo "   ❌ Public key is missing"
    exit 1
fi

echo "3. Checking repository Release file..."
if curl -f -s "$REPO_URL/dists/any/Release" > /dev/null; then
    echo "   ✅ Release file is available"
else
    echo "   ❌ Release file is missing"
    exit 1
fi

echo "4. Checking Packages file..."
if curl -f -s "$REPO_URL/dists/any/main/binary-amd64/Packages" > /dev/null; then
    echo "   ✅ Packages file is available"
    echo
    echo "Package information:"
    curl -s "$REPO_URL/dists/any/main/binary-amd64/Packages" | grep -E "^(Package|Version|Architecture):" | head -10
else
    echo "   ❌ Packages file is missing"
    exit 1
fi

echo
echo "✅ All checks passed! Repository appears to be working."
echo
echo "To install, run:"
echo "  curl -fsSL $REPO_URL/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sshpilot-ppa.gpg"
echo "  echo \"deb [signed-by=/usr/share/keyrings/sshpilot-ppa.gpg arch=amd64] $REPO_URL any main\" | sudo tee /etc/apt/sources.list.d/sshpilot-ppa.list"
echo "  sudo apt update && sudo apt install sshpilot"

