# SSH Pilot PPA

The official APT repository for SSH Pilot.

## About

This repository automatically publishes the latest version of [SSH Pilot](https://github.com/mfat/sshpilot) for Debian/Ubuntu systems.

```bash
# Add the GPG key
curl -fsSL https://mfat.github.io/sshpilot-ppa/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sshpilot-ppa.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/sshpilot-ppa.gpg arch=amd64] https://mfat.github.io/sshpilot-ppa any main" | sudo tee /etc/apt/sources.list.d/sshpilot-ppa.list

# Install
sudo apt update
sudo apt install sshpilot
```


## License

This repository only packages and distributes SSH Pilot. Please refer to the [original SSH Pilot repository](https://github.com/mfat/sshpilot) for license information.

