#!/bin/bash
set -e

echo "🔒 Secure ExploreSG Deployment"
echo "=============================="

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found"
    echo "📋 Please create .env file from env.example with your secure values"
    echo "   cp env.example .env"
    echo "   # Then edit .env with your actual secrets"
    echo ""
    echo "🔄 Proceeding with default values (NOT RECOMMENDED FOR PRODUCTION)"
    echo ""
fi

# Load environment variables if .env exists
if [ -f ".env" ]; then
    echo "📥 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ Environment variables loaded"
else
    echo "⚠️  Using default values from compose.yaml"
fi

echo ""
echo "🚀 Starting deployment with secure configuration..."

# Deploy with environment variables
docker compose up -d

echo ""
echo "✅ Secure deployment completed!"
echo ""
echo "🔒 Security Notes:"
echo "- Database password: ${POSTGRES_PASSWORD:-default}"
echo "- RabbitMQ password: ${RABBITMQ_PASSWORD:-default}"  
echo "- JWT secret: ${JWT_SECRET_KEY:-default}"
echo "- Mapbox token: ${MAPBOX_TOKEN:-default}"
echo ""
echo "📋 Next steps:"
echo "1. Create .env file with secure values"
echo "2. Restart services: docker compose down && docker compose up -d"
echo "3. Verify security: Run security scan workflow"
