#!/bin/bash

echo "Starting Library Management System..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Build and start the containers
echo " Building and starting containers..."
docker compose up --build -d

# Wait for the database to be ready
echo "Waiting for database to be ready..."
sleep 3

echo "Making migrations and seeding database..."
docker compose exec rails rails db:reset

# Check if containers are running
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "Library Management System is running!"
    echo "Rails API: http://localhost:5000"
    echo "PostgreSQL: localhost:5432"
else
    echo "Failed to start containers. Check logs with: docker compose logs"
    exit 1
fi
