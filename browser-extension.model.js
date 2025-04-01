const mongoose = require('mongoose');
const Schema = mongoose.Schema;

/**
 * Browser Extension Schema
 * Defines the structure for browser extensions created with AutoLaunch Studio
 */
const BrowserExtensionSchema = new Schema({
  // Basic extension information
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
  
  // Extension details
  icon: String,
  screenshots: [String],
  previewUrl: String,
  demoUrl: String,
  downloadUrl: String,
  
  // Browser compatibility
  browserCompatibility: [{
    browser: {
      type: String,
      enum: ['chrome', 'firefox', 'edge', 'safari', 'opera'],
      required: true
    },
    minVersion: String
  }],
  
  // Manifest version
  manifestVersion: {
    type: Number,
    enum: [2, 3],
    default: 3
  },
  
  // Extension type
  extensionType: {
    type: String,
    enum: [
      'browser_action',
      'page_action',
      'background',
      'content_script',
      'devtools',
      'options_page',
      'sidebar',
      'theme'
    ],
    default: 'browser_action'
  },
  
  // Permissions
  permissions: [{
    name: {
      type: String,
      enum: [
        'activeTab',
        'alarms',
        'background',
        'bookmarks',
        'browsingData',
        'clipboardRead',
        'clipboardWrite',
        'contentSettings',
        'contextMenus',
        'cookies',
        'declarativeContent',
        'declarativeNetRequest',
        'declarativeWebRequest',
        'desktopCapture',
        'downloads',
        'history',
        'identity',
        'idle',
        'management',
        'nativeMessaging',
        'notifications',
        'pageCapture',
        'privacy',
        'proxy',
        'scripting',
        'search',
        'sessions',
        'storage',
        'tabGroups',
        'tabs',
        'topSites',
        'tts',
        'ttsEngine',
        'unlimitedStorage',
        'webNavigation',
        'webRequest',
        'webRequestBlocking'
      ]
    },
    description: String,
    required: {
      type: Boolean,
      default: true
    }
  }],
  
  // Host permissions
  hostPermissions: [{
    pattern: String,
    description: String
  }],
  
  // Content scripts
  contentScripts: [{
    name: String,
    matches: [String],
    excludeMatches: [String],
    js: [String],
    css: [String],
    runAt: {
      type: String,
      enum: ['document_start', 'document_end', 'document_idle'],
      default: 'document_idle'
    },
    allFrames: {
      type: Boolean,
      default: false
    },
    matchAboutBlank: {
      type: Boolean,
      default: false
    }
  }],
  
  // Background scripts
  backgroundScripts: {
    scripts: [String],
    persistent: {
      type: Boolean,
      default: false
    },
    serviceWorker: {
      type: Boolean,
      default: true
    }
  },
  
  // Action (browser_action or page_action)
  action: {
    defaultIcon: {
      '16': String,
      '32': String,
      '48': String,
      '128': String
    },
    defaultTitle: String,
    defaultPopup: String
  },
  
  // Options page
  optionsPage: {
    page: String,
    openInTab: {
      type: Boolean,
      default: true
    }
  },
  
  // Web accessible resources
  webAccessibleResources: [{
    resources: [String],
    matches: [String]
  }],
  
  // Extension features
  features: {
    popup: {
      type: Boolean,
      default: true
    },
    options: {
      type: Boolean,
      default: true
    },
    contentScript: {
      type: Boolean,
      default: false
    },
    background: {
      type: Boolean,
      default: true
    },
    devtools: {
      type: Boolean,
      default: false
    },
    contextMenu: {
      type: Boolean,
      default: false
    },
    storage: {
      type: Boolean,
      default: true
    },
    notifications: {
      type: Boolean,
      default: false
    }
  },
  
  // Extension structure
  structure: {
    hasPopup: {
      type: Boolean,
      default: true
    },
    hasOptions: {
      type: Boolean,
      default: true
    },
    hasContentScript: {
      type: Boolean,
      default: false
    },
    hasBackground: {
      type: Boolean,
      default: true
    },
    hasDevtools: {
      type: Boolean,
      default: false
    }
  },
  
  // Extension files
  files: {
    html: [String],
    js: [String],
    css: [String],
    images: [String],
    manifest: String
  },
  
  // Store information
  storeInfo: {
    category: {
      type: String,
      enum: [
        'accessibility',
        'blogging',
        'developer-tools',
        'fun',
        'news-and-weather',
        'photos',
        'productivity',
        'search-tools',
        'shopping',
        'social-and-communication',
        'sports',
        'utilities'
      ],
      default: 'utilities'
    },
    price: {
      type: String,
      default: 'free'
    },
    privacyPolicyUrl: String,
    supportUrl: String
  },
  
  // Extension status
  status: {
    type: String,
    enum: ['draft', 'pending', 'published', 'archived'],
    default: 'draft'
  },
  
  // Creation and modification timestamps
  createdBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  }
}, { timestamps: true });

// Add text search index
BrowserExtensionSchema.index({
  name: 'text',
  description: 'text',
  'author.name': 'text'
});

// Create slug from name if not provided
BrowserExtensionSchema.pre('save', function(next) {
  if (!this.slug && this.name) {
    this.slug = this.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/-$/, '');
  }
  next();
});

module.exports = mongoose.model('BrowserExtension', BrowserExtensionSchema);
