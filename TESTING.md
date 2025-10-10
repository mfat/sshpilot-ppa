# Testing the SSH Pilot PPA

## Pre-deployment Checks

### 1. Verify GitHub Actions Workflow

After pushing to GitHub:

1. Go to your repository on GitHub
2. Click the **Actions** tab
3. You should see a workflow run for "Build & Publish Debian Package"
4. Click on the run to see detailed logs
5. Check that all steps complete successfully:
   - ✅ Checkout repository
   - ✅ Install dependencies
   - ✅ Import GPG key
   - ✅ Determine latest sshpilot version
   - ✅ Download latest sshpilot binary
   - ✅ Sign Debian package
   - ✅ Create APT repository with reprepro
   - ✅ Deploy APT repository to GitHub Pages

**Common issues:**
- If "Import GPG key" fails: Check that `GPG_PRIVATE_KEY` secret is set correctly
- If "Download latest sshpilot binary" fails: Check that SSH Pilot has releases with `.deb` files
- If "Deploy" fails on first run: You may need to enable GitHub Pages deployment from Actions

### 2. Verify GitHub Pages Deployment

1. Go to **Settings** → **Pages**
2. Ensure "Source" is set to "Deploy from a branch"
3. Select `gh-pages` branch (it's created automatically by the action)
4. After a few minutes, you should see: "Your site is live at https://mahdi.github.io/sshpilot-ppa/"

### 3. Test the Web Interface

Open your browser and visit:
```
https://mahdi.github.io/sshpilot-ppa/
```

You should see:
- The SSH Pilot PPA landing page with installation instructions
- No 404 errors

### 4. Check Repository Files

Visit these URLs to verify the repository structure:

```
https://mahdi.github.io/sshpilot-ppa/pubkey.gpg
https://mahdi.github.io/sshpilot-ppa/dists/any/Release
https://mahdi.github.io/sshpilot-ppa/dists/any/main/binary-amd64/Packages
```

All should return data (not 404 errors).

## Installation Testing

### Test on a Ubuntu/Debian VM or Container

The safest way to test is using Docker:

```bash
# Start an Ubuntu container
docker run -it --rm ubuntu:22.04 bash

# Inside the container, follow your installation instructions:
apt-get update && apt-get install -y curl gnupg

# Add the GPG key
curl -fsSL https://mahdi.github.io/sshpilot-ppa/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/sshpilot-ppa.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/sshpilot-ppa.gpg arch=amd64] https://mahdi.github.io/sshpilot-ppa any main" | tee /etc/apt/sources.list.d/sshpilot-ppa.list

# Update and install
apt-get update
apt-get install sshpilot

# Verify installation
which sshpilot
sshpilot --version
```

### Expected Output

**During `apt-get update`:**
```
Hit:1 https://mahdi.github.io/sshpilot-ppa any InRelease
Reading package lists... Done
```

**During `apt-get install sshpilot`:**
```
Reading package lists... Done
Building dependency tree... Done
The following NEW packages will be installed:
  sshpilot
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
```

### Troubleshooting

#### Error: "The following signatures couldn't be verified"

**Problem:** GPG key mismatch or not properly imported

**Solution:**
```bash
# Re-import the key
curl -fsSL https://mahdi.github.io/sshpilot-ppa/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/sshpilot-ppa.gpg

# Verify key was imported
gpg --no-default-keyring --keyring /usr/share/keyrings/sshpilot-ppa.gpg --list-keys
```

#### Error: "Unable to locate package sshpilot"

**Problem:** Repository not found or package not in repository

**Solutions:**
1. Check that the repository line is correct in `/etc/apt/sources.list.d/sshpilot-ppa.list`
2. Verify the repository URL is accessible: `curl https://mahdi.github.io/sshpilot-ppa/dists/any/Release`
3. Check the GitHub Action completed successfully
4. Ensure SSH Pilot actually has `.deb` releases at https://github.com/mfat/sshpilot/releases

#### Error: 404 on GitHub Pages

**Problem:** GitHub Pages not deployed yet

**Solutions:**
1. Wait a few minutes after the Action completes
2. Check Settings → Pages is configured for `gh-pages` branch
3. Check that the Action has "pages: write" permission
4. Try manually triggering the workflow from the Actions tab

## Manual Verification Commands

### Check Repository Metadata

```bash
# Download and inspect the Release file
curl https://mahdi.github.io/sshpilot-ppa/dists/any/Release

# Should show:
# Origin: GitHub
# Label: GitHub SSH Pilot
# Suite: stable
# Codename: any
# ...
```

### Check Package List

```bash
# Download package list
curl https://mahdi.github.io/sshpilot-ppa/dists/any/main/binary-amd64/Packages

# Should show package information including:
# Package: sshpilot
# Version: X.X.X
# Architecture: amd64
# ...
```

### Verify GPG Signature

```bash
# Download and verify the InRelease file
curl https://mahdi.github.io/sshpilot-ppa/dists/any/InRelease | gpg --verify

# Should show: "Good signature from..."
```

## Automated Testing Script

Save this as `test-ppa.sh`:

```bash
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
```

Run it with:
```bash
chmod +x test-ppa.sh
./test-ppa.sh
```

## Testing Updates

To verify automatic updates work:

1. Wait for SSH Pilot to release a new version, OR
2. Manually trigger the workflow:
   - Go to Actions tab
   - Click "Build & Publish Debian Package"
   - Click "Run workflow" → "Run workflow"
3. Check that the new version appears in the repository
4. On a system with SSH Pilot installed:
   ```bash
   sudo apt update
   sudo apt list --upgradable | grep sshpilot
   sudo apt upgrade sshpilot
   ```

