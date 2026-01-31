#!/bin/bash
set -e

echo "🔌 Setting up Hardware Gateway with pre-built Docker image..."

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

# Pull pre-built Docker image from GHCR
echo "🐳 Pulling pre-built nRF52840 hardware gateway environment..."
docker pull ghcr.io/${GITHUB_REPO}/nrf52840-env:latest

# Run the hardware gateway container
echo "🚀 Starting hardware gateway container..."
docker run -d \
  --name nrf52840-hardware \
  --restart unless-stopped \
  --privileged \
  --network host \
  ghcr.io/${GITHUB_REPO}/nrf52840-env:latest \
  sleep infinity

# Create keepalive script
cat > /usr/local/bin/keepalive.sh << 'EOF'
#!/bin/bash
dd if=/dev/zero of=/dev/null bs=1M count=10 &>/dev/null
EOF

chmod +x /usr/local/bin/keepalive.sh
(crontab -l 2>/dev/null; echo "0 */6 * * * /usr/local/bin/keepalive.sh") | crontab -

# Signal completion
touch /var/log/user_data_complete.log
echo "✅ Hardware Gateway setup complete" > /var/log/setup_status.log
