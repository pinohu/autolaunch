#!/bin/bash

# AutoLaunch Studio - Standard Deployment Script
# This script handles deployment of AutoLaunch Studio using standard deployment methods

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEPLOYMENT_METHOD="docker"
ENVIRONMENT="production"
APP_NAME="AutoLaunch Studio"
FRONTEND_PORT=3000
BACKEND_PORT=3001
DEPLOY_DIR="./deploy"

# Display banner
function display_banner() {
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║                                                            ║${NC}"
  echo -e "${BLUE}║  ${YELLOW}AutoLaunch Studio - Standard Deployment${BLUE}                ║${NC}"
  echo -e "${BLUE}║                                                            ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

# Display help
function display_help() {
  echo -e "Usage: $0 [options]"
  echo -e ""
  echo -e "Options:"
  echo -e "  -m, --method METHOD    Deployment method (docker, github, vercel, netlify)"
  echo -e "  -e, --env ENV          Environment (development, staging, production)"
  echo -e "  -n, --name NAME        Application name"
  echo -e "  -d, --dir DIRECTORY    Deployment directory"
  echo -e "  -h, --help             Display this help message"
  echo -e ""
  echo -e "Examples:"
  echo -e "  $0 --method docker --env production"
  echo -e "  $0 --method vercel --name \"My App\""
  echo -e ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -m|--method)
      DEPLOYMENT_METHOD="$2"
      shift
      shift
      ;;
    -e|--env)
      ENVIRONMENT="$2"
      shift
      shift
      ;;
    -n|--name)
      APP_NAME="$2"
      shift
      shift
      ;;
    -d|--dir)
      DEPLOY_DIR="$2"
      shift
      shift
      ;;
    -h|--help)
      display_help
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      display_help
      exit 1
      ;;
  esac
done

# Validate deployment method
if [[ ! "$DEPLOYMENT_METHOD" =~ ^(docker|github|vercel|netlify)$ ]]; then
  echo -e "${RED}Invalid deployment method: $DEPLOYMENT_METHOD${NC}"
  echo -e "${YELLOW}Valid methods are: docker, github, vercel, netlify${NC}"
  exit 1
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
  echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
  echo -e "${YELLOW}Valid environments are: development, staging, production${NC}"
  exit 1
fi

# Create deployment directory if it doesn't exist
mkdir -p "$DEPLOY_DIR"

# Display banner and configuration
display_banner
echo -e "${YELLOW}Deployment Configuration:${NC}"
echo -e "  Method:      ${GREEN}$DEPLOYMENT_METHOD${NC}"
echo -e "  Environment: ${GREEN}$ENVIRONMENT${NC}"
echo -e "  App Name:    ${GREEN}$APP_NAME${NC}"
echo -e "  Deploy Dir:  ${GREEN}$DEPLOY_DIR${NC}"
echo -e ""

# Function to deploy using Docker
function deploy_docker() {
  echo -e "${YELLOW}Deploying using Docker...${NC}"
  
  # Check if Docker is installed
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker before continuing.${NC}"
    exit 1
  fi
  
  # Check if Docker Compose is installed
  if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose before continuing.${NC}"
    exit 1
  fi
  
  # Create .env file for Docker Compose
  echo -e "${YELLOW}Creating .env file...${NC}"
  cat > .env << EOL
NODE_ENV=$ENVIRONMENT
APP_NAME=$APP_NAME
FRONTEND_PORT=$FRONTEND_PORT
BACKEND_PORT=$BACKEND_PORT
MONGODB_URI=mongodb://mongo:27017/autolaunch
JWT_SECRET=$(openssl rand -hex 32)
EOL
  echo -e "${GREEN}✓ Created .env file${NC}"
  
  # Build and start Docker containers
  echo -e "${YELLOW}Building and starting Docker containers...${NC}"
  docker-compose up -d --build
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker deployment successful!${NC}"
    echo -e "${GREEN}The application is now available at:${NC}"
    echo -e "${GREEN}Frontend: http://localhost:$FRONTEND_PORT${NC}"
    echo -e "${GREEN}Backend API: http://localhost:$BACKEND_PORT${NC}"
    
    # Save deployment information
    mkdir -p "$DEPLOY_DIR/docker"
    cat > "$DEPLOY_DIR/docker/deployment-info.txt" << EOL
Deployment Method: Docker
Environment: $ENVIRONMENT
App Name: $APP_NAME
Deployment Time: $(date)
Frontend URL: http://localhost:$FRONTEND_PORT
Backend URL: http://localhost:$BACKEND_PORT
EOL
    echo -e "${GREEN}✓ Deployment information saved to $DEPLOY_DIR/docker/deployment-info.txt${NC}"
  else
    echo -e "${RED}✗ Docker deployment failed. Please check the logs for more information.${NC}"
    exit 1
  fi
}

