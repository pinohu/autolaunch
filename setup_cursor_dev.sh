#!/bin/bash

# AutoLaunch Studio - Cursor AI Development Setup Script
# This script sets up the development environment for using Cursor AI with AutoLaunch Studio

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║  ${YELLOW}AutoLaunch Studio - Cursor AI Development Setup${BLUE}          ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script will set up your development environment for using Cursor AI with AutoLaunch Studio.${NC}"
echo ""

# Check if Cursor AI is installed
echo -e "${YELLOW}Checking for Cursor AI installation...${NC}"
if [ -d "/Applications/Cursor.app" ] || [ -d "$HOME/Applications/Cursor.app" ] || [ -d "/usr/share/applications/cursor" ] || [ -d "$HOME/.local/share/applications/cursor" ]; then
    echo -e "${GREEN}✓ Cursor AI appears to be installed.${NC}"
else
    echo -e "${RED}✗ Cursor AI does not appear to be installed.${NC}"
    echo -e "${YELLOW}Please download and install Cursor AI from https://cursor.sh before continuing.${NC}"
    echo -e "${YELLOW}After installing Cursor AI, run this script again.${NC}"
    exit 1
fi

# Create .vscode directory if it doesn't exist
echo -e "${YELLOW}Setting up VS Code / Cursor AI configuration...${NC}"
mkdir -p .vscode

# Create settings.json for Cursor AI
cat > .vscode/settings.json << EOL
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "javascript.updateImportsOnFileMove.enabled": "always",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "cursor.showWhatsNewOnStartup": false,
  "cursor.enableTelemetry": false,
  "cursor.features.chatWindow.enabled": true,
  "cursor.features.copilot.enableAutoCompletions": true
}
EOL
echo -e "${GREEN}✓ Created VS Code settings for Cursor AI.${NC}"

# Create extensions.json for recommended extensions
cat > .vscode/extensions.json << EOL
{
  "recommendations": [
    "cursor.cursor"
  ]
}
EOL
echo -e "${GREEN}✓ Created recommended extensions file.${NC}"

# Create cursor-prompts directory
echo -e "${YELLOW}Creating Cursor AI prompts directory...${NC}"
mkdir -p docs/cursor-prompts

# Create README.md for cursor-prompts
cat > docs/cursor-prompts/README.md << EOL
# Cursor AI Prompts for AutoLaunch Studio

This directory contains helpful prompts for using Cursor AI with AutoLaunch Studio.

## How to Use These Prompts

1. Open your project in Cursor AI
2. Press Cmd+K (Mac) or Ctrl+K (Windows/Linux) to open the AI chat
3. Copy and paste a prompt from one of the prompt files
4. Customize the prompt by replacing the placeholders in [square brackets]
5. Send the prompt to Cursor AI
6. Review and refine the generated code as needed

## Available Prompt Categories

- [General Development](general-development.md)
- [Frontend Development](frontend-development.md)
- [Backend Development](backend-development.md)
- [WordPress Development](wordpress-development.md)
- [Browser Extensions](browser-extensions.md)
EOL
echo -e "${GREEN}✓ Created Cursor AI prompts README.${NC}"

# Create general-development.md
cat > docs/cursor-prompts/general-development.md << EOL
# General Development Prompts for Cursor AI

## Project Structure

