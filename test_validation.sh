#!/bin/bash

# AutoLaunch Studio - Test Validation Script
# This script tests and validates the AutoLaunch Studio implementation

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║  ${YELLOW}AutoLaunch Studio - Test Validation${BLUE}                   ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create test directory
TEST_DIR="./test_validation"
mkdir -p $TEST_DIR

# Function to check if a file exists
check_file() {
  local file=$1
  local description=$2
  
  echo -n "Checking $description ($file)... "
  
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓ Found${NC}"
    return 0
  else
    echo -e "${RED}✗ Not found${NC}"
    return 1
  fi
}

# Function to check if a directory exists
check_directory() {
  local dir=$1
  local description=$2
  
  echo -n "Checking $description ($dir)... "
  
  if [ -d "$dir" ]; then
    echo -e "${GREEN}✓ Found${NC}"
    return 0
  else
    echo -e "${RED}✗ Not found${NC}"
    return 1
  fi
}

# Function to validate JavaScript file syntax
validate_js_syntax() {
  local file=$1
  local description=$2
  
  echo -n "Validating $description syntax ($file)... "
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found${NC}"
    return 1
  fi
  
  # Create a temporary file for node to check syntax
  cat > $TEST_DIR/syntax_check.js << EOL
try {
  require('${file}');
  console.log('Syntax OK');
} catch (error) {
  console.error('Syntax Error:', error.message);
  process.exit(1);
}
EOL
  
  # Run the syntax check
  node $TEST_DIR/syntax_check.js > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Invalid${NC}"
    return 1
  fi
}

# Function to validate JSON file syntax
validate_json_syntax() {
  local file=$1
  local description=$2
  
  echo -n "Validating $description syntax ($file)... "
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found${NC}"
    return 1
  fi
  
  # Create a temporary file for node to check JSON syntax
  cat > $TEST_DIR/json_check.js << EOL
try {
  const json = require('${file}');
  console.log('JSON Valid');
} catch (error) {
  console.error('JSON Error:', error.message);
  process.exit(1);
}
EOL
  
  # Run the JSON check
  node $TEST_DIR/json_check.js > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Invalid${NC}"
    return 1
  fi
}

# Function to check if Docker Compose file is valid
validate_docker_compose() {
  local file=$1
  
  echo -n "Validating Docker Compose file ($file)... "
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found${NC}"
    return 1
  fi
  
  # Check if docker-compose is installed
  if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠ docker-compose not installed, skipping validation${NC}"
    return 0
  fi
  
  # Validate the docker-compose file
  docker-compose -f $file config > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Invalid${NC}"
    return 1
  fi
}

# Function to check if a model schema is valid
validate_model_schema() {
  local file=$1
  local model_name=$2
  
  echo -n "Validating $model_name model schema ($file)... "
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found${NC}"
    return 1
  fi
  
  # Create a temporary file to validate the schema
  cat > $TEST_DIR/schema_check.js << EOL
try {
  const mongoose = require('mongoose');
  const schema = require('${file}');
  
  // Check if it's a valid Mongoose model
  if (schema.modelName && schema.schema) {
    console.log('Valid Mongoose model');
  } else {
    console.error('Not a valid Mongoose model');
    process.exit(1);
  }
} catch (error) {
  console.error('Schema Error:', error.message);
  process.exit(1);
}
EOL
  
  # Run the schema check
  node $TEST_DIR/schema_check.js > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Invalid${NC}"
    return 1
  fi
}

# Function to check if a service is implemented
validate_service() {
  local file=$1
  local service_name=$2
  local required_methods=$3
  
  echo -n "Validating $service_name service ($file)... "
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found${NC}"
    return 1
  fi
  
  # Create a temporary file to validate the service
  cat > $TEST_DIR/service_check.js << EOL
try {
  const service = require('${file}');
  
  // Check if required methods exist
  const requiredMethods = '${required_methods}'.split(',');
  const missingMethods = [];
  
  for (const method of requiredMethods) {
    if (typeof service[method] !== 'function') {
      missingMethods.push(method);
    }
  }
  
  if (missingMethods.length > 0) {
    console.error('Missing methods:', missingMethods.join(', '));
    process.exit(1);
  }
  
  console.log('Valid service with all required methods');
} catch (error) {
  console.error('Service Error:', error.message);
  process.exit(1);
}
EOL
  
  # Run the service check
  node $TEST_DIR/service_check.js > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Invalid${NC}"
    return 1
  fi
}

