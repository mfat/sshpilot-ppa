# SSH Pilot PPA

An unofficial APT repository for SSH Pilot, hosted on GitHub Pages.

## About

This repository automatically packages and publishes the latest version of [SSH Pilot](https://github.com/mfat/sshpilot) as an APT repository for easy installation on Debian/Ubuntu systems.

## Setup Instructions

### 1. Generate GPG Keys

First, you need to generate GPG keys that will be used to sign the packages:

```bash
# Create a directory for the keys
rm -rf repo-key
mkdir repo-key
chmod 700 repo-key

# Create GPG config
echo "batch" > repo-key/gpg.conf
echo "pinentry-mode loopback" >> repo-key/gpg.conf

# Generate the key (replace YOUR_EMAIL with your actual email)
gpg --full-generate-key --homedir repo-key --passphrase ''

# When prompted, choose:
# - Key type: (1) RSA and RSA
# - Key size: 4096
# - Expiration: 0 (does not expire)
# - Name: SSH Pilot PPA
# - Email: YOUR_EMAIL

# List the keys and note the key ID/fingerprint
gpg --list-keys --with-keygrip --homedir repo-key

# Export the private key (replace YOUR_EMAIL)
gpg --homedir repo-key --armor --export-secret-keys YOUR_EMAIL > private.asc

# Export the public key (replace YOUR_EMAIL)
gpg --homedir repo-key --export YOUR_EMAIL > pubkey.gpg
```

### 2. Configure GitHub Repository

1. **Add the public key to the repository:**
   ```bash
   git add pubkey.gpg
   git commit -m "Add GPG public key"
   git push
   ```

2. **Configure GitHub Secrets and Variables:**
   - Go to your repository on GitHub
   - Navigate to `Settings` → `Secrets and variables` → `Actions`
   - Create an environment named `Main`
   - Add a **Repository secret**:
     - Name: `GPG_PRIVATE_KEY`
     - Value: Contents of `private.asc` file
   - Add a **Repository variable**:
     - Name: `KEY_ID`
     - Value: Your GPG key fingerprint (the long hex string from `gpg --list-keys`)

3. **Delete local keys (important for security):**
   ```bash
   rm -rf repo-key private.asc
   ```

### 3. Enable GitHub Pages

1. Go to `Settings` → `Pages`
2. Under "Source", select `Deploy from a branch`
3. Select the `gh-pages` branch
4. Click `Save`

If your first build fails with a permissions error, follow GitHub's instructions for "First deployment with GITHUB_TOKEN".

### 4. Push and Deploy

```bash
git add .
git commit -m "Initial PPA setup"
git push origin main
```

The GitHub Action will automatically:
- Download the latest SSH Pilot release
- Sign the package with your GPG key
- Create an APT repository
- Deploy it to GitHub Pages

## Usage

Once deployed, users can install SSH Pilot by following the instructions at:
`https://YOUR_USERNAME.github.io/sshpilot-ppa/`

Example installation commands:

```bash
# Add the GPG key
curl -fsSL https://YOUR_USERNAME.github.io/sshpilot-ppa/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sshpilot-ppa.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/sshpilot-ppa.gpg arch=amd64] https://YOUR_USERNAME.github.io/sshpilot-ppa any main" | sudo tee /etc/apt/sources.list.d/sshpilot-ppa.list

# Install
sudo apt update
sudo apt install sshpilot
```

## Features

- ✅ Automatic updates when new SSH Pilot releases are published
- ✅ Daily checks for new versions (3am UTC)
- ✅ GPG-signed packages for security
- ✅ Easy installation via apt
- ✅ Manual trigger via GitHub Actions UI

## Credits

- SSH Pilot: https://github.com/mfat/sshpilot
- Setup guide: https://linsomniac.com/post/2025-03-18-building_and_publishing_apt_repos_to_github_pages/

## License

This repository only packages and distributes SSH Pilot. Please refer to the [original SSH Pilot repository](https://github.com/mfat/sshpilot) for license information.