# Function to deploy using GitHub Actions
function deploy_github() {
  echo -e "${YELLOW}Setting up GitHub Actions deployment...${NC}"
  
  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows
  
  # Create GitHub Actions workflow file
  echo -e "${YELLOW}Creating GitHub Actions workflow file...${NC}"
  cat > .github/workflows/deploy.yml << EOL
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
  
  # Create setup instructions
  mkdir -p "$DEPLOY_DIR/github"
  cat > "$DEPLOY_DIR/github/setup-instructions.md" << EOL
# GitHub Actions Deployment Setup

Follow these steps to set up GitHub Actions deployment for AutoLaunch Studio:

1. Push your code to a GitHub repository
2. Add the following secrets to your GitHub repository:
   - \`HOST\`: Your server hostname or IP address
   - \`USERNAME\`: Your SSH username
   - \`SSH_KEY\`: Your SSH private key
3. Update the deployment path in \`.github/workflows/deploy.yml\` to match your server's directory structure
4. Push changes to the main branch to trigger deployment

## Server Requirements

- Node.js 16.x or higher
- PM2 for process management
- Git

## Deployment Information

- Deployment Method: GitHub Actions
- Environment: $ENVIRONMENT
- App Name: $APP_NAME
- Setup Time: $(date)
EOL
  echo -e "${GREEN}✓ Setup instructions saved to $DEPLOY_DIR/github/setup-instructions.md${NC}"
  
  echo -e "${YELLOW}GitHub Actions deployment setup complete!${NC}"
  echo -e "${YELLOW}Please follow the instructions in $DEPLOY_DIR/github/setup-instructions.md to complete the setup.${NC}"
}

# Function to deploy using Vercel
function deploy_vercel() {
  echo -e "${YELLOW}Setting up Vercel deployment...${NC}"
  
  # Check if Vercel CLI is installed
  if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}Vercel CLI not found. Installing...${NC}"
    npm install -g vercel
  fi
  
  # Create vercel.json file
  echo -e "${YELLOW}Creating vercel.json file...${NC}"
  cat > vercel.json << EOL
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
      "dest": "frontend/$1"
    }
  ],
  "env": {
    "NODE_ENV": "$ENVIRONMENT",
    "APP_NAME": "$APP_NAME"
  }
}
EOL
  echo -e "${GREEN}✓ Created vercel.json file${NC}"
  
  # Create setup instructions
  mkdir -p "$DEPLOY_DIR/vercel"
  cat > "$DEPLOY_DIR/vercel/setup-instructions.md" << EOL
# Vercel Deployment Setup

Follow these steps to deploy AutoLaunch Studio to Vercel:

1. Install Vercel CLI if you haven't already:
   \`\`\`
   npm install -g vercel
   \`\`\`

2. Login to Vercel:
   \`\`\`
   vercel login
   \`\`\`

3. Deploy to Vercel:
   \`\`\`
   vercel --prod
   \`\`\`

4. Set up environment variables in the Vercel dashboard:
   - \`NODE_ENV\`: $ENVIRONMENT
   - \`APP_NAME\`: $APP_NAME
   - \`MONGODB_URI\`: Your MongoDB connection string
   - \`JWT_SECRET\`: Your JWT secret

## Deployment Information

- Deployment Method: Vercel
- Environment: $ENVIRONMENT
- App Name: $APP_NAME
- Setup Time: $(date)
EOL
  echo -e "${GREEN}✓ Setup instructions saved to $DEPLOY_DIR/vercel/setup-instructions.md${NC}"
  
  echo -e "${YELLOW}Vercel deployment setup complete!${NC}"
  echo -e "${YELLOW}Please follow the instructions in $DEPLOY_DIR/vercel/setup-instructions.md to complete the deployment.${NC}"
}

# Function to deploy using Netlify
function deploy_netlify() {
  echo -e "${YELLOW}Setting up Netlify deployment...${NC}"
  
  # Check if Netlify CLI is installed
  if ! command -v netlify &> /dev/null; then
    echo -e "${YELLOW}Netlify CLI not found. Installing...${NC}"
    npm install -g netlify-cli
  fi
  
  # Create netlify.toml file
  echo -e "${YELLOW}Creating netlify.toml file...${NC}"
  cat > netlify.toml << EOL
[build]
  base = "frontend"
  publish = "build"
  command = "npm run build"

[build.environment]
  REACT_APP_API_URL = "/.netlify/functions/api"
  NODE_ENV = "$ENVIRONMENT"
  APP_NAME = "$APP_NAME"

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
  echo -e "${GREEN}✓ Created netlify.toml file${NC}"
  
  # Create Netlify functions directory
  mkdir -p backend/netlify/functions
  
  # Create API function for Netlify
  echo -e "${YELLOW}Creating Netlify API function...${NC}"
  cat > backend/netlify/functions/api.js << EOL
const express = require('express');
const serverless = require('serverless-http');
const app = require('../../src/server');

// Wrap the Express app with serverless
module.exports.handler = serverless(app);
EOL
  echo -e "${GREEN}✓ Created Netlify API function${NC}"
  
  # Create setup instructions
  mkdir -p "$DEPLOY_DIR/netlify"
  cat > "$DEPLOY_DIR/netlify/setup-instructions.md" << EOL
# Netlify Deployment Setup

Follow these steps to deploy AutoLaunch Studio to Netlify:

1. Install Netlify CLI if you haven't already:
   \`\`\`
   npm install -g netlify-cli
   \`\`\`

2. Login to Netlify:
   \`\`\`
   netlify login
   \`\`\`

3. Initialize Netlify site:
   \`\`\`
   netlify init
   \`\`\`

4. Deploy to Netlify:
   \`\`\`
   netlify deploy --prod
   \`\`\`

5. Set up environment variables in the Netlify dashboard:
   - \`NODE_ENV\`: $ENVIRONMENT
   - \`APP_NAME\`: $APP_NAME
   - \`MONGODB_URI\`: Your MongoDB connection string
   - \`JWT_SECRET\`: Your JWT secret

## Additional Requirements

Install the serverless-http package in your backend:
\`\`\`
cd backend
npm install --save serverless-http
\`\`\`

## Deployment Information

- Deployment Method: Netlify
- Environment: $ENVIRONMENT
- App Name: $APP_NAME
- Setup Time: $(date)
EOL
  echo -e "${GREEN}✓ Setup instructions saved to $DEPLOY_DIR/netlify/setup-instructions.md${NC}"
  
  echo -e "${YELLOW}Netlify deployment setup complete!${NC}"
  echo -e "${YELLOW}Please follow the instructions in $DEPLOY_DIR/netlify/setup-instructions.md to complete the deployment.${NC}"
}

# Deploy based on selected method
case $DEPLOYMENT_METHOD in
  docker)
    deploy_docker
    ;;
  github)
    deploy_github
    ;;
  vercel)
    deploy_vercel
    ;;
  netlify)
    deploy_netlify
    ;;
esac

echo -e "\n${GREEN}Deployment setup completed successfully!${NC}"
echo -e "${YELLOW}Thank you for using AutoLaunch Studio.${NC}"