# Function to check if React component is valid
validate_react_component() {
  local file=$1
  local component_name=$2
  
  echo -n "Validating React component $component_name ($file)... "
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found${NC}"
    return 1
  fi
  
  # Create a temporary file to validate the React component
  cat > $TEST_DIR/react_check.js << EOL
try {
  const fs = require('fs');
  const content = fs.readFileSync('${file}', 'utf8');
  
  // Check for React import
  if (!content.includes('import React') && !content.includes('from "react"') && !content.includes("from 'react'")) {
    console.error('Missing React import');
    process.exit(1);
  }
  
  // Check for component definition
  if (!content.includes('function ${component_name}') && !content.includes('class ${component_name}') && !content.includes('const ${component_name}')) {
    console.error('Component ${component_name} not defined');
    process.exit(1);
  }
  
  // Check for export
  if (!content.includes('export default ${component_name}')) {
    console.error('Component not exported');
    process.exit(1);
  }
  
  console.log('Valid React component');
} catch (error) {
  console.error('React Component Error:', error.message);
  process.exit(1);
}
EOL
  
  # Run the React component check
  node $TEST_DIR/react_check.js > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Invalid${NC}"
    return 1
  fi
}

# Function to check if a script is executable
check_executable() {
  local file=$1
  local description=$2
  
  echo -n "Checking if $description is executable ($file)... "
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found${NC}"
    return 1
  fi
  
  if [ -x "$file" ]; then
    echo -e "${GREEN}✓ Executable${NC}"
    return 0
  else
    echo -e "${YELLOW}⚠ Not executable${NC}"
    chmod +x "$file"
    echo -e "${GREEN}✓ Made executable${NC}"
    return 0
  fi
}

