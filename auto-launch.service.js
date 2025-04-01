const mongoose = require('mongoose');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const axios = require('axios');

/**
 * AutoLaunch Service
 * Handles automatic deployment of applications upon creation
 */
class AutoLaunchService {
  constructor() {
    this.deploymentMethods = {
      docker: this.deployWithDocker,
      github: this.deployWithGitHub,
      vercel: this.deployWithVercel,
      netlify: this.deployWithNetlify
    };
    
    // Default configuration
    this.config = {
      autoDeployEnabled: true,
      defaultEnvironment: 'staging',
      deploymentMethod: 'docker',
      requireApproval: true,
      notifyOnDeployment: true,
      baseUrl: 'https://apps.autolaunchstudio.com'
    };
    
    // Load configuration
    this.loadConfig();
  }
  
  /**
   * Load configuration from database or environment variables
   */
  async loadConfig() {
    try {
      // Try to load from database if available
      if (mongoose.connection.readyState === 1) {
        const Config = mongoose.model('Config');
        const config = await Config.findOne({ configType: 'deployment' });
        
        if (config) {
          this.config = {
            ...this.config,
            ...config.settings
          };
        }
      }
      
      // Override with environment variables if present
      if (process.env.AUTO_DEPLOY_ENABLED) {
        this.config.autoDeployEnabled = process.env.AUTO_DEPLOY_ENABLED === 'true';
      }
      
      if (process.env.DEFAULT_ENVIRONMENT) {
        this.config.defaultEnvironment = process.env.DEFAULT_ENVIRONMENT;
      }
      
      if (process.env.DEPLOYMENT_METHOD) {
        this.config.deploymentMethod = process.env.DEPLOYMENT_METHOD;
      }
      
      if (process.env.REQUIRE_APPROVAL) {
        this.config.requireApproval = process.env.REQUIRE_APPROVAL === 'true';
      }
      
      if (process.env.NOTIFY_ON_DEPLOYMENT) {
        this.config.notifyOnDeployment = process.env.NOTIFY_ON_DEPLOYMENT === 'true';
      }
      
      if (process.env.BASE_URL) {
        this.config.baseUrl = process.env.BASE_URL;
      }
      
      console.log('AutoLaunch configuration loaded:', this.config);
    } catch (error) {
      console.error('Error loading AutoLaunch configuration:', error);
    }
  }
  
  /**
   * Auto-launch an application
   * @param {Object} app - Application object
   * @param {String} appType - Type of application (website, wordpress-theme, wordpress-plugin, browser-extension, mobile-app)
   * @param {String} environment - Deployment environment (development, staging, production)
   * @returns {Promise<Object>} - Deployment result
   */
  async launchApp(app, appType, environment = null) {
    try {
      // Check if auto-deploy is enabled
      if (!this.config.autoDeployEnabled) {
        return {
          success: false,
          message: 'Auto-deploy is disabled in configuration',
          app
        };
      }
      
      // Use default environment if not specified
      const deployEnv = environment || this.config.defaultEnvironment;
      
      // Check if approval is required for production deployments
      if (deployEnv === 'production' && this.config.requireApproval && !app.approved) {
        return {
          success: false,
          message: 'Production deployment requires approval',
          status: 'pending_approval',
          app
        };
      }
      
      console.log(`Starting auto-launch for ${appType}: ${app.name} to ${deployEnv} environment`);
      
      // Create deployment record
      const deployment = await this.createDeploymentRecord(app, appType, deployEnv);
      
      // Prepare app files
      const appDir = await this.prepareAppFiles(app, appType);
      
      // Deploy using the configured method
      const deployMethod = this.deploymentMethods[this.config.deploymentMethod];
      
      if (!deployMethod) {
        throw new Error(`Unsupported deployment method: ${this.config.deploymentMethod}`);
      }
      
      // Execute deployment
      const result = await deployMethod.call(this, app, appType, deployEnv, appDir);
      
      // Update deployment record
      await this.updateDeploymentRecord(deployment._id, {
        status: result.success ? 'deployed' : 'failed',
        deployedUrl: result.url,
        logs: result.logs
      });
      
      // Send notification if enabled
      if (this.config.notifyOnDeployment) {
        await this.sendDeploymentNotification(app, result);
      }
      
      return {
        success: result.success,
        message: result.message,
        url: result.url,
        logs: result.logs,
        deployment: deployment._id,
        app
      };
    } catch (error) {
      console.error(`Error in auto-launch for ${app.name}:`, error);
      
      return {
        success: false,
        message: `Deployment failed: ${error.message}`,
        error: error.toString(),
        app
      };
    }
  }
  
  /**
   * Create a deployment record in the database
   * @param {Object} app - Application object
   * @param {String} appType - Type of application
   * @param {String} environment - Deployment environment
   * @returns {Promise<Object>} - Created deployment record
   */
  async createDeploymentRecord(app, appType, environment) {
    try {
      const Deployment = mongoose.model('Deployment');
      
      const deployment = new Deployment({
        app: app._id,
        appType,
        environment,
        deploymentMethod: this.config.deploymentMethod,
        status: 'in_progress',
        startTime: new Date(),
        createdBy: app.createdBy
      });
      
      await deployment.save();
      return deployment;
    } catch (error) {
      console.error('Error creating deployment record:', error);
      throw error;
    }
  }
  
