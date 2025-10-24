#!/bin/bash

echo "🔍 Checking DigitalOcean Droplet Deployment Setup..."
echo "📍 Target: 129.212.208.247"
echo ""

# Check if SSH connection works
echo "1️⃣ Testing SSH connection..."
if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@129.212.208.247 "echo 'SSH connection successful'" 2>/dev/null; then
    echo "✅ SSH connection works"
else
    echo "❌ SSH connection failed"
    echo "   Make sure you have SSH access to the droplet"
    exit 1
fi

echo ""

# Check if required directory exists
echo "2️⃣ Checking application directory..."
if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "test -d /opt/exploresg/docker-compose" 2>/dev/null; then
    echo "✅ Directory /opt/exploresg/docker-compose exists"
else
    echo "❌ Directory /opt/exploresg/docker-compose does not exist"
    echo "   You need to create this directory and copy files there"
fi

echo ""

# Check if deploy.sh script exists and is executable
echo "3️⃣ Checking deploy.sh script..."
if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "test -f /opt/exploresg/docker-compose/deploy.sh" 2>/dev/null; then
    echo "✅ deploy.sh script exists"
    
    # Check if it's executable
    if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "test -x /opt/exploresg/docker-compose/deploy.sh" 2>/dev/null; then
        echo "✅ deploy.sh is executable"
    else
        echo "⚠️  deploy.sh exists but is not executable"
        echo "   Run: ssh root@129.212.208.247 'chmod +x /opt/exploresg/docker-compose/deploy.sh'"
    fi
else
    echo "❌ deploy.sh script does not exist"
    echo "   You need to copy the deploy.sh script to the droplet"
fi

echo ""

# Check if compose.yaml exists
echo "4️⃣ Checking compose.yaml file..."
if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "test -f /opt/exploresg/docker-compose/compose.yaml" 2>/dev/null; then
    echo "✅ compose.yaml exists"
else
    echo "❌ compose.yaml does not exist"
    echo "   You need to copy the compose.yaml file to the droplet"
fi

echo ""

# Check if nginx-gateway.conf exists
echo "5️⃣ Checking nginx-gateway.conf file..."
if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "test -f /opt/exploresg/docker-compose/nginx-gateway.conf" 2>/dev/null; then
    echo "✅ nginx-gateway.conf exists"
else
    echo "❌ nginx-gateway.conf does not exist"
    echo "   You need to copy the nginx-gateway.conf file to the droplet"
fi

echo ""

# Check if db directory exists
echo "6️⃣ Checking database files..."
if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "test -d /opt/exploresg/docker-compose/db" 2>/dev/null; then
    echo "✅ db directory exists"
    
    # Check for seed file
    if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "test -f /opt/exploresg/docker-compose/db/seed-fleet.sql" 2>/dev/null; then
        echo "✅ seed-fleet.sql exists"
    else
        echo "⚠️  seed-fleet.sql missing"
    fi
else
    echo "❌ db directory does not exist"
    echo "   You need to copy the db directory to the droplet"
fi

echo ""

# Check Docker and Docker Compose
echo "7️⃣ Checking Docker installation..."
if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "docker --version" 2>/dev/null; then
    echo "✅ Docker is installed"
else
    echo "❌ Docker is not installed"
fi

if ssh -o StrictHostKeyChecking=no root@129.212.208.247 "docker compose version" 2>/dev/null; then
    echo "✅ Docker Compose is available"
else
    echo "❌ Docker Compose is not available"
fi

echo ""

# Check current services status
echo "8️⃣ Checking current services status..."
ssh -o StrictHostKeyChecking=no root@129.212.208.247 "cd /opt/exploresg/docker-compose && docker compose ps" 2>/dev/null || echo "❌ Could not check services status"

echo ""
echo "🎯 Summary:"
echo "   If any items show ❌, you need to set up those components"
echo "   If all items show ✅, your droplet is ready for GitHub Actions deployment"
echo ""
echo "📋 To fix missing components, run:"
echo "   ./copy-files-to-droplet.sh"