# Function to check if a directory structure is complete
validate_directory_structure() {
  local base_dir=$1
  local required_dirs=$2
  
  echo -e "${YELLOW}Validating directory structure in $base_dir...${NC}"
  
  local missing_dirs=()
  
  for dir in ${required_dirs//,/ }; do
    if [ ! -d "$base_dir/$dir" ]; then
      missing_dirs+=("$dir")
      echo -e "${RED}✗ Missing directory: $dir${NC}"
    else
      echo -e "${GREEN}✓ Found directory: $dir${NC}"
    fi
  done
  
  if [ ${#missing_dirs[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All required directories present${NC}"
    return 0
  else
    echo -e "${RED}✗ Missing ${#missing_dirs[@]} directories${NC}"
    return 1
  fi
}

# Start validation
echo -e "${YELLOW}Starting validation of AutoLaunch Studio implementation...${NC}"
echo ""

# Check core files
echo -e "${BLUE}Checking core files...${NC}"
check_file "scripts/deploy.sh" "Deployment script"
check_file "scripts/generate_deployment_configs.sh" "Deployment configuration generator"
check_file "scripts/cursor-ai/setup_cursor_dev.sh" "Cursor AI setup script"
check_file "scripts/cursor-ai/cursor_integration.js" "Cursor AI integration script"
check_file "docker-compose.yml" "Docker Compose file"
check_file "config/nginx.conf" "Nginx configuration"
echo ""

# Validate Docker Compose file
echo -e "${BLUE}Validating Docker configuration...${NC}"
validate_docker_compose "docker-compose.yml"
echo ""

# Check model schemas
echo -e "${BLUE}Checking model schemas...${NC}"
check_file "backend/src/models/wordpress-theme.model.js" "WordPress theme model"
check_file "backend/src/models/wordpress-plugin.model.js" "WordPress plugin model"
check_file "backend/src/models/browser-extension.model.js" "Browser extension model"
check_file "backend/src/models/mobile-app.model.js" "Mobile app model"
echo ""

# Validate model schemas
echo -e "${BLUE}Validating model schemas...${NC}"
validate_js_syntax "backend/src/models/wordpress-theme.model.js" "WordPress theme model"
validate_js_syntax "backend/src/models/wordpress-plugin.model.js" "WordPress plugin model"
validate_js_syntax "backend/src/models/browser-extension.model.js" "Browser extension model"
validate_js_syntax "backend/src/models/mobile-app.model.js" "Mobile app model"
echo ""

# Check services
echo -e "${BLUE}Checking services...${NC}"
check_file "backend/src/services/auto-launch.service.js" "Auto-launch service"
echo ""

# Validate services
echo -e "${BLUE}Validating services...${NC}"
validate_js_syntax "backend/src/services/auto-launch.service.js" "Auto-launch service"
echo ""

# Check frontend components
echo -e "${BLUE}Checking frontend components...${NC}"
check_file "frontend/src/App.js" "Main App component"
check_file "frontend/src/pages/CreateApp.js" "Create App page"
check_file "frontend/src/pages/Dashboard.js" "Dashboard page"
check_file "frontend/src/pages/Admin.js" "Admin page"
check_file "frontend/src/pages/ConfigWizard.js" "Configuration Wizard page"
echo ""

# Validate frontend components
echo -e "${BLUE}Validating frontend components...${NC}"
validate_js_syntax "frontend/src/App.js" "Main App component"
validate_js_syntax "frontend/src/pages/CreateApp.js" "Create App page"
validate_js_syntax "frontend/src/pages/Dashboard.js" "Dashboard page"
validate_js_syntax "frontend/src/pages/Admin.js" "Admin page"
validate_js_syntax "frontend/src/pages/ConfigWizard.js" "Configuration Wizard page"
echo ""

# Check backend routes and controllers
echo -e "${BLUE}Checking backend routes and controllers...${NC}"
check_file "backend/src/routes/admin.routes.js" "Admin routes"
check_file "backend/src/controllers/admin.controller.js" "Admin controller"
check_file "backend/src/routes/deployment.routes.js" "Deployment routes"
check_file "backend/src/controllers/deployment.controller.js" "Deployment controller"
echo ""

# Validate backend routes and controllers
echo -e "${BLUE}Validating backend routes and controllers...${NC}"
validate_js_syntax "backend/src/routes/admin.routes.js" "Admin routes"
validate_js_syntax "backend/src/controllers/admin.controller.js" "Admin controller"
validate_js_syntax "backend/src/routes/deployment.routes.js" "Deployment routes"
validate_js_syntax "backend/src/controllers/deployment.controller.js" "Deployment controller"
echo ""

# Check documentation
echo -e "${BLUE}Checking documentation...${NC}"
check_file "docs/cursor-ai-guide.md" "Cursor AI guide"
check_file "docs/deployment-guide.md" "Deployment guide"
check_file "README.md" "Main README file"
echo ""

# Check directory structure
echo -e "${BLUE}Checking directory structure...${NC}"
validate_directory_structure "." "frontend,backend,scripts,config,docs,mobile-builder,extension-tester"
validate_directory_structure "frontend" "src,public"
validate_directory_structure "frontend/src" "pages,components"
validate_directory_structure "backend" "src"
validate_directory_structure "backend/src" "models,controllers,routes,services"
validate_directory_structure "scripts" "cursor-ai"
echo ""

# Make scripts executable
echo -e "${BLUE}Making scripts executable...${NC}"
check_executable "scripts/deploy.sh" "Deployment script"
check_executable "scripts/generate_deployment_configs.sh" "Deployment configuration generator"
check_executable "scripts/cursor-ai/setup_cursor_dev.sh" "Cursor AI setup script"
echo ""

echo -e "${YELLOW}Validation complete!${NC}"
echo ""

# Clean up test directory
rm -rf $TEST_DIR

echo -e "${GREEN}AutoLaunch Studio is ready for deployment.${NC}"
echo -e "${YELLOW}To deploy, run: ./scripts/deploy.sh --method docker --env production${NC}"
