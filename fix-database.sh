#!/bin/bash

echo "🔧 Fixing database schema and loading full seed data..."

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check if tables exist, if not wait for Spring Boot to create them
echo "🔍 Checking if tables exist..."
ssh -i ~/.ssh/id_rsa root@129.212.208.247 "cd /opt/exploresg/docker-compose && docker compose exec postgres psql -U exploresguser -d exploresg -c 'SELECT COUNT(*) FROM car_models;' 2>/dev/null || echo 'Tables not ready yet'"

# If tables don't exist, wait a bit more
echo "⏳ Waiting for Spring Boot to create schema..."
sleep 20

# Now run the full seed file
echo "🌱 Loading comprehensive seed data..."
ssh -i ~/.ssh/id_rsa root@129.212.208.247 "cd /opt/exploresg/docker-compose && docker compose exec -T postgres psql -U exploresguser -d exploresg < /tmp/seed-fleet.sql"

# Verify the data
echo "✅ Verifying data load..."
ssh -i ~/.ssh/id_rsa root@129.212.208.247 "cd /opt/exploresg/docker-compose && docker compose exec postgres psql -U exploresguser -d exploresg -c 'SELECT COUNT(*) as car_models FROM car_models; SELECT COUNT(*) as fleet_vehicles FROM fleet_vehicles;'"

echo "🎉 Database fix complete!"
