const mongoose = require('mongoose');
const Schema = mongoose.Schema;

/**
 * Mobile App Schema
 * Defines the structure for mobile applications created with AutoLaunch Studio
 */
const MobileAppSchema = new Schema({
  // Basic app information
  name: {
    type: String,
    required: true,
    trim: true
  },
  slug: {
    type: String,
    required: true,
    trim: true,
    lowercase: true,
    unique: true
  },
  description: {
    type: String,
    required: true
  },
  version: {
    type: String,
    default: '1.0.0'
  },
  author: {
    name: String,
    email: String,
    url: String
  },
  
  // App details
  icon: String,
  screenshots: [String],
  previewUrl: String,
  demoUrl: String,
  downloadUrl: String,
  
  // Platform compatibility
  platforms: [{
    type: String,
    enum: ['ios', 'android', 'pwa'],
    required: true
  }],
  
  // Minimum OS versions
  minOsVersions: {
    ios: String,
    android: String
  },
  
  // App type
  appType: {
    type: String,
    enum: ['native', 'hybrid', 'pwa', 'react-native', 'flutter'],
    default: 'react-native'
  },
  
  // App category
  category: {
    type: String,
    enum: [
      'business',
      'education',
      'entertainment',
      'finance',
      'food',
      'games',
      'health-fitness',
      'lifestyle',
      'medical',
      'music',
      'navigation',
      'news',
      'photo-video',
      'productivity',
      'shopping',
      'social',
      'sports',
      'travel',
      'utilities',
      'weather'
    ],
    default: 'utilities'
  },
  
  // App features
  features: [{
    name: String,
    description: String,
    icon: String
  }],
  
  // App screens
  screens: [{
    name: String,
    description: String,
    route: String,
    components: [String],
    screenshot: String
  }],
  
  // App navigation
  navigation: {
    type: {
      type: String,
      enum: ['stack', 'tab', 'drawer', 'bottom-tab', 'material-top-tab', 'mixed'],
      default: 'stack'
    },
    structure: Schema.Types.Mixed
  },
  
  // App state management
  stateManagement: {
    type: {
      type: String,
      enum: ['redux', 'mobx', 'context', 'recoil', 'zustand', 'none'],
      default: 'redux'
    },
    storeStructure: Schema.Types.Mixed
  },
  
  // API integration
  apiIntegration: {
    hasApi: {
      type: Boolean,
      default: true
    },
    endpoints: [{
      name: String,
      url: String,
      method: {
        type: String,
        enum: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
      },
      description: String
    }],
    authType: {
      type: String,
      enum: ['none', 'jwt', 'oauth', 'api-key'],
      default: 'jwt'
    }
  },
  
  // Authentication
  authentication: {
    enabled: {
      type: Boolean,
      default: true
    },
    methods: [{
      type: String,
      enum: ['email', 'phone', 'social', 'biometric']
    }],
    socialProviders: [{
      type: String,
      enum: ['google', 'facebook', 'apple', 'twitter']
    }]
  },
  
  // Storage
  storage: {
    local: {
      enabled: {
        type: Boolean,
        default: true
      },
      type: {
        type: String,
        enum: ['async-storage', 'secure-storage', 'sqlite', 'realm'],
        default: 'async-storage'
      }
    },
    remote: {
      enabled: {
        type: Boolean,
        default: true
      },
      type: {
        type: String,
        enum: ['firebase', 'aws', 'custom-api'],
        default: 'firebase'
      }
    }
  },
  
  // Notifications
  notifications: {
    enabled: {
      type: Boolean,
      default: true
    },
    types: [{
      type: String,
      enum: ['push', 'in-app', 'email']
    }],
    provider: {
      type: String,
      enum: ['firebase', 'onesignal', 'custom'],
      default: 'firebase'
    }
  },
  
  // Analytics
  analytics: {
    enabled: {
      type: Boolean,
      default: true
    },
    provider: {
      type: String,
      enum: ['firebase', 'google-analytics', 'mixpanel', 'amplitude', 'custom'],
      default: 'firebase'
    },
    events: [String]
  },
  
  // Monetization
  monetization: {
    strategy: [{
      type: String,
      enum: ['free', 'paid', 'freemium', 'subscription', 'ads', 'in-app-purchases']
    }],
    adTypes: [{
      type: String,
      enum: ['banner', 'interstitial', 'rewarded', 'native']
    }],
    subscriptionPlans: [{
      name: String,
      price: Number,
      interval: {
        type: String,
        enum: ['monthly', 'quarterly', 'yearly']
      },
      features: [String]
    }]
  },
  
  // App structure
  structure: {
    hasAuthentication: {
      type: Boolean,
      default: true
    },
    hasApi: {
      type: Boolean,
      default: true
    },
    hasNotifications: {
      type: Boolean,
      default: true
    },
    hasAnalytics: {
      type: Boolean,
      default: true
    },
    hasInAppPurchases: {
      type: Boolean,
      default: false
    },
    hasAds: {
      type: Boolean,
      default: false
    }
  },
  
  // App files
  files: {
    js: [String],
    assets: [String],
    config: [String]
  },
  
  // App status
  status: {
    type: String,
    enum: ['draft', 'pending', 'published', 'archived'],
    default: 'draft'
  },
  
  // Store information
  storeInfo: {
    appStoreId: String,
    playStoreId: String,
    privacyPolicyUrl: String,
    termsOfServiceUrl: String,
    supportUrl: String
  },
  
  // Creation and modification timestamps
  createdBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  }
}, { timestamps: true });

// Add text search index
MobileAppSchema.index({
  name: 'text',
  description: 'text',
  'author.name': 'text'
});

// Create slug from name if not provided
MobileAppSchema.pre('save', function(next) {
  if (!this.slug && this.name) {
    this.slug = this.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/-$/, '');
  }
  next();
});

module.exports = mongoose.model('MobileApp', MobileAppSchema);
