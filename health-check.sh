#!/bin/bash
set -e

echo "🏥 ExploreSG Health Check"
echo "========================="

# Check if we're in the right directory
if [ ! -f "compose.yaml" ]; then
    echo "❌ Error: compose.yaml not found. Please run from the correct directory."
    exit 1
fi

echo "📊 Service Status:"
docker compose ps

echo ""
echo "🔗 API Health Checks:"

# Get the external IP if running in GitHub Actions, otherwise use localhost
if [ -n "$DROPLET_IP" ]; then
    BASE_URL="http://$DROPLET_IP"
    echo "🌐 Using external IP: $DROPLET_IP"
else
    BASE_URL="http://localhost"
    echo "🏠 Using localhost"
fi

# Frontend check
echo "Checking frontend..."
if curl -f -s $BASE_URL:3000 > /dev/null; then
    echo "✅ Frontend is responding"
else
    echo "❌ Frontend is not responding"
fi

# Auth service check
echo "Checking auth service..."
if curl -f -s $BASE_URL:8081/actuator/health > /dev/null; then
    echo "✅ Auth service is healthy"
else
    echo "❌ Auth service is not healthy"
fi

# Fleet service check
echo "Checking fleet service..."
if curl -f -s $BASE_URL:8082/actuator/health > /dev/null; then
    echo "✅ Fleet service is healthy"
else
    echo "❌ Fleet service is not healthy"
fi

# Booking service check
echo "Checking booking service..."
if curl -f -s $BASE_URL:8083/actuator/health > /dev/null; then
    echo "✅ Booking service is healthy"
else
    echo "❌ Booking service is not healthy"
fi

# Payment service check
echo "Checking payment service..."
if curl -f -s $BASE_URL:8084/actuator/health > /dev/null; then
    echo "✅ Payment service is healthy"
else
    echo "❌ Payment service is not healthy"
fi

echo ""
echo "🗄️ Database Health Check:"
if docker compose exec -T postgres pg_isready -U exploresguser -d exploresg > /dev/null 2>&1; then
    echo "✅ Database is accessible"
else
    echo "❌ Database is not accessible"
fi

echo ""
echo "🐰 RabbitMQ Health Check:"
if docker compose exec -T rabbitmq rabbitmq-diagnostics ping > /dev/null 2>&1; then
    echo "✅ RabbitMQ is healthy"
else
    echo "❌ RabbitMQ is not healthy"
fi

echo ""
echo "✅ Health check completed!"
