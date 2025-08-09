#!/bin/bash

# Library Management System - Full Stack Startup Script (Dockerized)

set -euo pipefail

echo "Starting Library Management System (Full Stack via Docker Compose)..."
echo

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Prerequisites
echo "Checking prerequisites..."
if ! command_exists docker; then
  echo "Docker is not installed. Please install Docker to continue."
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose (Docker CLI plugin) is not available. Please install/update Docker."
  exit 1
fi
echo "Docker and Docker Compose detected"
echo

# Ensure we are at repo root (where docker-compose.yml lives)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Build and start all services
echo "Building and starting containers (postgres, rails, frontend)..."
docker compose up --build -d

# Optional: wait a moment for services to initialize
echo "Waiting for services to initialize..."
sleep 5

# Ensure stale PID files are removed (belt-and-suspenders)
echo "Ensuring no stale server PID remains..."
docker compose exec -T rails bash -lc "rm -f tmp/pids/server.pid"

# Initialize database (reset for a clean dev state)
echo "Preparing database (rails db:reset)..."
docker compose exec rails bash -c "rails db:reset"

# Show status and endpoints
echo
echo "✅ Library Management System is running!"
echo "🔗 Rails API:       http://localhost:3000"
echo "🔗 React Frontend:  http://localhost:3001"
echo "🗄️  PostgreSQL:      localhost:5432"
echo
echo "👥 Demo accounts:"
echo "  - Librarian: librarian@library.com / password123"
echo "  - Member:    member1@library.com / password123"
echo

# Follow logs unless --no-logs flag is provided
if [[ "${1-}" != "--no-logs" ]]; then
  echo "Streaming logs (Ctrl+C to stop streaming without stopping containers)..."
  docker compose logs -f
else
  echo "Containers started in background (no logs). Use 'docker compose logs -f' to follow logs."
fi

