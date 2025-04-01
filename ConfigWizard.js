import React, { useState, useEffect } from 'react';
import {
  Box,
  Container,
  Typography,
  Stepper,
  Step,
  StepLabel,
  Paper,
  Button,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  Switch,
  Grid,
  CircularProgress,
  Alert,
  Divider,
  InputAdornment,
  IconButton,
  Tabs,
  Tab
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  CheckCircle,
  Settings,
  Storage,
  Security,
  Code,
  CloudDone,
  Extension,
  PhoneAndroid,
  Web,
  WordPress
} from '@mui/icons-material';
import { toast } from 'react-toastify';

// Configuration wizard steps
const steps = [
  'Welcome',
  'Admin Account',
  'System Settings',
  'Database Setup',
  'Platform Support',
  'Deployment Settings',
  'Integrations',
  'Confirmation'
];

function ConfigWizard() {
  const [activeStep, setActiveStep] = useState(0);
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [platformTabValue, setPlatformTabValue] = useState(0);
  const [formData, setFormData] = useState({
    // Admin account
    adminName: '',
    adminEmail: '',
    adminPassword: '',
    adminPasswordConfirm: '',
    
    // System settings
    siteName: 'AutoLaunch Studio',
    siteUrl: 'https://apps.autolaunchstudio.com',
    frontendPort: 3000,
    backendPort: 3001,
    
    // Database settings
    databaseType: 'mongodb',
    databaseHost: 'localhost',
    databasePort: 27017,
    databaseName: 'autolaunch',
    databaseUser: '',
    databasePassword: '',
    
    // Platform support
    wordpressSupport: true,
    wordpressPort: 8080,
    wordpressAdminUser: 'admin',
    wordpressAdminPassword: '',
    
    browserExtensionSupport: true,
    browserExtensionTypes: ['chrome', 'firefox'],
    
    mobileAppSupport: true,
    mobileAppPlatforms: ['android', 'ios'],
    mobileAppBuildTools: true,
    
    // Deployment settings
    defaultEnvironment: 'staging',
    deploymentMethod: 'docker',
    autoDeployEnabled: true,
    requireApproval: true,
    notifyOnDeployment: true,
    
    // Integrations
    cursorAiEnabled: true,
    githubEnabled: false,
    githubToken: '',
    analyticsEnabled: true
  });
  
  const [errors, setErrors] = useState({});
  const [setupComplete, setSetupComplete] = useState(false);
  
  // Handle platform tab change
  const handlePlatformTabChange = (event, newValue) => {
    setPlatformTabValue(newValue);
  };
  
  // Check if setup has already been completed
  useEffect(() => {
    const checkSetupStatus = async () => {
      try {
        setIsLoading(true);
        
        // Simulate API call to check setup status
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // For demo purposes, assume setup is not completed
        setSetupComplete(false);
      } catch (error) {
        console.error('Error checking setup status:', error);
      } finally {
        setIsLoading(false);
      }
    };
    
    checkSetupStatus();
  }, []);
  
  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? checked : value
    });
    
    // Clear error for this field if it exists
    if (errors[name]) {
      setErrors({
        ...errors,
        [name]: null
      });
    }
  };
  
  // Handle array input changes (for multi-select)
  const handleArrayInputChange = (name, value) => {
    setFormData({
      ...formData,
      [name]: value
    });
    
    // Clear error for this field if it exists
    if (errors[name]) {
      setErrors({
        ...errors,
        [name]: null
      });
    }
  };
  
  // Toggle password visibility
  const handleTogglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };
  
  // Validate current step
  const validateStep = () => {
    const newErrors = {};
    
    switch (activeStep) {
      case 1: // Admin Account
        if (!formData.adminName.trim()) {
          newErrors.adminName = 'Admin name is required';
        }
        
        if (!formData.adminEmail.trim()) {
          newErrors.adminEmail = 'Admin email is required';
        } else if (!/\S+@\S+\.\S+/.test(formData.adminEmail)) {
          newErrors.adminEmail = 'Invalid email format';
        }
        
        if (!formData.adminPassword) {
          newErrors.adminPassword = 'Password is required';
        } else if (formData.adminPassword.length < 8) {
          newErrors.adminPassword = 'Password must be at least 8 characters';
        }
        
        if (formData.adminPassword !== formData.adminPasswordConfirm) {
          newErrors.adminPasswordConfirm = 'Passwords do not match';
        }
        break;
        
      case 2: // System Settings
        if (!formData.siteName.trim()) {
          newErrors.siteName = 'Site name is required';
        }
        
        if (!formData.siteUrl.trim()) {
          newErrors.siteUrl = 'Site URL is required';
        } else if (!/^https?:\/\/\S+/.test(formData.siteUrl)) {
          newErrors.siteUrl = 'Invalid URL format';
        }
        break;
        
      case 3: // Database Setup
        if (!formData.databaseHost.trim()) {
          newErrors.databaseHost = 'Database host is required';
        }
        
        if (!formData.databaseName.trim()) {
          newErrors.databaseName = 'Database name is required';
        }
        
        if (formData.databaseType !== 'mongodb' && !formData.databaseUser.trim()) {
          newErrors.databaseUser = 'Database user is required';
        }
        break;
        
      case 4: // Platform Support
        if (formData.wordpressSupport && !formData.wordpressAdminPassword) {
          newErrors.wordpressAdminPassword = 'WordPress admin password is required when WordPress support is enabled';
        }
        
        if (formData.browserExtensionSupport && formData.browserExtensionTypes.length === 0) {
          newErrors.browserExtensionTypes = 'Select at least one browser extension type';
        }
        
        if (formData.mobileAppSupport && formData.mobileAppPlatforms.length === 0) {
          newErrors.mobileAppPlatforms = 'Select at least one mobile app platform';
        }
        break;
        
      case 6: // Integrations
        if (formData.githubEnabled && !formData.githubToken.trim()) {
          newErrors.githubToken = 'GitHub token is required when GitHub integration is enabled';
        }
        break;
        
      default:
        break;
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };
  
  // Handle next button click
  const handleNext = () => {
    if (activeStep === 0 || validateStep()) {
      setActiveStep((prevActiveStep) => prevActiveStep + 1);
    }
  };
  
  // Handle back button click
  const handleBack = () => {
    setActiveStep((prevActiveStep) => prevActiveStep - 1);
  };
  
  // Handle form submission
  const handleSubmit = async () => {
    try {
      setIsLoading(true);
      
      // Simulate API call to save configuration
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Success
      toast.success('Configuration completed successfully!');
      setSetupComplete(true);
    } catch (error) {
      toast.error('Configuration failed: ' + error.message);
    } finally {
      setIsLoading(false);
    }
  };
  
  // Render step content
  const getStepContent = (step) => {
    switch (step) {
      case 0: // Welcome
        return (
          <Box sx={{ textAlign: 'center', py: 4 }}>
            <Typography variant="h4" gutterBottom>
              Welcome to AutoLaunch Studio!
            </Typography>
            <Typography variant="body1" paragraph>
              This wizard will guide you through the initial setup of your AutoLaunch Studio installation.
            </Typography>
            <Typography variant="body1" paragraph>
              AutoLaunch Studio is a comprehensive platform for creating, deploying, and managing various types of web applications, mobile apps, WordPress themes/plugins, browser extensions, and more.
            </Typography>
            <Typography variant="body1">
              Click "Next" to begin the setup process.
            </Typography>
          </Box>
        );
        
      case 1: // Admin Account
        return (
          <Box sx={{ py: 2 }}>
            <Typography variant="h6" gutterBottom>
              Create Admin Account
            </Typography>
            <Typography variant="body2" sx={{ mb: 3 }}>
              This account will have full administrative privileges.
            </Typography>
            
            <Grid container spacing={3}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Name"
                  name="adminName"
                  value={formData.adminName}
                  onChange={handleInputChange}
                  error={!!errors.adminName}
                  helperText={errors.adminName}
                  required
                />
              </Grid>
              
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Email"
                  name="adminEmail"
                  type="email"
                  value={formData.adminEmail}
                  onChange={handleInputChange}
                  error={!!errors.adminEmail}
                  helperText={errors.adminEmail}
                  required
                />
              </Grid>
              
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Password"
                  name="adminPassword"
                  type={showPassword ? 'text' : 'password'}
                  value={formData.adminPassword}
                  onChange={handleInputChange}
                  error={!!errors.adminPassword}
                  helperText={errors.adminPassword}
                  required
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          onClick={handleTogglePasswordVisibility}
                          edge="end"
                        >
                          {showPassword ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    )
                  }}
                />
              </Grid>
              
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Confirm Password"
                  name="adminPasswordConfirm"
                  type={showPassword ? 'text' : 'password'}
                  value={formData.adminPasswordConfirm}
                  onChange={handleInputChange}
                  error={!!errors.adminPasswordConfirm}
                  helperText={errors.adminPasswordConfirm}
                  required
                />
              </Grid>
            </Grid>
          </Box>
        );
        
      case 2: // System Settings
        return (
          <Box sx={{ py: 2 }}>
            <Typography variant="h6" gutterBottom>
              System Settings
            </Typography>
            <Typography variant="body2" sx={{ mb: 3 }}>
              Configure basic system settings for your AutoLaunch Studio installation.
            </Typography>
            
            <Grid container spacing={3}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Site Name"
                  name="siteName"
                  value={formData.siteName}
                  onChange={handleInputChange}
                  error={!!errors.siteName}
                  helperText={errors.siteName}
                  required
                />
              </Grid>
              
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Site URL"
                  name="siteUrl"
                  value={formData.siteUrl}
                  onChange={handleInputChange}
                  error={!!errors.siteUrl}
                  helperText={errors.siteUrl}
                  required
                />
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Frontend Port"
                  name="frontendPort"
                  type="number"
                  value={formData.frontendPort}
                  onChange={handleInputChange}
                  error={!!errors.frontendPort}
                  helperText={errors.frontendPort}
                />
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Backend Port"
                  name="backendPort"
                  type="number"
                  value={formData.backendPort}
                  onChange={handleInputChange}
                  error={!!errors.backendPort}
                  helperText={errors.backendPort}
                />
              </Grid>
            </Grid>
          </Box>
        );
        
      case 3: // Database Setup
        return (
          <Box sx={{ py: 2 }}>
            <Typography variant="h6" gutterBottom>
              Database Setup
            </Typography>
            <Typography variant="body2" sx={{ mb: 3 }}>
              Configure the database connection for your AutoLaunch Studio installation.
            </Typography>
            
            <Grid container spacing={3}>
              <Grid item xs={12}>
                <FormControl fullWidth>
                  <InputLabel>Database Type</InputLabel>
                  <Select
                    name="databaseType"
                    value={formData.databaseType}
                    onChange={handleInputChange}
                    label="Database Type"
                  >
                    <MenuItem value="mongodb">MongoDB</MenuItem>
                    <MenuItem value="postgres">PostgreSQL</MenuItem>
                    <MenuItem value="mysql">MySQL</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              
              <Grid item xs={12} sm={8}>
                <TextField
                  fullWidth
                  label="Database Host"
                  name="databaseHost"
                  value={formData.databaseHost}
                  onChange={handleInputChange}
                  error={!!errors.databaseHost}
                  helperText={errors.databaseHost}
                  required
                />
              </Grid>
              
              <Grid item xs={12} sm={4}>
                <TextField
                  fullWidth
                  label="Database Port"
                  name="databasePort"
                  type="number"
                  value={formData.databasePort}
                  onChange={handleInputChange}
                  error={!!errors.databasePort}
                  helperText={errors.databasePort}
                />
              </Grid>
              
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Database Name"
                  name="databaseName"
                  value={formData.databaseName}
                  onChange={handleInputChange}
                  error={!!errors.databaseName}
                  helperText={errors.databaseName}
                  required
                />
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Database User"
                  name="databaseUse
(Content truncated due to size limit. Use line ranges to read in chunks)