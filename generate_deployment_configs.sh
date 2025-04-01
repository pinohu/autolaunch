#!/bin/bash

# AutoLaunch Studio - Deployment Configuration Generator
# This script generates deployment configuration files for various platforms

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║  ${YELLOW}AutoLaunch Studio - Deployment Configuration Generator${BLUE}  ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create config directory if it doesn't exist
mkdir -p config/deployment

# Generate Docker configuration
echo -e "${YELLOW}Generating Docker configuration...${NC}"

# Create docker-compose.yml
cat > config/deployment/docker-compose.yml << EOL
version: '3.8'

services:
  # Frontend service
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: autolaunch-frontend
    ports:
      - "\${FRONTEND_PORT:-3000}:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=\${NODE_ENV:-production}
      - REACT_APP_API_URL=http://backend:\${BACKEND_PORT:-3001}/api
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - autolaunch-network

  # Backend service
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: autolaunch-backend
    ports:
      - "\${BACKEND_PORT:-3001}:3001"
    volumes:
      - ./backend:/app
      - /app/node_modules
      - ./deploy:/app/deploy
    environment:
      - NODE_ENV=\${NODE_ENV:-production}
      - PORT=\${BACKEND_PORT:-3001}
      - MONGODB_URI=\${MONGODB_URI:-mongodb://mongo:27017/autolaunch}
      - JWT_SECRET=\${JWT_SECRET:-autolaunchsecret}
    depends_on:
      - mongo
    restart: unless-stopped
    networks:
      - autolaunch-network

  # MongoDB service
  mongo:
    image: mongo:latest
    container_name: autolaunch-mongo
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    restart: unless-stopped
    networks:
      - autolaunch-network

  # Nginx for reverse proxy
  nginx:
    image: nginx:latest
    container_name: autolaunch-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./config/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./config/ssl:/etc/nginx/ssl
    depends_on:
      - frontend
      - backend
    restart: unless-stopped
    networks:
      - autolaunch-network

volumes:
  mongo-data:

networks:
  autolaunch-network:
    driver: bridge
EOL
echo -e "${GREEN}✓ Created docker-compose.yml${NC}"

# Create frontend Dockerfile
mkdir -p config/deployment/docker
cat > config/deployment/docker/frontend.Dockerfile << EOL
FROM node:16-alpine as build

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the frontend code
COPY . .

# Build the React app
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy the build output from the build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx config if needed
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 3000
EXPOSE 3000

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
EOL
echo -e "${GREEN}✓ Created frontend Dockerfile${NC}"

# Create backend Dockerfile
cat > config/deployment/docker/backend.Dockerfile << EOL
FROM node:16-alpine

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the backend code
COPY . .

# Create deploy directory
RUN mkdir -p /app/deploy

# Expose port 3001
EXPOSE 3001

# Start the server
CMD ["npm", "start"]
EOL
echo -e "${GREEN}✓ Created backend Dockerfile${NC}"

# Generate GitHub Actions configuration
echo -e "${YELLOW}Generating GitHub Actions configuration...${NC}"

mkdir -p config/deployment/github-actions
cat > config/deployment/github-actions/deploy.yml << EOL
name: Deploy AutoLaunch Studio

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
        
    - name: Install frontend dependencies
      run: |
        cd frontend
        npm ci
        
    - name: Build frontend
      run: |
        cd frontend
        npm run build
        
    - name: Install backend dependencies
      run: |
        cd backend
        npm ci
        
    - name: Deploy to server
      uses: appleboy/ssh-action@master
      with:
        host: \${{ secrets.HOST }}
        username: \${{ secrets.USERNAME }}
        key: \${{ secrets.SSH_KEY }}
        script: |
          cd /path/to/deployment
          git pull
          cd frontend
          npm ci
          npm run build
          cd ../backend
          npm ci
          pm2 restart autolaunch-backend
EOL
echo -e "${GREEN}✓ Created GitHub Actions workflow file${NC}"

# Generate Vercel configuration
echo -e "${YELLOW}Generating Vercel configuration...${NC}"

mkdir -p config/deployment/vercel
cat > config/deployment/vercel/vercel.json << EOL
{
  "version": 2,
  "builds": [
    {
      "src": "frontend/package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "build"
      }
    },
    {
      "src": "backend/src/server.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "backend/src/server.js"
    },
    {
      "src": "/(.*)",
      "dest": "frontend/\$1"
    }
  ]
}
EOL
echo -e "${GREEN}✓ Created vercel.json${NC}"

