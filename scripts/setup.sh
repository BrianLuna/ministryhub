#!/bin/bash

# Exit on error
set -e

echo "🚀 Setting up MinistryHub development environment..."

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install it first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install it first."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose up -d

# Build the project
echo "🔨 Building the project..."
pnpm turbo build

echo "✅ Setup complete! You can now run:"
echo "  - pnpm dev:web    # Start the web app"
echo "  - pnpm dev:api    # Start the API"
echo "  - pnpm test       # Run tests"
echo "  - pnpm lint       # Run linter" 