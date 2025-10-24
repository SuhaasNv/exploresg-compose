#!/bin/bash
set -e

echo "🚀 Deploying ExploreSG to DigitalOcean..."

# Get tag from argument or use latest
TAG=${1:-latest}
echo "📦 Using tag: $TAG"

# Navigate to compose directory
cd /opt/exploresg/docker-compose

# Update compose file with tag
echo "🔄 Updating compose file with tag: $TAG"
sed -i "s/:latest/:$TAG/g" compose.yaml

# Pull latest images
echo "📥 Pulling images..."
docker compose pull

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down

# Start services
echo "🏃 Starting services..."
docker compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Show status
echo "📊 Service status:"
docker compose ps

# Health check
echo "🏥 Running health checks..."
if [ -f "./health-check.sh" ]; then
    ./health-check.sh
else
    echo "⚠️ health-check.sh not found, running basic checks..."
    echo "📊 Service status:"
    docker compose ps
    echo "🔗 Testing frontend..."
    curl -f http://localhost:3000 > /dev/null && echo "✅ Frontend responding" || echo "❌ Frontend not responding"
fi

echo "✅ Deployment complete!"
echo "🌐 Application should be available at: http://$(curl -s ifconfig.me):3000"