  /**
   * Update a deployment record in the database
   * @param {String} deploymentId - Deployment ID
   * @param {Object} updates - Fields to update
   * @returns {Promise<Object>} - Updated deployment record
   */
  async updateDeploymentRecord(deploymentId, updates) {
    try {
      const Deployment = mongoose.model('Deployment');
      
      const deployment = await Deployment.findByIdAndUpdate(
        deploymentId,
        {
          ...updates,
          endTime: new Date()
        },
        { new: true }
      );
      
      return deployment;
    } catch (error) {
      console.error('Error updating deployment record:', error);
      throw error;
    }
  }
  
  /**
   * Prepare application files for deployment
   * @param {Object} app - Application object
   * @param {String} appType - Type of application
   * @returns {Promise<String>} - Path to prepared app directory
   */
  async prepareAppFiles(app, appType) {
    try {
      // Create base directory for app files
      const baseDir = path.join(process.cwd(), 'deploy', appType, app.slug);
      
      // Ensure directory exists
      if (!fs.existsSync(baseDir)) {
        fs.mkdirSync(baseDir, { recursive: true });
      }
      
      // Different preparation logic based on app type
      switch (appType) {
        case 'website':
          await this.prepareWebsiteFiles(app, baseDir);
          break;
          
        case 'wordpress-theme':
          await this.prepareWordPressThemeFiles(app, baseDir);
          break;
          
        case 'wordpress-plugin':
          await this.prepareWordPressPluginFiles(app, baseDir);
          break;
          
        case 'browser-extension':
          await this.prepareBrowserExtensionFiles(app, baseDir);
          break;
          
        case 'mobile-app':
          await this.prepareMobileAppFiles(app, baseDir);
          break;
          
        default:
          throw new Error(`Unsupported app type: ${appType}`);
      }
      
      return baseDir;
    } catch (error) {
      console.error('Error preparing app files:', error);
      throw error;
    }
  }
  
  /**
   * Prepare website files for deployment
   * @param {Object} app - Website object
   * @param {String} baseDir - Base directory for app files
   * @returns {Promise<void>}
   */
  async prepareWebsiteFiles(app, baseDir) {
    // Create necessary directories
    const srcDir = path.join(baseDir, 'src');
    const buildDir = path.join(baseDir, 'build');
    
    if (!fs.existsSync(srcDir)) {
      fs.mkdirSync(srcDir, { recursive: true });
    }
    
    if (!fs.existsSync(buildDir)) {
      fs.mkdirSync(buildDir, { recursive: true });
    }
    
    // Write files from app.files to src directory
    if (app.files) {
      for (const fileType in app.files) {
        for (const filePath of app.files[fileType]) {
          const fileContent = await this.getFileContent(app._id, filePath);
          const destPath = path.join(srcDir, filePath);
          const destDir = path.dirname(destPath);
          
          if (!fs.existsSync(destDir)) {
            fs.mkdirSync(destDir, { recursive: true });
          }
          
          fs.writeFileSync(destPath, fileContent);
        }
      }
    }
    
    // Build the website
    await this.buildWebsite(app, srcDir, buildDir);
  }
  
  /**
   * Prepare WordPress theme files for deployment
   * @param {Object} app - WordPress theme object
   * @param {String} baseDir - Base directory for app files
   * @returns {Promise<void>}
   */
  async prepareWordPressThemeFiles(app, baseDir) {
    // Create theme directory
    const themeDir = path.join(baseDir, app.slug);
    
    if (!fs.existsSync(themeDir)) {
      fs.mkdirSync(themeDir, { recursive: true });
    }
    
    // Create style.css with theme information
    const styleCss = `/*
Theme Name: ${app.name}
Theme URI: ${app.previewUrl || ''}
Author: ${app.author ? app.author.name : 'AutoLaunch Studio'}
Author URI: ${app.author && app.author.url ? app.author.url : ''}
Description: ${app.description}
Version: ${app.version}
Requires at least: ${app.requires}
Tested up to: ${app.tested}
Requires PHP: 7.0
License: GNU General Public License v2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html
Text Domain: ${app.slug}
*/`;
    
    fs.writeFileSync(path.join(themeDir, 'style.css'), styleCss);
    
    // Write files from app.files to theme directory
    if (app.files) {
      for (const fileType in app.files) {
        for (const filePath of app.files[fileType]) {
          const fileContent = await this.getFileContent(app._id, filePath);
          const destPath = path.join(themeDir, filePath);
          const destDir = path.dirname(destPath);
          
          if (!fs.existsSync(destDir)) {
            fs.mkdirSync(destDir, { recursive: true });
          }
          
          fs.writeFileSync(destPath, fileContent);
        }
      }
    }
    
    // Create screenshot.png if it doesn't exist
    if (app.screenshot && !fs.existsSync(path.join(themeDir, 'screenshot.png'))) {
      const screenshotContent = await this.getFileContent(app._id, app.screenshot);
      fs.writeFileSync(path.join(themeDir, 'screenshot.png'), screenshotContent);
    }
    
    // Create zip file for theme
    const zipPath = path.join(baseDir, `${app.slug}.zip`);
    await this.createZipFile(themeDir, zipPath);
  }
  
