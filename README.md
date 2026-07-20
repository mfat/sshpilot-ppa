# SSH Pilot PPA

The official APT repository for SSH Pilot.

## About

This repository automatically publishes the latest version of [SSH Pilot](https://github.com/mfat/sshpilot) for Debian/Ubuntu systems.

**Requires Debian 13 (trixie) or newer, or Ubuntu 24.04 (noble) or newer** — and
the derivatives built on them, such as Linux Mint 22.x, Pop!\_OS 24.04, Zorin 18
and elementary OS 8. The package needs libadwaita 1.5, which Debian 12 and
Ubuntu 22.04 do not ship; on those, `apt install` fails with
`Depends: gir1.2-adw-1 (>= 1.5) but it is not installable`.

amd64 and arm64 are both published. The package itself is architecture-independent.

```bash
# Add the GPG key
curl -fsSL https://mfat.github.io/sshpilot-ppa/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sshpilot-ppa.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/sshpilot-ppa.gpg] https://mfat.github.io/sshpilot-ppa any main" | sudo tee /etc/apt/sources.list.d/sshpilot-ppa.list

# Install
sudo apt update
sudo apt install sshpilot
```


## License

This repository only packages and distributes SSH Pilot. Please refer to the [original SSH Pilot repository](https://github.com/mfat/sshpilot) for license information.

