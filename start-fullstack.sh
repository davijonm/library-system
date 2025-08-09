#!/bin/bash

# Library Management System - Full Stack Startup Script

echo "Starting Library Management System (Full Stack)..."
echo

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."

# Check Docker
if ! command_exists docker; then
    echo " Docker is not installed. Please install Docker to continue."
    exit 1
fi

# Check Docker Compose
if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
    echo " Docker Compose is not installed. Please install Docker Compose to continue."
    exit 1
fi

# Check Node.js
if ! command_exists node; then
    echo " Node.js is not installed. Please install Node.js 16+ to continue."
    exit 1
fi

# Check npm
if ! command_exists npm; then
    echo " npm is not installed. Please install npm to continue."
    exit 1
fi

echo " All prerequisites are installed"
echo

# Start backend in background
echo " Starting Rails API and PostgreSQL..."
sudo chmod +x ./start.sh & ./start.sh & BACKEND_PID=$!

# Wait a bit for backend to start
echo " Waiting for backend to initialize..."
sleep 15

# Start frontend
echo " Starting React frontend..."
cd library-frontend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo " Installing frontend dependencies..."
    npm install
fi

# Start frontend
echo
echo " System URLs:"
echo "  - Rails API: http://localhost:5000"
echo "  - React Frontend: http://localhost:3000"
echo
echo " Demo accounts:"
echo "  - Librarian: librarian@library.com / password123"
echo "  - Member: member1@library.com / password123"
echo
echo " Press Ctrl+C to stop both servers"
echo

# Function to cleanup on exit
cleanup() {
    echo
    echo "🛑 Stopping servers..."
    kill $BACKEND_PID 2>/dev/null
    docker-compose down 2>/dev/null
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start frontend (this will block)
npm start

# Cleanup if npm start exits
cleanup
