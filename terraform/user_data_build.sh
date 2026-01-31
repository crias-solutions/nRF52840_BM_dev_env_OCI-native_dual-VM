#!/bin/bash
set -e

# Update system
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Enable Docker on boot
systemctl enable docker
systemctl start docker

# Pull pre-built image (or build from Dockerfile)
docker pull ghcr.io/YOUR_USERNAME/nrf52840-build-server:latest || \
docker build -t nrf52840-build-server https://github.com/YOUR_USERNAME/nrf52840-oci-dev.git#main:.devcontainer

# Run build server container
docker run -d \
  --name nrf52840-build \
  --restart unless-stopped \
  -v /workspace:/workspace \
  -p 8080:8080 \
  nrf52840-build-server \
  sleep infinity

# Enable swap (2GB)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Keepalive script
cat > /usr/local/bin/keepalive.sh << 'EOF'
#!/bin/bash
dd if=/dev/zero of=/dev/null bs=1M count=10 &>/dev/null
EOF

chmod +x /usr/local/bin/keepalive.sh
(crontab -l 2>/dev/null; echo "0 */6 * * * /usr/local/bin/keepalive.sh") | crontab -

touch /var/log/user_data_complete.log
