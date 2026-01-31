#!/bin/bash
set -e

echo "🚀 Setting up Build Server with pre-built Docker image..."

# Update system
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Docker
echo "📦 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Enable Docker on boot
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Enable swap (2GB) for compilation safety
echo "💾 Configuring swap space..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
sysctl vm.swappiness=10
echo 'vm.swappiness=10' >> /etc/sysctl.conf

# Pull pre-built Docker image from GHCR
echo "🐳 Pulling pre-built nRF52840 development environment..."
docker pull ghcr.io/${GITHUB_REPO}/nrf52840-env:latest

# Run the development container
echo "🚀 Starting development container..."
docker run -d \
  --name nrf52840-build \
  --restart unless-stopped \
  --privileged \
  -v /workspace:/workspace \
  ghcr.io/${GITHUB_REPO}/nrf52840-env:latest \
  sleep infinity

# Create keepalive script (prevent OCI idle reclamation)
cat > /usr/local/bin/keepalive.sh << 'EOF'
#!/bin/bash
dd if=/dev/zero of=/dev/null bs=1M count=10 &>/dev/null
EOF

chmod +x /usr/local/bin/keepalive.sh
(crontab -l 2>/dev/null; echo "0 */6 * * * /usr/local/bin/keepalive.sh") | crontab -

# Signal completion
touch /var/log/user_data_complete.log
echo "✅ Build Server setup complete" > /var/log/setup_status.log
