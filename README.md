# AutoLaunch Studio

AutoLaunch Studio is a comprehensive platform for creating, deploying, and managing various types of web applications, WordPress themes/plugins, browser extensions, mobile apps, and more.

## Features

- **Multi-Platform Support**: Create websites, WordPress themes, WordPress plugins, browser extensions, and mobile apps
- **Browser-Based Frontend**: User-friendly interface for submitting prompts and managing applications
- **Admin Backend**: Manage user roles, view logs, and approve deployments
- **Auto-Launch Functionality**: Automatically deploy applications upon creation
- **Cursor AI Integration**: Development environment optimized for use with Cursor AI coding assistant
- **Multiple Deployment Methods**: Support for Docker, GitHub Actions, Vercel, and Netlify

## Getting Started

### Prerequisites

- Node.js 16.x or higher
- Docker and Docker Compose (for containerized deployment)
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/autolaunch-studio.git
   cd autolaunch-studio
   ```

2. Install dependencies:
   ```bash
   # Install frontend dependencies
   cd frontend
   npm install
   
   # Install backend dependencies
   cd ../backend
   npm install
   
   # Return to root directory
   cd ..
   ```

3. Generate deployment configurations:
   ```bash
   ./scripts/generate_deployment_configs.sh
   ```

4. Start the application using Docker:
   ```bash
   docker-compose up -d
   ```

5. Access the application:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001
   - WordPress (if enabled): http://localhost:8080

### Configuration

On first run, you'll be guided through a configuration wizard that will help you set up:

1. Admin account
2. System settings
3. Database connection
4. Platform support options
5. Deployment settings
6. External integrations

## Platform Support

### WordPress Themes and Plugins

AutoLaunch Studio provides comprehensive support for creating and deploying WordPress themes and plugins:

- **Theme Development**: Create custom WordPress themes with full customizer support
- **Plugin Development**: Build plugins with admin interfaces, shortcodes, and more
- **Testing Environment**: Integrated WordPress instance for testing themes and plugins
- **Deployment**: Package themes and plugins for distribution

### Browser Extensions

Create browser extensions for multiple browsers:

- **Multi-Browser Support**: Chrome, Firefox, Edge, Safari, and Opera
- **Extension Types**: Browser actions, page actions, content scripts, and more
- **Testing Environment**: Automated testing of extensions in multiple browsers
- **Packaging**: Build and package extensions for distribution

### Mobile Apps

Develop mobile applications for various platforms:

- **Platform Support**: Android, iOS, and Progressive Web Apps
- **Framework Options**: React Native, Flutter, and native development
- **Build Tools**: Integrated build tools for compiling mobile applications
- **Distribution**: Package apps for app store submission

## Deployment

AutoLaunch Studio supports multiple deployment methods:

- **Docker**: Containerized deployment for all application types
- **GitHub Actions**: CI/CD pipeline deployment
- **Vercel**: Serverless deployment for web applications
- **Netlify**: JAMstack deployment with serverless functions

For detailed deployment instructions, see the [Deployment Guide](docs/deployment-guide.md).

## Using with Cursor AI

AutoLaunch Studio is optimized for development with Cursor AI, a coding assistant integrated with VS Code/Visual Studio. For information on using Cursor AI with AutoLaunch Studio, see the [Cursor AI Guide](docs/cursor-ai-guide.md).

## Directory Structure

```
autolaunch-studio/
├── frontend/               # React frontend application
│   ├── public/             # Static files
│   └── src/                # Source code
│       ├── components/     # Reusable components
│       └── pages/          # Page components
├── backend/                # Node.js backend application
│   └── src/
│       ├── controllers/    # Request handlers
│       ├── models/         # Database models
│       ├── routes/         # API routes
│       └── services/       # Business logic
├── config/                 # Configuration files
│   └── nginx.conf          # Nginx configuration
├── scripts/                # Utility scripts
│   ├── cursor-ai/          # Cursor AI integration scripts
│   ├── deploy.sh           # Deployment script
│   └── generate_deployment_configs.sh  # Configuration generator
├── mobile-builder/         # Mobile app building tools
├── extension-tester/       # Browser extension testing tools
└── docs/                   # Documentation
```

## Development

### Running in Development Mode

```bash
# Start frontend in development mode
cd frontend
npm run dev

# Start backend in development mode
cd backend
npm run dev
```

### Testing

```bash
# Run validation tests
./test_validation.sh
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Cursor AI for development assistance
- All open-source libraries used in this project