\`\`\`
Analyze the current project structure and suggest improvements for better organization and maintainability.
\`\`\`

## Code Review

\`\`\`
Review the following code for potential issues, bugs, and improvements:

\`\`\`\`
[paste your code here]
\`\`\`\`
\`\`\`

## Documentation

\`\`\`
Generate comprehensive documentation for the following code:

\`\`\`\`
[paste your code here]
\`\`\`\`
\`\`\`

## Testing

\`\`\`
Generate unit tests for the following function:

\`\`\`\`
[paste your function here]
\`\`\`\`
\`\`\`

## Performance Optimization

\`\`\`
Analyze the following code for performance issues and suggest optimizations:

\`\`\`\`
[paste your code here]
\`\`\`\`
\`\`\`
EOL
echo -e "${GREEN}✓ Created general development prompts.${NC}"

# Create frontend-development.md
cat > docs/cursor-prompts/frontend-development.md << EOL
# Frontend Development Prompts for Cursor AI

## React Component

\`\`\`
Create a React functional component named [ComponentName] that [describe what the component should do].

The component should accept the following props:
- [propName]: [propType] - [description]
- [propName]: [propType] - [description]

Include proper TypeScript types and styled-components for styling.
\`\`\`

## Form Component

\`\`\`
Create a React form component for [purpose of the form]. The form should include fields for:
- [field name]: [field type] - [validation requirements]
- [field name]: [field type] - [validation requirements]

Use Material-UI components and include form validation with error messages.
\`\`\`

## Dashboard Layout

\`\`\`
Create a dashboard layout component with the following sections:
- Header with logo, navigation, and user profile
- Sidebar with menu items
- Main content area
- Footer with copyright information

Make it responsive and use Material-UI components.
\`\`\`

## Data Visualization

\`\`\`
Create a data visualization component using [Chart.js/D3.js/Recharts] to display [type of data].

The component should:
- Accept data as a prop
- Allow customization of colors and labels
- Handle responsive resizing
- Include tooltips for data points
\`\`\`

## Animation

\`\`\`
Create an animation for [describe what to animate] using [CSS/Framer Motion/React Spring].

The animation should:
- Trigger on [event]
- Last for [duration] seconds
- Include [describe animation effects]
\`\`\`
EOL
echo -e "${GREEN}✓ Created frontend development prompts.${NC}"

# Create backend-development.md
cat > docs/cursor-prompts/backend-development.md << EOL
# Backend Development Prompts for Cursor AI

## API Endpoint

\`\`\`
Create an Express.js API endpoint for [purpose of endpoint].

The endpoint should:
- Accept [HTTP method] requests at [route path]
- Validate input using [validation library]
- Interact with the database to [describe database operation]
- Return appropriate responses and handle errors
\`\`\`

## Database Model

\`\`\`
Create a Mongoose schema for [model name] with the following fields:
- [field name]: [field type] - [description]
- [field name]: [field type] - [description]

Include validation, indexes, and any necessary virtual properties or methods.
\`\`\`

## Authentication

\`\`\`
Implement JWT authentication with the following features:
- User registration and login endpoints
- Password hashing using bcrypt
- JWT token generation and validation
- Protected routes middleware
- Refresh token mechanism
\`\`\`

## File Upload

\`\`\`
Create an endpoint for file uploads with the following requirements:
- Support for [file types]
- Maximum file size of [size]
- Store files in [storage location]
- Generate and return file URLs
- Include proper error handling
\`\`\`

## WebSocket

\`\`\`
Implement a WebSocket server for [purpose] with the following features:
- Connection handling
- Message broadcasting
- Room/channel support
- Authentication integration
- Error handling and reconnection logic
\`\`\`
EOL
echo -e "${GREEN}✓ Created backend development prompts.${NC}"

# Create wordpress-development.md
cat > docs/cursor-prompts/wordpress-development.md << EOL
# WordPress Development Prompts for Cursor AI

## Theme Functions

\`\`\`
Create WordPress theme functions.php file with the following features:
- Theme setup function
- Enqueue scripts and styles
- Register navigation menus
- Register widget areas
- Add theme support for [features]
- Include custom post types and taxonomies
\`\`\`

## Plugin Structure

\`\`\`
Create a WordPress plugin structure for [plugin name] that [plugin purpose].

Include:
- Main plugin file with plugin header
- Admin class for backend functionality
- Public class for frontend functionality
- Includes directory for helper functions
- Assets directory for CSS, JS, and images
\`\`\`

## Custom Post Type

\`\`\`
Create a WordPress custom post type for [post type name] with:
- Labels and registration arguments
- Custom taxonomies
- Custom meta boxes
- Admin columns
- Template files
\`\`\`

## Shortcode

\`\`\`
Create a WordPress shortcode for [purpose] that:
- Accepts attributes: [list attributes]
- Processes content: [describe processing]
- Returns formatted output
- Includes proper escaping and security measures
\`\`\`

## Theme Template

\`\`\`
Create a WordPress theme template for [template purpose] with:
- Header and footer integration
- Main content area
- Sidebar integration
- Responsive design
- Template-specific styling
\`\`\`
EOL
echo -e "${GREEN}✓ Created WordPress development prompts.${NC}"

# Create browser-extensions.md
cat > docs/cursor-prompts/browser-extensions.md << EOL
# Browser Extension Development Prompts for Cursor AI

## Manifest File

\`\`\`
Create a manifest.json file for a browser extension that [extension purpose].

Include:
- Basic information (name, version, description)
- Permissions: [list required permissions]
- Background scripts
- Content scripts
- Browser action or page action
- Icons and other assets
\`\`\`

## Content Script

\`\`\`
Create a content script for a browser extension that [script purpose].

The script should:
- Target pages matching [URL pattern]
- Manipulate the DOM to [describe manipulation]
- Handle user interactions
- Communicate with the background script
\`\`\`

## Background Script

\`\`\`
Create a background script for a browser extension that [script purpose].

The script should:
- Initialize on browser startup
- Handle messages from content scripts
- Manage extension state
- Interact with browser APIs: [list APIs]
- Implement event listeners for [list events]
\`\`\`

## Popup UI

\`\`\`
Create a popup UI for a browser extension with:
- HTML structure for [describe UI elements]
- CSS styling for a clean, modern interface
- JavaScript for interactivity
- Communication with background script
- User settings and preferences
\`\`\`

## Options Page

\`\`\`
Create an options page for a browser extension with:
- Settings for [list settings]
- Form controls for user input
- Storage and retrieval of user preferences
- Reset to defaults functionality
- Validation and error handling
\`\`\`
EOL
echo -e "${GREEN}✓ Created browser extension development prompts.${NC}"

# Create a README.md file for the project
echo -e "${YELLOW}Creating project README.md...${NC}"
cat > README.md << EOL
# AutoLaunch Studio

AutoLaunch Studio is a comprehensive platform for creating, deploying, and managing various types of web applications, mobile apps, WordPress themes/plugins, browser extensions, and more.

## Development with Cursor AI

This project is designed to be developed with [Cursor AI](https://cursor.sh), a coding assistant integrated with VS Code that helps with code generation, refactoring, and more.

### Getting Started with Cursor AI

1. Install Cursor AI from [https://cursor.sh](https://cursor.sh)
2. Open this project in Cursor AI
3. Use Cmd+K (Mac) or Ctrl+K (Windows/Linux) to open the AI chat
4. Start developing with AI assistance!

### Cursor AI Prompts

We've included a collection of helpful prompts for using Cursor AI with this project. You can find them in the [docs/cursor-prompts](docs/cursor-prompts) directory.

## Features

- **Multi-platform App Creation**: Create web applications, mobile apps, desktop apps, WordPress themes, WordPress plugins, browser extensions, and more
- **Browser-based Frontend**: User-friendly interface for creating and managing applications
- **Admin Dashboard**: Comprehensive admin interface for user management, deployment control, and system settings
- **Docker Deployment**: Complete Docker setup for easy deployment
- **Auto-launch Functionality**: Automatically deploy apps upon creation

## Installation

See the [Installation Guide](docs/installation.md) for detailed instructions.

## License

[MIT License](LICENSE)
EOL
echo -e "${GREEN}✓ Created project README.md.${NC}"

# Create a basic .gitignore file
echo -e "${YELLOW}Creating .gitignore file...${NC}"
cat > .gitignore << EOL
# Dependencies
node_modules/
/.pnp
.pnp.js

# Testing
/coverage

# Production
/build
/dist

# Misc
.DS_Store
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
EOL
echo -e "${GREEN}✓ Created .gitignore file.${NC}"

# Make the script executable
chmod +x scripts/cursor-ai/cursor_integration.js
echo -e "${GREEN}✓ Made cursor_integration.js executable.${NC}"

echo ""
echo -e "${GREEN}Setup complete! Your development environment is now configured for using Cursor AI with AutoLaunch Studio.${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Open this project in Cursor AI"
echo -e "2. Use Cmd+K (Mac) or Ctrl+K (Windows/Linux) to open the AI chat"
echo -e "3. Try using the prompts in the docs/cursor-prompts directory"
echo -e "4. Run the cursor_integration.js script for additional setup options:"
echo -e "   ${BLUE}node scripts/cursor-ai/cursor_integration.js${NC}"
echo ""
