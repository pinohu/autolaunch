# Deployment Guide for AutoLaunch Studio

This guide explains how to deploy AutoLaunch Studio using various standard deployment methods.

## Overview

AutoLaunch Studio supports multiple deployment methods to accommodate different hosting environments and preferences:

1. **Docker Deployment** - For containerized deployment with Docker and Docker Compose
2. **GitHub Actions** - For CI/CD pipeline deployment
3. **Vercel Deployment** - For serverless deployment of frontend and backend
4. **Netlify Deployment** - For JAMstack deployment with serverless functions

## Prerequisites

- Node.js 16.x or higher
- npm or yarn
- Git

Additional requirements depend on your chosen deployment method:

- **Docker Deployment**: Docker and Docker Compose
- **GitHub Actions**: GitHub account and a server for hosting
- **Vercel Deployment**: Vercel account
- **Netlify Deployment**: Netlify account

## Deployment Methods

### Docker Deployment

Docker provides a containerized deployment solution that ensures consistency across environments.

#### Steps:

1. **Prepare your environment**:
   ```bash
   # Generate deployment configurations
   ./scripts/generate_deployment_configs.sh
   
   # Copy Docker configuration files
   cp config/deployment/docker-compose.yml ./
   cp config/deployment/docker/frontend.Dockerfile frontend/Dockerfile
   cp config/deployment/docker/backend.Dockerfile backend/Dockerfile
   ```

2. **Create a .env file**:
   ```
   NODE_ENV=production
   FRONTEND_PORT=3000
   BACKEND_PORT=3001
   MONGODB_URI=mongodb://mongo:27017/autolaunch
   JWT_SECRET=your_secure_jwt_secret
   ```

3. **Deploy with Docker Compose**:
   ```bash
   docker-compose up -d
   ```

4. **Access your application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001

### GitHub Actions Deployment

GitHub Actions provides CI/CD pipeline deployment to your own server.

#### Steps:

1. **Push your code to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/autolaunch-studio.git
   git push -u origin main
   ```

2. **Set up GitHub Actions workflow**:
   ```bash
   mkdir -p .github/workflows
   cp config/deployment/github-actions/deploy.yml .github/workflows/
   ```

3. **Add GitHub repository secrets**:
   - `HOST`: Your server hostname or IP address
   - `USERNAME`: Your SSH username
   - `SSH_KEY`: Your SSH private key

4. **Update deployment path**:
   Edit `.github/workflows/deploy.yml` to update the deployment path on your server.

5. **Push changes to trigger deployment**:
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Add GitHub Actions workflow"
   git push
   ```

### Vercel Deployment

Vercel provides a serverless deployment platform ideal for frontend applications with API routes.

#### Steps:

1. **Prepare your project**:
   ```bash
   cp config/deployment/vercel/vercel.json ./
   ```

2. **Install Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

3. **Login to Vercel**:
   ```bash
   vercel login
   ```

4. **Deploy to Vercel**:
   ```bash
   vercel --prod
   ```

5. **Configure environment variables**:
   In the Vercel dashboard, add the following environment variables:
   - `NODE_ENV`: `production`
   - `MONGODB_URI`: Your MongoDB connection string
   - `JWT_SECRET`: Your JWT secret

### Netlify Deployment

Netlify provides a JAMstack deployment platform with serverless functions.

#### Steps:

1. **Prepare your project**:
   ```bash
   cp config/deployment/netlify/netlify.toml ./
   mkdir -p backend/netlify/functions
   cp config/deployment/netlify/functions/api.js backend/netlify/functions/
   ```

2. **Install serverless-http package**:
   ```bash
   cd backend
   npm install --save serverless-http
   cd ..
   ```

3. **Install Netlify CLI**:
   ```bash
   npm install -g netlify-cli
   ```

4. **Login to Netlify**:
   ```bash
   netlify login
   ```

5. **Initialize Netlify site**:
   ```bash
   netlify init
   ```

6. **Deploy to Netlify**:
   ```bash
   netlify deploy --prod
   ```

7. **Configure environment variables**:
   In the Netlify dashboard, add the following environment variables:
   - `NODE_ENV`: `production`
   - `MONGODB_URI`: Your MongoDB connection string
   - `JWT_SECRET`: Your JWT secret

## Using the Deployment Script

For easier deployment, use the provided deployment script:

```bash
# Make the script executable
chmod +x scripts/deploy.sh

# Display help
./scripts/deploy.sh --help

# Deploy using Docker
./scripts/deploy.sh --method docker --env production

# Deploy using GitHub Actions
./scripts/deploy.sh --method github --env production

# Deploy using Vercel
./scripts/deploy.sh --method vercel --env production

# Deploy using Netlify
./scripts/deploy.sh --method netlify --env production
```

## Deployment Configuration Generator

To generate deployment configurations for all supported platforms:

```bash
# Make the script executable
chmod +x scripts/generate_deployment_configs.sh

# Generate configurations
./scripts/generate_deployment_configs.sh
```

This will create configuration files in the `config/deployment` directory.

## Troubleshooting

### Docker Deployment Issues

- **Container fails to start**: Check logs with `docker-compose logs`
- **Database connection issues**: Ensure MongoDB container is running with `docker ps`
- **Port conflicts**: Change the port mappings in `docker-compose.yml`

### GitHub Actions Issues

- **Deployment fails**: Check the GitHub Actions logs in your repository
- **SSH connection issues**: Verify your SSH key and server details
- **Permission issues**: Ensure your SSH user has the necessary permissions

### Vercel/Netlify Issues

- **Build fails**: Check the build logs in the respective dashboard
- **API routes not working**: Verify your API routes configuration
- **Environment variables**: Ensure all required environment variables are set

## Next Steps

After deployment, you should:

1. Set up your admin account through the configuration wizard
2. Configure your application settings
3. Set up monitoring and logging
4. Implement a backup strategy for your database

For more information, refer to the [AutoLaunch Studio Documentation](../README.md).