  /**
   * Prepare WordPress plugin files for deployment
   * @param {Object} app - WordPress plugin object
   * @param {String} baseDir - Base directory for app files
   * @returns {Promise<void>}
   */
  async prepareWordPressPluginFiles(app, baseDir) {
    // Create plugin directory
    const pluginDir = path.join(baseDir, app.slug);
    
    if (!fs.existsSync(pluginDir)) {
      fs.mkdirSync(pluginDir, { recursive: true });
    }
    
    // Create main plugin file with plugin information
    const mainPluginFile = `<?php
/*
Plugin Name: ${app.name}
Plugin URI: ${app.previewUrl || ''}
Description: ${app.description}
Version: ${app.version}
Author: ${app.author ? app.author.name : 'AutoLaunch Studio'}
Author URI: ${app.author && app.author.url ? app.author.url : ''}
License: GPL2
License URI: https://www.gnu.org/licenses/gpl-2.0.html
Text Domain: ${app.slug}
Domain Path: /languages
*/

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

define('${app.slug.toUpperCase()}_VERSION', '${app.version}');
define('${app.slug.toUpperCase()}_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('${app.slug.toUpperCase()}_PLUGIN_URL', plugin_dir_url(__FILE__));

// Include the core plugin class
require plugin_dir_path(__FILE__) . 'includes/class-${app.slug}.php';

/**
 * Begins execution of the plugin.
 */
function run_${app.slug.replace(/-/g, '_')}() {
    $plugin = new ${app.slug.replace(/-/g, '_').replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); }).replace(/\s+/g, '_')}();
    $plugin->run();
}
run_${app.slug.replace(/-/g, '_')}();
`;
    
    fs.writeFileSync(path.join(pluginDir, `${app.slug}.php`), mainPluginFile);
    
    // Create readme.txt
    const readmeTxt = `=== ${app.name} ===
Contributors: ${app.author ? app.author.name.toLowerCase().replace(/\s+/g, '') : 'autolaunchstudio'}
Tags: ${app.category || 'plugin'}
Requires at least: ${app.requires}
Tested up to: ${app.tested}
Requires PHP: ${app.requiresPhp || '7.0'}
Stable tag: ${app.version}
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

${app.description}

== Description ==

${app.description}

== Installation ==

1. Upload the plugin files to the \`/wp-content/plugins/${app.slug}\` directory, or install the plugin through the WordPress plugins screen directly.
2. Activate the plugin through the 'Plugins' screen in WordPress
3. Configure the plugin settings

== Frequently Asked Questions ==

= Is this plugin free? =

Yes, this plugin is completely free to use.

== Screenshots ==

1. Plugin in action

== Changelog ==

= ${app.version} =
* Initial release

== Upgrade Notice ==

= ${app.version} =
Initial release
`;
    
    fs.writeFileSync(path.join(pluginDir, 'readme.txt'), readmeTxt);
    
    // Create basic directory structure
    const directories = ['admin', 'includes', 'public', 'languages'];
    
    for (const dir of directories) {
      const dirPath = path.join(pluginDir, dir);
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
      }
    }
    
    // Write files from app.files to plugin directory
    if (app.files) {
      for (const fileType in app.files) {
        for (const filePath of app.files[fileType]) {
          const fileContent = await this.getFileContent(app._id, filePath);
          const destPath = path.join(pluginDir, filePath);
          const destDir = path.dirname(destPath);
          
          if (!fs.existsSync(destDir)) {
            fs.mkdirSync(destDir, { recursive: true });
          }
          
          fs.writeFileSync(destPath, fileContent);
        }
      }
    }
    
    // Create zip file for plugin
    const zipPath = path.join(baseDir, `${app.slug}.zip`);
    await this.createZipFile(pluginDir, zipPath);
  }
  
  /**
   * Prepare browser extension files for deployment
   * @param {Object} app - Browser extension object
   * @param {String} baseDir - Base directory for app files
   * @returns {Promise<void>}
   */
  async prepareBrowserExtensionFiles(app, baseDir) {
    // Create extension directory
    const extensionDir = path.join(baseDir, app.slug);
    
    if (!fs.existsSync(extensionDir)) {
      fs.mkdirSync(extensionDir, { recursive: true });
    }
    
    // Create manifest.json
    const manifest = {
      manifest_version: app.manifestVersion || 3,
      name: app.name,
      version: app.version,
      description: app.description,
      author: app.author ? app.author.name : undefined,
      icons: app.action && app.action.defaultIcon ? app.action.defaultIcon : undefined,
      action: app.action ? {
        default_icon: app.action.defaultIcon,
        default_title: app.action.defaultTitle,
        default_popup: app.action.defaultPopup
      } 
(Content truncated due to size limit. Use line ranges to read in chunks)