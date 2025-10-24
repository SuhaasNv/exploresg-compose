#!/bin/bash

echo "📦 Copying ExploreSG files to DigitalOcean droplet..."
echo "📍 Target: 129.212.208.247"
echo ""

# Create directory structure on droplet
echo "1️⃣ Creating directory structure..."
ssh -o StrictHostKeyChecking=no root@129.212.208.247 "mkdir -p /opt/exploresg/docker-compose/db"

# Copy main files
echo "2️⃣ Copying main configuration files..."
scp -o StrictHostKeyChecking=no compose.yaml root@129.212.208.247:/opt/exploresg/docker-compose/
scp -o StrictHostKeyChecking=no nginx-gateway.conf root@129.212.208.247:/opt/exploresg/docker-compose/
scp -o StrictHostKeyChecking=no deploy.sh root@129.212.208.247:/opt/exploresg/docker-compose/
scp -o StrictHostKeyChecking=no status-check.sh root@129.212.208.247:/opt/exploresg/docker-compose/

# Copy database files
echo "3️⃣ Copying database files..."
scp -o StrictHostKeyChecking=no -r db/* root@129.212.208.247:/opt/exploresg/docker-compose/db/

# Make scripts executable
echo "4️⃣ Making scripts executable..."
ssh -o StrictHostKeyChecking=no root@129.212.208.247 "chmod +x /opt/exploresg/docker-compose/deploy.sh"
ssh -o StrictHostKeyChecking=no root@129.212.208.247 "chmod +x /opt/exploresg/docker-compose/status-check.sh"

# Verify files were copied
echo "5️⃣ Verifying files..."
ssh -o StrictHostKeyChecking=no root@129.212.208.247 "ls -la /opt/exploresg/docker-compose/"

echo ""
echo "✅ Files copied successfully!"
echo "🎯 Your droplet is now ready for GitHub Actions deployment"
echo ""
echo "📋 Next steps:"
echo "   1. Set up GitHub Secrets:"
echo "      - DO_SSH_PRIVATE_KEY: Your SSH private key"
echo "      - DO_DROPLET_IP: 129.212.208.247"
echo "   2. Push to main branch to trigger deployment"
echo "   3. Or manually trigger the workflow from GitHub Actions tab"
