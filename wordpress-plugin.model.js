const mongoose = require('mongoose');
const Schema = mongoose.Schema;

/**
 * WordPress Plugin Schema
 * Defines the structure for WordPress plugins created with AutoLaunch Studio
 */
const WordPressPluginSchema = new Schema({
  // Basic plugin information
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
  
  // Plugin details
  icon: String,
  bannerImage: String,
  previewUrl: String,
  demoUrl: String,
  downloadUrl: String,
  
  // WordPress compatibility
  requires: {
    type: String,
    default: '5.0'
  },
  tested: {
    type: String,
    default: '6.4'
  },
  requiresPhp: {
    type: String,
    default: '7.0'
  },
  
  // Plugin category
  category: {
    type: String,
    enum: [
      'admin-tools',
      'blocks',
      'content-management',
      'e-commerce',
      'editor',
      'forms',
      'marketing',
      'media',
      'seo',
      'security',
      'social-media',
      'widgets',
      'other'
    ],
    default: 'other'
  },
  
  // Plugin features
  features: [{
    name: String,
    description: String
  }],
  
  // Plugin hooks
  hooks: {
    actions: [{
      name: String,
      description: String,
      parameters: [String]
    }],
    filters: [{
      name: String,
      description: String,
      parameters: [String]
    }]
  },
  
  // Admin pages
  adminPages: [{
    title: String,
    slug: String,
    capability: {
      type: String,
      default: 'manage_options'
    },
    icon: String,
    position: Number
  }],
  
  // Shortcodes
  shortcodes: [{
    tag: String,
    description: String,
    attributes: [{
      name: String,
      default: String,
      required: Boolean
    }],
    hasContent: {
      type: Boolean,
      default: false
    }
  }],
  
  // Database tables
  databaseTables: [{
    name: String,
    description: String,
    columns: [{
      name: String,
      type: String,
      nullable: Boolean,
      default: String
    }],
    indexes: [String]
  }],
  
  // Custom post types
  customPostTypes: [{
    name: String,
    slug: String,
    description: String,
    labels: {
      singular: String,
      plural: String
    },
    supports: [String],
    public: {
      type: Boolean,
      default: true
    },
    hasArchive: {
      type: Boolean,
      default: true
    },
    menuIcon: String
  }],
  
  // Custom taxonomies
  customTaxonomies: [{
    name: String,
    slug: String,
    description: String,
    labels: {
      singular: String,
      plural: String
    },
    hierarchical: {
      type: Boolean,
      default: false
    },
    postTypes: [String]
  }],
  
  // Widgets
  widgets: [{
    name: String,
    description: String,
    fields: [{
      name: String,
      type: String,
      label: String,
      default: String
    }]
  }],
  
  // Block editor blocks
  blocks: [{
    name: String,
    title: String,
    description: String,
    icon: String,
    category: String,
    attributes: [{
      name: String,
      type: String,
      default: Schema.Types.Mixed
    }]
  }],
  
  // REST API endpoints
  restApi: {
    enabled: {
      type: Boolean,
      default: false
    },
    namespace: {
      type: String,
      default: 'autolaunch/v1'
    },
    endpoints: [{
      route: String,
      methods: [{
        type: String,
        enum: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
      }],
      description: String,
      requiresAuth: {
        type: Boolean,
        default: false
      }
    }]
  },
  
  // Plugin dependencies
  dependencies: [{
    name: String,
    slug: String,
    required: {
      type: Boolean,
      default: false
    },
    version: String
  }],
  
  // Plugin structure
  structure: {
    hasSettings: {
      type: Boolean,
      default: true
    },
    hasAdminPages: {
      type: Boolean,
      default: false
    },
    hasFrontend: {
      type: Boolean,
      default: false
    },
    hasShortcodes: {
      type: Boolean,
      default: false
    },
    hasWidgets: {
      type: Boolean,
      default: false
    },
    hasBlocks: {
      type: Boolean,
      default: false
    },
    hasRestApi: {
      type: Boolean,
      default: false
    }
  },
  
  // Plugin files
  files: {
    php: [String],
    js: [String],
    css: [String],
    images: [String],
    languages: [String]
  },
  
  // Plugin status
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
WordPressPluginSchema.index({
  name: 'text',
  description: 'text',
  'author.name': 'text'
});

// Create slug from name if not provided
WordPressPluginSchema.pre('save', function(next) {
  if (!this.slug && this.name) {
    this.slug = this.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/-$/, '');
  }
  next();
});

module.exports = mongoose.model('WordPressPlugin', WordPressPluginSchema);