# Generate Netlify configuration
echo -e "${YELLOW}Generating Netlify configuration...${NC}"

mkdir -p config/deployment/netlify
cat > config/deployment/netlify/netlify.toml << EOL
[build]
  base = "frontend"
  publish = "build"
  command = "npm run build"

[build.environment]
  REACT_APP_API_URL = "/.netlify/functions/api"

[functions]
  directory = "backend/netlify/functions"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/api/:splat"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
EOL
echo -e "${GREEN}✓ Created netlify.toml${NC}"

# Create Netlify function wrapper
mkdir -p config/deployment/netlify/functions
cat > config/deployment/netlify/functions/api.js << EOL
const express = require('express');
const serverless = require('serverless-http');
const app = require('../../src/server');

// Wrap the Express app with serverless
module.exports.handler = serverless(app);
EOL
echo -e "${GREEN}✓ Created Netlify function wrapper${NC}"

# Create deployment README
cat > config/deployment/README.md << EOL
# AutoLaunch Studio Deployment Configurations

This directory contains deployment configurations for various platforms.

## Available Deployment Methods

### Docker

For containerized deployment:

1. Copy \`docker-compose.yml\` to your project root
2. Copy \`docker/frontend.Dockerfile\` to \`frontend/Dockerfile\`
3. Copy \`docker/backend.Dockerfile\` to \`backend/Dockerfile\`
4. Run \`docker-compose up -d\`

### GitHub Actions

For CI/CD deployment:

1. Create a \`.github/workflows\` directory in your project root
2. Copy \`github-actions/deploy.yml\` to \`.github/workflows/deploy.yml\`
3. Configure the following secrets in your GitHub repository:
   - \`HOST\`: Your server hostname or IP address
   - \`USERNAME\`: Your SSH username
   - \`SSH_KEY\`: Your SSH private key
4. Update the deployment path in the workflow file

### Vercel

For Vercel deployment:

1. Copy \`vercel/vercel.json\` to your project root
2. Install Vercel CLI: \`npm install -g vercel\`
3. Login to Vercel: \`vercel login\`
4. Deploy: \`vercel --prod\`

### Netlify

For Netlify deployment:

1. Copy \`netlify/netlify.toml\` to your project root
2. Create a \`backend/netlify/functions\` directory
3. Copy \`netlify/functions/api.js\` to \`backend/netlify/functions/api.js\`
4. Install Netlify CLI: \`npm install -g netlify-cli\`
5. Login to Netlify: \`netlify login\`
6. Deploy: \`netlify deploy --prod\`

## Using the Deployment Script

For easier deployment, use the \`scripts/deploy.sh\` script:

\`\`\`bash
# Deploy using Docker
./scripts/deploy.sh --method docker

# Deploy using GitHub Actions
./scripts/deploy.sh --method github

# Deploy using Vercel
./scripts/deploy.sh --method vercel

# Deploy using Netlify
./scripts/deploy.sh --method netlify
\`\`\`

See \`./scripts/deploy.sh --help\` for more options.
EOL
echo -e "${GREEN}✓ Created deployment README${NC}"

echo -e "\n${GREEN}Deployment configurations generated successfully!${NC}"
echo -e "${YELLOW}You can find all deployment configurations in the config/deployment directory.${NC}"
echo -e "${YELLOW}See config/deployment/README.md for usage instructions.${NC}"
