#!/bin/bash
set -e

echo "🔒 Setting up secure environment on Digital Ocean droplet"
echo "========================================================"

# Check if we have the required environment variables
if [ -z "$DROPLET_IP" ]; then
    echo "❌ Error: DROPLET_IP environment variable not set"
    echo "Please set DROPLET_IP=your_droplet_ip"
    exit 1
fi

if [ -z "$DROPLET_USER" ]; then
    DROPLET_USER="root"
fi

if [ -z "$DEPLOY_PATH" ]; then
    DEPLOY_PATH="/opt/exploresg/docker-compose"
fi

echo "📍 Target: $DROPLET_IP"
echo "👤 User: $DROPLET_USER"
echo "📁 Path: $DEPLOY_PATH"
echo ""

# Create secure .env file on droplet
echo "🔐 Creating secure .env file on droplet..."

ssh -o StrictHostKeyChecking=no $DROPLET_USER@$DROPLET_IP "cat > $DEPLOY_PATH/.env << 'EOF'
# ExploreSG Secure Environment Configuration
# Generated on $(date)

# Database Configuration
POSTGRES_PASSWORD=SecureDBPass_$(date +%s)_$(openssl rand -hex 4)

# RabbitMQ Configuration  
RABBITMQ_PASSWORD=SecureRabbitMQ_$(date +%s)_$(openssl rand -hex 4)

# JWT Configuration
JWT_SECRET_KEY=$(openssl rand -base64 64)

# Mapbox Configuration (keep existing token)
MAPBOX_TOKEN=pk.eyJ1Ijoic3JlZS1yLW9uZSIsImEiOiJjbWgzeXFpb3cwd2R5MmlyNXgxcWRvcWw0In0.DDYbNKeGZkkpChwcKPI6pQ

# Security Notes
# - All passwords are randomly generated
# - JWT secret is cryptographically secure
# - Mapbox token is kept for functionality
EOF"

echo "✅ Secure .env file created on droplet"
echo ""

# Show the generated values (for reference)
echo "🔍 Generated secure values:"
ssh -o StrictHostKeyChecking=no $DROPLET_USER@$DROPLET_IP "cd $DEPLOY_PATH && echo 'Database Password: \${POSTGRES_PASSWORD}' && echo 'RabbitMQ Password: \${RABBITMQ_PASSWORD}' && echo 'JWT Secret: \${JWT_SECRET_KEY}'"

echo ""
echo "🚀 Restarting services with secure configuration..."

# Restart services with new environment
ssh -o StrictHostKeyChecking=no $DROPLET_USER@$DROPLET_IP "cd $DEPLOY_PATH && docker compose down && docker compose up -d"

echo ""
echo "⏳ Waiting for services to start..."
sleep 30

echo ""
echo "🏥 Checking service health..."
ssh -o StrictHostKeyChecking=no $DROPLET_USER@$DROPLET_IP "cd $DEPLOY_PATH && ./health-check.sh"

echo ""
echo "✅ Secure deployment completed!"
echo ""
echo "🔒 Security improvements applied:"
echo "- ✅ Random database password generated"
echo "- ✅ Random RabbitMQ password generated" 
echo "- ✅ Cryptographically secure JWT secret"
echo "- ✅ Services restarted with secure configuration"
echo ""
echo "📋 Next steps:"
echo "1. Run security scan workflow to verify improvements"
echo "2. Test application functionality"
echo "3. Monitor logs for any issues"
